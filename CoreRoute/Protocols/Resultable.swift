import Foundation

public typealias ResultableSuccessBlock<R: AbstractRoute, D> = (Response<R, D>) -> Void
public typealias ResultableFailureBlock = (Error) -> Void

public protocol Resultable {
    associatedtype RouteType: AbstractRoute
    associatedtype DestinationType
    
    func onSuccess(_ success: @escaping ResultableSuccessBlock<RouteType, DestinationType>) -> Self
    func onFailure(_ failure: @escaping ResultableFailureBlock) -> Self
}

