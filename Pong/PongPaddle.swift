import Foundation
import SpriteKit

enum PongPaddlePosition {
	case Left, Right
}

class PongPaddle: PongEntity, PongSpriteNodeProtocol, PongDirectionProtocol, PongCollisionListenerProtocol {
	
	var node: SKSpriteNode?
	
	let defaultWidth: CGFloat = 10
	let defaultHeight: CGFloat = 70
	let padding: CGFloat = 50
	
	var direction: PongDirection = .None
	var velocityMultiplier: CGFloat = 300
	
	init(withScene scene: SKScene, startAt position: PongPaddlePosition, name: String) {
		
		super.init(withName: name)
		
		// Create the paddle sprite
		let paddleSize = CGSize(width: defaultWidth, height: defaultHeight)
		node = SKSpriteNode(color: SKColor.whiteColor(), size: paddleSize)
		node?.name = name
		// Set the anchor point to the sprite centre rather than
		// the relative cartesian origin
		node?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		
		// Position it either left-centre or right-centre
		switch position {
		case .Left:
			node!.position = CGPoint(x: padding,
			                         y: scene.frame.midY)
		case .Right:
			node!.position = CGPoint(x: scene.frame.width - padding,
			                         y: scene.frame.midY)
		}
		
		// Physics properties
		node!.physicsBody = SKPhysicsBody(rectangleOfSize: node!.frame.size, center: CGPointZero)
		node!.physicsBody?.affectedByGravity = false
		node!.physicsBody?.dynamic = true
		node!.physicsBody?.friction = 0
		node!.physicsBody?.angularDamping = 0
		node!.physicsBody?.linearDamping = 0
		node!.physicsBody?.restitution = 0
		
		// Collision/contact rules
		node!.physicsBody?.categoryBitMask = PhysicsCategory.paddle
		node!.physicsBody?.collisionBitMask = PhysicsCategory.scene
		node!.physicsBody?.contactTestBitMask = PhysicsCategory.scene | PhysicsCategory.ball
	}
	
	func didCollideWith(entity: PongEntity, contact: SKPhysicsContact) {
		print("PongPaddle: didCollideWith: \(entity.name)")
		if entity.name == "ball" {
			let ball = entity as! PongBall
			ball.angle = ball.angle + M_PI
		}
	}
	
	override func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
		let deltaY = direction.rawValue * velocityMultiplier
		node?.physicsBody?.velocity = CGVector(dx: 0.0, dy: deltaY)
	}
	
}