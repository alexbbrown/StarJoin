//: A SpriteKit based Playground

// Expected: Nothing yet, The original select function being hacked up to at least execute.

//
//  Selection.swift
//  SpriteJoin
//
//  Created by apple on 19/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//

// Issues
// Selection class should not be bound up with a specific class,
// but should support any class obeying protocols allowing
// tree walking and manipulation.

// handy d3 references
// https://github.com/mbostock/d3/blob/48ad44fdeef32b518c6271bb99a9aed376c1a1d6/src/selection/data.js

// TODO:[new]
// Where's my state machine?
// get the old one working;
// build a NEW one.
// handle structures which are not arrays

// TODO:[old]
// refactor into DataDominant, NodeDominant, and Perfect joins
// rationalise the the setKeyAttr logic
// deprecate setKeyAttr in favour of attr
// allow simple types and tuples to pass setKeyAttr
// Allow data function to be a dictionary, which is auto-keyed. Perhaps a common ancestor of Array, Dictionary

// Feature switches
let transitionFeatures = false


import Foundation

// MARK: start of Adaptor Protocols AdaptorProtocols.swift

// MARK: required delegate protocols

// why do we need this?  it looks like a mutable collection of some kind
public protocol TreeNavigable {
    typealias T = Self
    func addChildNode(_: Self)

    func removeNodeFromParent()

    var childNodes: [T]! { get }
}

// this is a way to store metadata in the node itself, which lets us put the value in there so it can be retrieved without reference to the origianl array, for examine in 'each'.  I need to consider what this means.
public protocol NodeMetadata {
    var metadata: AnyObject? { get set }
}

// KVC protocol encapsulates the idea that values can be accessed using string accessors.  This enables one sort of interaction, bit it's not the only one.
public protocol KVC {
    // real functions
    func setValue(_: AnyObject?, forKey:String) -> Void
    func valueForKey(_: String) -> AnyObject?

    func setValue(_: AnyObject?, forKeyPath:String) -> Void
    func valueForKeyPath(_: String) -> AnyObject?

    // proxy functions
    func setNodeValue(_ toValue:AnyObject?, forKeyPath keyPath:String)
    func setNodeValueAnimated(_ toValue:AnyObject?, forKeyPath keyPath:String, withDuration: TimeInterval)

    // this feels closer to TreeNavigable
    func removeNodeFromParent(withDelay: TimeInterval)
}

// MARK: start of body Selector.swift

// NodeData carries Node, Value pairs,
// even if Node is missing.  Note that live
// nodes keep a reference to their data, too
// TODO(4): can this be a struct
public class NodeData<NodeType, ValueType> {
    public var node:NodeType?
    public var value:ValueType
    init(node:NodeType?, value:ValueType) {
        self.node = node
        self.value = value
    }
}

// Non AnyObject types such as tuples need boxing
// since metadata (SKNode) may be stored in NSMutableDictionaries
internal class BoxedValue<ValueType> {
    internal var value:ValueType
    init(value:ValueType) {
        self.value = value
    }
}

// MARK: Selection - base class

// Selection is just a boring abstract base class.  Sets the Node and Value types
// although ValueType might become subclass specific later.
public class Selection<NodeType: KVC & TreeNavigable & NodeMetadata> {

    public var nodes:[NodeType]

    // Convenience data types
    public typealias ParentType = NodeType // does this go here?

    // convenience function to do select, selectAll and join in one throw
    public class func selection<ValueType>(parent: NodeType, nodes: [NodeType], data: [ValueType]) -> JoinSelection<NodeType, ValueType> {
        return self.select(parent).selectAll(nodes).join(data)
    }

    public func selectAll(_ nodes: [NodeType]) -> MultiSelection<NodeType> {
        fatalError("This method must be overridden")
    }

    // This needs generalising - a select on a multiselection returns a multiselection
    // this one just returns a selection for one node.
    public class func select(_ node: NodeType) -> SingleSelection<NodeType> {
        return SingleSelection<NodeType>(node: node)
    }

    // Remove nodes from the document
    public func remove() {
        // TODO: should do something here - it's possible to remove things other than the exit selection
    }

    public init (node:NodeType) {
        nodes = [node]
    }

    public init (nodes:[NodeType]) {
        self.nodes = nodes
    }
}

public func select<NodeType: KVC & TreeNavigable & NodeMetadata>(node:NodeType) -> SingleSelection<NodeType> {
    return SingleSelection(node: node)
}

