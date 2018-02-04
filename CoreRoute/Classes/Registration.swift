import Foundation

public final class Registration: Configurable {
    public let routePattern: String
    public let destination: Any?
    public let buildDestination: (([String: Any]?) -> Any?)?
    public let routeType: AbstractRoute.Type?
    public let route: AbstractRoute?
    
    public let configuration = Configuration()
    
    var context: [String: Any] = [:]
    
    init<R: Route>(routeType: R.Type) {
        self.routePattern = routeType.routePattern
        self.routeType = routeType
        self.destination = routeType.destination
        self.buildDestination = routeType.buildDestination
        self.route = nil
    }
    
    init(route: AbstractRoute, destination: Any) {
        self.routePattern = route.routePath
        self.routeType = type(of: route)
        self.destination = destination
        self.buildDestination = nil
        self.route = route
    }
}
