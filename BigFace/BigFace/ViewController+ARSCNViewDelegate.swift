//
//  ViewController+Extentions.swift
//  BigFace
//
//  Created by dohankim on 2022/11/22.
//

import UIKit
import ARKit

// MARK: BigFace 생성
extension ViewController : ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else { return nil }
        guard let sceneView = renderer as? ARSCNView,
              let frame = sceneView.session.currentFrame,
              anchor is ARFaceAnchor
        else { return nil }
        
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!, fillMesh: true)!
        let material = faceGeometry.firstMaterial!
        //material을 기존의 얼굴로 채운다.
        material.diffuse.contents = sceneView.scene.background.contents
        material.lightingModel = .constant
        
        guard let shaderURL = Bundle.main.url(forResource: "VideoTexturedFace", withExtension: "shader"),
              let modifier = try? String(contentsOf: shaderURL)
        else { fatalError("Can't load shader modifier from bundle.") }
        // shader를 이용한 얼굴형 확대
        faceGeometry.shaderModifiers = [ .geometry: modifier]
        let affineTransform = (frame.displayTransform(for: .portrait, viewportSize: screenSize))
        let transform = SCNMatrix4(affineTransform)
        faceGeometry.setValue(SCNMatrix4Invert(transform), forKey: "displayTransform")
        let node = SCNNode(geometry: faceGeometry)
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry,
              let pixelBuffer = self.sceneView.session.currentFrame?.capturedImage,
              let sceneView = renderer as? ARSCNView
        else {
            return
        }
        //움직일때마다 얼굴 업데이트
        faceGeometry.update(from: faceAnchor.geometry)
        
        // MARK: emotion detection model - model deleted
        //        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:]).perform([VNCoreMLRequest(model: model) { [weak self] request, error in
        //            //Here we get the first result of the Classification Observation result.
        //            guard let firstResult = (request.results as? [VNClassificationObservation])?.first else { return }
        //            DispatchQueue.main.async { [self] in
        //                if firstResult.confidence > 0.92 {
        //
        //                }
        //            }
        //        }])
    }
    
}
