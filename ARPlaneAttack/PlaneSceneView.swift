//
//  DroneView.swift
//  ARKitDrone
//
//  Created by Christopher Webb on 1/9/23.
//  Copyright © 2023 Christopher Webb. All rights reserved.
//

import ARKit
import SceneKit

class PlaneSceneView: ARSCNView {
    
    var planeNode: SCNNode!
    var planeModel: SCNNode!
    var airportNode: SCNNode!

    func setup() {
        scene = SCNScene()
        planeModel = nodeWithModelName("art.scnassets/Fighter.scn")
        planeNode = planeModel.childNode(withName: "F-35B_Lightning_II", recursively: true)
        airportNode = nodeWithModelName("art.scnassets/airfield.scn")
      // planeNode = scene.rootNode.childNode(withName: "F_35B_Lightning_II", recursively: true)
    }
    
    func positionAirport(node: SCNNode, anchor: ARAnchor) {
        self.airportNode.position = SCNVector3(anchor.transform.translation4.x, anchor.transform.translation4.y, anchor.transform.translation4.z)
//        if let anchor = anchor {
//            
//            //SCNVector3Make(anchor.center.x, 0, anchor.center.z)
//        }
        // Create a new anchor with the object's current transform and add it to the session
//        let newAnchor = ARAnchor(transform: object.simdWorldTransform)
//        object.anchor = newAnchor
//        session.add(anchor: newAnchor)
//        self.markerOne = self.airportNode.childNode(withName: "markerOne", recursively: true)
//        self.markerTwo = self.airportNode.childNode(withName: "markerTwo", recursively: true)
//        self.scene.rootNode.addChildNode(self.airportNode!)
//        if let anchor = anchor {
//            self.airportNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
//        }
//        self.setupPlane()
//        self.planeNode.position = SCNVector3(self.airportNode.position.x - 0.005, self.markerOne.position.y - 0.285, self.markerTwo.position.z + 0.5)
//        self.planeNode.orientation = self.airportNode.orientation
    }

    func startEngine() {
 
    }

    func rotate(value: Float) {
        if (value > 0.5) || (value < -0.5) {
            print(value)
        }
        SCNTransaction.begin()
        let (x, y, z, w) = SCNQuaternion.angleConversion(x: 0, y:0, z:  value * Float(Double.pi), w: 0)
        planeNode.localRotate(by: SCNQuaternion(x, y, z, w))
        SCNTransaction.commit()
    }
    
    func moveForward(value: Float) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.25
        planeNode.localTranslate(by: SCNVector3(x: 0, y: value, z: 0))
        SCNTransaction.commit()
    }
    
    func changeAltitude(value: Float) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.25
        planeNode.position = SCNVector3(planeNode.position.x, planeNode.position.y, planeNode.position.z + value)
        SCNTransaction.commit()
    }


    func moveSides(value: Float) {
       
    }

}
