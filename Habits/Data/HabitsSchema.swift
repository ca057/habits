//
//  HabitsSchema.swift
//
//  Created by Christian Ost on 21.07.25.
//

import Foundation
import SwiftData

enum HabitsSchemaV110: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(1, 1, 0) }

    static var models: [any PersistentModel.Type] {
        [self.Habit.self, self.Entry.self]
    }
}

enum HabitsSchemaV120: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(1, 2, 0) }

    static var models: [any PersistentModel.Type] {
        [self.Habit.self, self.Entry.self]
    }
}

enum HabitsSchemaV130: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(1, 3, 0) }

    static var models: [any PersistentModel.Type] {
        [self.Habit.self, self.Entry.self]
    }
}

enum HabitsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [HabitsSchemaV110.self, HabitsSchemaV120.self, HabitsSchemaV130.self]
    }
    static var stages: [MigrationStage] { [migrateV110toV120, migrateV120toV130] }
    
    static func migrateDateToDay(from date: Date) -> String {
        // entries were stored at local midnight, so the correct timezone can be determined whichever
        // has 0 for the hour; candidates are based on my own usage
        // TODO: this needs testing
        let timeZoneCandidates = [TimeZone.current, TimeZone(identifier: "Europe/Berlin")!]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        var bestTimeZone = TimeZone.current
        var minHour = 24
        
        for timeZone in timeZoneCandidates {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = timeZone

            let hour = calendar.component(.hour, from: date)
            if hour < minHour {
                minHour = hour
                bestTimeZone = timeZone
            }
        }
        formatter.timeZone = bestTimeZone
        
        return formatter.string(from: date)
    }

    static let migrateV110toV120 = MigrationStage.custom(
        fromVersion: HabitsSchemaV110.self,
        toVersion: HabitsSchemaV120.self,
        willMigrate: nil,
        didMigrate: { context in
            let entries = try context.fetch(FetchDescriptor<HabitsSchemaV120.Entry>())
            
            for entry in entries where entry.day == nil {
                entry.day = migrateDateToDay(from: entry.date)
            }
            
            try context.save()
        }
    )

    // Drop the date column — day is already populated by the V120 migration
    static let migrateV120toV130 = MigrationStage.lightweight(
        fromVersion: HabitsSchemaV120.self,
        toVersion: HabitsSchemaV130.self
    )
}
