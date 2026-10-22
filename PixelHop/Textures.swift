enum Textures {
    static let all: [String: [String]] = [
        "grass": [
            "gggggggggg",
            "ggggggglgg",
            "gggggglggg",
            "gggggggggg",
            "gggggggggg",
            "glgggggggg",
            "lggggggggg",
            "gggggggggg",
            "ggggglgggg",
            "gggggggggg",
        ],
        "flowers": [
            "gggggggggg",
            "ggwggggggg",
            "gwywgggggg",
            "ggwggggggg",
            "gggggggggg",
            "gggggggrgg",
            "ggggggryrg",
            "gggggggrgg",
            "gggggggggg",
            "gggggggggg",
        ],
        "path": [
            "yyyyyyyyyy",
            "yyyyoyyyyy",
            "yyyyyyyyyy",
            "yoyyyyyyyy",
            "yyyyyyyoyy",
            "yyyyyyyyyy",
            "yyyoyyyyyy",
            "yyyyyyyyyy",
            "yyyyyyyyoy",
            "yyyyyyyyyy",
        ],
        "planks": [
            "pppppppppp",
            "yyypyyypyy",
            "ooopooopoo",
            "ooopooopoo",
            "ooopooopoo",
            "ooopooopoo",
            "ooopooopoo",
            "ooopooopoo",
            "ooopooopoo",
            "pppppppppp",
        ],
        "water": [
            "bbbbbbbbbb",
            "bbsbbbbbbb",
            "bsbsbbbbbb",
            "bbbbbbbbbb",
            "bbbbbbsbbb",
            "bbbbbsbsbb",
            "bbbbbbbbbb",
            "bbbbbbbbbb",
            "bbsbbbbbbb",
            "bsbsbbbbbb",
        ],
        "earth": [
            "gglggglggg",
            "gggggggggg",
            "guggguggug",
            "uuuguuuuuu",
            "uuuuuuhuuu",
            "uhuuuuuuuu",
            "uuuuuuuuhu",
            "uuuhuuuuuu",
            "uuuuuuhuuu",
            "huuuuuuuuu",
        ],
        "sandEarth": [
            "yyyyyoyyyy",
            "yyoyyyyyyy",
            "yuyyyuyyuy",
            "uuuyuuuuuu",
            "uuuuuuhuuu",
            "uhuuuuuuuu",
            "uuuuuuuuhu",
            "uuuhuuuuuu",
            "uuuuuuhuuu",
            "huuuuuuuuu",
        ],
        "planksSide": [
            "pppppppppp",
            "yyyyyyyyyy",
            "oooooooooo",
            "oooooooooo",
            "pppppppppp",
            "yyyyyyyyyy",
            "oooooooooo",
            "oooooooooo",
            "pppppppppp",
            "pppppppppp",
        ],
    ]
}

struct Block {
    let top: String
    let side: String
    let height: Float
    let solid: Bool

    static func of(_ tile: Character) -> Block {
        kinds[tile] ?? grass
    }

    private static let grass = Block(top: "grass", side: "earth", height: 0, solid: false)

    private static let kinds: [Character: Block] = [
        "T": Block(top: "grass", side: "earth", height: 0, solid: true),
        "R": Block(top: "grass", side: "earth", height: 0, solid: true),
        "*": Block(top: "flowers", side: "earth", height: 0, solid: false),
        "=": Block(top: "path", side: "sandEarth", height: 0, solid: false),
        "#": Block(top: "planks", side: "planksSide", height: 0, solid: false),
        "~": Block(top: "water", side: "water", height: -0.2, solid: true),
    ]
}
