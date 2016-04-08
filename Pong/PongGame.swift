import Foundation
import SpriteKit

class PongGame : NSObject, SKSceneDelegate {
	
	var entities: PongEntityCollection
	var scene: PongScene
	
	var serveDirection: PongDirectionX = .Right
	
	init(withScene scene: PongScene) {
		self.scene = scene
		self.entities = PongEntityCollection(withScene: self.scene)
		
		super.init()
		self.scene.delegate = self
		
		entities.addEntity(PongPaddle(withScene: scene, startAt: .Right, name: "playerPaddle"))
		entities.addEntity(PongPaddle(withScene: scene, startAt: .Left, name: "enemyPaddle"))
		entities.addEntity(PongBall(withScene: scene, name: "ball"))
		
		serve()
	}
	
	// SKSceneDelegate
	
	func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
		entities.update(currentTime, forScene: scene)
	}
	
	func entitiesDidCollide(a: String, _ b: String, contact: SKPhysicsContact) {
		print("PongGame: entitiesDidCollide: a:\(a), b:\(b)")
		
		// Ensure that entities exist in the entity collection
		// under the given keys
		guard let entityA = entities[a] else {
			print("Entity A named `\(a)` is unregistered in entity collection. Collision not reported.")
			return
		}
		guard let entityB = entities[b] else {
			print("Entity B named `\(b)` is unregistered in entity collection. Collision not reported.")
			return
		}
		
		// If A is listening for collisions, notify it of collision with B.
		if let entityA = entityA as? PongCollisionListenerProtocol {
			entityA.didCollideWith(entityB, contact: contact)
		}
		
		// If B is also listening for collisions, notify it of collision with A.
		if let entityB = entityB as? PongCollisionListenerProtocol {
			entityB.didCollideWith(entityA, contact: contact)
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
	
	// Gameplay routines
	
	func serve() {
		// Serve the ball to the last scorer (or the right for the first serve)
		let ball = entities["ball"] as? PongBall
		switch serveDirection {
		case .Left:
			ball?.angle = π
			break
		case .Right:
			ball?.angle = 0
			break
		default:
			print("Unspecified serve direction!")
		}
	}
	
}