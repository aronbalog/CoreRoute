import Foundation

public class Task<R: AbstractRoute, D>: Resultable {
    public typealias RouteType = R
    public typealias DestinationType = D
    
    let request: Request<R, D>
    let routeMatcher: RouteMatching
    let registrations: [Registration]
    
    var onSuccessBlocks: [ResultableSuccessBlock<R, D>] = []
    var onFailureBlocks: [ResultableFailureBlock] = []
    
    init(request: Request<R, D>, routeMatcher: RouteMatching, registrations: [Registration]) {
        self.request = request
        self.routeMatcher = routeMatcher
        self.registrations = registrations
    }
    
    public func onSuccess(_ success: @escaping (Response<R, D>) -> Void) -> Self {
        onSuccessBlocks.append(success)

        return self
    }
    
    public func onFailure(_ failure: @escaping ResultableFailureBlock) -> Self {
        onFailureBlocks.append(failure)

        return self
    }
    
    @discardableResult public func execute() -> Response<R, D>? {
        guard let routeMatch = routeMatcher.match(route: request.route, from: registrations) else {
            onFailureBlocks.forEach({ (block) in
                block(RouteError.routeNotFound)
            })
            return nil
        }
        
        let registrationConfiguration = routeMatch.registration.configuration
        let requestConfiguration = request.configuration

        // protect if needed
        if let protectionSpace = getProtectionSpace(registrationConfiguration: registrationConfiguration, requestConfiguration: requestConfiguration) {
            var execution: (Response<R, D>)?
            
            let shouldProtect = protectionSpace.shouldProtect(unprotect: {
                execution = self.execute()
            }, failure: { (error) in
                self.onFailureBlocks.forEach({ (block) in
                    block(error)
                })
            })
            
            if shouldProtect {
                return execution
            }
        }
        
        // append success and failure blocks from registration
        if let registrationOnSuccessblocks = registrationConfiguration.onSuccessBlocks as? [ResultableSuccessBlock<R, D>] {
            onSuccessBlocks.append(contentsOf: registrationOnSuccessblocks)
        }
        onFailureBlocks.append(contentsOf: registrationConfiguration.onFailureBlocks)
        
        // prepare response
        return response(for: routeMatch, route: request.route, responseBlock: { (response) in
            self.onSuccessBlocks.forEach({ (responseBlock) in
                responseBlock(response)
            })
        })
    }
    
    private func response(for routeMatch: RouteMatchable, route: RouteType, responseBlock: @escaping (Response<R, D>) -> Void) -> Response<RouteType, D> {
        var _parameters: [String: Any] = routeMatch.parameters ?? [:]
        
        let registration = routeMatch.registration
        
        let requestConfiguration = request.configuration
        let registrationConfiguration = registration.configuration
        
        registrationConfiguration.parameters?.forEach { (item) in
            _parameters[item.key] = item.value
        }
        requestConfiguration.parameters?.forEach { (item) in
            _parameters[item.key] = item.value
        }
                
        let parameters = _parameters.count > 0 ? _parameters : nil
        
        let _destination: D? = {
            return routeMatch.registration.buildDestination?(_parameters) as? D
        }()
        
        guard let destination = _destination else { fatalError("Destination cannot be determined") }
        
        let response = Response(route: route, destination: destination, parameters: parameters, context: registration.context)
        
        responseBlock(response)
        
        return response
    }
    
    private func getProtectionSpace(registrationConfiguration: Configuration, requestConfiguration: Configuration) -> ProtectionSpace? {
        let _isIgnoringProtection = isIgnoringProtection(registrationConfiguration: registrationConfiguration, requestConfiguration: requestConfiguration)
        
        guard !_isIgnoringProtection else {
            return nil
        }
        
        let protectionSpace = requestConfiguration.protectionSpace ?? registrationConfiguration.protectionSpace
        
        return protectionSpace
    }
    
    private func isIgnoringProtection(registrationConfiguration: Configuration, requestConfiguration: Configuration) -> Bool {
        var isIgnoringProtection = false
        
        let isIgnoringProtectionFromRegistration = registrationConfiguration.isIgnoringProtection
        let isIgnoringProtectionFromRequest = requestConfiguration.isIgnoringProtection
        
        if let isIgnoringProtectionFromRegistration = isIgnoringProtectionFromRegistration {
            isIgnoringProtection = isIgnoringProtectionFromRegistration
        }
        if let isIgnoringProtectionFromRequest = isIgnoringProtectionFromRequest {
            isIgnoringProtection = isIgnoringProtectionFromRequest
        }
        
        return isIgnoringProtection
    }
}
