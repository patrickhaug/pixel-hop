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
    static let hero = heroRun[0]

    static let heroRun = [
        texture(heroBody + ["..gg..gg..", ".gg....gg."]),
        texture(heroBody + ["...gg.gg..", "..gg.gg..."]),
    ]

    private static let heroBody = [
        "..ww..ww..",
        ".wkw.wkw..",
        ".gggggggg.",
        "gggggggggk",
        "gglllllgg.",
        ".glllllgg.",
    ]

    static let obstacles = [
        texture([
            "....eeee....",
            "..eewwweee..",
            ".eewweeeeed.",
            "eeweeeeeeedd",
            "eeeeeeeeeddd",
            "deeeeeeedddd",
            ".dddddddddd.",
        ]),
        texture([
            "...rrrr...",
            ".rrwwrrrr.",
            "rrwwrrrrwr",
            "rrrrrrrrrr",
            "rwwrrrwwrr",
            ".rrrrrrrr.",
            "..wwwwww..",
            "..wkwwkw..",
            "..wwwwww..",
            "..wwwwww..",
            "..eeeeee..",
        ]),
        texture([
            "ooooooooo",
            "oyyyyyyyo",
            "oyryyyryo",
            "oyyryryyo",
            "oyyyryyyo",
            "oyyryryyo",
            "oyryyyryo",
            "oyyyyyyyo",
            "ooooooooo",
        ]),
    ]

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

    static let jumpButton = texture([
        ".ooooooooooo.",
        "oyyyyyyyyyyyo",
        "oyyyyykyyyyyo",
        "oyyyykkkyyyyo",
        "oyyykkkkkyyyo",
        "oyykkkkkkkyyo",
        "oyyyykkkyyyyo",
        "oyyyykkkyyyyo",
        "oyyyyyyyyyyyo",
        "orrrrrrrrrrro",
        ".ooooooooooo.",
    ])

    static let ground = texture((0..<20).map { y in
        String((0..<16).map { x -> Character in
            switch y {
            case 0: "l"
            case 1: x % 5 == 0 ? "l" : "g"
            default: (x * 7 + y * 3) % 11 == 0 ? "d" : "m"
            }
        })
    })

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
