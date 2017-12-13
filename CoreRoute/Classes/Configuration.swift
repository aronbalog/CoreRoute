public class Configuration: ParametersAware {
    var protectionSpace: ProtectionSpace?
    var isIgnoringProtection: Bool?
    var onSuccessBlocks: [Any] = []
    var onFailureBlocks: [ResultableFailureBlock] = []
    public var parameters: [String: Any]?
}

