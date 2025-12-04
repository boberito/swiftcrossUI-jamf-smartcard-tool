import SwiftCrossUI
import Foundation

#if os(Linux)
    import GtkBackend
#else
    import DefaultBackend
#endif

struct TopLeft: View {
    
    @State private var search: String = ""
    
    var showInfo: Bool
    var showPrefs: Bool
    @Binding var showPassField: Bool
    @Binding var jamfLogin: JamfLoginInfo

    @Binding var searchText: String
    var body: some View {
        HStack {
            VStack{
                Image(Bundle.SCEU.bundleURL.appendingPathComponent("logo.png"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 205, height: 75, alignment: .topLeading)
                    .padding(.bottom, -20)
                HStack{
                    Text("Jamf Pro Username:")
                    TextField("", text: self.$jamfLogin.username)
                        .frame(maxWidth: 110, maxHeight: 30)
                        .disabled(showInfo || showPrefs || showPassField)
                }
                HStack {
                    Button("Jamf Pro Password") {
                        showPassField.toggle()
                    }

                }
                HStack {
                    Text("Search: ")
                    TextField("", text: self.$searchText)
                        .frame(maxWidth: 105, maxHeight: 30)
                        .padding(.leading, 12)
                        .disabled(showInfo || showPrefs || showPassField)
                }
            }
        }
        .padding(.top, 10)
        
        
    }
}

extension Bundle {
    static var SCEU: Bundle {
        let bundleURL: URL
    #if os(macOS)
        bundleURL = Bundle.main.bundleURL.appendingPathComponent(
            "Contents/Resources"
        )
    #elseif os(Linux) || os(Windows)
        bundleURL = Bundle.main.bundleURL.appendingPathComponent(
            "SCEU_SCEU.bundle"
        )
    #endif
    return Bundle(url: bundleURL)!
    }
}
