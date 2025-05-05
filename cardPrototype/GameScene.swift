//
//  GameScene.swift
//  cardPrototype
//
//  Created by Wito Irawan on 24/04/25.
//

import SpriteKit

// MARK: - Card Definitions
struct CardDefinition {
    let element: String
    let value: Int
    var texture: SKTexture { SKTexture(imageNamed: element) }
}

// MARK: - CardNode
class CardNode: SKSpriteNode {
    // MARK: Properties
    var isSelected = false
    var originalPosition = CGPoint.zero
    var isAnimating = false
    var attackValue: Int = 0
    var cardType: String = ""
    let valueLabel = SKLabelNode(fontNamed: "Arial Bold")  // Made internal for access

    // MARK: Initialization
    init(texture: SKTexture?) {
        super.init(texture: texture, color: .clear, size: texture?.size() ?? .zero)
        setupLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Label Setup
    private func setupLabel() {
        valueLabel.fontSize = 40
        valueLabel.fontColor = .white
        valueLabel.position = CGPoint(x: 0, y: -40)
        valueLabel.zPosition = 1
        addChild(valueLabel)
    }
}


// MARK: - GameScene
class GameScene: SKScene {
    // MARK: Deck Properties
    private var deck: [CardDefinition] = []
    private var discardPile: [CardDefinition] = []
    private var currentDeck: [CardDefinition] = []
    private let cardBackTexture = SKTexture(imageNamed: "card_back")
    private var deckNode: SKSpriteNode!
    private let deckCountLabel = SKLabelNode(fontNamed: "Arial Bold")

    // MARK: Buttons & Selection
    private let attackButton = SKSpriteNode(imageNamed: "attack_button")
    private let discardButton = SKSpriteNode(imageNamed: "discard_button")
    private var playAreaCards = [CardNode]()
    private var selectedCards = [CardNode]()
    private let maxSelection = 4
    private let cardInHand = 6
    private let playAreaPadding: CGFloat = 4
    private var playAreaPosition: CGPoint { CGPoint(x: frame.midX, y: frame.midY - 100) }

    // MARK: Boss Properties
    private var bossSprite = SKSpriteNode(imageNamed: "boss")
    private var bossHealth: Int = 100
    private let bossMaxHealth: Int = 100
    private var bossHealthBar = SKNode()
    private var bossHealthLabel = SKLabelNode()

    // MARK: Labels & State
    private let victoryLabel = SKLabelNode(fontNamed: "Arial Bold")
    private var attackChances = 4
    private let chancesLabel = SKLabelNode(fontNamed: "Arial Bold")
    private var discardLeft = 3
    private let discardLeftLabel = SKLabelNode(fontNamed: "Arial Bold")
    private let comboInfoLabel = SKLabelNode(fontNamed: "Arial Bold")
    private let gameOverLabel = SKLabelNode(fontNamed: "Arial Bold")
    private var isAnimating = false

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        initializeDeck()
        setupDeckNode()
        setupButtons()
        setupBoss()
        setupLabels()
        updateButtonVisibility()
    }

    // MARK: - Deck Management
    private func initializeDeck() {
        deck.removeAll()
        let elements = ["fire", "water", "wind", "earth"]
        for element in elements {
            for value in 1...10 {
                deck.append(CardDefinition(element: element, value: value))
            }
        }
        currentDeck = deck.shuffled()
        updateDeckCount()
    }

    private func updateDeckCount() {
        deckCountLabel.text = "\(currentDeck.count)/40"
    }

    private func setupDeckNode() {
        deckNode = SKSpriteNode(texture: cardBackTexture)
        deckNode.position = CGPoint(x: frame.midX + 350, y: frame.midY - 100)
        scaleCard(deckNode)
        addChild(deckNode)

        deckCountLabel.fontSize = 24
        deckCountLabel.fontColor = .white
        deckCountLabel.position = CGPoint(x: deckNode.position.x, y: deckNode.position.y + 50)
        addChild(deckCountLabel)
    }

