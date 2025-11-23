//
//  InfoView.swift
//  SCEU
//
//  Created by Gendler, Bob (Fed) on 11/7/25.
//

import SwiftCrossUI
import Foundation

#if os(Linux)
    import GtkBackend
#else
    import DefaultBackend
#endif


struct InfoView: View {    
    
    @Binding var showInfo: Bool
    let computerRecord: ComputerResult?
    let eaID1: String?
    let eaID2: String?
    
    var body: some View {
        VStack{
            HStack{
               Text("Hostname:")
               Text(computerRecord?.general.name ?? "")
               .emphasized()
            }

            HStack{
                Text("Property Tag:")
                Text(computerRecord?.general.assetTag ?? "")
                .emphasized()
            }
            
            HStack{
                Text("OS Version:")
                Text(computerRecord?.operatingSystem.version ?? "")
                .emphasized()
            }        

            HStack{
                Text("Processor Type:")
                if let computerRecord = computerRecord, let hardware = computerRecord.hardware {
                    if let appleSilicon = hardware.appleSilicon {
                        if appleSilicon {
                            Text("Apple Silicon")
                            .emphasized()
                        } else {
                            Text("Intel")
                            .emphasized()    
                        }
                    } else {
                        Text("")
                    }

                } else {
                    Text("")
                }
            
                
            }

            HStack{
                Text("Last Checkin:")
                Text(computerRecord?.general.lastContactTime ?? "")
                .emphasized()
            }

            HStack{
                Text("Last Recon:")
                Text(computerRecord?.general.reportDate ?? "")
                .emphasized()
            }

            HStack{
                Text("Managed Status:")
                // if computerRecord?.general.remoteManagement.managed {
                if computerRecord?.general.remoteManagement?.managed == true {
                    Text("Managed")
                    .emphasized()
                } else {
                    Text("Unmanaged")
                    .emphasized()
                }
                
            }

            HStack{
                Text("IP Address:")
                Text(computerRecord?.general.lastIpAddress ?? "")
                .emphasized()
            }
            HStack{
                Text("IP Reported Address:")
                Text(computerRecord?.general.lastReportedIpV4 ?? "")                
                .emphasized()
            }
            HStack{
                Text("Uptime:")
                if let uptime = computerRecord?.extensionAttributes.first(where: {$0.definitionId == "478" }) {
                    Text(uptime.values.first ?? "")
                    .emphasized()
                } else {
                    Text("")
                }             
            }
            HStack {
                Text("Smartcard Status:")   
                if let configProfiles = computerRecord?.configurationProfiles {
                    if (configProfiles.first(where: {$0.displayName == "SmartCard Settings"}) != nil ) {
                        let disabledUntil = computerRecord?.extensionAttributes.first(where: {$0.definitionId == eaID2})?.values.first
                        if let disabledUntil = disabledUntil {
                            Text("Enforcement Disabled\nuntil \(disabledUntil)")
                            .emphasized()
                        } else {
                            Text("Enforcement Disabled")
                            .emphasized()
                        }
                    }
                    if (configProfiles.first(where: {$0.displayName == "Smartcard Settings - Enforced"}) != nil ) {                    
                        if computerRecord?.extensionAttributes.first(where: {$0.definitionId == eaID1 })?.values.first == "Disabled" {
                            Text("Enforcement Disabled\nsent but not received")
                            .emphasized()
                        } else {
                            Text("Enforced")
                            .emphasized()
                        }
                    }
                } else {
                    Text("")
                }

            }
            HStack{
                Text("AD Cert Status:")
                if let adcertStatus = computerRecord?.extensionAttributes.first(where: {$0.definitionId == "605" }) {
                    Text(adcertStatus.values.first ?? "")
                    .emphasized()
                } else {
                    Text("")
                }
                
            }

            HStack{
                Text("AD Group Membership:")
                if let adGroups = computerRecord?.extensionAttributes.first(where: {$0.definitionId == "523" }) {
                    Text(adGroups.values.first ?? "")
                    .emphasized()
                } else {
                    Text("")
                }
            }
            Button("Close") {
                showInfo.toggle()
            }
        }
        .padding(.bottom, 10)

    }
        
    
}    

