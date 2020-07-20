import CoreBluetooth
import Foundation

protocol BluetoothPeripheralDelegate: AnyObject {
    func logError(_: String, context _: String, meta: [String: Any]?)
}

class BluetoothPeripheral: NSObject {
    private let environment: Environment
    var peripheralManager: CBPeripheralManager?
    weak var delegate: BluetoothPeripheralDelegate?

    private var characteristic: CBCharacteristic?
    private let peripheralManagerClass: CBPeripheralManager.Type
    
    init(
        environment: Environment,
        peripheralManagerClass: CBPeripheralManager.Type = CBPeripheralManager.self
    ) {
        self.environment = environment
        self.peripheralManagerClass = peripheralManagerClass
    }
    
    var isStarted: Bool {
        return peripheralManager != nil
    }

    func start() {
        guard !isStarted else { return }
        peripheralManager = peripheralManagerClass.init(delegate: self, queue: nil, options: [
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
    
    private func logError(_ error: String, context: String, meta: [String: Any]? = nil) {
        delegate?.logError(error, context: context, meta: meta)
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
        prepareDataForRequest { result in
            switch result {
            case .success(let data):
                request.value = data
                peripheral.respond(to: request, withResult: .success)
            case .failure:
                peripheral.respond(to: request, withResult: .attributeNotFound)
            }
        }
    }
    
    func prepareDataForRequest(completion: @escaping (Result<Data, Error>) -> Void) {
        let appState = self.environment.device.appState()
        let model = self.environment.device.model()
        
        environment.traceIDs.getCurrent { traceID in
            guard let traceID = traceID else {
                self.logError("ID not found", context: "didReceiveReadRequest")
                completion(.failure(PeripheralError.idNotFound))
                return
            }

            let packet = TracePacket(
                traceID: traceID,
                foreground: appState == .active,
                phoneModel: model)
            
            do {
                let jsonData = try JSONEncoder().encode(packet)
                completion(.success(jsonData))
            } catch let error {
                self.logError("Could not serialize JSON", context: "didReceiveReadRequest")
                completion(.failure(error))
            }
        }
    }
}

enum PeripheralError: Error {
    case idNotFound
}
