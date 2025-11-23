//
//  jamfData.swift
//  
//
//  Created by Gendler, Bob (Fed) on 4/1/22.
//

import Foundation

struct ComputerKey: Hashable, Decodable, Encodable {
    let name: String
    let id: String
}

struct LoginInfo: Hashable, Decodable, Encodable {
    var username: String
    var password: String
}

struct JamfSearchInfo: Decodable, Hashable, Encodable {
    let totalCount: Int
    let results: [ComputerResult]
}

struct ComputerResult: Hashable, Decodable, Encodable, Identifiable {
        let id: String
        let udid: String
        let general: General
        let userAndLocation: UserAndLocation
        let hardware: Hardware?  // Make optional since it could be null
        let operatingSystem: OperatingSystem
        let configurationProfiles: [ConfigurationProfile]?
        let extensionAttributes: [ExtensionAttribute]
        
        // Add CodingKeys if needed to handle missing fields in your struct
        private enum CodingKeys: String, CodingKey {
            case id, udid, general, userAndLocation, hardware, operatingSystem, configurationProfiles
            case extensionAttributes = "extensionAttributes"
        }
}        

struct General: Hashable, Decodable, Encodable {
    let name: String
    let lastIpAddress: String?
    let lastReportedIpV4: String?
    let assetTag: String?
    let reportDate: String?
    let lastContactTime: String?
    let lastEnrolledDate: String?
    let mdmProfileExpiration: String?
    let managementId: String
    let remoteManagement: remoteManagement?
    let extensionAttributes: [ExtensionAttribute]
}

struct remoteManagement: Hashable, Decodable, Encodable {
    let managed: Bool?
    let managementUsername: String?
}
struct UserAndLocation: Hashable, Decodable, Encodable {
    let username: String?
    let realname: String?
    let email: String?
    let position: String?
    let phone: String?
    let departmentId: String?
    let buildingId: String?
    let room: String?
    let extensionAttributes: [ExtensionAttribute]
}

struct ConfigurationProfile: Hashable, Decodable, Encodable {
    let id: String?
    let username: String?
    let lastInstalled: String?
    let removable: Bool?
    let displayName: String?
    let profileIdentifier: String?
}
struct Hardware: Hashable, Decodable, Encodable {
    let make: String?
    let model: String?
    let modelIdentifier: String?
    let serialNumber: String?
    let processorType: String?
    let processorArchitecture: String?
    let appleSilicon: Bool?
    let extensionAttributes: [ExtensionAttribute]
}

struct OperatingSystem: Hashable, Decodable, Encodable {
    let version: String?
    let activeDirectoryStatus: String?
    let extensionAttributes: [ExtensionAttribute]
}

struct ExtensionAttribute: Hashable, Decodable, Encodable {
    let definitionId: String?
    let name: String?
    let description: String?
    let values: [String]
    
    // Add CodingKeys to ignore fields you don't need
    private enum CodingKeys: String, CodingKey {
        case definitionId, name, description, values
    }
}



struct userGroupInfo: Decodable {
    let user_group: usergroup
    
    struct usergroup: Decodable {
        let users:[entries]
        
        struct entries: Decodable {
            let username: String
        }
    }
}

struct extensionAttribute: Decodable {
    let computer: computerEA
    
    struct computerEA: Decodable {
        let extension_attributes: [EA]
        
        struct EA: Decodable {
            let id: Int
            let name: String
            let value: String
        }
        
    }
    
}

struct jamfauth: Decodable {
    let token: String
    let expires: String?
    let httpStatus: Int?
}

struct permissionInfo: Decodable {
    let user: User
    struct User: Decodable {
        let privileges: [String]
    }
}
