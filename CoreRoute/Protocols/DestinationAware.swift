import Foundation

public protocol DestinationAware {
    associatedtype Destination = Any?
    
    static var destination: Destination { get }

    static func buildDestination(parameters: [String: Any]?) -> Any?
}

extension DestinationAware {
    public static func buildDestination(parameters: [String: Any]?) -> Any? {
        return destination
    }
}
