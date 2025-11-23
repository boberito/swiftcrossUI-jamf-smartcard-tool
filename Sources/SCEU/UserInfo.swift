//
//  TopLeft.swift
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

#if canImport(SwiftBundlerRuntime)
    import SwiftBundlerRuntime
#endif


struct UserInfo: View {
    
    @State var text: String = ""
    let computerRecord: ComputerResult?
    
    var body: some View {
        VStack(spacing: 8) {
            Text("User Information")            
            TextEditor(text: $text)
                // .frame(minWidth: 200, maxWidth: 200, minHeight: 190, maxHeight: 190)
                .frame(width: 195, height: 190)
                .disabled(true)
                .padding(4)                    
                .background(Color.gray.opacity(0.3))
        }
        .padding(.bottom, 10)
        .padding(.trailing, 5)
         .onChange(of: computerRecord) {            
            guard let computerRecord = computerRecord else 
            { 
                text = "" 
                return 
            }
            text = """
            Computer: \(computerRecord.general.name)
            Real Name: \(computerRecord.userAndLocation.realname ?? "")            
            UserName: \(computerRecord.userAndLocation.username ?? "")
            Email: \(computerRecord.userAndLocation.email ?? "")
            Property Tag: \(computerRecord.general.assetTag ?? "")
            Last CheckIn: \(computerRecord.general.lastContactTime ?? "")
            Processor: \(computerRecord.hardware?.processorType ?? "")
            """
        }
        
    }
    
}
