import SpriteKit

extension Sprites {
    static func world(_ map: [String]) -> SKTexture {
        texture(map.flatMap { line in
            (0..<grass.count).map { y in
                String(line.flatMap { tiles[$0, default: grass][y] })
            }
        })
    }

    private static let tiles: [Character: [String]] = [
        ".": grass,
        "C": grass,
        "@": grass,
        "*": [
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
        "T": [
            "ggkkkkkkgg",
            "gkttllttkg",
            "kttllgtttk",
            "ktllgttttk",
            "ktlgtttttk",
            "kttttttttk",
            "gkttttttkg",
            "ggkkttkkgg",
            "ggggppgggg",
            "gggggggggg",
        ],
        "R": [
            "gggggggggg",
            "ggddddddgg",
            "gdeewweedg",
            "deewweeeed",
            "deweeeeedd",
            "deeeeeeddd",
            "ddeeeedddd",
            "gddddddddg",
            "ggddddddgg",
            "gggggggggg",
        ],
        "~": [
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
        "=": [
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
        "#": [
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
    ]

    private static let grass = [
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
    ]
}
