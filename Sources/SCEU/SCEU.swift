// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftCrossUI
import Foundation

#if os(Linux)
    import GtkBackend
#else
    import DefaultBackend
#endif

@main
struct SCEU: App {
    @State var resizable = true    
    @State var selectedComputer: String? = nil
    @State var smartcardStatus: String? = nil
    @State var computerUserInfo: UserAndLocation?
    @State var showPrefs: Bool = false
    @State var showInfo: Bool = false
    @State var searchText: String = ""
    @State var loginInfo = JamfLoginInfo()
    
    @State var jamfResults: [ComputerResult] = []
    @State var eaID1 = String()
    @State var eaID2 = String()
    @State var showPassField: Bool = false

    @State var computerRecord: ComputerResult?

    let jamf = JamfClass()

    var body: some Scene {
        WindowGroup("Smartcard Enforcement Utility") {
            ZStack(alignment: .bottomTrailing) {
                HStack {
                    VStack {
                        TopLeft(showInfo: showInfo, showPrefs: showPrefs, showPassField: $showPassField, jamfLogin: $loginInfo, searchText: $searchText)                        
                        ComputerTable(selectedComputer: $selectedComputer, smartcardStatus: $smartcardStatus, computerUserInfo: $computerUserInfo, data: $jamfResults, ea_ID1: eaID1)
                        .onChange(of: selectedComputer) {
                            guard let selectedComputer = selectedComputer else { return }
                            computerRecord = jamfResults.first(where: { $0.id == selectedComputer })
                        }
                    }
                    
                    VStack(spacing: 8) {
                        AppButtons(selectedComputer: $selectedComputer, smartcardStatus: $smartcardStatus, showPrefs: $showPrefs, showInfo: $showInfo, jamfLogin: $loginInfo, searchText: $searchText, jamfResults: $jamfResults, EA1_ID: $eaID1, EA_ID2: $eaID2, jamfActions: jamf)
                        .onChange(of: jamfResults){
                            computerRecord = nil
                        }
                        Divider()
                        UserInfo(computerRecord: computerRecord)
                    }

                    
                    
                }
                if showInfo {
                    ZStack {
                                Color(0.5, 0.5, 0.5, 0.5)
                                InfoView(showInfo: $showInfo, computerRecord: computerRecord, eaID1: eaID1, eaID2: eaID2)
                                    .frame(maxWidth: 500)                                    
                                    .cornerRadius(8)
                                    .padding()
                                    .background(Color.white)
                           
                            }
                }

               if showPrefs {
                            ZStack {
                                Color(0.5, 0.5, 0.5, 0.5)
                                PrefView(showPrefs: $showPrefs)
                                    .frame(maxWidth: 500)                                    
                                    .cornerRadius(8)
                                    .padding()
                                    .background(Color.white)
                           
                            }
                        } 
                if showPassField {
                        ZStack {
                            Color(0.5, 0.5, 0.5, 0.5)
                            PasswordField(jamfLogin: $loginInfo ,showPassField: $showPassField)
                                .frame(maxWidth: 150)                                    
                                .cornerRadius(8)
                                .padding()
                                .background(Color.white)
                        }
                }
            }
        }
        .defaultSize(width: 650, height: 350)
        .windowResizability(.contentSize)
    }
}
