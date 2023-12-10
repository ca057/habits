//
//  DataExport.swift
//  Habits
//
//  Created by Christian Ost on 07.12.23.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct DataExport {
    enum HabitsStorageError: Error {
        case exportFailed
        case importFailed
    }
    
    struct HabitsExportItemEntry: Codable {
        let date: Date
        
        // TODO: create from & to methods
    }
    
    struct HabitsExportItem: Codable {
        let id: UUID
        let name: String
        let createdAt: Date
        let colour: String
        let entries: [HabitsExportItemEntry]
        
        // TODO: create from & to methods
    }
    
    struct HabitsExport: Codable {
        let appVersion: String
        let exportDate: Date
        let habits: [HabitsExportItem]
    }
    
    struct JSONFile: FileDocument {
        static var readableContentTypes = [UTType.json]
        static var writableContentTypes = [UTType.json]
        
        var data = Data()
        
        init(_ json: Data) {
            data = json
        }
        
        init(configuration: ReadConfiguration) throws {
            if let content = configuration.file.regularFileContents {
                data = content
            }
        }
        
        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            let fileWrapper = FileWrapper(regularFileWithContents: data)
            fileWrapper.filename = "habits-export-\(Date().toString(format: .isoDateTime) ?? "?")"
            
            return fileWrapper
        }
    }
}
