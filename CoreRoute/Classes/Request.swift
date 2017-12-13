import Foundation

public final class Request<R: AbstractRoute, D>: Configurable {
    public let route: R
    
    public let configuration = Configuration()
    
    public init(route: R, parameters: [String: Any]? = nil) {
        self.route = route
        self.configuration.parameters = parameters
    }
}
