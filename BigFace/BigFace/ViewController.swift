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
    // 메모리를 위한 필터생성 - 매번 필터를 생성해서 씌우고 변경하면 낭비!
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
        setUpDelegate()
        setUpLayout()
    }
    
    func setUpDelegate(){
        guard ARFaceTrackingConfiguration.isSupported else { return }
        view.addSubview(sceneView)
        sceneView.delegate = self
        let ARFace: ARFaceTrackingConfiguration = ARFaceTrackingConfiguration();
        ARFace.maximumNumberOfTrackedFaces = 5
        sceneView.session.run(ARFace, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func setUpLayout(){
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
    
}


