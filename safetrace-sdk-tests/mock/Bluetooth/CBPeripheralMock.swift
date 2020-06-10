import CoreBluetooth
import Foundation

internal final class CBPeripheralMock: CBInstantiablePeripheral {
    var mockIdentifier: UUID
    override var identifier: UUID {
        return mockIdentifier
    }
    
    var mockServices: [CBService]?
    override var services: [CBService]? {
        return mockServices
    }
    
    init(uuid: UUID, services: [CBService]? = nil) {
        mockIdentifier = uuid
        mockServices = services
        super.init()
    }
    
    var lastDiscoverServicesArg: [CBUUID]?
    override func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        lastDiscoverServicesArg = serviceUUIDs
    }
    
    var lastDiscoverCharacteristicsUUIDArd: [CBUUID]?
    var lastDiscoverCharacteristicsServiceArg: CBService?
    override func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        lastDiscoverCharacteristicsUUIDArd = characteristicUUIDs
        lastDiscoverCharacteristicsServiceArg = service
    }
    
    var lastReadValueArg: CBCharacteristic?
    override func readValue(for characteristic: CBCharacteristic) {
        lastReadValueArg = characteristic
    }
}

internal final class CBServiceMock: CBMutableService {
    init(uuid: CBUUID, characteristics: [CBCharacteristic]? = nil) {
        super.init(type: uuid, primary: true)
        self.characteristics = characteristics
    }
}

internal final class CBCharacteristicMock: CBMutableCharacteristic {
    
    init(uuid: CBUUID) {
        super.init(type: uuid, properties: [], value: nil, permissions: [])
    }
}
