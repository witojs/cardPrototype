//
//  backup.swift
//  cardPrototype
//
//  Created by Wito Irawan on 03/05/25.
//


//legacy code
import SpriteKit


//class CardNode: SKSpriteNode {
//    var isSelected = false
//    var originalPosition = CGPoint.zero
//    var isAnimating = false
//    var attackValue: Int = 0
//    var cardType: String = ""
//}

/*

class CardNode: SKSpriteNode {
    var isSelected = false
    var originalPosition = CGPoint.zero
    var isAnimating = false
    var attackValue: Int = 0
    var cardType: String = ""
    let valueLabel = SKLabelNode(fontNamed: "Arial Bold")  // Add label
    
    init(texture: SKTexture?) {
        super.init(texture: texture, color: .clear, size: texture?.size() ?? CGSize.zero)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel() {
        valueLabel.fontSize = 40
        valueLabel.fontColor = .white
        valueLabel.position = CGPoint(x: 0, y: -40)  // Position below card
        valueLabel.zPosition = 1
        addChild(valueLabel)
    }
}


class GameScene: SKScene {
    var deck: SKSpriteNode!
    let cardBackTexture = SKTexture(imageNamed: "card_back")
    
    var cardTextures: [SKTexture] {
        return Array(cardData.keys)
    }
    
    // Update card data for elements
    let elementTypes = ["fire", "water", "wind", "earth"]
    let cardData: [SKTexture: (String)] = [
        SKTexture(imageNamed: "fire"): "fire",
        SKTexture(imageNamed: "water"): "water",
        SKTexture(imageNamed: "wind"): "wind",
        SKTexture(imageNamed: "earth"): "earth"
    ]
    
//    let cardData: [SKTexture: (value: Int, type: String)] = [
//        SKTexture(imageNamed: "card_creature_wolf"): (5, "wolf"),
//        SKTexture(imageNamed: "card_creature_bear"): (5, "bear"),
//        SKTexture(imageNamed: "card_creature_dragon"): (10, "dragon"),
//        SKTexture(imageNamed: "card_creature_unicorn"): (8, "unicorn"),
//        SKTexture(imageNamed: "card_creature_phoenix"): (7, "phoenix")
//    ]
    
    //attack & discard button
    let attackButton = SKSpriteNode(imageNamed: "attack_button")
    let discardButton = SKSpriteNode(imageNamed: "discard_button")
    
    var isAnimating = false
    let playAreaPadding: CGFloat = 4
    var playAreaCards = [CardNode]()
    var selectedCards = [CardNode]()
    let maxSelection = 3

    var playAreaPosition: CGPoint {
        return CGPoint(x: frame.midX, y: frame.midY - 100)
    }
    
    // Add boss properties
    var bossSprite = SKSpriteNode(imageNamed: "boss")
    var bossHealth: Int = 100
    let bossMaxHealth: Int = 100
    var bossHealthBar = SKNode()
    var bossHealthLabel = SKLabelNode()
    
    //victory label
    let victoryLabel = SKLabelNode(fontNamed: "Arial Bold")
    
    //attack chance
    var attackChances = 4
    let chancesLabel = SKLabelNode(fontNamed: "Arial Bold")
    let gameOverLabel = SKLabelNode(fontNamed: "Arial Bold")

    override func didMove(to view: SKView) {
        deck = SKSpriteNode(texture: cardBackTexture)
        deck.position = CGPoint(x: frame.midX + 350, y: frame.midY - 100)
        scaleCard(deck)
        addChild(deck)
        
        // Setup buttons
        let buttonYPosition: CGFloat = 100
        attackButton.position = CGPoint(x: frame.midX - 100, y: buttonYPosition)
        attackButton.zPosition = 10
        attackButton.name = "attack"
        attackButton.isHidden = true
        attackButton.scale(to: frame.size, width: false, multiplier: 0.07)
        addChild(attackButton)
        
        discardButton.position = CGPoint(x: frame.midX + 100, y: buttonYPosition)
        discardButton.zPosition = 10
        discardButton.name = "discard"
        discardButton.isHidden = true
        discardButton.scale(to: frame.size, width: false, multiplier: 0.07)
        addChild(discardButton)
        
        // Add boss setup
        setupBoss()
        
        //attack chance
        chancesLabel.text = "Attacks Left: \(attackChances)"
        chancesLabel.fontSize = 40
        chancesLabel.fontColor = .white
        chancesLabel.horizontalAlignmentMode = .left
        chancesLabel.position = CGPoint(x: 50, y: frame.height - 100)
        addChild(chancesLabel)
    }
    
    //boss
    func setupBoss() {
        // Boss sprite
        bossSprite.position = CGPoint(x: frame.midX, y: frame.height - 150)
        bossSprite.zPosition = 5
        bossSprite.scale(to: frame.size, width: false, multiplier: 0.5)
        addChild(bossSprite)
        
        // Health bar
        let barWidth: CGFloat = 150
        let barHeight: CGFloat = 10
        
        let backgroundBar = SKSpriteNode(color: .red, size: CGSize(width: barWidth, height: barHeight))
        backgroundBar.position = CGPoint(x: 0, y: +120)
        
        let healthBar = SKSpriteNode(color: .green, size: CGSize(width: barWidth, height: barHeight))
        healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBar.position = CGPoint(x: -barWidth/2, y: +120)
        healthBar.name = "healthBar"
        
        bossHealthBar.addChild(backgroundBar)
        bossHealthBar.addChild(healthBar)
        bossHealthBar.position = bossSprite.position
        addChild(bossHealthBar)
        
        // Health label
        bossHealthLabel.text = "\(bossHealth)/\(bossMaxHealth)"
        bossHealthLabel.fontSize = 24
        bossHealthLabel.fontColor = .white
        bossHealthLabel.position = CGPoint(x: 0, y: 90)
        bossHealthBar.addChild(bossHealthLabel)
    }
    
    func updateBossHealth(damage: Int) {
        bossHealth = max(0, bossHealth - damage)
        
        // Update health bar
        if let healthBar = bossHealthBar.childNode(withName: "healthBar") as? SKSpriteNode {
            let healthPercentage = CGFloat(bossHealth) / CGFloat(bossMaxHealth)
            healthBar.run(SKAction.scaleX(to: healthPercentage, duration: 0.2))
        }
        
        bossHealthLabel.text = "\(bossHealth)/\(bossMaxHealth)"
        
        if bossHealth <= 0 {
            bossDefeated()
        }
    }
    
    func bossDefeated() {
        print("Boss defeated!")
        
        // Create victory label
        victoryLabel.text = "You Win!"
        victoryLabel.fontSize = 100
        victoryLabel.fontColor = .yellow
        victoryLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        victoryLabel.zPosition = 20  // Ensure it's on top
        victoryLabel.setScale(0)  // Start invisible
        
        // Add animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.2)
        let finalScale = SKAction.scale(to: 1.0, duration: 0.2)
        //to loop forever
//        let pulse = SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown]))
        
        addChild(victoryLabel)
        victoryLabel.run(SKAction.sequence([
            SKAction.unhide(),
            scaleUp,
            scaleDown,
            finalScale
        ]))
//        victoryLabel.run(SKAction.sequence([
//            SKAction.scale(to: 1.0, duration: 0.5),
//            pulse
//        ]))
        
        // Disable further interactions
        isUserInteractionEnabled = false
    }
    
    func updateButtonVisibility() {
        if !selectedCards.isEmpty {
            // Fixed positions at bottom center of screen
            let buttonYPosition: CGFloat = 100  // Adjust this value based on your layout
            attackButton.position = CGPoint(x: frame.midX - 250, y: buttonYPosition)
            discardButton.position = CGPoint(x: frame.midX + 250, y: buttonYPosition)
            
            attackButton.isHidden = false
            discardButton.isHidden = false
        } else {
            attackButton.isHidden = true
            discardButton.isHidden = true
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check buttons first
        if !selectedCards.isEmpty {
            if attackButton.contains(location) {
                handleAttack()
                return
            }
            if discardButton.contains(location) {
                handleDiscard()
                return
            }
        }
        
        // First check card selection
        for card in playAreaCards {
            if card.contains(location) && !card.isAnimating && !isAnimating {
                handleCardSelection(card)
                return
            }
        }
        
        // Then check deck interaction
        if !isAnimating && deck.contains(location) {
            drawCardsFromDeck()
        }
    }
    
    
    // Add these new methods to the GameScene class
    func replaceSelectedCards() {
        guard !selectedCards.isEmpty else { return }
        
        // Store positions of selected cards
        let replacedPositions = selectedCards.map { $0.originalPosition }
        
        // Animate out selected cards
        selectedCards.forEach { card in
            let discardAnimation = SKAction.group([
                SKAction.moveBy(x: 1000, y: 0, duration: 0.5), // Move right off screen
                SKAction.fadeOut(withDuration: 0.3)
            ])
            
            card.run(SKAction.sequence([
                discardAnimation,
                SKAction.removeFromParent()
            ]))
        }
        
        // Remove selected cards from play area
        playAreaCards.removeAll { selectedCards.contains($0) }
        selectedCards.removeAll()
        
        // Draw new cards to replace discarded ones
        isAnimating = true
        var cardsToAnimate = replacedPositions.count
        
        for position in replacedPositions {
            let newCard = CardNode(texture: cardBackTexture)
            newCard.position = deck.position
            newCard.originalPosition = position
            newCard.zPosition = 1
            scaleCard(newCard)
            addChild(newCard)
            playAreaCards.append(newCard)
            
            animateCard(newCard, to: position) {
                cardsToAnimate -= 1
                if cardsToAnimate == 0 {
                    self.isAnimating = false
                }
            }
        }
    }

    // Update the handleAttack function
    func handleAttack() {
        guard !selectedCards.isEmpty else { return }
        
        attackChances -= 1  // Reduce attack chance
        chancesLabel.text = "Attacks Left: \(attackChances)"
        
        let baseAttack = selectedCards.reduce(0) { $0 + $1.attackValue }
        let types = selectedCards.map { $0.cardType }
        let multiplier = calculateComboMultiplier(for: types)
        let totalDamage = Int(Double(baseAttack) * multiplier)
        
        print("Attacking with \(totalDamage) damage! (\(baseAttack) base × \(multiplier)x multiplier)")
        
        // Update boss health
        updateBossHealth(damage: totalDamage)
        
        // Replace selected cards with new ones
        replaceSelectedCards()
        
        // Clear selection and update buttons
        updateButtonVisibility()
        
        // Check for game over condition
        if attackChances <= 0 && bossHealth > 0 {
            showGameOver()
        }
    }
    
    func showGameOver() {
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 100
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.zPosition = 20
        gameOverLabel.setScale(0)
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.3)
        let finalScale = SKAction.scale(to: 1.0, duration: 0.2)
        
        addChild(gameOverLabel)
        gameOverLabel.run(SKAction.sequence([
            SKAction.unhide(),
            scaleUp,
            scaleDown,
            finalScale
        ]))
        
        // Disable interactions
        isUserInteractionEnabled = false
    }
    
    
//    private func calculateComboMultiplier(for types: [String]) -> Double {
//        guard types.count == 3 else { return 1.0 }
//
//        // Bear Combo: 3 bears
//        if types.filter({ $0 == "bear" }).count == 3 {
//            return 1.5
//        }
//
//        // Dragon-Unicorn-Phoenix Combo
//        let requiredTypes: Set<String> = ["dragon", "unicorn", "phoenix"]
//        let selectedTypes = Set(types)
//
//        if selectedTypes == requiredTypes && types.count == 3 {
//            return 2.5
//        }
//
//        return 1.0
//    }
    
    // Update combo multiplier for elements
    private func calculateComboMultiplier(for types: [String]) -> Double {
        guard types.count == 3 else { return 1.0 }
        
        // Check for 3 of same element
        if types.allSatisfy({ $0 == types.first }) {
            return 2.0
        }
        
        // Check for all different elements
        if Set(types).count == 3 {
            return 1.5
        }
        
        return 1.0
    }

    func handleDiscard() {
        guard !selectedCards.isEmpty else { return }
        
        print("Discarding selected cards:", selectedCards)
        
        // Replace selected cards with new ones
        replaceSelectedCards()
        
        // Clear selection and update buttons
        updateButtonVisibility()

    }

    func drawCardsFromDeck() {
        attackButton.isHidden = true
        discardButton.isHidden = true
        isAnimating = true
        playAreaCards.forEach { $0.removeFromParent() }
        playAreaCards.removeAll()
        
        // Get scaled dimensions from deck
        let originalCardSize = cardBackTexture.size()
        let scaledCardWidth = deck.frame.size.width
        let scaleFactor = scaledCardWidth / originalCardSize.width
        
        // Scale padding proportionally
        let scaledPadding = playAreaPadding * scaleFactor
        
        // Calculate positions using SCALED values
        let totalWidth = (scaledCardWidth * 5) + (scaledPadding * 4)
        var xPosition = playAreaPosition.x - (totalWidth / 2) + (scaledCardWidth / 2)
        
        var targetPositions = [CGPoint]()
        for _ in 0..<5 {
            targetPositions.append(CGPoint(x: xPosition, y: playAreaPosition.y))
            xPosition += scaledCardWidth + scaledPadding
        }
        
        var currentCardIndex = 0
        
        func drawNextCard() {
            guard currentCardIndex < 5 else {
                isAnimating = false
                return
            }
            
            let newCard = CardNode(texture: cardBackTexture)
            newCard.position = deck.position
            newCard.zPosition = 1
            newCard.originalPosition = targetPositions[currentCardIndex]
            scaleCard(newCard)
            addChild(newCard)
            playAreaCards.append(newCard)
            
            animateCard(newCard, to: targetPositions[currentCardIndex]) {
                currentCardIndex += 1
                drawNextCard()
            }
        }
        
        drawNextCard()
        selectedCards.removeAll()
    }

    func animateCard(_ card: CardNode, to position: CGPoint, completion: @escaping () -> Void) {
        let totalMoveDuration: TimeInterval = 0.6
        let flipDuration: TimeInterval = 0.3
        
        //adjust card animation based on scale card
        let originalXScale = card.xScale
        
        let moveAction = SKAction.move(to: position, duration: totalMoveDuration)
        
//        let flipSequence = SKAction.sequence([
//            SKAction.wait(forDuration: (totalMoveDuration/2) - (flipDuration/2)),
//            SKAction.scaleX(to: 0, duration: flipDuration/2),
//            SKAction.run { [weak self] in
//                guard let self = self else { return }
//                // Get random texture from cardData keys
//                if let randomTexture = self.cardTextures.randomElement(),
//                   let data = self.cardData[randomTexture] {
//                    card.texture = randomTexture
//                    card.attackValue = data.value
//                    card.cardType = data.type
//                }
//            },
//            SKAction.scaleX(to: originalXScale, duration: flipDuration/2)
//        ])
        
        let flipSequence = SKAction.sequence([
            SKAction.wait(forDuration: (totalMoveDuration/2) - (flipDuration/2)),
            SKAction.scaleX(to: 0, duration: flipDuration/2),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                if let randomTexture = self.cardTextures.randomElement(),
                   let elementType = self.cardData[randomTexture] {
                    // Assign random value between 1-10
                    card.attackValue = Int.random(in: 1...10)
                    card.cardType = elementType
                    card.texture = randomTexture
                    card.valueLabel.text = "\(card.attackValue)"
                }
            },
            SKAction.scaleX(to: originalXScale, duration: flipDuration/2)
        ])
        
        let popEffect = SKAction.sequence([
            SKAction.scale(to: originalXScale * 1.1, duration: 0.1),
            SKAction.scale(to: originalXScale, duration: 0.1)
        ])
        
        card.run(SKAction.group([moveAction, flipSequence])) {
            card.run(popEffect) {
                completion()
            }
        }
    }

    func handleCardSelection(_ card: CardNode) {
        let moveDistance: CGFloat = 20
        let moveDuration: TimeInterval = 0.2
        
        guard !card.isAnimating else { return }
        
        if card.isSelected {
            // Deselect the card
            card.isAnimating = true
            let moveAction = SKAction.move(to: card.originalPosition, duration: moveDuration)
            moveAction.timingMode = .easeInEaseOut
            
            card.run(moveAction) {
                card.isAnimating = false
                card.isSelected = false
                if let index = self.selectedCards.firstIndex(of: card) {
                    self.selectedCards.remove(at: index)
                }
                // Move update here
                self.updateButtonVisibility()
            }
        } else {
            guard selectedCards.count < maxSelection else { return }
            
            // Select the card
            card.isAnimating = true
            let newPosition = CGPoint(x: card.position.x, y: card.originalPosition.y + moveDistance)
            let moveAction = SKAction.move(to: newPosition, duration: moveDuration)
            moveAction.timingMode = .easeInEaseOut
            
            card.run(moveAction) {
                card.isAnimating = false
                card.isSelected = true
                self.selectedCards.append(card)
                // Move update here
                self.updateButtonVisibility()
            }
        }
    }
    
    //scale card
    func scaleCard(_ card: SKSpriteNode) {
        card.scale(to: frame.size, width: false, multiplier: 0.25)
        card.texture?.filteringMode = .nearest // For pixel art preservation
        
        if let cardNode = card as? CardNode {
            cardNode.valueLabel.fontSize = 10 * (card.xScale / 0.25)
        }
    }
}

*/

