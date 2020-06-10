import Foundation
import XCTest
@testable import SafeTrace

internal final class MockEnvironment: Environment {
    lazy var tracer: ContactTracer = ContactTracer(environment: self)
    var network: NetworkProtocol { return mockNetwork }
    var session: UserSessionProtocol { return mockSession }
    var defaults: UserDefaultsProtocol { return mockDefaults }
    var traceIDs: TraceIDStorageProtocol { return mockTraceIDs }
    var location: LocationProviding { return mockLocation }
    var device = Device()
    var date: () -> Date = { Date() }
    
    let mockNetwork = NetworkProtocolMock()
    let mockSession = UserSessionProtocolMock()
    let mockDefaults = UserDefaultsProtocolMock()
    let mockTraceIDs = TraceIDStorageProtocolMock()
    let mockLocation = LocationProvidingMock()
}

var environment: MockEnvironment!

open class TestCase: XCTestCase {
    open override func setUp() {
        super.setUp()
        // reset mock environment to null state before every test
        environment = MockEnvironment()
    }
}
