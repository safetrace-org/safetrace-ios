import CoreBluetooth
import Foundation
import SwiftyMocky
import XCTest
@testable import SafeTrace

enum TestError: Error {
    case ohNo
}

internal final class BluetoothCentralTests: TestCase {
    var sut: BluetoothCentral!
    var mockCentralManager: CBCentralManagerMock? {
        return sut.centralManager as? CBCentralManagerMock
    }
    
    override func setUp() {
        super.setUp()
        sut = BluetoothCentral(environment: environment, centralManagerClass: CBCentralManagerMock.self)
    }
    
    func testDoesNotInstantiateCentralOnInit() {
        XCTAssert(sut.centralManager == nil)
    }
    
    func testInstantiatesCentralOnStartButDoesNotScan() {
        sut.start()
        
        XCTAssert(sut.centralManager != nil)
        XCTAssert(mockCentralManager!.lastServicesToScanFor == nil)
        XCTAssertEqual(
            mockCentralManager!.initOptions![CBCentralManagerOptionRestoreIdentifierKey] as! String,
            centralRestorationIdentifier)
    }
    
    func testScansForPeripheralsWhenPoweredOn() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn
        sut.centralManagerDidUpdateState(mockCentralManager!)
        
        XCTAssert(mockCentralManager!.lastServicesToScanFor == [contactTracingServiceIdentifier])
    }
    
    func testConnectsToPeripheralWithNoAdvertisementData() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        let peripheral = CBPeripheralMock(uuid: UUID())
        sut.centralManager(mockCentralManager!, didDiscover: peripheral, advertisementData: [:], rssi: 1.0)

        XCTAssert(mockCentralManager!.lastConnectedPeripheral == peripheral)
    }

    func testDoesNotConnectToSamePeripheralTwice() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        let peripheral = CBPeripheralMock(uuid: UUID())
        sut.centralManager(mockCentralManager!, didDiscover: peripheral, advertisementData: [:], rssi: 1.0)
        
        mockCentralManager?.lastConnectedPeripheral = nil
        sut.centralManager(mockCentralManager!, didDiscover: peripheral, advertisementData: [:], rssi: 1.0)
        
        XCTAssert(mockCentralManager!.lastConnectedPeripheral == nil)
    }
    
    func testDoesNotConnectToDifferentAndroidPeripheralsWithSameManufacturerData() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        let peripheral1 = CBPeripheralMock(uuid: UUID())
        let peripheral2 = CBPeripheralMock(uuid: UUID())
        let manufacturerData = "abcdefg".data(using: .utf8)
        
        sut.centralManager(
            mockCentralManager!,
            didDiscover: peripheral1,
            advertisementData: [
                CBAdvertisementDataManufacturerDataKey: manufacturerData as Any
            ],
            rssi: 1.0)
        
        sut.centralManager(
            mockCentralManager!,
            didDiscover: peripheral2,
            advertisementData: [
                CBAdvertisementDataManufacturerDataKey: manufacturerData as Any
            ],
            rssi: 1.0)

        XCTAssert(mockCentralManager!.lastConnectedPeripheral == peripheral1)
    }
    
    
    func testConnectsToDifferentAndroidPeripheralsWithDifferentManufacturerData() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        let peripheral1 = CBPeripheralMock(uuid: UUID())
        let peripheral2 = CBPeripheralMock(uuid: UUID())
        let manufacturerData1 = "abcdefg".data(using: .utf8)
        let manufacturerData2 = "hijklmn".data(using: .utf8)

        sut.centralManager(
            mockCentralManager!,
            didDiscover: peripheral1,
            advertisementData: [
                CBAdvertisementDataManufacturerDataKey: manufacturerData1 as Any
            ],
            rssi: 1.0)
        
        sut.centralManager(
            mockCentralManager!,
            didDiscover: peripheral2,
            advertisementData: [
                CBAdvertisementDataManufacturerDataKey: manufacturerData2 as Any
            ],
            rssi: 1.0)

        XCTAssert(mockCentralManager!.lastConnectedPeripheral == peripheral2)
    }
    
    func testRetainsPeripheralWhenConnecting() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        var peripheral: CBPeripheralMock? = CBPeripheralMock(uuid: UUID())
        sut.centralManager(mockCentralManager!, didDiscover: peripheral!, advertisementData: [:], rssi: 1.0)
        weak var weakPeripheral: CBPeripheralMock? = peripheral
        peripheral = nil

        XCTAssertNotNil(weakPeripheral)
    }
    
    func testReleasesPeripheralWhenFailedToConnect() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        var peripheral: CBPeripheralMock? = CBPeripheralMock(uuid: UUID())
        sut.centralManager(mockCentralManager!, didDiscover: peripheral!, advertisementData: [:], rssi: 1.0)
        sut.centralManager(mockCentralManager!, didFailToConnect: peripheral!, error: TestError.ohNo)

        weak var weakPeripheral: CBPeripheralMock? = peripheral
        peripheral = nil

        XCTAssertNil(weakPeripheral)
    }

    func testDiscoversServicesWhenConnectedToPeripheral() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        let peripheral = CBPeripheralMock(uuid: UUID())
        sut.centralManager(mockCentralManager!, didDiscover: peripheral, advertisementData: [:], rssi: 1.0)
        sut.centralManager(mockCentralManager!, didConnect: peripheral)
        
        XCTAssert(peripheral.lastDiscoverServicesArg == [contactTracingServiceIdentifier])
    }
    
    func testDiscoversCharacteristicsWhenServiceDiscovered() {
        sut.start()
        
        let service = CBServiceMock(uuid: contactTracingServiceIdentifier)
        let peripheral = CBPeripheralMock(uuid: UUID(), services: [service])
        sut.centralManager(mockCentralManager!, didDiscover: peripheral, advertisementData: [:], rssi: 1.0)
        sut.peripheral(peripheral, didDiscoverServices: nil)
        
        XCTAssert(peripheral.lastDiscoverCharacteristicsServiceArg == service)
        XCTAssert(peripheral.lastDiscoverCharacteristicsUUIDArd == [tracePacketCharacteristicIdentifier])
    }
    
    func testReleasesPeripheralWhenFailedToDiscoverServices() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        var peripheral: CBPeripheralMock? = CBPeripheralMock(uuid: UUID())
        sut.centralManager(mockCentralManager!, didDiscover: peripheral!, advertisementData: [:], rssi: 1.0)
        sut.peripheral(peripheral!, didDiscoverServices: TestError.ohNo)
        
        XCTAssert(peripheral!.lastDiscoverCharacteristicsServiceArg == nil)
        XCTAssert(peripheral!.lastDiscoverCharacteristicsUUIDArd == nil)

        weak var weakPeripheral: CBPeripheralMock? = peripheral
        peripheral = nil
        
        XCTAssertNil(weakPeripheral)
    }
    
    func testReleasesPeripheralWhenServiceNotFound() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        // No error, but peripheral is being instantiated without the desired service.
        var peripheral: CBPeripheralMock? = CBPeripheralMock(uuid: UUID())
        sut.centralManager(mockCentralManager!, didDiscover: peripheral!, advertisementData: [:], rssi: 1.0)
        sut.peripheral(peripheral!, didDiscoverServices: nil)
        
        XCTAssert(peripheral!.lastDiscoverCharacteristicsServiceArg == nil)
        XCTAssert(peripheral!.lastDiscoverCharacteristicsUUIDArd == nil)

        weak var weakPeripheral: CBPeripheralMock? = peripheral
        peripheral = nil
        
        XCTAssertNil(weakPeripheral)
    }
    
    func readsValueWhenCharacteristicDiscovered() {
        sut.start()
        
        let characteristic = CBCharacteristicMock(uuid: tracePacketCharacteristicIdentifier)
        let service = CBServiceMock(uuid: contactTracingServiceIdentifier, characteristics: [characteristic])
        let peripheral = CBPeripheralMock(uuid: UUID(), services: [service])
        sut.centralManager(mockCentralManager!, didDiscover: peripheral, advertisementData: [:], rssi: 1.0)
        sut.peripheral(peripheral, didDiscoverCharacteristicsFor: service, error: nil)
        
        XCTAssert(peripheral.lastReadValueArg == characteristic)
    }
    
    func testReleasesPeripheralWhenFailedToDiscoverCharacteristic() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        var peripheral: CBPeripheralMock? = CBPeripheralMock(uuid: UUID())
        let characteristic = CBCharacteristicMock(uuid: tracePacketCharacteristicIdentifier)
        let service = CBServiceMock(uuid: contactTracingServiceIdentifier, characteristics: [characteristic])
        sut.centralManager(mockCentralManager!, didDiscover: peripheral!, advertisementData: [:], rssi: 1.0)
        sut.peripheral(peripheral!, didDiscoverCharacteristicsFor: service, error: TestError.ohNo)
        
        XCTAssert(peripheral?.lastReadValueArg == nil)
        
        weak var weakPeripheral: CBPeripheralMock? = peripheral
        peripheral = nil
        
        XCTAssertNil(weakPeripheral)
    }
    
    func testReleasesPeripheralWhenCharacteristicNotFound() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        var peripheral: CBPeripheralMock? = CBPeripheralMock(uuid: UUID())
        let service = CBServiceMock(uuid: contactTracingServiceIdentifier, characteristics: [])
        sut.centralManager(mockCentralManager!, didDiscover: peripheral!, advertisementData: [:], rssi: 1.0)
        sut.peripheral(peripheral!, didDiscoverCharacteristicsFor: service, error: nil)
        
        XCTAssert(peripheral?.lastReadValueArg == nil)
        
        weak var weakPeripheral: CBPeripheralMock? = peripheral
        peripheral = nil
        
        XCTAssertNil(weakPeripheral)
    }
    
    func testCallsDelegateWhenFinishedTrace() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn
        let delegate = BluetoothCentralDelegateMock()
        sut.delegate = delegate
        let now = Date()
        environment.date = { now }
        environment.device.appState = { .active }
        environment.device.model = { "floop" }

        let peripheral = CBPeripheralMock(uuid: UUID())
        let characteristic = CBCharacteristicMock(uuid: tracePacketCharacteristicIdentifier)
        sut.centralManager(mockCentralManager!, didDiscover: peripheral, advertisementData: [:], rssi: 1.0)
            
        let value = TracePacket(traceID: "zoop", foreground: true, phoneModel: "zip")
        let data = try! JSONEncoder().encode(value)
        characteristic.value = data
        sut.peripheral(peripheral, didUpdateValueFor: characteristic, error: nil)
        
        let expectedTrace = ContactTrace(sender: .init(foreground: true, signalStrength: 1.0, phoneModel: "zip", traceID: "zoop"),
                                 receiver: .init(timestamp: now, location: nil, foreground: true))

        Verify(delegate, .didFinishTrace(.value(expectedTrace)))
    }
    
    func testReleasesPeripheralWhenFinishedTrace() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        var peripheral: CBPeripheralMock? = CBPeripheralMock(uuid: UUID())
        let characteristic = CBCharacteristicMock(uuid: tracePacketCharacteristicIdentifier)
        sut.centralManager(mockCentralManager!, didDiscover: peripheral!, advertisementData: [:], rssi: 1.0)
            
        let value = TracePacket(traceID: "zoop", foreground: true, phoneModel: "zip")
        let data = try! JSONEncoder().encode(value)
        characteristic.value = data
        sut.peripheral(peripheral!, didUpdateValueFor: characteristic, error: nil)
        
        weak var weakPeripheral: CBPeripheralMock? = peripheral
        peripheral = nil
        
        XCTAssertNil(weakPeripheral)
    }
    
    func testReleasesPeripheralWhenReadValueFails() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        var peripheral: CBPeripheralMock? = CBPeripheralMock(uuid: UUID())
        let characteristic = CBCharacteristicMock(uuid: tracePacketCharacteristicIdentifier)
        let value = TracePacket(traceID: "zoop", foreground: true, phoneModel: "zip")
        let data = try! JSONEncoder().encode(value)
        characteristic.value = data
        sut.centralManager(mockCentralManager!, didDiscover: peripheral!, advertisementData: [:], rssi: 1.0)
        sut.peripheral(peripheral!, didUpdateValueFor: characteristic, error: TestError.ohNo)
        
        weak var weakPeripheral: CBPeripheralMock? = peripheral
        peripheral = nil
        
        XCTAssertNil(weakPeripheral)
    }
    
    func testReleasesPeripheralWhenValueIsNil() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        var peripheral: CBPeripheralMock? = CBPeripheralMock(uuid: UUID())
        let characteristic = CBCharacteristicMock(uuid: tracePacketCharacteristicIdentifier)
        sut.centralManager(mockCentralManager!, didDiscover: peripheral!, advertisementData: [:], rssi: 1.0)
        sut.peripheral(peripheral!, didUpdateValueFor: characteristic, error: nil)
        
        weak var weakPeripheral: CBPeripheralMock? = peripheral
        peripheral = nil
        
        XCTAssertNil(weakPeripheral)
    }
    
    func testReleasesPeripheralWhenParseValueFails() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn

        var peripheral: CBPeripheralMock? = CBPeripheralMock(uuid: UUID())
        let characteristic = CBCharacteristicMock(uuid: tracePacketCharacteristicIdentifier)
        sut.centralManager(mockCentralManager!, didDiscover: peripheral!, advertisementData: [:], rssi: 1.0)
        
        characteristic.value = "aaa".data(using: .utf8)
        sut.peripheral(peripheral!, didUpdateValueFor: characteristic, error: nil)
        
        weak var weakPeripheral: CBPeripheralMock? = peripheral
        peripheral = nil
        
        XCTAssertNil(weakPeripheral)
    }
    
    func testClearsCentralManagerWhenStopped() {
        sut.start()
        mockCentralManager!.mockState = .poweredOn
        let mockCentralManager = self.mockCentralManager
        
        sut.stop()
        
        XCTAssert(mockCentralManager!.stopScanCalled)
        XCTAssert(sut.centralManager == nil)
    }
}
