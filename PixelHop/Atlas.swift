import UIKit

struct Atlas {
    static let shared = Atlas()

    private static let cell = Textures.size + 2
    private static let shades = Face.allCases.count

    let image: UIImage
    private let width: Float
    private let entries: [String: Int]

    private init() {
        let solid = Palette.colors.keys.sorted().map { key in
            ("color-\(key)", Array(repeating: String(repeating: key, count: Textures.size), count: Textures.size))
        }
        let list = Textures.all.sorted { $0.key < $1.key }.map { ($0.key, $0.value) } + solid
        entries = Dictionary(uniqueKeysWithValues: list.enumerated().map { ($1.0, $0) })
        let cells = list.count * Self.shades
        width = Float(cells * Self.cell)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        image = UIGraphicsImageRenderer(size: CGSize(width: cells * Self.cell, height: Self.cell), format: format).image { context in
            for (index, entry) in list.enumerated() {
                let grid = entry.1.map { Array($0) }
                for face in Face.allCases {
                    let left = (index * Self.shades + face.rawValue) * Self.cell
                    for y in 0..<Self.cell {
                        let row = grid[min(max(y - 1, 0), grid.count - 1)]
                        for x in 0..<Self.cell {
                            Palette.color(row[min(max(x - 1, 0), row.count - 1)], brightness: face.brightness).setFill()
                            context.fill(CGRect(x: left + x, y: y, width: 1, height: 1))
                        }
                    }
                }
            }
        }
    }

    func uvs(_ texture: String, face: Face, height: Float = 1) -> [SIMD2<Float>] {
        let left = Float(cellIndex(texture, face) * Self.cell)
        let u0 = (left + 1) / width
        let u1 = (left + Float(Self.cell) - 1) / width
        let v0 = 1 / Float(Self.cell)
        let v1 = 1 - v0
        let bottom = v1 - min(height, 1) * (v1 - v0)
        return [[u0, bottom], [u0, v1], [u1, v1], [u1, bottom]]
    }

    func uv(_ key: Character, face: Face) -> SIMD2<Float> {
        let left = Float(cellIndex("color-\(key)", face) * Self.cell)
        return [(left + Float(Self.cell) / 2) / width, 0.5]
    }

    private func cellIndex(_ name: String, _ face: Face) -> Int {
        entries[name, default: 0] * Self.shades + face.rawValue
    }
}
