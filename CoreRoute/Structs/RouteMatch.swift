import Foundation

struct RouteMatch: RouteMatchable {
    var registration: Registration
    
    var parameters: [String : Any]?
    
    static func buildParameters(with pathParameters: [String : Any]?) -> [String : Any]? {
        return pathParameters
    }
}
