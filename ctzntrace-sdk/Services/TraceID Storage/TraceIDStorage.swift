import Foundation

internal struct TraceIDRecord: Codable {
    public let start: Date
    public let end: Date
    public let traceID: String
}

//sourceery:AutoMockable
internal protocol TraceIDStorageProtocol {
    func getCurrent(_ completion: @escaping (String?) -> Void)
    func refreshIfNeeded()
    func clear()
}

internal final class TraceIDStorage: TraceIDStorageProtocol {
    private let environment: Environment
    private let userDefaultsIdentifier = "org.ctzn.traceUUIDs"
    private var knownIDs: [TraceIDRecord] = []
    private var lastID: TraceIDRecord?
    
    init(environment: Environment) {
        self.environment = environment
        restorePersistedIDs()
    }
    
    func getCurrent(_ completion: @escaping (String?) -> Void) {
        getCurrent(completion, refreshIfNeeded: true)
    }
    
    func refreshIfNeeded() {
        guard let lastID = knownIDs.last else {
            updateStoredIDs()
            return
        }
        
        let twelveHoursInSeconds: TimeInterval = 12 * 60 * 60
        let twelveHoursFromNow = Date()
            .addingTimeInterval(twelveHoursInSeconds)
        
        if lastID.end <= twelveHoursFromNow {
            updateStoredIDs()
        }
    }
    
    func clear() {
        knownIDs = []
        persistIDs([])
    }
    
    private func getCurrent(_ completion: @escaping (String?) -> Void, refreshIfNeeded: Bool) {
        let time = Date()
        
        // If the last known ID is still valid, just return that
        if let lastID = lastID, lastID.isCurrent(time) {
            completion(lastID.traceID)
            return
        }
        
        lastID = nil
        
        // Find the next valid ID
        if let (idx, id) = knownIDs.enumerated().first(where: { $1.isCurrent(time) }) {
            completion(id.traceID)
            lastID = id
            
            // Discard all the IDs older than the one we found; they're of
            // no use to us anymore
            knownIDs = Array(knownIDs[idx...])
            persistIDs(knownIDs)
            return
        }
        
        // If we still didn't find one, refresh our pool of IDs
        // Attempt to refresh one time at most
        guard refreshIfNeeded else {
            completion(nil)
            return
        }
        
        updateStoredIDs { success in
            if success {
                self.getCurrent(completion, refreshIfNeeded: false)
            } else {
                completion(nil)
            }
        }
    }

    private func updateStoredIDs(completion: ((_ success: Bool) -> Void)? = nil) {
        guard let userID = environment.session.userID else { return }

        environment.network.getTraceIDs(userID: userID) { result in
            if case .success(let ids) = result {
                self.didDownloadIDs(ids)
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }

    private func didDownloadIDs(_ ids: [TraceIDRecord]) {
        let sortedIDs = ids.sorted {
            $0.start < $1.start
        }
        
        self.knownIDs = sortedIDs
        self.persistIDs(sortedIDs)
    }
    
    private func restorePersistedIDs() {
        if let data = environment.defaults.data(forKey: userDefaultsIdentifier),
            let ids = try? JSONDecoder().decode([TraceIDRecord].self, from: data) {
            
            self.knownIDs = ids
        }
    }
    
    private func persistIDs(_ ids: [TraceIDRecord]) {
        guard let json = try? JSONEncoder().encode(ids) else {
            assertionFailure("Could not serialize trace IDs")
            return
        }
        
        environment.defaults.set(json, forKey: userDefaultsIdentifier)
    }
}

extension TraceIDRecord {
    func isCurrent(_ timestamp: Date) -> Bool {
        return timestamp >= start && timestamp < end
    }
}
