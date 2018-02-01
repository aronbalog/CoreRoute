import Foundation

public protocol Route: AbstractRoute, ParametersAware {
    associatedtype Destination = Any
    
    static var destination: Destination { get }
    
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
