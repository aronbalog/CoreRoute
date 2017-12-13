import Foundation

extension String {
    func stringByReplacing(_ replaceStrings: [String], with string: String) -> String {
        var stringObject = self
        
        for replaceString in replaceStrings {
            stringObject = stringObject.replacingOccurrences(of: replaceString, with: string)
        }
        
        return stringObject
    }
}
