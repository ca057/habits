//
//  PeriodicO.swift
//  Habits
//
//  Created by Christian Ost on 19.04.24.
//

import SwiftUI

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

struct FrequencyAchievementOverview<Content: View>: View {
    @Environment(\.calendar) private var calendar

    var year: Date
    @ViewBuilder var content: (Date) -> Content

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
                                    content(day)
                                    
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
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
 
#Preview {
    struct Container: View {
        @Environment(\.calendar) private var calendar

        private var achievedDays: [String] {
            guard var interval = Calendar.current.dateInterval(of: .year, for: Date.now) else { return [] }
            interval.end = Date.now
            
            return Calendar.current.generateDates(
                    inside: interval,
                    matching: DateComponents(hour: 0)
                ).reduce(into: [Date]()) { res, d in
                    if Int.random(in: 1..<100) < 70 {
                        res.append(d)
                    }
                }.map { $0.toString(format: .isoDate) ?? "" }
        }

        var body: some View {
            VStack {
                FrequencyAchievementOverview(year: Date.now) { day in
                    let date = day.toString(format: .isoDate) ?? ""
                    let isAchieved = achievedDays.contains(where: { $0 == date })
                    let size = CGFloat(isAchieved ? 12 : 4)
                    
//                    let isMonday = 
//                    let isSunday =

                    Circle()
                        .frame(width: size, height: size)
                        .foregroundStyle(isAchieved ? .green : .secondary)
                        .opacity(calendar.isDateInWeekend(day) ? 0.5 : 1)
                        .overlay {
                            if calendar.isDateInToday(day) {
                                Circle()
                                    .stroke(Color.primary, lineWidth: 2)
                                    .fill(.clear)
                                    .frame(width: 16, height: 16)
                            }
                        }

                }
            }
            .padding()
        }
    }
    
    return Container()
}
