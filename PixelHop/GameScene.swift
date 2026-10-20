import SpriteKit
import UIKit

final class GameScene: SKScene {
    private static let worldHeight: CGFloat = 100
    private let groundY: CGFloat = 20
    private let gravity: CGFloat = 600
    private let jumpSpeed: CGFloat = 185
    private let runSpeed: CGFloat = 70
    private let buttonY: CGFloat = 5

    private let hero = SKSpriteNode(texture: Sprites.hero)
    private let ground = SKNode()
    private let obstacles = SKNode()
    private let coins = SKNode()
    private let coinCounter = SKNode()
    private let jumpButton = SKSpriteNode(texture: Sprites.jumpButton)
    private var velocity: CGFloat = 0
    private var lastTime: TimeInterval = 0
    private var distance: CGFloat = 0
    private var nextObstacle: CGFloat = 60
    private var crashTime: TimeInterval?
    private var coinCount = UserDefaults.standard.integer(forKey: "coins") {
        didSet { UserDefaults.standard.set(coinCount, forKey: "coins") }
    }

    init(viewSize: CGSize) {
        let aspect = viewSize.height > 0 ? viewSize.width / viewSize.height : 2
        super.init(size: CGSize(width: (Self.worldHeight * aspect).rounded(), height: Self.worldHeight))
        scaleMode = .aspectFill
        anchorPoint = .zero
        backgroundColor = Palette.color("n")
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func didMove(to view: SKView) {
        guard hero.parent == nil else { return }
        buildGround()
        addChild(obstacles)
        addChild(coins)
        hero.anchorPoint = CGPoint(x: 0.5, y: 0)
        hero.position = CGPoint(x: 36, y: groundY)
        addChild(hero)
        jumpButton.anchorPoint = .zero
        jumpButton.position = CGPoint(x: size.width - 17, y: buttonY)
        addChild(jumpButton)
        let coinIcon = SKSpriteNode(texture: Sprites.coin)
        coinIcon.anchorPoint = .zero
        coinIcon.position = CGPoint(x: 10, y: size.height - 14)
        addChild(coinIcon)
        coinCounter.position = CGPoint(x: 19, y: size.height - 12)
        addChild(coinCounter)
        updateCoinCounter()
        startRunning()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pressButton()
        if let crashTime {
            if lastTime - crashTime > 0.6 { restart() }
            return
        }
        guard hero.position.y <= groundY else { return }
        velocity = jumpSpeed
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastTime == 0 ? 0 : CGFloat(min(currentTime - lastTime, 1.0 / 30))
        lastTime = currentTime
        velocity -= gravity * dt
        hero.position.y = max(groundY, hero.position.y + velocity * dt)
        if hero.position.y <= groundY { velocity = 0 }
        guard crashTime == nil else { return }
        scroll(by: runSpeed * dt)
    }

    private func scroll(by step: CGFloat) {
        distance += step
        ground.position.x = -distance.truncatingRemainder(dividingBy: Sprites.ground.size().width)
        if distance >= nextObstacle { spawnObstacle() }
        for node in obstacles.children + coins.children {
            node.position.x -= step
            if node.frame.maxX < 0 { node.removeFromParent() }
        }
        for coin in coins.children where hero.frame.intersects(coin.frame) {
            collect(coin)
        }
        let hitBox = hero.frame.insetBy(dx: 2, dy: 1)
        if obstacles.children.contains(where: { hitBox.intersects($0.frame.insetBy(dx: 1, dy: 1)) }) {
            crash()
        }
    }

    private func spawnObstacle() {
        nextObstacle = distance + CGFloat.random(in: 90...170)
        guard let texture = Sprites.obstacles.randomElement() else { return }
        let obstacle = SKSpriteNode(texture: texture)
        obstacle.anchorPoint = .zero
        obstacle.position = CGPoint(x: size.width + 16, y: groundY)
        obstacles.addChild(obstacle)
        let arc: [(dx: CGFloat, dy: CGFloat)] = [(-14, 20), (0, 32), (14, 20)]
        for (dx, dy) in arc {
            spawnCoin(at: CGPoint(x: obstacle.frame.midX.rounded() + dx, y: groundY + dy))
        }
    }

    private func spawnCoin(at position: CGPoint) {
        let coin = SKSpriteNode(texture: Sprites.coin)
        coin.position = position
        coin.run(.repeatForever(.animate(with: Sprites.coinSpin, timePerFrame: 0.12)))
        coins.addChild(coin)
    }

    private func collect(_ coin: SKNode) {
        coin.move(toParent: self)
        coin.run(.sequence([
            .group([.moveBy(x: 0, y: 8, duration: 0.25), .fadeOut(withDuration: 0.25)]),
            .removeFromParent(),
        ]))
        coinCount += 1
        updateCoinCounter()
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }

    private func updateCoinCounter() {
        coinCounter.removeAllChildren()
        for (i, digit) in String(coinCount).compactMap(\.wholeNumberValue).enumerated() {
            let sprite = SKSpriteNode(texture: Sprites.digits[digit])
            sprite.anchorPoint = .zero
            sprite.position.x = CGFloat(i * 4)
            coinCounter.addChild(sprite)
        }
    }

    private func crash() {
        crashTime = lastTime
        hero.removeAllActions()
        hero.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.2, duration: 0.1),
            .fadeAlpha(to: 1, duration: 0.1),
        ])))
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    private func restart() {
        crashTime = nil
        obstacles.removeAllChildren()
        coins.removeAllChildren()
        nextObstacle = distance + 60
        hero.removeAllActions()
        hero.alpha = 1
        startRunning()
    }

    private func startRunning() {
        hero.run(.repeatForever(.animate(with: Sprites.heroRun, timePerFrame: 0.12)))
    }

    private func pressButton() {
        jumpButton.removeAllActions()
        jumpButton.position.y = buttonY - 1
        jumpButton.run(.sequence([.wait(forDuration: 0.12), .moveTo(y: buttonY, duration: 0)]))
    }

    private func buildGround() {
        let width = Sprites.ground.size().width
        (0...Int(size.width / width) + 1).forEach { i in
            let tile = SKSpriteNode(texture: Sprites.ground)
            tile.anchorPoint = .zero
            tile.position = CGPoint(x: CGFloat(i) * width, y: 0)
            ground.addChild(tile)
        }
        addChild(ground)
    }
}
