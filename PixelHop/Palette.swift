import UIKit

enum Palette {
    static let colors: [Character: UIColor] = [
        "k": UIColor(hex: 0x1a1c2c),
        "p": UIColor(hex: 0x5d275d),
        "r": UIColor(hex: 0xb13e53),
        "o": UIColor(hex: 0xef7d57),
        "y": UIColor(hex: 0xffcd75),
        "l": UIColor(hex: 0xa7f070),
        "g": UIColor(hex: 0x38b764),
        "t": UIColor(hex: 0x257179),
        "n": UIColor(hex: 0x29366f),
        "b": UIColor(hex: 0x3b5dc9),
        "s": UIColor(hex: 0x41a6f6),
        "c": UIColor(hex: 0x73eff7),
        "w": UIColor(hex: 0xf4f4f4),
        "e": UIColor(hex: 0x94b0c2),
        "d": UIColor(hex: 0x566c86),
        "m": UIColor(hex: 0x333c57),
        "u": UIColor(hex: 0x9a6340),
        "h": UIColor(hex: 0x6b4130),
        "i": UIColor(hex: 0xf5a3be),
    ]

    static func color(_ key: Character, brightness: CGFloat = 1) -> UIColor {
        guard let color = colors[key] else { return .clear }
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: red * brightness, green: green * brightness, blue: blue * brightness, alpha: alpha)
    }
}

enum PixelArt {
    static func image(_ rows: [String]) -> UIImage {
        let width = rows.map(\.count).max() ?? 1
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        return UIGraphicsImageRenderer(size: CGSize(width: width, height: rows.count), format: format).image { context in
            for (y, row) in rows.enumerated() {
                for (x, key) in row.enumerated() where key != "." {
                    Palette.color(key).setFill()
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
    }
}

private extension UIColor {
    convenience init(hex: Int) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255,
            alpha: 1
        )
    }
}
