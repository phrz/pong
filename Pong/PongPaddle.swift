import Foundation
import SpriteKit

enum PongPaddlePosition {
	case Left, Right
}

class PongPaddle: PongEntity, PongShapeNodeProtocol, PongDirectionProtocol {
	
	var node: SKShapeNode?
	
	let defaultWidth: CGFloat = 10
	let defaultHeight: CGFloat = 100
	let padding: CGFloat = 100
	
	var direction: PongDirection = .None
	var velocityMultiplier: CGFloat = 300
	
	init(withScene scene: SKScene, startAt position: PongPaddlePosition) {
		node = SKShapeNode()
		
		switch position {
		case .Left:
			node!.position = CGPoint(x: defaultWidth + padding,
			                         y: scene.frame.midY - 0.5 * defaultHeight)
		case .Right:
			node!.position = CGPoint(x: scene.frame.width - padding,
			                         y: scene.frame.midY - 0.5 * defaultHeight)
		}
		
		let paddleSize = CGSize(width: 10, height: 100)
		let paddleRect = CGRect(origin: CGPoint.zero, size: paddleSize)
		
		node!.path = CGPathCreateWithRect(paddleRect, nil)
		node!.fillColor = SKColor.whiteColor()
		
		node!.physicsBody = SKPhysicsBody(rectangleOfSize: paddleSize)
		node!.physicsBody!.affectedByGravity = false
		node!.physicsBody!.dynamic = true
	}
	
	
	override func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
		let deltaY = direction.rawValue * velocityMultiplier
		node?.physicsBody?.velocity = CGVector(dx: 0.0, dy: deltaY)
	}
	
}