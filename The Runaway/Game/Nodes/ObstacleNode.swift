//
//  ObstacleNode.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

import Foundation
import SpriteKit

// DİKKAT: Artık SKShapeNode değil, SKSpriteNode kullanıyoruz!
class ObstacleNode: SKSpriteNode {
    
    init(imageNamed: String, width: CGFloat, height: CGFloat) {
        let texture = SKTexture(imageNamed: imageNamed)
        let size = CGSize(width: width, height: height)
        
        // Görseli başlat
        super.init(texture: texture, color: .clear, size: size)
        
        // --- DEĞİŞİKLİK BURADA ---
                // Görsel boyutu (size) yerine, daha küçük bir fiziksel boyut tanımlıyoruz.
                // Genişliği %40, yüksekliği %10 kırpıyoruz ki "ucundan" çarpmasın.
                let hitboxSize = CGSize(width: width * 0.6, height: height * 0.9)
                
                self.physicsBody = SKPhysicsBody(rectangleOf: hitboxSize)
        
        // Fizik Ayarları (Aynen kalıyor, dikdörtgen)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false // Çivi gibi çakılı
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 0.0
        
        self.physicsBody?.categoryBitMask = PhysicsCategories.obstacle
        self.physicsBody?.collisionBitMask = PhysicsCategories.none
        self.physicsBody?.contactTestBitMask = PhysicsCategories.player
        
        self.name = "Obstacle"
        self.zPosition = 1 // Arka planın önünde, oyuncunun arkasında
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
