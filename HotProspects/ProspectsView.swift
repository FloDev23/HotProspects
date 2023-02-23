//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Floriano Fraccastoro on 20/02/23.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    enum FilterType{
        case none, contacted, uncontacted
    }
    
    enum SortBy{
        case name, date
    }
    
    var filter: FilterType
    @State private var sortCriteria: SortBy = .name
    
    @EnvironmentObject var prospects: Prospects
    
    
    @State private var isShowingScanner = false
    @State private var isShowingSort = false
    @State private var isShowingNotification = false
    
    var body: some View {
        NavigationView{
            List{
                ForEach(filteredProspects.sorted(by: sortFunction)){ prospect in
                    HStack{
                        HStack{
                            VStack(alignment: .leading){
                                Text(prospect.name)
                                    .font(.headline)
                                Text(prospect.emailAddress)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if filter == .none && prospect.isContacted{
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                        }
                    }
                    .swipeActions{
                        Button{
                            addNotification(for: prospect)
                        } label: {
                            Label("Remind me", systemImage: "bell")
                        }
                        .tint(.orange)
                    }
                }
            }
            .navigationTitle(title)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button{
                        isShowingScanner = true
                    }label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading){
                    Button{
                        isShowingSort = true
                    }label: {
                        Label("Sort", systemImage: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner){
                CodeScannerView(codeTypes: [.qr], completion: handleScan)
            }
            .confirmationDialog("Sort", isPresented: $isShowingSort){
                Button("Name") { sortCriteria = .name }
                Button("Date") { sortCriteria = .date }
                Button("Cancel", role: .cancel) { }
            }
            .alert("Unauthorized Notifications", isPresented: $isShowingNotification){
                Button("Ok") {}
            } message: {
                Text("Go to setting and authorize notifications")
            }
        }
    }
    
    var title: String{
        switch filter{
        case .none:
            return "Everyone"
        case.contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var listProspects: [Prospect]{
        switch filter{
        case .none:
            return prospects.people
        default:
            return prospects.people
        }
    }
    
    var filteredProspects: [Prospect]{
        switch filter{
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }
    
    private func sortFunction(_ p1: Prospect, _ p2: Prospect) -> Bool{
        switch sortCriteria{
        case .name:
            return p1.name < p2.name
        case .date:
            return p1.date < p2.date
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>){
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            
            prospects.add(person)
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact: \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        isShowingNotification = true
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
