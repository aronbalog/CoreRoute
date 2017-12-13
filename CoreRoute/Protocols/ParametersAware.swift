import Foundation

public protocol ParametersAware {
    var parameters: [String: Any]? { get set }
}
