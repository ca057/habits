//
//  Settings.swift
//  Habits
//
//  Created by Christian Ost on 29.03.23.
//

import SwiftUI
import SwiftData
import Foundation

fileprivate struct ErrorAlert {
    var showing = false
    var title = ""
    var message = ""
}

struct Settings: View {
    @Environment(\.modelContext) private var modelContext

    @State private var errorMessage = ErrorAlert()
    @State private var showingExporter = false
    @State private var showingImporter = false

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Data") {
                        Button(action: { showingExporter = true }) {
                            Label {
                                Text("Backup data")
                            } icon: {
                                Image(systemName: "square.and.arrow.up")
                                    .symbolRenderingMode(.hierarchical)
                            }
                        }
                        Button(action: { showingImporter = true }) {
                            Label {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Import data")
                                    Text("Use with caution - data might be duplicated or overwritten.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            } icon: {
                                Image(systemName: "square.and.arrow.down")
                                    .symbolRenderingMode(.hierarchical)
                            }
                        }
                    }
                    
                    Section("About") {
                        if let url = URL(string: "https://github.com/ca057/habits") {
                            
                            Link(destination: url) {
                                Label {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Browse the source code")
                                        Text(url.absoluteString)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                } icon: {
                                    Image(systemName: "link")
                                }
                            }
                        }
                        VStack(alignment: .center) {
                            HStack {
                                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                                    .cornerRadius(4)
                                Text(Bundle.main.versionAndBuildNumber)
                                    .font(.footnote)
                            }
                        }.frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Settings")
            .fileExporter(
                isPresented: $showingExporter,
                document: getDataAsJsonFile(),
                contentType: .json
            ) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print("export whoopsie \(error.localizedDescription)")
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    importDataFromJsonFileUrl(urls)
                case .failure(let error):
                    print("import whoopsie \(error.localizedDescription)")
                }
            }
            .alert(isPresented: $errorMessage.showing) {
                Alert(
                    title: Text(errorMessage.title),
                    message: Text(errorMessage.message)
                )
            }
        }
    }
    
    private func getHighResolutionAppIconName() -> String? {
        guard let infoPlist = Bundle.main.infoDictionary else { return nil }
        guard let bundleIcons = infoPlist["CFBundleIcons"] as? NSDictionary else { return nil }
        guard let bundlePrimaryIcon = bundleIcons["CFBundlePrimaryIcon"] as? NSDictionary else { return nil }
        guard let bundleIconFiles = bundlePrimaryIcon["CFBundleIconFiles"] as? NSArray else { return nil }
        guard let appIcon = bundleIconFiles.lastObject as? String else { return nil }
        return appIcon
    }

}

fileprivate extension Settings {
    func getDataAsJsonFile() -> DataExport.JSONFile? {
        do {
            let allHabitsDescriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.createdAt)])
            let allHabits = try modelContext.fetch(allHabitsDescriptor)
            
            let export = DataExport.HabitsExport(
                appVersion: Bundle.main.versionAndBuildNumber,
                exportDate: Date(),
                habits: allHabits.map { habit in
                    DataExport.HabitsExportItem(
                        id: habit.id,
                        name: habit.name,
                        createdAt: habit.createdAt,
                        colour: habit.colour,
                        entries: habit.entry.map { entry in
                            DataExport.HabitsExportItemEntry(date: entry.date)
                        }
                    )
                }
            )
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.dateEncodingStrategy = .iso8601
            jsonEncoder.outputFormatting = .prettyPrinted
            
            return DataExport.JSONFile(try jsonEncoder.encode(export))
        } catch {
            errorMessage = ErrorAlert(
                showing: true,
                title: "Export your data failed",
                message: "Something went wrong during the export. Please try again." // TODO: original message
            )
            
            return nil
        }
    }
    
    func importDataFromJsonFileUrl(_ urls: [URL]) {
        if urls.count > 1 {
            errorMessage = ErrorAlert(
                showing: true,
                title: "Importing your data failed",
                message: "You can only import one file at once. Please try again."
            )
            return
        }
        
        guard let url = urls.first else {
            errorMessage = ErrorAlert(
                showing: true,
                title: "Importing your data failed",
                message: "Something went wrong retrieving the file location. Please try again."
            )
            return
        }
        
        do {
            guard let data = try String(contentsOf: url).data(using: .utf8) else {
                throw DataExport.HabitsStorageError.importFailed
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let decodedData = try decoder.decode(DataExport.HabitsExport.self, from: data)
            
            decodedData.habits.forEach { habitToImport in
                let habit = Habit(
                    colour: habitToImport.colour,
                    createdAt: habitToImport.createdAt,
                    id: habitToImport.id,
                    name: habitToImport.name,
                    order: 0
                )
                modelContext.insert(habit)
                
                habitToImport.entries.forEach { entryToImport in
                    let entry = Entry(date: entryToImport.date, habit: habit)
                    modelContext.insert(entry)
                }
            }
            try modelContext.save()
        } catch {
            print("error during import \(error)")
            errorMessage = ErrorAlert(
                showing: true,
                title: "Importing your data failed",
                message: "The data in your export couldn’t be read. Check if it’s a valid export and try again."
            )
        }
    }
}

#Preview {
    Settings()
}

