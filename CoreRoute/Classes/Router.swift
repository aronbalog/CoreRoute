import Foundation

public class Router {
    internal(set) public var registrations: [Registration] = []

    let routeMatcher: RouteMatching
    
    public init(routeMatcher: RouteMatching = RouteMatcher.default) {
        self.routeMatcher = routeMatcher
    }

    public func request<R, D>(_ request: Request<R, D>) -> Task<R, D> {
        return Task<R, D>(request: request, routeMatcher: routeMatcher, registrations: registrations)
    }
    
    public func register<R: Route>(routeType: R.Type) {
        let registration = Registration(routeType: routeType)
        registrations.append(registration)
    }
    
    public func register(route: AbstractRoute, destination: Any) {
        let registration = Registration(route: route, destination: destination)
        registrations.append(registration)
    }
}

