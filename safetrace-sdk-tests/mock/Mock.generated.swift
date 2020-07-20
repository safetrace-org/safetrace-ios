// Generated using Sourcery 0.17.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT



// Generated with SwiftyMocky 3.5.0

import SwiftyMocky
#if !MockyCustom
import XCTest
#endif
import AdSupport
import CoreBluetooth
import CoreLocation
import Foundation
import UIKit
import UserNotifications
import WebKit
@testable import SafeTrace


// MARK: - BluetoothCentralDelegate
open class BluetoothCentralDelegateMock: BluetoothCentralDelegate, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    open func didFinishTrace(_ trace: ContactTrace) {
        addInvocation(.m_didFinishTrace__trace(Parameter<ContactTrace>.value(`trace`)))
		let perform = methodPerformValue(.m_didFinishTrace__trace(Parameter<ContactTrace>.value(`trace`))) as? (ContactTrace) -> Void
		perform?(`trace`)
    }

    open func logError(_: String, context _: String, meta: [String: Any]?) {
        addInvocation(.m_logError__metacontextmeta(Parameter<[String: Any]?>.value(`meta`)))
		let perform = methodPerformValue(.m_logError__metacontextmeta(Parameter<[String: Any]?>.value(`meta`))) as? ([String: Any]?) -> Void
		perform?(`meta`)
    }


    fileprivate enum MethodType {
        case m_didFinishTrace__trace(Parameter<ContactTrace>)
        case m_logError__metacontextmeta(Parameter<[String: Any]?>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_didFinishTrace__trace(let lhsTrace), .m_didFinishTrace__trace(let rhsTrace)):
                guard Parameter.compare(lhs: lhsTrace, rhs: rhsTrace, with: matcher) else { return false } 
                return true 
            case (.m_logError__metacontextmeta(let lhsMeta), .m_logError__metacontextmeta(let rhsMeta)):
                guard Parameter.compare(lhs: lhsMeta, rhs: rhsMeta, with: matcher) else { return false } 
                return true 
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_didFinishTrace__trace(p0): return p0.intValue
            case let .m_logError__metacontextmeta(p0): return p0.intValue
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func didFinishTrace(_ trace: Parameter<ContactTrace>) -> Verify { return Verify(method: .m_didFinishTrace__trace(`trace`))}
        public static func logError(meta: Parameter<[String: Any]?>) -> Verify { return Verify(method: .m_logError__metacontextmeta(`meta`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func didFinishTrace(_ trace: Parameter<ContactTrace>, perform: @escaping (ContactTrace) -> Void) -> Perform {
            return Perform(method: .m_didFinishTrace__trace(`trace`), performs: perform)
        }
        public static func logError(meta: Parameter<[String: Any]?>, perform: @escaping ([String: Any]?) -> Void) -> Perform {
            return Perform(method: .m_logError__metacontextmeta(`meta`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - KeychainProtocol
open class KeychainProtocolMock: KeychainProtocol, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }

    public var accessGroup: String? {
		get {	invocations.append(.p_accessGroup_get); return __p_accessGroup ?? optionalGivenGetterValue(.p_accessGroup_get, "KeychainProtocolMock - stub value for accessGroup was not defined") }
		set {	invocations.append(.p_accessGroup_set(.value(newValue))); __p_accessGroup = newValue }
	}
	private var __p_accessGroup: (String)?





    open func set(_ value: String, forKey key: String, withAccess: KeychainSwiftAccessOptions?) -> Bool {
        addInvocation(.m_set__valueforKey_keywithAccess_withAccess(Parameter<String>.value(`value`), Parameter<String>.value(`key`), Parameter<KeychainSwiftAccessOptions?>.value(`withAccess`)))
		let perform = methodPerformValue(.m_set__valueforKey_keywithAccess_withAccess(Parameter<String>.value(`value`), Parameter<String>.value(`key`), Parameter<KeychainSwiftAccessOptions?>.value(`withAccess`))) as? (String, String, KeychainSwiftAccessOptions?) -> Void
		perform?(`value`, `key`, `withAccess`)
		var __value: Bool
		do {
		    __value = try methodReturnValue(.m_set__valueforKey_keywithAccess_withAccess(Parameter<String>.value(`value`), Parameter<String>.value(`key`), Parameter<KeychainSwiftAccessOptions?>.value(`withAccess`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for set(_ value: String, forKey key: String, withAccess: KeychainSwiftAccessOptions?). Use given")
			Failure("Stub return value not specified for set(_ value: String, forKey key: String, withAccess: KeychainSwiftAccessOptions?). Use given")
		}
		return __value
    }

    open func get(_ key: String) -> String? {
        addInvocation(.m_get__key(Parameter<String>.value(`key`)))
		let perform = methodPerformValue(.m_get__key(Parameter<String>.value(`key`))) as? (String) -> Void
		perform?(`key`)
		var __value: String? = nil
		do {
		    __value = try methodReturnValue(.m_get__key(Parameter<String>.value(`key`))).casted()
		} catch {
			// do nothing
		}
		return __value
    }

    open func delete(_ key: String) -> Bool {
        addInvocation(.m_delete__key(Parameter<String>.value(`key`)))
		let perform = methodPerformValue(.m_delete__key(Parameter<String>.value(`key`))) as? (String) -> Void
		perform?(`key`)
		var __value: Bool
		do {
		    __value = try methodReturnValue(.m_delete__key(Parameter<String>.value(`key`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for delete(_ key: String). Use given")
			Failure("Stub return value not specified for delete(_ key: String). Use given")
		}
		return __value
    }


    fileprivate enum MethodType {
        case m_set__valueforKey_keywithAccess_withAccess(Parameter<String>, Parameter<String>, Parameter<KeychainSwiftAccessOptions?>)
        case m_get__key(Parameter<String>)
        case m_delete__key(Parameter<String>)
        case p_accessGroup_get
		case p_accessGroup_set(Parameter<String?>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_set__valueforKey_keywithAccess_withAccess(let lhsValue, let lhsKey, let lhsWithaccess), .m_set__valueforKey_keywithAccess_withAccess(let rhsValue, let rhsKey, let rhsWithaccess)):
                guard Parameter.compare(lhs: lhsValue, rhs: rhsValue, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsKey, rhs: rhsKey, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsWithaccess, rhs: rhsWithaccess, with: matcher) else { return false } 
                return true 
            case (.m_get__key(let lhsKey), .m_get__key(let rhsKey)):
                guard Parameter.compare(lhs: lhsKey, rhs: rhsKey, with: matcher) else { return false } 
                return true 
            case (.m_delete__key(let lhsKey), .m_delete__key(let rhsKey)):
                guard Parameter.compare(lhs: lhsKey, rhs: rhsKey, with: matcher) else { return false } 
                return true 
            case (.p_accessGroup_get,.p_accessGroup_get): return true
			case (.p_accessGroup_set(let left),.p_accessGroup_set(let right)): return Parameter<String?>.compare(lhs: left, rhs: right, with: matcher)
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_set__valueforKey_keywithAccess_withAccess(p0, p1, p2): return p0.intValue + p1.intValue + p2.intValue
            case let .m_get__key(p0): return p0.intValue
            case let .m_delete__key(p0): return p0.intValue
            case .p_accessGroup_get: return 0
			case .p_accessGroup_set(let newValue): return newValue.intValue
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }

        public static func accessGroup(getter defaultValue: String?...) -> PropertyStub {
            return Given(method: .p_accessGroup_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }

        public static func set(_ value: Parameter<String>, forKey key: Parameter<String>, withAccess: Parameter<KeychainSwiftAccessOptions?>, willReturn: Bool...) -> MethodStub {
            return Given(method: .m_set__valueforKey_keywithAccess_withAccess(`value`, `key`, `withAccess`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func get(_ key: Parameter<String>, willReturn: String?...) -> MethodStub {
            return Given(method: .m_get__key(`key`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func delete(_ key: Parameter<String>, willReturn: Bool...) -> MethodStub {
            return Given(method: .m_delete__key(`key`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func set(_ value: Parameter<String>, forKey key: Parameter<String>, withAccess: Parameter<KeychainSwiftAccessOptions?>, willProduce: (Stubber<Bool>) -> Void) -> MethodStub {
            let willReturn: [Bool] = []
			let given: Given = { return Given(method: .m_set__valueforKey_keywithAccess_withAccess(`value`, `key`, `withAccess`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (Bool).self)
			willProduce(stubber)
			return given
        }
        public static func get(_ key: Parameter<String>, willProduce: (Stubber<String?>) -> Void) -> MethodStub {
            let willReturn: [String?] = []
			let given: Given = { return Given(method: .m_get__key(`key`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (String?).self)
			willProduce(stubber)
			return given
        }
        public static func delete(_ key: Parameter<String>, willProduce: (Stubber<Bool>) -> Void) -> MethodStub {
            let willReturn: [Bool] = []
			let given: Given = { return Given(method: .m_delete__key(`key`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (Bool).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func set(_ value: Parameter<String>, forKey key: Parameter<String>, withAccess: Parameter<KeychainSwiftAccessOptions?>) -> Verify { return Verify(method: .m_set__valueforKey_keywithAccess_withAccess(`value`, `key`, `withAccess`))}
        public static func get(_ key: Parameter<String>) -> Verify { return Verify(method: .m_get__key(`key`))}
        public static func delete(_ key: Parameter<String>) -> Verify { return Verify(method: .m_delete__key(`key`))}
        public static var accessGroup: Verify { return Verify(method: .p_accessGroup_get) }
		public static func accessGroup(set newValue: Parameter<String?>) -> Verify { return Verify(method: .p_accessGroup_set(newValue)) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func set(_ value: Parameter<String>, forKey key: Parameter<String>, withAccess: Parameter<KeychainSwiftAccessOptions?>, perform: @escaping (String, String, KeychainSwiftAccessOptions?) -> Void) -> Perform {
            return Perform(method: .m_set__valueforKey_keywithAccess_withAccess(`value`, `key`, `withAccess`), performs: perform)
        }
        public static func get(_ key: Parameter<String>, perform: @escaping (String) -> Void) -> Perform {
            return Perform(method: .m_get__key(`key`), performs: perform)
        }
        public static func delete(_ key: Parameter<String>, perform: @escaping (String) -> Void) -> Perform {
            return Perform(method: .m_delete__key(`key`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - LocationProviding
open class LocationProvidingMock: LocationProviding, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }

    public var current: CLLocation? {
		get {	invocations.append(.p_current_get); return __p_current ?? optionalGivenGetterValue(.p_current_get, "LocationProvidingMock - stub value for current was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_current = newValue }
	}
	private var __p_current: (CLLocation)?






    fileprivate enum MethodType {
        case p_current_get

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.p_current_get,.p_current_get): return true
            }
        }

        func intValue() -> Int {
            switch self {
            case .p_current_get: return 0
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }

        public static func current(getter defaultValue: CLLocation?...) -> PropertyStub {
            return Given(method: .p_current_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }

    }

    public struct Verify {
        fileprivate var method: MethodType

        public static var current: Verify { return Verify(method: .p_current_get) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - NetworkProtocol
open class NetworkProtocolMock: NetworkProtocol, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    open func resetURLSession() {
        addInvocation(.m_resetURLSession)
		let perform = methodPerformValue(.m_resetURLSession) as? () -> Void
		perform?()
    }

    open func requestAuthCode(phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_requestAuthCode__phone_phonecompletion_completion(Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_requestAuthCode__phone_phonecompletion_completion(Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (String, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`phone`, `completion`)
    }

    open func authenticateWithCode(_ token: String, phone: String, deviceID: String?, completion: @escaping (Result<AuthData, Error>) -> Void) {
        addInvocation(.m_authenticateWithCode__tokenphone_phonedeviceID_deviceIDcompletion_completion(Parameter<String>.value(`token`), Parameter<String>.value(`phone`), Parameter<String?>.value(`deviceID`), Parameter<(Result<AuthData, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_authenticateWithCode__tokenphone_phonedeviceID_deviceIDcompletion_completion(Parameter<String>.value(`token`), Parameter<String>.value(`phone`), Parameter<String?>.value(`deviceID`), Parameter<(Result<AuthData, Error>) -> Void>.value(`completion`))) as? (String, String, String?, @escaping (Result<AuthData, Error>) -> Void) -> Void
		perform?(`token`, `phone`, `deviceID`, `completion`)
    }

    open func authenticateWithEmailCode(_ code: String, phone: String, completion: @escaping (Result<AuthData, Error>) -> Void) {
        addInvocation(.m_authenticateWithEmailCode__codephone_phonecompletion_completion(Parameter<String>.value(`code`), Parameter<String>.value(`phone`), Parameter<(Result<AuthData, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_authenticateWithEmailCode__codephone_phonecompletion_completion(Parameter<String>.value(`code`), Parameter<String>.value(`phone`), Parameter<(Result<AuthData, Error>) -> Void>.value(`completion`))) as? (String, String, @escaping (Result<AuthData, Error>) -> Void) -> Void
		perform?(`code`, `phone`, `completion`)
    }

    open func resendEmailAuthCode(phone: String, deviceID: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(Parameter<String>.value(`phone`), Parameter<String?>.value(`deviceID`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(Parameter<String>.value(`phone`), Parameter<String?>.value(`deviceID`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (String, String?, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`phone`, `deviceID`, `completion`)
    }

    open func setTracingEnabled(_ enabled: Bool, userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_setTracingEnabled__enableduserID_userIDcompletion_completion(Parameter<Bool>.value(`enabled`), Parameter<String>.value(`userID`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_setTracingEnabled__enableduserID_userIDcompletion_completion(Parameter<Bool>.value(`enabled`), Parameter<String>.value(`userID`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (Bool, String, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`enabled`, `userID`, `completion`)
    }

    open func syncPushToken(_ token: Data, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_syncPushToken__tokencompletion_completion(Parameter<Data>.value(`token`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_syncPushToken__tokencompletion_completion(Parameter<Data>.value(`token`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (Data, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`token`, `completion`)
    }

    open func sendHealthCheck(        userID: String,        bluetoothEnabled: Bool,        notificationsEnabled: Bool,        wakeReason: WakeReason,        isOptedIn: Bool,        appVersion: String,        bluetoothHardwareEnabled: Bool,        batteryLevel: Int,        isLowPowerMode: Bool,        completion: @escaping (Result<Void, Error>) -> Void    ) {
        addInvocation(.m_sendHealthCheck__userID_userIDbluetoothEnabled_bluetoothEnablednotificationsEnabled_notificationsEnabledwakeReason_wakeReasonisOptedIn_isOptedInappVersion_appVersionbluetoothHardwareEnabled_bluetoothHardwareEnabledbatteryLevel_batteryLevelisLowPowerMode_isLowPowerModecompletion_completion(Parameter<String>.value(`userID`), Parameter<Bool>.value(`bluetoothEnabled`), Parameter<Bool>.value(`notificationsEnabled`), Parameter<WakeReason>.value(`wakeReason`), Parameter<Bool>.value(`isOptedIn`), Parameter<String>.value(`appVersion`), Parameter<Bool>.value(`bluetoothHardwareEnabled`), Parameter<Int>.value(`batteryLevel`), Parameter<Bool>.value(`isLowPowerMode`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_sendHealthCheck__userID_userIDbluetoothEnabled_bluetoothEnablednotificationsEnabled_notificationsEnabledwakeReason_wakeReasonisOptedIn_isOptedInappVersion_appVersionbluetoothHardwareEnabled_bluetoothHardwareEnabledbatteryLevel_batteryLevelisLowPowerMode_isLowPowerModecompletion_completion(Parameter<String>.value(`userID`), Parameter<Bool>.value(`bluetoothEnabled`), Parameter<Bool>.value(`notificationsEnabled`), Parameter<WakeReason>.value(`wakeReason`), Parameter<Bool>.value(`isOptedIn`), Parameter<String>.value(`appVersion`), Parameter<Bool>.value(`bluetoothHardwareEnabled`), Parameter<Int>.value(`batteryLevel`), Parameter<Bool>.value(`isLowPowerMode`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (String, Bool, Bool, WakeReason, Bool, String, Bool, Int, Bool, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`userID`, `bluetoothEnabled`, `notificationsEnabled`, `wakeReason`, `isOptedIn`, `appVersion`, `bluetoothHardwareEnabled`, `batteryLevel`, `isLowPowerMode`, `completion`)
    }

    open func getTraceIDs(userID: String, completion: @escaping (Result<[TraceIDRecord], Error>) -> Void) {
        addInvocation(.m_getTraceIDs__userID_userIDcompletion_completion(Parameter<String>.value(`userID`), Parameter<(Result<[TraceIDRecord], Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_getTraceIDs__userID_userIDcompletion_completion(Parameter<String>.value(`userID`), Parameter<(Result<[TraceIDRecord], Error>) -> Void>.value(`completion`))) as? (String, @escaping (Result<[TraceIDRecord], Error>) -> Void) -> Void
		perform?(`userID`, `completion`)
    }

    open func uploadTraces(_ traces: ContactTraces, userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_uploadTraces__tracesuserID_userIDcompletion_completion(Parameter<ContactTraces>.value(`traces`), Parameter<String>.value(`userID`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_uploadTraces__tracesuserID_userIDcompletion_completion(Parameter<ContactTraces>.value(`traces`), Parameter<String>.value(`userID`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (ContactTraces, String, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`traces`, `userID`, `completion`)
    }


    fileprivate enum MethodType {
        case m_resetURLSession
        case m_requestAuthCode__phone_phonecompletion_completion(Parameter<String>, Parameter<(Result<Void, Error>) -> Void>)
        case m_authenticateWithCode__tokenphone_phonedeviceID_deviceIDcompletion_completion(Parameter<String>, Parameter<String>, Parameter<String?>, Parameter<(Result<AuthData, Error>) -> Void>)
        case m_authenticateWithEmailCode__codephone_phonecompletion_completion(Parameter<String>, Parameter<String>, Parameter<(Result<AuthData, Error>) -> Void>)
        case m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(Parameter<String>, Parameter<String?>, Parameter<(Result<Void, Error>) -> Void>)
        case m_setTracingEnabled__enableduserID_userIDcompletion_completion(Parameter<Bool>, Parameter<String>, Parameter<(Result<Void, Error>) -> Void>)
        case m_syncPushToken__tokencompletion_completion(Parameter<Data>, Parameter<(Result<Void, Error>) -> Void>)
        case m_sendHealthCheck__userID_userIDbluetoothEnabled_bluetoothEnablednotificationsEnabled_notificationsEnabledwakeReason_wakeReasonisOptedIn_isOptedInappVersion_appVersionbluetoothHardwareEnabled_bluetoothHardwareEnabledbatteryLevel_batteryLevelisLowPowerMode_isLowPowerModecompletion_completion(Parameter<String>, Parameter<Bool>, Parameter<Bool>, Parameter<WakeReason>, Parameter<Bool>, Parameter<String>, Parameter<Bool>, Parameter<Int>, Parameter<Bool>, Parameter<(Result<Void, Error>) -> Void>)
        case m_getTraceIDs__userID_userIDcompletion_completion(Parameter<String>, Parameter<(Result<[TraceIDRecord], Error>) -> Void>)
        case m_uploadTraces__tracesuserID_userIDcompletion_completion(Parameter<ContactTraces>, Parameter<String>, Parameter<(Result<Void, Error>) -> Void>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_resetURLSession, .m_resetURLSession):
                return true 
            case (.m_requestAuthCode__phone_phonecompletion_completion(let lhsPhone, let lhsCompletion), .m_requestAuthCode__phone_phonecompletion_completion(let rhsPhone, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_authenticateWithCode__tokenphone_phonedeviceID_deviceIDcompletion_completion(let lhsToken, let lhsPhone, let lhsDeviceid, let lhsCompletion), .m_authenticateWithCode__tokenphone_phonedeviceID_deviceIDcompletion_completion(let rhsToken, let rhsPhone, let rhsDeviceid, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsToken, rhs: rhsToken, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsDeviceid, rhs: rhsDeviceid, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_authenticateWithEmailCode__codephone_phonecompletion_completion(let lhsCode, let lhsPhone, let lhsCompletion), .m_authenticateWithEmailCode__codephone_phonecompletion_completion(let rhsCode, let rhsPhone, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsCode, rhs: rhsCode, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(let lhsPhone, let lhsDeviceid, let lhsCompletion), .m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(let rhsPhone, let rhsDeviceid, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsDeviceid, rhs: rhsDeviceid, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_setTracingEnabled__enableduserID_userIDcompletion_completion(let lhsEnabled, let lhsUserid, let lhsCompletion), .m_setTracingEnabled__enableduserID_userIDcompletion_completion(let rhsEnabled, let rhsUserid, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsEnabled, rhs: rhsEnabled, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsUserid, rhs: rhsUserid, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_syncPushToken__tokencompletion_completion(let lhsToken, let lhsCompletion), .m_syncPushToken__tokencompletion_completion(let rhsToken, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsToken, rhs: rhsToken, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_sendHealthCheck__userID_userIDbluetoothEnabled_bluetoothEnablednotificationsEnabled_notificationsEnabledwakeReason_wakeReasonisOptedIn_isOptedInappVersion_appVersionbluetoothHardwareEnabled_bluetoothHardwareEnabledbatteryLevel_batteryLevelisLowPowerMode_isLowPowerModecompletion_completion(let lhsUserid, let lhsBluetoothenabled, let lhsNotificationsenabled, let lhsWakereason, let lhsIsoptedin, let lhsAppversion, let lhsBluetoothhardwareenabled, let lhsBatterylevel, let lhsIslowpowermode, let lhsCompletion), .m_sendHealthCheck__userID_userIDbluetoothEnabled_bluetoothEnablednotificationsEnabled_notificationsEnabledwakeReason_wakeReasonisOptedIn_isOptedInappVersion_appVersionbluetoothHardwareEnabled_bluetoothHardwareEnabledbatteryLevel_batteryLevelisLowPowerMode_isLowPowerModecompletion_completion(let rhsUserid, let rhsBluetoothenabled, let rhsNotificationsenabled, let rhsWakereason, let rhsIsoptedin, let rhsAppversion, let rhsBluetoothhardwareenabled, let rhsBatterylevel, let rhsIslowpowermode, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsUserid, rhs: rhsUserid, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsBluetoothenabled, rhs: rhsBluetoothenabled, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsNotificationsenabled, rhs: rhsNotificationsenabled, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsWakereason, rhs: rhsWakereason, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsIsoptedin, rhs: rhsIsoptedin, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsAppversion, rhs: rhsAppversion, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsBluetoothhardwareenabled, rhs: rhsBluetoothhardwareenabled, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsBatterylevel, rhs: rhsBatterylevel, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsIslowpowermode, rhs: rhsIslowpowermode, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_getTraceIDs__userID_userIDcompletion_completion(let lhsUserid, let lhsCompletion), .m_getTraceIDs__userID_userIDcompletion_completion(let rhsUserid, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsUserid, rhs: rhsUserid, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_uploadTraces__tracesuserID_userIDcompletion_completion(let lhsTraces, let lhsUserid, let lhsCompletion), .m_uploadTraces__tracesuserID_userIDcompletion_completion(let rhsTraces, let rhsUserid, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsTraces, rhs: rhsTraces, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsUserid, rhs: rhsUserid, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case .m_resetURLSession: return 0
            case let .m_requestAuthCode__phone_phonecompletion_completion(p0, p1): return p0.intValue + p1.intValue
            case let .m_authenticateWithCode__tokenphone_phonedeviceID_deviceIDcompletion_completion(p0, p1, p2, p3): return p0.intValue + p1.intValue + p2.intValue + p3.intValue
            case let .m_authenticateWithEmailCode__codephone_phonecompletion_completion(p0, p1, p2): return p0.intValue + p1.intValue + p2.intValue
            case let .m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(p0, p1, p2): return p0.intValue + p1.intValue + p2.intValue
            case let .m_setTracingEnabled__enableduserID_userIDcompletion_completion(p0, p1, p2): return p0.intValue + p1.intValue + p2.intValue
            case let .m_syncPushToken__tokencompletion_completion(p0, p1): return p0.intValue + p1.intValue
            case let .m_sendHealthCheck__userID_userIDbluetoothEnabled_bluetoothEnablednotificationsEnabled_notificationsEnabledwakeReason_wakeReasonisOptedIn_isOptedInappVersion_appVersionbluetoothHardwareEnabled_bluetoothHardwareEnabledbatteryLevel_batteryLevelisLowPowerMode_isLowPowerModecompletion_completion(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9): return p0.intValue + p1.intValue + p2.intValue + p3.intValue + p4.intValue + p5.intValue + p6.intValue + p7.intValue + p8.intValue + p9.intValue
            case let .m_getTraceIDs__userID_userIDcompletion_completion(p0, p1): return p0.intValue + p1.intValue
            case let .m_uploadTraces__tracesuserID_userIDcompletion_completion(p0, p1, p2): return p0.intValue + p1.intValue + p2.intValue
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func resetURLSession() -> Verify { return Verify(method: .m_resetURLSession)}
        public static func requestAuthCode(phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_requestAuthCode__phone_phonecompletion_completion(`phone`, `completion`))}
        public static func authenticateWithCode(_ token: Parameter<String>, phone: Parameter<String>, deviceID: Parameter<String?>, completion: Parameter<(Result<AuthData, Error>) -> Void>) -> Verify { return Verify(method: .m_authenticateWithCode__tokenphone_phonedeviceID_deviceIDcompletion_completion(`token`, `phone`, `deviceID`, `completion`))}
        public static func authenticateWithEmailCode(_ code: Parameter<String>, phone: Parameter<String>, completion: Parameter<(Result<AuthData, Error>) -> Void>) -> Verify { return Verify(method: .m_authenticateWithEmailCode__codephone_phonecompletion_completion(`code`, `phone`, `completion`))}
        public static func resendEmailAuthCode(phone: Parameter<String>, deviceID: Parameter<String?>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(`phone`, `deviceID`, `completion`))}
        public static func setTracingEnabled(_ enabled: Parameter<Bool>, userID: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_setTracingEnabled__enableduserID_userIDcompletion_completion(`enabled`, `userID`, `completion`))}
        public static func syncPushToken(_ token: Parameter<Data>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_syncPushToken__tokencompletion_completion(`token`, `completion`))}
        public static func sendHealthCheck(userID: Parameter<String>, bluetoothEnabled: Parameter<Bool>, notificationsEnabled: Parameter<Bool>, wakeReason: Parameter<WakeReason>, isOptedIn: Parameter<Bool>, appVersion: Parameter<String>, bluetoothHardwareEnabled: Parameter<Bool>, batteryLevel: Parameter<Int>, isLowPowerMode: Parameter<Bool>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_sendHealthCheck__userID_userIDbluetoothEnabled_bluetoothEnablednotificationsEnabled_notificationsEnabledwakeReason_wakeReasonisOptedIn_isOptedInappVersion_appVersionbluetoothHardwareEnabled_bluetoothHardwareEnabledbatteryLevel_batteryLevelisLowPowerMode_isLowPowerModecompletion_completion(`userID`, `bluetoothEnabled`, `notificationsEnabled`, `wakeReason`, `isOptedIn`, `appVersion`, `bluetoothHardwareEnabled`, `batteryLevel`, `isLowPowerMode`, `completion`))}
        public static func getTraceIDs(userID: Parameter<String>, completion: Parameter<(Result<[TraceIDRecord], Error>) -> Void>) -> Verify { return Verify(method: .m_getTraceIDs__userID_userIDcompletion_completion(`userID`, `completion`))}
        public static func uploadTraces(_ traces: Parameter<ContactTraces>, userID: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_uploadTraces__tracesuserID_userIDcompletion_completion(`traces`, `userID`, `completion`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func resetURLSession(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_resetURLSession, performs: perform)
        }
        public static func requestAuthCode(phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (String, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_requestAuthCode__phone_phonecompletion_completion(`phone`, `completion`), performs: perform)
        }
        public static func authenticateWithCode(_ token: Parameter<String>, phone: Parameter<String>, deviceID: Parameter<String?>, completion: Parameter<(Result<AuthData, Error>) -> Void>, perform: @escaping (String, String, String?, @escaping (Result<AuthData, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_authenticateWithCode__tokenphone_phonedeviceID_deviceIDcompletion_completion(`token`, `phone`, `deviceID`, `completion`), performs: perform)
        }
        public static func authenticateWithEmailCode(_ code: Parameter<String>, phone: Parameter<String>, completion: Parameter<(Result<AuthData, Error>) -> Void>, perform: @escaping (String, String, @escaping (Result<AuthData, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_authenticateWithEmailCode__codephone_phonecompletion_completion(`code`, `phone`, `completion`), performs: perform)
        }
        public static func resendEmailAuthCode(phone: Parameter<String>, deviceID: Parameter<String?>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (String, String?, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(`phone`, `deviceID`, `completion`), performs: perform)
        }
        public static func setTracingEnabled(_ enabled: Parameter<Bool>, userID: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (Bool, String, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_setTracingEnabled__enableduserID_userIDcompletion_completion(`enabled`, `userID`, `completion`), performs: perform)
        }
        public static func syncPushToken(_ token: Parameter<Data>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (Data, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_syncPushToken__tokencompletion_completion(`token`, `completion`), performs: perform)
        }
        public static func sendHealthCheck(userID: Parameter<String>, bluetoothEnabled: Parameter<Bool>, notificationsEnabled: Parameter<Bool>, wakeReason: Parameter<WakeReason>, isOptedIn: Parameter<Bool>, appVersion: Parameter<String>, bluetoothHardwareEnabled: Parameter<Bool>, batteryLevel: Parameter<Int>, isLowPowerMode: Parameter<Bool>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (String, Bool, Bool, WakeReason, Bool, String, Bool, Int, Bool, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_sendHealthCheck__userID_userIDbluetoothEnabled_bluetoothEnablednotificationsEnabled_notificationsEnabledwakeReason_wakeReasonisOptedIn_isOptedInappVersion_appVersionbluetoothHardwareEnabled_bluetoothHardwareEnabledbatteryLevel_batteryLevelisLowPowerMode_isLowPowerModecompletion_completion(`userID`, `bluetoothEnabled`, `notificationsEnabled`, `wakeReason`, `isOptedIn`, `appVersion`, `bluetoothHardwareEnabled`, `batteryLevel`, `isLowPowerMode`, `completion`), performs: perform)
        }
        public static func getTraceIDs(userID: Parameter<String>, completion: Parameter<(Result<[TraceIDRecord], Error>) -> Void>, perform: @escaping (String, @escaping (Result<[TraceIDRecord], Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_getTraceIDs__userID_userIDcompletion_completion(`userID`, `completion`), performs: perform)
        }
        public static func uploadTraces(_ traces: Parameter<ContactTraces>, userID: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (ContactTraces, String, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_uploadTraces__tracesuserID_userIDcompletion_completion(`traces`, `userID`, `completion`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - TraceIDStorageProtocol
open class TraceIDStorageProtocolMock: TraceIDStorageProtocol, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    open func getCurrent(_ completion: @escaping (String?) -> Void) {
        addInvocation(.m_getCurrent__completion(Parameter<(String?) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_getCurrent__completion(Parameter<(String?) -> Void>.value(`completion`))) as? (@escaping (String?) -> Void) -> Void
		perform?(`completion`)
    }

    open func refreshIfNeeded() {
        addInvocation(.m_refreshIfNeeded)
		let perform = methodPerformValue(.m_refreshIfNeeded) as? () -> Void
		perform?()
    }

    open func clear() {
        addInvocation(.m_clear)
		let perform = methodPerformValue(.m_clear) as? () -> Void
		perform?()
    }


    fileprivate enum MethodType {
        case m_getCurrent__completion(Parameter<(String?) -> Void>)
        case m_refreshIfNeeded
        case m_clear

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_getCurrent__completion(let lhsCompletion), .m_getCurrent__completion(let rhsCompletion)):
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_refreshIfNeeded, .m_refreshIfNeeded):
                return true 
            case (.m_clear, .m_clear):
                return true 
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_getCurrent__completion(p0): return p0.intValue
            case .m_refreshIfNeeded: return 0
            case .m_clear: return 0
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func getCurrent(_ completion: Parameter<(String?) -> Void>) -> Verify { return Verify(method: .m_getCurrent__completion(`completion`))}
        public static func refreshIfNeeded() -> Verify { return Verify(method: .m_refreshIfNeeded)}
        public static func clear() -> Verify { return Verify(method: .m_clear)}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func getCurrent(_ completion: Parameter<(String?) -> Void>, perform: @escaping (@escaping (String?) -> Void) -> Void) -> Perform {
            return Perform(method: .m_getCurrent__completion(`completion`), performs: perform)
        }
        public static func refreshIfNeeded(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_refreshIfNeeded, performs: perform)
        }
        public static func clear(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_clear, performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - UserDefaultsProtocol
open class UserDefaultsProtocolMock: UserDefaultsProtocol, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    open func set(_: Any?, forKey: String) {
        addInvocation(.m_set__forKeyforKey(Parameter<String>.value(`forKey`)))
		let perform = methodPerformValue(.m_set__forKeyforKey(Parameter<String>.value(`forKey`))) as? (String) -> Void
		perform?(`forKey`)
    }

    open func object(forKey: String) -> Any? {
        addInvocation(.m_object__forKey_forKey(Parameter<String>.value(`forKey`)))
		let perform = methodPerformValue(.m_object__forKey_forKey(Parameter<String>.value(`forKey`))) as? (String) -> Void
		perform?(`forKey`)
		var __value: Any? = nil
		do {
		    __value = try methodReturnValue(.m_object__forKey_forKey(Parameter<String>.value(`forKey`))).casted()
		} catch {
			// do nothing
		}
		return __value
    }

    open func data(forKey: String) -> Data? {
        addInvocation(.m_data__forKey_forKey(Parameter<String>.value(`forKey`)))
		let perform = methodPerformValue(.m_data__forKey_forKey(Parameter<String>.value(`forKey`))) as? (String) -> Void
		perform?(`forKey`)
		var __value: Data? = nil
		do {
		    __value = try methodReturnValue(.m_data__forKey_forKey(Parameter<String>.value(`forKey`))).casted()
		} catch {
			// do nothing
		}
		return __value
    }

    open func bool(forKey: String) -> Bool {
        addInvocation(.m_bool__forKey_forKey(Parameter<String>.value(`forKey`)))
		let perform = methodPerformValue(.m_bool__forKey_forKey(Parameter<String>.value(`forKey`))) as? (String) -> Void
		perform?(`forKey`)
		var __value: Bool
		do {
		    __value = try methodReturnValue(.m_bool__forKey_forKey(Parameter<String>.value(`forKey`))).casted()
		} catch {
			onFatalFailure("Stub return value not specified for bool(forKey: String). Use given")
			Failure("Stub return value not specified for bool(forKey: String). Use given")
		}
		return __value
    }


    fileprivate enum MethodType {
        case m_set__forKeyforKey(Parameter<String>)
        case m_object__forKey_forKey(Parameter<String>)
        case m_data__forKey_forKey(Parameter<String>)
        case m_bool__forKey_forKey(Parameter<String>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_set__forKeyforKey(let lhsForkey), .m_set__forKeyforKey(let rhsForkey)):
                guard Parameter.compare(lhs: lhsForkey, rhs: rhsForkey, with: matcher) else { return false } 
                return true 
            case (.m_object__forKey_forKey(let lhsForkey), .m_object__forKey_forKey(let rhsForkey)):
                guard Parameter.compare(lhs: lhsForkey, rhs: rhsForkey, with: matcher) else { return false } 
                return true 
            case (.m_data__forKey_forKey(let lhsForkey), .m_data__forKey_forKey(let rhsForkey)):
                guard Parameter.compare(lhs: lhsForkey, rhs: rhsForkey, with: matcher) else { return false } 
                return true 
            case (.m_bool__forKey_forKey(let lhsForkey), .m_bool__forKey_forKey(let rhsForkey)):
                guard Parameter.compare(lhs: lhsForkey, rhs: rhsForkey, with: matcher) else { return false } 
                return true 
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_set__forKeyforKey(p0): return p0.intValue
            case let .m_object__forKey_forKey(p0): return p0.intValue
            case let .m_data__forKey_forKey(p0): return p0.intValue
            case let .m_bool__forKey_forKey(p0): return p0.intValue
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


        public static func object(forKey: Parameter<String>, willReturn: Any?...) -> MethodStub {
            return Given(method: .m_object__forKey_forKey(`forKey`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func data(forKey: Parameter<String>, willReturn: Data?...) -> MethodStub {
            return Given(method: .m_data__forKey_forKey(`forKey`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func bool(forKey: Parameter<String>, willReturn: Bool...) -> MethodStub {
            return Given(method: .m_bool__forKey_forKey(`forKey`), products: willReturn.map({ StubProduct.return($0 as Any) }))
        }
        public static func object(forKey: Parameter<String>, willProduce: (Stubber<Any?>) -> Void) -> MethodStub {
            let willReturn: [Any?] = []
			let given: Given = { return Given(method: .m_object__forKey_forKey(`forKey`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (Any?).self)
			willProduce(stubber)
			return given
        }
        public static func data(forKey: Parameter<String>, willProduce: (Stubber<Data?>) -> Void) -> MethodStub {
            let willReturn: [Data?] = []
			let given: Given = { return Given(method: .m_data__forKey_forKey(`forKey`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (Data?).self)
			willProduce(stubber)
			return given
        }
        public static func bool(forKey: Parameter<String>, willProduce: (Stubber<Bool>) -> Void) -> MethodStub {
            let willReturn: [Bool] = []
			let given: Given = { return Given(method: .m_bool__forKey_forKey(`forKey`), products: willReturn.map({ StubProduct.return($0 as Any) })) }()
			let stubber = given.stub(for: (Bool).self)
			willProduce(stubber)
			return given
        }
    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func set(forKey: Parameter<String>) -> Verify { return Verify(method: .m_set__forKeyforKey(`forKey`))}
        public static func object(forKey: Parameter<String>) -> Verify { return Verify(method: .m_object__forKey_forKey(`forKey`))}
        public static func data(forKey: Parameter<String>) -> Verify { return Verify(method: .m_data__forKey_forKey(`forKey`))}
        public static func bool(forKey: Parameter<String>) -> Verify { return Verify(method: .m_bool__forKey_forKey(`forKey`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func set(forKey: Parameter<String>, perform: @escaping (String) -> Void) -> Perform {
            return Perform(method: .m_set__forKeyforKey(`forKey`), performs: perform)
        }
        public static func object(forKey: Parameter<String>, perform: @escaping (String) -> Void) -> Perform {
            return Perform(method: .m_object__forKey_forKey(`forKey`), performs: perform)
        }
        public static func data(forKey: Parameter<String>, perform: @escaping (String) -> Void) -> Perform {
            return Perform(method: .m_data__forKey_forKey(`forKey`), performs: perform)
        }
        public static func bool(forKey: Parameter<String>, perform: @escaping (String) -> Void) -> Perform {
            return Perform(method: .m_bool__forKey_forKey(`forKey`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - UserSessionAuthenticationDelegate
open class UserSessionAuthenticationDelegateMock: UserSessionAuthenticationDelegate, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }





    open func authenticationStatusDidChange(forSession: UserSessionProtocol) {
        addInvocation(.m_authenticationStatusDidChange__forSession_forSession(Parameter<UserSessionProtocol>.value(`forSession`)))
		let perform = methodPerformValue(.m_authenticationStatusDidChange__forSession_forSession(Parameter<UserSessionProtocol>.value(`forSession`))) as? (UserSessionProtocol) -> Void
		perform?(`forSession`)
    }

    open func authenticationTokenDidChange(forSession: UserSessionProtocol) {
        addInvocation(.m_authenticationTokenDidChange__forSession_forSession(Parameter<UserSessionProtocol>.value(`forSession`)))
		let perform = methodPerformValue(.m_authenticationTokenDidChange__forSession_forSession(Parameter<UserSessionProtocol>.value(`forSession`))) as? (UserSessionProtocol) -> Void
		perform?(`forSession`)
    }


    fileprivate enum MethodType {
        case m_authenticationStatusDidChange__forSession_forSession(Parameter<UserSessionProtocol>)
        case m_authenticationTokenDidChange__forSession_forSession(Parameter<UserSessionProtocol>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_authenticationStatusDidChange__forSession_forSession(let lhsForsession), .m_authenticationStatusDidChange__forSession_forSession(let rhsForsession)):
                guard Parameter.compare(lhs: lhsForsession, rhs: rhsForsession, with: matcher) else { return false } 
                return true 
            case (.m_authenticationTokenDidChange__forSession_forSession(let lhsForsession), .m_authenticationTokenDidChange__forSession_forSession(let rhsForsession)):
                guard Parameter.compare(lhs: lhsForsession, rhs: rhsForsession, with: matcher) else { return false } 
                return true 
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_authenticationStatusDidChange__forSession_forSession(p0): return p0.intValue
            case let .m_authenticationTokenDidChange__forSession_forSession(p0): return p0.intValue
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }


    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func authenticationStatusDidChange(forSession: Parameter<UserSessionProtocol>) -> Verify { return Verify(method: .m_authenticationStatusDidChange__forSession_forSession(`forSession`))}
        public static func authenticationTokenDidChange(forSession: Parameter<UserSessionProtocol>) -> Verify { return Verify(method: .m_authenticationTokenDidChange__forSession_forSession(`forSession`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func authenticationStatusDidChange(forSession: Parameter<UserSessionProtocol>, perform: @escaping (UserSessionProtocol) -> Void) -> Perform {
            return Perform(method: .m_authenticationStatusDidChange__forSession_forSession(`forSession`), performs: perform)
        }
        public static func authenticationTokenDidChange(forSession: Parameter<UserSessionProtocol>, perform: @escaping (UserSessionProtocol) -> Void) -> Perform {
            return Perform(method: .m_authenticationTokenDidChange__forSession_forSession(`forSession`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

// MARK: - UserSessionProtocol
open class UserSessionProtocolMock: UserSessionProtocol, Mock {
    init(sequencing sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst, stubbing stubbingPolicy: StubbingPolicy = .wrap, file: StaticString = #file, line: UInt = #line) {
        SwiftyMockyTestObserver.setup()
        self.sequencingPolicy = sequencingPolicy
        self.stubbingPolicy = stubbingPolicy
        self.file = file
        self.line = line
    }

    var matcher: Matcher = Matcher.default
    var stubbingPolicy: StubbingPolicy = .wrap
    var sequencingPolicy: SequencingPolicy = .lastWrittenResolvedFirst
    private var invocations: [MethodType] = []
    private var methodReturnValues: [Given] = []
    private var methodPerformValues: [Perform] = []
    private var file: StaticString?
    private var line: UInt?

    public typealias PropertyStub = Given
    public typealias MethodStub = Given
    public typealias SubscriptStub = Given

    /// Convenience method - call setupMock() to extend debug information when failure occurs
    public func setupMock(file: StaticString = #file, line: UInt = #line) {
        self.file = file
        self.line = line
    }

    /// Clear mock internals. You can specify what to reset (invocations aka verify, givens or performs) or leave it empty to clear all mock internals
    public func resetMock(_ scopes: MockScope...) {
        let scopes: [MockScope] = scopes.isEmpty ? [.invocation, .given, .perform] : scopes
        if scopes.contains(.invocation) { invocations = [] }
        if scopes.contains(.given) { methodReturnValues = [] }
        if scopes.contains(.perform) { methodPerformValues = [] }
    }

    public var authenticationDelegate: UserSessionAuthenticationDelegate? {
		get {	invocations.append(.p_authenticationDelegate_get); return __p_authenticationDelegate ?? optionalGivenGetterValue(.p_authenticationDelegate_get, "UserSessionProtocolMock - stub value for authenticationDelegate was not defined") }
		set {	invocations.append(.p_authenticationDelegate_set(.value(newValue))); __p_authenticationDelegate = newValue }
	}
	private var __p_authenticationDelegate: (UserSessionAuthenticationDelegate)?

    public var isAuthenticated: Bool {
		get {	invocations.append(.p_isAuthenticated_get); return __p_isAuthenticated ?? givenGetterValue(.p_isAuthenticated_get, "UserSessionProtocolMock - stub value for isAuthenticated was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_isAuthenticated = newValue }
	}
	private var __p_isAuthenticated: (Bool)?

    public var isCitizenAuthenticated: Bool {
		get {	invocations.append(.p_isCitizenAuthenticated_get); return __p_isCitizenAuthenticated ?? givenGetterValue(.p_isCitizenAuthenticated_get, "UserSessionProtocolMock - stub value for isCitizenAuthenticated was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_isCitizenAuthenticated = newValue }
	}
	private var __p_isCitizenAuthenticated: (Bool)?

    public var userID: String? {
		get {	invocations.append(.p_userID_get); return __p_userID ?? optionalGivenGetterValue(.p_userID_get, "UserSessionProtocolMock - stub value for userID was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_userID = newValue }
	}
	private var __p_userID: (String)?

    public var authToken: String? {
		get {	invocations.append(.p_authToken_get); return __p_authToken ?? optionalGivenGetterValue(.p_authToken_get, "UserSessionProtocolMock - stub value for authToken was not defined") }
		@available(*, deprecated, message: "Using setters on readonly variables is deprecated, and will be removed in 3.1. Use Given to define stubbed property return value.")
		set {	__p_authToken = newValue }
	}
	private var __p_authToken: (String)?





    open func logout() {
        addInvocation(.m_logout)
		let perform = methodPerformValue(.m_logout) as? () -> Void
		perform?()
    }

    open func authenticateWithCode(_: String, phone: String, completion: @escaping (Result<LoginResponseContext, Error>) -> Void) {
        addInvocation(.m_authenticateWithCode__phonephone_completioncompletion(Parameter<String>.value(`phone`), Parameter<(Result<LoginResponseContext, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_authenticateWithCode__phonephone_completioncompletion(Parameter<String>.value(`phone`), Parameter<(Result<LoginResponseContext, Error>) -> Void>.value(`completion`))) as? (String, @escaping (Result<LoginResponseContext, Error>) -> Void) -> Void
		perform?(`phone`, `completion`)
    }

    open func updateAuthTokenWebViewCookies(authToken: String?) {
        addInvocation(.m_updateAuthTokenWebViewCookies__authToken_authToken(Parameter<String?>.value(`authToken`)))
		let perform = methodPerformValue(.m_updateAuthTokenWebViewCookies__authToken_authToken(Parameter<String?>.value(`authToken`))) as? (String?) -> Void
		perform?(`authToken`)
    }

    open func requestAuthenticationCode(for phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_requestAuthenticationCode__for_phonecompletion_completion(Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_requestAuthenticationCode__for_phonecompletion_completion(Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (String, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`phone`, `completion`)
    }

    open func authenticateWithEmailCode(_ code: String, phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_authenticateWithEmailCode__codephone_phonecompletion_completion(Parameter<String>.value(`code`), Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_authenticateWithEmailCode__codephone_phonecompletion_completion(Parameter<String>.value(`code`), Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (String, String, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`code`, `phone`, `completion`)
    }

    open func resendEmailAuthCode(phone: String, deviceID: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(Parameter<String>.value(`phone`), Parameter<String?>.value(`deviceID`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(Parameter<String>.value(`phone`), Parameter<String?>.value(`deviceID`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (String, String?, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`phone`, `deviceID`, `completion`)
    }

    open func setAPNSToken(_ token: Data) {
        addInvocation(.m_setAPNSToken__token(Parameter<Data>.value(`token`)))
		let perform = methodPerformValue(.m_setAPNSToken__token(Parameter<Data>.value(`token`))) as? (Data) -> Void
		perform?(`token`)
    }


    fileprivate enum MethodType {
        case m_logout
        case m_authenticateWithCode__phonephone_completioncompletion(Parameter<String>, Parameter<(Result<LoginResponseContext, Error>) -> Void>)
        case m_updateAuthTokenWebViewCookies__authToken_authToken(Parameter<String?>)
        case m_requestAuthenticationCode__for_phonecompletion_completion(Parameter<String>, Parameter<(Result<Void, Error>) -> Void>)
        case m_authenticateWithEmailCode__codephone_phonecompletion_completion(Parameter<String>, Parameter<String>, Parameter<(Result<Void, Error>) -> Void>)
        case m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(Parameter<String>, Parameter<String?>, Parameter<(Result<Void, Error>) -> Void>)
        case m_setAPNSToken__token(Parameter<Data>)
        case p_authenticationDelegate_get
		case p_authenticationDelegate_set(Parameter<UserSessionAuthenticationDelegate?>)
        case p_isAuthenticated_get
        case p_isCitizenAuthenticated_get
        case p_userID_get
        case p_authToken_get

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_logout, .m_logout):
                return true 
            case (.m_authenticateWithCode__phonephone_completioncompletion(let lhsPhone, let lhsCompletion), .m_authenticateWithCode__phonephone_completioncompletion(let rhsPhone, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_updateAuthTokenWebViewCookies__authToken_authToken(let lhsAuthtoken), .m_updateAuthTokenWebViewCookies__authToken_authToken(let rhsAuthtoken)):
                guard Parameter.compare(lhs: lhsAuthtoken, rhs: rhsAuthtoken, with: matcher) else { return false } 
                return true 
            case (.m_requestAuthenticationCode__for_phonecompletion_completion(let lhsPhone, let lhsCompletion), .m_requestAuthenticationCode__for_phonecompletion_completion(let rhsPhone, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_authenticateWithEmailCode__codephone_phonecompletion_completion(let lhsCode, let lhsPhone, let lhsCompletion), .m_authenticateWithEmailCode__codephone_phonecompletion_completion(let rhsCode, let rhsPhone, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsCode, rhs: rhsCode, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(let lhsPhone, let lhsDeviceid, let lhsCompletion), .m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(let rhsPhone, let rhsDeviceid, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsDeviceid, rhs: rhsDeviceid, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_setAPNSToken__token(let lhsToken), .m_setAPNSToken__token(let rhsToken)):
                guard Parameter.compare(lhs: lhsToken, rhs: rhsToken, with: matcher) else { return false } 
                return true 
            case (.p_authenticationDelegate_get,.p_authenticationDelegate_get): return true
			case (.p_authenticationDelegate_set(let left),.p_authenticationDelegate_set(let right)): return Parameter<UserSessionAuthenticationDelegate?>.compare(lhs: left, rhs: right, with: matcher)
            case (.p_isAuthenticated_get,.p_isAuthenticated_get): return true
            case (.p_isCitizenAuthenticated_get,.p_isCitizenAuthenticated_get): return true
            case (.p_userID_get,.p_userID_get): return true
            case (.p_authToken_get,.p_authToken_get): return true
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case .m_logout: return 0
            case let .m_authenticateWithCode__phonephone_completioncompletion(p0, p1): return p0.intValue + p1.intValue
            case let .m_updateAuthTokenWebViewCookies__authToken_authToken(p0): return p0.intValue
            case let .m_requestAuthenticationCode__for_phonecompletion_completion(p0, p1): return p0.intValue + p1.intValue
            case let .m_authenticateWithEmailCode__codephone_phonecompletion_completion(p0, p1, p2): return p0.intValue + p1.intValue + p2.intValue
            case let .m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(p0, p1, p2): return p0.intValue + p1.intValue + p2.intValue
            case let .m_setAPNSToken__token(p0): return p0.intValue
            case .p_authenticationDelegate_get: return 0
			case .p_authenticationDelegate_set(let newValue): return newValue.intValue
            case .p_isAuthenticated_get: return 0
            case .p_isCitizenAuthenticated_get: return 0
            case .p_userID_get: return 0
            case .p_authToken_get: return 0
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
        }

        public static func authenticationDelegate(getter defaultValue: UserSessionAuthenticationDelegate?...) -> PropertyStub {
            return Given(method: .p_authenticationDelegate_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func isAuthenticated(getter defaultValue: Bool...) -> PropertyStub {
            return Given(method: .p_isAuthenticated_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func isCitizenAuthenticated(getter defaultValue: Bool...) -> PropertyStub {
            return Given(method: .p_isCitizenAuthenticated_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func userID(getter defaultValue: String?...) -> PropertyStub {
            return Given(method: .p_userID_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }
        public static func authToken(getter defaultValue: String?...) -> PropertyStub {
            return Given(method: .p_authToken_get, products: defaultValue.map({ StubProduct.return($0 as Any) }))
        }

    }

    public struct Verify {
        fileprivate var method: MethodType

        public static func logout() -> Verify { return Verify(method: .m_logout)}
        public static func authenticateWithCode(phone: Parameter<String>, completion: Parameter<(Result<LoginResponseContext, Error>) -> Void>) -> Verify { return Verify(method: .m_authenticateWithCode__phonephone_completioncompletion(`phone`, `completion`))}
        public static func updateAuthTokenWebViewCookies(authToken: Parameter<String?>) -> Verify { return Verify(method: .m_updateAuthTokenWebViewCookies__authToken_authToken(`authToken`))}
        public static func requestAuthenticationCode(for phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_requestAuthenticationCode__for_phonecompletion_completion(`phone`, `completion`))}
        public static func authenticateWithEmailCode(_ code: Parameter<String>, phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_authenticateWithEmailCode__codephone_phonecompletion_completion(`code`, `phone`, `completion`))}
        public static func resendEmailAuthCode(phone: Parameter<String>, deviceID: Parameter<String?>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(`phone`, `deviceID`, `completion`))}
        public static func setAPNSToken(_ token: Parameter<Data>) -> Verify { return Verify(method: .m_setAPNSToken__token(`token`))}
        public static var authenticationDelegate: Verify { return Verify(method: .p_authenticationDelegate_get) }
		public static func authenticationDelegate(set newValue: Parameter<UserSessionAuthenticationDelegate?>) -> Verify { return Verify(method: .p_authenticationDelegate_set(newValue)) }
        public static var isAuthenticated: Verify { return Verify(method: .p_isAuthenticated_get) }
        public static var isCitizenAuthenticated: Verify { return Verify(method: .p_isCitizenAuthenticated_get) }
        public static var userID: Verify { return Verify(method: .p_userID_get) }
        public static var authToken: Verify { return Verify(method: .p_authToken_get) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func logout(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_logout, performs: perform)
        }
        public static func authenticateWithCode(phone: Parameter<String>, completion: Parameter<(Result<LoginResponseContext, Error>) -> Void>, perform: @escaping (String, @escaping (Result<LoginResponseContext, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_authenticateWithCode__phonephone_completioncompletion(`phone`, `completion`), performs: perform)
        }
        public static func updateAuthTokenWebViewCookies(authToken: Parameter<String?>, perform: @escaping (String?) -> Void) -> Perform {
            return Perform(method: .m_updateAuthTokenWebViewCookies__authToken_authToken(`authToken`), performs: perform)
        }
        public static func requestAuthenticationCode(for phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (String, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_requestAuthenticationCode__for_phonecompletion_completion(`phone`, `completion`), performs: perform)
        }
        public static func authenticateWithEmailCode(_ code: Parameter<String>, phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (String, String, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_authenticateWithEmailCode__codephone_phonecompletion_completion(`code`, `phone`, `completion`), performs: perform)
        }
        public static func resendEmailAuthCode(phone: Parameter<String>, deviceID: Parameter<String?>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (String, String?, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_resendEmailAuthCode__phone_phonedeviceID_deviceIDcompletion_completion(`phone`, `deviceID`, `completion`), performs: perform)
        }
        public static func setAPNSToken(_ token: Parameter<Data>, perform: @escaping (Data) -> Void) -> Perform {
            return Perform(method: .m_setAPNSToken__token(`token`), performs: perform)
        }
    }

    public func given(_ method: Given) {
        methodReturnValues.append(method)
    }

    public func perform(_ method: Perform) {
        methodPerformValues.append(method)
        methodPerformValues.sort { $0.method.intValue() < $1.method.intValue() }
    }

    public func verify(_ method: Verify, count: Count = Count.moreOrEqual(to: 1), file: StaticString = #file, line: UInt = #line) {
        let invocations = matchingCalls(method.method)
        MockyAssert(count.matches(invocations.count), "Expected: \(count) invocations of `\(method.method)`, but was: \(invocations.count)", file: file, line: line)
    }

    private func addInvocation(_ call: MethodType) {
        invocations.append(call)
    }
    private func methodReturnValue(_ method: MethodType) throws -> StubProduct {
        let candidates = sequencingPolicy.sorted(methodReturnValues, by: { $0.method.intValue() > $1.method.intValue() })
        let matched = candidates.first(where: { $0.isValid && MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) })
        guard let product = matched?.getProduct(policy: self.stubbingPolicy) else { throw MockError.notStubed }
        return product
    }
    private func methodPerformValue(_ method: MethodType) -> Any? {
        let matched = methodPerformValues.reversed().first { MethodType.compareParameters(lhs: $0.method, rhs: method, matcher: matcher) }
        return matched?.performs
    }
    private func matchingCalls(_ method: MethodType) -> [MethodType] {
        return invocations.filter { MethodType.compareParameters(lhs: $0, rhs: method, matcher: matcher) }
    }
    private func matchingCalls(_ method: Verify) -> Int {
        return matchingCalls(method.method).count
    }
    private func givenGetterValue<T>(_ method: MethodType, _ message: String) -> T {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            onFatalFailure(message)
            Failure(message)
        }
    }
    private func optionalGivenGetterValue<T>(_ method: MethodType, _ message: String) -> T? {
        do {
            return try methodReturnValue(method).casted()
        } catch {
            return nil
        }
    }
    private func onFatalFailure(_ message: String) {
        #if Mocky
        guard let file = self.file, let line = self.line else { return } // Let if fail if cannot handle gratefully
        SwiftyMockyTestObserver.handleMissingStubError(message: message, file: file, line: line)
        #endif
    }
}

