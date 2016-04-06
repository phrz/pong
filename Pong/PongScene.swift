import SpriteKit

let upKeyMapping: UInt16 = 0   // A
let downKeyMapping: UInt16 = 6 // Z

struct PhysicsCategory {
	static let scene:  UInt32 = 0b1 << 0
	static let paddle: UInt32 = 0b1 << 1
	static let ball:   UInt32 = 0b1 << 2
}

class PongScene: SKScene, SKPhysicsContactDelegate {
	
	var keysDown = Set<UInt16>()
	
	override func didMoveToView(view: SKView) {
		self.backgroundColor = SKColor.blackColor()
		self.scaleMode = .Fill
		
		// Points and vectors
		let topStart = CGPoint(x: 0, y: self.frame.height)
		let topEnd = CGPoint(x: self.frame.width, y: self.frame.height)
		let bottomStart = CGPointZero
		let bottomEnd = CGPoint(x: self.frame.width, y: 0)
		
		let topEdge = SKPhysicsBody(edgeFromPoint: topStart, toPoint: topEnd)
		let bottomEdge = SKPhysicsBody(edgeFromPoint: bottomStart, toPoint: bottomEnd)
		let borderBody = SKPhysicsBody(bodies: [topEdge, bottomEdge])
		
		// Scene physics
		self.physicsWorld.gravity = CGVector(dx: 0,dy: 0)
		self.physicsWorld.contactDelegate = self
		self.physicsBody = borderBody
		
		self.physicsBody?.friction = 0
		
		self.physicsBody?.categoryBitMask = PhysicsCategory.scene
		self.physicsBody?.collisionBitMask = PhysicsCategory.paddle
		self.physicsBody?.contactTestBitMask = PhysicsCategory.paddle

	}
	
	override func keyDown(theEvent: NSEvent) {
		keysDown.insert(theEvent.keyCode)
		print(keysDown)
		updateKeyMovement()
	}
	
	
	override func keyUp(theEvent: NSEvent) {
		let pongDelegate = self.delegate as! PongGame
		keysDown.remove(theEvent.keyCode)
		print(keysDown)
		if keysDown.isEmpty {
			pongDelegate.stopPlayerMovement()
		}
		updateKeyMovement()
	}
	
	
	func updateKeyMovement() {
		
		let pongDelegate = self.delegate as! PongGame
		
		if keysDown.contains(upKeyMapping) {
			pongDelegate.startPlayerMovement(.Up)
		} else if keysDown.contains(downKeyMapping) {
			pongDelegate.startPlayerMovement(.Down)
		}
	}
}
