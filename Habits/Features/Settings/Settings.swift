//
//  Settings.swift
//  Habits
//
//  Created by Christian Ost on 29.03.23.
//

import SwiftUI

struct Settings: View {
    @StateObject private var viewModel = ViewModel()
            
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Data") {
                        Button(action: {
                            viewModel.showingExporter = true
                        }) {
                            Label("Export data", systemImage: "square.and.arrow.up")
                        }
                    }
                    
                    Section("About") {
                        Link("Source Code", destination: URL(string: "https://github.com/ca057/habits")!)
                        VStack(alignment: .center) {
                            Text(Bundle.main.versionAndBuildNumber)
                                .font(.footnote)
                        }.frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Settings")
            .fileExporter(
                isPresented: $viewModel.showingExporter,
                document: viewModel.getDataAsJsonFile(),
                contentType: .json
            ) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    print("whoopsie \(error.localizedDescription)")
                }
            }
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}


