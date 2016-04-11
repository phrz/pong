//
//  AppDelegate.swift
//  Pong
//
//  Created by Paul Herz on 4/5/16.
//  Copyright (c) 2016 Paul Herz. All rights reserved.
//


import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
	
	var game: PongGame!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        /* Pick a size for the scene */
        if let scene = PongScene(fileNamed:"PongScene") {
            /* Set the scale mode to scale to fit the window */
			
			self.game = PongGame(withScene: scene)

            self.skView!.presentScene(scene)
			
            self.skView!.ignoresSiblingOrder = true
            self.skView!.showsFPS = true
            self.skView!.showsNodeCount = true
			self.skView!.showsPhysics = false
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
