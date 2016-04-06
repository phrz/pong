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
		
		entities.addEntity(PongPaddle(withScene: scene, startAt: .Right, name: "playerPaddle"))
		entities.addEntity(PongPaddle(withScene: scene, startAt: .Left, name: "enemyPaddle"))
		entities.addEntity(PongBall(withScene: scene, name: "ball"))
		let ball = entities["ball"] as? PongBall
		ball?.angle = 0*M_PI
	}
	
	// SKSceneDelegate
	
	func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
		entities.update(currentTime, forScene: scene)
	}
	
	func entitiesDidCollide(a: String, _ b: String, contact: SKPhysicsContact) {
		print("PongGame: entitiesDidCollide: a:\(a), b:\(b)")
		if let entityA = entities[a] as? PongCollisionListenerProtocol {
			entityA.didCollideWith(entities[b]!,contact: contact)
		}
		if let entityB = entities[b] as? PongCollisionListenerProtocol {
			entityB.didCollideWith(entities[a]!,contact: contact)
		}
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