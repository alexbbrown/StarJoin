//
//  Selection.swift
//  StarJoinSelector
//
//  Created by apple on 19/08/2014.
//  Copyright (c) 2014 apple. All rights reserved.
//

// Issues
// * Selection class should not be bound up with a specific class, but should support any class obeying protocols allowing tree walking and manipulation.
// * d might be not optional?
// * do I still need boxing?

// handy d3 references
// https://github.com/mbostock/d3/blob/48ad44fdeef32b518c6271bb99a9aed376c1a1d6/src/selection/data.js

// TODO:[new]
// Where's my state machine?
// get the old one working;
// build a NEW one.
// handle node structures which are not shallow heirarchies
// handle data structures which are not arrays

// update to d3.js new merge selection semantics - merges two selections, should be used after enter!
// https://github.com/d3/d3-selection/issues/60 - merge issue
// https://github.com/d3/d3-selection/blob/master/README.md#selection_merge

// TODO:[old]
// refactor into DataDominant, NodeDominant, and Perfect joins
// rationalise the the setKeyAttr logic
// deprecate setKeyAttr in favour of attr
// allow simple types and tuples to pass setKeyAttr
// Allow data function to be a dictionary, which is auto-keyed. Perhaps a common ancestor of Array, Dictionary

import Foundation

// NodeData carries Node, Value pairs,
// even if Node is missing.  Note that live
// nodes keep a reference to their data, too
// is this just a convenience or is it critical?
// is this really a map?  or even a weak map?
public struct NodeData<NodeType, ValueType> {
    public var node:NodeType?
    public var value:ValueType
    init(node:NodeType?, value:ValueType) {
        self.node = node
        self.value = value
    }
}

// MARK: -
// Selection is just a boring abstract base class.  Sets the Node and Value types
// although ValueType might become subclass specific later.
public class Selection<ParentType, NodeType> {

    // public accessible so axis can use it
    public var nodes:[NodeType]

    // Convenience data types

    /// Abstract
    public func select<NewNodeType>(all nodes: [NewNodeType]) -> MultiSelection<ParentType, NewNodeType> {
        fatalError("This method must be overridden")
    }

    // This needs generalising - a select on a multiselection returns a multiselection
    // this one just returns a selection for one node.
    /// Starting point : make the initial selection
    public class func select<NewNodeType>(only node: NewNodeType) -> SingleSelection<NewNodeType> {
        return SingleSelection(node: node)
    }

    fileprivate init(nodes:[NodeType]) {
        self.nodes = nodes
    }

    convenience public init(node:NodeType) {
        self.init(nodes:[node])
    }
}

// MARK: -
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
// this might be a selection of a parent only - we should distinguish between this and grabbing a single node to manipulate it
public class SingleSelection<ParentType> : Selection<Void, ParentType>
where ParentType : TreeNavigable & KVC & NodeMetadata {

    typealias NodeType = ParentType

    // These nodes should be descendants of the parent node
    /// Step 2. select the children -
    /// * example: select(all: root.children)
    public func select<NewNodeType>(all nodes: [NewNodeType]) -> MultiSelection<ParentType, NewNodeType>
    where NewNodeType : KVC & NodeMetadata {
        return .init(parent: self.nodes[0], nodes: nodes)
    }

    // These nodes should be descendants of the parent node
    public func select<NewNodeType>(all nodes: (ParentType) -> [NewNodeType]) -> MultiSelection<ParentType, NewNodeType> {
        return .init(parent: self.nodes[0], nodes: nodes(self.nodes[0]))
    }

    // todo: add initialisers for other kinds of searching, and add a
    // select method (which is also a subscript operator) for sub-selection

    // todo: append2
    //internal typealias CallFunction = (Selection) -> ()

    @discardableResult public
    func call(function: (SingleSelection) -> ()) -> Self {
        function(self)

        return self
    }

    convenience fileprivate init(node:NodeType) {
        self.init(nodes:[node])
    }
}

// MARK: -

// (internal) InternalMultiSelection represents the common properties and actions
// of a multiple selection

