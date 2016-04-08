import Foundation
import SpriteKit

class ScoreLabelNode: SKLabelNode {
	init(side: PongDirectionX, scene: SKScene) {
		
		super.init()
		
		var shift: CGFloat = 100
		if(side == .Left) { shift *= -1 }
		
		self.fontName = "Helvetica"
		self.fontSize = 30
		self.text = "0"
		self.color = SKColor.whiteColor()
		self.position = CGPoint(x: scene.frame.midX + shift, y: scene.frame.height - 100)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class PongGame : NSObject, SKSceneDelegate {
	
	var entities: PongEntityCollection
	var scene: PongScene
	
	var serveDirection: PongDirectionX = .Right
	var shouldHandleOutOfBounds = true
	
	
	// Score tracking and display
	var _playerScore = 0
	var _enemyScore = 0
	
	let _playerScoreLabel: ScoreLabelNode
	let _enemyScoreLabel: ScoreLabelNode
	
	var playerScore: Int {
		get {
			return _playerScore
		}
		set(newScore) {
			_playerScore = newScore
			_playerScoreLabel.text = String(_playerScore)
		}
	}
	
	var enemyScore: Int {
		get {
			return _enemyScore
		}
		set(newScore) {
			_enemyScore = newScore
			_enemyScoreLabel.text = String(_enemyScore)
		}
	}
	// END SCORE TRACKING
	
	
	init(withScene scene: PongScene) {
		self.scene = scene
		self.entities = PongEntityCollection(withScene: self.scene)
		
		// Score Labels: not edited directly, but modified by
		// the setters in playerscore/enemyscore
		_playerScoreLabel = ScoreLabelNode(side: .Right, scene: scene)
		_enemyScoreLabel = ScoreLabelNode(side: .Left, scene: scene)
		scene.addChild(_playerScoreLabel)
		scene.addChild(_enemyScoreLabel)
		
		super.init()
		self.scene.delegate = self
		
		entities.addEntity(PongPaddle(withScene: scene, startAt: .Right, name: "playerPaddle"))
		entities.addEntity(PongPaddle(withScene: scene, startAt: .Left, name: "enemyPaddle"))
		entities.addEntity(PongBall(withScene: scene, name: "ball"))
		
		// dummy entity for the scene so collisions with it get reported
		// to the other entity
		entities.addEntity(PongEntity(withName: "pongScene"))
		
		serve()
	}
	
	// SKSceneDelegate
	
	func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
		entities.update(currentTime, forScene: scene)
	}
	
	func didFinishUpdateForScene(scene: SKScene) {
		if(self.scene != scene) {
			return
		}
		// check ball out of bounds
		let ball = entities["ball"] as! PongBall
		
		if ball.outOfBounds != .None {
			handleOutOfBounds(ball.outOfBounds)
		}
	}
	
	func handleOutOfBounds(side: PongDirectionX) {
		guard shouldHandleOutOfBounds else { return }
		shouldHandleOutOfBounds = false
		
		switch side {
		case .Left:
			print("OOB on Left")
			break
		case .Right:
			print("OOB on Right")
			break
		default:
			print("Unexpected out of bounds case!")
			break
		}
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
		
		playerScore += 1
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