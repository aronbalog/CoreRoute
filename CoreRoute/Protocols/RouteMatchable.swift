import Foundation

public protocol RouteMatchable: ParametersAware {
    var registration: Registration { get }
}
