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
                        ShareLink(
                            item: viewModel.getDataAsJson(),
                            preview: SharePreview("Habits export")
                        ) {
                            Label("Export data as JSON", systemImage: "square.and.arrow.up")
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
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}


