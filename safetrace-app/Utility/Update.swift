import Foundation

@discardableResult
func update<Root: AnyObject>(_ value: Root, _ transforms: ((Root) -> Void)...) -> Root {
    transforms.forEach { $0(value) }
    return value
}
