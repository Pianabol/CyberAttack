//
//  MenuScene.swift
//  The Runaway
//
//  Created by Furkan TUC on 16.12.2025.
//

import Foundation

import SpriteKit

class MenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        // Koordinat merkezi ekranın ortası olsun
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // --- DEĞİŞİKLİK 1: ARKA PLAN DÜZELTMESİ ---
        let background = SKSpriteNode(imageNamed: "bg_cyber")
        // background.size = self.size // <-- BU HATALI SATIRI SİLDİK
        
        // Görseli ekrana sığdır (Aspect Fill - En boy oranını koruyarak doldur)
        if let texture = background.texture {
            let verticalRatio = self.size.height / texture.size().height
            let horizontalRatio = self.size.width / texture.size().width
            // Hangi oran daha büyükse onu seç ki ekranın tamamı dolsun
            let scaleRatio = max(verticalRatio, horizontalRatio)
            background.setScale(scaleRatio)
        }
        background.position = CGPoint.zero
        background.zPosition = -1
        addChild(background)
        
        //  DEĞİŞİKLİK 2: BAŞLIK KALDIRILDI
        // "THE RUNAWAY" başlığını ekleyen kod bloğu tamamen silindi.
        
        //  Hikaye Kutusu (Div)
        createStoryBox()
        
        //  Tap to Start Yazısı
        let startLabel = SKLabelNode(fontNamed: "Orbitron-Bold")
        startLabel.text = "Sızmak için Dokun" // "Sızmak için Dokun, TAP TO INFILTRATE"
        startLabel.fontSize = 28
        startLabel.fontColor = .yellow
        
        // Başlık kalktığı için bu yazıyı yukarı al.
        startLabel.position = CGPoint(x: 0, y: -self.size.height / 3 + 20)
        
        // Yanıp Sönme Animasyonu
        let blink = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.6),
            SKAction.fadeIn(withDuration: 0.6)
        ])
        startLabel.run(SKAction.repeatForever(blink))
        addChild(startLabel)
    }
    
    func createStoryBox()
    {
        // Kutu Boyutları
        let boxWidth: CGFloat = 340
        let boxHeight: CGFloat = 220
        let cornerRadius: CGFloat = 15
        
        // Kutuyu oluştur
        let storyBox = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: cornerRadius)
        
        // değişiklik -> KUTU RENKLERİ
        // Arka Plan: Gri (%90 opaklık)
        storyBox.fillColor = UIColor.gray.withAlphaComponent(0.9)
        // Çerçeve: Siyaha yakın
        storyBox.strokeColor = UIColor(white: 0.3, alpha: 1.0)
        storyBox.lineWidth = 3
        
        storyBox.position = CGPoint(x: 0, y: 0) // Tam orta
        addChild(storyBox)
        
        // Hikaye Metni
        let line1 = SKLabelNode(fontNamed: "Orbitron-Regular")
        line1.text = "CASUS: 734"
        line1.fontSize = 18
        line1.fontColor = .black // Gri zemin üstüne siyah yazı daha iyi okunur
        line1.position = CGPoint(x: 0, y: 60)
        storyBox.addChild(line1)
        
        let line2 = SKLabelNode(fontNamed: "AvenirNext-Regular")
        line2.text = "Cyberpunk bir dünyada sistemi"
        line2.fontSize = 16
        line2.fontColor = .black      //UIColor(white: 0.1, alpha: 1.0) gri yazı.
        line2.position = CGPoint(x: 0, y: 20)
        storyBox.addChild(line2)
        
        let line3 = SKLabelNode(fontNamed: "AvenirNext-Regular")
        line3.text = "çökertmek için görevlendirildin."
        line3.fontSize = 16
        line3.fontColor = .black  //UIColor(white: 0.1, alpha: 1.0)
        line3.position = CGPoint(x: 0, y: -5)
        storyBox.addChild(line3)
        
        let line4 = SKLabelNode(fontNamed: "AvenirNext-Bold")
        line4.text = "Engelleri aş, dünyayı kurtar!"
        line4.fontSize = 16
        line4.fontColor = .red // Vurgu rengini kırmızı yaptım, daha çarpıcı.
        line4.position = CGPoint(x: 0, y: -45)
        storyBox.addChild(line4)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // Ekrana dokunulduğunda Oyuna (GameScene) geç
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = self.scaleMode
        
        // geçiş efekti (kapı açılması)
        let transition = SKTransition.doorsOpenVertical(withDuration: 1.0)
        self.view?.presentScene(gameScene, transition: transition)
    }
}
