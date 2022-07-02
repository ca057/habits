//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var viewModel = MainViewModel()

    var body: some View {
        NavigationView {
            DashboardView()
                .navigationTitle("habits")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.showingAddHabit = true
                        } label: {
                            Label("Add new habit", systemImage: "plus")
                                .labelStyle(IconOnlyLabelStyle())
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showingAddHabit) {
                    AddHabitView()
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
