import Foundation

public final class Registration: Configurable {
    public let route: AbstractRoute
    public let destination: Any
    
    public let configuration = Configuration()
    
    var context: [String: Any] = [:]
    
    init<R: Route>(route: R) {
        self.route = route
        self.destination = route.destination
    }
    
    init(route: AbstractRoute, destination: Any) {
        self.route = route
        self.destination = destination
    }
}
