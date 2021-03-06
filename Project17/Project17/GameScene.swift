//
//  GameScene.swift
//  Project17
//
//  Created by Emin Roblack on 4/4/19.
//  Copyright © 2019 Emin Roblack. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    
    var enemyCounter = 0
    var timerValue = 1.0
    
    var score = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starField = SKEmitterNode(fileNamed: "Starfield")!
        starField.position = CGPoint(x: 1024, y: 384)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        score = 0
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func createEnemy(){
        enemyCounter += 1
        
        guard let enemy = possibleEnemies.randomElement() else {return}
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping = 0
        sprite.physicsBody?.angularDamping = 0
        
        // Increasing difficulty
        if enemyCounter == 20 {
            timerValue -= 0.1
            enemyCounter = 0
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        } else {
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
        //-----------------------------------------------------------------------------------------
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300{
            node.removeFromParent()
            }
        }
        if !isGameOver {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        player.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {return}
//        let location = touch.location(in: self)
        player.position = player.position
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        player.removeFromParent()
        gameTimer?.invalidate()
        isGameOver = true
    }
    
}
