import Foundation

extension URL: AbstractRoute {
    public var routePath: String {
        return absoluteString
    }
}
