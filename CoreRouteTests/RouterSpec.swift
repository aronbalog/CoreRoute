import Quick
import Nimble

@testable import CoreRoute

class MockProtectionSpaceUnprotecting: ProtectionSpace {
    var invokeCount: Int = 0
    var shouldProtect: Bool = true
    
    func shouldProtect(unprotect: @escaping () -> Void, failure: @escaping (Error) -> Void) -> Bool {
        invokeCount += 1
        if invokeCount > 1 {
            return false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.shouldProtect = false
            unprotect()
        }
        return shouldProtect
    }
}

enum MockError: Error {
    case protectionFailure
}

class MockProtectionSpaceFailing: ProtectionSpace {
    var invokeCount: Int = 0
    var shouldProtect: Bool = true
    
    func shouldProtect(unprotect: @escaping () -> Void, failure: @escaping (Error) -> Void) -> Bool {
        invokeCount += 1
        if invokeCount > 1 {
            return false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.shouldProtect = true
            failure(MockError.protectionFailure)
        }
        return shouldProtect
    }
}


class RouterSpec: QuickSpec {
    lazy var sut: Router = Router()
    
    override func spec() {
        describe("Router") {
            sut.register(route: "mock-route", destination: "")
            
            context("when request is made", {
                let request = Request<String, String>(route: "mock-route").parameters(["key1": "value1"])
                let task = self.sut.request(request)
                
                var response: Response<String, String>?
                var error: Error?
                
                response = task
                    .onSuccess({ (_response) in
                        response = _response
                    })
                    .onFailure({ (_error) in
                        error = _error
                    })
                    .execute()
                
                
                it("response is returned", closure: {
                    expect(response).toEventuallyNot(beNil())
                })
                it("response has parameters", closure: {
                    expect(response?.parameters?.first?.key).to(equal("key1"))
                    expect(response?.parameters?.first?.value as? String).to(equal("value1"))
                })
                it("error is not returned", closure: {
                    expect(error).toEventually(beNil())
                })
            })
            
            context("when request is made with protection that is unprotecting", {
                let protectionSpace = MockProtectionSpaceUnprotecting()
                
                let request = Request<String, String>(route: "mock-route")
                    .parameters(["key1": "value1"])
                    .protect(with: protectionSpace)
                
                let task = self.sut.request(request)
                
                var response: Response<String, String>?
                var asyncResponse: Response<String, String>?
                var error: Error?
                
                response = task
                    .onSuccess({ (_response) in
                        asyncResponse = _response
                    })
                    .onFailure({ (_error) in
                        error = _error
                    })
                    .execute()
                
                it("does not return response immediately", closure: {
                    expect(response).to(beNil())
                    expect(error).to(beNil())
                })
                
                it("response is returned after unprotect", closure: {
                    expect(asyncResponse).toEventuallyNot(beNil(), timeout: 2, pollInterval: 0.1, description: nil)
                })
                
                it("response has parameters", closure: {
                    expect(asyncResponse?.parameters?.first?.key).toEventually(equal("key1"))
                    expect(asyncResponse?.parameters?.first?.value as? String).toEventually(equal("value1"))
                })
                
                it("error is not returned", closure: {
                    expect(error).toEventually(beNil(), timeout: 2, pollInterval: 0.1, description: nil)
                })
            })
            
            context("when request is made with protection that is failing", {
                let protectionSpace = MockProtectionSpaceFailing()

                let request = Request<String, String>(route: "mock-route")
                    .parameters(["key1": "value1"])
                    .protect(with: protectionSpace)
                
                let task = self.sut.request(request)
                
                var response: Response<String, String>?
                var asyncResponse: Response<String, String>?
                var error: Error?
                
                response = task
                    .onSuccess({ (_response) in
                        asyncResponse = _response
                    })
                    .onFailure({ (_error) in
                        error = _error
                    })
                    .execute()
                
                it("does not return response", closure: {
                    expect(response).to(beNil())
                })
                
                it("response is not returned on failure", closure: {
                    expect(asyncResponse).toEventually(beNil(), timeout: 2, pollInterval: 0.1, description: nil)
                })
                
                it("error is returned on failure", closure: {
                    expect(error).toEventuallyNot(beNil(), timeout: 2, pollInterval: 0.1, description: nil)
                })
            })
        }
    }
}
