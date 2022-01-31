//
//  GameScene.swift
//  StarJoinStocks
//
//  Created by alex on 7/20/17.
//  Copyright © 2017 apple. All rights reserved.
//

//
//  GameScene.swift
//  SpriteJoinGame
//
//  Created by alex on 21/08/2014.
//  Copyright (c) 2014 Alex B Brown. All rights reserved.
//

import SpriteKit
import StarJoinSelector
import StarJoinSpriteKitAdaptor

class GameScene: SKScene {

    #if os(OSX)

        let colors = NSColorList(named:NSColorList.Name("Apple"))!
    #else
        let colors:[SKColor] = [SKColor.red,SKColor.green,SKColor.blue,SKColor.yellow]
    #endif

    let companies = ["apple","ibm", "intel", "microsoft"]

    var orderedCompanies:[String]?

    var history:[String:[[String:String]]] = [:]

    var clickCount = 0

    var plot:SingleSelection<SKNode>?

    var duration:TimeInterval = 1 // animation duration

    enum PlotMode {
        case each(which: Int, max: Int)
        case all
        case smallMultiple
    }

    var plotMode:PlotMode = PlotMode.smallMultiple

    var nodeUniquenessHack = 0

    override func didMove(to view: SKView) {
        /* Setup your scene here */

        backgroundColor = SKColor.black

        // MARK: Data Configuration
        for company in companies {
            if let q = yahooHistorical(name:company) {
                history[company] = q
            }
        }

        // sort

        let stockHistory = companies.map{ (key) in (key,self.history[key]!) }

        let maxValues = stockHistory.map { (el:(String,[[String:String]])) in
            CGFloat(QuoteNode.stockRange(el.1).max)
        }

        let sortableCompanies = zip(companies, maxValues)

        orderedCompanies = sortableCompanies.sorted { $0.1 < $1.1 }.map { $0.0 }

        // basic selection

        plotMode = PlotMode.each(which: 0, max: companies.count)

        // Cyclic runner

        func repeatedlyExecute(_ block: @escaping (()->()), atInterval interval:TimeInterval, count:Int) {
            let action = SKAction.repeat(SKAction.group(
                [SKAction.wait(forDuration: interval),
                    SKAction.run(block)]),count:count)
            self.run(action)
        }

        let plotNode = SKNode()
        self.addChild(plotNode)

        plot = SingleSelection<SKNode>(node: plotNode)

//        // variables to control the 'animation'
//        var duration:TimeInterval = 0.5
//        var count = 200
//        var runCounter = 0

        updatePlot()
    }

