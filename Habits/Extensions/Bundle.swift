//
//  Bundle.swift
//  Habits
//
//  Created by Christian Ost on 10.06.22.
//

import Foundation

extension Bundle {
    private var versionNumber: String {
        self.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
    private var buildNumber: String {
        self.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
    
    var versionAndBuildNumber: String {
        "v\(self.versionNumber) (\(self.buildNumber))"
    }
}
