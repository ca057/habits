//
//  SettingsView.swift
//  habits
//
//  Created by Christian Ost on 18.02.22.
//

import CoreData
import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) var dismissView
    
    private var showDebugSettings: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Display Settings") {
                    Text("Sort by")
                }
                
                if showDebugSettings {
                    Section("Developer Settings") {
                        Button("Delete all data", role: .destructive) {
                            deleteAllData()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Close") {
                    dismissView()
                }
            }
        }
    }
    
    func deleteAllData() {
        print("⚠️ deleting all data")

        let habitsFetchReq = NSFetchRequest<Habit>(entityName: "Habit")
        do {
            let fetchedHabits = try moc.fetch(habitsFetchReq)
            if fetchedHabits.isEmpty {
                print("nothing to delete...")
                return
            }

            for habit in fetchedHabits {
                moc.delete(habit)
            }
            
            if moc.hasChanges {
                try moc.save()
            }
        } catch {
            print("error deleting all data: \(error.localizedDescription)")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