    // MARK: - Buttons Setup
    private func setupButtons() {
        let buttonY: CGFloat = frame.midY - 10
        attackButton.name = "attack"
        discardButton.name = "discard"

        [attackButton, discardButton].forEach { button in
            button.zPosition = 10
            button.scale(to: frame.size, width: false, multiplier: 0.07)
            button.isHidden = true
            addChild(button)
        }
        attackButton.position = CGPoint(x: frame.midX - 50, y: buttonY)
        discardButton.position = CGPoint(x: frame.midX + 50, y: buttonY)
    }

    // MARK: - Button Visibility
    private func updateButtonVisibility() {
        let hasSelection = !selectedCards.isEmpty

        // Attack button only when you have a selection
        attackButton.isHidden = !hasSelection

        // Discard button also only when you have a selection…
        discardButton.isHidden = !hasSelection

        if discardLeft == 0 {
            discardButton.color = .gray
            discardButton.colorBlendFactor = 0.7
        } else {
            discardButton.colorBlendFactor = 0
        }
    }


    // MARK: - Boss Setup
    private func setupBoss() {
        bossSprite.position = CGPoint(x: frame.midX, y: frame.height - 150)
        bossSprite.zPosition = 5
        bossSprite.scale(to: frame.size, width: false, multiplier: 0.5)
        addChild(bossSprite)

        let barWidth: CGFloat = 150, barHeight: CGFloat = 10
        let backgroundBar = SKSpriteNode(color: .red, size: CGSize(width: barWidth, height: barHeight))
        backgroundBar.position = CGPoint(x: 0, y: 120)

        let healthBar = SKSpriteNode(color: .green, size: CGSize(width: barWidth, height: barHeight))
        healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBar.position = CGPoint(x: -barWidth/2, y: 120)
        healthBar.name = "healthBar"

        bossHealthBar.addChild(backgroundBar)
        bossHealthBar.addChild(healthBar)
        bossHealthBar.position = bossSprite.position
        addChild(bossHealthBar)

        bossHealthLabel.text = "\(bossHealth)/\(bossMaxHealth)"
        bossHealthLabel.fontSize = 24
        bossHealthLabel.fontColor = .white
        bossHealthLabel.position = CGPoint(x: 0, y: 90)
        bossHealthBar.addChild(bossHealthLabel)
    }

