import SwiftUI

struct CoinCounter: View {
    let count: Int
    private static let icon = PixelArt.image(Icons.coin)

    var body: some View {
        HStack(spacing: 10) {
            Image(uiImage: Self.icon)
                .interpolation(.none)
                .resizable()
                .frame(width: 24, height: 32)
            Text("\(count)")
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.45), radius: 0, x: 2, y: 2)
        }
    }
}

struct DPad: View {
    let steer: (Direction?) -> Void
    @State private var pressed: Direction?
    private let size: CGFloat = 132
    private static let image = PixelArt.image(Icons.dpad)

    var body: some View {
        Image(uiImage: Self.image)
            .interpolation(.none)
            .resizable()
            .frame(width: size, height: size)
            .opacity(0.85)
            .offset(x: CGFloat(pressed?.vector.x ?? 0) * 4, y: CGFloat(pressed?.vector.y ?? 0) * 4)
            .frame(width: size, height: size)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { update(direction(at: $0.location)) }
                    .onEnded { _ in update(nil) }
            )
    }

    private func direction(at point: CGPoint) -> Direction? {
        let dx = point.x - size / 2
        let dy = point.y - size / 2
        guard max(abs(dx), abs(dy)) > size * 0.08 else { return nil }
        let direction: Direction = abs(dx) > abs(dy) ? (dx > 0 ? .right : .left) : (dy > 0 ? .down : .up)
        return direction
    }

    private func update(_ direction: Direction?) {
        guard direction != pressed else { return }
        pressed = direction
        steer(direction)
    }
}
