//
//  ScanAcceptedBorder.swift
//  QR Scanner
//
//  Created by Eduardo Valencia on 2/13/17.
//  Copyright © 2017 Eduardo Valencia. All rights reserved.
//

import UIKit

class ScanAcceptedBorder: UIView {

    var borderLayer: CAShapeLayer?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // Drawing code
        borderLayer?.removeFromSuperlayer()
        self.contentMode = .redraw
        UIGraphicsBeginImageContext(rect.size)
        let radius: CGFloat = 28
        let rectangleRect = CGRect(x: 0, y: 0, width: 180, height: 180)
        borderLayer = CAShapeLayer()
        borderLayer?.position = self.center
        borderLayer?.rasterizationScale = UIScreen.main.scale * 2
        borderLayer?.shouldRasterize = true
        borderLayer?.bounds = rectangleRect
        borderLayer?.fillColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1).cgColor
        borderLayer?.path = drawScannerSquare(rect: rectangleRect, radius: radius, borderWidth: 5.5, sideLength: 60)
        UIGraphicsEndImageContext()
        guard borderLayer != nil else {
            return
        }
        self.layer.addSublayer(borderLayer!)
    }

    func drawScannerSquare(rect: CGRect, radius: CGFloat, borderWidth: CGFloat, sideLength: CGFloat) -> CGMutablePath {
        
        let innerArcRadius = radius - (borderWidth/2) * 2
        
        let path = CGMutablePath()
        let innerRect = rect.insetBy(dx: radius, dy: radius)
        let insideRight = innerRect.origin.x + innerRect.size.width
        let outsideRight = rect.origin.x + rect.size.width
        let insideBottom = innerRect.origin.y + innerRect.size.height
        let outsideBottom = rect.origin.y + rect.size.height
        let insideTop = innerRect.origin.y
        let outsideTop = rect.origin.y
        let outsideLeft = rect.origin.x
        let insideLeft = innerRect.origin.x
        
        let rightFirstXCoordinate = outsideRight - sideLength
        let rightTopLowestXCoordinate = outsideRight - borderWidth
        let rightTopLowestArcYCoordinate = insideTop + borderWidth
        let rightTopLowestArcXCoordinate = insideRight - borderWidth
        let rightTopHighestArcYCoordinate = outsideTop + borderWidth
        
        let leftBottomLowestXCoordinate = outsideLeft + borderWidth
        let leftBottomHighestArcYCoordinate = insideBottom - borderWidth
        let leftBottomLowestArcYCoordinate = outsideBottom - borderWidth
        let leftBottomLowestArcXCoordinate = insideLeft + borderWidth
        
        path.move(to: CGPoint(x: rightFirstXCoordinate, y: outsideTop))
        path.addLine(to: CGPoint(x: insideLeft, y: outsideTop))
        path.addArc(tangent1End: CGPoint(x: outsideLeft, y: outsideTop), tangent2End: CGPoint(x: outsideLeft, y: insideTop), radius: radius)
        path.addLine(to: CGPoint(x: outsideLeft, y: insideBottom))
        path.addArc(tangent1End: CGPoint(x: outsideLeft, y: outsideBottom), tangent2End: CGPoint(x: insideLeft, y: outsideBottom), radius: radius)
        path.addLine(to: CGPoint(x: insideRight, y: outsideBottom))
        path.addArc(tangent1End: CGPoint(x: outsideRight, y: outsideBottom), tangent2End: CGPoint(x: outsideRight, y: insideBottom), radius: radius)
        path.addLine(to: CGPoint(x: outsideRight, y: insideTop))
        path.addArc(tangent1End: CGPoint(x: outsideRight, y: outsideTop), tangent2End: CGPoint(x: insideRight, y: outsideTop), radius: radius)
        path.addLine(to: CGPoint(x: rightFirstXCoordinate, y: outsideTop))
        
        path.move(to: CGPoint(x: rightFirstXCoordinate, y: rightTopHighestArcYCoordinate))
        path.addLine(to: CGPoint(x: rightTopLowestArcXCoordinate, y: rightTopHighestArcYCoordinate))
        path.addArc(tangent1End: CGPoint(x: rightTopLowestXCoordinate, y: rightTopHighestArcYCoordinate), tangent2End: CGPoint(x: rightTopLowestXCoordinate, y: rightTopLowestArcYCoordinate), radius: innerArcRadius)
        path.addLine(to: CGPoint(x: rightTopLowestXCoordinate, y: leftBottomHighestArcYCoordinate))
        path.addArc(tangent1End: CGPoint(x: rightTopLowestXCoordinate, y: leftBottomLowestArcYCoordinate), tangent2End: CGPoint(x: rightTopLowestArcXCoordinate, y: leftBottomLowestArcYCoordinate), radius: innerArcRadius)
        path.addLine(to: CGPoint(x: leftBottomLowestArcXCoordinate, y: leftBottomLowestArcYCoordinate))
        path.addArc(tangent1End: CGPoint(x: leftBottomLowestXCoordinate, y: leftBottomLowestArcYCoordinate), tangent2End: CGPoint(x: leftBottomLowestXCoordinate, y: leftBottomHighestArcYCoordinate), radius: innerArcRadius)
        path.addLine(to: CGPoint(x: leftBottomLowestXCoordinate, y: rightTopLowestArcYCoordinate))
        path.addArc(tangent1End: CGPoint(x: leftBottomLowestXCoordinate, y:rightTopHighestArcYCoordinate), tangent2End: CGPoint(x: leftBottomLowestArcXCoordinate, y: rightTopHighestArcYCoordinate), radius: innerArcRadius)
        path.addLine(to: CGPoint(x: rightFirstXCoordinate, y: rightTopHighestArcYCoordinate))
        path.closeSubpath()
        
        return path
    
    }
    
}
