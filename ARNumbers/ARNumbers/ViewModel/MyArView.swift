//
//  MyArView.swift
//  ARNumbers
//
//  Created by Gerrit Zeissl on 05.06.23.
//


import Foundation
import RealityKit
import ARKit

class MyArView : ARSCNView {
    
    var number: Number?
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        setUp()
    }
    
    func setUp() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        debugOptions = [
            .showFeaturePoints
        ]
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        guard let sceneView = sender.view as? ARSCNView else {return}
        
        let touchLocation = sender.location(in: sceneView)
        let hittest = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .horizontal)
        
        if let test = hittest, !sceneView.session.raycast(test).isEmpty, let first = sceneView.session.raycast(test).first {
            
            let transform = first.worldTransform
            
            let planeX = transform.columns.3.x
            let planeY = transform.columns.3.y
            let planeZ = transform.columns.3.z
            
            let textImage = "0".image(withAttributes: [.backgroundColor: UIColor.orange, .foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 50.0)])
            
            let planeGeometry = SCNBox(width: 0.15, height: 0.15, length: 0.15, chamferRadius: 0.01)
            let planeNode = SCNNode(geometry: planeGeometry)
            planeNode.name = "plane"
            let textMaterial = SCNMaterial()
            textMaterial.diffuse.contents = textImage
            textMaterial.isDoubleSided = true
            textMaterial.reflective.contents = UIColor.white
            textMaterial.reflective.intensity = 0.1
            planeGeometry.materials = [textMaterial]
            planeNode.position = SCNVector3(planeX, planeY, planeZ)
            planeNode.eulerAngles = SCNVector3(0, 0, 0)
            sceneView.scene.rootNode.addChildNode(planeNode)
            
            number?.hasBox = true
        }
    }
    
    func updateNumber(uiView: ARSCNView) {
        guard let number = number else {return}
        
        if(!number.hasBox) {
            uiView.scene.rootNode.enumerateChildNodes { (childNode, _) in
                childNode.removeFromParentNode()
            }
            return
        }
        
        uiView.scene.rootNode.enumerateChildNodes { (childNode, _) in
            if childNode.name == "plane" {
                childNode.geometry?.firstMaterial?.diffuse.contents = "\(number.num)".image(withAttributes: [.backgroundColor: UIColor.orange, .foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 50.0)])
            }
        }
    }
}

extension String {
    
    /// Generates a `UIImage` instance from this string using a specified
    /// attributes and size.
    ///
    /// - Parameters:
    ///     - attributes: to draw this string with. Default is `nil`.
    ///     - size: of the image to return.
    /// - Returns: a `UIImage` instance from this string using a specified
    /// attributes and size, or `nil` if the operation fails.
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(in: CGRect(origin: .zero, size: size),
                                    withAttributes: attributes)
        }
    }
}
