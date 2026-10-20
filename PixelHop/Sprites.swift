import SpriteKit
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
    ]

    static func color(_ key: Character) -> UIColor {
        colors[key] ?? .clear
    }
}

enum Sprites {
    static let heroFrames: [[SKTexture]] = (0..<4).map { turns in
        heroSteps.map { texture(rotated($0, turns: turns)) }
    }

    private static let heroSteps = [
        [
            "..........",
            "...w..w...",
            "..wkggkw..",
            "g.gggggg.g",
            "gggllllggg",
            "..gllllg..",
            "..gllllg..",
            "gggggggggg",
            "g.g....g.g",
            "..........",
        ],
        [
            "..........",
            "...w..w...",
            "..wkggkw..",
            "..gggggg..",
            "gggllllggg",
            "g.gllllg.g",
            "..gllllg..",
            "..gggggg..",
            ".gg....gg.",
            "..........",
        ],
    ]

    private static func rotated(_ rows: [String], turns: Int) -> [String] {
        (0..<turns).reduce(rows) { rows, _ in
            let grid = rows.map { Array($0) }
            return (0..<(grid.first?.count ?? 0)).map { x in
                String(grid.reversed().map { $0[x] })
            }
        }
    }

    static let coin = coinSpin[0]

    static let coinSpin = [coinFront, coinTurn, coinSide, coinTurn]

    private static let coinFront = texture([
        ".oooo.",
        "oyyyyo",
        "oywyyo",
        "oywyyo",
        "oywyyo",
        "oywyyo",
        "oyyyyo",
        ".oooo.",
    ])

    private static let coinTurn = texture([
        "..oo..",
        ".oyyo.",
        ".owyo.",
        ".owyo.",
        ".owyo.",
        ".owyo.",
        ".oyyo.",
        "..oo..",
    ])

    private static let coinSide = texture([
        "..oo..",
        "..yo..",
        "..yo..",
        "..yo..",
        "..yo..",
        "..yo..",
        "..yo..",
        "..oo..",
    ])

    static let digits = [
        ["www", "w.w", "w.w", "w.w", "www"],
        [".w.", "ww.", ".w.", ".w.", "www"],
        ["www", "..w", "www", "w..", "www"],
        ["www", "..w", ".ww", "..w", "www"],
        ["w.w", "w.w", "www", "..w", "..w"],
        ["www", "w..", "www", "..w", "www"],
        ["www", "w..", "www", "w.w", "www"],
        ["www", "..w", "..w", ".w.", ".w."],
        ["www", "w.w", "www", "w.w", "www"],
        ["www", "w.w", "www", "..w", "www"],
    ].map { texture($0) }

    static let dpad = texture([
        ".......kkkkkkk.......",
        ".......kmmmmmk.......",
        ".......kmmemmk.......",
        ".......kmeeemk.......",
        ".......keeeeek.......",
        ".......kmmmmmk.......",
        ".......kmmmmmk.......",
        "kkkkkkkmmmmmmmkkkkkkk",
        "kmmmemmmmmmmmmmmemmmk",
        "kmmeemmmmmmmmmmmeemmk",
        "kmeeemmmmmmmmmmmeeemk",
        "kmmeemmmmmmmmmmmeemmk",
        "kmmmemmmmmmmmmmmemmmk",
        "kkkkkkkmmmmmmmkkkkkkk",
        ".......kmmmmmk.......",
        ".......kmmmmmk.......",
        ".......keeeeek.......",
        ".......kmeeemk.......",
        ".......kmmemmk.......",
        ".......kmmmmmk.......",
        ".......kkkkkkk.......",
    ])

    static func texture(_ rows: [String]) -> SKTexture {
        let width = rows.map(\.count).max() ?? 1
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let size = CGSize(width: width, height: rows.count)
        let image = UIGraphicsImageRenderer(size: size, format: format).image { context in
            for (y, row) in rows.enumerated() {
                for (x, key) in row.enumerated() where key != "." {
                    Palette.color(key).setFill()
                    context.fill(CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .nearest
        return texture
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