    func updatePlot() {

        var stockHistory:[(String,[[String:String]])]

        var allRange:(min:CGFloat,max:CGFloat)? = nil

        switch plotMode {
        case .all,.smallMultiple:

            // data

            stockHistory = orderedCompanies!.map{ (key) in (key,self.history[key]!) }

            allRange = stockHistory.reduce(
                (min:CGFloat(2.0e32),max:CGFloat(0.0))) {
                    (acc:(min:CGFloat,max:CGFloat), el:(String,[[String:String]])) -> (min: CGFloat, max: CGFloat) in
                    return (min:min(acc.min, QuoteNode.stockRange(el.1).min),
                        max:max(acc.max, QuoteNode.stockRange(el.1).max))
            }

        case .each(let index, _):

            let currentCompany = orderedCompanies![index % orderedCompanies!.count]

            // data
            stockHistory = [(currentCompany,history[currentCompany]!)]

        }
        // join
        let selectAll = plot!
            .select(all: allChildrenSelector)

        let join = selectAll
            .join(stockHistory, keyFunction:{ (d, i) -> String in
                switch self.plotMode {
                case .all:
                    return d.0
                case .smallMultiple:
                    return d.0
                case .each(0, _):
                    return d.0
                default:
                    return "\(i)" // there's only one series, and we want it to re-use that one.  fails.
                }
            })

        var ordinalScale:OrdinalRangeBandsScale<String,CGFloat>? = nil

        switch plotMode {
        case .all:
            print("building all scale")
            ordinalScale = OrdinalRangeBandsScale<String,CGFloat>(
                domain:[orderedCompanies![0]],
                range:(50 + self.position.y,
                    self.position.y + self.size.height))
        case .smallMultiple:
            print("building all scale")
            ordinalScale = OrdinalRangeBandsScale<String,CGFloat>(
                domain:orderedCompanies!,
                range:(50 + self.position.y,
                    self.position.y + self.size.height))
        default:
            print("building other scale")

            ordinalScale = OrdinalRangeBandsScale<String,CGFloat>(
                domain:stockHistory.map { $0.0 },
                range:(50 + self.position.y,
                    self.position.y + self.size.height))
        }

        ordinalScale!.padding = 50
        ordinalScale!.outerPadding = 50

        let enterAppendedSelection = join
            .enter()
            .append { (d:(String,[[String:String]]), i) -> SKNode in

                let newNode = QuoteNode(quote: d, color:SKColor.red, duration:self.duration)

                // hack for <rdar://problem/18176561> SpriteKit removeFromParent removes ALL hashable equal nodes
                newNode.name = "\(self.nodeUniquenessHack)"
                self.nodeUniquenessHack = self.nodeUniquenessHack + 1
                newNode.size = self.size

                return newNode
            }

        let exitSelection = join.exit()

        exitSelection
            .transition(duration:0.5)
            .attr("hidden", toValue:true)
            .remove()
        // this crashes SpriteKit on the move from All to one ... why?
        // this crashes even if I have no child nodes.  Perhaps plotNode
        // is not safe to destroy

        let merged = join.update().merge(with: enterAppendedSelection)

        merged
            .attr("hidden", toValue:false)
            .each({ (s, d, i) in ()
                if let s = s as? QuoteNode {

                    if let companyIndex = self.orderedCompanies!.firstIndex(of: d.0) {
                        #if os(OSX)
                        let colorName = self.colors.allKeys[1+companyIndex]
                            if let color = self.colors.color(withKey: colorName) { // can overflow!
                            s.pointColor = color
                        }
                        #else
                        s.pointColor = self.colors[companyIndex]
                        #endif
                    }

                    s.quote = d

                    print("looking for \(d.0) in \(String(describing: ordinalScale!.domain))")

                    let aKey = (ordinalScale!.domain!.count == 1) ? ordinalScale!.domain![0] : d.0

                    if let band = ordinalScale!.band(aKey) {

                        s.virtualPosition.y = band.0

                        s.size = self.size
                        s.size.height = (band.1-band.0)
                    }

                    s.updateScales()

                    switch self.plotMode {
                    case .all:

                        // common scale from zero for all graphs
                        s.newScales.y!.domain = [0,allRange!.max]
                        s.updateAxes(niceTickCount:10, remove:i != 0)

                    case .smallMultiple:

                        //s.newScales.y!.domain = [allRange!.0,allRange!.1]
                        s.updateAxes(niceTickCount:3)

                    default:
                        s.updateAxes(niceTickCount:10)
                    }

                    s.updateLabel()

                    s.updatePlot()
                }
            })

        enterAppendedSelection
            .attr("alpha", toValue:CGFloat(0.0))
            .transition(duration: 0.5)
            .attr("alpha", toValue:CGFloat(1.0))

    }

    func nextScene() {
        switch plotMode {
        case .all:
            plotMode = .smallMultiple
        case .smallMultiple:
            plotMode = .each(which: 0, max: companies.count)
        case .each(let index, let maxIndex):
            let newIndex = index + 1
            if newIndex == maxIndex {
                plotMode = .all
            } else {
                plotMode = PlotMode.each(which: newIndex, max: maxIndex)
            }
        }

        updatePlot()

        clickCount += 1
    }

    #if os(OSX)
    override func mouseDown(with event: NSEvent) {
        /* Called when a mouse click occurs */

        nextScene()

//        let location = theEvent.locationInNode(self)
//        let sprite = SKSpriteNode(imageNamed:"Spaceship")
//        sprite.position = location;
//        sprite.setScale(0.5)
//
//        let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//        sprite.runAction(SKAction.repeatActionForever(action))
//
//        self.addChild(sprite)
    }

    #else

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            /* Called when a touch begins */

            nextScene()

//            for touch: AnyObject in touches {
//                let location = touch.locationInNode(self)
//
//                let sprite = SKSpriteNode(imageNamed:"Spaceship")
//
//                sprite.xScale = 0.5
//                sprite.yScale = 0.5
//                sprite.position = location
//
//                let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//
//                sprite.runAction(SKAction.repeatActionForever(action))
//
//                self.addChild(sprite)
//            }
        }

    #endif

    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}


#if false
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
#endif
