//
//  HabitViewModel.swift
//  Habits
//
//  Created by Christian Ost on 05.05.22.
//

import Foundation

let scopeWindow = -3 // in months

extension HabitView {
    @MainActor final class ViewModel: ObservableObject {
        private var habitsStorage: HabitsStorage
        private var habit: Habit
       
        @Published var name: String {
            didSet {
                self.saveChanges()
            }
        }
        @Published var colour: Colour {
            didSet {
                self.saveChanges()
            }
        }

        private var initialEarliestScope: Date = Date()
        @Published var currentEarliestScope: Date = Date()
        @Published var earliestEntry: Date = Date()
        @Published var latestEntry: Date = Date()
        
        var cannotLoadMore: Bool {
            currentEarliestScope <= earliestEntry
        }
        var cannotLoadLess: Bool {
            currentEarliestScope >= initialEarliestScope
        }
        
        func saveChanges() {
            habitsStorage.update(habit, name: name, colour: colour)
        }
        
        func deleteHabit() {
            habitsStorage.delete(self.habit)
        }
        
        func hasEntryForDate(_ date: Date?) -> Bool {
            guard let date = date else { return false }
            return habit.hasEntry(for: date)
        }
        
        func increaseCurrentVisibleScope () {
            currentEarliestScope = determineEarliestDate(
                currentEarliestScope.offset(.month, value: scopeWindow) ?? currentEarliestScope,
                earliestEntry
            )
        }
        func decreaseCurrentVisibleScope () {
            let now = Date.now
            let nextCurrentEarliestScope = determineLatestDate(
                currentEarliestScope.offset(.month, value: scopeWindow * -1) ?? currentEarliestScope,
                determineEarliestDate(
                    now.offset(.month, value: scopeWindow) ?? now,
                    earliestEntry
                )
            )
            currentEarliestScope = nextCurrentEarliestScope
        }

        // MARK: -
        convenience init(_ habit: Habit) {
            self.init(habit: habit, habitsStorage: .shared)
        }
        init(habit: Habit, habitsStorage: HabitsStorage) {
            // TODO: figure out why earliest entry is not shown
            self.habitsStorage = habitsStorage
            self.habit = habit
            self.name = habit.name ?? ""
            self.colour = Colour.fromRawValue(habit.colour)
            
            guard let entries = habit.entry, entries.count > 0 else { return }

            // TODO: get them sorted and use at(0) & at(-1)
            entries.forEach({
                guard
                    let entry = $0 as? Entry,
                    let date = entry.date
                else { return }

                if date.compare(.isEarlier(than: earliestEntry)) {
                    earliestEntry = date
                }
                if date.compare(.isLater(than: latestEntry)) {
                    latestEntry = date
                }
            })
            
            let now = Date.now
            currentEarliestScope = determineEarliestDate(
                now.offset(.month, value: scopeWindow) ?? now,
                earliestEntry
            )
            initialEarliestScope = currentEarliestScope
        }
        
        private func determineEarliestDate(_ dateA: Date, _ dateB: Date) -> Date {
            dateA < dateB ? dateB : dateA
        }
        
        private func determineLatestDate(_ dateA: Date, _ dateB: Date) -> Date {
            dateA > dateB ? dateB : dateA
        }
    }
}
