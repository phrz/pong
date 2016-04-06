//
//  PongEntityCollection.swift
//  Pong
//
//  Created by Paul Herz on 4/5/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import SpriteKit

class PongEntityCollection {
	
	var entities = [String: PongEntity]()
	let scene: SKScene
	
	init(withScene scene: SKScene) {
		self.scene = scene
	}
	
	func addEntity(entity: PongEntity) {
		self.entities[entity.name] = entity
		let spriteEntity = entity as? PongSpriteNodeProtocol
		if let spriteNode = spriteEntity?.node {
			self.scene.addChild(spriteNode)
		}
	}
	
	subscript(index: String) -> PongEntity? {
		get {
			return self.entities[index]
		}
		set(newEntity) {
			if let newEntity = newEntity {
				self.addEntity(newEntity)
			}
		}
	}
	
	func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
		for (_, entity) in entities {
			entity.update(currentTime, forScene: scene)
		}
	}
	
}