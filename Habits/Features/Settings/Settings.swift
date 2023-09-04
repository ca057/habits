//
//  Settings.swift
//  Habits
//
//  Created by Christian Ost on 29.03.23.
//

import SwiftUI
import Foundation


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
                            HStack {
                                Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                                Text(Bundle.main.versionAndBuildNumber)
                                    .font(.footnote)
                            }
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
    
    func getHighResolutionAppIconName() -> String? {
        guard let infoPlist = Bundle.main.infoDictionary else { return nil }
        guard let bundleIcons = infoPlist["CFBundleIcons"] as? NSDictionary else { return nil }
        guard let bundlePrimaryIcon = bundleIcons["CFBundlePrimaryIcon"] as? NSDictionary else { return nil }
        guard let bundleIconFiles = bundlePrimaryIcon["CFBundleIconFiles"] as? NSArray else { return nil }
        guard let appIcon = bundleIconFiles.lastObject as? String else { return nil }
        return appIcon
    }

}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}