internal class InternalMultiSelection<ParentType, NodeType> : Selection<ParentType, NodeType> {

    // Convenience Types

    // Properties

    /// The parent object is where new objects are created.  This is
    // probably incorrect in the long run; new objects may be created
    // on cascading created objects.
    internal var parent:ParentType // TODO: should be readonly (really?)
    // computed accessor to get managed nodes & data
    /// selection is the set of nodes initially supplied

    internal init(parent:ParentType, nodes:[NodeType]) {
        self.parent = parent

        super.init(nodes: nodes)
    }
}

// MARK: -

// MultiSelection deals with pre-joined state - SelectAlls.
// MultiSelection can be operated upon as basic selections, or converted
// into a JoinSelection
public class MultiSelection<ParentType, NodeType> : InternalMultiSelection<ParentType, NodeType> {


    // Convenience Types
    public typealias NodeValueIndexToVoid = (NodeType?,Void,Int) -> ()
    public typealias NodeValueIndexToAny = (NodeType?,Void,Int) -> Any?
    public typealias NodeValueIndexToNode = (NodeType?,Void,Int) -> NodeType

    // Properties

    // Constructor for specific nodes, equivalent to selectAll
    // TODO: add constructors for patterns, too.
    internal override init(parent:ParentType, nodes:[NodeType]) {

        super.init(parent: parent, nodes: nodes)
    }

    public func join<ValueType,KeyType:Hashable>(_ data:[ValueType], keyFunction:(ValueType,Int) -> KeyType) -> JoinPreSelection<ParentType, NodeType, ValueType> {
        return .init(parent: self.parent,
                     nodes: self.nodes,
                     data: data,
                     keyFunction: keyFunction)
    }

    public func join<ValueType>(_ data: [ValueType]) -> JoinPreSelection<ParentType, NodeType, ValueType> {
        return .init(parent: self.parent,
                     nodes: self.nodes,
                     data: data)
    }

    @discardableResult public func each(_ eachFn:NodeValueIndexToVoid) -> Self {
        // TODO create more childrens
        for (i, selected) in nodes.enumerated() {

            // unfortunate boxing required to handle tuples stored in
            // NSMutableDictionary.  Can't push it down to the helper
            // right now

            eachFn(selected, (), i)
        }
        return self;
    }

}

extension MultiSelection where NodeType : KVC & NodeMetadata {

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValueFn: NodeValueIndexToAny) -> Self {
        for (i, node) in nodes.enumerated() {
            node.setNodeValue(toValueFn(node, (), i), forKeyPath: keyPath)
        }
        return self;
    }


}

// MARK: -

