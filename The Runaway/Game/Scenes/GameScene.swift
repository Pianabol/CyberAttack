//
//  GameScene.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

// bu versiyona, game over eklendi, ve çalışırsa eğer restart modu geldi. hadi bakalım.
// bu versiyona skor eklendi, yüksek skor kayıt ediliyor. Yeni rekor, yeni yüksek rekor ve kayıtlı.

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    
    var player: PlayerNode?
    var scoreLabel: SKLabelNode!
    
    var isGameOver = false
    
    //SKOR DEĞİŞKENLERİ
    var score = 0
    {
        didSet
        {
            scoreLabel.text = "\(score)"
            // Skor değiştiği an ekrandaki yazıyı güncelle
        }
    }
    
    var lastUpdateTime: TimeInterval = 0
    var obstacleSpawnRate: TimeInterval = 1.5
    var timeSinceLastSpawn: TimeInterval = 0
    
    override func didMove(to view: SKView)
    {
        // Koordinat düzeltmesi
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = .black
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -12.0)
        
        createWalls()
        addPlayer()
        setupScoreLabel() // Skoru ekrana koyan fonksiyonu çağır
    }
    
    func setupScoreLabel()
    {
        scoreLabel = SKLabelNode(fontNamed: "Orbitron-Bold")
        scoreLabel.text = "0"
        scoreLabel.fontSize = 60
        scoreLabel.fontColor = .white.withAlphaComponent(0.5) // Hafif saydam olsun, göz yormasın
        
        scoreLabel.position = CGPoint(x: 0, y: self.size.height / 2 - 160) // ekranın en tepesinde olması sorun yarattı, biraz daha ortalıyoruz.
        scoreLabel.zPosition = 5 // Engellerin arkasında, arka planın önünde
        addChild(scoreLabel)
    }
    
    func createWalls()
    {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0.0
        self.physicsBody?.categoryBitMask = PhysicsCategories.ground
    }
    
    func addPlayer()
    {
        player = PlayerNode(width: 50)
        player?.position = CGPoint(x: -self.size.width / 3, y: 0)
        if let playerNode = player
        {
            addChild(playerNode)
        }
    }
    
    func spawnObstacle()
    {
        if isGameOver { return }
        
        let obstacleWidth: CGFloat = 40
        let obstacleHeight: CGFloat = 150 // Biraz daha uzattım zor olsun 100->120->150
        
        let obstacle = ObstacleNode(width: obstacleWidth, height: obstacleHeight)
        
        let startX = self.size.width / 2 + obstacleWidth
        let isTop = Bool.random()
        let yPos = isTop ? (self.size.height / 2 - obstacleHeight) : (-self.size.height / 2)
        
        obstacle.position = CGPoint(x: startX, y: yPos)
        addChild(obstacle)
        
        // HAREKET VE SKOR MANTIĞI
        let moveLeft = SKAction.moveBy(x: -(self.size.width + obstacleWidth * 2), y: 0, duration: 3.5)
        
        // Engel ekranı terk ettiğinde çalışacak kod bloğu:
        let scoreAction = SKAction.run
        {
            if !self.isGameOver {
                self.score += 1 // Skoru artır
                // Belki bir "bip" sesi çalarız burada ileride
            }
        }
        
        let remove = SKAction.removeFromParent()
        
        // Sırayla: Git -> Skoru Artır -> Kendini Yok Et
        obstacle.run(SKAction.sequence([moveLeft, scoreAction, remove]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if isGameOver
        {
            restartGame()
            return
        }
        
        physicsWorld.gravity.dy *= -1
        player?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: physicsWorld.gravity.dy * 2))
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == (PhysicsCategories.player | PhysicsCategories.obstacle)
        {
            triggerGameOver()
        }
    }
    
    func triggerGameOver()
    {
        if isGameOver { return }
        
        isGameOver = true
        
        player?.fillColor = .red
        self.enumerateChildNodes(withName: "Obstacle") { node, _ in
            node.removeAllActions()
        }
        player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        
        // --- HIGH SCORE KAYDETME ---
        // Telefon hafızasından eski rekoru çek
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        
        if score > highScore
        {
            // Yeni rekor! Hafızaya kaydet.
            UserDefaults.standard.set(score, forKey: "HighScore")
        }
        
        //  EKRANA YAZDIRMA
        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: 0, y: 50)
        gameOverLabel.zPosition = 10
        addChild(gameOverLabel)
        
        let scoreInfoLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        scoreInfoLabel.text = "Score: \(score)  •  Best: \(max(score, highScore))"
        scoreInfoLabel.fontSize = 25
        scoreInfoLabel.fontColor = .cyan // Neon mavisi
        scoreInfoLabel.position = CGPoint(x: 0, y: 0)
        scoreInfoLabel.zPosition = 10
        addChild(scoreInfoLabel)
        
        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 20
        restartLabel.fontColor = .yellow
        restartLabel.position = CGPoint(x: 0, y: -60)
        restartLabel.zPosition = 10
        restartLabel.run(SKAction.repeatForever(SKAction.sequence([SKAction.fadeOut(withDuration: 0.5), SKAction.fadeIn(withDuration: 0.5)]))) // Yanıp sönme efekti
        addChild(restartLabel)
    }
    
    func restartGame()
    {
        if let view = self.view
        {
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = self.scaleMode
            let transition = SKTransition.fade(withDuration: 0.5)
            view.presentScene(newScene, transition: transition)
        }
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if isGameOver { return }
        
        if lastUpdateTime == 0
        {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        timeSinceLastSpawn += deltaTime
        
        if timeSinceLastSpawn > obstacleSpawnRate {
            spawnObstacle()
            timeSinceLastSpawn = 0
            
            // Oyun ilerledikçe zorlaşabilir, şu aşamada gerek yok.
            // obstacleSpawnRate *= 0.98 // Her engel çıktığında süre %2 kısalsın
        }
    }
}
