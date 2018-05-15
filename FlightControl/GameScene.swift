//
//  GameScene.swift
//  FlightControl
//
//  Created by 駱光璽 on 2018/5/15.
//  Copyright © 2018年 Avocado. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let myLabel = SKLabelNode(fontNamed: "Chalkduster")
    let myScore = SKLabelNode(fontNamed: "Chalkduster")
    let restart = SKLabelNode(fontNamed: "Chalkduster")
   
    var fly:SKSpriteNode = SKSpriteNode()
    var currentSpace:SpaceNode?
    var timer:CFTimeInterval = 0
    var lastUpdateTime:CFTimeInterval = 0.0
    var score:Int = 0
    var gameStatus = 0 //0 遊戲中 //1 結束
    
    let spaceCat:UInt32 = 1 << 0
    let parkingCat:UInt32 = 1 << 1
    
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        physicsWorld.contactDelegate = self
        
        //game Over
        myLabel.text = ""
        myLabel.fontSize = 65
        myLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(myLabel)
        
        
        //score
        myScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        myScore.text = "\(self.score)"
        myScore.fontSize = 50;
        myScore.fontColor = UIColor(red: 1/255, green: 1/255, blue: 1/255, alpha: 150/255)
        myScore.position = CGPoint(x: 10, y: 150)
        addChild(myScore)
        
        //restart
        restart.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        restart.text = "重新開始"
        restart.name = "restart"
        restart.fontSize = 20
        restart.fontColor = UIColor(red: 1/255, green: 1/255, blue: 1/255, alpha: 150/255)
        restart.position = CGPoint(x: -350, y: 180)
        addChild(restart)
        
        
        //background
        var bg = SKSpriteNode(imageNamed: "game_bg.jpg")
        bg.zPosition = -1
        bg.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(bg)
        
        //goal
        var parking = SKSpriteNode(imageNamed: "parking.png")
        parking.zPosition = 0
        parking.position = CGPoint(x: frame.maxX - parking.size.width, y: -225)
        addChild(parking)
        parking.physicsBody = SKPhysicsBody(circleOfRadius: parking.size.width/2.0)
        parking.physicsBody?.categoryBitMask = parkingCat
        parking.physicsBody?.contactTestBitMask = spaceCat
        parking.physicsBody?.collisionBitMask = 0
        
        //main object
//        objFly()
        objSpace()
        
    }
    
    //main object
    func objFly(){
        
        var fly1 = SKTexture(imageNamed: "space1.png")
        var fly2 = SKTexture(imageNamed: "space2.png")
        
        let ani1 = SKAction.animate(with: [fly1,fly2], timePerFrame: 0.25)
        
        let ani2 = SKAction.repeatForever(ani1)
        
        fly = SKSpriteNode(texture: fly1)
        fly.run(ani2)
        fly.zPosition = 2
        fly.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(fly)
        
    }
    
    func objSpace(){
        
        if gameStatus == 0 {
            let space = SpaceNode(imageNamed: "space1.png")
            space.position = CGPoint(x: Int(arc4random_uniform(300)), y: Int(arc4random_uniform(125)))
            space.name = "space"
            space.size = CGSize(width: space.size.width/2 , height: space.size.height/2)
            addChild(space)
            space.physicsBody = SKPhysicsBody(circleOfRadius: space.size.width/2.0)
            space.physicsBody?.categoryBitMask = spaceCat
            space.physicsBody?.contactTestBitMask = spaceCat | parkingCat
            space.physicsBody?.collisionBitMask = 0
            
            
            var ani1 = SKAction.run {
                self.objSpace()
            }
            
            var ani2 = SKAction.sequence([SKAction.wait(forDuration: 5),ani1])
            
            run(ani2)
            
            
        }
        
        
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        
        print("撞")
        let con1 = contact.bodyA.node
        let con2 = contact.bodyB.node
        let collision = con1!.physicsBody!.categoryBitMask | con2!.physicsBody!.categoryBitMask
        
        if collision == spaceCat {
            print("撞到啦")
            
            myLabel.text = "Game Over"
            
        }else if collision == spaceCat | parkingCat{
            
            self.score = self.score + 1
            myScore.text = "\(self.score)"
            
            if con1!.physicsBody!.categoryBitMask == spaceCat {
                con1?.removeFromParent()
            }
            if con2!.physicsBody!.categoryBitMask == spaceCat {
                con2?.removeFromParent()
            }
            
        }
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStatus == 0 {
            if let touch = touches.first {
                
                let location: CGPoint = touch.location(in: self)
                
                let node = scene?.atPoint(location)
                
                if node?.name == "space" {
                    
                    let space = node as! SpaceNode
                    space.arrayClear()
                    space.arrayAdd(step: location)
                    currentSpace = space
                }
                
                if node?.name == "restart" {
                    
                    if let view = self.view {
                        // Load the SKScene from 'GameScene.sks'
                        if let scene = SKScene(fileNamed: "GameScene") {
                            // Set the scale mode to scale to fit the window
                            scene.scaleMode = .aspectFill
                            
                            // Present the scene
                            view.presentScene(scene)
                        }

                    }
                
                }
                
            }
            
        }

        

        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStatus == 0 {
            if let touch = touches.first {
                let location: CGPoint = touch.location(in: self)
                
                if let node = currentSpace {
                    node.arrayAdd(step: location)
                }
            }
        }
        
        
        
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStatus == 0 {
            currentSpace = nil
        }
        
        
        
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: CFTimeInterval) {
        
        self.timer = currentTime - self.lastUpdateTime
        self.lastUpdateTime = currentTime
        
        enumerateChildNodes(withName: "space") { (node, stop) in
            let space = node as! SpaceNode
            space.move(timer: self.timer)
        }
        
        funcLine()

    }
    
    
    //draw line
    func funcLine(){
        
        //delete old line
        enumerateChildNodes(withName: "line") { (node, stop) in
            node.removeFromParent()
        }
        
        //make new line
        enumerateChildNodes(withName: "space") { (node, stop) in
            let space = node as! SpaceNode
            let shapeNode = SKShapeNode()
            shapeNode.path = space.getPath()
            shapeNode.name = "line"
            shapeNode.strokeColor = UIColor.red
            shapeNode.lineWidth = 2
            shapeNode.zPosition = 10
            self.addChild(shapeNode)
            
        }
    }
    
    
}