/// (internal) JoinedSelection includes the operations that are possible on a bound or pre-joined selection
// note that JoinedSelection inherited from a pre-entered Join may contain partially bound data
// where there is a value but no node.
// update should be used to split out notes with no value.  It is not possible to address nodes that
// don't exists - this has changed - a JoinedSelection cannot (apart from subclasses) contain missing nodes
public class InternalJoinedSelection<ParentType, NodeType, ValueType> : InternalMultiSelection<ParentType, NodeType>
     where NodeType : KVC & NodeMetadata {


    // Convenience Types
    public typealias NodeValueIndexToVoid = (NodeType?,ValueType,Int) -> ()
    // TODO: should probably call this NodeToValue function and make it return Any
    public typealias NodeValueIndexToAny = (NodeType?,ValueType,Int) -> Any?
    public typealias NodeValueIndexToNode = (NodeType?,ValueType,Int) -> NodeType

    // Properties

    // TODO: return data - strip out missing results, perhaps? or return ValueType?
    fileprivate var data:[ValueType] { return [] } // this TYPE only makes sense for multiply selected things

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
// MARK: -

// PerfectSelection is a Node-Data join that has values for both sides
// (assuming someone hasn't futzed with the node graph or metadata)
// Child types: ExitSelection (WHAT?) and UpdateSelection
public class PerfectSelection<ParentType, NodeType, ValueType> : InternalJoinedSelection<ParentType, NodeType, ValueType>
where NodeType : KVC & NodeMetadata {

    // Convenience types
    fileprivate typealias NodeDataType = NodeData<NodeType, ValueType>

    // Properties

    /// Vector of Node / Data pairs for existing nodes
    fileprivate var nodeData:[NodeDataType]

    fileprivate init(parent:ParentType, nodeData:[NodeDataType], nodes:[NodeType]) {

        self.nodeData = nodeData

        super.init(parent: parent, nodes: nodes)
    }


    @discardableResult public func each(_ eachFn:NodeValueIndexToVoid) -> Self {
        for (i, node) in nodes.enumerated() {
            let dataValue = self.metadata(from: node)
            eachFn(node, dataValue!, i) // TODO: explain the ! here - any if it's true.  what about re-binds?
        }
        return self;
    }

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValue: Any!) -> Self {
        for selected in nodes {
            selected.setNodeValue(toValue, forKeyPath: keyPath)
        }
        return self;
    }

    // set a property using key value coding
    @discardableResult public func attr(_ keyPath: String, toValueFn: NodeValueIndexToAny) -> Self {
        for (i, node) in nodes.enumerated() {
            let dataValue = self.metadata(from: node)
            node.setNodeValue(toValueFn(node, dataValue!, i), forKeyPath: keyPath) // todo: explain the ! here
        }
        return self;
    }

    private func metadata(from node:NodeType?) -> ValueType? {
        return node?.metadata as? ValueType
    }

    public func call(function: (PerfectSelection) -> ()) -> Self {
        function(self)

        return self
    }
}

// MARK: -

