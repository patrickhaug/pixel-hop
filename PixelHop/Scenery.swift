import Metal
import RealityKit
import UIKit

enum Scenery {
    enum Failure: Error {
        case missingImage
    }

    static func pixelMaterial(_ image: UIImage) async throws -> UnlitMaterial {
        let sampler = MTLSamplerDescriptor()
        sampler.minFilter = .nearest
        sampler.magFilter = .nearest
        sampler.mipFilter = .notMipmapped
        var material = UnlitMaterial(applyPostProcessToneMap: false)
        material.color = UnlitMaterial.BaseColor(
            tint: .white,
            texture: MaterialParameters.Texture(try await texture(image, named: "atlas"), sampler: MaterialParameters.Texture.Sampler(sampler))
        )
        material.faceCulling = .none
        return material
    }

    static func shadow() throws -> ModelEntity {
        var builder = MeshBuilder()
        for x in -4...3 {
            for z in -4...3 {
                let center = SIMD2<Float>(Float(x) + 0.5, Float(z) + 0.5)
                guard (center * center).sum() <= 16 else { continue }
                builder.quad(
                    Face.top.corners.map { SIMD3<Float>((Float(x) + $0.x) * 0.1, 0.01, (Float(z) + $0.z) * 0.1) },
                    normal: Face.top.normal,
                    uvs: Array(repeating: .zero, count: 4)
                )
            }
        }
        var material = UnlitMaterial(color: .black)
        material.blending = .transparent(opacity: .init(scale: 0.28))
        return ModelEntity(mesh: try builder.resource(named: "shadow"), materials: [material])
    }

    static func backdrop() async throws -> ModelEntity {
        var material = UnlitMaterial(applyPostProcessToneMap: false)
        material.color = UnlitMaterial.BaseColor(tint: .white, texture: MaterialParameters.Texture(try await texture(skyImage(), named: "sky")))
        material.faceCulling = .none
        let plane = ModelEntity(mesh: .generatePlane(width: 400, height: 160), materials: [material])
        plane.position = [0, 0, -120]
        return plane
    }

    private static func texture(_ image: UIImage, named name: String) async throws -> TextureResource {
        guard let cgImage = image.cgImage else { throw Failure.missingImage }
        return try await TextureResource(image: cgImage, withName: name, options: .init(semantic: .color, mipmapsMode: .none))
    }

    private static func skyImage() -> UIImage {
        let top: [CGFloat] = [0.49, 0.78, 0.95]
        let horizon: [CGFloat] = [1, 0.88, 0.72]
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: 1, height: 64), format: format).image { context in
            for y in 0..<64 {
                let t = CGFloat(y) / 63
                let mix = zip(top, horizon).map { $0 + ($1 - $0) * t }
                UIColor(red: mix[0], green: mix[1], blue: mix[2], alpha: 1).setFill()
                context.fill(CGRect(x: 0, y: y, width: 1, height: 1))
            }
        }
    }
}
