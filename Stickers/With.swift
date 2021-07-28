
import Foundation


func modify<T>(_ object: T, _ modifier: (inout T) -> ()) -> T {
    var copy = object
    modifier(&copy)
    return copy
}

extension NSObjectProtocol {
    @discardableResult func with(_ modifier: (inout Self) -> ()) -> Self {
        var copy = self
        modifier(&copy)
        return copy
    }
}
