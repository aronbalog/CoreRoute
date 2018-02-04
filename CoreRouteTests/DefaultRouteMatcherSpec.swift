import UIKit
import Quick
import Nimble

@testable import CoreRoute

enum AbstractRoute: String {
    case route1 = "mock-route-1"
}

struct MockRoute2: CoreRoute.Route {
    static var destination: String = "MockRoute-destination"
    
    typealias Destination = String
    
    var routePath: String = "mock-route-2"
    static var routePattern: String = "mock-route-2"
    
    var parameters: [String : Any]? = [
        "key1": "value1"
    ]
}

struct MockRoute3: CoreRoute.Route {
    typealias Destination = String
    
    static var destination: String = "MockRoute-destination"
    
    var routePath: String = "mock-route/-3"
    static var routePattern: String = "mock-route/-<id>"
    
    var parameters: [String : Any]? = [
        "key1": "value1"
    ]
    
    static func buildParameters(with pathParameters: [String: Any]?) -> [String: Any]? {
        return ["key1": "value1"]
    }
}

class RouteMatcherSpec: QuickSpec {
    lazy var mockRegistrations: [Registration] = [
        Registration(route: AbstractRoute.route1.rawValue, destination: "My destination"),
        Registration(routeType: MockRoute2.self),
        Registration(routeType: MockRoute3.self)
    ]
    
    var sut: RouteMatcher {
        return RouteMatcher.default
    }
    
    override func spec() {
        describe("RouteMatcher") {
            context("when matching abstract route from registrations", {
                let match = self.sut.match(route: AbstractRoute.route1.rawValue, from: self.mockRegistrations)
                it("matches route", closure: {
                    expect(match).notTo(beNil())
                    expect(match?.registration.destination).to(beAKindOf(String.self))
                    expect(match?.registration.destination as? String).to(equal("My destination"))
                })
            })
            
            context("when matching non-abstract route from registrations", {
                let match = self.sut.match(route: MockRoute2(), from: self.mockRegistrations)
                it("matches route", closure: {
                    expect(match).notTo(beNil())
                })
                
                it("passes parameters", closure: {
                    let parameters = match?.parameters
                    expect(parameters).notTo(beNil())
                    expect(parameters?.count).to(equal(1))
                    expect(match!.parameters?.first?.key).to(equal("key1"))
                    expect(match!.parameters?.first?.value as? String).to(equal("value1"))
                })
            })
            
            context("when matching non-abstract route from registrations", {
                let match = self.sut.match(route: MockRoute3(), from: self.mockRegistrations)
                it("matches route", closure: {
                    expect(match).notTo(beNil())
                })
                
                it("passes parameters", closure: {
                    let parameters = match?.parameters
                    expect(parameters).notTo(beNil())
                    expect(parameters?.count).to(equal(2))
                    expect(match!.parameters?["key1"] as? String).to(equal("value1"))
                    expect(match!.parameters?["id"] as? String).to(equal("3"))
                })
            })
            
            context("when matching non-abstract route from registrations", {
                let match = self.sut.match(route: "mock-route/-4", from: self.mockRegistrations)
                it("matches route", closure: {
                    expect(match).notTo(beNil())
                })
                
                it("passes parameters", closure: {
                    let parameters = match?.parameters
                    expect(parameters).notTo(beNil())
                    expect(parameters?.count).to(equal(2))
//                    expect(match!.parameters?["key1"] as? String).to(equal("value1"))
                    expect(match!.parameters?["id"] as? String).to(equal("4"))
                })
            })
        }
    }
}

