//
//  JoystickSKScene.swift
//  ARPlaneAttack
//
//  Created by Derrick Liu on 12/14/14.
//  Copyright (c) 2014 TheSneakyNarwhal. All rights reserved.


import SpriteKit

class JoystickScene: SKScene {
    
    weak var joystickDelegate: JoystickSceneDelegate?
    
    var stickNum: Int = 0
    var velocity: Float = 0
    
    var point = CGPoint(x: 0, y: 0)
    
    lazy var joystick: Joystick = {
        var joystick = Joystick()
        joystick.position = CGPointMake(90, 85)
        return joystick
    }()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        setupJoystick()
    }
    
    func setupNodes() {
        anchorPoint = point
    }
    
    func setupJoystick() {
        self.addChild(joystick)
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        if joystick.velocity.x != 0 || joystick.velocity.y != 0 {
            if abs(joystick.velocity.x) < abs(joystick.velocity.y) {
                joystickDelegate?.update(yValue: Float(joystick.velocity.y), stickNum: stickNum)
            } else {
                joystickDelegate?.update(xValue: Float(joystick.velocity.x), stickNum: stickNum)
            }
        }
    }
}
