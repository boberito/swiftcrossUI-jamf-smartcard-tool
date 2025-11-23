//
//  JamfClass.swift
//  SCEU
//
//  Created by Gendler, Bob (Fed) on 11/17/25.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import SwiftCrossUI

@MainActor
class JamfClass: SwiftCrossUI.ObservableObject {
    @SwiftCrossUI.Published var jamfSearchResults: [ComputerResult] = []
    @SwiftCrossUI.Published var jamfResponseCode = 0
    var server = ""
    var id = ""
    var id2 = ""
    var username: String = ""
    var password: String = ""
    var token: String?
    var expires: Date?
    var jamfData = Data()
    
    private func testAuth() -> Bool {
        let now = Date()
        if let expiration = self.expires {
            if now > expiration {
                return false
            }
            return true
        } else {
            return false
        }
        
        
    }

    func getData(apiURL: String) async {
        let fullURL = self.server + apiURL        
        guard let fullURLurl = URL(string: fullURL) else { return }
        var request = URLRequest(url: fullURLurl)
        if let token = self.token {
            request.setValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "GET"
        
        if testAuth() {
            
            if let (data, response) = try? await URLSession.shared.data(for: request) {
                        if let decodedJamf = try? JSONDecoder().decode(JamfSearchInfo.self, from: data) {
                            self.jamfSearchResults = decodedJamf.results
                            self.jamfResponseCode = (response as! HTTPURLResponse).statusCode
                            
                        }
                
            }
            
        } else {
            
            let (tokeny, tokendatey) = await authenticate()
                self.token = tokeny
                self.expires = tokendatey
                
                if let token = self.token {
                    request.setValue("Bearer \(String(describing: token))", forHTTPHeaderField: "Authorization")
                }
                
                
                if let (data, response) = try? await URLSession.shared.data(for: request) {
                    // dump(String(data: data, encoding: .utf8) ?? "")
                    if let decodedJamf = try? JSONDecoder().decode(JamfSearchInfo.self, from: data) {
                                
                                self.jamfSearchResults = decodedJamf.results
                                self.jamfResponseCode = (response as! HTTPURLResponse).statusCode
                                
                                
                            }
                }
                
        }
        
    }
    func putData(apiURL: String, xmlData: String) async {
        let fullURL = self.server + apiURL
        guard let fullURLurl = URL(string: fullURL) else { return }
        var request = URLRequest(url: fullURLurl)
        
        if let token = self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.httpBody = xmlData.data(using: .utf8)
        request.httpMethod = "PUT"
        
        func executeRequest() async {
            if let (_, urlResponse) = try? await URLSession.shared.data(for: request) {
                if let returnResponse = urlResponse as? HTTPURLResponse {
                    self.jamfResponseCode = returnResponse.statusCode
                } else {
                    self.jamfResponseCode = 666
                }
            }

        }
        
    
        if testAuth() {
            let (tokeny, expiry) = await authenticate() 
                token = tokeny
                expires = expiry
            
        } else {
            let (tokeny, expirey) = await authenticate()
                self.token = tokeny
                self.expires = expirey

                if let token = self.token {
                    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }

                await executeRequest()

        }
    }

    private func authenticate() async -> (String?, Date?) {
        
        let concatCreds = self.username + ":" + self.password
        if let utf8Creds = concatCreds.data(using: .utf8) {
            let base64Creds = utf8Creds.base64EncodedString()
            
            var request = URLRequest(url: URL(string: "api/v1/auth/token", relativeTo: URL(string: self.server))!)
            request.setValue("Basic \(base64Creds)", forHTTPHeaderField: "Authorization")
            request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpMethod = "POST"
   
            if let (returnData, response) = try? await URLSession.shared.data(for: request) {

            if let returnResponse = response as? HTTPURLResponse {
                jamfResponseCode = (returnResponse).statusCode
            } else {
                jamfResponseCode = 666
            }
            
            
            let returnData = returnData 
                let decoder = JSONDecoder()
                do {
                    let authToken = try decoder.decode(jamfauth.self, from: returnData)
                    
                    // token = authToken.token
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    if let authTokenExpires = authToken.expires {
                        guard let tokenDatey = dateFormatter.date(from:authTokenExpires) else { return (nil, nil ) }
                        return (authToken.token, tokenDatey)
                    }
                } catch {
                 
                    return (nil, nil)
                }          
        return (nil, nil)
        }
        
    }
        return(nil, nil)
    }

}
