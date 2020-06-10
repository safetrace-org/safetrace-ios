import CoreBluetooth
import Foundation

internal final class CBCentralManagerMock: CBCentralManager {
    var mockState: CBManagerState = .poweredOff
    override var state: CBManagerState {
        return mockState
    }

    var dummyDelegate: CBCentralManagerDelegate = CBCentralManagerMockDummyDelegate()
    override var delegate: CBCentralManagerDelegate? {
        get { dummyDelegate }
        set { }
    }

    var initOptions: [String: Any]?
    var initDelegate: CBCentralManagerDelegate?
    override init(delegate: CBCentralManagerDelegate?, queue: DispatchQueue?, options: [String: Any]? = nil) {
        initOptions = options
        initDelegate = delegate
        super.init(delegate: dummyDelegate, queue: nil, options: options)
    }

    var lastServicesToScanFor: [CBUUID]?
    override func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]? = nil) {
        lastServicesToScanFor = serviceUUIDs
    }
    
    weak var lastConnectedPeripheral: CBPeripheral?
    override func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil) {
        lastConnectedPeripheral = peripheral
    }
    
    var stopScanCalled = false
    override func stopScan() {
        stopScanCalled = true
    }
}

internal final class CBCentralManagerMockDummyDelegate: NSObject, CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        //
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        //
    }
}
