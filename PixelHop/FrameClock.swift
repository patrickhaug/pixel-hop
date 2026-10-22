import UIKit

final class FrameClock: NSObject {
    private let tick: (Float) -> Void
    private var link: CADisplayLink?
    private var last: CFTimeInterval = 0

    init(tick: @escaping (Float) -> Void) {
        self.tick = tick
    }

    func start() {
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    @objc private func step(_ link: CADisplayLink) {
        let dt = last == 0 ? 0 : min(link.timestamp - last, 1.0 / 20)
        last = link.timestamp
        tick(Float(dt))
    }
}
