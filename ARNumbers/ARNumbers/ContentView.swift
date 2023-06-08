//
//  ContentView.swift
//  ARNumbers
//
//  Created by Gerrit Zeissl on 04.06.23.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var number = Number()
    
    var body: some View {
        VStack {
            ARViewContainer(number: number)
            Spacer()
            NumberButtonBarView(number: number)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
