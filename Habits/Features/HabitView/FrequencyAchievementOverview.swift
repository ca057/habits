//
//  PeriodicO.swift
//  Habits
//
//  Created by Christian Ost on 19.04.24.
//

import SwiftUI

//protocol FrequencyAchievement {
//    var year: Date
//}

enum Frequency: String, CaseIterable, Identifiable {
    case daily
//    , weekly
    
    var id: Self { self }
}

//fileprivate struct WeeklyFrequencyAchievementOverview: View {
//    @Environment(\.calendar) private var calendar
//    
//    var year: Date
//    
//    var body: some View {
//        Text("N/A")
//    }
//}

fileprivate struct DailyFrequencyAchievementOverview: View {
    @Environment(\.calendar) private var calendar

    var year: Date
    var achieved: [Date]
    var color: Color

    private var daysOfMonth: [[Date]] {
        guard
            let yearInteral = calendar.dateInterval(of: .year, for: year)
        else { return [] }
        
        return calendar.generateDates(
            inside: yearInteral,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        ).map { getDaysInMonth($0) }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                ForEach(daysOfMonth, id: \.self) { days in
                    HStack {
                        VStack(spacing: 4) {
                            ForEach(days, id: \.self) { day in
                                Circle()
                                    .frame(width: 12, height: 12)
                                    .foregroundStyle(
                                        // TODO: make this more efficient!
                                        achieved.contains(where: {
                                            $0.compare(.isSameDay(as: day))
                                        })
                                        ? color.opacity(day.compare(.isWeekend) ? 0.5 : 1)
                                        : .gray.opacity(day.compare(.isWeekend) ? 0.75 : 1)
                                    )
                                    .overlay {
                                        if day.compare(.isToday) {
                                            Circle()
                                                .stroke(.black, lineWidth: 2)
                                                .fill(.clear)
                                                .frame(width: 16, height: 16)
                                        }
                                    }
                            }
                        }
                        if daysOfMonth.last != days {
                            Spacer()
                        }
                    }
                }
            }.padding(.bottom)
        }
    }
    
    private func getDaysInMonth(_ month: Date) -> [Date] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: month)
        else { return [] }
        
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
}

struct FrequencyAchievementOverview: View {
    var frequency: Frequency = .daily
    var year: Date
    var achieved: [Date]
    var color: Color

    var body: some View {
        switch frequency {
        case .daily: DailyFrequencyAchievementOverview(year: year, achieved: achieved, color: color)
//        case .weekly: WeeklyFrequencyAchievementOverview(year: Date.now)
        }
    }
    
    init(_ frequency: Frequency = .daily, year: Date, achieved: [Date], color: Color) {
        self.frequency = frequency
        self.year = year
        self.achieved = achieved
        self.color = color
    }
}

#Preview {
    struct Container: View {
        @State private var frequency = Frequency.daily

        private var achievedDays: [Date] {
            guard var interval = Calendar.current.dateInterval(of: .year, for: Date.now) else { return [] }
            interval.end = Date.now
            
            return Calendar.current.generateDates(
                    inside: interval,
                    matching: DateComponents(hour: 0)
                ).reduce(into: [Date]()) { res, d in
                    if Int.random(in: 1..<100) < 70 {
                        res.append(d)
                    }
                }
        }

        var body: some View {
            VStack {
                FrequencyAchievementOverview(frequency, year: Date.now, achieved: achievedDays, color: .green)
                
                Spacer()

                Picker("frequency", selection: $frequency) {
                    ForEach(Frequency.allCases) { f in
                        Text(f.rawValue.capitalized).tag(f)
                    }
                }.pickerStyle(.segmented)
            }
            .padding()
        }
    }
    
    return Container()
}
