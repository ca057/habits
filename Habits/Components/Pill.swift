//
//  FancyPill.swift
//  Habits
//
//  Created by Christian Ost on 27.02.24.
//

import SwiftUI

struct Pill: View {
    var color: Color
    @Binding var filled: Bool
    
    private let duration = 0.15

    var body: some View {
        GeometryReader { g in
            let shorterSide = min(g.size.width, g.size.height)
            RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                .fill(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: .infinity, style: .continuous)
                        .fill(color)
                        .blur(radius: shorterSide / 4)
                        .frame(width: g.size.width * 1.5, height: g.size.height * 1.5)
                        .transformEffect(.init(translationX: -(g.size.width * 0.15), y: g.size.height * 0.15))
                }
                .mask(
                    ZStack {
                        RoundedRectangle(cornerRadius: shorterSide, style: .continuous)
                            .strokeBorder(.black, lineWidth: shorterSide * 0.1)
                        
                        RoundedRectangle(cornerRadius: shorterSide, style: .continuous)
                            .scaleEffect(filled ? 1 : 0)
                            .animation(.easeOut(duration: duration), value: filled)
                    }
                )
                .phaseAnimator([false, true], trigger: filled) { content, phase in
                    content.scaleEffect(filled && phase ? 1.05 : 1)
                } animation: { phase in
                        .spring(duration: duration, bounce: 0.7)
                }
        }
    }
    
    init(_ color: Color, filled: Binding<Bool>) {
        self.color = color
        self._filled = filled
    }
    
    init(_ color: Color) {
        self.init(color, filled: .constant(false))
    }
}

#Preview {
    struct Container: View {
        @State var filled = true

        var body: some View {
            VStack {
                Pill(.red, filled: $filled)
                
                Pill(.blue, filled: $filled)
                
                Form {
                    Section {
                        Pill(.green, filled: $filled)
                    }
                    
                    Section {
                        HStack {
                            Text("fancy")
                            Pill(.gray, filled: $filled)
                        }
                    }
                }

                HStack {
                    Pill(.yellow, filled: $filled)
                    
                    Pill(.black, filled: $filled)
                    
                    Pill(.white, filled: $filled)
                }
            }
            .background(.gray)
            .padding()
            .onTapGesture {
                filled.toggle()
            }
        }
    }
    
    return Container()
}
