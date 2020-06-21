import ReactiveSwift

extension Signal {
    func debug(_ logPrefix: String = "", transform: @escaping (Value) -> Any = { $0 }) -> Signal<Value, Error> {
        return map {
            print("\(logPrefix): \(transform($0))")
            return $0
        }
        .mapError {
            print("\(logPrefix): \($0)")
            return $0
        }
    }
}
