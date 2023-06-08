//
//  GameScene.swift
//  FlappyCloneSwiftUI
//
//  Created by Gerrit Zeissl on 04.06.23.
//

import SpriteKit

class GameScene: SKScene {
        
    // MARK: - Initialization
    private var bird : SKSpriteNode?
    private var ground : SKSpriteNode?
    private var ceiling : SKSpriteNode?
    private var scoreLabel : SKLabelNode?
    private var highscoreLabel : SKLabelNode?
    private var background : SKSpriteNode?
    // Score and Restart
    private var objTimer : Timer?
    private var yourScoreLabel : SKLabelNode?
    private var finalScoreLabel : SKLabelNode?
    private var restartButton : SKSpriteNode?
    private var isRunning : Bool!
    // Animation
    var birdAnimation : [SKTexture] = []
    // Score and variables for difficulty
    private var score : Int = 0
    private let duration = 4.5 // Time in seconds in which Objects go from right to left. Smaller value = faster movement
    private let respawn = 3.0 // Time in seconds in which new Objects spawn. Smaller value = faster respawn
    private let gapHeight = 150.0 // Gap between upper and lower Pipe
    private let safeArea = 50.0 // Safe area between upper and lower boundary
    // Collision Categories (according to Apple max. 32 Categories are possible, Bit Shifting is most efficient)
    private let noCategory : UInt32 = 0x1 << 0 // 1
    private let birdCategory : UInt32 = 0x1 << 1 // 2
    private let gapCategory : UInt32 = 0x1 << 2 // 4
    private let pipeCategory : UInt32 = 0x1 << 3 // 8
    private let groundAndCeilCategory : UInt32 = 0x1 << 4 // 16
    
    // MARK: - Did Move
    // Overwritten Methode, called once, when Scene is shown
    override func didMove(to view: SKView) {
        
        // Set the contact delegate to self (see extension below)
        physicsWorld.contactDelegate = self
        //physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        
        // Background
        background = SKSpriteNode(texture: SKTexture(imageNamed: "bg"))
        background?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background?.size.height = self.frame.height
        background?.zPosition = -1
        addChild(background!)
        
        // Bird
        bird = SKSpriteNode(texture: SKTexture(imageNamed: "flappy1"))
        bird?.size = CGSize(width: 60, height: 50)
        bird?.zPosition = 0
        bird?.name = "bird"
        bird?.physicsBody = SKPhysicsBody(rectangleOf: bird!.size)
        bird?.physicsBody?.categoryBitMask = birdCategory // own bitmask
        bird?.physicsBody?.contactTestBitMask = gapCategory | pipeCategory // check for contact and call delegate function didBegin
        bird?.physicsBody?.collisionBitMask = groundAndCeilCategory // check for collisions
        bird?.physicsBody?.isDynamic = true // is affected by physics
        bird?.physicsBody?.allowsRotation = false // does not rotate
        bird?.physicsBody?.pinned = false // is not pinned, so it can move
        bird?.physicsBody?.affectedByGravity = true // is affected by gravity
        bird?.physicsBody?.mass = 2.0 // own mass (kinda fat bird)
        // Animationen init
        for number in 1...2 {
            birdAnimation.append(SKTexture(imageNamed: "flappy\(number)"))
        }
        addChild(bird!) // Add bird to the canvas
        
        // Ground
        ground = SKSpriteNode(color: .red, size: CGSize(width: self.frame.width, height: 10))
        ground?.name = "ground"
        ground?.position = CGPoint(x: self.frame.midX, y: self.frame.minY - 5)
        ground?.zPosition = 0
        ground?.physicsBody = SKPhysicsBody(rectangleOf: ground!.size)
        ground?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ground?.physicsBody?.collisionBitMask = birdCategory
        ground?.physicsBody?.isDynamic = false
        ground?.physicsBody?.allowsRotation = false
        ground?.physicsBody?.pinned = true
        ground?.physicsBody?.affectedByGravity = false
        ground?.physicsBody?.mass = 2.0
        addChild(ground!)
        
        // Ceiling
        ceiling = SKSpriteNode(color: .red, size: CGSize(width: self.frame.width, height: 10))
        ceiling?.name = "ceiling"
        ceiling?.position = CGPoint(x: self.frame.midX, y: self.frame.maxY + 5)
        ceiling?.zPosition = 0
        ceiling?.physicsBody = SKPhysicsBody(rectangleOf: ceiling!.size)
        ceiling?.physicsBody?.categoryBitMask = groundAndCeilCategory
        ceiling?.physicsBody?.collisionBitMask = birdCategory
        ceiling?.physicsBody?.isDynamic = false
        ceiling?.physicsBody?.allowsRotation = false
        ceiling?.physicsBody?.pinned = true
        ceiling?.physicsBody?.affectedByGravity = false
        ceiling?.physicsBody?.mass = 2.0
        addChild(ceiling!)
        
        // Score Label
        scoreLabel = SKLabelNode(text: "Score:")
        scoreLabel?.position = CGPoint(x: self.frame.minX + 73, y: self.frame.maxY - 150)
        scoreLabel?.zPosition = 0
        addChild(scoreLabel!)
        
        // Highscore Label
        highscoreLabel = SKLabelNode(text: "Highscore:")
        highscoreLabel?.position = CGPoint(x: self.frame.minX + 100, y: self.frame.maxY - 100)
        highscoreLabel?.zPosition = 0
        addChild(highscoreLabel!)
        
        resetGame()
    }
    
