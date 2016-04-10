//
//  PongSoundManager.swift
//  Pong
//
//  Created by Paul Herz on 4/10/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import SpriteKit

class PongSoundManager {
	let soundFiles = [
		"ballHitWall": "ballHitWall.wav",
		"ballHitPaddle": "ballHitPaddle.wav",
		"ballMiss": "ballMiss.wav"
	]
	
	var sounds = [String: SKAction]()
	
	let scene: SKScene
	
	init(withScene scene: SKScene) {
		
		self.scene = scene
		
		for (soundName, soundFileName) in soundFiles {
			let action = SKAction.playSoundFileNamed(soundFileName, waitForCompletion: false)
			sounds[soundName] = action
		}
		
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(PongSoundManager.collisionNotificationHandler),
			name: collisionNotificationKey,
			object: nil
		)
		
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(PongSoundManager.outOfBoundsNotificationHandler),
			name: outOfBoundsNotificationKey,
			object: nil
		)
	}
	
	func playSound(name: String) {
		print("PongSoundManager.playSound: Playing sound \(name)")
		self.scene.runAction(sounds[name]!)
	}
	
	@objc func collisionNotificationHandler(notification: NSNotification) {
		
		guard let userInfo = notification.userInfo as? [String: Set<String>] else {
			print("Could not type cast userInfo")
			return
		}
		
		guard let entityNameSet = userInfo["entities"] else {
			print(notification.userInfo)
			print("Could not get entity set")
			return
		}
		
		let ballHitWallCase = Set(arrayLiteral: "pongScene", "ball")
		let ballHitPaddleACase = Set(arrayLiteral: "playerPaddle", "ball")
		let ballHitPaddleBCase = Set(arrayLiteral: "enemyPaddle", "ball")
		
		if(entityNameSet == ballHitWallCase) {
			print("PongSoundManager.collisionNotificationHandler: ballHitWallCase")
			playSound("ballHitWall")
		} else if(entityNameSet == ballHitPaddleACase || entityNameSet == ballHitPaddleBCase) {
			print("PongSoundManager.collisionNotificationHandler: ballHitPaddleCase")
			playSound("ballHitPaddle")
		}
	}
	
	@objc func outOfBoundsNotificationHandler() {
		playSound("ballMiss")
	}
}