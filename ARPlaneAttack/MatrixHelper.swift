//
//  MatrixHelper.swift
//  ARPlaneAttack
//
//  Created by Christopher Webb on 1/9/23.
//

import Foundation
import GLKit
import SceneKit
import ARKit
import UIKit

class MatrixHelper {
    
    static func transform(rotationY: Float, distance: Int) -> SCNMatrix4 {
        let translation = SCNMatrix4MakeTranslation(0, 0, Float(-distance))
        let rotation = SCNMatrix4MakeRotation(-1 * rotationY, 0, 1, 0)
        let transform = SCNMatrix4Mult(translation, rotation)
        return transform
    }
    
    static func translationMatrix(with matrix: matrix_float4x4, for translation : vector_float4) -> matrix_float4x4 {
        var matrix = matrix
        matrix.columns.3 = translation
        return matrix
    }
    
    static func rotateAroundY(with matrix: matrix_float4x4, for degrees: Float) -> matrix_float4x4 {
        var matrix : matrix_float4x4 = matrix
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    static func transformMatrix(for matrix: simd_float4x4, position: vector_float4, degrees: Float) -> simd_float4x4 {
        let bearing = degrees.degreesToRadians
        let translationMatrix = MatrixHelper.translationMatrix(with: matrix_identity_float4x4, for: position)
        let rotationMatrix = MatrixHelper.rotateAroundY(with: matrix_identity_float4x4, for: Float(bearing))
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        return simd_mul(matrix, transformMatrix)
    }
}

extension BinaryInteger {
    
    var degreesToRadians: CGFloat {
        CGFloat(self) * .pi / 180
    }
}

extension Double {
    
    var degreesToRadians: Self {
        self * .pi / 180
    }
    
    var radiansToDegrees: Self {
        self * 180 / .pi
    }
}

extension FloatingPoint {
    
    var degreesToRadians: Self {
        self * .pi / 180
    }
    
    var radiansToDegrees: Self {
        self * 180 / .pi
    }
}

extension float4x4 {
    
    public func toMatrix() -> SCNMatrix4 {
        return SCNMatrix4(self)
    }
    
    public var translation4: SCNVector4 {
        get {
            return SCNVector4(columns.3.x, columns.3.y, columns.3.z, columns.3.w)
        }
    }
}

extension SCNVector4 {
    
    init(_ vector: SIMD4<Float>) {
        self.init(x: vector.x, y: vector.y, z: vector.z, w: vector.w)
    }
    
    init(_ vector: SCNVector3) {
        self.init(x: vector.x, y: vector.y, z: vector.z, w: 1)
    }
}

extension SCNMatrix4 {
    public func toSimd() -> float4x4 {
        return float4x4(self)
    }
}


extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
     */
    var translation: SIMD3<Float> {
        get {
            let translation = columns.3
            return [translation.x, translation.y, translation.z]
        }
        set(newValue) {
            columns.3 = [newValue.x, newValue.y, newValue.z, columns.3.w]
        }
    }
    
    /**
     Factors out the orientation component of the transform.
     */
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    /**
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}

func nodeWithModelName(_ modelName: String) -> SCNNode {
    return SCNScene(named: modelName)!.rootNode.clone()
}