    func createPipes() {
               
        // Helpers, to determie the right positions
        /* Level 1
        var screenSize = SKSpriteNode()
        screenSize.size = CGSize(width: self.size.width, height: self.size.height)
        screenSize.color = .green
        screenSize.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(screenSize)
       
        /* Level 2
        var pipeImg = SKSpriteNode(imageNamed: "pipe1")
        var pipe = SKSpriteNode()
        pipe.size = pipeImg.size
        pipe.color = .blue
        pipe.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        pipe.position.y += pipeImg.size.height / 2 + self.frame.height / 2 - safeArea
        self.addChild(pipe)
        
        var pipe2 = SKSpriteNode()
        pipe2.size = pipeImg.size
        pipe2.color = .blue
        pipe2.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        pipe2.position.y -= pipeImg.size.height / 2 + self.frame.height / 2 - safeArea
        self.addChild(pipe2)
        */
        
        var centerPoint = SKSpriteNode()
        centerPoint.size = CGSize(width: 10, height: 10)
        centerPoint.color = .red
        centerPoint.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(centerPoint)
        */
        
        let upperPipe = SKSpriteNode(imageNamed: "pipe1")
        upperPipe.xScale = 0.7
        upperPipe.name = "UpperPipe"
        upperPipe.physicsBody = SKPhysicsBody(rectangleOf: upperPipe.size)
        upperPipe.physicsBody?.categoryBitMask = pipeCategory
        upperPipe.physicsBody?.contactTestBitMask = birdCategory
        upperPipe.physicsBody?.collisionBitMask = noCategory
        upperPipe.physicsBody?.affectedByGravity = false
        
        let lowerPipe = SKSpriteNode(imageNamed: "pipe2")
        lowerPipe.xScale = 0.7
        lowerPipe.name = "LowerPipe"
        lowerPipe.physicsBody = SKPhysicsBody(rectangleOf: lowerPipe.size)
        lowerPipe.physicsBody?.categoryBitMask = pipeCategory
        lowerPipe.physicsBody?.contactTestBitMask = birdCategory
        lowerPipe.physicsBody?.collisionBitMask = noCategory
        lowerPipe.physicsBody?.affectedByGravity = false
        
        let gapNode = SKSpriteNode()
        gapNode.xScale = 0.7
        gapNode.name = "Gap"
        gapNode.size = CGSize(width: upperPipe.size.width / 2, height: gapHeight) // Gap should be smaller
        gapNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upperPipe.size.width / 2, height: gapHeight))
        gapNode.physicsBody?.categoryBitMask = gapCategory
        gapNode.physicsBody?.contactTestBitMask = birdCategory
        gapNode.physicsBody?.collisionBitMask = noCategory
        gapNode.physicsBody?.affectedByGravity = false
        //gapNode.color = .purple // Debug purposes
        
        //let objStartX = self.size.width / 2 + 100 // Debug purpose, set fix start point to check min/max level and size etc.
        let objStartX = self.frame.maxX + upperPipe.size.width / 2 // this is the final position, right out of the visible screen area
                
        let topPos = self.frame.midY + upperPipe.size.height / 2 + self.frame.height / 2 - safeArea
        let lowPos = self.frame.midY - lowerPipe.size.height / 2 - self.frame.height / 2 + safeArea + gapHeight + lowerPipe.size.height / 2 + upperPipe.size.height / 2

        // Test purpose, set pipe to most up or most down position
        //let upperY = topPos
        //let upperY = lowPos
        let upperY = CGFloat.random(in: lowPos...topPos) // in the final game the position is a random value between the lowest and highest position
        let gapY = upperY - upperPipe.size.height / 2 - gapHeight / 2
        let lowerY = gapY - gapHeight / 2 - lowerPipe.size.height / 2
        
        // Set the position of the pipes and the gap
        upperPipe.position = CGPoint(x: objStartX, y: upperY)
        lowerPipe.position = CGPoint(x: objStartX, y: lowerY)
        gapNode.position = CGPoint(x: objStartX + gapNode.size.width / 2, y: gapY)
        
        // Add them to the canvas
        addChild(upperPipe)
        addChild(lowerPipe)
        addChild(gapNode)
        
        // Set the end X positions
        let objEndX = -self.size.width / 2 - upperPipe.size.width / 2
        let upperEndX = CGPoint(x: objEndX, y: upperY)
        let gapEndX = CGPoint(x: objEndX + gapNode.size.width / 2, y: gapY)
        let lowerEndX = CGPoint(x: objEndX, y: lowerY)
        
        // Add the move action for the given duration
        let moveUpper = SKAction.move(to: upperEndX, duration: duration)
        let moveGap = SKAction.move(to: gapEndX, duration: duration)
        let moveLower = SKAction.move(to: lowerEndX, duration: duration)
        
        // Add the remove action
        let remove = SKAction.removeFromParent()
        
        // Run both actions on all pipes so the pipes move and then get removed
        upperPipe.run(SKAction.sequence([moveUpper, remove]))
        lowerPipe.run(SKAction.sequence([moveLower, remove]))
        gapNode.run(SKAction.sequence([moveGap, remove]))
    }
    
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // When the game is running while a touch occurs, apply a force to the bird in upward direction
        if isRunning {
            bird?.physicsBody?.applyForce(CGVector(dx: 0, dy: 70000))
            return
        }
        
        // Otherwise, check if the "play" button has been clicked and if yes, restart the game
        let touch = touches.first
        if let location = touch?.location(in: self) {
            
            let theNodes = nodes(at: location)
        
            for node in theNodes {
                if node.name == "play" {
                    resetGame()
                }
            }
        }
    }
    
    // MARK: - Game Over and restart
    func resetGame() {
        restartButton?.removeFromParent()
        yourScoreLabel?.removeFromParent()
        finalScoreLabel?.removeFromParent()
        score = 0
        scoreLabel?.text = "Score: 0"
        
        // Reload the highscore from the user defaults so if there was a new highscore, it will be displayed
        let high = UserDefaults.standard.object(forKey: "Highscore")
        if let highscore = high as? Int {
            highscoreLabel?.text = "Highscore: \(highscore)"
        } else {
            highscoreLabel?.text = "Highscore: 0"
        }
        
        // Set the game to running again, reset Animations/Positions and restart the Pipes
        isRunning = true
        bird?.run(SKAction.repeatForever(SKAction.animate(with: birdAnimation, timePerFrame: 0.09)))
        bird?.position = CGPoint(x: self.frame.midX - 100.0, y: self.frame.midY)
        self.startTimer()
    }
    
    // This method starts a Timer which fires every "respawn" seconds and calls createPipes method to spawn new Pipes
    func startTimer() {
        objTimer = Timer.scheduledTimer(withTimeInterval: respawn, repeats: true, block: { (timer) in
            self.createPipes()
        })
    }
    
    func gameOver() {
        
        // Then the game is over, stop pipes from spawning and bird from flying
        objTimer?.invalidate()
        bird?.removeAllActions()
        
        isRunning = false
        
        // Remove all pipes that are still in the game
        for child in children {
            if child.name == "LowerPipe" ||
                child.name == "UpperPipe" ||
                child.name == "Gap" {
                child.removeFromParent()
            }
        }
        
        // Show score and restart Button
        yourScoreLabel = SKLabelNode(text: "Your Score:")
        yourScoreLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 200)
        yourScoreLabel?.fontSize = 80
        yourScoreLabel?.zPosition = 1
        if yourScoreLabel != nil {
            addChild(yourScoreLabel!)
        }
        
        finalScoreLabel = SKLabelNode(text: "\(score)")
        finalScoreLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        finalScoreLabel?.fontSize = 150
        finalScoreLabel?.zPosition = 1
        if finalScoreLabel != nil {
            addChild(finalScoreLabel!)
        }
        
        // Press is already checked in the touchesBegan Method
        restartButton = SKSpriteNode(imageNamed: "play")
        restartButton?.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 200)
        restartButton?.name = "play"
        restartButton?.zPosition = 1
        restartButton?.size = CGSize(width: 200, height: 200)
        addChild(restartButton!)
        
        // Save highscore to the user defaults
        let high = UserDefaults.standard.object(forKey: "Highscore")
        if high == nil {
            UserDefaults.standard.set(score, forKey: "Highscore")
        } else if let highscore = high as? Int {
            if highscore < score {
                UserDefaults.standard.set(score, forKey: "Highscore")
            }
        }
    }
}

// MARK: - PhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
   
    // This method gets called by the delegate whenever a contact occurs (collisions won't trigger this method)
    func didBegin(_ contact: SKPhysicsContact) {
        
        // When the gap was hit, increase the score
        if contact.bodyA.categoryBitMask == gapCategory  ||
            contact.bodyB.categoryBitMask == gapCategory {
            score += 1
            self.scoreLabel?.text = "Score: \(score)"
        }
        
        // When a pipe was hit, game over
        if contact.bodyA.categoryBitMask == pipeCategory ||
            contact.bodyB.categoryBitMask == pipeCategory {
            gameOver()
        }
    }
}

