import Foundation

public class RouteMatcher: RouteMatching {
    private let allCharactersRegexPattern = "([^</]*)"

    public static let `default` = RouteMatcher()
    
    public func match<R: AbstractRoute>(route: R, from registrations: [Registration]) -> RouteMatchable? {
        var routeMatch: RouteMatch?
        
        registrations.forEach { (registration) in
            if let _routeMatch = match(registration: registration, compareTo: route) {
                routeMatch = _routeMatch
                
                return
            }
        }
        
        return routeMatch
    }
    
    
    private func match(registration: Registration, compareTo calledRoute: AbstractRoute) -> RouteMatch? {
        let (registrationPath, registrationQueryParameters) = stripQueryParameters(from: registration.route.routePath)
        let (calledPath, calledQueryParameters) = stripQueryParameters(from: calledRoute.routePath)
        
        var routeCandidateRegexPattern = registrationPath
        let routeParameterNames = self.routeParameterNames(from: registrationPath)
        
        let uuidString = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        
        routeParameterNames.forEach { (routeParameterName) in
            routeCandidateRegexPattern = routeCandidateRegexPattern.replacingOccurrences(of: routeParameterName, with: uuidString)
        }
        
        routeCandidateRegexPattern = NSRegularExpression.escapedPattern(for: routeCandidateRegexPattern)
        
        routeCandidateRegexPattern = routeCandidateRegexPattern.replacingOccurrences(of: uuidString, with: allCharactersRegexPattern)
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", routeCandidateRegexPattern)
        let matches = predicate.evaluate(with: calledPath)
        
        guard matches else {
            return nil
        }
        
        var parameters: [String: Any] = [:]
        
        let pathParameters = extractParameters(from: calledRoute, routeParameterNames: routeParameterNames, regexPattern: routeCandidateRegexPattern)
        
        if let routeParameters = (registration.route as? ParametersAware)?.parameters {
            parameters.merge(routeParameters) { (_, newValue) -> Any in
                return newValue
            }
        }
        
        if let registrationStorageItemRegistrationParameters = registration.configuration.parameters {
            parameters.merge(registrationStorageItemRegistrationParameters) { (_, newValue) -> Any in
                return newValue
            }
        }

        if let defaultRouteParameters = (calledRoute as? ParametersAware)?.parameters {
            parameters.merge(defaultRouteParameters) { (_, newValue) -> Any in
                return newValue
            }
        }
        parameters.merge(registrationQueryParameters) { (_, newValue) -> Any in
            return newValue
        }
        parameters.merge(calledQueryParameters) { (_, newValue) -> Any in
            return newValue
        }
        parameters.merge(pathParameters) { (_, newValue) -> Any in
            return newValue
        }
        
        return RouteMatch(
            registration: registration,
            parameters: parameters
        )
    }
    
    private func stripQueryParameters(from routePath: String) -> (routePath: String, parameters: [String: String]) {
        let components = routePath.split(separator: "?", maxSplits: 1, omittingEmptySubsequences: false)
        
        guard components.count == 2 else {
            return (routePath, [:])
        }
        
        let pathComponent = components[0]
        let parametersComponent = components[1]
        
        let pairs = parametersComponent.split(separator: "&")
        
        var parameters: [String: String] = [:]
        
        pairs.forEach { (pair) in
            guard pair.contains("=") else { return }
            
            let keyAndValue = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            let key = keyAndValue[0]
            let value = keyAndValue[1]
            
            parameters[String(key)] = String(value)
        }
        
        return (String(pathComponent), parameters)
    }
    
    private func extractParameters(from route: AbstractRoute, routeParameterNames: [String], regexPattern: String) -> [String: Any] {
        var parameters: Dictionary<String, Any> = [:]
        
        if let routeParameterValues = self.routeParameterValues(from: route.routePath, regexPattern: regexPattern) {
            let _routeParameterNames = routeParameterNames.map({ (name) -> String in
                return name.stringByReplacing(["<", ">"], with: "")
            })
            
            if routeParameterNames.count == routeParameterValues.count {
                parameters = Dictionary<String, Any>.init(keys: _routeParameterNames, values: routeParameterValues)
            }
        }
        
        return parameters
    }
    
    private func routeParameterNames(from path: String) -> [String] {
        let regexPattern = "\\<[^</]*\\>"
        let regex = try! NSRegularExpression(pattern: regexPattern, options: .caseInsensitive)
        let results = regex.matches(in: path, range: NSRange(path.startIndex..., in: path))
        
        let names = results.map { (result) -> String in
            let range = Range(result.range, in: path)!
            return String(path[range])
        }
        
        return names
    }
    
    private func routeParameterValues(from path: String, regexPattern: String) -> [String]? {
        let regex = try! NSRegularExpression(pattern: regexPattern, options: [NSRegularExpression.Options.caseInsensitive])
        
        guard let result = regex.firstMatch(in: path, options: [], range: NSRange.init(location: 0, length: path.count)) else {
            return nil
        }
        
        var values: [String] = []
        
        for index in 1..<result.numberOfRanges {
            let range = result.range(at: index)
            let value = (path as NSString).substring(with: range)
            
            values.append(value)
        }
        
        return values.count > 0 ? values : nil
    }
}
