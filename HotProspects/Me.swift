//
//  Me.swift
//  HotProspects
//
//  Created by Floriano Fraccastoro on 22/02/23.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct UserData: Codable {
    var name: String = "Unknown"
    var emailAddress: String = "unknown@yoursite.com"
    var qrCodeData: Data = Data()
    
    mutating func setQRCodeImage(_ image: UIImage) {
        qrCodeData = image.jpegData(compressionQuality: 1.0) ?? Data()
    }
}

class UserClass: ObservableObject{
    @Published var userData = UserData()
    
    private let filePath = "UserData.json"
    
    init(){
        do {
            let fileURL = FileManager.documentsDirectory.appendingPathComponent(filePath)
            let jsonData = try Data(contentsOf: fileURL)
            let decodedData = try JSONDecoder().decode(UserData.self, from: jsonData)
            userData.name = decodedData.name
            userData.emailAddress = decodedData.emailAddress
            if let qrCodeImage = UIImage(data: decodedData.qrCodeData) {
                userData.setQRCodeImage(qrCodeImage)
            }
        } catch {
            print("Error loading user data:", error.localizedDescription)
        }
    }
    
    private func save(){
        do {
            let jsonData = try JSONEncoder().encode(userData)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsDirectory.appendingPathComponent(filePath)
            try jsonData.write(to: fileURL)
        } catch {
            print("Error saving user data:", error.localizedDescription)
        }
    }
    
    func saveUserData(name: String, emailAddress: String, qrCode: UIImage) {
        userData.name = name
        userData.emailAddress = emailAddress
        userData.setQRCodeImage(qrCode)
        save()
    }
}
