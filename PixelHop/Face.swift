import CoreGraphics

enum Face: Int, CaseIterable {
    case top, south, west, east, north, bottom

    static let sides: [Face] = [.south, .west, .east, .north]

    var brightness: CGFloat {
        switch self {
        case .top: 1
        case .south: 0.86
        case .west: 0.78
        case .east: 0.68
        case .north: 0.6
        case .bottom: 0.5
        }
    }

    var normal: SIMD3<Float> {
        SIMD3<Float>(offset)
    }

    var offset: SIMD3<Int> {
        switch self {
        case .top: [0, 1, 0]
        case .south: [0, 0, 1]
        case .west: [-1, 0, 0]
        case .east: [1, 0, 0]
        case .north: [0, 0, -1]
        case .bottom: [0, -1, 0]
        }
    }

    var corners: [SIMD3<Float>] {
        switch self {
        case .top: [[0, 1, 1], [0, 1, 0], [1, 1, 0], [1, 1, 1]]
        case .south: [[0, 0, 1], [0, 1, 1], [1, 1, 1], [1, 0, 1]]
        case .west: [[0, 0, 0], [0, 1, 0], [0, 1, 1], [0, 0, 1]]
        case .east: [[1, 0, 1], [1, 1, 1], [1, 1, 0], [1, 0, 0]]
        case .north: [[1, 0, 0], [1, 1, 0], [0, 1, 0], [0, 0, 0]]
        case .bottom: [[0, 0, 0], [0, 0, 1], [1, 0, 1], [1, 0, 0]]
        }
    }
}
