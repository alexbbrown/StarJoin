//
//  GameViewController.swift
//  iOSSpriteJoinDemo
//
//  Created by apple on 26/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(_ file : NSString) throws -> SKNode? {
        if let path = Bundle.main.path(forResource: file as String, ofType: "sks") {
            let sceneData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            if let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? GameScene {
                archiver.finishDecoding()
                return scene
            }
        }
        return nil
        
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            if let scene = try GameScene.unarchiveFromFile("GameScene") as? GameScene {
                // Configure the view.
                if let skView = self.view as? SKView {
                    skView.showsFPS = true
                    skView.showsNodeCount = true
                    
                    /* Sprite Kit applies additional optimizations to improve rendering performance */
                    skView.ignoresSiblingOrder = true
                    
                    /* Set the scale mode to scale to fit the window */
                    scene.scaleMode = .aspectFill
                    
                    skView.presentScene(scene)
                }
            }
        } catch {
            NSLog("Error unarchiving scene")
        }
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
