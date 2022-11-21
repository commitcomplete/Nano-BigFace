//
//  ViewController+ComponentMake.swift
//  BigFace
//
//  Created by dohankim on 2022/11/22.
//

import Foundation
import UIKit
import AVFoundation

extension ViewController{
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
                    self.mosaicFilterButton.layer.opacity =  1.0
                    self.mosaicFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 110)
                    self.crystalFilterButton.layer.opacity =  1.0
                    self.crystalFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 170)
                    self.convex1FilterButton.layer.opacity =  1.0
                    self.convex1FilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 230)
                    self.convex2FilterButton.layer.opacity =  1.0
                    self.convex2FilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 290)
                    self.circleFilterButton.layer.opacity =  1.0
                    self.circleFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 350)
                    self.dotFilterButton.layer.opacity =  1.0
                    self.dotFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 30 - 410)
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
                if currentDistortFilter == "Mosaic"{
                    distortFilter = mosaicFilter
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
                //추가 필터들
                else if currentDistortFilter == "Dot"{
                    distortFilter = dotFilter
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
                if button.title(for: .normal) == "Mosaic" {
                    sceneView.scene.rootNode.filters = [mosaicFilter]
                    
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
                //추가 필터들
                else if button.title(for: .normal) == "Dot"{
                    sceneView.scene.rootNode.filters = [dotFilter]
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
                
                if button.title(for: .normal) == "Mosaic" {
                    sceneView.scene.rootNode.filters = [colorFilter, mosaicFilter]
                    
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
                //추가 필터들
                else if button.title(for: .normal) == "Dot"{
                    sceneView.scene.rootNode.filters = [colorFilter,dotFilter]
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
            self.mosaicFilterButton.layer.opacity = 0.0
            self.mosaicFilterButton.layer.position = CGPoint(x: self.width * 0.8 , y: self.height * 0.9 - 25)
            self.crystalFilterButton.layer.opacity = 0.0
            self.crystalFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 25)
            self.convex1FilterButton.layer.opacity = 0.0
            self.convex1FilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 25)
            self.convex2FilterButton.layer.opacity = 0.0
            self.convex2FilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 25)
            self.circleFilterButton.layer.opacity = 0.0
            self.circleFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 25)
            //추가 필터들
            self.dotFilterButton.layer.opacity = 0.0
            self.dotFilterButton.layer.position = CGPoint(x: self.width * 0.8, y: self.height * 0.9 - 25)
        }) { _ in
            // Once animation completed, remove it from view.
            self.isDistortSelectOpen = false
        }
    }
    
}
