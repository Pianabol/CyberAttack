//
//  GameScene.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player: PlayerNode?
    
    // Engellerin ne sıklıkla geleceğini takip eden zamanlayıcı
    var lastUpdateTime: TimeInterval = 0
    var obstacleSpawnRate: TimeInterval = 1.5 // Her 1.5 saniyede bir engel
    var timeSinceLastSpawn: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .black
        
        // Yerçekimi
        physicsWorld.gravity = CGVector(dx: 0, dy: -12.0) // Biraz hızlandırdım
        
        // Zemin ve Tavan (Duvarlar)
        createWalls()
        
        // Oyuncu
        addPlayer()
    }
    
    func createWalls() {
        // Alt ve Üst sınırları fiziksel duvar yapıyoruz
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.friction = 0.0
    }
    
    func addPlayer() {
        player = PlayerNode(width: 50)
        // Oyuncuyu biraz daha sola alalım ki engelleri görebilsin
        player?.position = CGPoint(x: -self.size.width / 3, y: 0)
        if let playerNode = player {
            addChild(playerNode)
        }
    }
    
    func spawnObstacle() {
        // Rastgele yükseklik belirleme (Ya tavan ya zemin)
        // Basit tutalım: Şimdilik sadece zeminden çıkan engeller yapalım.
        
        let obstacleWidth: CGFloat = 40
        let obstacleHeight: CGFloat = 100 // Uzun çubuklar
        
        let obstacle = ObstacleNode(width: obstacleWidth, height: obstacleHeight)
        
        // Başlangıç pozisyonu: Ekranın en sağı (ekran dışı)
        let startX = self.size.width / 2 + obstacleWidth
        
        // Rastgele: Ya tavanda olsun ya zeminde
        let isTop = Bool.random()
        let yPos = isTop ? (self.size.height / 2 - obstacleHeight) : (-self.size.height / 2)
        
        obstacle.position = CGPoint(x: startX, y: yPos)
        addChild(obstacle)
        
        // HAREKET: Sağa koyduk, sola doğru kaysın
        // duration: 4.0 saniye (Ne kadar küçükse o kadar hızlı gelir)
        let moveLeft = SKAction.moveBy(x: -(self.size.width + obstacleWidth * 2), y: 0, duration: 4.0)
        let remove = SKAction.removeFromParent() // Ekrandan çıkınca sil (hafıza dolmasın)
        
        obstacle.run(SKAction.sequence([moveLeft, remove]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        physicsWorld.gravity.dy *= -1
        player?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: physicsWorld.gravity.dy * 2))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Zamanlayıcı Mantığı:
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        timeSinceLastSpawn += deltaTime
        
        // Eğer süre dolduysa yeni engel at
        if timeSinceLastSpawn > obstacleSpawnRate {
            spawnObstacle()
            timeSinceLastSpawn = 0
        }
    }
}
