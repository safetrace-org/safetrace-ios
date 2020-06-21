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

extension SignalProducer where Error == Never {
    /// Creates a SignalProducer with an async method that produces a single value and terminates.
    init(_ handler: @escaping (_ completion: @escaping (Value) -> Void) -> Void) {
        self = .init({ observer, lifetime in
            let completion = { (value: Value) in
                observer.send(value: value)
                observer.sendCompleted()
            }

            handler(completion)
        })
    }
}
