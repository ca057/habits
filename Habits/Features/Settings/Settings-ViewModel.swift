//
//  Settings-ViewModel.swift
//  Habits
//
//  Created by Christian Ost on 30.03.23.
//

import Foundation

struct HabitsExportItemEntry: Codable {
    let date: Date
}

struct HabitsExportItem: Codable {
    let id: UUID?
    let name: String?
    let createdAt: Date?
    let colour: String?
    let entries: [HabitsExportItemEntry]
}

struct HabitsExport: Codable {
    let appVersion: String
    let exportDate: Date
    let habits: [HabitsExportItem]
}

extension Settings {
    @MainActor final class ViewModel: ObservableObject {
        @Published var showingExporter = false
        
        private let habitsStorage = HabitsStorage.shared

        func getDataAsJson() -> String {
            // TODO: do I need to make this async? for sure with a cool animation
            
            var habits: [HabitsExportItem] = []
            habitsStorage.habits.forEach({ habit in
                var entries: [HabitsExportItemEntry] = []
                habit.entry?.array.forEach({
                    guard let entryDate = ($0 as? Entry)?.date else { return }
                    
                    entries.append(HabitsExportItemEntry(date: entryDate))
                })
                                
                habits.append(HabitsExportItem(
                    id: habit.id,
                    name: habit.name,
                    createdAt: habit.createdAt,
                    colour: habit.colour,
                    entries: entries
                ))
            })
            
            let export = HabitsExport(
                appVersion: Bundle.main.versionAndBuildNumber,
                exportDate: Date(),
                habits: habits
            )
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            jsonEncoder.outputFormatting = .prettyPrinted
            
            do {
                let habitsAsJson = try jsonEncoder.encode(export)

                return String(data: habitsAsJson, encoding: .utf8) ?? "export failed: N/A"
            } catch {
                print("something failed \(error)")
                
                return "export failed: \(error.localizedDescription)"
            }
        }
    }
}
