import SpriteKit

class PongBasicPlayer: PongEntity, PongPlayerProtocol {
	
	let ball: PongBall
	let paddle: PongPaddle
	
	var nextDecisionTime: NSTimeInterval = 0.0
	let noneDecisionInterval: NSTimeInterval = 1.0/20
	let moveDecisionInterval: NSTimeInterval = 1.0/10
	
	// Maintain prior decision state
	var decisionState: PongDirection = .None
	
	// Reaction time is emulated by imposing latency on the ball position
	let delayTime = 1.0
	let ballYDelay: PongSignalDelay<CGFloat>
	
	// Chance that, if moving, AI will continue to move.
	let persistenceProbability = 10
	
	init(paddle: PongPaddle, ball: PongBall, name: String) {
		self.ball = ball
		self.paddle = paddle
		
		self.ballYDelay = PongSignalDelay<CGFloat>(delay: delayTime) {
			return ball.node!.position.y
		}
		
		super.init(withName: name)
	}
	
	func strategy(time: NSTimeInterval) -> PongDirection {
		// if the ball is travelling right, stay still
		if ball.node!.physicsBody!.velocity.dx > 0 {
			decisionState = .None
			nextDecisionTime = time + noneDecisionInterval
			return decisionState
		}
		
		// if the ball is on the right half of the field,
		// AI is "blind" to it
		if ball.node!.position.x > ball.node!.scene!.frame.midX {
			decisionState = .None
			nextDecisionTime = time + noneDecisionInterval
			return decisionState
		}
		
		// If we have yet to reach the next decision time
		// (artificially limiting AI reaction), persist state
		if time < nextDecisionTime {
			return decisionState
		}
		
		// There is a chance that movement will persist
		if(decisionState != .None && Int(arc4random_uniform(100)) < persistenceProbability) {
			print("persist")
			return decisionState
		}
		
		let top = self.paddle.node!.frame.maxY
		let bottom = self.paddle.node!.frame.minY
		
		// Move towards the Y position of the ball
		// (We use a delayed value for reaction time)
		guard let ballY = ballYDelay.get() else {
			decisionState = .None
			nextDecisionTime = time + noneDecisionInterval
			return decisionState
		}
		
		// Jitter function (optional)
//		ballY += CGFloat(arc4random_uniform(30))
		
		
		if(ballY >= bottom && ballY <= top) {
			// within paddle range
			decisionState = .None
			nextDecisionTime = time + noneDecisionInterval
		} else if(ballY < bottom) {
			// below paddle
			decisionState = .Down
			nextDecisionTime = time + moveDecisionInterval
		} else if(ballY > top) {
			// above paddle
			decisionState = .Up
			nextDecisionTime = time + moveDecisionInterval
		}
		
		return decisionState
	}
	
}