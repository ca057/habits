//
//  DataImportExportService+Live.swift
//  Habits
//
//  Created by Christian Ost on 18.05.26.
//

import Foundation

extension DataImportExporter where Self == DataImportExportService {
    static var live: DataImportExportService {
        DataImportExportService(appVersion: Bundle.main.versionAndBuildNumber, calendar: Calendar.current)
    }
}
