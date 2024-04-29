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

fileprivate struct VerticalLabel: View {
    // copied from https://stackoverflow.com/a/76570744
    var text: Text
    
    var body: some View {
        VerticalLayout() {
            text
        }.rotationEffect(.degrees(-90))
    }
    
    private struct VerticalLayout: Layout {
        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            let size = subviews.first!.sizeThatFits(.unspecified)
            return .init(width: size.height, height: size.width)
        }
        
        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            subviews.first!.place(at: .init(x: bounds.midX, y: bounds.midY), anchor: .center, proposal: .unspecified)
        }
    }
}

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
                                VStack {
                                    // TODO: test this first but propably make this more efficient!
                                    let isAchieved = achieved.contains(where: {
                                        $0.compare(.isSameDay(as: day))
                                    })
                                    let size = CGFloat(isAchieved ? 12 : 4)

                                    Circle()
                                        .frame(width: size, height: size)
                                        .foregroundStyle(isAchieved ? color : .gray)
                                        .opacity(day.compare(.isWeekend) ? 0.75 : 1)
                                        .overlay {
                                            if day.compare(.isToday) {
                                                Circle()
                                                    .stroke(Color.primary, lineWidth: 2)
                                                    .fill(.clear)
                                                    .frame(width: 16, height: 16)
                                            }
                                        }
                                }
                                .frame(maxWidth: .infinity, minHeight: 12)
                                .padding(.bottom, 2)
                            }
                        }
                    }
                }
            }.padding(.bottom, 2)
            HStack {
                ForEach(0..<calendar.shortStandaloneMonthSymbols.count, id: \.self) { index in
                    VerticalLabel(
                        text: Text(calendar.shortStandaloneMonthSymbols[index].uppercased())
                            .monospaced()
                    ).frame(maxWidth: .infinity)
                }
            }
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
        @State private var theme: ColorScheme = .dark
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
//
                Picker("theme", selection: $theme) {
                    ForEach(ColorScheme.allCases, id: \.self) { f in
                        Text(f == .dark ? "dark" : "light").tag(f)
                    }
                }.pickerStyle(.segmented)
            }
            .preferredColorScheme(theme)
            .padding()
        }
    }
    
    return Container()
}
