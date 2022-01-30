 //
//  AppDelegate.swift
//  SpriteJoinDemo
//
//  Created by apple on 25/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//


import Cocoa
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) throws -> SKNode? {
        if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
            let sceneData = try NSData(contentsOfFile:path, options: .mappedIfSafe)
            
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData as Data)
                
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            if let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? GameScene {
                archiver.finishDecoding()
                return scene
            }
        }
        return nil
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        /* Pick a size for the scene */
        
        do {
            let gs = try GameScene.unarchiveFromFile(file: "GameScene")
        
            if let scene = try gs as? GameScene {
                /* Set the scale mode to scale to fit the window */
                scene.scaleMode = .aspectFill

                self.skView!.presentScene(scene)

                /* Sprite Kit applies additional optimizations to improve rendering performance */
                self.skView!.ignoresSiblingOrder = true

                self.skView!.showsFPS = true
                self.skView!.showsNodeCount = true
            }
        } catch {
            NSLog("Crash loading scene")
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true;
    }
}
