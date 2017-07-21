//
//  PlotNode.swift
//  SpriteJoinGame
//
//  Created by apple on 21/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//

import SpriteKit
import StarJoinSpriteKitAdaptor
import StarJoinSelector
//import SpriteJoinSampleData

func field<T>(_ name:String, _ el:[String:T]) -> T? {
    return el[name]
}

open class QuoteNode: SKNode {
    
    
    typealias Scale = LinearScale<CGFloat>
    public typealias CompanyHistory = (company:String,history:[[String:String]])

    // Data - note this is also available in metadata
    var quote : CompanyHistory
    
    var plot:SingleSelection<SKNode>?
    
    var duration:TimeInterval
    
    var pointColor:SKColor
    
    // Layout parameters
    open var margin:CGSize = CGSize(width:100,height:0)
    
    var size:CGSize
    
    var virtualPosition = CGPoint(x:0,y:0)
    
    
    var oldScales:(x:Scale?,y:Scale?) = (nil,nil)
    
    var newScales:(x:Scale?,y:Scale?) = (nil,nil)
    
    public init(quote: CompanyHistory, color: SKColor, duration:TimeInterval) {
        /* Setup your scene here */
      
        self.duration = duration
        self.pointColor = color
        self.quote = quote
        self.plot = nil
        self.size = CGSize(width:1, height:1)
        
        super.init()
        
        // MARK: Data Configuration
                
        // Cyclic runner
        
        let plotNode = SKNode()
        addChild(plotNode)
        
        plot = SingleSelection<SKNode>(node:plotNode)
        
        // create a layer for the axes

        
        addAxes()
    }
    
    func addAxes() -> SKNode {
        let axesNode = SKNode()
        let xAxisNode = SKNode()
        let yAxisNode = SKNode()
        
        axesNode.name = "axes"
        xAxisNode.name = "xAxis"
        yAxisNode.name = "yAxis"
        self.addChild(axesNode)
        axesNode.addChild(xAxisNode)
        axesNode.addChild(yAxisNode)
        
        return axesNode
    }
    
    open class func stockRange(_ history:[[String:String]]) -> (min:CGFloat,max:CGFloat) {
        
        // naughty downcasting to NSString to get doubleValue
        let closeS:[String?] = history.map{ d in d["Close"] }
            
        let close = closeS.map{ CGFloat(($0 as NSString?)!.doubleValue) }

        let z:[((CGFloat,CGFloat)->CGFloat,CGFloat)] = [(min,CGFloat.infinity),(max,0)]

        let results = z.map({ close.reduce($1, $0) })
        
        return (results[0], results[1])
    }
    
    open func updateScales(domain domainOverride:(min:CGFloat?,max:CGFloat?) = (nil,nil)) {
        
        // Store the old scales so Entering nodes are animated correctly.
        oldScales = self.newScales
        
        let width = self.size.width
        let height = self.size.height
        
        // scales
        
        self.newScales.x = LinearScale<CGFloat>(domain:[0,CGFloat(quote.history.count)],
            range:(virtualPosition.x + margin.width, virtualPosition.x + width-margin.width * 2.0))

        var (stockMin, stockMax) = QuoteNode.stockRange(quote.history)
        
        if let minOverride = domainOverride.min {
            stockMin = minOverride
        }
        
        if let maxOverride = domainOverride.max {
            stockMax = maxOverride
        }
        
        let stockExtent = stockMax - stockMin

        let expandedDomain = [stockMin - 0.1 * stockExtent,
                              stockMax + 0.1 * stockExtent]
        
        newScales.y = LinearScale<CGFloat>(domain:expandedDomain,
            range:(virtualPosition.y + margin.height, virtualPosition.y + height-margin.height))
    }
    
    open func updateLabel() {

        let node = SingleSelection<SKNode>(node:self)
        
        let (stockMin, stockMax) = QuoteNode.stockRange(quote.history)
        
        let stockLast = quote.history.last!["Close"]
        let closeLast:NSString? = stockLast as NSString?
        let closeLastD:CGFloat = CGFloat(closeLast!.doubleValue)
        
        // TODO: this should be a selection, not a selectAll
        let mySelection = node
            .selectAll(allChildrenNamedSelector(name: "label"))
            .join([quote.company])
        
//        labelNode.name = "label"
//        addChild(labelNode)

        mySelection.enter()
            .append { (s, d, i) in
                let newNode = SKLabelNode()
                newNode.name = "label"
                return newNode
            }
            .attr("position") { (s, d, i) in
                return SKPoint(x:self.newScales.x!.range!.1 + 10,
                    y:self.newScales.y?.scale(closeLastD) ?? 0)
            }
            .attr("alpha", toValue: 0)
            .transition(duration: duration)
            .attr("alpha", toValue: 1)
            
        mySelection.update()
            .each { (s, d, i) in
                if let label = s as? SKLabelNode {
                    label.fontSize = 40
                    label.fontColor = SKColor.white
                    label.fontName = "HelveticaNeue"
                    label.verticalAlignmentMode = .center
                    label.horizontalAlignmentMode = .left
                }
            }
            .transition(duration: duration)
            .attr("text", toValue: quote.company)
            .attr("position") { (s, d, i) in
                return SKPoint(x:self.newScales.x!.range!.1 + 10,
                    y:self.newScales.y?.scale(closeLastD) ?? 0)
            }

    }
    
