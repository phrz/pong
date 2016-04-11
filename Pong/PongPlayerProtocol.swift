//
//  PongPlayerProtocol.swift
//  Pong
//
//  Created by Paul Herz on 4/10/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

// Spaceship operator code
// [CITE] https://vperi.com/2014/06/05/spaceship-operator-in-swift/
enum Comparison: Int {
	case Lesser = -1,
	Equal = 0,
	Greater = 1
}
infix operator <=> {}
func <=><T: Comparable> (left: T, right: T) -> Comparison {
	if      left < right { return .Lesser  }
	else if left > right { return .Greater }
	else                 { return .Equal   }
}

protocol PongPlayerProtocol {
	
	var ball: PongBall { get }
	var paddle: PongPaddle { get }
	
	func strategy(time: NSTimeInterval) -> PongDirection
	
}