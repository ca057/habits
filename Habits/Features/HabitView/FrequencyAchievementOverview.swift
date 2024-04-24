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
    
    private var countOfDays: Int {
        guard let startOfYear = Date.now.adjust(for: .startOfYear),
              let endOfToday = Date.now.adjust(for: .endOfDay)
        else { return 0 }

        let hours = calendar.dateComponents([.hour], from: startOfYear, to: endOfToday).hour
        
        return Int(ceil(Double(hours ?? 0) / 24))
    }
    private var achievedPercentage: Double {
        (Double(achieved.count) / Double(countOfDays) * 100).rounded() / 100
    }
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
                                        ? .green.opacity(day.compare(.isWeekend) ? 0.5 : 1)
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
            
            // TODO: move this out of this component
            Text("\(achieved.count)").fontDesign(.rounded) +
            Text(" out of ").fontDesign(.rounded) +
            Text("\(countOfDays)").fontDesign(.rounded) +
            Text(" days ") +
            Text("(\(achievedPercentage.formatted(.percent))").fontDesign(.rounded).monospacedDigit().fontWeight(.bold)
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
    var achieved: [Date]

    var body: some View {
        switch frequency {
        case .daily: DailyFrequencyAchievementOverview(year: Date.now, achieved: achieved)
//        case .weekly: WeeklyFrequencyAchievementOverview(year: Date.now)
        }
    }
    
    init(_ frequency: Frequency = .daily, achieved: [Date]) {
        self.frequency = frequency
        self.achieved = achieved
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
                FrequencyAchievementOverview(frequency, achieved: achievedDays)
                
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
