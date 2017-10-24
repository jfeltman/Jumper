//
//  GameScene.swift
//  Jumper
//
//  Created by Josh Feltman on 10/19/17.
//  Copyright © 2017 Josh Feltman. All rights reserved.
//

import SpriteKit
import GameplayKit


enum GameState {
    case introLogo
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode()
    var obstacle = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    
    var logo: SKSpriteNode!
    var gameOver: SKSpriteNode!
    var gameState = GameState.introLogo
    
    override func didMove(to view: SKView) {
        
        backgroundColor = UIColor.black
        
        createPlayer()
        createGround()
        //startObstacles()
        createScore()
        createLogos()
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self
        
    }
    
    func createPlayer() {
        
        let playerTexture = SKTexture(imageNamed: "player")
        player = SKSpriteNode(imageNamed: "player")
        player.size = CGSize(width: 30, height: 30)
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.4)
        player.zPosition = 10
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: player.size)
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask
        player.physicsBody?.isDynamic = false
        
        //player.physicsBody?.collisonBitMask = 0
        
        addChild(player)
        
    }
    
    func createGround() {
        let groundLine = SKSpriteNode(color: UIColor.white, size: CGSize(width: size.width * 2, height: 5))
        groundLine.position = CGPoint(x: 0, y: size.height * 0.37)
        
        groundLine.physicsBody = SKPhysicsBody(rectangleOf: groundLine.size)
        groundLine.physicsBody?.isDynamic = false
        
        addChild(groundLine)
    }
    
    func createObstacles() {
        obstacle = SKSpriteNode(color: UIColor.white, size: CGSize(width: 10, height: 30))
        obstacle.zPosition = -20
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.name = "obstacle"
        
        /*
        let obstacleCollison = SKSpriteNode(color: UIColor.red, size: CGSize(width: 20, height: frame.height))
        obstacleCollison.name = "scoreDetect"
        obstacleCollison.physicsBody = SKPhysicsBody(rectangleOf: obstacleCollison.size)
        obstacleCollison.physicsBody?.isDynamic = false
        */
        let xPosition = frame.width + obstacle.frame.width
        //let endPosition = frame.width + (obstacle.frame.width * 2)
        
        addChild(obstacle)
        //addChild(obstacleCollison)
        
        obstacle.position = CGPoint(x: xPosition, y: size.height * 0.39)
        //obstacleCollison.position = CGPoint(x: 5 + xPosition + (obstacle.size.width * 2), y: frame.midY)
        
        let randDuration = random(min: CGFloat(1), max: CGFloat(1.5))
        let actionMove = SKAction.moveTo(x: -1, duration: TimeInterval(randDuration))
        let actionMoveDone = SKAction.removeFromParent()
        let moveSequence = SKAction.sequence([actionMove, actionMoveDone])
        
        obstacle.run(moveSequence,
                     completion: {
                        self.score += 1
        })
        
    }
    
    func startObstacles() {
        let create = SKAction.run {[unowned self] in
            self.createObstacles()
        }
        
        let wait = SKAction.wait(forDuration: 1.5)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever, withKey: "startObstacles")
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.white
        
        addChild(scoreLabel)
    }
    
    func createLogos() {
        logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        logo.zPosition = 20
        addChild(logo)
        
        gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.alpha = 0
        addChild(gameOver)
        
    }
    
    func stopObstacles() {
        obstacle.removeAction(forKey: "startObstacles")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .introLogo:
            gameState = .playing
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run {[unowned self] in
                self.player.physicsBody?.isDynamic = true
                self.startObstacles()
            }
            
            let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
            logo.run(sequence, withKey: "start")
            
        case .playing:
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
            
        case .dead:
            let scene = GameScene(size: size)
            let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
            self.view?.presentScene(scene, transition: transition)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "obstacle" || contact.bodyB.node?.name == "obstacle" {
            
            gameOver.alpha = 1
            gameState = .dead
        
            contact.bodyB.node?.removeFromParent()
            contact.bodyA.node?.removeFromParent()
            
            removeAllActions()
            
            return
        }
 
    }
    
    
    override func update(_ currentTime: TimeInterval) {
    }
}
