import Foundation
import SpriteKit

protocol PongCollisionListenerProtocol {
	func didCollideWith(entity: PongEntity, contact: SKPhysicsContact)
}
