//
//  SettingsStore.swift
//  Habits
//
//  Created by Christian Ost on 03.09.24.
//

struct SettingProperties {
    static let overviewDateRangeKey = "overviewDateRange"
    enum OverviewDateRange : String {
        case pastSevenDays = "pastSevenDays"
        case currentWeek = "currentWeek"
    }
}
