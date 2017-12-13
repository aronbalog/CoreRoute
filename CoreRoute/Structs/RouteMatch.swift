import Foundation

struct RouteMatch: RouteMatchable {
    var registration: Registration
    
    var parameters: [String : Any]?
}
