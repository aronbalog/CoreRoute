import Foundation

public class Router {
    internal(set) public var registrations: [Registration] = []

    let routeMatcher: RouteMatching
    
    public init(routeMatcher: RouteMatching = RouteMatcher.default) {
        self.routeMatcher = routeMatcher
    }
    
    subscript<R: Route>(route: R) -> Task<R, R.Destination> {
        get {
            let _request = Request<R, R.Destination>(route: route)
            return request(_request)
        }
        set {
            register(route: route)
        }
    }

    public func request<R, D>(_ request: Request<R, D>) -> Task<R, D> {
        return Task<R, D>(request: request, routeMatcher: routeMatcher, registrations: registrations)
    }
    
    public func register<R: Route>(route: R) {
        let registration = Registration(route: route, destination: route.destination)
        registrations.append(registration)
    }
    
    public func register(route: AbstractRoute, destination: Any) {
        let registration = Registration(route: route, destination: destination)
        registrations.append(registration)
    }
}

