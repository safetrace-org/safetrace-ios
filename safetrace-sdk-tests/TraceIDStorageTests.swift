import Foundation
import XCTest
import SwiftyMocky
@testable import SafeTrace

private let fifteenMinutes: TimeInterval = 15 * 60
private let twelveHours: TimeInterval = 12 * 60 * 60

final class TraceIDStorageTests: TestCase {
    var sut: TraceIDStorage!

    // Add persisted traceIDs before initializing SUT
    func initialize(with ids: [TraceIDRecord]) {
        let data = try! JSONEncoder().encode(ids)
        Given(environment.mockDefaults, .data(forKey: .any, willReturn: .some(data)))

        sut = TraceIDStorage(environment: environment)
        Given(environment.mockSession, .userID(getter: "6"))
    }


    func setRemoteTraceIDs(_ ids: [TraceIDRecord]) {
        Perform(environment.mockNetwork, .getTraceIDs(userID: .any, completion: .any, perform: { (_, completion) in
            completion(.success(ids))
        }))
    }
    
    // Ensure we can get the ID repeatedly without it changing and without making a new request
    func testGetCurrentIDTwice() {
        let now = environment.date()
        let ids: [TraceIDRecord] = [
            .init(
                start: now.addingTimeInterval(-fifteenMinutes),
                end: now,
                traceID: "past"),
            .init(
                start: now,
                end: now.addingTimeInterval(fifteenMinutes),
                traceID: "present"),
            .init(
                start: now.addingTimeInterval(fifteenMinutes),
                end: now.addingTimeInterval(fifteenMinutes * 2),
                traceID: "future")
        ]

        initialize(with: ids)
        setRemoteTraceIDs([])

        let expectation = XCTestExpectation(description: "async")
        sut.getCurrent { id1 in
            XCTAssertEqual(id1, "present")

            DispatchQueue.main.async {
                self.sut.getCurrent { id2 in
                    XCTAssertEqual(id2, "present")
                    Verify(environment.mockNetwork, 0, .getTraceIDs(userID: .any, completion: .any))
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testGetCurrentIDRequiringReload() {
        let now = environment.date()
        let ids: [TraceIDRecord] = [
            .init(
                start: now.addingTimeInterval(-fifteenMinutes * 2),
                end: now.addingTimeInterval(-fifteenMinutes),
                traceID: "distant past"),
            .init(
                start: now.addingTimeInterval(-fifteenMinutes),
                end: now,
                traceID: "past")
        ]

        initialize(with: ids)

        setRemoteTraceIDs([
            .init(
                start: now.addingTimeInterval(-fifteenMinutes),
                end: now,
                traceID: "past"),
            .init(
                start: now,
                end: now.addingTimeInterval(fifteenMinutes),
                traceID: "present"),
            .init(
                start: now.addingTimeInterval(fifteenMinutes),
                end: now.addingTimeInterval(fifteenMinutes * 2),
                traceID: "future")
        ])

        let expectation = XCTestExpectation(description: "async")
        sut.getCurrent { id1 in
            XCTAssertEqual(id1, "present")

            // Verify the IDs were stored and we don't request twice
            DispatchQueue.main.async {
                self.sut.getCurrent { id2 in
                    XCTAssertEqual(id2, "present")
                    Verify(environment.mockNetwork, 1, .getTraceIDs(userID: .any, completion: .any))
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testGetCurrentIDWhenAPIReturnsIncorrectSortOrder() {
        let now = environment.date()

        initialize(with: [])
        setRemoteTraceIDs([
            .init(
                start: now.addingTimeInterval(fifteenMinutes),
                end: now.addingTimeInterval(fifteenMinutes * 2),
                traceID: "future"),
            .init(
                start: now,
                end: now.addingTimeInterval(fifteenMinutes),
                traceID: "present"),
            .init(
                start: now.addingTimeInterval(-fifteenMinutes),
                end: now,
                traceID: "past")
        ])

        let expectation = XCTestExpectation(description: "async")
        sut.getCurrent { id1 in
            XCTAssertEqual(id1, "present")

            environment.date = { now.addingTimeInterval(fifteenMinutes) }
            self.sut.getCurrent { id2 in
                XCTAssertEqual(id2, "future")
                Verify(environment.mockNetwork, 1, .getTraceIDs(userID: .any, completion: .any))

                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1)
    }

    func testGetCurrentIDWithInvalidAPIResponse() {
        initialize(with: [])
        setRemoteTraceIDs([])

        let expectation = XCTestExpectation(description: "async")
        sut.getCurrent { id in
            XCTAssertEqual(id, nil)
            Verify(environment.mockNetwork, 1, .getTraceIDs(userID: .any, completion: .any))

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testUpdateIfNeededWhenUpdateIsNeeded() {
        let now = environment.date()
        
        initialize(with: [
            .init(
                start: now,
                end: now.addingTimeInterval(twelveHours),
                traceID: "past")
        ])

        sut.refreshIfNeeded()
        Verify(environment.mockNetwork, 1, .getTraceIDs(userID: .any, completion: .any))
    }

    func testUpdateIfNeededWhenUpdateIsNotNeeded() {
        let now = environment.date()
        
        initialize(with: [
            .init(
                start: now,
                end: now.addingTimeInterval(twelveHours + fifteenMinutes),
                traceID: "past")
        ])

        sut.refreshIfNeeded()
        Verify(environment.mockNetwork, 0, .getTraceIDs(userID: .any, completion: .any))
    }
}
