import Foundation

public protocol RouteMatching {
    func match<R: AbstractRoute>(route: R, from registrations: [Registration]) -> RouteMatchable?
}
