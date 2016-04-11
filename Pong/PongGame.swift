import Foundation
import SpriteKit

let collisionNotificationKey = "com.paulherz.PongCollision"
let outOfBoundsNotificationKey = "com.paulherz.PongOutOfBounds"

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
	let soundManager: PongSoundManager
	
	var isFirstServe: Bool = true
	
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
		self.soundManager = PongSoundManager(withScene: scene)
		// Score Labels: not edited directly, but modified by
		// the setters in playerscore/enemyscore
		_playerScoreLabel = ScoreLabelNode(side: .Right, scene: scene)
		_enemyScoreLabel = ScoreLabelNode(side: .Left, scene: scene)
		scene.addChild(_playerScoreLabel)
		scene.addChild(_enemyScoreLabel)
		
		super.init()
		self.scene.delegate = self
		
		// Add the paddles
		let playerPaddle = PongPaddle(withScene: scene, startAt: .Right,
		                              name: "playerPaddle")
		entities.addEntity(playerPaddle)
		
		let enemyPaddle = PongPaddle(withScene: scene, startAt: .Left,
		                             name: "enemyPaddle")
		entities.addEntity(enemyPaddle)
		
		// the ball
		let ball = PongBall(withScene: scene, name: "ball")
		entities.addEntity(ball)
		
		// Add the AI
		entities.addEntity(PongBasicPlayer(paddle: enemyPaddle, ball: ball,
										   name: "computer"))
		
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
			let side = ball.outOfBounds
			ball.outOfBounds = .None
			handleOutOfBounds(side)
		}
	}
	
	func handleOutOfBounds(side: PongDirectionX) {
		guard shouldHandleOutOfBounds else { return }
		shouldHandleOutOfBounds = false
		
		let oobNotification = NSNotification(
			name: outOfBoundsNotificationKey,
			object: self
		)
		
		NSNotificationCenter.defaultCenter().postNotification(oobNotification)
		
		switch side {
		case .Left:
			print("PongGame: Out of Bounds on Left")
			playerScore += 1
			serveDirection = .Right // player gets next serve
			break
		case .Right:
			print("PongGame: Out of Bounds on Right")
			enemyScore += 1
			serveDirection = .Left // enemy gets next serve
			break
		default:
			print("PongGame: Unexpected out of bounds case!")
			break
		}
		
		serve()
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
		
		// Broadcast collision event
		let entitySet: Set<String> = Set(arrayLiteral: entityA.name, entityB.name)
		
		let collisionNotification = NSNotification(
			name: collisionNotificationKey,
			object: self,
			userInfo: [
				"entities": entitySet
			]
		)
		
		NSNotificationCenter.defaultCenter().postNotification(collisionNotification)
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
		
		var serveY: CGFloat
		var angleDeviation: Double = 0.0
		
		if(isFirstServe) {
			// First serve from middle
			isFirstServe = false
			serveY = self.scene.frame.midY
		} else {
			// Serve Y position should be randomised within a certain
			// range of deviation. First we produce a random float 0.0...1.0
			let randomRatio = Float(arc4random()) / Float(UINT32_MAX)
			// We define max deviation distance from centre to be
			// a quarter of the field height
			let maxDeviation = self.scene.frame.height * 0.5
			// We calculate deviation by multiplying the random percent by
			// the max deviation, then biasing it so half of all random deviations
			// will be negative (below the middle)
			let deviation = CGFloat(randomRatio) * maxDeviation - (0.5*maxDeviation)
			// We offset the serve Y from centre
			serveY = self.scene.frame.midY - deviation
			print("Serving at height \(serveY)")
			
			// Now deviate the angle of the serve (0...π/3)
			let randomRatioForAngle = Double(arc4random()) / Double(UINT32_MAX)
			let angleDeviationMax: Double = 2 * π / 5
			angleDeviation = angleDeviationMax * randomRatioForAngle - (0.5*angleDeviationMax)
		}
		
		guard let ball = entities["ball"] as? PongBall else {
			print("Could not type cast PongBall in serve()")
			return
		}
		
		ball.node!.position = CGPoint(x: self.scene.frame.midX, y: serveY)
		ball.node!.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
		// Serve the ball to the last scorer (or the right for the first serve)
		switch serveDirection {
		case .Left:
			ball.angle = π - angleDeviation
			break
		case .Right:
			ball.angle = 0 + angleDeviation
			break
		default:
			print("Unspecified serve direction!")
		}
		
		shouldHandleOutOfBounds = true
	}
	
}