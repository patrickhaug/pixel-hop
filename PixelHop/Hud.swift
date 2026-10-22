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

struct Hearts: View {
    let count: Int
    private static let full = PixelArt.image(Icons.heart)
    private static let empty = PixelArt.image(Icons.emptyHeart)

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<Adventure.maxHearts, id: \.self) { index in
                Image(uiImage: index < count ? Self.full : Self.empty)
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 27, height: 24)
            }
        }
    }
}

struct EnergyBar: View {
    let level: Double

    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle().fill(Color(red: 0.2, green: 0.24, blue: 0.34))
            Rectangle()
                .fill(Color(red: 0.45, green: 0.94, blue: 0.97))
                .frame(width: 84 * level)
        }
        .frame(width: 84, height: 12)
        .overlay(Rectangle().stroke(Color(red: 0.1, green: 0.11, blue: 0.17), lineWidth: 3))
    }
}

struct FlyButton: View {
    let flying: Bool
    let action: () -> Void
    private static let icon = PixelArt.image(Icons.wings)

    var body: some View {
        Button(action: action) {
            Image(uiImage: Self.icon)
                .interpolation(.none)
                .resizable()
                .frame(width: 80, height: 50)
                .padding(10)
                .background(Circle().fill(flying ? Color(red: 0.45, green: 0.94, blue: 0.97).opacity(0.85) : Color.black.opacity(0.25)))
        }
        .accessibilityLabel(flying ? "Landen" : "Fliegen")
    }
}

struct QuestBanner: View {
    let label: String
    let arrow: Double
    private static let icon = PixelArt.image(Icons.arrow)

    var body: some View {
        HStack(spacing: 10) {
            Image(uiImage: Self.icon)
                .interpolation(.none)
                .resizable()
                .frame(width: 27, height: 27)
                .rotationEffect(.degrees(arrow))
            Text(label)
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.16, green: 0.21, blue: 0.44).opacity(0.92)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white, lineWidth: 3))
    }
}

struct TalkButton: View {
    let action: () -> Void
    private static let icon = PixelArt.image(Icons.bubble)

    var body: some View {
        Button(action: action) {
            Image(uiImage: Self.icon)
                .interpolation(.none)
                .resizable()
                .frame(width: 96, height: 72)
        }
        .accessibilityLabel("Reden")
    }
}

struct DialogBox: View {
    let dialog: Game.Dialog

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dialog.title)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(Color(red: 1, green: 0.8, blue: 0.46))
            Text(dialog.text)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: 480, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.16, green: 0.21, blue: 0.44).opacity(0.92)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white, lineWidth: 3))
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
        if direction != nil { Cue.steer.play() }
        pressed = direction
        steer(direction)
    }
}
