import SpriteKit

func CGPathLineFrom(from: CGPoint, to: CGPoint) -> CGPath {
	let path: CGMutablePathRef = CGPathCreateMutable()
	CGPathMoveToPoint(path, nil, from.x, from.y)
	CGPathAddLineToPoint(path, nil, to.x, to.y)
	return path
}

class PongTrigPlayer: PongEntity, PongPlayerProtocol {
	
	let ball: PongBall
	let paddle: PongPaddle
	let scene: SKScene
	
	var xLine = SKShapeNode()
	var yLine = SKShapeNode()
	var hypLine = SKShapeNode()
	
	// Maintain prior decision state
	var decisionState: PongDirection = .None
	
	// Trigonometric projection helpers
	var hasProjectedPosition = false
	var projectedY: Double?
	var projectedYDiff: Double?
	
	init(paddle: PongPaddle, ball: PongBall, name: String) {
		self.ball = ball
		self.paddle = paddle
		self.scene = ball.node!.scene!
		
		for line in [xLine,yLine,hypLine] {
			line.lineWidth = 2
			line.strokeColor = SKColor.redColor()
			scene.addChild(line)
		}
		
		hypLine.strokeColor = SKColor.blueColor()
		
		super.init(withName: name)
		
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: #selector(PongTrigPlayer.collisionHandler),
			name: collisionNotificationKey,
			object: nil
		)
	}
	
	@objc func collisionHandler(notification: NSNotification) {
		
		guard let userInfo = notification.userInfo as? [String: Set<String>] else {
			print("Could not type cast userInfo")
			return
		}
		
		guard let entityNameSet = userInfo["entities"] else {
			print(notification.userInfo)
			print("Could not get entity set")
			return
		}
		
		let ballHitWallCase = Set(arrayLiteral: "pongScene", "ball")
		if(entityNameSet == ballHitWallCase) {
			hasProjectedPosition = false
		}
	}
	
	func strategy(time: NSTimeInterval) -> PongDirection {
		// Travelling right case
		if ball.node!.physicsBody!.velocity.dx > 0 {
			// reset trig flag
			hasProjectedPosition = false
			// don't move
			decisionState = .None
			return decisionState
		}
		// Right side of field case
//		if ball.node!.position.x > ball.node!.scene!.frame.midX {
//			// don't move
//			decisionState = .None
//			return decisionState
//		}
		// We have to perform projection
		if !hasProjectedPosition {
			projectPositionOf(ball)
			hasProjectedPosition = true
		}
		
		// If the projection has been calculated, move towards it
		guard projectedY != nil else {
			return decisionState
		}
		
		let cgProjectedY = CGFloat(projectedY!)
		
		let top = self.paddle.node!.frame.maxY
		let bottom = self.paddle.node!.frame.minY
		
		if(cgProjectedY >= bottom && cgProjectedY <= top) {
			// within paddle range
			decisionState = .None
		} else if(cgProjectedY < bottom) {
			// below paddle
			decisionState = .Down
		} else if(cgProjectedY > top) {
			// above paddle
			decisionState = .Up
		}
		
		return decisionState
	} // strategy
	
	func projectPositionOf(ball: PongBall) {
		// y0 is the initial ball Y
		let y0 = Double(ball.node!.position.y)
		// x is the distance between the ball and the paddle
		let x = Double(abs(paddle.node!.position.x - ball.node!.position.x))
		// θ is the angle (in radians) of the ball relative to the horizontal.
		// Angle above the horizontal is positive.
		var θa = ball.angle
		while θa < 0 { θa += 2*π }
		while θa > 2*π { θa -= 2*π }
		
		var θ = abs(θa - π)
		if(ball.node!.physicsBody!.velocity.dy < 0) {
			θ *= -1
		}
		
		print()
		print("θa = \(θa*180/π)°")
		print("θ  = \(θ*180/π)°")
		print()
		
		projectedYDiff = x * atan(θ)
		
		projectedY = y0 + projectedYDiff!
		
		drawLines()
	}
	
	func drawLines() {
		let intersectX = paddle.node!.position.x
		let intersect = CGPoint(x: intersectX, y: ball.node!.position.y)
		let projectedIntersect = CGPoint(x: intersect.x, y: intersect.y + CGFloat(projectedYDiff!))
		// X Line from ball to enemy paddle X
		xLine.path = CGPathLineFrom(
			ball.node!.position,
		    to: intersect
		)
		// Y line from paddle to projected Y delta
		yLine.path = CGPathLineFrom(
			intersect,
			to: projectedIntersect
		)
		// Hypotenuse
		hypLine.path = CGPathLineFrom(
			ball.node!.position,
			to: projectedIntersect
		)
	}
}