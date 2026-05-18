//
//  SettingsTest.swift
//  HabitsTests
//
//  Created by Christian Ost on 13.05.26.
//

import Testing
import Foundation

struct DataImportExportServiceTests {
    @Suite("tests importing of backup files")
    struct DataImportTests {
        var calendar: Calendar {
            var cal = Calendar(identifier: .gregorian)
            cal.timeZone = TimeZone(identifier: "Europe/London")! // TODO: add tests for different time zones
            
            return cal
        }
        
        var service: DataImportExportService {
            DataImportExportService(appVersion: "1.2.3", calendar: calendar)
        }

        @Test("imports backup file with entries containing a date property") func importsBackupFileWithEntriesWithDate() throws {
            let backupJson = """
                {
                    "appVersion": "1.2.3",
                    "exportDate": "2026-04-21T23:00:00Z",
                    "habits": [
                        {
                            "id": "E1A185CD-06BA-4C4B-9B2C-E4C33AE42F3B",
                            "name": "Test",
                            "createdAt": "2026-02-25T23:00:00Z",
                            "colour": "green",
                            "order": 0,
                            "entries": [
                                { "date": "2026-02-26T07:49:29Z" },
                                { "date": "2026-03-21T23:00:00Z" }
                            ],
                        }
                    ]
                }
                """

            let items = try service.importHabitsFromJsonFile(from: Data(backupJson.utf8))
            
            #expect(items.count == 1)
            
            #expect(items.first?.entries.count == 2)
            #expect(items.first?.id.uuidString == "E1A185CD-06BA-4C4B-9B2C-E4C33AE42F3B")
            #expect(items.first?.entries[0].day == "2026-02-26")
            #expect(items.first?.entries[1].day == "2026-03-22")
        }

        @Test("imports backup file with entries containing a day property") func importsBackupFileWithEntriesWithDay() throws {
            // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        }

        @Test("fails gracefully when importing a backup file where entries have neither a day nor date property") func failsForImportOfBackupFileWithEntriesWithNeitherDateOrDay() throws {
            // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        }
    }
    
    @Suite("tests exporting of Habits")
    struct DataExportTests {
        
    }
}
