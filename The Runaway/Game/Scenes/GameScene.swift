//
//  GameScene.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

// bu versiyona, game over eklendi, ve çalışırsa eğer restart modu geldi. hadi bakalım.
// bu versiyona skor eklendi, yüksek skor kayıt ediliyor. Yeni rekor, yeni yüksek rekor ve kayıtlı.
// arka plan ve engellere görsel eklendi, ayrıca karakterimiz için bir icon getirildi.

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: PlayerNode?
    var scoreLabel: SKLabelNode!
    var background: SKSpriteNode! // Arka planı tutacak değişken
    
    var isGameOver = false
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    
    var lastUpdateTime: TimeInterval = 0
    var obstacleSpawnRate: TimeInterval = 1.5
    var timeSinceLastSpawn: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // Siyah arka plan satırını sildik!
        
        createBackground() // YENİ: Arka plan görselini ekle
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -12.0)
        
        createWalls()
        addPlayer()
        setupScoreLabel()
    }
    
    func createBackground() {
        // YENİ FONKSİYON: Arka plan görselini yükle
        background = SKSpriteNode(imageNamed: "bg_cyber")
        // Görselin sahneyi tamamen kaplamasını sağla (Aspect Fill gibi)
        background.size = self.size
        background.aspectFillToSize(fillSize: self.size)
        background.position = CGPoint.zero // Tam ortaya koy
        background.zPosition = -10 // Her şeyin en arkasında dursun
        addChild(background)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Orbitron-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = .white.withAlphaComponent(0.8) // Biraz daha belirgin yaptım
        scoreLabel.position = CGPoint(x: 0, y: self.size.height / 2 - 160) // Çentik altı
        scoreLabel.zPosition = 5
        addChild(scoreLabel)
    }
    
    func createWalls() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0.0
        self.physicsBody?.categoryBitMask = PhysicsCategories.ground
    }
    
    func addPlayer()
    {
            // Virüsün genişliğini 100 yaptık, artık kocaman ve net görünecek
            player = PlayerNode(imageNamed: "virus_player", width: 100)
            
            // Konumunu biraz daha yukarı alalım (y: -100) ki zemine tam otursun
            player?.position = CGPoint(x: -self.size.width / 3, y: -100)
            
            if let playerNode = player {
                addChild(playerNode)
            }
        }
    
    func spawnObstacle() {
            if isGameOver { return }
            
            // Kristal engelleri de büyütelim
            let obstacleWidth: CGFloat = 70
            let obstacleHeight: CGFloat = 200 // Boyunu uzattık
            
            let obstacle = ObstacleNode(imageNamed: "obstacle_crystal", width: obstacleWidth, height: obstacleHeight)
            
            let startX = self.size.width / 2 + obstacleWidth
            
            // Zemin veya Tavan hesabı (Oyuncuyu yukarı aldığımız için bunu da ayarladık)
            let isTop = Bool.random()
            let yPos = isTop ? (self.size.height / 2 - obstacleHeight/2 - 50) : (-self.size.height / 2 + obstacleHeight/2 + 100)
            
            obstacle.position = CGPoint(x: startX, y: yPos)
            addChild(obstacle)
            
            let moveLeft = SKAction.moveBy(x: -(self.size.width + obstacleWidth * 2), y: 0, duration: 3.0)
            
            let scoreAction = SKAction.run {
                if !self.isGameOver { self.score += 1 }
            }
            
            let remove = SKAction.removeFromParent()
            obstacle.run(SKAction.sequence([moveLeft, scoreAction, remove]))
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
            return
        }
        
        // YENİ: Arka Plan Parlaklık Efekti!
        // Arka planı anlık olarak beyaza boyayıp (parlatıp) geri eski haline döndürür.
        let flashUp = SKAction.colorize(with: .white, colorBlendFactor: 0.3, duration: 0.05)
        let flashDown = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.05)
        background.run(SKAction.sequence([flashUp, flashDown]))
        
        physicsWorld.gravity.dy *= -1
        player?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: physicsWorld.gravity.dy * 2))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == (PhysicsCategories.player | PhysicsCategories.obstacle) {
            triggerGameOver()
        }
    }
    
    func triggerGameOver() {
        if isGameOver { return }
        isGameOver = true
        
        player?.color = .red // Görsellerde fillColor yerine color kullanılır
        player?.colorBlendFactor = 0.8 // Kırmızı efektini uygula
        
        self.enumerateChildNodes(withName: "Obstacle") { node, _ in
            node.removeAllActions()
        }
        player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
        
        let gameOverLabel = SKLabelNode(fontNamed: "Orbitron-Bold")
        gameOverLabel.text = "SYSTEM FAILURE" // Temaya uygun "Sistem Hatası"
        gameOverLabel.fontSize = 45
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: 0, y: 50)
        gameOverLabel.zPosition = 10
        addChild(gameOverLabel)
        
        let scoreInfoLabel = SKLabelNode(fontNamed: "Orbitron-Regular")
        scoreInfoLabel.text = "Data Stolen: \(score)  •  Best: \(max(score, highScore))"
        scoreInfoLabel.fontSize = 20
        scoreInfoLabel.fontColor = .cyan
        scoreInfoLabel.position = CGPoint(x: 0, y: 0)
        scoreInfoLabel.zPosition = 10
        addChild(scoreInfoLabel)
        
        let restartLabel = SKLabelNode(fontNamed: "Orbitron-Regular")
        restartLabel.text = "Tap to Reboot" // Temaya uygun "Yeniden Başlat"
        restartLabel.fontSize = 25
        restartLabel.fontColor = .yellow
        restartLabel.position = CGPoint(x: 0, y: -60)
        restartLabel.zPosition = 10
        restartLabel.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.fadeIn(withDuration: 0.5)])))
        addChild(restartLabel)
    }
    
    func restartGame() {
        if let view = self.view {
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            let transition = SKTransition.fade(withDuration: 0.5)
            view.presentScene(newScene, transition: transition)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameOver { return }
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        timeSinceLastSpawn += deltaTime
        if timeSinceLastSpawn > obstacleSpawnRate {
            spawnObstacle()
            timeSinceLastSpawn = 0
        }
    }
}
// Yardımcı bir eklenti: Görseli bozmadan sahneye sığdırmak için
extension SKSpriteNode {
    func aspectFillToSize(fillSize: CGSize) {
        if let texture = self.texture {
            self.size = texture.size()
            let verticalRatio = fillSize.height / self.texture!.size().height
            let horizontalRatio = fillSize.width / self.texture!.size().width
            let scaleRatio = max(verticalRatio, horizontalRatio)
            self.setScale(scaleRatio)
        }
    }
}
