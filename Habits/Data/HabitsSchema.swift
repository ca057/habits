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

    // Populate day from date. Entries were stored at local midnight, so the correct timezone
    // is whichever candidate has hour == 0 for the stored timestamp.
    static let migrateV110toV120 = MigrationStage.custom(
        fromVersion: HabitsSchemaV110.self,
        toVersion: HabitsSchemaV120.self,
        willMigrate: nil,
        didMigrate: { context in
            let candidates = [TimeZone.current, TimeZone(identifier: "Europe/Berlin")!]

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            let entries = try context.fetch(FetchDescriptor<HabitsSchemaV120.Entry>())
            for entry in entries where entry.day == nil {
                var bestTZ = TimeZone.current
                var minHour = 24
                for tz in candidates {
                    var cal = Calendar(identifier: .gregorian)
                    cal.timeZone = tz
                    let hour = cal.component(.hour, from: entry.date)
                    if hour < minHour {
                        minHour = hour
                        bestTZ = tz
                    }
                }
                formatter.timeZone = bestTZ
                entry.day = formatter.string(from: entry.date)
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
