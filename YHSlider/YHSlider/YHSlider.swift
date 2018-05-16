//
//  YHSlider.swift
//  YHSlider
//
//  Created by baiwei－mac on 2018/5/15.
//  Copyright © 2018年 YuHua. All rights reserved.
//

import UIKit

class YHSlider: UIView {
    
    //圆弧上的数字
    var titleArray: Array<Int>?
    //当前数字
    var currentValue: Double? {
        didSet {
            setNeedsDisplay()
        }
    }
    //值改变后会调用该闭包
    var valueChange: ((Double)->())?
    
    //与x轴的角度
    var startAngle = Double.pi/4
    //圆弧宽度
    var sliderWidth: CGFloat = 20
    //圆弧颜色
    var sliderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    //圆弧滑过的颜色
    var sliderSlipColor = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
    //边框宽度
    var sliderBoardWidth: CGFloat = 2
    //边框颜色
    var sliderBoardColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    //圆弧上是否显示文字
    let isShowTitle = true
    //文字是否需要旋转
    let isRotate = true
    
    private var titleLabel: UILabel!
    private var lastPoint: CGPoint?
    
    override func draw(_ rect: CGRect) {
        //半径
        let radius = (frame.width-sliderWidth)/2-sliderBoardWidth
        //左端点
        let startPoint = getPoint(radius: Double(radius), angle: startAngle, quadrant: 0)
        //结束角度
        let endAngle = CGFloat(Double.pi-startAngle)
        //右端点
        let endPoint = CGPoint(x: frame.width-startPoint.x, y: startPoint.y)
        //中心点
        let sliderCenter = CGPoint(x: frame.width/2, y: frame.width/2)

        let ctx = UIGraphicsGetCurrentContext()!
        
        //圆弧边框
        ctx.setLineWidth(sliderBoardWidth)
        ctx.setStrokeColor(sliderBoardColor.cgColor)
        ctx.addArc(center: sliderCenter, radius: radius+sliderWidth/2, startAngle: CGFloat(startAngle), endAngle: endAngle, clockwise: true)
        ctx.addEllipse(in: CGRect(x: startPoint.x-sliderWidth/2, y: startPoint.y-sliderWidth/2, width: sliderWidth, height: sliderWidth))
        ctx.strokePath()
        ctx.addArc(center: sliderCenter, radius: radius-sliderWidth/2, startAngle: CGFloat(startAngle), endAngle: endAngle, clockwise: true)
        ctx.addEllipse(in: CGRect(x: endPoint.x-sliderWidth/2, y: endPoint.y-sliderWidth/2, width: sliderWidth, height: sliderWidth))
        ctx.strokePath()
        
        //圆弧
        ctx.addArc(center: sliderCenter, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
        ctx.setLineWidth(sliderWidth)
        ctx.setLineCap(.round)
        ctx.setStrokeColor(sliderColor.cgColor)
        ctx.strokePath()
        
        //当前值
        guard let titles = titleArray, let value = currentValue, Int(value) <= titles.last!, titles.first! <= Int(value) else {
            return
        }
        let angle = (Double.pi+2*startAngle)/Double(titles.count)
        let index = titles.index(of: Int(value))
        let valueEndAngle = angle*value.truncatingRemainder(dividingBy: 1)+angle*Double(index!)
        ctx.addArc(center: sliderCenter, radius: radius, startAngle: endAngle, endAngle: endAngle+CGFloat(valueEndAngle), clockwise: false)
        ctx.setStrokeColor(sliderSlipColor.cgColor)
        ctx.strokePath()
        
        let result = getPointAndRotate(value: value-Double(titles.first!), angle: angle, radius: radius, half: false)!
        titleLabel.center = result.0
        if isRotate {
            titleLabel.transform = CGAffineTransform(rotationAngle: CGFloat(result.1))
        }
    }
    
    //获得需要的点
    private func getPoint(radius: Double, angle: Double, quadrant: Int) -> CGPoint {
        let y = radius*sin(angle)
        let x = radius*cos(angle)
        switch quadrant {
        case 0:
            return CGPoint(x: Double(center.x)-x, y: Double(frame.width/2)+y)
        case 1:
            return CGPoint(x: Double(center.x)-x, y: Double(frame.width/2)-y)
        case 2:
            return CGPoint(x: Double(center.x)+x, y: Double(frame.width/2)-y)
        case 3:
            return CGPoint(x: Double(center.x)+x, y: Double(frame.width/2)+y)
        default:
            return CGPoint()
        }
    }
    
    private func getPointAndRotate(value: Double, angle: Double, radius: CGFloat, half: Bool) -> (CGPoint, Double)? {
        let mathAngle = startAngle-angle*value-(half ? (angle/2) : 0)
        switch mathAngle {
        case 0 ... startAngle:
            return (getPoint(radius: Double(radius), angle: mathAngle, quadrant: 0), -mathAngle-Double.pi/2)
        case -Double.pi/2 ..< 0:
            return (getPoint(radius: Double(radius), angle: -mathAngle, quadrant: 1), -Double.pi/2-mathAngle)
        case -Double.pi ..< -Double.pi/2:
            return (getPoint(radius: Double(radius), angle: Double.pi+mathAngle, quadrant: 2), Double.pi/2-Double.pi-mathAngle)
        case -Double.pi-startAngle ... -Double.pi:
            return (getPoint(radius: Double(radius), angle: -mathAngle-Double.pi, quadrant: 3), Double.pi/2-mathAngle-Double.pi)
        default:
            return nil
        }
    }
    
    //添加文字
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if !isShowTitle {
            return
        }
        guard let titles = titleArray, let value = currentValue, Int(value) <= titles.last! else {
            return
        }
        _ = subviews.map {$0.removeFromSuperview()}
        let angle = (Double.pi+2*startAngle)/Double(titles.count)
        let radius = (frame.width-sliderWidth)/2-sliderBoardWidth
        if let titles = titleArray {
            for (index, title) in titles.enumerated() {
                let result = getPointAndRotate(value: Double(index), angle: angle, radius: radius, half: true)
                addLabel(title: String(title), center: result!.0, rotate: result!.1)
            }
        }
        let titleResult = getPointAndRotate(value: value-Double(titles.first!), angle: angle, radius: radius, half: false)
        let lab = UILabel(frame: CGRect(x: titleResult!.0.x-13, y: titleResult!.0.y-13, width: 26, height: 26))
        lab.text = String(Int(value))
        lab.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        lab.textColor = .black
        lab.textAlignment = .center
        lab.backgroundColor = UIColor.white
        lab.layer.cornerRadius = 13
        lab.layer.borderWidth = 1
        lab.layer.masksToBounds = true
        lab.layer.borderColor = sliderBoardColor.cgColor
        titleLabel = lab
        addSubview(lab)
    }
    
