import Foundation
import SpriteKit

enum PongDirection: CGFloat {
	case Up = 1, Down = -1, None = 0
}

enum PongDirectionX: CGFloat {
	case Right = 1, Left = -1, None = 0
}

protocol PongDirectionProtocol {
	var direction: PongDirection { get set }
}