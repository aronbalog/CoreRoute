import Foundation

public class Response<R: AbstractRoute, D> {
    public let route: R
    public let destination: D?
    public let parameters: [String: Any]?
    public let context: [String: Any]
    
    init(route: R, destination: D, parameters: [String: Any]?, context: [String: Any] = [:]) {
        self.route = route
        self.destination = destination
        self.parameters = parameters
        self.context = context
    }
}
