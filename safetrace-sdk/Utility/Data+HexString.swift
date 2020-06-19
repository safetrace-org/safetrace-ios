import Foundation

extension Data {
    var hexStringRepresentation: String {
        // "Array" of all bytes:
        let bytes = UnsafeBufferPointer<UInt8>(
            start: (self as NSData)
                .bytes.bindMemory(to: UInt8.self, capacity: self.count),
            count: self.count)
        // Array of hex strings, one for each byte:
        let hexBytes = bytes.map { String(format: "%02hhx", $0) }
        // Concatenate all hex strings:
        return hexBytes.joined()
    }
}
