//
//  ContentView.swift
//  FlappyCloneSwiftUI
//
//  Created by Gerrit Zeissl on 04.06.23.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    // Computed Property
    var scene: SKScene {
        let scene = GameScene()
            scene.size = CGSize(width: UIScreen.main.bounds.size.width,
                                height: UIScreen.main.bounds.size.height)
            scene.scaleMode = .aspectFill
            return scene
        }
    
        var body: some View {
            SpriteView(scene: scene,
                       options: [.ignoresSiblingOrder], // ignore draw order
                       debugOptions: [ .showsFPS, .showsNodeCount, .showsPhysics]) // show some debug infos
                .ignoresSafeArea()
                
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
