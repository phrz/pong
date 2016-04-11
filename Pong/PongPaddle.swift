import Foundation
import SpriteKit

let π = M_PI

enum PongPaddlePosition {
	case Left, Right
}

class PongPaddle: PongEntity, PongSpriteNodeProtocol, PongDirectionProtocol, PongCollisionListenerProtocol {
	
	var node: SKSpriteNode?
	
	let defaultWidth: CGFloat = 10
	let defaultHeight: CGFloat = 70
	let padding: CGFloat = 50
	
	let position: PongPaddlePosition

	// For the angle that the ball reflects away at, we don't
	// follow any physical standard. Instead, at the moment of
	// collision with paddle, the centre Y position of the ball
	// is subtracted by the paddle's centre Y to get Δy, which is
	// a negative, positive, or zero scalar.
	//
	// The reflectiveRange property below, `R`, represents the highest
	// or lowest point of the paddle with an angle change. It is a measure
	// of scene-units away from the Y-centre of the paddle. Up until that
	// distance, the angle of reflection will become more severe.
	let reflectiveRange: CGFloat = 25
	
	let reflectiveAngleMax: Double = π/5 // the max reflection from
	// the incoming incident angle, either positive or negative.
	
	var direction: PongDirection = .None
	var velocityMultiplier: CGFloat = 500
	
	init(withScene scene: SKScene, startAt position: PongPaddlePosition, name: String) {
		
		self.position = position
		
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
			// Get the contact point Y (absolute in coord. system)
			// Note: the actual SKPhysicsContact is not reliable for
			// rectangle-to-rectangle collision. Instead, get the Y of
			// the ball itself.
			let absoluteY = ball.node!.position.y
			
			// Get the point Y relative to the paddle's anchor point
			// (positive is above the center, negative is below
			let relativeY = absoluteY - node!.position.y
			
			// The percent, positive (above) or negative (below) of reflection
			// that should be imparted on the ball.
			var reflectiveAngle = reflectiveAngleMax
			
			if abs(relativeY) > reflectiveRange {
				// reflectionAmount can only be up to the max,
				// so if the relativeY is outside of the range,
				// just give the angle the right sign.
				reflectiveAngle *= scalarUnit(Double(relativeY))
			} else {
				// otherwise calculate the ratio of the dy to the range
				reflectiveAngle *= Double(relativeY / reflectiveRange)
			}
			
			// Add π to vertically mirror the velocity angle,
			// then subtract the reflective angle to represent
			// the proper velocity y-component change
			switch position {
			case .Left:
				ball.angle += π + 2 * reflectiveAngle
				break
			case .Right:
				ball.angle += π - reflectiveAngle
				break
			}
		}
	}
	
	private func scalarUnit(num: Double) -> Double {
		if num < 0 {
			return -1
		} else if num > 0 {
			return 1
		} else {
			return 0
		}
	}
	
	override func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
		let deltaY = direction.rawValue * velocityMultiplier
		node?.physicsBody?.velocity = CGVector(dx: 0.0, dy: deltaY)
	}
	
}