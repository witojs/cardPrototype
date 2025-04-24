//
//  GameScene.swift
//  cardPrototype
//
//  Created by Wito Irawan on 24/04/25.
//

import SpriteKit


class CardNode: SKSpriteNode {
    var isSelected = false
    var originalPosition = CGPoint.zero
    var isAnimating = false
}

class GameScene: SKScene {
    var deck: SKSpriteNode!
    let cardBackTexture = SKTexture(imageNamed: "card_back")
    let creatureTextures = [
        SKTexture(imageNamed: "card_creature_wolf"),
        SKTexture(imageNamed: "card_creature_bear"),
        SKTexture(imageNamed: "card_creature_dragon")
    ]
    
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

    override func didMove(to view: SKView) {
        deck = SKSpriteNode(texture: cardBackTexture)
        deck.position = CGPoint(x: frame.midX + 350, y: frame.midY - 100)
        scaleCard(deck)
        addChild(deck)
        
        // Setup buttons
        attackButton.position = CGPoint(x: -1000, y: -1000) // Offscreen initially
        attackButton.zPosition = 10
        attackButton.name = "attack"
        attackButton.isHidden = true
        attackButton.scale(to: frame.size, width: false, multiplier: 0.07)
        addChild(attackButton)
        
        discardButton.position = CGPoint(x: -1000, y: -1000)
        discardButton.zPosition = 10
        discardButton.name = "discard"
        discardButton.isHidden = true
        discardButton.scale(to: frame.size, width: false, multiplier: 0.07)
        addChild(discardButton)
    }
    
    func updateButtonVisibility() {
        guard let firstCard = playAreaCards.first else {
            attackButton.isHidden = true
            discardButton.isHidden = true
            return
        }
        
        if !selectedCards.isEmpty {
            // Position buttons 200 points left of first card
            let baseX = firstCard.originalPosition.x - 150
            let baseY = firstCard.originalPosition.y
            
            attackButton.position = CGPoint(x: baseX, y: baseY + 20)
            discardButton.position = CGPoint(x: baseX, y: baseY - 20)
            
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
    
    func handleAttack() {
        print("Attack with selected cards:", selectedCards)
        // Add your attack logic here
    }

    func handleDiscard() {
        print("Discard selected cards:", selectedCards)
        // Add your discard logic here
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
        
        let flipSequence = SKAction.sequence([
            SKAction.wait(forDuration: (totalMoveDuration/2) - (flipDuration/2)),
            SKAction.scaleX(to: 0, duration: flipDuration/2),
            SKAction.run { [weak self] in
                card.texture = self?.creatureTextures.randomElement()!
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
    }
}
