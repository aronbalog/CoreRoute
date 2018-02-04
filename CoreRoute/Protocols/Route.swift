import Foundation

public protocol Route: AbstractRoute, DestinationAware, ParametersAware {
    static var routePattern: String { get }
}

extension Route {
    public var routePath: String {
        return Self.routePattern
    }
    
    public var parameters: [String: Any]? {
        return nil
    }
    
    public static func buildParameters(with pathParameters: [String: Any]?) -> [String: Any]? {
        return pathParameters
    }
}
