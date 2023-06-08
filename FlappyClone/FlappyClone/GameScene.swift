//
//  GameScene.swift
//  FlappyClone
//
//  Created by Gerrit Zeissl on 30.05.23.
//

import SpriteKit
//import GameplayKit

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
    // Score und Variablen für Schwierigkeit
    private var score : Int?
    private let duration = 4.5 // Zeit in Sekunden, die Object von rechts nach links braucht. weniger = schneller
    private let respawn = 3.0 // Zeit in Sekunden, in der neues Object spawnt. Je weniger, desto schneller
    private let moveSpeed = 150.0 // Zeit zur Bemessung für Geschwindigkeit der Objekte
    private let gapHeight = 200.0 // Abstand zwischen den Röhren
    private let safeArea = 100.0 // Sicherheitsabstand oben und unten
    // Kollisions Kategorien
    // Laut Apple nur 32 Kategorien möglich und am effektivsten mit Bitmuster
    private let noCategory : UInt32 = 0x1 << 0
    private let birdCategory : UInt32 = 0x1 << 1
    private let gapCategory : UInt32 = 0x1 << 2
    private let pipeCategory : UInt32 = 0x1 << 3
    private let groundAndCeilCategory : UInt32 = 0x1 << 4
    
    // MARK: - Did Move
    override func didMove(to view: SKView) {
        
        // 1x aufgerufen direkt nachdem szene angezeigt wird
        physicsWorld.contactDelegate = self
        
        // Hintergrund
        background = SKSpriteNode(texture: SKTexture(imageNamed: "bg"))
        background?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background?.size.height = self.frame.height
        background?.zPosition = -1
        addChild(background!)
        
        // Bird
        bird = childNode(withName: "Bird") as? SKSpriteNode
        bird?.physicsBody?.categoryBitMask = birdCategory // eigene Bitmask
        bird?.physicsBody?.contactTestBitMask = gapCategory | pipeCategory // Wenn Berührung -> Meldung
        bird?.physicsBody?.collisionBitMask = groundAndCeilCategory // Mit wem Kollision stattfinden kann
        bird?.physicsBody?.node?.name = "bird"
        
        // Animationen init
        for number in 1...2 {
            birdAnimation.append(SKTexture(imageNamed: "flappy\(number)"))
        }
        
        
        self.ground = childNode(withName: "Ground") as? SKSpriteNode
        self.ceiling = childNode(withName: "Ceiling") as? SKSpriteNode
        
        self.ground?.physicsBody?.categoryBitMask = groundAndCeilCategory
        self.ceiling?.physicsBody?.categoryBitMask = groundAndCeilCategory
        
        self.ground?.physicsBody?.collisionBitMask = birdCategory
        self.ceiling?.physicsBody?.collisionBitMask = birdCategory
        
        self.scoreLabel = childNode(withName: "Score") as? SKLabelNode
        self.highscoreLabel = childNode(withName: "Highscore") as? SKLabelNode
        
        resetGame()
    }
    
    func createPipes() {
               
        /*var screenSize = SKSpriteNode()
        screenSize.size = CGSize(width: self.size.width, height: self.size.height)
        screenSize.color = .green
        screenSize.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(screenSize)
       
        /*let safeArea = 100.0
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
        self.addChild(pipe2)*/
        
        var centerPoint = SKSpriteNode()
        centerPoint.size = CGSize(width: 10, height: 10)
        centerPoint.color = .red
        centerPoint.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(centerPoint)*/
        
        let upperPipe = SKSpriteNode(imageNamed: "pipe1")
        let lowerPipe = SKSpriteNode(imageNamed: "pipe2")
        let gapNode = SKSpriteNode()
        
        upperPipe.physicsBody = SKPhysicsBody(rectangleOf: upperPipe.size)
        upperPipe.physicsBody?.categoryBitMask = pipeCategory
        upperPipe.physicsBody?.contactTestBitMask = birdCategory
        upperPipe.physicsBody?.collisionBitMask = noCategory
        upperPipe.physicsBody?.affectedByGravity = false
        upperPipe.physicsBody?.node?.name = "UpperPipe"
        upperPipe.name = "UpperPipe"
        
        lowerPipe.physicsBody = SKPhysicsBody(rectangleOf: lowerPipe.size)
        lowerPipe.physicsBody?.categoryBitMask = pipeCategory
        lowerPipe.physicsBody?.contactTestBitMask = birdCategory
        lowerPipe.physicsBody?.collisionBitMask = noCategory
        lowerPipe.physicsBody?.affectedByGravity = false
        lowerPipe.physicsBody?.node?.name = "LowerPipe"
        lowerPipe.name = "LowerPipe"
        
        gapNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upperPipe.size.width / 2, height: gapHeight))
        gapNode.physicsBody?.categoryBitMask = gapCategory
        gapNode.physicsBody?.contactTestBitMask = birdCategory
        gapNode.physicsBody?.collisionBitMask = noCategory
        gapNode.physicsBody?.affectedByGravity = false
        gapNode.physicsBody?.node?.name = "Gap"
        gapNode.name = "Gap"
        gapNode.size = CGSize(width: upperPipe.size.width / 2, height: gapHeight)
        //gapNode.color = .purple
        
        //let objStartX = 150.0
        let objStartX = self.size.width / 2 + upperPipe.size.width / 2
                
        let topPos = self.frame.midY + upperPipe.size.height / 2 + self.frame.height / 2 - safeArea
        let lowPos = self.frame.midY - lowerPipe.size.height / 2 - self.frame.height / 2 + safeArea + gapHeight + lowerPipe.size.height / 2 + upperPipe.size.height / 2

        //let upperY = topPos
        //let upperY = lowPos
        let upperY = CGFloat.random(in: lowPos...topPos)
        let gapY = upperY - upperPipe.size.height / 2 - gapHeight / 2
        let lowerY = gapY - gapHeight / 2 - lowerPipe.size.height / 2
        
        upperPipe.position = CGPoint(x: objStartX, y: upperY)
        lowerPipe.position = CGPoint(x: objStartX, y: lowerY)
        gapNode.position = CGPoint(x: objStartX + gapNode.size.width / 2, y: gapY)
        
        self.addChild(upperPipe)
        self.addChild(lowerPipe)
        self.addChild(gapNode)
        
        let objEndX = -self.size.width / 2 - upperPipe.size.width / 2
        let upperEndX = CGPoint(x: objEndX, y: upperY)
        let gapEndX = CGPoint(x: objEndX + gapNode.size.width / 2, y: gapY)
        let lowerEndX = CGPoint(x: objEndX, y: lowerY)
        
        let moveUpper = SKAction.move(to: upperEndX, duration: duration)
        let moveGap = SKAction.move(to: gapEndX, duration: duration)
        let moveLower = SKAction.move(to: lowerEndX, duration: duration)
        
        let remove = SKAction.removeFromParent() // Aus Szene entfernen
        
        upperPipe.run(SKAction.sequence([moveUpper, remove]))
        lowerPipe.run(SKAction.sequence([moveLower, remove]))
        gapNode.run(SKAction.sequence([moveGap, remove]))
    }
    
    
    
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isRunning {
            bird?.physicsBody?.applyForce(CGVector(dx: 0, dy: 70000))
            return
        }
        
        // Schauen ob play Button gedrückt wurde...
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
        self.restartButton?.removeFromParent()
        self.yourScoreLabel?.removeFromParent()
        self.finalScoreLabel?.removeFromParent()
        self.score = 0
        self.scoreLabel?.text = "Score: 0"
        
        // Highscore laden
        let high = UserDefaults.standard.object(forKey: "Highscore")
        if let highscore = high as? Int {
            self.highscoreLabel?.text = "Highscore: \(highscore)"
        } else {
            self.highscoreLabel?.text = "Highscore: 0"
        }
        
        self.isRunning = true
        self.bird?.run(SKAction.repeatForever(SKAction.animate(with: birdAnimation, timePerFrame: 0.09)))
        self.bird?.position = CGPoint(x: self.frame.midX - 180.0, y: self.frame.midY)
        self.startTimer()
    }
    
    func startTimer() {
        objTimer = Timer.scheduledTimer(withTimeInterval: respawn, repeats: true, block: { (timer) in
            self.createPipes()
        })
    }
    
    func gameOver() {
        
        objTimer?.invalidate()
        self.bird?.removeAllActions()
        
        isRunning = false
        
        for child in children {
            if child.name == "LowerPipe" ||
                child.name == "UpperPipe" ||
                child.name == "Gap" {
                child.removeFromParent()
            }
        }
        
        yourScoreLabel = SKLabelNode(text: "Your Score:")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 100
        yourScoreLabel?.zPosition = 1
        if yourScoreLabel != nil {
            self.addChild(yourScoreLabel!)
        }
        
        if score == nil {
            score = 0
        }
        finalScoreLabel = SKLabelNode(text: String(score!))
        finalScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalScoreLabel?.fontSize = 200
        finalScoreLabel?.zPosition = 1
        if finalScoreLabel != nil {
            self.addChild(finalScoreLabel!)
        }
        
        restartButton = SKSpriteNode(imageNamed: "play")
        restartButton?.position = CGPoint(x: 0, y: -200)
        restartButton?.name = "play"
        restartButton?.zPosition = 1
        self.addChild(restartButton!)
        // Press Methode oben bei touchesBegan
        
        // Highscore speichern
        let high = UserDefaults.standard.object(forKey: "Highscore")
        if high == nil {
            UserDefaults.standard.set(score, forKey: "Highscore")
        } else if let highscore = high as? Int {
            if highscore < score! {
                UserDefaults.standard.set(score, forKey: "Highscore")
            }
        }
    }
}

// MARK: - PhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
   
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == gapCategory {
            if score == nil {
                score = 0
            }
            
            score! += 1
            self.scoreLabel?.text = "Score: \(score!)"
        }
        
        if contact.bodyB.categoryBitMask == gapCategory {
            if score == nil {
                score = 0
            }
            
            score! += 1
            self.scoreLabel?.text = "Score: \(score!)"
        }
        
        if contact.bodyA.categoryBitMask == pipeCategory {
            gameOver()
        }
        
        if contact.bodyB.categoryBitMask == pipeCategory {
            gameOver()
        }
    }
}
