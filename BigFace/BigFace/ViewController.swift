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
    let sceneView = ARSCNView(frame: UIScreen.main.bounds)
    //The CoreML model we use for emotion classification.
    // MARK: emotion detect model deleted
    //    private let model = try! VNCoreMLModel(for: CNNEmotions().model)
    // MARK: filter 생성
    // 메모리를 위한 필터생성
    // 색상필터
    lazy var redFilter = self.filter(color: 1.0)
    lazy var yellowFilter = self.filter(color: 0.1)
    lazy var greenFilter = self.filter(color: 0.2)
    lazy var blueFilter = self.filter(color: 0.5)
    lazy var purpleFilter = self.filter(color: 0.9)
    // 특이 필터
    lazy var mosaicFilter = setMosaic()
    lazy var crystalFilter = setCrystal()
    lazy var convexFilter = setConvex()
    lazy var convexFilterHeight = setConvexHeight()
    lazy var circularDistortionFilter = setCircularDistortion()
    //----- 기본이외 추가 필터들
    lazy var dotFilter = setDotFilter()
    
    // MARK: button 생성
    // TODO: 반복되는 코드가 너무 많음 -> 줄일수 있다.
    // 칼라버튼
    lazy var colorFilterSelectButton = makeColorFilterSelectButton()
    lazy var distortFilterSelectButton = makeDistortFilterSelectButton()
    
    lazy var redFilterButton = makeColorFilterButton(color: .red)
    lazy var yellowFilterButton = makeColorFilterButton(color: .yellow)
    lazy var greenFilterButton = makeColorFilterButton(color: .green)
    lazy var blueFilterButton = makeColorFilterButton(color: .blue)
    lazy var purpleFilterButton = makeColorFilterButton(color: .purple)
    lazy var noColorFilterButton = makeColorFilterButton(color: .clear)
    
    lazy var mosaicFilterButton = makeDistortFilterButton(name: "Mosaic")
    lazy var crystalFilterButton = makeDistortFilterButton(name: "Crystal")
    lazy var convex1FilterButton = makeDistortFilterButton(name: "Convex1")
    lazy var convex2FilterButton = makeDistortFilterButton(name: "Convex2")
    lazy var circleFilterButton = makeDistortFilterButton(name: "Circle")
    lazy var noDistortFilterButton = makeDistortFilterButton(name: "BigFace")
    //----- 기본이외 추가 필터들
    lazy var dotFilterButton = makeDistortFilterButton(name: "Dot")
    
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
        addColorFilterButtons()
        addDistortFilterButtons()
        
    }
    
    func addColorFilterButtons(){
        view.addSubview(redFilterButton)
        view.addSubview(yellowFilterButton)
        view.addSubview(greenFilterButton)
        view.addSubview(blueFilterButton)
        view.addSubview(purpleFilterButton)
        view.addSubview(noColorFilterButton)
        view.addSubview(colorFilterSelectButton)
    }
    
    func addDistortFilterButtons(){
        view.addSubview(mosaicFilterButton)
        view.addSubview(crystalFilterButton)
        view.addSubview(convex1FilterButton)
        view.addSubview(convex2FilterButton)
        view.addSubview(circleFilterButton)
        view.addSubview(noDistortFilterButton)
        view.addSubview(distortFilterSelectButton)
        //추가 필터들
        view.addSubview(dotFilterButton)
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
    
    //MARK: 사진공유 기능 - 지금은 MVP에서 빠짐
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
    func setMosaic() -> CIFilter{
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
    
    func setDotFilter() -> CIFilter{
        let f = CIFilter.dotScreen()
        f.angle = .greatestFiniteMagnitude
        return f
    }
}