// Join Selection deals with data-bound node?s only
// This is a precursor to Enter, Exit and Update selections
// ultimately it's not really a selection at all, and should not be!
final public class JoinPreSelection<ParentType, NodeType, ValueType>
where ParentType : TreeNavigable, NodeType : KVC & NodeMetadata, ParentType.ChildType == NodeType  {

    // Convenience types
    private typealias NodeDataType = NodeData<NodeType, ValueType>

    // Debug Properties

    // this is just to make unit tests work - i'm not sure having data like this is meaningful
    internal var debugNewData:[ValueType] { return boundData } // this TYPE only makes sense for multiply selected things

    // computed accessor to get managed nodes & data
    internal var debugNodes:[NodeType] { get {
        // the enter (before append) is empty by definition
        return updateAndEnterNodeData.flatMap { $0.node }
        }
        set { }
    }

    // Properties

    internal let parent:ParentType

    /// Vector of Node / Data pairs including the unrealised enter nodes
    private let updateAndEnterNodeData: [NodeDataType]

    private let updateSelection:(nodes: [NodeType], values: [ValueType])

    /// Vector of (missing) Node / Data pairs for existing nodes
    private let enterValues: [ValueType]

    /// boundData is a vector of arbitrary data type (preferable homogeneous).
    // this value is just kept around for debugging
    // try using tuples or dictionaries.
    private let boundData: [ValueType]

    /// selection is a vector of NodeTypes discovered by the selection criteria.
    /// selection is a vector of optional NodeTypes.  These are the representable manipulable nodes in the scene graph.
    /// Right now selection is just the nodes which are present and have a new data node that could be bound to them

    //     Note that the selections need to act upon the original data and node objects, in place, even in the face of mutation of a different selection - ie the enterSelection needs to act upon the same nodes that selection acts upon (later)
    // enter and exit should probably be separate selection objects, too.
    // How can I maintain a stable index?  perhaps store it in the userData?
    // is the enter index based upon the master selection order or the enter
    // selection order?  Is the exit index stable?  I can't see how unless it's only local

    // exitSelection is the set of nodes (that have only latent data from prior calls)
    // that should be removed using exit().remove(), or animated
    // ISSUE: there may be a race condition if a later selection picks them up
    // while they are in a timed animation and exit.  Should take care to check that
    // such nodes have their timed exit terminated (or that they are not eligible)
    private let exitSelection:[NodeType]


    // unkeyed version of join init
    fileprivate init(parent:ParentType, nodes initialSelection:[NodeType], data boundData: [ValueType]) {

        self.boundData = boundData;

        var retainedSelection = [NodeType]()
        var exitSelection = [NodeType]()
        var updateAndEnterNodeData = [NodeDataType]()
        var enterValues = [ValueType]()

        // count up how many nodes to preserve, how many to create and how many to destroy.
        // note that for simple indexed joins, we either create OR destroy, not both
        let boundCount = boundData.count
        let retainedCount = min(boundCount, initialSelection.count)

        retainedSelection.reserveCapacity(retainedCount)
        exitSelection.reserveCapacity(max(0,initialSelection.count - boundData.count))
        updateAndEnterNodeData.reserveCapacity(boundData.count)
        enterValues.reserveCapacity(max(0,boundData.count - initialSelection.count))

        // handle the Simple index case - where unique keys have not been supplied

        // grab the retained selection - those nodes we are going to keep that already exist

        for (var nodeToUpdate, valueToUpdateWith) in zip(initialSelection, boundData) {

            // may want to re-order these 3 statements, depending, when nodeToUpdate is immutable
            retainedSelection.append(nodeToUpdate)

            updateAndEnterNodeData.append(NodeDataType(node: nodeToUpdate,
                                         value: valueToUpdateWith))

            // write the new metadata for the updated node only.
            // TODO: consider handling the old value somehow, too.
            nodeToUpdate.metadata = valueToUpdateWith
        }

        // grab the enter selection, which has no nodes yet
        enterValues = Array(boundData.dropFirst(initialSelection.count))

        // grab the exit selection
        for excessNode in initialSelection.dropFirst(boundData.count) {
            exitSelection.append(excessNode)
        }

        updateSelection = (nodes:retainedSelection,
                           values:boundData // dubious - could be retainedData?
            )

        self.exitSelection = exitSelection

        self.updateAndEnterNodeData = updateAndEnterNodeData
        self.enterValues = enterValues

        self.parent = parent
//        super.init(parent: parent, nodes: retainedSelection)
    }

    // keyed version of join init
    fileprivate init<KeyType:Hashable>(parent:ParentType, nodes initialSelection:[NodeType], data boundData: [ValueType], keyFunction:((ValueType,Int) -> KeyType)) {

        self.boundData = boundData;

        var retainedSelection = [NodeType]()
        var exitSelection = [NodeType]()
        var updateAndEnterNodeData = [NodeDataType]()
        var enterValues = [ValueType]()

        // count up how many nodes to preserve, how many to create and how many to destroy.
        // note that for simple indexed joins, we either create OR destroy, not both
        let retainedCount = min(boundData.count,initialSelection.count)

        retainedSelection.reserveCapacity(retainedCount)
        exitSelection.reserveCapacity(max(0,initialSelection.count - boundData.count))
        updateAndEnterNodeData.reserveCapacity(boundData.count)
        enterValues.reserveCapacity(max(0,boundData.count - initialSelection.count))

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

            if let metaData = initialNode.metadata as? ValueType {
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

                updateAndEnterNodeData.append(NodeDataType(node: node,
                                             value: updatedValue))

                node.metadata = updatedValue
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

                // TODO: the nodeData (update set) should not include the new ones
                // TODO: expect a new merge selection operation!
                updateAndEnterNodeData.append(newNodeData)
                enterValues.append(updatedValue)
            }
        }

        updateSelection = (nodes:retainedSelection,
                           values:boundData // dubious - could be retainedData?
        )

        self.exitSelection = exitSelection

        self.updateAndEnterNodeData = updateAndEnterNodeData
        self.enterValues = enterValues

//        super.init(parent: parent, nodes: retainedSelection)
        self.parent = parent
    }

    // Enter returns the limited selection matching only missing nodes.
    // it is passed our nodeData object so new nodes are visible.
    // see also update - which extracts a concrete set of nodes at any time
    public func enter() -> EnterPreSelection<ParentType, ValueType> {
        return .init(parent: self.parent, data: self.enterValues)
    }

    // Update creates a new selection containing only valid node:value pairs
    // this needs clarifying (and unit testing - can update include enter or not?)
    public func update() -> UpdateSelection<ParentType, NodeType, ValueType> {

        // There's a new plan: this behaviour is naughty now
        // it should only return the goodNodeData.
        let goodNodeData = updateAndEnterNodeData.filter { (nodeDataEl:NodeDataType) -> Bool in
            return nil != nodeDataEl.node
        }

        let goodNodes = goodNodeData.map { (nodeDataEl) -> NodeType in
            nodeDataEl.node!
        }

        return UpdateSelection<ParentType, NodeType, ValueType>(parent: self.parent, nodeData: goodNodeData, nodes:goodNodes)
    }

    // Return the Exit selection
    // this should only be a method on initialSelection
    public func exit() -> ExitSelection<ParentType, NodeType, ValueType> {

        // let's take in on faith that exitnodes have values.  not necessarily true.
        // FIXME: metadata! is untenable here - exit might not have data value?
        // d is now !, not ?; so we don't check.  Perhaps we ONLY exit managed nodes (with metadata?)
        // that doesn't work if we expect to execute on arrays.  But it would work if we always work on
        // selections - even for reselection.
        let exitNodeData:[NodeDataType] = exitSelection.map { (node:NodeType) in
            NodeDataType(node: node, value: node.metadata as! ValueType)
        }

        return .init(parent: self.parent, nodeData: exitNodeData, nodes: exitSelection)
    }

}

