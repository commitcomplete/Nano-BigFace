//
//  ViewController.swift
//  BigFace
//
//  Created by dohankim on 2022/08/30.
//

import UIKit
import ARKit
import CoreImage
import CoreImage.CIFilterBuiltins
import AVFoundation

class ViewController: UIViewController {
    private let sceneView = ARSCNView(frame: UIScreen.main.bounds)
    //The CoreML model we use for emotion classification.
    private let model = try! VNCoreMLModel(for: CNNEmotions().model)
    // MARK: filter 생성
    // 메모리를 위한 필터생성
    // 색상필터
    lazy var redFilter = self.filter(color: 1.0)
    lazy var yellowFilter = self.filter(color: 0.1)
    lazy var greenFilter = self.filter(color: 0.2)
    lazy var blueFilter = self.filter(color: 0.5)
    lazy var purpleFilter = self.filter(color: 0.9)
    // 특이 필터
    lazy var mosaikFilter = setMosaik()
    lazy var crystalFilter = setCrystal()
    lazy var convexFilter = setConvex()
    lazy var convexFilterHeight = setConvexHeight()
    lazy var circularDistortionFilter = setCircularDistortion()
    // MARK: button 생성
    // 칼라버튼
    lazy var colorFilterSelectButton = makeColorFilterSelectButton()
    lazy var distortFilterSelectButton = makeDistortFilterSelectButton()
    
    lazy var redFilterButton = makeColorFilterButton(color: .red)
    lazy var yellowFilterButton = makeColorFilterButton(color: .yellow)
    lazy var greenFilterButton = makeColorFilterButton(color: .green)
    lazy var blueFilterButton = makeColorFilterButton(color: .blue)
    lazy var purpleFilterButton = makeColorFilterButton(color: .purple)
    lazy var noColorFilterButton = makeColorFilterButton(color: .clear)
    
    lazy var mosaikFilterButton = makeDistortFilterButton(name: "Mosaik")
    lazy var crystalFilterButton = makeDistortFilterButton(name: "Crystal")
    lazy var convex1FilterButton = makeDistortFilterButton(name: "Convex1")
    lazy var convex2FilterButton = makeDistortFilterButton(name: "Convex2")
    lazy var circleFilterButton = makeDistortFilterButton(name: "Circle")
    lazy var noDistortFilterButton = makeDistortFilterButton(name: "BigFace")
    
    var screenSize = UIScreen.main.bounds.size
    var width = UIScreen.main.bounds.width
    var height = UIScreen.main.bounds.height
    // 칼라필터 선택창이 열렸는지 확인
    var isColorSelectOpen = false
    var currentColorFilter : UIColor = .clear
    
