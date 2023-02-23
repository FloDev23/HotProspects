//
//  MeView.swift
//  HotProspects
//
//  Created by Floriano Fraccastoro on 20/02/23.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MeView: View {
    @State private var name = "Unknown"
    @State private var emailAddress = "unknown@yoursite.com"
    @State private var qrCode = UIImage()
    @State private var isShowingTextField = true
    
    @StateObject var userData = UserClass()
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        NavigationView{
            Form{
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .font(.title)
                    .foregroundColor(isShowingTextField ? .secondary : .primary)
                    .disabled(isShowingTextField)
                TextField("Email address", text: $emailAddress)
                    .textContentType(.emailAddress)
                    .font(.title)
                    .foregroundColor(isShowingTextField ? .secondary : .primary)
                    .disabled(isShowingTextField)
                HStack{
                    Spacer()
                    
                    Image(uiImage: qrCode)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding()
                        .contextMenu{
                            Button{
                                let imageSaver = ImageSaver()
                                imageSaver.writeToPhotoAlbum(image: qrCode)
                            } label: {
                                Label("Save to Photos", systemImage: "square.and.arrow.down")
                            }
                        }
                    Spacer()
                }
            }
            .navigationTitle("Your code")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button{
                        isShowingTextField.toggle()
                    } label: {
                        Text(isShowingTextField ? "Modify" : "Done")
                    }
                }
            }
            .onChange(of: name) { _ in updateCode() }
            .onChange(of: emailAddress) { _ in updateCode() }
        }
        .onDisappear {
            userData.saveUserData(name: name, emailAddress: emailAddress, qrCode: qrCode)
        }
        .onAppear{
            name = userData.userData.name
            emailAddress = userData.userData.emailAddress
            qrCode = UIImage(data: userData.userData.qrCodeData) ?? UIImage()
            updateCode()
        }
    }
    
    func generateQRCode(from string: String) -> UIImage{
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage{
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    func updateCode() {
        qrCode = generateQRCode(from: "\(name)\n\(emailAddress)")
    }
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