// MARK: SingleSelection
// select a single node.  data operator applies once.
// Selections are a selection of a single node, although subclasses handle
// multiple nodes.  For now, the data TYPE is bound here also, although that
// is likely to change to allow type specification to happen optionally, or
// only on action leaves.
// Selections can be converted to
//      Selection <- select
//      MultiSelection <- selectAll
// Selections support simple operations such as append - which generate
// new selections.
public class SingleSelection<NodeType: KVC & TreeNavigable & NodeMetadata> : Selection<NodeType> {

    // initialise the selection of a single node (usually the base node)
    override public init (node:NodeType) {
        super.init(node:node)
    }

    // These nodes should be descendants of the parent node
    public override func selectAll(_ nodes: [NodeType]) -> MultiSelection<NodeType> {
        return MultiSelection<NodeType>(parent: self.nodes[0], nodes: nodes)
    }

    // These nodes should be descendants of the parent node
    public func selectAll(_ nodes: (NodeType) -> [NodeType]) -> MultiSelection<NodeType> {
        return MultiSelection<NodeType>(parent: self.nodes[0], nodes: nodes(self.nodes[0]))
    }

    // todo: add initialisers for other kinds of searching, and add a
    // select method (which is also a subscript operator) for sub-selection

    // todo: append
    //internal typealias CallFunction = (Selection) -> ()

    public func call(function: (SingleSelection) -> ()) -> Self {
        function(self)

        return self
    }
}

// MARK: InternalMultiSelection

// (internal) InternalMultiSelection represents the common properties and actions
// of a multiple selection

public class InternalMultiSelection<NodeType: KVC & TreeNavigable & NodeMetadata> : Selection<NodeType> {

    // Convenience Types


    // Properties

    /// The parent object is where new objects are created.  This is
    // probably incorrect in the long run; new objects may be created
    // on cascading created objects.
    internal var parent:ParentType // TODO: should be readonly
    // computed accessor to get managed nodes & data
    /// selection is the set of nodes initially supplied

    internal init (parent:ParentType, nodes:[NodeType]) {
        self.parent = parent

        super.init(nodes: nodes)
    }
}

// MARK: MultiSelection

// MultiSelection deals with pre-joined state - SelectAlls.
// MultiSelection can be operated upon as basic selections, or converted
// into a JoinSelection
public class MultiSelection<NodeType: KVC & TreeNavigable & NodeMetadata> : InternalMultiSelection<NodeType> {

    // Convenience Types
    public typealias NodeFunction = (NodeType?,Void,Int) -> ()
    public typealias NodeToIdFunction = (NodeType?,Void,Int) -> AnyObject?
    public typealias NodeToNodeFunction = (NodeType?,Void,Int) -> NodeType

    // Properties

    // Constructor for specific nodes, equivalent to selectAll
    // TODO: add constructors for patterns, too.
    public override init (parent:ParentType, nodes:[NodeType]) {

        super.init(parent: parent, nodes: nodes)
    }



    public func join<ValueType,KeyType:Hashable>(_ data:[ValueType], keyFunction:(ValueType,Int) -> KeyType) -> JoinSelection<NodeType, ValueType> {
        return JoinSelection<NodeType, ValueType>(parent: self.parent,
                                                  nodes: self.nodes,
                                                  data: data,
                                                  keyFunction: keyFunction)
    }

    public func join<ValueType>(_ data: [ValueType]) -> JoinSelection<NodeType, ValueType> {
        return JoinSelection<NodeType, ValueType>(parent: self.parent,
                                                  nodes: self.nodes,
                                                  data: data)
    }



    public func each(eachFn:NodeFunction) -> Self {
        // TODO create more childrens
        for (i, selected) in nodes.enumerated() {

            // unfortunate boxing required to handle tuples stored in
            // NSMutableDictionary.  Can't push it down to the helper
            // right now

            eachFn(selected, (), i)
        }
        return self;
    }

    // set a property using key value coding
    public func setKeyedAttr(keyPath: String, toValue: AnyObject?) -> Self {
        for selected in nodes {
            selected.setNodeValue(toValue, forKeyPath: keyPath)
        }

        return self;
    }

    // shorthand alias for setKeyedAttr to work like d3
    public func attr(keyPath: String, toValue: AnyObject?) -> Self {
        return setKeyedAttr(keyPath: keyPath, toValue: toValue)
    }