//version 2 implementing deck
/*
 import SpriteKit


 //class CardNode: SKSpriteNode {
 //    var isSelected = false
 //    var originalPosition = CGPoint.zero
 //    var isAnimating = false
 //    var attackValue: Int = 0
 //    var cardType: String = ""
 //}
 class CardNode: SKSpriteNode {
     var isSelected = false
     var originalPosition = CGPoint.zero
     var isAnimating = false
     var attackValue: Int = 0
     var cardType: String = ""
     let valueLabel = SKLabelNode(fontNamed: "Arial Bold")  // Add label
     
     init(texture: SKTexture?) {
         super.init(texture: texture, color: .clear, size: texture?.size() ?? CGSize.zero)
         setupLabel()
     }
     
     required init?(coder aDecoder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
     func setupLabel() {
         valueLabel.fontSize = 40
         valueLabel.fontColor = .white
         valueLabel.position = CGPoint(x: 0, y: -40)  // Position below card
         valueLabel.zPosition = 1
         addChild(valueLabel)
     }
 }


 struct CardDefinition {
     let element: String
     let value: Int
     var texture: SKTexture {
         return SKTexture(imageNamed: "\(element)")
     }
 }

 class GameScene: SKScene {
     // Replace existing deck/cardData with these properties
     var deck: [CardDefinition] = []
     var discardPile: [CardDefinition] = []
     var currentDeck: [CardDefinition] = []
     
     var deckNode: SKSpriteNode!
     let cardBackTexture = SKTexture(imageNamed: "card_back")
     
     // Add deck count label property
     let deckCountLabel = SKLabelNode(fontNamed: "Arial Bold")
     
 //    var cardTextures: [SKTexture] {
 //        return Array(cardData.keys)
 //    }
 //
 //    // Update card data for elements
 //    let elementTypes = ["fire", "water", "wind", "earth"]
 //    let cardData: [SKTexture: (String)] = [
 //        SKTexture(imageNamed: "fire"): "fire",
 //        SKTexture(imageNamed: "water"): "water",
 //        SKTexture(imageNamed: "wind"): "wind",
 //        SKTexture(imageNamed: "earth"): "earth"
 //    ]
     
     
 //    let cardData: [SKTexture: (value: Int, type: String)] = [
 //        SKTexture(imageNamed: "card_creature_wolf"): (5, "wolf"),
 //        SKTexture(imageNamed: "card_creature_bear"): (5, "bear"),
 //        SKTexture(imageNamed: "card_creature_dragon"): (10, "dragon"),
 //        SKTexture(imageNamed: "card_creature_unicorn"): (8, "unicorn"),
 //        SKTexture(imageNamed: "card_creature_phoenix"): (7, "phoenix")
 //    ]
     
     //attack & discard button
     let attackButton = SKSpriteNode(imageNamed: "attack_button")
     let discardButton = SKSpriteNode(imageNamed: "discard_button")
     
     var isAnimating = false
     let playAreaPadding: CGFloat = 4
     var playAreaCards = [CardNode]()
     var selectedCards = [CardNode]()
     let maxSelection = 3

     var playAreaPosition: CGPoint {
         return CGPoint(x: frame.midX, y: frame.midY - 100)
     }
     
     // Add boss properties
     var bossSprite = SKSpriteNode(imageNamed: "boss")
     var bossHealth: Int = 100
     let bossMaxHealth: Int = 100
     var bossHealthBar = SKNode()
     var bossHealthLabel = SKLabelNode()
     
     //victory label
     let victoryLabel = SKLabelNode(fontNamed: "Arial Bold")
     
     //attack chance
     var attackChances = 4
     let chancesLabel = SKLabelNode(fontNamed: "Arial Bold")
     let gameOverLabel = SKLabelNode(fontNamed: "Arial Bold")

     override func didMove(to view: SKView) {
         initializeDeck()
         
         deckNode = SKSpriteNode(texture: cardBackTexture)
         deckNode.position = CGPoint(x: frame.midX + 350, y: frame.midY - 100)
         scaleCard(deckNode)
         addChild(deckNode)
         
         // Add deck count label
         deckCountLabel.text = "\(currentDeck.count)/40"
         deckCountLabel.fontSize = 24
         deckCountLabel.fontColor = .white
         deckCountLabel.position = CGPoint(x: deckNode.position.x, y: deckNode.position.y + 50)
         addChild(deckCountLabel)
         
         // Setup buttons
         let buttonYPosition: CGFloat = 100
         attackButton.position = CGPoint(x: frame.midX - 100, y: buttonYPosition)
         attackButton.zPosition = 10
         attackButton.name = "attack"
         attackButton.isHidden = true
         attackButton.scale(to: frame.size, width: false, multiplier: 0.07)
         addChild(attackButton)
         
         discardButton.position = CGPoint(x: frame.midX + 100, y: buttonYPosition)
         discardButton.zPosition = 10
         discardButton.name = "discard"
         discardButton.isHidden = true
         discardButton.scale(to: frame.size, width: false, multiplier: 0.07)
         addChild(discardButton)
         
         // Add boss setup
         setupBoss()
         
         //attack chance
         chancesLabel.text = "Attacks Left: \(attackChances)"
         chancesLabel.fontSize = 40
         chancesLabel.fontColor = .white
         chancesLabel.horizontalAlignmentMode = .left
         chancesLabel.position = CGPoint(x: 50, y: frame.height - 100)
         addChild(chancesLabel)
     }
     
     // Initialize deck
     func initializeDeck() {
         deck.removeAll()
         let elements = ["fire", "water", "wind", "earth"]
         
         for element in elements {
             for value in 1...10 {
                 deck.append(CardDefinition(element: element, value: value))
             }
         }
         
         currentDeck = deck.shuffled()
         updateDeckCount()  // Update count after initialization
     }
     
     // Add this helper function
     func updateDeckCount() {
         deckCountLabel.text = "\(currentDeck.count)/40"
     }
     
     //boss
     func setupBoss() {
         // Boss sprite
         bossSprite.position = CGPoint(x: frame.midX, y: frame.height - 150)
         bossSprite.zPosition = 5
         bossSprite.scale(to: frame.size, width: false, multiplier: 0.5)
         addChild(bossSprite)
         
         // Health bar
         let barWidth: CGFloat = 150
         let barHeight: CGFloat = 10
         
         let backgroundBar = SKSpriteNode(color: .red, size: CGSize(width: barWidth, height: barHeight))
         backgroundBar.position = CGPoint(x: 0, y: +120)
         
         let healthBar = SKSpriteNode(color: .green, size: CGSize(width: barWidth, height: barHeight))
         healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
         healthBar.position = CGPoint(x: -barWidth/2, y: +120)
         healthBar.name = "healthBar"
         
         bossHealthBar.addChild(backgroundBar)
         bossHealthBar.addChild(healthBar)
         bossHealthBar.position = bossSprite.position
         addChild(bossHealthBar)
         
         // Health label
         bossHealthLabel.text = "\(bossHealth)/\(bossMaxHealth)"
         bossHealthLabel.fontSize = 24
         bossHealthLabel.fontColor = .white
         bossHealthLabel.position = CGPoint(x: 0, y: 90)
         bossHealthBar.addChild(bossHealthLabel)
     }
     
     func updateBossHealth(damage: Int) {
         bossHealth = max(0, bossHealth - damage)
         
         // Update health bar
         if let healthBar = bossHealthBar.childNode(withName: "healthBar") as? SKSpriteNode {
             let healthPercentage = CGFloat(bossHealth) / CGFloat(bossMaxHealth)
             healthBar.run(SKAction.scaleX(to: healthPercentage, duration: 0.2))
         }
         
         bossHealthLabel.text = "\(bossHealth)/\(bossMaxHealth)"
         
         if bossHealth <= 0 {
             bossDefeated()
         }
     }
     
     func bossDefeated() {
         print("Boss defeated!")
         
         // Create victory label
         victoryLabel.text = "You Win!"
         victoryLabel.fontSize = 100
         victoryLabel.fontColor = .yellow
         victoryLabel.position = CGPoint(x: frame.midX, y: frame.midY)
         victoryLabel.zPosition = 20  // Ensure it's on top
         victoryLabel.setScale(0)  // Start invisible
         
         // Add animation
         let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
         let scaleDown = SKAction.scale(to: 0.9, duration: 0.2)
         let finalScale = SKAction.scale(to: 1.0, duration: 0.2)
         //to loop forever
 //        let pulse = SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown]))
         
         addChild(victoryLabel)
         victoryLabel.run(SKAction.sequence([
             SKAction.unhide(),
             scaleUp,
             scaleDown,
             finalScale
         ]))
 //        victoryLabel.run(SKAction.sequence([
 //            SKAction.scale(to: 1.0, duration: 0.5),
 //            pulse
 //        ]))
         
         // Disable further interactions
         isUserInteractionEnabled = false
     }
     
     func updateButtonVisibility() {
         if !selectedCards.isEmpty {
             // Fixed positions at bottom center of screen
             let buttonYPosition: CGFloat = 100  // Adjust this value based on your layout
             attackButton.position = CGPoint(x: frame.midX - 250, y: buttonYPosition)
             discardButton.position = CGPoint(x: frame.midX + 250, y: buttonYPosition)
             
             attackButton.isHidden = false
             discardButton.isHidden = false
         } else {
             attackButton.isHidden = true
             discardButton.isHidden = true
         }
     }

     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         guard let touch = touches.first else { return }
         let location = touch.location(in: self)
         
         // Check buttons first
         if !selectedCards.isEmpty {
             if attackButton.contains(location) {
                 handleAttack()
                 return
             }
             if discardButton.contains(location) {
                 handleDiscard()
                 return
             }
         }
         
         // First check card selection
         for card in playAreaCards {
             if card.contains(location) && !card.isAnimating && !isAnimating {
                 handleCardSelection(card)
                 return
             }
         }
         
         // Then check deck interaction
         if !isAnimating && deckNode.contains(location) {
             drawCardsFromDeck()
         }
     }
     
     
     // Updated replaceSelectedCards
     func replaceSelectedCards() {
         guard !selectedCards.isEmpty else { return }
         
         // Store positions
         let replacedPositions = selectedCards.map { $0.originalPosition }
         
         // Move to discard pile
         selectedCards.forEach { card in
             discardPile.append(CardDefinition(
                 element: card.cardType,
                 value: card.attackValue
             ))
             let discardAnimation = SKAction.group([
                 SKAction.moveBy(x: 1000, y: 0, duration: 0.5),
                 SKAction.fadeOut(withDuration: 0.3)
             ])
             card.run(SKAction.sequence([discardAnimation, SKAction.removeFromParent()]))
         }
         
         // Remove from play area
         playAreaCards.removeAll { selectedCards.contains($0) }
         selectedCards.removeAll()
         
         // Draw new cards
         isAnimating = true
         var cardsToAnimate = replacedPositions.count
         
         for position in replacedPositions {
             guard !currentDeck.isEmpty else {
                 print("Deck is empty!")
                 cardsToAnimate -= 1
                 if cardsToAnimate == 0 {
                     self.isAnimating = false
                     self.updateDeckCount()  // Update when deck is empty
                 }
                 continue
             }
             
             let cardDef = currentDeck.removeFirst()
             updateDeckCount()
             let newCard = CardNode(texture: cardBackTexture)
             newCard.position = deckNode.position
             newCard.originalPosition = position
             newCard.zPosition = 1
             newCard.attackValue = cardDef.value
             newCard.cardType = cardDef.element
             newCard.valueLabel.text = "\(newCard.attackValue)"
             newCard.valueLabel.isHidden = true
             
             scaleCard(newCard)
             addChild(newCard)
             playAreaCards.append(newCard)
             
             animateCard(newCard, to: position) {
                 cardsToAnimate -= 1
                 if cardsToAnimate == 0 {
                     self.isAnimating = false
                 }
             }
         }
     }

     // Update the handleAttack function
     func handleAttack() {
         guard !selectedCards.isEmpty else { return }
         
         attackChances -= 1  // Reduce attack chance
         chancesLabel.text = "Attacks Left: \(attackChances)"
         
         let baseAttack = selectedCards.reduce(0) { $0 + $1.attackValue }
         let types = selectedCards.map { $0.cardType }
         let multiplier = calculateComboMultiplier(for: types)
         let totalDamage = Int(Double(baseAttack) * multiplier)
         
         print("Attacking with \(totalDamage) damage! (\(baseAttack) base × \(multiplier)x multiplier)")
         
         // Update boss health
         updateBossHealth(damage: totalDamage)
         
         // Replace selected cards with new ones
         replaceSelectedCards()
         
         updateDeckCount()
         
         // Clear selection and update buttons
         updateButtonVisibility()
         
         // Check for game over condition
         if attackChances <= 0 && bossHealth > 0 {
             showGameOver()
         }
     }
     
     func showGameOver() {
         gameOverLabel.text = "Game Over!"
         gameOverLabel.fontSize = 100
         gameOverLabel.fontColor = .red
         gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
         gameOverLabel.zPosition = 20
         gameOverLabel.setScale(0)
         
         let scaleUp = SKAction.scale(to: 1.2, duration: 0.5)
         let scaleDown = SKAction.scale(to: 0.9, duration: 0.3)
         let finalScale = SKAction.scale(to: 1.0, duration: 0.2)
         
         addChild(gameOverLabel)
         gameOverLabel.run(SKAction.sequence([
             SKAction.unhide(),
             scaleUp,
             scaleDown,
             finalScale
         ]))
         
         // Disable interactions
         isUserInteractionEnabled = false
     }
     
     
 //    private func calculateComboMultiplier(for types: [String]) -> Double {
 //        guard types.count == 3 else { return 1.0 }
 //
 //        // Bear Combo: 3 bears
 //        if types.filter({ $0 == "bear" }).count == 3 {
 //            return 1.5
 //        }
 //
 //        // Dragon-Unicorn-Phoenix Combo
 //        let requiredTypes: Set<String> = ["dragon", "unicorn", "phoenix"]
 //        let selectedTypes = Set(types)
 //
 //        if selectedTypes == requiredTypes && types.count == 3 {
 //            return 2.5
 //        }
 //
 //        return 1.0
 //    }
     
     // Update combo multiplier for elements
     private func calculateComboMultiplier(for types: [String]) -> Double {
         guard types.count == 3 else { return 1.0 }
         
         // Check for 3 of same element
         if types.allSatisfy({ $0 == types.first }) {
             return 2.0
         }
         
         // Check for all different elements
         if Set(types).count == 3 {
             return 1.5
         }
         
         return 1.0
     }

     func handleDiscard() {
         guard !selectedCards.isEmpty else { return }
         
         print("Discarding selected cards:", selectedCards)
         
         // Replace selected cards with new ones
         replaceSelectedCards()
         
         updateDeckCount()
         
         // Clear selection and update buttons
         updateButtonVisibility()

     }

     // Modified drawCardsFromDeck
     func drawCardsFromDeck() {
         attackButton.isHidden = true
         discardButton.isHidden = true
         isAnimating = true
         
         // Remove existing cards
         playAreaCards.forEach { $0.removeFromParent() }
         playAreaCards.removeAll()
         
         // Draw up to 5 cards
         let cardsToDraw = min(5, currentDeck.count)
         guard cardsToDraw > 0 else {
             print("Deck is empty!")
             isAnimating = false
             return
         }
         
         // Calculate positions
         let cardSize = cardBackTexture.size()
         let scaledCardWidth = deckNode.frame.size.width
         let totalWidth = (scaledCardWidth * 5) + (playAreaPadding * 4)
         var xPosition = playAreaPosition.x - (totalWidth / 2) + (scaledCardWidth / 2)
         
         var targetPositions = [CGPoint]()
         for _ in 0..<5 {
             targetPositions.append(CGPoint(x: xPosition, y: playAreaPosition.y))
             xPosition += scaledCardWidth + playAreaPadding
         }
         
         var currentCardIndex = 0
         
         func drawNextCard() {
             guard currentCardIndex < cardsToDraw else {
                 isAnimating = false
                 return
             }
             
             let cardDef = currentDeck.removeFirst()
             updateDeckCount()
             let newCard = CardNode(texture: cardBackTexture)
             newCard.position = deckNode.position
             newCard.originalPosition = targetPositions[currentCardIndex]
             newCard.zPosition = 1
             newCard.attackValue = cardDef.value
             newCard.cardType = cardDef.element
             newCard.valueLabel.text = "\(newCard.attackValue)"
             newCard.valueLabel.isHidden = true
             
             scaleCard(newCard)
             addChild(newCard)
             playAreaCards.append(newCard)
             
             animateCard(newCard, to: targetPositions[currentCardIndex]) {
                 currentCardIndex += 1
                 drawNextCard()
             }
         }
         
         drawNextCard()
         selectedCards.removeAll()
     }

     // Updated animateCard
     func animateCard(_ card: CardNode, to position: CGPoint, completion: @escaping () -> Void) {
         let totalMoveDuration: TimeInterval = 0.6
         let flipDuration: TimeInterval = 0.3
         let originalXScale = card.xScale
         
         let moveAction = SKAction.move(to: position, duration: totalMoveDuration)
         
         let flipSequence = SKAction.sequence([
             SKAction.wait(forDuration: (totalMoveDuration/2) - (flipDuration/2)),
             SKAction.scaleX(to: 0, duration: flipDuration/2),
             SKAction.run {
                 // Reveal element and value
                 if let element = card.cardType as? String {
                     card.texture = SKTexture(imageNamed: "\(element)")
                 }
                 card.valueLabel.isHidden = false
             },
             SKAction.scaleX(to: originalXScale, duration: flipDuration/2)
         ])
         
         let popEffect = SKAction.sequence([
             SKAction.scale(to: originalXScale * 1.1, duration: 0.1),
             SKAction.scale(to: originalXScale, duration: 0.1)
         ])
         
         card.run(SKAction.group([moveAction, flipSequence])) {
             card.run(popEffect) {
                 completion()
             }
         }
     }

     func handleCardSelection(_ card: CardNode) {
         let moveDistance: CGFloat = 20
         let moveDuration: TimeInterval = 0.2
         
         guard !card.isAnimating else { return }
         
         if card.isSelected {
             // Deselect the card
             card.isAnimating = true
             let moveAction = SKAction.move(to: card.originalPosition, duration: moveDuration)
             moveAction.timingMode = .easeInEaseOut
             
             card.run(moveAction) {
                 card.isAnimating = false
                 card.isSelected = false
                 if let index = self.selectedCards.firstIndex(of: card) {
                     self.selectedCards.remove(at: index)
                 }
                 // Move update here
                 self.updateButtonVisibility()
             }
         } else {
             guard selectedCards.count < maxSelection else { return }
             
             // Select the card
             card.isAnimating = true
             let newPosition = CGPoint(x: card.position.x, y: card.originalPosition.y + moveDistance)
             let moveAction = SKAction.move(to: newPosition, duration: moveDuration)
             moveAction.timingMode = .easeInEaseOut
             
             card.run(moveAction) {
                 card.isAnimating = false
                 card.isSelected = true
                 self.selectedCards.append(card)
                 // Move update here
                 self.updateButtonVisibility()
             }
         }
     }
     
     //scale card
     func scaleCard(_ card: SKSpriteNode) {
         card.scale(to: frame.size, width: false, multiplier: 0.25)
         card.texture?.filteringMode = .nearest // For pixel art preservation
         
         if let cardNode = card as? CardNode {
             cardNode.valueLabel.fontSize = 10 * (card.xScale / 0.25)
         }
     }
 }

 */
