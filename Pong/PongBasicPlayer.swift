import SpriteKit

class PongBasicPlayer: PongEntity {
	
	let ball: PongBall
	let paddle: PongPaddle
	
	// To prevent excessive calculation, we limit decisions to 10x/s
	let movementDecisionInterval: NSTimeInterval = 1.0/10
	var nextDecisionTime: NSTimeInterval = 0.0
	
	// Maintain prior decision state
	var decisionState: PongDirection = .None
	
	// Reaction time is emulated by imposing latency on the ball position
	let ballYDelay: PongSignalDelay<CGFloat>
	
	init(paddle: PongPaddle, ball: PongBall, name: String) {
		self.ball = ball
		self.paddle = paddle
		
		self.ballYDelay = PongSignalDelay<CGFloat>(delay: 1) {
			return ball.node!.position.y
		}
		
		super.init(withName: name)
	}
	
	override func update(currentTime: NSTimeInterval, forScene scene: SKScene) {
		let direction: PongDirection = strategy(currentTime)
		paddle.direction = direction
	}
	
	func strategy(time: NSTimeInterval) -> PongDirection {
		// if the ball is travelling right, stay still
		if ball.node!.physicsBody!.velocity.dx > 0 {
			decisionState = .None
			return decisionState
		}
		
		// if the ball is on the right half of the field,
		// AI is "blind" to it
		if ball.node!.position.x > ball.node!.scene!.frame.midX {
			decisionState = .None
			return decisionState
		}
		
		// If we have yet to reach the next decision time
		// (artificially limiting AI reaction), persist state
		if time < nextDecisionTime {
			return decisionState
		}
		
		let top = self.paddle.node!.frame.maxY
		let bottom = self.paddle.node!.frame.minY
		
		// Change the next decision time to the current time plus
		// the decision interval constant.
		nextDecisionTime = time + movementDecisionInterval
		
		// Move towards the Y position of the ball
		let ballY = ball.node!.position.y
		
		print("Ball Y:        \(ballY)")
		print("Ball Y (delay: \(ballYDelay.get())")
		
		if(ballY >= bottom && ballY <= top) {
			// within paddle range
			decisionState = .None
		}
		
		else if(ballY < bottom) {
			// below paddle
			decisionState = .Down
		}
		
		else if(ballY > top) {
			// above paddle
			decisionState = .Up
		}
		
		return decisionState
	}
	
}