    // shorthand alias for setKeyedAttr to work like d3
    public func attr(keyPath: String, toValueFn: NodeToIdFunction) -> Self {
        return setKeyedAttr(keyPath: keyPath, toValueFn: toValueFn)
    }

    // compound attr for functions
    // TODO: can I unify the value and function dictionary representations?
    public func attr(keyedFunctions: [String:NodeToIdFunction]) -> Self {

        // TODO: performance - could iterate the nodes outside?
        for (keyPath, toValueFn) in keyedFunctions  {
            attr(keyPath: keyPath, toValueFn: toValueFn)
        }
        return self;
    }

    // compound attr for values
    public func attr(keyedValues: [String:AnyObject?]) -> Self {

        // TODO: performance - could iterate the nodes outside?
        for (keyPath, toValue) in keyedValues  {
            attr(keyPath: keyPath, toValue: toValue)
        }
        return self;
    }

    // set a property using key value coding
    public func setKeyedAttr(keyPath: String, toValueFn: NodeToIdFunction) -> Self {
        for (i, selected) in nodes.enumerated() {

            // unfortunate boxing required to handle tuples stored in
            // NSMutableDictionary.  Can't push it down to the helper
            // right now

            let optionalSelected = selected as NodeType?

            selected.setNodeValue(toValueFn(optionalSelected, (), i), forKeyPath: keyPath)
        }
        return self;
    }

    #if transitionFeatures
    public func transition(duration: TimeInterval = 3) -> TransitionMultiSelection<NodeType> {
        return TransitionMultiSelection(parent: self.parent, nodes:self.nodes, duration:duration)
    }
    #endif
}

// MARK: JoinedSelection

/// (internal) JoinedSelection includes the operations that are possible on a bound or pre-joined selection
// note that JoinedSelection inherited from a pre-entered Join may contain partially bound data
// where there is a value but no node.
// update should be used to split out notes with no value.  It is not possible to address nodes that
// don't exists - this has changed - a JoinedSelection cannot (apart from subclasses) contain missing nodes
public class JoinedSelection<NodeType: KVC & TreeNavigable & NodeMetadata, ValueType> : InternalMultiSelection<NodeType> {

    // Convenience Types
    public typealias NodeFunction = (NodeType?,ValueType?,Int) -> ()
    public typealias NodeToIdFunction = (NodeType?,ValueType?,Int) -> AnyObject?
    public typealias NodeToNodeFunction = (NodeType?,ValueType?,Int) -> NodeType
    typealias BoxedValueType = BoxedValue<ValueType>

    // Properties

    // TODO: return data - strip out missing results, perhaps? or return ValueType?
    public var data:[ValueType] { get { return [] } } // this TYPE only makes sense for multiply selected things

    // Initialisers
    // TODO: does JoinedSelection use nodeData array or metadata?
    // passing nodeData here is a convenience, the exact same data should be available
    // in the metadata!
    override internal init (parent:ParentType, nodes: [NodeType]) {

        super.init(parent: parent, nodes: nodes)
    }

    //    // Append should accept a node type or class type, but I don't know how.
    //    public func append(constructorFn:NodeToNodeFunction) -> Self {
    //        for (var i = 0; i < nodes.count; i++) {
    //            let selected:NodeType = nodes[i]
    //
    //            var newNode = constructorFn(nodes[i], selected.metadata as? ValueType, i)
    //            nodes[i] = newNode
    //            parent.addChildNode(newNode) // oops this is NOT generic - can I fix with protocol?  also - use insert?
    //        }
    //        // actually self should return the appended selection!
    //        return self;
    //    }

    public func each(eachFn:NodeFunction) -> Self {
        for (i, selected) in nodes.enumerated() {

            eachFn(selected, self.metadataForNode(i:i), i)
        }
        return self;
    }

    // set a property using key value coding
    public func setKeyedAttr(keyPath: String, toValue: AnyObject!) -> Self {
        for selected in nodes {
            selected.setNodeValue(toValue, forKeyPath: keyPath)
        }

        return self;
    }

    // set a property using key value coding
    public func setKeyedAttr(keyPath: String, toValueFn: NodeToIdFunction) -> Self {
        for (i, node) in nodes.enumerated() {

            node.setNodeValue(toValueFn(node, self.metadataForNode(i:i), i), forKeyPath: keyPath)
        }
        return self;
    }

