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
    private let jumpButton = SKSpriteNode(texture: Sprites.jumpButton)
    private var velocity: CGFloat = 0
    private var lastTime: TimeInterval = 0
    private var distance: CGFloat = 0
    private var nextObstacle: CGFloat = 60
    private var crashTime: TimeInterval?

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
        hero.anchorPoint = CGPoint(x: 0.5, y: 0)
        hero.position = CGPoint(x: 36, y: groundY)
        addChild(hero)
        jumpButton.anchorPoint = .zero
        jumpButton.position = CGPoint(x: size.width - 17, y: buttonY)
        addChild(jumpButton)
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
        for obstacle in obstacles.children {
            obstacle.position.x -= step
            if obstacle.frame.maxX < 0 { obstacle.removeFromParent() }
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
        obstacle.position = CGPoint(x: size.width, y: groundY)
        obstacles.addChild(obstacle)
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
