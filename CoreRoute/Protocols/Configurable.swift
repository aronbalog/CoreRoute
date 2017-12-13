import Foundation

public protocol Configurable: ConfigurationAware {
    func protect(with protectionSpace: ProtectionSpace) -> Self
    func ignoreProtection(_ ignoreProtection: Bool) -> Self
    func onSuccess<R: Route, D>(_ success: @escaping ResultableSuccessBlock<R, D>) -> Self
    func onFailure(_ failure: @escaping ResultableFailureBlock) -> Self
    func parameters(_ parameters: [String: Any]?) -> Self
}

extension Configurable {
    public func protect(with protectionSpace: ProtectionSpace) -> Self {
        configuration.protectionSpace = protectionSpace
        
        return self
    }
    
    public func ignoreProtection(_ ignoreProtection: Bool) -> Self {
        configuration.isIgnoringProtection = ignoreProtection
        
        return self
    }
    
    public func onSuccess<R: Route, D>(_ success: @escaping ResultableSuccessBlock<R, D>) -> Self {
        configuration.onSuccessBlocks.append(success)
        
        return self
    }
    
    public func onFailure(_ failure: @escaping ResultableFailureBlock) -> Self {
        configuration.onFailureBlocks.append(failure)
        
        return self
    }
    
    public func parameters(_ parameters: [String: Any]?) -> Self {
        configuration.parameters = parameters
        
        return self
    }

}
