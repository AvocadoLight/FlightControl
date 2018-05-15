//
//  SpaceNode.swift
//  FlightControl
//
//  Created by 駱光璽 on 2018/5/15.
//  Copyright © 2018年 Avocado. All rights reserved.
//

import Foundation
import SpriteKit

class SpaceNode: SKSpriteNode {
    
    var steps:[CGPoint] = []
    let pointsPerSecond:CGFloat = 80.0
    
    init(imageNamed name:String){
        
        let texture = SKTexture(imageNamed: name)
        super.init(texture: texture, color: UIColor(), size: texture.size())
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //clear matrix
    func arrayClear(){
        steps.removeAll(keepingCapacity: false)
    }
    
    //add one matrix data
    func arrayAdd(step:CGPoint){
        steps.append(step)
        print(step.x)
    }
    
    func move(timer:TimeInterval){
        
        let currentPosition = position
        var newPosition = position
        
        if steps.count > 0 {
            let targetPoint = steps[0]
            
            //1
            let offset = CGPoint(x: targetPoint.x - currentPosition.x, y: targetPoint.y - currentPosition.y)
            let length = Double(sqrtf(Float(offset.x * offset.x) + Float(offset.y * offset.y)))
            let direction = CGPoint(x:CGFloat(offset.x) / CGFloat(length), y: CGFloat(offset.y) / CGFloat(length))
            var velocity = CGPoint(x: direction.x * pointsPerSecond, y: direction.y * pointsPerSecond)
            
            //2
            newPosition = CGPoint(x:currentPosition.x + velocity.x * CGFloat(timer), y:currentPosition.y + velocity.y * CGFloat(timer))
            
            
            position = newPosition
            
            if frame.contains(targetPoint){
                steps.remove(at: 0)
            }
            
        }
    }
    
    func getPath()-> CGPath?{
        
        let ref = CGMutablePath()
        
        if self.steps.count>1 {
            
            for i in 0..<self.steps.count {
                
                let point = self.steps[i]
                
                if(i == 0){
                    
                    ref.move(to: CGPoint(x: point.x, y: point.y))
                    
                }else{
                    
                    ref.addLine(to: CGPoint(x: point.x, y: point.y))
                
                }
            }
            
        }else{
            
            return nil
        }
        
        return ref
        
    }

}

