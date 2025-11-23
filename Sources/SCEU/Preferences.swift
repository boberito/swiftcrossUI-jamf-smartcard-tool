import Foundation
#if os(Windows)
    import WinSDK
#endif

enum PrefError: Error {
    case failed
    case suiteNotFound
    case verificationFailed
}

struct Preferences {

    var Server: String
    var ID1: String
    var ID2: String
    
    static func readPreferences() -> Preferences {
#if os(macOS)
        let bundlePLIST = UserDefaults.init(suiteName: "gov.nist.SmartCardEnforcementUtility")
        if let jamfserver = bundlePLIST?.string(forKey: "jss_URL"), let eaID = bundlePLIST?.string(forKey: "EA_ID"), let eaID2 = bundlePLIST?.string(forKey: "EA2_ID") {
            return(Preferences(Server: jamfserver, ID1: eaID, ID2: eaID2))
        }
        return(Preferences(Server: "",ID1: "",ID2: ""))
        
        
#elseif os(Windows)
        
        var jamfserver = String()
        jamfserver = ""
        var eaID = ""
        var eaID2 = ""
        

        func ReadRegistry(scope: HKEY, path: String, key: String) throws -> String {
            var szBuffer: [WCHAR] = Array<WCHAR>(repeating: 0, count: 64)

            var cbData: DWORD = 0
            while true {
                let lStatus: LSTATUS =
                    RegGetValueW(scope, path.wide,
                            key.wide, DWORD(RRF_RT_REG_SZ),
                            nil, &szBuffer, &cbData)
            
                if lStatus == ERROR_MORE_DATA {
                    szBuffer = Array<WCHAR>(repeating: 0, count: szBuffer.count * 2)
                    continue
                }
            
                guard lStatus == 0 else {
                    return ""
                }
                return String(decodingCString: szBuffer, as: UTF16.self)
                // return String(decoding: szBuffer, as: UTF16.self)
            }
        }


        do {
            jamfserver = try ReadRegistry(scope: HKEY_CURRENT_USER, path: "jamf-smartcard-utility", key: "jss_URL")
            eaID = try ReadRegistry(scope: HKEY_CURRENT_USER, path: "jamf-smartcard-utility", key: "EA_ID")
            eaID2 = try ReadRegistry(scope: HKEY_CURRENT_USER, path: "jamf-smartcard-utility", key: "EA2_ID")
       
        } catch {
            print("Error. Keys not found")
        }
        // return(Server: jamfserver, ID1: eaID, ID2: eaID2)
        return(Preferences(Server: jamfserver, ID1: eaID, ID2: eaID2))
        
#elseif os(Linux)
        
        var jamfserver = ""
        var eaID = ""
        var eaID2 = ""
        
        do {
            let homeDirURL = FileManager.default.homeDirectoryForCurrentUser
            let configPath = homeDirURL.path + "/.jamf-smartcard-utility.config"
            let contents = try String(contentsOfFile: configPath, encoding: String.Encoding.utf8)
            
            let entries = contents.components(separatedBy: "\n")
            
            for entry in entries {
                if entry.contains("jss_URL = "){
                    jamfserver = entry.components(separatedBy: " = ")[1].replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
                }
                if entry.contains("EA_ID = "){
                    eaID = entry.components(separatedBy: " = ")[1].replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
                }
                if entry.contains("EA2_ID = "){
                    eaID2 = entry.components(separatedBy: " = ")[1].replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
                }
            }
        } catch {
            //no config file found
        }
        
        return(Preferences(Server: jamfserver, ID1: eaID, ID2: eaID2))
        
#endif
    }

    func writeLinuxPrefs(server: String, ea1: String, ea2: String) throws {

        let home = FileManager.default.homeDirectoryForCurrentUser
        let fileURL = home.appendingPathComponent(".jamf-smartcard-utility.config")

        // Create the plain text contents
        let contents = """
        jss_URL = \(server)
        EA_ID = \(ea1)
        EA2_ID = \(ea2)
        """

        // Convert to Data
        guard let data = contents.data(using: .utf8) else {
            throw PrefError.failed
        }

        // Write atomically (safe write)
        try data.write(to: fileURL, options: .atomic)
    }

    func writePreferences(key: String, value: String) throws {
#if os(Windows)
        let registryKey = "jamf-smartcard-utility" + "\0"
        var hkey: HKEY? = nil
        var disposition: DWORD = 0
        let registryResult = RegCreateKeyExW(HKEY_CURRENT_USER, registryKey.wide, 0, nil, 0, 0xF003F, nil, &hkey, &disposition)

        guard registryResult == ERROR_SUCCESS else {
            throw PrefError.failed
        }

        let registryValueResult = RegSetKeyValueW(HKEY_CURRENT_USER, registryKey.wide, key.wide, DWORD(REG_SZ), value.wide, DWORD(value.utf16.count * MemoryLayout<WCHAR>.size))

        guard registryValueResult == ERROR_SUCCESS else {
            throw PrefError.failed
        }
#endif

#if os(macOS)
        

        guard let bundlePLIST = UserDefaults.init(suiteName: "gov.nist.SmartCardEnforcementUtility") else {
            throw PrefError.suiteNotFound
        }
        bundlePLIST.set(value, forKey: key)

        let testPlist = bundlePLIST.object(forKey: key) 

        if testPlist == nil {
            throw PrefError.verificationFailed
        }
#endif 
    }


}

#if os(Windows)
extension String {
  // Convert a String to a UTF-16 wide string
  public var wide: [UInt16] {
    return self.withCString(encodedAs: UTF16.self) { buffer in
      [UInt16](unsafeUninitializedCapacity: self.utf16.count + 1) {  // +1 for null terminator
        wcscpy_s($0.baseAddress, $0.count, buffer)
        $1 = $0.count
      }
    }
  }
}

#endif