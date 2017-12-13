import Foundation

public protocol Route: AbstractRoute, ParametersAware {
    associatedtype Destination = Any
    
    var destination: Destination { get }
}

extension Route {
    public var parameters: [String: Any]? {
        get {
            return nil
        }
        set {
            
        }
    }
}
