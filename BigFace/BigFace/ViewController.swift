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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            snapshotView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
}

extension ViewController : ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        <#code#>
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        <#code#>
    }
    
}

