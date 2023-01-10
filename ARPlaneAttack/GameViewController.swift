//
//  ViewController.swift
//  ARPlaneAttack
//
//  Created by Christopher Webb-Orenstein on 10/7/17.
//  Copyright © 2017 Christopher Webb-Orenstein. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SpriteKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var messagesLabel: UILabel!
    
    var placed: Bool = false

    lazy var padView1: SKView = {
        let view = SKView(frame: CGRect(x:50, y: 30, width:150, height: 150))
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var padView2: SKView = {
        let view = SKView(frame: CGRect(x:650, y: UIScreen.main.bounds.height - 200, width:150, height: 150))
        view.isMultipleTouchEnabled = true
        view.backgroundColor = .clear
        return view
    }()
    
    var session: ARSession {
        return sceneView.session
    }
    
    var planes = [ARPlaneAnchor: Plane]()
    
    /// A serial queue used to coordinate adding or removing nodes from the scene.
    let updateQueue = DispatchQueue(label: "com.example.apple-samplecode.arkitexample.serialSceneKitQueue")
    
    let focusNode = FocusSquare()
    
    @IBOutlet weak var sceneView: PlaneSceneView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.scene.rootNode.addChildNode(focusNode)
        sceneView.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        runSession()
    }
    
    func runSession() {
        sceneView.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !placed {
            let position = focusNode.lastPosition ?? float3(0)
            sceneView.airportNode.position = SCNVector3(position.x, position.y, position.z)
            self.sceneView.scene.rootNode.addChildNode(self.sceneView.airportNode)
            placed = true
            DispatchQueue.main.async {
                self.messagesLabel.text = "Rotating screen"
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.messagesLabel.isHidden = true
                    DeviceOrientation.shared.set(orientation: .landscapeLeft)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.sceneView.addSubview(self.padView1)
                        self.sceneView.addSubview(self.padView2)
                        self.setupPadScene()
                    }
                }
            }
        }
    }
    
    func setupPadScene() {
        let scene = JoystickScene()
        scene.point = CGPoint(x: 0, y: 0)
        scene.size = CGSize(width: 180, height: 170)
        scene.joystickDelegate = self
        scene.stickNum = 1
        padView1.presentScene(scene)
        padView1.ignoresSiblingOrder = true
        
        let scene2 = JoystickScene()
        scene2.point = CGPoint(x: 0, y: 0)
        scene2.size = CGSize(width: 180, height: 170)
        scene2.joystickDelegate = self
        scene.stickNum = 2
        padView2.presentScene(scene2)
        padView2.ignoresSiblingOrder = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
}


extension GameViewController: JoystickSceneDelegate {
    
    func update(xValue: Float, stickNum: Int) {
        if stickNum == 1 {
            let scaled = (xValue) * 0.00025
            sceneView.rotate(value: scaled)
        } else if stickNum == 2 {
            let scaled = -(xValue) * 0.5
            sceneView.moveSides(value: scaled)
        }
    }
    
    func update(yValue: Float, stickNum: Int) {
        if stickNum == 1 {
            let scaled = (yValue) * 0.5
            sceneView.moveForward(value: scaled)
        } else if stickNum == 2 {
            let scaled = -(yValue) * 0.5
            sceneView.changeAltitude(value: scaled)
        }
    }
}

extension GameViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
    
    func updateFocusSquare() {
        focusNode.unhide()
        // Perform ray casting only when ARKit tracking is in a good state.
        if let camera = session.currentFrame?.camera, case .normal = camera.trackingState,
            let query = sceneView.getRaycastQuery(),
            let result = sceneView.castRay(for: query).first {
            updateQueue.async {
                self.sceneView.scene.rootNode.addChildNode(self.focusNode)
                self.focusNode.state = .detecting(raycastResult: result, camera: camera)
            }
        } else {
            updateQueue.async {
                self.focusNode.state = .initializing
                self.sceneView.pointOfView?.addChildNode(self.focusNode)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateFocusSquare()
        }
        // If light estimation is enabled, update the intensity of the model's lights and the environment map
        if let lightEstimate = session.currentFrame?.lightEstimate {
            sceneView.scene.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40, queue: updateQueue)
        } else {
            sceneView.scene.enableEnvironmentMapWithIntensity(40, queue: updateQueue)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        updateQueue.async {
            self.updatePlane(anchor: planeAnchor)
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        updateQueue.async {
            self.removePlane(anchor: planeAnchor)
        }
    }
    
    
    // Override to create and configure nodes for anchors added to the view's session.
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor {
            updateQueue.async {
                self.addPlane(node: node, anchor: planeAnchor)
            }
            DispatchQueue.main.async {
                self.messagesLabel.text = "FOUND"
            }
        }
    }
}

extension GameViewController: ARSessionDelegate {
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        let plane = Plane(anchor)
        planes[anchor] = plane
        node.addChildNode(plane)
    }
    
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            plane.update(anchor)
        }
    }
            
    func removePlane(anchor: ARPlaneAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            plane.removeFromParentNode()
        }
    }
}
