//
//  PlayerNode.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

import Foundation


import SpriteKit

// DİKKAT: Artık SKShapeNode değil, SKSpriteNode kullanıyoruz!
class PlayerNode: SKSpriteNode {
    
    // init fonksiyonu artık resim adını da alıyor
    init(imageNamed: String, width: CGFloat) {
        // Görseli yükle
        let texture = SKTexture(imageNamed: imageNamed)
        // Görselin boyutunu ayarla (kare olacak şekilde)
        let size = CGSize(width: width, height: width)
        
        // SKSpriteNode'un kendi başlatıcısını çağır
        super.init(texture: texture, color: .clear, size: size)
        
        // DEĞİŞİKLİK BURADA
                // Virüsün dikenlerini saymayalım, sadece gövdesi çarpınca yansın.
                // Kutuyu %50 oranında küçülttüm.
                let hitboxSize = CGSize(width: width * 0.5, height: width * 0.5)
                
                self.physicsBody = SKPhysicsBody(rectangleOf: hitboxSize)
                
        
        /*
        // Görsel Ayarlar (Neon Efekti Kodla Değil, Resimden Geliyor)
        // Ancak hafif bir ekstra parlama ekleyebiliriz (Opsiyonel)
        // self.color = .cyan
        // self.colorBlendFactor = 0.2
         */
        
        // 3. Fizik Ayarları (Aynen kalıyor)
        // Virüsün şekline göre değil, yine basit bir kare fizik alanı kullanıyoruz (Performans için)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.linearDamping = 0.0
        
        self.physicsBody?.categoryBitMask = PhysicsCategories.player
        self.physicsBody?.collisionBitMask = PhysicsCategories.ground
        self.physicsBody?.contactTestBitMask = PhysicsCategories.obstacle
        
        self.name = "Player"
        self.zPosition = 2 // Engellerin önünde görünsün
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
