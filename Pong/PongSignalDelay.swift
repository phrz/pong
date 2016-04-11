//
//  PongSignalDelay.swift
//  Pong
//
//  Created by Paul Herz on 4/10/16.
//  Copyright © 2016 Paul Herz. All rights reserved.
//

import Foundation

class PongSignalDelay <PongSignalType> {
	
	let sampleRate: NSTimeInterval = 1.0/60
	let delay: NSTimeInterval
	
	var sampleQueue = [PongSignalType]()
	let queueSize: UInt
	
	let liveValue: () -> PongSignalType
	var delayValue: PongSignalType
	
	init(delay: NSTimeInterval, liveValue: () -> PongSignalType) {
		
		self.liveValue = liveValue
		self.delay = delay
		
		// Begin setting value on a timer
		NSTimer.scheduledTimerWithTimeInterval(sampleRate, target: self, selector: #selector("PongSignalDelay.update"), userInfo: <#T##AnyObject?#>, repeats: <#T##Bool#>)
	}
	
	@objc
	private func update() {
		
	}
	
	// Get the delayed value
	func get() -> PongSignalType {
		
	}
}