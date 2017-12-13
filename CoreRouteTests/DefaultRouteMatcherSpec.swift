import UIKit
import Quick
import Nimble

@testable import CoreRoute

enum AbstractRoute: String {
    case route1 = "mock-route-1"
}

struct MockRoute: CoreRoute.Route {
    typealias Destination = String
    
    var destination: String = "MockRoute-destination"
    
    var routePath: String = "mock-route-2"
    
    var parameters: [String : Any]? = [
        "key1": "value1"
    ]
}

class RouteMatcherSpec: QuickSpec {
    lazy var mockRegistrations: [Registration] = [
        Registration(route: AbstractRoute.route1.rawValue, destination: "My destination"),
        Registration(route: MockRoute())
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
                let match = self.sut.match(route: MockRoute(), from: self.mockRegistrations)
                it("matches route", closure: {
                    expect(match).notTo(beNil())
                    expect(match?.registration.destination).to(beAKindOf(MockRoute.Destination.self))
                })
                
                it("passes parameters", closure: {
                    expect(match?.parameters).notTo(beNil())
                    expect(match?.parameters?.count).to(equal(1))
                    expect(match!.parameters?.first?.key).to(equal("key1"))
                    expect(match!.parameters?.first?.value as? String).to(equal("value1"))
                })
            })
        }
    }
}

