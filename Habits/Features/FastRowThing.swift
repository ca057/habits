//
//  FastRowThing.swift
//  Habits
//
//  Created by Christian Ost on 10.09.23.
//

import SwiftUI

struct FastRowThing: View {
    @State private var rows = 1
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<rows, id: \.self) {
                    Text("index \($0)")
                        
                }.transition(.move(edge: .leading))
            }
            HStack {
                Button("more rows") {
                    withAnimation {
                        rows += 10
                    }
                }
                Button("less rows") {
                    withAnimation {
                        rows -= 10
                    }
                }
            }.transition(.move(edge: .trailing))
        }
    
    }
}

struct FastRowThing_Previews: PreviewProvider {
    static var previews: some View {
        FastRowThing()
    }
}
