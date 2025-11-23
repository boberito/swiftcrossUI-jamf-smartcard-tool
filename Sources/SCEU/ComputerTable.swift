//
//  ComputerTable.swift
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


struct ComputerTable: View {
    @Binding var selectedComputer: String?
    @Binding var smartcardStatus: String?
    @Binding var computerUserInfo: UserAndLocation?
    @Binding var data: [ComputerResult]

    var ea_ID1 = String()    
    
    var body: some View {
        VStack{
            HStack {
                        Text("Computer")
                        .font(.title3)
                        .emphasized()
                        .frame(width: 100, height: 25, alignment: .leading)
                        Divider()
                        Text("Status")
                        .font(.title3)
                        .emphasized()
                        .frame(width: 80, height: 25, alignment: .trailing)
                        .padding(.trailing, 10)
                    }
                    .frame(height: 25, alignment: .top)
                    .padding(.leading, 15)
                    .padding(.trailing, 10)
            Divider()
            ScrollView{
            ForEach(data) { item in                        
                let ea = item.extensionAttributes.first(where: { $0.definitionId == ea_ID1 })
                VStack {                
                    HStack{
                    Text(item.general.name)
                    .frame(width: 100, alignment: .leading)
                    .background(selectedComputer == item.id ? Color.blue.opacity(0.3) : Color.clear)
                    .onTapGesture {
                        selectedComputer = item.id
                        smartcardStatus = ea?.values.first ?? ""
                        computerUserInfo = item.userAndLocation
                    }
                    Divider()
                    Text(ea?.values.first ?? "")
                    .frame(width: 75, alignment: .trailing)
                    .padding(.trailing, 5)
                    
                    
                    }.background(selectedComputer == item.id ? Color.blue.opacity(0.3) : Color.clear)
                    .onTapGesture {
                        selectedComputer = item.id
                        smartcardStatus = ea?.values.first ?? ""        
                        computerUserInfo = item.userAndLocation
                    }
                } 
                .frame(alignment: .top)
                .padding(.bottom, 5)
            }
            // }.frame(Width: 205, Height: 205, alignment: .top)
            }.frame(width: 205, height: 205, alignment: .top)
         
        }
        .frame(alignment: .top)
        .padding(.bottom, 5)
    }
    
}