    // TODO: move attr and setKeyedAttr default implementations up the tree.
    // shorthand alias for setKeyedAttr to work like d3
    public func attr(keyPath: String, toValue: AnyObject!) -> Self {
        return setKeyedAttr(keyPath: keyPath, toValue: toValue)
    }

    // shorthand alias for setKeyedAttr to work like d3
    public func attr(keyPath: String, toValueFn: NodeToIdFunction) -> Self {
        return setKeyedAttr(keyPath: keyPath, toValueFn: toValueFn)
    }

    // compound attr for functions
    // TODO: can I unify the value and function dictionary representations?
    public func attr(keyedFunctions: [String:NodeToIdFunction]) -> Self {

        // TODO: performance - could iterate the nodes outside?
        for (keyPath, toValueFn) in keyedFunctions  {
            attr(keyPath: keyPath, toValueFn: toValueFn)
        }
        return self;
    }

    // compound attr for values
    public func attr(keyedValues: [String:AnyObject?]) -> Self {

        // TODO: performance - could iterate the nodes outside?
        for (keyPath, toValue) in keyedValues  {
            attr(keyPath: keyPath, toValue: toValue)
        }
        return self;
    }

    //    /// Append should accept a node type or class type, but I don't know how.
    //    // actually a form of this should be available before JOIN.
    //    // TODO: FIXME: this append should append a child, not replace the node!
    //    public func append(constructorFn:NodeToNodeFunction) -> JoinedSelection<NodeType, ValueType> {
    //
    //        println("Joined override")
    //
    //        for (var i = 0; i < nodes.count; i++) {
    //            let selected:NodeType = nodes[i]
    //
    //            var newNode = constructorFn(nodes[i],selected.metadata as? ValueType, i)
    //            nodes[i] = newNode
    //            parent.addChildNode(newNode) // oops this is NOT generic - can I fix with protocol?  also - use insert?
    //        }
    //        // actually self should return the appended selection!
    //        return self;
    //    }

    internal func metadataForNode(i:Int) -> ValueType? {
        let node:NodeType = nodes[i]

        // unfortunate boxing required to handle tuples stored in
        // NSMutableDictionary.  Can't push it down to the helper
        // right now

        let boxedMetadata = node.metadata as? BoxedValueType

        let unboxedMetadata = boxedMetadata?.value

        return unboxedMetadata
    }
}

// as yet unused - need things to inherit from this
//public class DataDominantSelection<NodeType: KVC & TreeNavigable & NodeMetadata, ValueType> : JoinedSelection<NodeType, ValueType> {
//
//    // Convenience types
//    internal typealias NodeDataType = NodeData<NodeType, ValueType>
//
//    // Properties
//
//    /// Vector of Node / Data pairs for existing nodes
//    internal var nodeData:[NodeDataType]
//
//    internal init (parent:ParentType, nodeData:[NodeDataType]) {
//
//    }
//
//}

// PerfectSelection is a Node-Data join that has values for both sides
// (assuming someone hasn't futzed with the node graph or metadata)
public class PerfectSelection<NodeType: KVC & TreeNavigable & NodeMetadata, ValueType> : JoinedSelection<NodeType, ValueType> {

    // Convenience types
    internal typealias NodeDataType = NodeData<NodeType, ValueType>

    // Properties

    /// Vector of Node / Data pairs for existing nodes
    internal var nodeData:[NodeDataType]

    internal init (parent:ParentType, nodeData:[NodeDataType], nodes:[NodeType]) {

        self.nodeData = nodeData

        super.init(parent: parent, nodes: nodes)
    }

    #if transitionFeatures
    public func transition(duration: TimeInterval = 3) -> TransitionSelection<NodeType, ValueType> {
        return TransitionSelection(parent: self.parent, nodes:self.nodes, duration:duration)
    }
    #endif

    /// Append adds a new child node to every node in the selection
    // Take care when using on data-dominant selections - a join
    // after an append can go badly wrong.  Updateselection is a perfect selection
    // so that's OK.
    //
    // returns a new UpdateSelection containing the created nodes.
    // binds the child nodes to the same metadata.
    public func append(constructorFn:NodeToNodeFunction) -> PerfectSelection {

        var newNodes = [NodeType]()

        for (i, selected) in nodes.enumerated() {
            // MARK: WORKING FACE
            var newNode = constructorFn(nodes[i], selected.metadata as? ValueType, i)

            nodeData.append(NodeDataType(node: newNode,
                                         value: nodeData[i].value))

            let boxedMetadata:BoxedValueType = BoxedValueType(value: nodeData[i].value)
            newNode.metadata = boxedMetadata

            newNodes.append(newNode)
            nodes[i].addChildNode(newNode)
        }

        return PerfectSelection<NodeType, ValueType>(parent: self.parent, nodeData: [], nodes:newNodes);
    }