    open func updatePlot() {
    
        // join the current dataset to the plot
        let mySelection = plot!.selectAll(allChildrenSelector).join(quote.history)
        

        // kill dead nodes
        mySelection
            .exit()
            .transition(duration: duration)
            .attr("alpha", toValue: 0)
            .remove()
        
//        // existing nodes go red - or blue on purge cycles
//        mySelection
//            .update()
//            .transition(duration: duration)
        
        // create new nodes
        mySelection.enter()
            .append { (s, d, i) in SKSpriteNode()}
            .attr("size", toValue: SKSize(width:4.0,height:0.5))
            
            // start white
            .attr("color",toValue: SKColor.white)
            .attr("position") { (s, d, i) in
                
                let close = CGFloat((d!["Close"] as NSString?)!.doubleValue)
                
                return SKPoint(x:self.newScales.x?.scale(CGFloat(i)) ?? 0, y:self.newScales.y?.scale(close) ?? 0)
                
                //                    (s as SKSpriteNode).size = CGSizeMake(CGFloat(1), CGFloat(1))
            }
            .transition(duration: duration)
        // grow in
        //                .setKeyedAttr("scale") { (s, d, i) in CGFloat(d!.size) }
        
        
        mySelection
            .update()
            .transition(duration: duration)
            .attr("size", toValue: SKSize(width:4.0,height:5.0))
            .attr("color") { (s, d, i) in
                return self.pointColor
            }
            .attr("position") { (s, d, i) in
                
                let close = CGFloat((d!["Close"] as NSString?)!.doubleValue)
                
                return SKPoint(x:self.newScales.x?.scale(CGFloat(i)) ?? 0, y:self.newScales.y?.scale(close) ?? 0)
                
                //                    (s as SKSpriteNode).size = CGSizeMake(CGFloat(1), CGFloat(1))
        }
        
        //                .setKeyedAttr("position") { (s, d, i) in
        //                    NSValue(point:CGPointMake(xScale.scale(CGFloat(d!.x)), yScale.scale(CGFloat(d!.y))))
        //            }
        
    }
    
    open func updateAxes(niceTickCount:Int = 10, remove:Bool = false) {
        // Update axes - only if scale changes
        
        var axesNode = self.childNode(withName: "axes")

        if (oldScales.y == nil || oldScales.y! != newScales.y! || axesNode == nil) {
        
            if (axesNode != nil && remove) {
                axesNode!.removeFromParent()
                return
            }
            
            if  (axesNode == nil) {
                axesNode = addAxes()
            }
            
            switch (axesNode!.childNode(withName: "xAxis"),
                axesNode!.childNode(withName: "yAxis")) {
            case (.some(let xAxisNode), .some(let yAxisNode)):
            
                // offset the axes outwards
                let axisPadding:CGFloat = 10
            
                xAxisNode.position = CGPoint(x:0, y:newScales.y!.range!.0 - axisPadding)
                
                yAxisNode.position = CGPoint(x:newScales.x!.range!.0 - axisPadding, y:0)
                
                let xAxisSelection = SingleSelection<SKNode>(node: xAxisNode)
                
                let yAxisSelection = SingleSelection<SKNode>(node: yAxisNode)
                
                let xAxis = SKAxis<CGFloat,CGFloat>(scale: newScales.x!, side: AxisSide.bottom)
                
                xAxis.enterScale = oldScales.x
                xAxis.tickLabelFormatter = {
                    (d) in String(format:"%.0f",Double(d))
                }
                xAxis.lineColor = SKColor.white
                xAxis.lineWidth = 1
                xAxis.niceTickCount = 10
                
                xAxisSelection.call(function: xAxis.make)
                
                let yAxis = SKAxis<CGFloat,CGFloat>(scale: newScales.y!, side: AxisSide.left)
                
                yAxis.animationDuration = 0.7
                
                yAxis.enterScale = oldScales.y
                yAxis.tickLabelFormatter = { (d) in String(format:"%.0f",Double(d)) }
                yAxis.lineColor = SKColor.white
                yAxis.lineWidth = 1
                yAxis.niceTickCount = niceTickCount
                
                yAxisSelection.call(function: yAxis.make)
                
            default:
                print("Warning: missing axes")
            }
        }
        
    }
    
    required public init?(coder:NSCoder) {
        
        self.quote = ("",[])
        self.duration = 0
        self.pointColor = SKColor.red
        
        self.size = CGSize(width:1, height:1)
        super.init(coder:coder)
    }
    
}
