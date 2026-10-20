import SpriteKit
import UIKit

final class GameScene: SKScene {
    private static let worldHeight: CGFloat = 100
    private let walkSpeed: CGFloat = 40

    private let hero = SKSpriteNode(texture: Sprites.heroFrames[Direction.down.rawValue][0])
    private let coins = SKNode()
    private let coinCounter = SKNode()
    private let cameraNode = SKCameraNode()
    private let dpad = SKSpriteNode(texture: Sprites.dpad)
    private var dpadTouch: UITouch?
    private var lastTime: TimeInterval = 0
    private var facing = Direction.down
    private var heading: Direction? {
        didSet {
            guard heading != oldValue else { return }
            if let heading { facing = heading }
            animateHero()
        }
    }
    private var coinCount = UserDefaults.standard.integer(forKey: "coins") {
        didSet { UserDefaults.standard.set(coinCount, forKey: "coins") }
    }

    private enum Direction: Int {
        case up, right, down, left

        var vector: CGVector {
            switch self {
            case .up: CGVector(dx: 0, dy: 1)
            case .right: CGVector(dx: 1, dy: 0)
            case .down: CGVector(dx: 0, dy: -1)
            case .left: CGVector(dx: -1, dy: 0)
            }
        }
    }

    init(viewSize: CGSize) {
        let aspect = viewSize.height > 0 ? viewSize.width / viewSize.height : 2
        super.init(size: CGSize(width: (Self.worldHeight * aspect).rounded(), height: Self.worldHeight))
        scaleMode = .aspectFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundColor = Palette.color("k")
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func didMove(to view: SKView) {
        guard hero.parent == nil else { return }
        let world = SKSpriteNode(texture: Sprites.world(WorldMap.rows))
        world.anchorPoint = .zero
        addChild(world)
        addChild(coins)
        WorldMap.centers(of: "C").forEach { spawnCoin(at: $0) }
        hero.position = WorldMap.centers(of: "@").first ?? CGPoint(x: WorldMap.size.width / 2, y: WorldMap.size.height / 2)
        addChild(hero)
        camera = cameraNode
        addChild(cameraNode)
        buildHud()
        followHero()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard dpadTouch == nil, let touch = touches.first(where: { $0.location(in: cameraNode).x < 0 }) else { return }
        dpadTouch = touch
        steer(with: touch)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let dpadTouch, touches.contains(dpadTouch) else { return }
        steer(with: dpadTouch)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let dpadTouch, touches.contains(dpadTouch) else { return }
        self.dpadTouch = nil
        heading = nil
        dpad.position = dpadHome
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastTime == 0 ? 0 : CGFloat(min(currentTime - lastTime, 1.0 / 30))
        lastTime = currentTime
        if let heading { walk(heading, by: walkSpeed * dt) }
        followHero()
        let reach = hero.frame.insetBy(dx: 2, dy: 2)
        for coin in coins.children where reach.intersects(coin.frame) {
            collect(coin)
        }
    }

    private var dpadHome: CGPoint {
        CGPoint(x: -size.width / 2 + 16, y: -size.height / 2 + 14)
    }

    private var dpadCenter: CGPoint {
        CGPoint(x: dpadHome.x + 10.5, y: dpadHome.y + 10.5)
    }

    private func steer(with touch: UITouch) {
        let location = touch.location(in: cameraNode)
        let dx = location.x - dpadCenter.x
        let dy = location.y - dpadCenter.y
        guard max(abs(dx), abs(dy)) > 3 else {
            heading = nil
            dpad.position = dpadHome
            return
        }
        let direction: Direction = abs(dx) > abs(dy) ? (dx > 0 ? .right : .left) : (dy > 0 ? .up : .down)
        heading = direction
        dpad.position = CGPoint(x: dpadHome.x + direction.vector.dx, y: dpadHome.y + direction.vector.dy)
    }

    private func walk(_ direction: Direction, by step: CGFloat) {
        let vector = direction.vector
        let ahead = CGPoint(x: hero.position.x + vector.dx * step, y: hero.position.y + vector.dy * step)
        if !isBlocked(ahead) {
            hero.position = ahead
            return
        }
        let lane = vector.dx == 0 ? hero.position.x : hero.position.y
        let laneCenter = (lane / WorldMap.tileSize).rounded(.down) * WorldMap.tileSize + WorldMap.tileSize / 2
        let shift = max(-step, min(step, laneCenter - lane))
        let slide = vector.dx == 0
            ? CGPoint(x: hero.position.x + shift, y: hero.position.y)
            : CGPoint(x: hero.position.x, y: hero.position.y + shift)
        if !isBlocked(slide) { hero.position = slide }
    }

    private func isBlocked(_ center: CGPoint) -> Bool {
        let half: CGFloat = 3
        return [(-half, -half), (half, -half), (-half, half), (half, half)].contains { dx, dy in
            WorldMap.isBlocked(CGPoint(x: center.x + dx, y: center.y + dy))
        }
    }

    private func followHero() {
        let x = min(max(hero.position.x, size.width / 2), WorldMap.size.width - size.width / 2)
        let y = min(max(hero.position.y, size.height / 2), WorldMap.size.height - size.height / 2)
        cameraNode.position = CGPoint(x: x, y: y)
    }

    private func animateHero() {
        let frames = Sprites.heroFrames[facing.rawValue]
        hero.removeAllActions()
        hero.texture = frames[0]
        if heading != nil {
            hero.run(.repeatForever(.animate(with: frames, timePerFrame: 0.15)))
        }
    }

    private func buildHud() {
        let coinIcon = SKSpriteNode(texture: Sprites.coin)
        coinIcon.anchorPoint = .zero
        coinIcon.position = CGPoint(x: -size.width / 2 + 10, y: size.height / 2 - 14)
        cameraNode.addChild(coinIcon)
        coinCounter.position = CGPoint(x: -size.width / 2 + 19, y: size.height / 2 - 12)
        cameraNode.addChild(coinCounter)
        updateCoinCounter()
        dpad.anchorPoint = .zero
        dpad.alpha = 0.85
        dpad.position = dpadHome
        cameraNode.addChild(dpad)
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
}