    public func call(function: (PerfectSelection) -> ()) -> Self {
        function(self)

        return self
    }
}

// MARK: JoinSelection (DataSelection)

// Join Selection deals with data-bound node?s only
// This is a precursor to Enter, Exit and Update selections
public class JoinSelection<NodeType: KVC & TreeNavigable & NodeMetadata, ValueType> : JoinedSelection<NodeType, ValueType> {

    // Convenience types
    internal typealias NodeDataType = NodeData<NodeType, ValueType>

    // Properties

    /// Vector of Node / Data pairs for existing nodes
    internal var nodeData:[NodeDataType]

    internal var selectionData:[ValueType];

    /// Vector of (missing) Node / Data pairs for existing nodes
    internal var enterNodeData:[NodeDataType]

    /// boundData is a vector of arbitrary data type (preferable homogeneous).
    // this value is just kept around for debugging
    // try using tuples or dictionaries.
    internal var boundData:[ValueType];

    /// selection is a vector of NodeTypes discovered by the selection criteria.
    /// selection is a vector of optional NodeTypes.  These are the representable
    // manipulable nodes in the scene graph.  Right now selection is just the nodes
    // which are present and have a new data node that could be bound to them
    internal var selection:[NodeType];

    // Note that the selections need to act upon the original data and node
    // objects, in place, even in the face of mutation of a different
    // selection - ie the enterSelection needs to act upon the same nodes that
    // selection acts upon (later)
    // enter and exit should probably be separate selection objects, too.
    // how can I maintain a stable index?  perhaps store it in the userData?
    // is the enter index based upon the master selection order or the enter
    // selection order?  Is the exit index stable?  I can't see how unless
    // it's only local

    // exitSelection is the set of nodes (that have only latent data from prior calls)
    // that should be removed using exit().remove(), or animated
    // ISSUE: there may be a race condition if a later selection picks them up
    // while they are in a timed animation and exit.  Should take care to check that
    // such nodes have their timed exit terminated (or that they are not eligible)
    public var exitSelection:[NodeType]

    // computed accessor to get managed nodes & data
    public override var nodes:[NodeType] { get {
        // the enter (before append) is empty by definition

        return nodeData.flatMap { $0.node }
        }
        set {}
    }

    // unkeyed version of join init
    public init(parent:ParentType, nodes initialSelection:[NodeType], data boundData: [ValueType]) {

        self.boundData = boundData;

        var retainedSelection = [NodeType]()
        var exitSelection = [NodeType]()
        var nodeData = [NodeDataType]()
        var enterNodeData = [NodeDataType]()

        // count up how many nodes to preserve, how many to create and how many to destroy.
        // note that for simple indexed joins, we either create OR destroy, not both
        let retainedCount = min(boundData.count,initialSelection.count)

        retainedSelection.reserveCapacity(retainedCount)
        exitSelection.reserveCapacity(max(0,initialSelection.count - boundData.count))
        nodeData.reserveCapacity(boundData.count)
        enterNodeData.reserveCapacity(max(0,boundData.count - initialSelection.count))

        // handle the Simple index case - where unique keys have not been supplied

        // grab the retained selection - those nodes we are going to keep that already exist

        for i in 0 ..< retainedCount {
            var updatedNode:NodeType = initialSelection[i]
            let updatedValue = boundData[i]

            retainedSelection.append(updatedNode)

            nodeData.append(NodeDataType(node: updatedNode,
                                         value: updatedValue))

            let boxedMetadata:BoxedValueType = BoxedValueType(value: updatedValue)
            updatedNode.metadata = boxedMetadata
        }

        // grab the enter selection, which has no nodes yet
        for i in retainedCount ..< boundData.count {
            let newNodeData = NodeDataType(node: nil,
                                           value: boundData[i])

            nodeData.append(newNodeData)
            enterNodeData.append(newNodeData)
        }

        // grab the exit selection
        for i in boundData.count ..< initialSelection.count {
            exitSelection.append(initialSelection[i])
        }

        self.selection = retainedSelection as [NodeType]
        self.selectionData = boundData // dubious - could be retainedData?

        self.exitSelection = exitSelection

        self.nodeData = nodeData
        self.enterNodeData = enterNodeData

        super.init(parent: parent, nodes: retainedSelection)
    }

