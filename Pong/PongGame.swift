import Foundation
import SpriteKit

class PongGame : NSObject, SKSceneDelegate {
	
	var entities: PongEntityCollection
	var scene: PongScene
	
	init(withScene scene: PongScene) {
		self.scene = scene
		self.entities = PongEntityCollection(withScene: self.scene)
		
		super.init()
		self.scene.delegate = self
		
		entities.addEntity(PongPaddle(withScene: scene, startAt: .Right),
		                        withName: "playerPaddle")
	}
	
	// SKSceneDelegate
	
	func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
		entities.update(currentTime, forScene: scene)
	}
	
	// Player movement functions
	
	func startPlayerMovement(direction: PongDirection) {
		if var player = entities["playerPaddle"] as? PongDirectionProtocol {
			player.direction = direction
		}
	}
	
	func stopPlayerMovement() {
		if var player = entities["playerPaddle"] as? PongDirectionProtocol {
			player.direction = .None
		}
	}
	
}