import Foundation

struct SLog {
    static func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        items.forEach {
            Swift.print($0, separator: separator, terminator: terminator)
        }
        #endif
    }
}
