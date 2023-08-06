//
//  Created by Christian Ost on 17.02.22.
//

import SwiftUI

struct Dashboard: View {
    @StateObject private var viewModel = ViewModel()
    @Environment(\.editMode) private var editMode

    var body: some View {
        NavigationView {
            ScrollView {
                Text("This week")
                    .font(.title)
                    .fontDesign(.rounded)
                LazyVStack {
                    HStack {
                        Text("top")
                    }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(.blue)
                    ForEach(1...100, id: \.self) {
                        Text("Row \($0)")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("here")
                }
            }
            .toolbarTitleMenu {
                
                    Text("whoo")
                
            }
            .toolbarBackground(.automatic, for: .navigationBar)
        }
    }
}

extension Dashboard {
    struct EmptyView: View {
        var body: some View {
            Text("this is empty")
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}

struct Dashboard_Previews_Empty: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}

