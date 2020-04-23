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
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_set__valueforKey_keywithAccess_withAccess(p0, p1, p2): return p0.intValue + p1.intValue + p2.intValue
            case let .m_get__key(p0): return p0.intValue
            case let .m_delete__key(p0): return p0.intValue
            }
        }
    }

    open class Given: StubbedMethod {
        fileprivate var method: MethodType

        private init(method: MethodType, products: [StubProduct]) {
            self.method = method
            super.init(products)
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





    open func requestAuthCode(phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_requestAuthCode__phone_phonecompletion_completion(Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_requestAuthCode__phone_phonecompletion_completion(Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (String, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`phone`, `completion`)
    }

    open func authenticateWithCode(_ token: String, phone: String, completion: @escaping (Result<AuthData, Error>) -> Void) {
        addInvocation(.m_authenticateWithCode__tokenphone_phonecompletion_completion(Parameter<String>.value(`token`), Parameter<String>.value(`phone`), Parameter<(Result<AuthData, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_authenticateWithCode__tokenphone_phonecompletion_completion(Parameter<String>.value(`token`), Parameter<String>.value(`phone`), Parameter<(Result<AuthData, Error>) -> Void>.value(`completion`))) as? (String, String, @escaping (Result<AuthData, Error>) -> Void) -> Void
		perform?(`token`, `phone`, `completion`)
    }

    open func getTraceIDs(userID: String, completion: @escaping (Result<[TraceIDRecord], Error>) -> Void) {
        addInvocation(.m_getTraceIDs__userID_userIDcompletion_completion(Parameter<String>.value(`userID`), Parameter<(Result<[TraceIDRecord], Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_getTraceIDs__userID_userIDcompletion_completion(Parameter<String>.value(`userID`), Parameter<(Result<[TraceIDRecord], Error>) -> Void>.value(`completion`))) as? (String, @escaping (Result<[TraceIDRecord], Error>) -> Void) -> Void
		perform?(`userID`, `completion`)
    }

    open func uploadTraces(_: ContactTraces, userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_uploadTraces__userIDuserID_completioncompletion(Parameter<String>.value(`userID`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_uploadTraces__userIDuserID_completioncompletion(Parameter<String>.value(`userID`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (String, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`userID`, `completion`)
    }


    fileprivate enum MethodType {
        case m_requestAuthCode__phone_phonecompletion_completion(Parameter<String>, Parameter<(Result<Void, Error>) -> Void>)
        case m_authenticateWithCode__tokenphone_phonecompletion_completion(Parameter<String>, Parameter<String>, Parameter<(Result<AuthData, Error>) -> Void>)
        case m_getTraceIDs__userID_userIDcompletion_completion(Parameter<String>, Parameter<(Result<[TraceIDRecord], Error>) -> Void>)
        case m_uploadTraces__userIDuserID_completioncompletion(Parameter<String>, Parameter<(Result<Void, Error>) -> Void>)

        static func compareParameters(lhs: MethodType, rhs: MethodType, matcher: Matcher) -> Bool {
            switch (lhs, rhs) {
            case (.m_requestAuthCode__phone_phonecompletion_completion(let lhsPhone, let lhsCompletion), .m_requestAuthCode__phone_phonecompletion_completion(let rhsPhone, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_authenticateWithCode__tokenphone_phonecompletion_completion(let lhsToken, let lhsPhone, let lhsCompletion), .m_authenticateWithCode__tokenphone_phonecompletion_completion(let rhsToken, let rhsPhone, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsToken, rhs: rhsToken, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_getTraceIDs__userID_userIDcompletion_completion(let lhsUserid, let lhsCompletion), .m_getTraceIDs__userID_userIDcompletion_completion(let rhsUserid, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsUserid, rhs: rhsUserid, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.m_uploadTraces__userIDuserID_completioncompletion(let lhsUserid, let lhsCompletion), .m_uploadTraces__userIDuserID_completioncompletion(let rhsUserid, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsUserid, rhs: rhsUserid, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case let .m_requestAuthCode__phone_phonecompletion_completion(p0, p1): return p0.intValue + p1.intValue
            case let .m_authenticateWithCode__tokenphone_phonecompletion_completion(p0, p1, p2): return p0.intValue + p1.intValue + p2.intValue
            case let .m_getTraceIDs__userID_userIDcompletion_completion(p0, p1): return p0.intValue + p1.intValue
            case let .m_uploadTraces__userIDuserID_completioncompletion(p0, p1): return p0.intValue + p1.intValue
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

        public static func requestAuthCode(phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_requestAuthCode__phone_phonecompletion_completion(`phone`, `completion`))}
        public static func authenticateWithCode(_ token: Parameter<String>, phone: Parameter<String>, completion: Parameter<(Result<AuthData, Error>) -> Void>) -> Verify { return Verify(method: .m_authenticateWithCode__tokenphone_phonecompletion_completion(`token`, `phone`, `completion`))}
        public static func getTraceIDs(userID: Parameter<String>, completion: Parameter<(Result<[TraceIDRecord], Error>) -> Void>) -> Verify { return Verify(method: .m_getTraceIDs__userID_userIDcompletion_completion(`userID`, `completion`))}
        public static func uploadTraces(userID: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_uploadTraces__userIDuserID_completioncompletion(`userID`, `completion`))}
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func requestAuthCode(phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (String, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_requestAuthCode__phone_phonecompletion_completion(`phone`, `completion`), performs: perform)
        }
        public static func authenticateWithCode(_ token: Parameter<String>, phone: Parameter<String>, completion: Parameter<(Result<AuthData, Error>) -> Void>, perform: @escaping (String, String, @escaping (Result<AuthData, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_authenticateWithCode__tokenphone_phonecompletion_completion(`token`, `phone`, `completion`), performs: perform)
        }
        public static func getTraceIDs(userID: Parameter<String>, completion: Parameter<(Result<[TraceIDRecord], Error>) -> Void>, perform: @escaping (String, @escaping (Result<[TraceIDRecord], Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_getTraceIDs__userID_userIDcompletion_completion(`userID`, `completion`), performs: perform)
        }
        public static func uploadTraces(userID: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (String, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_uploadTraces__userIDuserID_completioncompletion(`userID`, `completion`), performs: perform)
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

    open func authenticateWithCode(_: String, phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_authenticateWithCode__phonephone_completioncompletion(Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_authenticateWithCode__phonephone_completioncompletion(Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (String, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`phone`, `completion`)
    }

    open func authenticateWithToken(_: String) {
        addInvocation(.m_authenticateWithToken)
		let perform = methodPerformValue(.m_authenticateWithToken) as? () -> Void
		perform?()
    }

    open func requestAuthenticationCode(for phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        addInvocation(.m_requestAuthenticationCode__for_phonecompletion_completion(Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`)))
		let perform = methodPerformValue(.m_requestAuthenticationCode__for_phonecompletion_completion(Parameter<String>.value(`phone`), Parameter<(Result<Void, Error>) -> Void>.value(`completion`))) as? (String, @escaping (Result<Void, Error>) -> Void) -> Void
		perform?(`phone`, `completion`)
    }


    fileprivate enum MethodType {
        case m_logout
        case m_authenticateWithCode__phonephone_completioncompletion(Parameter<String>, Parameter<(Result<Void, Error>) -> Void>)
        case m_authenticateWithToken
        case m_requestAuthenticationCode__for_phonecompletion_completion(Parameter<String>, Parameter<(Result<Void, Error>) -> Void>)
        case p_authenticationDelegate_get
		case p_authenticationDelegate_set(Parameter<UserSessionAuthenticationDelegate?>)
        case p_isAuthenticated_get
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
            case (.m_authenticateWithToken, .m_authenticateWithToken):
                return true 
            case (.m_requestAuthenticationCode__for_phonecompletion_completion(let lhsPhone, let lhsCompletion), .m_requestAuthenticationCode__for_phonecompletion_completion(let rhsPhone, let rhsCompletion)):
                guard Parameter.compare(lhs: lhsPhone, rhs: rhsPhone, with: matcher) else { return false } 
                guard Parameter.compare(lhs: lhsCompletion, rhs: rhsCompletion, with: matcher) else { return false } 
                return true 
            case (.p_authenticationDelegate_get,.p_authenticationDelegate_get): return true
			case (.p_authenticationDelegate_set(let left),.p_authenticationDelegate_set(let right)): return Parameter<UserSessionAuthenticationDelegate?>.compare(lhs: left, rhs: right, with: matcher)
            case (.p_isAuthenticated_get,.p_isAuthenticated_get): return true
            case (.p_userID_get,.p_userID_get): return true
            case (.p_authToken_get,.p_authToken_get): return true
            default: return false
            }
        }

        func intValue() -> Int {
            switch self {
            case .m_logout: return 0
            case let .m_authenticateWithCode__phonephone_completioncompletion(p0, p1): return p0.intValue + p1.intValue
            case .m_authenticateWithToken: return 0
            case let .m_requestAuthenticationCode__for_phonecompletion_completion(p0, p1): return p0.intValue + p1.intValue
            case .p_authenticationDelegate_get: return 0
			case .p_authenticationDelegate_set(let newValue): return newValue.intValue
            case .p_isAuthenticated_get: return 0
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
        public static func authenticateWithCode(phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_authenticateWithCode__phonephone_completioncompletion(`phone`, `completion`))}
        public static func authenticateWithToken() -> Verify { return Verify(method: .m_authenticateWithToken)}
        public static func requestAuthenticationCode(for phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>) -> Verify { return Verify(method: .m_requestAuthenticationCode__for_phonecompletion_completion(`phone`, `completion`))}
        public static var authenticationDelegate: Verify { return Verify(method: .p_authenticationDelegate_get) }
		public static func authenticationDelegate(set newValue: Parameter<UserSessionAuthenticationDelegate?>) -> Verify { return Verify(method: .p_authenticationDelegate_set(newValue)) }
        public static var isAuthenticated: Verify { return Verify(method: .p_isAuthenticated_get) }
        public static var userID: Verify { return Verify(method: .p_userID_get) }
        public static var authToken: Verify { return Verify(method: .p_authToken_get) }
    }

    public struct Perform {
        fileprivate var method: MethodType
        var performs: Any

        public static func logout(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_logout, performs: perform)
        }
        public static func authenticateWithCode(phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (String, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_authenticateWithCode__phonephone_completioncompletion(`phone`, `completion`), performs: perform)
        }
        public static func authenticateWithToken(perform: @escaping () -> Void) -> Perform {
            return Perform(method: .m_authenticateWithToken, performs: perform)
        }
        public static func requestAuthenticationCode(for phone: Parameter<String>, completion: Parameter<(Result<Void, Error>) -> Void>, perform: @escaping (String, @escaping (Result<Void, Error>) -> Void) -> Void) -> Perform {
            return Perform(method: .m_requestAuthenticationCode__for_phonecompletion_completion(`phone`, `completion`), performs: perform)
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

