//
//  ARViewContainer.swift
//  ARNumbers
//
//  Created by Gerrit Zeissl on 04.06.23.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    @ObservedObject var number: Number
    var myArView = MyArView()
    
    func makeUIView(context: Context) -> ARSCNView {
        myArView.number = number
        return myArView
    }
            
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        myArView.updateNumber(uiView: uiView)
    }
    
}

#if DEBUG
struct ARViewContainer_Previews : PreviewProvider {
    static var previews: some View {
        ARViewContainer(number: Number())
    }
}
#endif