// MARK: -

// Update Selection deals with joined nodes only.  Before enter it only
// applies to retained nodes.  After enter it applies to both retained and
// entered nodes.
// it returns to type MultiSelection after append is performed.
// extracts the concrete set of live nodes (for efficiency)
// UpdateSelection is a PerfectSelection - with complete data - value pairs
// assuming no-one has futzed with the node graph or metadata

// for perfect selection (update selection) can we do away with the parent?  If we aren't allowed to BIND again, we could.
final public class UpdateSelection<ParentType, NodeType, ValueType> : PerfectSelection<ParentType, NodeType, ValueType>
where ParentType : TreeNavigable, NodeType : KVC & NodeMetadata {

    // Properties

    // Initializers

//    internal override init (parent:ParentType, nodeData: [NodeDataType], nodes: [NodeType])
//    {
//        super.init(parent: parent, nodeData: nodeData, nodes: nodes)
//    }

    override fileprivate var data:[ValueType] { get {
        return nodeData.map { $0.value }
        } } // this TYPE only makes sense for multiply selected things

    // TODO: I consider this one to be probably the one that should get the active attr methods

    public func merge(with enterSelection:AppendedSelection<ParentType, NodeType, ValueType>) -> UpdateSelection<ParentType, NodeType, ValueType> {

        let combinedNodeData = self.nodeData + enterSelection.nodeData

        let combinedNodes = combinedNodeData.map { (nodeDataEl) -> NodeType in
            nodeDataEl.node!
        }

        return UpdateSelection<ParentType, NodeType, ValueType>(parent: self.parent, nodeData: combinedNodeData, nodes:combinedNodes)
    }

}

// MARK: -

// Enter Selection deals with entered nodes only.
// it returns to type MultiSelection after append is performed.
// TODO: EnterSelection has an 'each' but it's action is unexpected - it operates on 0 entries.  Is that intentional?  is enterselection really a joined selection?
final public class EnterPreSelection<ParentType, ValueType>
where ParentType : TreeNavigable { // should just be treenavigable here

    public typealias NodeType = ParentType.ChildType
    public typealias NodeValueIndexToVoid = (NodeType?,Void,Int) -> ()

    // Properties

    /// Vector of Node / Data pairs for existing nodes
    private var data:[ValueType]
    internal var parent:ParentType // TODO: should be readonly (really?)

    // initializers
    fileprivate init (parent:ParentType, data: [ValueType]) {
        self.parent = parent
        self.data = data
    }

    // internal for testability
    internal var debugNewData:[ValueType] {
        return data
    }

    /// Append for EnterSelection appends to the parent, not the current node.
    @discardableResult public
    func append<NewNodeType>(constructorFn:(ValueType,Int) -> NewNodeType ) -> AppendedSelection<ParentType, NewNodeType, ValueType>
    where NewNodeType==ParentType.ChildType, NewNodeType : KVC & TreeNavigable & NodeMetadata {

        // Convenience types
        typealias NewNodeDataType = NodeData<NewNodeType, ValueType>

        var newNodes:[NewNodeType] = []
        var nodeData:[NewNodeDataType] = []

        for (i, value) in data.enumerated() {

            var newNode = constructorFn(value, i)
            newNodes.append(newNode)
            nodeData.append(NewNodeDataType(node: newNode, value: value))

            newNode.metadata = value

            parent.add(child:newNode) // oops this is NOT generic - can I fix with protocol?  also - use insert?

        }
        // actually self should return the appended selection!
        // FIXME: let's get rid of as NewNodeType
        return AppendedSelection<ParentType, NewNodeType, ValueType>(parent: parent, nodeData: nodeData, nodes: newNodes)
    }
}

