import CoreBluetooth
import Foundation

internal final class CBPeripheralManagerMock: CBPeripheralManager {
    var mockState: CBManagerState = .poweredOff
    override var state: CBManagerState {
        return mockState
    }
    
    var dummyDelegate: CBPeripheralManagerDelegate = CBPeripheralManagerMockDummyDelegate()
    override var delegate: CBPeripheralManagerDelegate? {
        get { dummyDelegate }
        set { }
    }
    
    var initOptions: [String: Any]?
    weak var initDelegate: CBPeripheralManagerDelegate?
    override init(delegate: CBPeripheralManagerDelegate?, queue: DispatchQueue?, options: [String: Any]? = nil) {
        initOptions = options
        initDelegate = delegate
        super.init(delegate: dummyDelegate, queue: nil, options: nil)
    }
    
    var removeAllServicesCalled = false
    override func removeAllServices() {
        removeAllServicesCalled = true
    }
    
    var addedServices: [CBService] = []
    override func add(_ service: CBMutableService) {
        addedServices.append(service)
    }
    
    var advertisementData: [String: Any]?
    override func startAdvertising(_ advertisementData: [String: Any]?) {
        self.advertisementData = advertisementData
    }
    
    private var lastRespondedRequest: CBATTRequest?
    private var lastRespondedResult: CBATTError.Code?
    override func respond(to request: CBATTRequest, withResult result: CBATTError.Code) {
        lastRespondedRequest = request
        lastRespondedResult = result
    }
}

class CBPeripheralManagerMockDummyDelegate: NSObject, CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String: Any]) {
        // no-op
    }
}
