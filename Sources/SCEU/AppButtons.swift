//
//  AppButton.swift
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


struct AppButtons: View {
    @Environment(\.presentAlert) var presentAlert

    @State private var twentyFourHours = true
    @State private var disabledToggle: Bool = true
    @State private var toggleButtonText: String = "Disable"    
    @State private var preferences: Preferences
    
    @Binding var selectedComputer: String?
    @Binding var smartcardStatus: String?
    @Binding var showPrefs: Bool
    @Binding var showInfo: Bool
    @Binding var jamfLogin: JamfLoginInfo
    @Binding var searchText: String
    @Binding var jamfResults: [ComputerResult]
    @Binding var EA1_ID: String
    @Binding var EA_ID2: String

    let jamfActions: JamfClass


    init(selectedComputer: Binding<String?>, smartcardStatus: Binding<String?>, showPrefs: Binding<Bool>, showInfo: Binding<Bool>, jamfLogin: Binding<JamfLoginInfo>, searchText: Binding<String>, jamfResults: Binding<[ComputerResult]>, EA1_ID: Binding<String>, EA_ID2: Binding<String>, jamfActions: JamfClass) {
        self._selectedComputer = selectedComputer
        self._smartcardStatus = smartcardStatus
        self._showPrefs = showPrefs
        self._showInfo = showInfo
        self._jamfLogin = jamfLogin
        self._searchText = searchText
        self._jamfResults = jamfResults
        self._EA1_ID = EA1_ID
        self._EA_ID2 = EA_ID2
        self.jamfActions = jamfActions
        _preferences = State(wrappedValue: Preferences.readPreferences())
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
        VStack {

            Button("Look Up")
            {
                jamfActions.id = preferences.ID1
                jamfActions.id2 = preferences.ID2
                jamfActions.server = preferences.Server
                jamfActions.username = jamfLogin.username
                jamfActions.password = jamfLogin.password
                EA1_ID = preferences.ID1
                EA_ID2 = preferences.ID2
                searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                Task {
                    await jamfActions.getData(apiURL: "api/v2/computers-inventory?section=GENERAL&section=OPERATING_SYSTEM&section=HARDWARE&section=CONFIGURATION_PROFILES&section=USER_AND_LOCATION&section=EXTENSION_ATTRIBUTES&filter=userAndLocation.username==*\(searchText)*,userAndLocation.realname==*\(searchText)*,general.assetTag==*\(searchText)*,general.name==*\(searchText)*,hardware.serialNumber==*\(searchText)*")         
                    // print(jamfActions.jamfSearchResults)
                    switch jamfActions.jamfResponseCode {
                        case 200, 201:
                            jamfResults = jamfActions.jamfSearchResults                    
                        case 401:
                            await presentAlert("Incorrect Login Information")
                        default:
                            print("Not so sure")
                    }
                    
                }
                
            }   
            .frame(maxWidth: 85)                
            Button(toggleButtonText)
            {
                jamfActions.id = preferences.ID1
                jamfActions.id2 = preferences.ID2
                jamfActions.server = preferences.Server
                jamfActions.username = jamfLogin.username
                jamfActions.password = jamfLogin.password

                switch smartcardStatus?.lowercased() {
                case nil:
                    searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    let xmldata = "<computer><extension_attributes><extension_attribute><id>" + preferences.ID1 + "</id><value>Enabled</value></extension_attribute><extension_attribute><id>\(preferences.ID2)</id><value></value></extension_attribute></extension_attributes></computer>"
                    Task {
                        guard let selectedComputer = selectedComputer else { return }
                        await jamfActions.putData(apiURL: "JSSResource/computers/id/\(selectedComputer)", xmlData: xmldata)

                        switch jamfActions.jamfResponseCode {
                            case 200, 201:
                                await jamfActions.getData(apiURL: "api/v2/computers-inventory?section=GENERAL&section=OPERATING_SYSTEM&section=HARDWARE&section=CONFIGURATION_PROFILES&section=USER_AND_LOCATION&section=EXTENSION_ATTRIBUTES&filter=userAndLocation.username==*\(searchText)*,userAndLocation.realname==*\(searchText)*,general.assetTag==*\(searchText)*,general.name==*\(searchText)*,hardware.serialNumber==*\(searchText)*")

                                jamfResults = jamfActions.jamfSearchResults
                                toggleButtonText = "Disable"
                            case 401:
                                await presentAlert("Incorrect Login Information")
                            default:
                                print("I AM A FAILURE AT PUTTING")
                        }

                    }
                case "enabled":            
                    let daysToAdd = 1
                        let currentDate = Date()
                        var dateComponent = DateComponents()
                        dateComponent.day = daysToAdd
                        let futureDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat =  "MM-dd-YY"
                        var date = dateFormatter.string(from: futureDate!)
                        
                        if !twentyFourHours {
                            date = ""
                        }
                        
                        searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                        let xmldata = "<computer><extension_attributes><extension_attribute><id>" + preferences.ID1 + "</id><value>Disabled</value></extension_attribute><extension_attribute><id>\(preferences.ID2)</id><value>\(date)</value></extension_attribute></extension_attributes></computer>"
                        Task {
                            guard let selectedComputer = selectedComputer else { return }
                            await jamfActions.putData(apiURL: "JSSResource/computers/id/\(selectedComputer)", xmlData: xmldata)

                            switch jamfActions.jamfResponseCode {
                                case 200, 201:
                                    await jamfActions.getData(apiURL: "api/v2/computers-inventory?section=GENERAL&section=OPERATING_SYSTEM&section=HARDWARE&section=CONFIGURATION_PROFILES&section=USER_AND_LOCATION&section=EXTENSION_ATTRIBUTES&filter=userAndLocation.username==*\(searchText)*,userAndLocation.realname==*\(searchText)*,general.assetTag==*\(searchText)*,general.name==*\(searchText)*,hardware.serialNumber==*\(searchText)*")

                                    jamfResults = jamfActions.jamfSearchResults
                                    toggleButtonText = "Enable"
                                case 401:
                                    await presentAlert("Incorrect Login Information")                                    
                                default:
                                    print("I AM A FAILURE AT PUTTING")
                            }

                        }
                case "disabled":
                    searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    let xmldata = "<computer><extension_attributes><extension_attribute><id>" + preferences.ID1 + "</id><value>Enabled</value></extension_attribute><extension_attribute><id>\(preferences.ID2)</id><value></value></extension_attribute></extension_attributes></computer>"
                    Task {
                        guard let selectedComputer = selectedComputer else { return }
                        await jamfActions.putData(apiURL: "JSSResource/computers/id/\(selectedComputer)", xmlData: xmldata)

                        switch jamfActions.jamfResponseCode {
                            case 200, 201:
                                await jamfActions.getData(apiURL: "api/v2/computers-inventory?section=GENERAL&section=OPERATING_SYSTEM&section=HARDWARE&section=USER_AND_LOCATION&section=EXTENSION_ATTRIBUTES&filter=userAndLocation.username==*\(searchText)*,userAndLocation.realname==*\(searchText)*,general.assetTag==*\(searchText)*,general.name==*\(searchText)*,hardware.serialNumber==*\(searchText)*")

                                jamfResults = jamfActions.jamfSearchResults
                                toggleButtonText = "Disable"
                            case 401:
                                await presentAlert("Incorrect Login Information")                                
                            default:
                                print("I AM A FAILURE AT PUTTING")
                        }

                    }
                default:
                    searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    let xmldata = "<computer><extension_attributes><extension_attribute><id>" + preferences.ID1 + "</id><value>Enabled</value></extension_attribute><extension_attribute><id>\(preferences.ID2)</id><value></value></extension_attribute></extension_attributes></computer>"
                    Task {
                        guard let selectedComputer = selectedComputer else { return }
                        await jamfActions.putData(apiURL: "JSSResource/computers/id/\(selectedComputer)", xmlData: xmldata)

                        switch jamfActions.jamfResponseCode {
                            case 200, 201:
                                await jamfActions.getData(apiURL: "api/v2/computers-inventory?section=GENERAL&section=OPERATING_SYSTEM&section=HARDWARE&section=USER_AND_LOCATION&section=EXTENSION_ATTRIBUTES&filter=userAndLocation.username==*\(searchText)*,userAndLocation.realname==*\(searchText)*,general.assetTag==*\(searchText)*,general.name==*\(searchText)*,hardware.serialNumber==*\(searchText)*")

                                jamfResults = jamfActions.jamfSearchResults
                                toggleButtonText = "Disable"
                            case 401:
                                await presentAlert("Incorrect Login Information")                                
                            default:
                                print("I AM A FAILURE AT PUTTING")
                        }

                    }
            }
            }
                .frame(maxWidth: 85)
                .disabled(disabledToggle)
            Button("Information")
            {
                showInfo.toggle()
            }
                .frame(maxWidth: 85)
                .disabled(disabledToggle)
            Button("Preferences")
            {
                showPrefs.toggle()
            }
                .frame(maxWidth: 85)
            // Toggle("Disable for only 24 Hours", active: $twentyFourHours)
            //     .disabled()
            //     .toggleStyle(.checkbox)
        }
        .padding(.top, 15)
        .onChange(of: selectedComputer) {
            if selectedComputer != nil {
                disabledToggle = false
            }

            switch smartcardStatus?.lowercased() {
                case nil:
                    toggleButtonText = "Enable"
                case "enabled":
                    toggleButtonText = "Disable"
                case "disabled":
                    toggleButtonText = "Enable"
                default:
                    toggleButtonText = "Disable"
            }
                
            

        }
    
    }
    }

    
    
    
}

