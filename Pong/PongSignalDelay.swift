//
//  PongSignalDelay.swift
//  Pong
//
//  Created by Paul Herz on 4/10/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

// dispatch_after wrapper
// [CITE] http://stackoverflow.com/a/24318861/3592716
func doWithDelay(delay:Double, closure:()->()) {
	dispatch_after(
		dispatch_time(
			DISPATCH_TIME_NOW,
			Int64(delay * Double(NSEC_PER_SEC))
		),
		dispatch_get_main_queue(), closure)
}


class PongSignalDelay <PongSignalType> {
	
	let sampleRate: NSTimeInterval = 1.0/10
	let delay: NSTimeInterval
	
	let liveValue: () -> PongSignalType
	var delayValue: PongSignalType?
	
	init(delay: NSTimeInterval, liveValue: () -> PongSignalType) {
		
		self.liveValue = liveValue
		self.delay = delay
		
		// Begin setting value on a timer
		NSTimer.scheduledTimerWithTimeInterval(
			sampleRate,
			target: self,
			selector: #selector(PongSignalDelay.update),
			userInfo: nil,
			repeats: true
		)
	}
	
	@objc
	func update() {
		doWithDelay(self.delay) {
			self.delayValue = self.liveValue()
		}
	}
	
	// Get the delayed value
	func get() -> PongSignalType? {
		return delayValue
	}
}