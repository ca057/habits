//
//  HabitsSchema.swift
//  Habits
//
//  Created by Christian Ost on 21.07.25.
//

import SwiftData

enum HabitsSchemaV100: VersionedSchema {
    static var versionIdentifier: Schema.Version { .init(1, 0, 0) }
    
    static var models: [any PersistentModel.Type] {
        [self.Habit.self, self.Entry.self]
    }
}