    // keyed version of join init
    public init<KeyType:Hashable>(parent:ParentType, nodes initialSelection:[NodeType], data boundData: [ValueType], keyFunction:((ValueType,Int) -> KeyType)) {

        self.boundData = boundData;

        var retainedSelection = [NodeType]()
        var exitSelection = [NodeType]()
        var nodeData = [NodeDataType]()
        var enterNodeData = [NodeDataType]()

        // count up how many nodes to preserve, how many to create and how many to destroy.
        // note that for simple indexed joins, we either create OR destroy, not both
        let retainedCount = min(boundData.count,initialSelection.count)

        retainedSelection.reserveCapacity(retainedCount)
        exitSelection.reserveCapacity(max(0,initialSelection.count - boundData.count))
        nodeData.reserveCapacity(boundData.count)
        enterNodeData.reserveCapacity(max(0,boundData.count - initialSelection.count))

        // handle the keyed case
        // incoming data must be bound to the correct nodes

        // the set of node keys that will be exited
        var boundDataDictionary = [KeyType:ValueType]()
        var boundNodeDictionary = [KeyType:NodeType]()

        // make a dictionary of bound data
        for (i, boundDatum) in boundData.enumerated() {
            let key = keyFunction(boundDatum, i)

            if nil != boundDataDictionary[key] {
                fatalError("Duplicate key \(key) in data")
            }

            boundDataDictionary[key] = boundDatum
        }

        // make a dictionary of nodes
        for (i, initialNode) in initialSelection.enumerated() {

            if let boxedMetadata = initialNode.metadata as? BoxedValueType {
                let metaData = boxedMetadata.value
                let key = keyFunction(metaData, i)

                if nil != boundNodeDictionary[key] {
                    fatalError("Duplicate key \(key) in data")
                }

                boundNodeDictionary[key] = initialSelection[i]
            }
        }

        // update the exit and retained selection by searching for
        // data keys in the nodes.  bind as appropriate
        for (key, var node) in boundNodeDictionary {
            if let updatedValue = boundDataDictionary[key] {
                retainedSelection.append(node)

                nodeData.append(NodeDataType(node: node,
                                             value: updatedValue))

                let boxedMetadata:BoxedValueType = BoxedValueType(value: updatedValue)
                node.metadata = boxedMetadata
            } else {
                exitSelection.append(node)

            }
        }

        // update the enter selection by searching for
        // unbound data keys in the nodes.  bind as appropriate
        for (key, updatedValue) in boundDataDictionary {
            if let _ /* updatedNode */ = boundNodeDictionary[key] {

            } else {
                let newNodeData = NodeDataType(node: nil,
                                               value: updatedValue)

                nodeData.append(newNodeData)
                enterNodeData.append(newNodeData)
            }
        }

        self.selection = retainedSelection as [NodeType]
        self.selectionData = boundData // dubious - could be retainedData?

        self.exitSelection = exitSelection

        self.nodeData = nodeData
        self.enterNodeData = enterNodeData

        super.init(parent: parent, nodes: retainedSelection)
    }

    override public var data:[ValueType] { get {
        return boundData
        } } // this TYPE only makes sense for multiply selected things

    // dodgy function
    internal func metadata(from node:NodeType?) -> ValueType? {

        if let node = node {
            let boxedMetadata = node.metadata as? BoxedValueType

            let unboxedMetadata = boxedMetadata?.value

            return unboxedMetadata
        } else {
            return nil
        }
    }

    // Enter returns the limited selection matching only missing nodes.
    // it is passed our nodeData object so new nodes are visible.
    // see also update - which extracts a concrete set of nodes at any time
    public func enter() -> EnterSelection<NodeType, ValueType> {
        return EnterSelection<NodeType, ValueType>(parent: self.parent, nodeData: self.enterNodeData)
    }

    // Update creates a new selection containing only valid node:value pairs
    public func update() -> UpdateSelection<NodeType, ValueType> {

        let goodNodeData = nodeData.filter { (nodeDataEl:NodeDataType) -> Bool in
            return nil != nodeDataEl.node
        }

        let goodNodes = goodNodeData.map { (nodeDataEl) -> NodeType in
            nodeDataEl.node!
        }

        return UpdateSelection<NodeType, ValueType>(parent: self.parent, nodeData: goodNodeData, nodes:goodNodes)
    }

