import CoreBluetooth
import Foundation
import SwiftyMocky
import XCTest
@testable import SafeTrace

internal final class BluetoothPeripheralTests: TestCase {
    
    var sut: BluetoothPeripheral!
    var mockPeripheralManager: CBPeripheralManagerMock? {
        return sut.peripheralManager as? CBPeripheralManagerMock
    }
    
    override func setUp() {
        super.setUp()
        sut = BluetoothPeripheral(environment: environment, peripheralManagerClass: CBPeripheralManagerMock.self)
    }

    func testDoesNotInstantiatePeripheralOnInit() {
        XCTAssert(sut.peripheralManager == nil)
    }

    func testInstantiatesPeripheralOnStartAndDoesNotAddService() {
        sut.start()
        sut.peripheralManager(mockPeripheralManager!, willRestoreState: [:])
        XCTAssert(sut.peripheralManager != nil)
        XCTAssert(mockPeripheralManager!.addedServices.isEmpty)
        XCTAssertEqual(
            mockPeripheralManager!.initOptions![CBCentralManagerOptionRestoreIdentifierKey] as! String,
            peripheralRestorationIdentifier)
    }

    func testAddsServiceWhenPoweredOn() {
        sut.start()

        mockPeripheralManager!.mockState = .poweredOn
        sut.peripheralManagerDidUpdateState(mockPeripheralManager!)

        XCTAssert(mockPeripheralManager!.removeAllServicesCalled)
        XCTAssert(mockPeripheralManager!.addedServices.count == 1)
        let service = mockPeripheralManager!.addedServices.first!
        XCTAssertEqual(service.uuid, contactTracingServiceIdentifier)

        XCTAssert(service.characteristics!.count == 1)
        let characteristic = service.characteristics!.first!
        XCTAssertEqual(characteristic.uuid, tracePacketCharacteristicIdentifier)
        XCTAssertEqual(characteristic.properties, [.read])

        XCTAssert(mockPeripheralManager!.advertisementData == nil)
    }

    func testAdvertisesContactTracingService() {
        sut.start()

        mockPeripheralManager!.mockState = .poweredOn
        sut.peripheralManagerDidUpdateState(mockPeripheralManager!)
        sut.peripheralManager(mockPeripheralManager!, didAdd: mockPeripheralManager!.addedServices.first!, error: nil)

        XCTAssertEqual(
            mockPeripheralManager!.advertisementData![CBAdvertisementDataServiceUUIDsKey] as! [CBUUID],
            [contactTracingServiceIdentifier])
    }
    
    func testClearsServicesAndPeripheralManagerWhenStopped() {
        sut.start()

        mockPeripheralManager!.mockState = .poweredOn
        sut.peripheralManagerDidUpdateState(mockPeripheralManager!)
        sut.peripheralManager(mockPeripheralManager!, didAdd: mockPeripheralManager!.addedServices.first!, error: nil)

        // keep a reference, as SUT's reference will be cleared when stop() is called
        let mockPeripheralManager = self.mockPeripheralManager!
        mockPeripheralManager.removeAllServicesCalled = false
        sut.stop()
        
        XCTAssert(mockPeripheralManager.removeAllServicesCalled)
        XCTAssert(sut.peripheralManager == nil)
    }
    
    func testRespondsToReadRequestWithSuccess() {
        Perform(environment.mockTraceIDs, .getCurrent(.any, perform: { completion in
            completion("zoop")
        }))
        environment.device.model = { "floop" }
        environment.device.appState = { .active }

        let expectation = XCTestExpectation(description: "async")
        sut.prepareDataForRequest { result in
            let data = result.value!
            let decodedData = try! JSONDecoder().decode(TracePacket.self, from: data)
            XCTAssertEqual(decodedData.traceID, "zoop")
            XCTAssertEqual(decodedData.phoneModel, "floop")
            XCTAssertEqual(decodedData.foreground, true)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    func testRespondsToReadRequestWithFailureWhenIDNotFound() {
        Perform(environment.mockTraceIDs, .getCurrent(.any, perform: { completion in
            completion(nil)
        }))
        environment.device.model = { "floop" }
        environment.device.appState = { .active }

        let expectation = XCTestExpectation(description: "async")
        sut.prepareDataForRequest { result in
            XCTAssertNotNil(result.error)
            XCTAssertNil(result.value)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