    var isDistortSelectOpen = false
    var currentDistortFilter = "BigFace"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard ARFaceTrackingConfiguration.isSupported else { return }
        view.addSubview(sceneView)
        sceneView.delegate = self
        let ARFace: ARFaceTrackingConfiguration = ARFaceTrackingConfiguration();
        ARFace.maximumNumberOfTrackedFaces = 5
        sceneView.session.run(ARFace, options: [.resetTracking, .removeExistingAnchors])
        view.addSubview(makeCaptureButton())
        view.addSubview(mosaikFilterButton)
        view.addSubview(crystalFilterButton)
        view.addSubview(convex1FilterButton)
        view.addSubview(convex2FilterButton)
        view.addSubview(circleFilterButton)
        view.addSubview(noDistortFilterButton)
        view.addSubview(distortFilterSelectButton)
        view.addSubview(redFilterButton)
        view.addSubview(yellowFilterButton)
        view.addSubview(greenFilterButton)
        view.addSubview(blueFilterButton)
        view.addSubview(purpleFilterButton)
        view.addSubview(noColorFilterButton)
        view.addSubview(colorFilterSelectButton)
    }
    
    // MARK: UIComponent  + Action생성
    // uicomponenet 생성 ------------------------------------------
    func makeCaptureButton() -> UIButton{
        let button = UIButton()
        let width : CGFloat = 80
        let height : CGFloat = 80
        let xPos = self.width * 0.5 - width/2
        let yPos = self.height * 0.9 - height/2
        button.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        button.backgroundColor = .white
        button.layer.cornerRadius = 40
        button.addTarget(self, action: #selector(onClickCaptureButton(_:)), for: .touchUpInside)
        
        let btn = UIButton()
        btn.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        btn.backgroundColor = .white
        btn.layer.borderWidth = 3
        btn.layer.cornerRadius = 30
        btn.layer.borderColor = UIColor.black.cgColor
        btn.addTarget(self, action: #selector(onClickCaptureButton(_:)), for: .touchUpInside)
        button.addSubview(btn)
        
        return button
    }
    
    @objc internal func onClickCaptureButton(_ sender: Any) {
        if sender is UIButton {
            saveInPhoto(img: sceneView.snapshot())
            showScreenshotEffect()
            AudioServicesPlaySystemSound(1108)
        }
        
    }
    
    // make color button
    func makeColorFilterSelectButton() -> UIButton{
        let button = UIButton()
        let width : CGFloat = 60
        let height : CGFloat = 60
        let xPos = self.width * 0.2 - width/2
        let yPos = self.height * 0.9 - height/2
        button.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 30
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(onClickColorFilterSelectButton(_:)), for: .touchUpInside)
        return button
    }
    
    @objc internal func onClickColorFilterSelectButton(_ sender: Any) {
        if sender is UIButton {
            if !isColorSelectOpen {
                UIView.animate(withDuration: 0.4, animations: {
                    self.noColorFilterButton.layer.opacity = 0.6
                    self.noColorFilterButton.layer.position = CGPoint(x: self.width * 0.2 , y: self.height * 0.9 - 30 - 50)
                    self.redFilterButton.layer.opacity = 0.6
                    self.redFilterButton.layer.position = CGPoint(x: self.width * 0.2, y: self.height * 0.9 - 30 - 110)
                    self.yellowFilterButton.layer.opacity = 0.6
                    self.yellowFilterButton.layer.position = CGPoint(x: self.width * 0.2, y: self.height * 0.9 - 30 - 170)
                    self.greenFilterButton.layer.opacity = 0.6
                    self.greenFilterButton.layer.position = CGPoint(x: self.width * 0.2, y: self.height * 0.9 - 30 - 230)
                    self.blueFilterButton.layer.opacity = 0.6
                    self.blueFilterButton.layer.position = CGPoint(x: self.width * 0.2, y: self.height * 0.9 - 30 - 290)
                    self.purpleFilterButton.layer.opacity = 0.6
                    self.purpleFilterButton.layer.position = CGPoint(x: self.width * 0.2, y: self.height * 0.9 - 30 - 350)
                }) { _ in
                  
                    self.isColorSelectOpen = true
                }
            }
            else {
                closeColorFilters()
            }
            
        }
        
    }
    func makeDistortFilterSelectButton() -> UIButton{
        let button = UIButton()
        let width : CGFloat = 100
        let height : CGFloat = 60
        let xPos = self.width * 0.8 - width/2
        let yPos = self.height * 0.9 - height/2
        button.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        button.backgroundColor = .clear
        button.setTitle("BigFace", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(onClickDistortFilterSelectButton(_:)), for: .touchUpInside)
//        button.layer.cornerRadius = 30
//        button.layer.borderWidth = 2
//        button.layer.borderColor = UIColor.white.cgColor
        return button
    }
    
    @objc internal func onClickDistortFilterSelectButton(_ sender: Any) {
        if sender is UIButton {
            if !isDistortSelectOpen{
                UIView.animate(withDuration: 0.4, animations: {
                    self.noDistortFilterButton.layer.opacity = 1.0
                self.noDistortFilterButton.layer.position = CGPoint(x: self.width * 0.8 , y: self.height * 0.9 - 30 - 50)
                self.mosaikFilterButton.layer.opacity =  1.0
                self.mosaikFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 110)
                self.crystalFilterButton.layer.opacity =  1.0
                self.crystalFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 170)
                self.convex1FilterButton.layer.opacity =  1.0
                self.convex1FilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 230)
                self.convex2FilterButton.layer.opacity =  1.0
                self.convex2FilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 290)
                self.circleFilterButton.layer.opacity =  1.0
                self.circleFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 350)
                }){ _ in
                    
                    self.isDistortSelectOpen = true
                }
                               
            }
            else{
                closeDistortFilters()
            }
        }
        
    }
    
    func makeColorFilterButton(color: UIColor)->UIButton{
        let button = UIButton()
        let width : CGFloat = 50
        let height : CGFloat = 50
        let xPos = self.width * 0.2 - width/2
        let yPos = self.height * 0.9 - height/2
        button.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        button.backgroundColor = color
        button.layer.cornerRadius = 25
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.opacity = 0
        button.addTarget(self, action: #selector(onClickColorFilterButton(_:)), for: .touchUpInside)
        
        return button
        
    }
    
    @objc internal func onClickColorFilterButton(_ sender: Any) {
        if let button = sender as? UIButton {
            
            if currentDistortFilter == "BigFace"{
            
            if button.backgroundColor == .red{
                sceneView.scene.rootNode.filters = [redFilter]
            }
            else if button.backgroundColor == .yellow{
                sceneView.scene.rootNode.filters = [yellowFilter]
            }
            else if button.backgroundColor == .green{
                sceneView.scene.rootNode.filters = [greenFilter]
            }
            else if button.backgroundColor == .blue{
                sceneView.scene.rootNode.filters = [blueFilter]
            }
            else if button.backgroundColor == .purple{
                sceneView.scene.rootNode.filters = [purpleFilter]
            }
            else if button.backgroundColor == .clear{
                sceneView.scene.rootNode.filters = []
            }
            colorFilterSelectButton.backgroundColor = button.backgroundColor
            currentColorFilter = button.backgroundColor!
            closeColorFilters()
            
            }else{
                var distortFilter = CIFilter()
                if currentDistortFilter == "Mosaik"{
                    distortFilter = mosaikFilter
                }
                else if currentDistortFilter == "Crystal"{
                    distortFilter = crystalFilter
                }
                else if currentDistortFilter == "Convex1"{
                    distortFilter = convexFilter
                }
                else if currentDistortFilter == "Convex2"{
                    distortFilter = convexFilterHeight
                }
                else if currentDistortFilter == "Circle"{
                    distortFilter = circularDistortionFilter
                }
                
                if button.backgroundColor == .red{
                    sceneView.scene.rootNode.filters = [redFilter,distortFilter]
                }
                else if button.backgroundColor == .yellow{
                    sceneView.scene.rootNode.filters = [yellowFilter,distortFilter]
                }
                else if button.backgroundColor == .green{
                    sceneView.scene.rootNode.filters = [greenFilter,distortFilter]
                }
                else if button.backgroundColor == .blue{
                    sceneView.scene.rootNode.filters = [blueFilter,distortFilter]
                }
                else if button.backgroundColor == .purple{
                    sceneView.scene.rootNode.filters = [purpleFilter,distortFilter]
                }
                else if button.backgroundColor == .clear{
                    sceneView.scene.rootNode.filters = [distortFilter]
                }
                colorFilterSelectButton.backgroundColor = button.backgroundColor
                currentColorFilter = button.backgroundColor!
                closeColorFilters()
                
                
            }
            
        }
    }
    
    func makeDistortFilterButton(name: String)->UIButton{
        let button = UIButton()
        let width : CGFloat = 100
        let height : CGFloat = 50
        let xPos = self.width * 0.8 - width/2
        let yPos = self.height * 0.9 - height/2
        button.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        button.tintColor = .white
        button.setTitle(name, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.opacity = 0
        button.addTarget(self, action: #selector(onClickDistortFilterButton(_:)), for: .touchUpInside)
        
        return button
        
    }
    
    @objc internal func onClickDistortFilterButton(_ sender: Any) {
        if let button = sender as? UIButton {
            if currentColorFilter == UIColor.clear{
            if button.title(for: .normal) == "Mosaik" {
                sceneView.scene.rootNode.filters = [mosaikFilter]
                
            }
            else if button.title(for: .normal) == "Crystal"{
                sceneView.scene.rootNode.filters = [crystalFilter]
                
            }
            else if button.title(for: .normal) == "Convex1"{
                sceneView.scene.rootNode.filters = [convexFilter]
                
            }
            else if button.title(for: .normal) == "Convex2"{
                sceneView.scene.rootNode.filters = [convexFilterHeight]
                
            }
            else if button.title(for: .normal) == "Circle"{
                sceneView.scene.rootNode.filters = [circularDistortionFilter]
                
            }
            else if button.title(for: .normal) == "BigFace"{
                sceneView.scene.rootNode.filters = []
                
            }
            distortFilterSelectButton.setTitle(button.title(for: .normal)!, for: .normal)
            currentDistortFilter = button.title(for: .normal)!
            closeDistortFilters()
            
        }
            else{
                var colorFilter = CIFilter()
                if currentColorFilter == UIColor.red{
                    colorFilter = redFilter
                }
                else if currentColorFilter == UIColor.yellow{
                    colorFilter = yellowFilter
                }
                else if currentColorFilter == UIColor.green{
                    colorFilter = greenFilter
                }
                else if currentColorFilter == UIColor.blue{
                    colorFilter = blueFilter
                }
                else if currentColorFilter == UIColor.purple{
                    colorFilter = purpleFilter
                }
                
                if button.title(for: .normal) == "Mosaik" {
                    sceneView.scene.rootNode.filters = [colorFilter, mosaikFilter]
                    
                }
                else if button.title(for: .normal) == "Crystal"{
                    sceneView.scene.rootNode.filters = [colorFilter,crystalFilter]
                    
                }
                else if button.title(for: .normal) == "Convex1"{
                    sceneView.scene.rootNode.filters = [colorFilter,convexFilter]
                    
                }
                else if button.title(for: .normal) == "Convex2"{
                    sceneView.scene.rootNode.filters = [colorFilter,convexFilterHeight]
                    
                }
                else if button.title(for: .normal) == "Circle"{
                    sceneView.scene.rootNode.filters = [colorFilter,circularDistortionFilter]
                    
                }
                else if button.title(for: .normal) == "BigFace"{
                    sceneView.scene.rootNode.filters = [colorFilter]
                }
                distortFilterSelectButton.setTitle(button.title(for: .normal)!, for: .normal)
                currentDistortFilter = button.title(for: .normal)!
                closeDistortFilters()
            }
        }
    }
    
    func closeColorFilters(){
        UIView.animate(withDuration: 0.4, animations: {
            self.noColorFilterButton.layer.opacity = 0.0
            self.noColorFilterButton.layer.position = CGPoint(x: self.width * 0.2 , y: self.height * 0.9 - 25)
            self.redFilterButton.layer.opacity = 0.0
            self.redFilterButton.layer.position = CGPoint(x: self.width * 0.2 , y: self.height * 0.9 - 25)
            self.yellowFilterButton.layer.opacity = 0.0
            self.yellowFilterButton.layer.position = CGPoint(x: self.width * 0.2, y: self.height * 0.9 - 25)
            self.greenFilterButton.layer.opacity = 0.0
            self.greenFilterButton.layer.position = CGPoint(x: self.width * 0.2, y: self.height * 0.9 - 25)
            self.blueFilterButton.layer.opacity = 0.0
            self.blueFilterButton.layer.position = CGPoint(x: self.width * 0.2, y: self.height * 0.9 - 25)
            self.purpleFilterButton.layer.opacity = 0.0
            self.purpleFilterButton.layer.position = CGPoint(x: self.width * 0.2, y: self.height * 0.9 - 25)
        }) { _ in
            // Once animation completed, remove it from view.
            self.isColorSelectOpen = false
        }
    }
    
    func closeDistortFilters(){
        UIView.animate(withDuration: 0.4, animations: {
            self.noDistortFilterButton.layer.opacity = 0.0
            self.noDistortFilterButton.layer.position = CGPoint(x: self.width * 0.8 , y: self.height * 0.9 - 25)
            self.mosaikFilterButton.layer.opacity = 0.0
            self.mosaikFilterButton.layer.position = CGPoint(x: self.width * 0.8 , y: self.height * 0.9 - 25)
            self.crystalFilterButton.layer.opacity = 0.0
            self.crystalFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 25)
            self.convex1FilterButton.layer.opacity = 0.0
            self.convex1FilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 25)
            self.convex2FilterButton.layer.opacity = 0.0
            self.convex2FilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 25)
            self.circleFilterButton.layer.opacity = 0.0
            self.circleFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 25)
        }) { _ in
            // Once animation completed, remove it from view.
            self.isDistortSelectOpen = false
        }
    }
    
    // MARK: - make Color Filters
    // 칼라필터 생성 ---------------------------------------
    func filter(color : Float) -> CIFilter {
        let size = 64
        let defaultHue: Float = 0 //default color of blue truck
        let hueRange: Float = 60 //hue angle that we want to replace
        let centerHueAngle: Float = defaultHue/360.0
        var destCenterHueAngle: Float = color
        let minHueAngle: Float = (defaultHue - hueRange/2.0) / 360
        let maxHueAngle: Float = (defaultHue + hueRange/2.0) / 360
        let hueAdjustment = centerHueAngle - destCenterHueAngle
        if destCenterHueAngle == 0  {
            destCenterHueAngle = 1 //force red if slider angle is 0
        }
        var cubeData = [Float](repeating: 0, count: (size * size * size * 4))
        var offset = 0
        var x : Float = 0, y : Float = 0, z : Float = 0, a :Float = 1.0
        
        for b in 0..<size {
            x = Float(b)/Float(size)
            for g in 0..<size {
                y = Float(g)/Float(size)
                for r in 0..<size {
                    z = Float(r)/Float(size)
                    var hsv = RGBtoHSV(z, g: y, b: x)
                    
                    if (hsv.h > minHueAngle && hsv.h < maxHueAngle) {
                        hsv.h = destCenterHueAngle == 1 ? 0 : hsv.h - hueAdjustment //force red if slider angle is 360
                        let newRgb = HSVtoRGB(hsv.h, s:hsv.s, v:hsv.v)
                        
                        cubeData[offset] = newRgb.r
                        cubeData[offset+1] = newRgb.g
                        cubeData[offset+2] = newRgb.b
                    } else {
                        cubeData[offset] = z
                        cubeData[offset+1] = y
                        cubeData[offset+2] = x
                    }
                    cubeData[offset+3] =  a
                    offset += 4
                }
            }
        }
        
        let b = cubeData.withUnsafeBufferPointer{ Data(buffer:$0) }
        let data = b as NSData
        let colorCube = CIFilter(name: "CIColorCube", parameters: ["inputCubeDimension": size, "inputCubeData" : data])
        return colorCube!
    }
    
    func RGBtoHSV(_ r : Float, g : Float, b : Float) -> (h : Float, s : Float, v : Float) {
        var h : CGFloat = 0
        var s : CGFloat = 0
        var v : CGFloat = 0
        let col = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
        col.getHue(&h, saturation: &s, brightness: &v, alpha: nil)
        return (Float(h), Float(s), Float(v))
    }
    
    func HSVtoRGB(_ h : Float, s : Float, v : Float) -> (r : Float, g : Float, b : Float) {
        var r : Float = 0
        var g : Float = 0
        var b : Float = 0
        let C = s * v
        let HS = h * 6.0
        let X = C * (1.0 - fabsf(fmodf(HS, 2.0) - 1.0))
        if (HS >= 0 && HS < 1) {
            r = C
            g = X
            b = 0
        } else if (HS >= 1 && HS < 2) {
            r = X
            g = C
            b = 0
        } else if (HS >= 2 && HS < 3) {
            r = 0
            g = C
            b = X
        } else if (HS >= 3 && HS < 4) {
            r = 0
            g = X
            b = C
        } else if (HS >= 4 && HS < 5) {
            r = X
            g = 0
            b = C
        } else if (HS >= 5 && HS < 6) {
            r = C
            g = 0
            b = X
        }
        let m = v - C
        r += m
        g += m
        b += m
        return (r, g, b)
    }
    
    // MARK: - Photos
    //------------------- 이미지 저장, 공유 ---------------------
    // 사진 찍을때 깜빡임 효과
    func showScreenshotEffect() {
        let snapshotView = UIView()
        snapshotView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(snapshotView)
        // Activate full screen constraints
        let constraints:[NSLayoutConstraint] = [
            snapshotView.topAnchor.constraint(equalTo: view.topAnchor),
            snapshotView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            snapshotView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            snapshotView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        // White because it's the brightest color
        snapshotView.backgroundColor = UIColor.black
        // Animate the alpha to 0 to simulate flash
        UIView.animate(withDuration: 0.2, animations: {
            snapshotView.alpha = 0
        }) { _ in
            // Once animation completed, remove it from view.
            snapshotView.removeFromSuperview()
        }
    }
    // ui image 저장
    func saveInPhoto(img: UIImage) {
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }
    
    // ui image 공유
    func sharePicture(img: UIImage) {
        let av = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
    // MARK: setup 특이 필터
    func setCrystal() -> CIFilter{
        let f = CIFilter.crystallize()
        f.radius = 50
        return f
    }
    func setMosaik() -> CIFilter{
        let f = CIFilter(name: "CIPixellate")
        f?.setValuesForKeys([
            "inputScale": 50.0
        ])
        return f!
    }
    func setConvex() -> CIFilter{
        let f = CIFilter.bumpDistortion()
        f.radius = 1300.0
        f.center = CGPoint(x: 500, y: 1000)
        return f
    }
    func setConvexHeight() -> CIFilter{
        let f = CIFilter.bumpDistortionLinear()
        f.radius = 1300.0
        f.center = CGPoint(x: 500, y: 1000)
        return f
    }
    
    func setCircularDistortion() -> CIFilter{
        let f = CIFilter.pinchDistortion()
        f.radius = 300
        f.center = CGPoint(x: 500, y: 1000)
        return f
    }
}

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
        material.diffuse.contents = sceneView.scene.background.contents
        material.lightingModel = .constant
        
        guard let shaderURL = Bundle.main.url(forResource: "VideoTexturedFace", withExtension: "shader"),
              let modifier = try? String(contentsOf: shaderURL)
        else { fatalError("Can't load shader modifier from bundle.") }
        faceGeometry.shaderModifiers = [ .geometry: modifier]
        // Pass view-appropriate image transform to the shader modifier so
        // that the mapped video lines up correctly with the background video.
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
        //Updates the face geometry.
        faceGeometry.update(from: faceAnchor.geometry)
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:]).perform([VNCoreMLRequest(model: model) { [weak self] request, error in
            //Here we get the first result of the Classification Observation result.
            guard let firstResult = (request.results as? [VNClassificationObservation])?.first else { return }
            DispatchQueue.main.async { [self] in
                if firstResult.confidence > 0.92 {
                    
                }
            }
        }])
    }
    
}

