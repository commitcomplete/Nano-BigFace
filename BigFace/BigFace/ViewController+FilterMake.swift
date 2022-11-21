//
//  ViewController+FilterMake.swift
//  BigFace
//
//  Created by dohankim on 2022/11/22.
//

import Foundation
import UIKit

extension ViewController{
    // MARK: - make Color Filters
    // 칼라필터 생성 ---------------------------------------
    func filter(color : Float) -> CIFilter {
        let size = 64
        let defaultHue: Float = 0
        let hueRange: Float = 60
        let centerHueAngle: Float = defaultHue/360.0
        var destCenterHueAngle: Float = color
        let minHueAngle: Float = (defaultHue - hueRange/2.0) / 360
        let maxHueAngle: Float = (defaultHue + hueRange/2.0) / 360
        let hueAdjustment = centerHueAngle - destCenterHueAngle
        if destCenterHueAngle == 0  {
            //angle이 0이면 빨강
            destCenterHueAngle = 1
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
                        hsv.h = destCenterHueAngle == 1 ? 0 : hsv.h - hueAdjustment 
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