    //文字
    private func addLabel(title: String, center: CGPoint, rotate: Double) {
        let lab = UILabel(frame: CGRect(x: center.x-10, y: center.y-10, width: 20, height: 20))
        lab.text = title
        lab.adjustsFontSizeToFitWidth = true
        lab.textAlignment = .center
        lab.textColor = .black
        if isRotate {
            lab.transform = CGAffineTransform(rotationAngle: CGFloat(rotate))
        }
        addSubview(lab)
    }
    
    private func checkInTitle(touches: Set<UITouch>) -> Bool {
        var point = touches.first?.location(in: self)
        point = titleLabel.layer.convert(point!, from: self.layer)
        if titleLabel.layer.contains(point!) {
            return true
        }
        return false
    }
    
    private func moveTitle(currentPoint: CGPoint) {
        guard let titles = titleArray, let value = currentValue, Int(value) <= titles.last! else {
            return
        }
        let total = Double.pi+2*startAngle
        let center = CGPoint(x: frame.width/2, y: frame.width/2)
        let xDis = currentPoint.x-center.x
        let yDis = currentPoint.y-center.y
        var angle = Double(atan(fabs(currentPoint.y-center.y)/fabs(currentPoint.x-center.x)))
        if xDis<0,yDis<0 {//4
            angle += startAngle
        }else if xDis>0,yDis<0 {//1
            angle = (startAngle+Double.pi-angle)
        }else if xDis>0,yDis>0 {//2
            angle += (startAngle+Double.pi)
        }else if xDis<0,yDis>0 {//3
            angle = startAngle-angle
        }else if xDis==0 {
            if yDis>0 {
            }else {
                angle = startAngle+Double.pi/2
            }
        }else if yDis==0 {
            if xDis>0 {
                angle = startAngle+Double.pi
            }else {
                angle = startAngle
            }
        }
        if angle <= 0, angle >= total {
            return
        }
        var newValue = (angle/total)*Double(titles.last!-titles.first!)+Double(titles.first!)
        newValue = newValue<Double(titles.first!) ? Double(titles.first!) : newValue
        newValue = newValue>Double(titles.last!+1) ? Double(titles.last!)+0.99 : newValue
        currentValue = newValue
        titleLabel.text = String(Int(currentValue!))
        if let change = valueChange {
            change(currentValue!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard checkInTitle(touches: touches) else {
            lastPoint = nil
            return
        }
        lastPoint = touches.first?.location(in: self)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard lastPoint != nil else {return}
        let point = touches.first?.location(in: self)
        moveTitle(currentPoint: point!)
        lastPoint = point
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard lastPoint != nil else {return}
        let point = touches.first?.location(in: self)
        moveTitle(currentPoint: point!)
        lastPoint = point
    }
}
