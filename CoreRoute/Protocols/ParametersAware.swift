import Foundation

public protocol ParametersAware {
    var parameters: [String: Any]? { get }
    
    static func buildParameters(with pathParameters: [String: Any]?) -> [String: Any]?
}
