//
//  PrefView.swift
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


struct PrefView: View {    

    @Binding var showPrefs: Bool
    @State private var preferences: Preferences

     init(showPrefs: Binding<Bool>) {
        self._showPrefs = showPrefs
        _preferences = State(wrappedValue: Preferences.readPreferences())
    }
    
    var body: some View {            
        VStack{
            HStack{
                Text("Jamf Server URL: ")
                TextField("", text: $preferences.Server)
                .frame(maxWidth: 200, maxHeight: 30)                
            }
            HStack{
                Text("Smartcard EA ID: ")
                TextField("", text: $preferences.ID1)     
                .frame(maxWidth: 200, maxHeight: 30)           
            }
            HStack{
                Text("Date EA ID: ")
                TextField("", text: $preferences.ID2)
                .frame(maxWidth: 200, maxHeight: 30)   
                .padding(.leading, 32)             
            }

            HStack {
                Button("Save") {
                    let server: String = preferences.Server 
                    let ea1: String = preferences.ID1
                    let ea2: String = preferences.ID2

                    #if os(Linux)
                    do { 
                        try preferences.writeLinuxPrefs(server: server, ea1: ea1, ea2: ea2)
                    } catch {
                        showPrefs.toggle()
                    }
                    #else 
                    do {
                        try preferences.writePreferences(key: "jss_URL", value: server)
                        try preferences.writePreferences(key: "EA_ID", value: ea1)
                        try preferences.writePreferences(key: "EA2_ID", value: ea2)
                        showPrefs.toggle()
                    } catch {
                        showPrefs.toggle()
                    }
                    #endif
                }
                Button("Cancel") {
                    showPrefs.toggle()
                }
            }
            .padding(.bottom, 10)
            .padding(.top, 10)

        }
        
       
    }    
}
