//
//  PulseAnimation.swift
//  ARNumbers
//
//  Created by Gerrit Zeissl on 04.06.23.
//

import SwiftUI

struct PulseAnimation: View {
    
    var color: Color
    var leftToRight: Bool = false
    
    @State private var scaleInOut = false
    @State private var rotateInOut = false
    @State private var moveInOut = false
    
    var body: some View {
        ZStack {
            Rectangle() // Umrandung bzw Hintergrund
                .edgesIgnoringSafeArea(.all)
                .opacity(0.0)
            
            ZStack {
                ForEach(0...2, id:\.self) { circlePair in // In SwiftUI muss man mit id auf Item zugreifen...
                    ForEach(0...1, id:\.self) { circleRotation in
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [color, .white]), startPoint: circleRotation == 0 ? .bottom : .top, endPoint: circleRotation == 0 ? .top : .bottom))
                            .frame(width: 120, height: 120)
                            .offset(y: moveInOut ? circleRotation == 0 ? 60 : -60 : 0)
                            .opacity(0.5)
                            .rotationEffect(.degrees(Double(circlePair * 60)))
                    }
                }
            }
            .rotationEffect(.degrees(rotateInOut ? leftToRight ? -90 : 90 : 0))
            .scaleEffect(scaleInOut ? 1.0 : 0.25)
            .onAppear {
                withAnimation(Animation.easeInOut.repeatForever().speed(0.125)) {
                    moveInOut.toggle()
                    rotateInOut.toggle()
                    scaleInOut.toggle()
                }
            }
        }
    }
}

#if DEBUG
struct PulseAnimation_Previews : PreviewProvider {
    static var previews: some View {
        PulseAnimation(color: .green)
    }
}
#endif