    // Return the Exit selection
    // this should only be a method on initialSelection
    public func exit() -> ExitSelection<NodeType, ValueType> {

        // let's take in on faith that exitnodes have values.  not necessarily true.
        let exitNodeData:[NodeDataType] = exitSelection.map { (node:NodeType) -> NodeDataType in
            NodeDataType(node: node, value: self.metadata(from: node)!) // metadata! is untenable here - exit might not have data
        }

        return ExitSelection<NodeType, ValueType>(parent: self.parent, nodeData: exitNodeData, nodes: exitSelection)
    }

    public override func each(eachFn:NodeFunction) -> Self {
        // TODO create more childrens (what?)

        for i in 0 ..< selection.count {
            eachFn(selection[i], selectionData[i], i)
        }
        return self;
    }

    //    // Append should accept a node type or class type, but I don't know how.
    //    public override func append(constructorFn:(NodeType?,ValueType,Int) -> NodeType ) -> Self {
    //        for (var i = 0; i < selection.count; i++) {
    //            var newNode = constructorFn(selection[i], selectionData[i], i)
    //            selection[i] = newNode
    //            parent.addChildNode(newNode) // oops this is NOT generic - can I fix with protocol?  also - use insert?
    //        }
    //        // actually self should return the appended selection!
    //        return self;
    //    }

    // Remove nodes from the document
    public override func remove() {
        print("null remove executed from JoinSelection")
        // TODO: add remove - should prune nodes
    }

    //! this is just for checking the types that the generic thinks it is.
    public func typeTest(typeFn:(ParentType,NodeType,ValueType) -> Bool) -> () {

    }

    // set a property using key value coding
    public override func setKeyedAttr(keyPath: String, toValue: AnyObject!) -> Self {
        for node in selection {
            node.setNodeValue(toValue, forKeyPath: keyPath)
        }

        return self;
    }

    // TODO: put back
    //    // set a property using key value coding
    //    public func setKeyedAttr(keyPath: String, toValueFn: NodeToIdFunction) -> Self {
    //        for (var i = 0; i < selection.count; i++) {
    //            selection[i]?.setNodeValue(toValueFn(selection[i]!, selectionData[i], i), forKeyPath: keyPath)
    //        }
    //        return self;
    //    }


}

// MARK: Update Selection

// Update Selection deals with joined nodes only.  Before enter it only
// applies to retained nodes.  After enter it applies to both retained and
// entered nodes.
// it returns to type MultiSelection after append is performed.
// extracts the concrete set of live nodes (for efficiency)
// UpdateSelection is a PerfectSelection - with complete data - value pairs
// assuming no-one has futzed with the node graph or metadata
public class UpdateSelection<NodeType: KVC & TreeNavigable & NodeMetadata, ValueType> : PerfectSelection<NodeType, ValueType> {

    // Properties

    // Initializers

    internal override init (parent:ParentType, nodeData: [NodeDataType], nodes: [NodeType])
    {
        super.init(parent: parent, nodeData: nodeData, nodes: nodes)
    }

    override public var data:[ValueType] { get {
        return nodeData.map { $0.value }
        } } // this TYPE only makes sense for multiply selected things
}

// MARK: Enter Selection

// Enter Selection deals with entered nodes only.
// it returns to type MultiSelection after append is performed.
public class EnterSelection<NodeType: KVC & TreeNavigable & NodeMetadata, ValueType> : JoinedSelection<NodeType, ValueType> {

    // Convenience types
    internal typealias NodeDataType = NodeData<NodeType, ValueType>

    // Properties

    /// Vector of Node / Data pairs for existing nodes
    internal var nodeData:[NodeDataType]

    // initializers
    internal init (parent:ParentType, nodeData: [NodeDataType]) {
        self.nodeData = nodeData

        super.init(parent: parent, nodes: [])
    }

    // computed accessor to get managed nodes & data
    override public var nodes:[NodeType] { get {
        // the enter (before append) is empty by definition
        return []
        }
        set {} }

    override public var data:[ValueType] { get {
        return nodeData.map { $0.value }
        } } // this TYPE only makes sense for multiply selected things

