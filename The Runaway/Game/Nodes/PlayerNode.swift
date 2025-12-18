//
//  PlayerNode.swift
//  The Runaway
//
//  Created by Furkan TUC on 15.12.2025.
//

import Foundation


import SpriteKit

class PlayerNode: SKSpriteNode
{
    
    init(imageNamed: String, width: CGFloat)
    {
        let texture = SKTexture(imageNamed: imageNamed)
        
        // 1. GÖRSEL BOYUT (Gözün gördüğü)
        // Burası dışarıdan gelen 'width' değerini kullanır (Örn: 120)
        let visualSize = CGSize(width: width, height: width)
        
        super.init(texture: texture, color: .clear, size: visualSize)
        
        // 2. FİZİKSEL BOYUT
        
        // Görsel 120 olsa bile, buradan hitboxı küçült.
        // let hitboxSize = CGSize(width: 40, height: 60) // genişlik önemli değil ama yükseklik önemli. 60 iyi.
        
        
        // circle kullanırsak köşelerden çarpma riski daha da azalır.
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 27) // 2xYarıçap  = Genişlik. yuvarlak yapınca altlarından geçebiliyor. dikdörtgen olarak ayarlayacağım.
        
        // Kare kalması için alttaki line'ı aktif et, üsttekini comment'e al.
        //self.physicsBody = SKPhysicsBody(rectangleOf: hitboxSize)
        
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0.0
        self.physicsBody?.restitution = 0.0
        self.physicsBody?.linearDamping = 0.0
        
        self.physicsBody?.categoryBitMask = PhysicsCategories.player
        self.physicsBody?.collisionBitMask = PhysicsCategories.ground
        self.physicsBody?.contactTestBitMask = PhysicsCategories.obstacle
        
        self.name = "Player"
        self.zPosition = 2
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}
