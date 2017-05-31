//
//  main.swift
//  SvgToCoreGraphics
//
//  Created by Valentin Radu on 03/11/2016.
//  Copyright © 2016 valentinradu. All rights reserved.
//

import CoreFoundation
import PocketSVG


extension String : Error {}

let arguments = CommandLine.arguments

guard arguments.count > 1
else {throw "You need to have at least one SVG to convert (0 arguments given)"}

for path in arguments.dropFirst() {
    
    let url = URL(fileURLWithPath:path)
    
    _ = try url.checkResourceIsReachable()
    
    let name = url.deletingPathExtension().lastPathComponent
    let dir = url.deletingLastPathComponent()
    let layerFileURL = dir.appendingPathComponent(name + ".layer")
    
    
    let rootLayer = CALayer()
    
    var frame = CGRect.zero
    for vector in SVGBezierPath.pathsFromSVG(at: url as URL) {
        
        let layer = CAShapeLayer()
        layer.path = vector.cgPath
        
        
//        layer.path?.apply(info: nil) { (_, elementPointer) in
//            let element = elementPointer.pointee
//            let command: String
//            let pointCount: Int
//            switch element.type {
//            case .moveToPoint: command = "moveTo"; pointCount = 1
//            case .addLineToPoint: command = "lineTo"; pointCount = 1
//            case .addQuadCurveToPoint: command = "quadCurveTo"; pointCount = 2
//            case .addCurveToPoint: command = "curveTo"; pointCount = 3
//            case .closeSubpath: command = "close"; pointCount = 0
//            }
//            let points = Array(UnsafeBufferPointer(start: element.points, count: pointCount))
//            print("\(command) \(points)")
//        }
        
        //I hate the as! but it seems Swift 3 is still buggy
        layer.fillColor = vector.svgAttributes["fill"] as! CGColor?
        layer.fillRule = kCAFillRuleEvenOdd
        
        rootLayer.addSublayer(layer)
        
        frame = frame.union(vector.cgPath.boundingBox)
    }
    
    rootLayer.frame = frame
    
    for sublayer in rootLayer.sublayers ?? [] {
        sublayer.frame = frame
    }
    
    NSKeyedArchiver.archiveRootObject(rootLayer, toFile: layerFileURL.path)
}


