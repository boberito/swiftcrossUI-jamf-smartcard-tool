import SwiftCrossUI

struct PasswordField: View {
    @Binding var jamfLogin: JamfLoginInfo
    @Binding var showPassField: Bool

    @State private var passField: String = ""

    var body: some View {
        VStack {
            Text("Jamf Pro Password")
            if jamfLogin.password == "" {
                TextField("", text: $passField)    
                    .frame(maxWidth: 110, maxHeight: 30)
                    .padding(5)
            }  else {
                TextField("********", text: $passField)
                    .frame(maxWidth: 110, maxHeight: 30)
                    .padding(5)
            }   
            
            

            HStack {
                Button("Save") {
                    if passField != "" {
                        jamfLogin.password = passField
                    }
                    
                    showPassField = false
                }
                Button("Cancel") {                    
                    showPassField = false
                }
            }
        }
        .padding(.bottom, 10)
        // .onAppear {
        //     passField = jamfLogin.password
        // }
    }
}