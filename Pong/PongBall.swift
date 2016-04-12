import Foundation
import SpriteKit

extension CGVector {
	static func from(magnitude magnitude: Double, angle: Double) -> CGVector {
		let deltaX = magnitude * cos(angle)
		let deltaY = magnitude * sin(angle)
		return CGVector(dx: deltaX, dy: deltaY)
	}
	func toAngle() -> Double {
		let magnitude = sqrt( pow(Double(self.dx),2) + pow(Double(self.dy),2) )
		let unitX = Double(self.dx) / magnitude
		let unitY = Double(self.dy) / magnitude
		return atan2(unitY, unitX)
	}
}

class PongBall: PongEntity, PongSpriteNodeProtocol, PongCollisionListenerProtocol {
	
	let defaultWidth: CGFloat = 10
	let defaultHeight: CGFloat = 10
	let speedConstant: Double = 300
	
	var node: SKSpriteNode?
	
	var outOfBounds: PongDirectionX = .None
	
	var angle: Double {
		get {
			var a = (node?.physicsBody?.velocity.toAngle())!
			return a
		}
		set(newAngle) {
			node?.physicsBody?.velocity = CGVector.from(magnitude: speedConstant, angle: newAngle)
		}
	}
	
	var trailingEdge: CGFloat {
		get {
			let vx = self.node!.physicsBody!.velocity.dx
			let minX = self.node!.frame.minX
			let maxX = self.node!.frame.maxX
			// If we're going left, left edge is trailing
			if(vx < 0) {
				return minX
			} else {
				return maxX
			}
		}
	}
	
	init(withScene scene: SKScene, name: String) {
		
		super.init(withName: name)
		
		// Create the ball sprite
		let ballSize = CGSize(width: defaultWidth, height: defaultHeight)
		node = SKSpriteNode(color: SKColor.whiteColor(), size: ballSize)
		node?.name = name
		// Set the anchor point to the sprite centre rather than
		// the relative cartesian origin
		node?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		
		// Position it in the screen's centre
		node!.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
		
		// Physics properties
		node!.physicsBody = SKPhysicsBody(rectangleOfSize: node!.frame.size, center: CGPointZero)
		node!.physicsBody?.affectedByGravity = false
		node!.physicsBody?.dynamic = true
		node!.physicsBody?.friction = 0
		node!.physicsBody?.angularDamping = 0
		node!.physicsBody?.linearDamping = 0
		node!.physicsBody?.restitution = 1.0
		
		// Collision/contact rules
		node!.physicsBody?.categoryBitMask = PhysicsCategory.ball
		node!.physicsBody?.collisionBitMask = 0
		node!.physicsBody?.contactTestBitMask = PhysicsCategory.scene | PhysicsCategory.paddle
	}
	
	func didCollideWith(entity: PongEntity, contact: SKPhysicsContact) {
		print("PongBall: didCollideWith: \(entity.name)")
		
		if(entity.name == "pongScene") {
			print("PongBall: scene collision handler")
			didCollideWithScene()
		}
	}
	
	func didCollideWithScene() {
		// reflect the incident angle of the ball (this formula is for
		// horizontal walls)
		self.angle = -self.angle
	}
	
	override func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
		// Check out-of-bounds on update
		let position = node!.position
		let sceneRect = scene.frame
		if !CGRectContainsPoint(sceneRect, position) {
			// out-of-bounds
			// on whose side?
			if position.x < 0 {
				outOfBounds = .Left
			} else if position.x > sceneRect.width {
				outOfBounds = .Right
			} else {
				outOfBounds = .None
			}
		}
	} // update
}

