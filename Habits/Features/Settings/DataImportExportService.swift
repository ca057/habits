//
//  DataImportExportService.swift
//  Habits
//
//  Created by Christian Ost on 15.05.26.
//

import Foundation
import os

private extension Logger {
    static let dataImportExport = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "settings.dataImportExport")
}

protocol DataImportExporter {
      func exportHabitsToJsonFile(with habits: [DataExport.HabitsExportItem]) throws -> DataExport.JSONFile
      func importHabitsFromJsonFile(from data: Data) throws -> [DataExport.HabitsExportItem]
}

struct DataImportExportService: DataImportExporter {
    var appVersion: String
    var calendar: Calendar

    func exportHabitsToJsonFile(with habits: [DataExport.HabitsExportItem]) throws -> DataExport.JSONFile {
        Logger.dataImportExport.debug("starting export for \(habits.count) habits")
        
        let export = DataExport.HabitsExport(
            appVersion: appVersion,
            // TODO: consider model version?
            exportDate: Date(),
            habits: habits
        )

        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        jsonEncoder.outputFormatting = .prettyPrinted
        
        return DataExport.JSONFile(try jsonEncoder.encode(export))
    }
    
    func importHabitsFromJsonFile(from data: Data) throws -> [DataExport.HabitsExportItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedData = try decoder.decode(DataExport.HabitsImport.self, from: data)
        
        // TODO: do some sanity checks on the version
        
        return decodedData.habits.map { habit in
            DataExport.HabitsExportItem(
                id: habit.id,
                name: habit.name,
                createdAt: habit.createdAt,
                colour: habit.colour,
                order: habit.order,
                entries: habit.entries.compactMap { entry in
                    if let day = entry.day {
                        return DataExport.HabitsExportItemEntry(day: day)
                    } else if let date = entry.date {
                        return DataExport.HabitsExportItemEntry(day: HabitsMigrationPlan.migrateDateToDay(from: date, with: calendar))
                    } else {
                        // TODO: pass the feedback one level up
                        Logger.dataImportExport.warning("entry is missing both date and day and cannot be imported")
                        return nil
                    }
                }
            )
        }
    }
}
