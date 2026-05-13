//
//  SettingsTest.swift
//  HabitsTests
//
//  Created by Christian Ost on 13.05.26.
//

import Testing

struct SettingsTest {
    @Suite("tests importing of backup files")
    struct BackupImportTests {
        @Test("imports backup file with entries containing a date property") func importsBackupFileWithEntriesWithDate() async throws {
            // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        }

        @Test("imports backup file with entries containing a day property") func importsBackupFileWithEntriesWithDay() async throws {
            // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        }

        @Test("fails gracefully when importing a backup file where entries have neither a day nor date property") func failsForImportOfBackupFileWithEntriesWithNeitherDateOrDay() async throws {
            // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        }
    }
}