    // MARK: - Labels Setup
    private func setupLabels() {
        chancesLabel.text = "Attacks Left: \(attackChances)"
        chancesLabel.fontSize = 30
        chancesLabel.fontColor = .white
        chancesLabel.horizontalAlignmentMode = .left
        chancesLabel.position = CGPoint(x: 50, y: frame.height - 100)
        addChild(chancesLabel)
        
        // Discard left label below chances
        discardLeftLabel.text = "Discards Left: \(discardLeft)"
        discardLeftLabel.fontSize = 30
        discardLeftLabel.fontColor = .white
        discardLeftLabel.horizontalAlignmentMode = .left
        discardLeftLabel.position = CGPoint(x: 50, y: chancesLabel.position.y - 50)
        addChild(discardLeftLabel)
        
        comboInfoLabel.text = ""
        comboInfoLabel.fontSize = 24
        comboInfoLabel.fontColor = .yellow
        comboInfoLabel.horizontalAlignmentMode = .left
        comboInfoLabel.position = CGPoint(x: 50, y: discardLeftLabel.position.y - 40)
        addChild(comboInfoLabel)
    }

    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if !selectedCards.isEmpty {
            if attackButton.contains(location) { handleAttack(); return }
            if discardButton.contains(location) {
                // only allow if still have discards left
                guard discardLeft > 0 else { return }
                handleDiscard(); return
            }
        }
        for card in playAreaCards where card.contains(location) && !card.isAnimating && !isAnimating {
            handleCardSelection(card); return
        }
        if !isAnimating && deckNode.contains(location) {
            drawCardsFromDeck()
        }
    }

    // MARK: - Card Selection
    private func handleCardSelection(_ card: CardNode) {
        let moveDur: TimeInterval = 0.2
        if card.isSelected {
            deselect(card, duration: moveDur)
        } else {
            select(card, duration: moveDur)
        }
    }

    private func select(_ card: CardNode, duration: TimeInterval) {
        guard selectedCards.count < maxSelection else { return }
        card.isAnimating = true
        let up = CGPoint(x: card.position.x, y: card.originalPosition.y + 20)
        let move = SKAction.move(to: up, duration: duration)
        move.timingMode = .easeInEaseOut
        card.run(move) {
            card.isAnimating = false
            card.isSelected = true
            self.selectedCards.append(card)
            self.updateButtonVisibility()
            self.updateComboInfo()
        }
    }

    private func deselect(_ card: CardNode, duration: TimeInterval) {
        card.isAnimating = true
        let move = SKAction.move(to: card.originalPosition, duration: duration)
        move.timingMode = .easeInEaseOut
        card.run(move) {
            card.isAnimating = false
            card.isSelected = false
            self.selectedCards.removeAll { $0 == card }
            self.updateButtonVisibility()
            self.updateComboInfo()
        }
    }

    // MARK: - Draw & Replace Cards
    private func drawCardsFromDeck() {
        attackButton.isHidden = true
        discardButton.isHidden = true
        isAnimating = true

        playAreaCards.forEach { $0.removeFromParent() }
        playAreaCards.removeAll()
        selectedCards.removeAll()

        let count = min(cardInHand, currentDeck.count)
        guard count > 0 else { isAnimating = false; return }

        let cardWidth = deckNode.frame.width
        let totalWidth = (cardWidth * CGFloat(count)) + (playAreaPadding * CGFloat(count - 1))
        var x = playAreaPosition.x - (totalWidth / 2) + (cardWidth / 2)
        var positions = [CGPoint]()
        for _ in 0..<count {
            positions.append(CGPoint(x: x, y: playAreaPosition.y))
            x += cardWidth + playAreaPadding
        }

        animateDrawing(at: positions, index: 0)
    }

    private func animateDrawing(at positions: [CGPoint], index: Int) {
        guard index < positions.count else { isAnimating = false; return }
        let def = currentDeck.removeFirst()
        updateDeckCount()
        let card = CardNode(texture: cardBackTexture)
        card.position = deckNode.position
        card.originalPosition = positions[index]
        card.attackValue = def.value
        card.cardType = def.element
        card.valueLabel.text = "\(def.value)"
        card.valueLabel.isHidden = true
        scaleCard(card)
        addGlow(to: card)
        addChild(card)
        playAreaCards.append(card)

        animateCard(card, to: positions[index]) {
            self.animateDrawing(at: positions, index: index + 1)
        }
    }

    private func replaceSelectedCards() {
        guard !selectedCards.isEmpty else { return }
        let positions = selectedCards.map { $0.originalPosition }
        selectedCards.forEach { card in
            discardPile.append(CardDefinition(element: card.cardType, value: card.attackValue))
            let move = SKAction.group([.moveBy(x: 1000, y: 0, duration: 0.5), .fadeOut(withDuration: 0.3)])
            card.run(.sequence([move, .removeFromParent()]))
        }
        playAreaCards.removeAll(where: { selectedCards.contains($0) })
        selectedCards.removeAll()
        animateReplacement(at: positions, remaining: positions.count)
    }

    private func animateReplacement(at positions: [CGPoint], remaining: Int) {
        var left = remaining
        for pos in positions {
            guard !currentDeck.isEmpty else {
                left -= 1
                if left == 0 { isAnimating = false; updateDeckCount() }
                continue
            }
            let def = currentDeck.removeFirst()
            updateDeckCount()
            let card = CardNode(texture: cardBackTexture)
            card.position = deckNode.position
            card.originalPosition = pos
            card.attackValue = def.value
            card.cardType = def.element
            card.valueLabel.text = "\(def.value)"
            card.valueLabel.isHidden = true
            scaleCard(card)
            addGlow(to: card)
            addChild(card)
            playAreaCards.append(card)

            animateCard(card, to: pos) {
                left -= 1
                if left == 0 { self.isAnimating = false }
            }
        }
    }

    // MARK: - Attack & Discard
    private func handleAttack() {
        guard !selectedCards.isEmpty else { return }
        attackChances -= 1
        chancesLabel.text = "Attacks Left: \(attackChances)"

        let base = selectedCards.reduce(0) { $0 + $1.attackValue }
        let (name, mult) = evaluateCombo(for: selectedCards)
        let total = Int(Double(base) * mult)
        print("Attack: \(name) ×\(mult) → Base = \(base), Damage = \(total)")
        
        updateBossHealth(damage: total)
        replaceSelectedCards()
        updateDeckCount()
        updateButtonVisibility()

        if attackChances <= 0 && bossHealth > 0 { showGameOver() }
    }

    private func handleDiscard() {
        guard !selectedCards.isEmpty else { return }
        
        discardLeft = max(0, discardLeft - 1)
        discardLeftLabel.text = "Discards Left: \(discardLeft)"
        if discardLeft == 0 {
            discardButton.color = .gray
            discardButton.colorBlendFactor = 0.7
        }
        
        replaceSelectedCards()
        updateDeckCount()
        updateButtonVisibility()
    }

    // MARK: - Boss & Endgame
    private func showGameOver() {
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 100
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.zPosition = 20
        gameOverLabel.setScale(0)

        addChild(gameOverLabel)
        gameOverLabel.run(.sequence([.unhide(), .scale(to: 1.2, duration: 0.5), .scale(to: 0.9, duration: 0.3), .scale(to: 1.0, duration: 0.2)]))
        isUserInteractionEnabled = false
    }

    private func updateBossHealth(damage: Int) {
        bossHealth = max(0, bossHealth - damage)
        if let healthBar = bossHealthBar.childNode(withName: "healthBar") as? SKSpriteNode {
            let ratio = CGFloat(bossHealth) / CGFloat(bossMaxHealth)
            healthBar.run(.scaleX(to: ratio, duration: 0.2))
        }
        bossHealthLabel.text = "\(bossHealth)/\(bossMaxHealth)"
        if bossHealth <= 0 { bossDefeated() }
    }

    private func bossDefeated() {
        victoryLabel.text = "You Win!"
        victoryLabel.fontSize = 100
        victoryLabel.fontColor = .yellow
        victoryLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        victoryLabel.zPosition = 20
        victoryLabel.setScale(0)

        addChild(victoryLabel)
        victoryLabel.run(.sequence([.unhide(), .scale(to: 1.2, duration: 0.5), .scale(to: 0.9, duration: 0.2), .scale(to: 1.0, duration: 0.2)]))
        isUserInteractionEnabled = false
    }
    
    // MARK: - Combo Info Update
    private func updateComboInfo() {
        guard !selectedCards.isEmpty else {
            comboInfoLabel.text = ""
            return
        }
        let base = selectedCards.reduce(0) { $0 + $1.attackValue }
        let (name, mult) = evaluateCombo(for: selectedCards)
        let damage = Int(Double(base) * mult)
        comboInfoLabel.text = "\(name): \(damage)"
    }

    // MARK: - Evaluate Combo
    private func evaluateCombo(for cards: [CardNode]) -> (String, Double) {
        let n = cards.count
        let values = cards.map { $0.attackValue }
        let elements = cards.map { $0.cardType }
        let valueCounts = Dictionary(grouping: values, by: { $0 }).mapValues { $0.count }
        let elementCounts = Dictionary(grouping: elements, by: { $0 }).mapValues { $0.count }
        let isSameValue = valueCounts.values.contains(n)

        switch n {
        case 1:
            return ("Basic Spell", 1.0)
        case 2:
            if isSameValue { return ("Double Spell", 1.5) }
            let set = Set(elements)
            switch set {
            case Set(["fire","water"]): return ("Steam", 1.1)
            case Set(["earth","wind"]): return ("Sandstorm", 1.1)
            case Set(["fire","wind"]): return ("Heat", 1.2)
            case Set(["fire","earth"]): return ("Lava", 1.2)
            case Set(["water","wind"]): return ("Storm", 1.2)
            case Set(["water","earth"]): return ("Nature", 1.2)
            default: return ("Basic Spell", 1.0)
            }
        case 3:
            if elementCounts.values.contains(3) { return ("Triple Spell", 2.0) }
            if Set(elements).count == 3 && isSameValue { return ("Synergy", 2.2) }
            return ("Basic Spell", 1.0)
        case 4:
            if elementCounts.values.contains(4) { return ("Quad Spell", 2.5) }
            if Set(elements).count == 4 && isSameValue { return ("Harmony", 2.0) }
            let doubles = elementCounts.filter { $0.value == 2 }.map { $0.key }
            if doubles.count == 2 {
                let combo = Set(doubles)
                switch combo {
                case Set(["fire","water"]): return ("Double Steam", 1.5)
                case Set(["earth","wind"]): return ("Double Sandstorm", 1.5)
                case Set(["fire","wind"]): return ("Double Heat", 2.0)
                case Set(["fire","earth"]): return ("Double Lava", 2.0)
                case Set(["water","wind"]): return ("Double Storm", 2.0)
                case Set(["water","earth"]): return ("Double Nature", 2.0)
                default: break
                }
            }
            return ("Basic Spell", 1.0)
        default:
            return ("Basic Spell", 1.0)
        }
    }


    private func scaleCard(_ card: SKSpriteNode) {
        card.scale(to: frame.size, width: false, multiplier: 0.25)
        card.texture?.filteringMode = .nearest
        if let cardNode = card as? CardNode {
            cardNode.valueLabel.fontSize = 10 * (card.xScale / 0.25)
        }
    }

    private func animateCard(_ card: CardNode, to position: CGPoint, completion: @escaping () -> Void) {
        let moveDuration: TimeInterval = 0.6
        let half = moveDuration / 2
        let flipDuration: TimeInterval = 0.3
        let originalScale = card.xScale

        let move = SKAction.move(to: position, duration: moveDuration)
        let flip = SKAction.sequence([
            .wait(forDuration: half - flipDuration/2),
            .scaleX(to: 0, duration: flipDuration/2),
            .run { card.texture = SKTexture(imageNamed: card.cardType); card.valueLabel.isHidden = false },
            .scaleX(to: originalScale, duration: flipDuration/2)
        ])
        let pop = SKAction.sequence([.scale(to: originalScale * 1.1, duration: 0.1), .scale(to: originalScale, duration: 0.1)])

        card.run(.group([move, flip])) {
            card.run(pop) { completion() }
        }
    }
    
    private func addGlow(to card: SKSpriteNode) {
        // 1) compute the real, scaled size of the card
        let targetSize = CGSize(width: card.frame.width + 30,
                                height: card.frame.height + 40)

        // 2) make a rectangular shape with sharp corners
        let glow = SKShapeNode(rectOf: targetSize, cornerRadius: 0)
        glow.name = "glow"
        glow.strokeColor = .yellow
        glow.lineWidth = 4
        glow.glowWidth = 4
        glow.zPosition = card.zPosition - 1

        // 3) center it on the card
        glow.position = CGPoint.zero
        card.addChild(glow)
        
        // Animate alpha for pulsing glow effect
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        let pulse = SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn]))
        glow.run(pulse)
    }
}

