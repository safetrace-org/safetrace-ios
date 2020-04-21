//
//  TraceIDStorageTests.swift
//  safetrace-sdk-tests
//
//  Created by Max Mamis on 4/21/20.
//  Copyright © 2020 CTZN.ORG. All rights reserved.
//

import Foundation
import XCTest
import SwiftyMocky
@testable import SafeTrace

internal final class TraceIDStorageTests: XCTestCase {
    func testABC() {
        let mock = NetworkProtocolMock()
        Perform(mock, .getTraceIDs(userID: .any, completion: .any, perform: { (_, completion) in
            completion(.success([]))
        }))
        
        let expectation = XCTestExpectation(description: "async")
        mock.getTraceIDs(userID: "1") { (result) in
            XCTAssert(result.value!.isEmpty)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
