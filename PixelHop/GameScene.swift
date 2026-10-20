import SpriteKit
import UIKit

final class GameScene: SKScene {
    private static let worldHeight: CGFloat = 100
    private let groundY: CGFloat = 20
    private let gravity: CGFloat = 600
    private let jumpSpeed: CGFloat = 185

    private let hero = SKSpriteNode(texture: Sprites.hero)
    private var velocity: CGFloat = 0
    private var lastTime: TimeInterval = 0

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
        hero.anchorPoint = CGPoint(x: 0.5, y: 0)
        hero.position = CGPoint(x: 36, y: groundY)
        addChild(hero)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    }

    private func buildGround() {
        let width = Sprites.ground.size().width
        (0...Int(size.width / width)).forEach { i in
            let tile = SKSpriteNode(texture: Sprites.ground)
            tile.anchorPoint = .zero
            tile.position = CGPoint(x: CGFloat(i) * width, y: 0)
            addChild(tile)
        }
    }
}