// MARK: -

// Exit Selection deals with exiting nodes only
// TODO: deprecate Exit Selection - all it's functionality exists elsewhere (probably)
// is it joined?... it's prejoined.  we can rejoin it?
// ExitSelection is not definitely a PerfectJoin - if the initial join is applied
// to an imperfect join.  We may be able to transmit this information, maybe not.
final public class ExitSelection<ParentType, NodeType, ValueType> : PerfectSelection<ParentType, NodeType, ValueType>
where ParentType : TreeNavigable, NodeType : KVC & NodeMetadata, ParentType.ChildType == NodeType {

//    override fileprivate init(parent:ParentType, nodeData: [NodeDataType], nodes: [NodeType]) {
//        super.init(parent: parent, nodeData: nodeData, nodes: nodes)
//    }

    // Remove nodes from the document
    // unusually, this function doesn't chain - since the represented nodes are now dead
    public func remove() {

        //let anyArray = self.selection as [AnyObject]
        for node in nodes {
            parent.remove(child: node)
        }

    }

    // TODO: add dataNodes, each etc.

    public override func call(function: (ExitSelection) -> ()) -> Self {
        function(self)

        return self
    }
}

final public class AppendedSelection<ParentType, NodeType, ValueType> : PerfectSelection<ParentType, NodeType, ValueType>
where ParentType : TreeNavigable, NodeType : KVC & NodeMetadata {

}

// MARK: -

// extensions

#if true
extension PerfectSelection {

    // this isn't exactly the same as the main append - so let's call it append2
    // it's tested in the axis logic

    /// Append adds a new child node to every node in the selection
    // Take care when using on data-dominant selections - a join
    // after an append can go badly wrong.  Updateselection is a perfect selection
    // so that's OK.
    //
    // returns a new UpdateSelection containing the created nodes.
    // binds the child nodes to the same metadata.
    // TODO: There should be a datafn version of this which calculates the bound data item
    // e.g. if it's a subfield of the parent.
    public func append2<NewNodeType>(constructorFn:(NodeType?,ValueType,Int) -> NewNodeType) -> PerfectSelection<Void, NewNodeType, ValueType>
    where NewNodeType==NodeType.ChildType, NodeType : TreeNavigable, NewNodeType : KVC & NodeMetadata {

        // Convenience types
        typealias NewNodeDataType = NodeData<NewNodeType, ValueType>

        var newNodes:[NewNodeType] = []
        var newNodeData:[NewNodeDataType] = []

        for (i, oldNode) in nodes.enumerated() {
            // MARK: WORKING FACE
            
            var newNode = constructorFn(oldNode, oldNode.metadata as! ValueType, i)

            newNodeData.append(NewNodeDataType(node: newNode,
                                               value: nodeData[i].value))

            newNode.metadata = nodeData[i].value

            newNodes.append(newNode)
            oldNode.add(child: newNode)
        }

        // It's too hard to fit parents into this model, so I'm just throwing up my hands.  There's no parent.
        return .init(parent: (), nodeData: newNodeData, nodes: newNodes)

        //
    }
}
#endif