    /// Append for EnterSelection appends to the parent, not the current node.
    public func append(constructorFn:(NodeType?,ValueType,Int) -> NodeType ) -> PerfectSelection<NodeType, ValueType> {

        var newNodes = [NodeType]()

        for (i, datum) in nodeData.enumerated() {
            let nodeValue:ValueType = datum.value
            var newNode = constructorFn(nil, nodeValue, i)
            newNodes.append(newNode)
            nodeData[i].node = newNode // TODO: check if I need this

            newNode.metadata = BoxedValueType(value: nodeValue)

            parent.addChildNode(newNode) // oops this is NOT generic - can I fix with protocol?  also - use insert?

        }
        // actually self should return the appended selection!
        return PerfectSelection<NodeType, ValueType>(parent: parent, nodeData: nodeData, nodes: newNodes);
    }
}

// MARK: Exit Selection

// Exit Selection deals with exiting nodes only
// TODO: deprecate Exit Selection - all it's functionality exists elsewhere (probably)
// is it joined?... it's prejoined.  we can rejoin it?
// ExitSelection is not definitely a PerfectJoin - if the initial join is applied
// to an imperfect join.  We may be able to transmit this information, maybe not.
public class ExitSelection<NodeType: KVC & TreeNavigable & NodeMetadata, ValueType> : PerfectSelection<NodeType, ValueType
> {

    override internal init (parent:ParentType, nodeData: [NodeDataType], nodes: [NodeType]) {
        super.init(parent: parent, nodeData: nodeData, nodes: nodes)
    }

    // Remove nodes from the document
    // unusually, this function doesn't chain - since the represented nodes are now dead
    override public func remove() {

        //let anyArray = self.selection as [AnyObject]
        for node in nodes {
            node.removeNodeFromParent()
        }

    }

    // TODO: add dataNodes, each etc.

    public override func call(function: (ExitSelection) -> ()) -> Self {
        function(self)

        return self
    }
}


#if transitionFeatures

/// PerfectTransitionSelection is a PerfectSelection with delayed property operations
// it has a duration property which defines how long the transitions take.
// TODO: allow duration to be a function for each node.
public class TransitionSelection<NodeType: KVC & TreeNavigable & NodeMetadata, ValueType> : JoinedSelection<NodeType, ValueType> {

    let duration : TimeInterval

    internal init (parent:ParentType, nodes: [NodeType], duration:TimeInterval)
    {
        self.duration = duration
        super.init(parent: parent, nodes: nodes)
    }

    // set a property using key value coding
    public override func setKeyedAttr(keyPath: String, toValue: AnyObject!) -> Self {

        // TODO: make action deferred for at least some cases

        for (var i = 0; i < nodes.count; i++) {
            nodes[i].setNodeValueAnimated(toValue, forKeyPath: keyPath, withDuration:self.duration)
        }

        return self;
    }

    // set a property using key value coding
    public override func setKeyedAttr(keyPath: String, toValueFn: NodeToIdFunction) -> Self {

        // TODO: make action deferred for at least some cases

        for (var i = 0; i < nodes.count; i++) {

            let node:NodeType = nodes[i]

            node.setNodeValueAnimated(toValueFn(node, self.metadataForNode(i:i), i), forKeyPath: keyPath, withDuration:self.duration)
        }
        return self;
    }

    override public func remove() {

        for var i = 0; i < self.nodes.count; i++ {
            self.nodes[i].removeNodeFromParent(duration)
        }
    }
}

// imperfect Transition
public class TransitionMultiSelection<NodeType: KVC & TreeNavigable & NodeMetadata> : MultiSelection<NodeType> {

    let duration : TimeInterval

    internal init (parent:ParentType, nodes: [NodeType], duration:TimeInterval)
    {
        self.duration = duration
        super.init(parent: parent, nodes: nodes)
    }

    // set a property using key value coding
    public override func setKeyedAttr(keyPath: String, toValue: AnyObject!) -> Self {

        // TODO: make action deferred for at least some cases

        for (var i = 0; i < nodes.count; i++) {
            nodes[i].setNodeValueAnimated(toValue, forKeyPath: keyPath, withDuration:self.duration)
        }

        return self;
    }

    // set a property using key value coding
    public override func setKeyedAttr(keyPath: String, toValueFn: NodeToIdFunction) -> Self {

        // TODO: make action deferred for at least some cases

        for (i, node) in nodes.enumerated() {

            node.setNodeValueAnimated(toValueFn(node, (), i), forKeyPath: keyPath, withDuration:self.duration)
        }
        return self;
    }

    override public func remove() {

        // be careful what we are iterating across here to avoid deleting and iterating
        for node in nodes {
            node.removeNodeFromParent(duration)
        }
    }
}

#endif



