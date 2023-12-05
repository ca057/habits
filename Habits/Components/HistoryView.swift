//
//  HistoryView.swift
//  Habits
//
//  Created by Christian Ost on 16.09.23.
//

import SwiftUI

struct HistoryView<Content>: View where Content: View {
    @Environment(\.calendar) var calendar

    @State private var monthsToDisplay: Int = 6

    @ViewBuilder var cell: (Date) -> Content

    private let increment: Int = 6
    private var startOfCurrentMonth: Date? {
        Date().adjust(for: .startOfMonth, calendar: calendar)
    }

    var body: some View {
        VStack {
            Header()
            
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        Button("show more") {
                            monthsToDisplay = monthsToDisplay + increment
                        }
                        Spacer()
                        Button("show less") {
                            monthsToDisplay = max(monthsToDisplay - increment, 1)
                        }
                        .disabled(monthsToDisplay == 1)
                        Spacer()
                    }
                    .padding(.bottom)
                    
                    VStack(spacing: 12) {
                        ForEach((0..<monthsToDisplay).reversed(), id: \.self) { rowIndex in
                            HistoryMonthView(
                                startOfMonth: (startOfCurrentMonth!).offset(.month, value: rowIndex * -1)!,
                                cell: cell
                            )
                        }
                    }
                    .scrollTargetLayout()
                }
                .padding()
            }
            .scrollTargetBehavior(.viewAligned)
            .defaultScrollAnchor(.bottom)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom)
    }
}

extension HistoryView {
    private struct Header: View {
        var body: some View {
            VStack {
                HStack(spacing: 0) {
                    ForEach(0..<CalendarUtils.shared.weekDays.count, id: \.self) { index in
                        Text(CalendarUtils.shared.weekDays[index])
                            .fontDesign(.rounded)
                            .foregroundStyle(index < 5 ? .primary : .secondary)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }.padding(.horizontal)
                Divider()
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView() { date in
            Text("\(date.toString(format: .custom("d")) ?? "")")
                .monospacedDigit()
                .foregroundStyle(date.compare(.isWeekend) ? .secondary : .primary)
        }.padding()
    }
}
