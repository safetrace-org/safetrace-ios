import CoreBluetooth
import Foundation

class BluetoothPeripheral: NSObject {
    private let environment: Environment
    
    private var peripheralManager: CBPeripheralManager?
    private var characteristic: CBCharacteristic?
    
    
    init(environment: Environment) {
        self.environment = environment
    }
    
    func start() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionRestoreIdentifierKey: peripheralRestorationIdentifier
        ])
    }
    
    func stop() {
        peripheralManager?.removeAllServices()
        peripheralManager = nil
    }

    private func startPeripheralService() {
        characteristic = CBMutableCharacteristic(
            type: tracePacketCharacteristicIdentifier,
            properties: [.read],
            value: nil,
            permissions: [.readable]
        )
        
        let serviceUUID = contactTracingServiceIdentifier
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [characteristic!]
        peripheralManager?.removeAllServices()
        peripheralManager?.add(service)
    }
    
    private func logError(_: String, context _: String) {
        // todo
    }
}

extension BluetoothPeripheral: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            startPeripheralService()
        }
    }
    
    func peripheralManager(_ manager: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        manager.startAdvertising([
            CBAdvertisementDataLocalNameKey: "Contact Tracing Service",
            CBAdvertisementDataServiceUUIDsKey: [service.uuid]
        ])
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String: Any]) {
        // no-op
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        let appState = self.environment.device.appState()
        let model = self.environment.device.model()
        environment.traceIDs.getCurrent { traceID in
            guard let traceID = traceID else {
                self.logError("UUID not found", context: "didReceiveReadRequest")
                peripheral.respond(to: request, withResult: .attributeNotFound)
                return
            }
            
            let packet = TracePacket(
                traceID: traceID,
                foreground: appState == .active,
                phoneModel: model)
            
            let jsonData = try? JSONEncoder().encode(packet)
            request.value = jsonData
            peripheral.respond(to: request, withResult: .success)
        }
    }
}
