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
// get the old one working -> build a NEW one.
// handle node structures which are not shallow heirarchies
// handle data structures which are not arrays
// handle data structures which are non linear
// handle data structures which are generic collections
// examine rebind

// update to d3.js new merge selection semantics - merges two selections, should be used after enter!
// https://github.com/d3/d3-selection/issues/60 - merge issue
// https://github.com/d3/d3-selection/blob/master/README.md#selection_merge

// TODO:[old]
// refactor into DataDominant, NodeDominant, and Perfect joins
// Allow data function to be a dictionary, which is auto-keyed. Perhaps a common ancestor of Array, Dictionary

import Foundation

// NodeData carries Node, Value pairs,
// even if Node is missing.  Note that live
// nodes keep a reference to their data, too
// is this just a convenience or is it critical?
// is this really a map?  or even a weak map?
public struct NodeValuePair<NodeType, ValueType> {
    public var node:NodeType?
    public var value:ValueType
    init(node:NodeType?, value:ValueType) {
        self.node = node
        self.value = value
    }
}

// This needs generalising - a select on a multiselection returns a multiselection
// this one just returns a selection for one node.
/// Starting point : make the initial selection of the root node
public class StarJoin {
    public class func select<NodeType>(only node: NodeType) -> SingleSelection<NodeType> {
        return SingleSelection(node: node)
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
public class SingleSelection<NodeType>
where NodeType : TreeNavigable {

    private var nodes:[NodeType]

    // for skaxis
    public var node:NodeType { return nodes[0] }

    // These nodes should be descendants of the parent node
    /// Step 2. select the children -
    /// * example: select(all: root.children)
    public func select<NewNodeType>(all nodes: [NewNodeType]) -> MultiSelection<NodeType, NewNodeType> {
        return .init(parent: self.nodes[0], nodes: nodes)
    }

    
    // These nodes should be descendants of the parent node
    public func select<NewNodeType>(all nodes: (NodeType) -> [NewNodeType]) -> MultiSelection<NodeType, NewNodeType> {
        return .init(parent: self.nodes[0], nodes: nodes(self.nodes[0]))
    }

    // todo: add initialisers for other kinds of searching, and add a
    // select method (which is also a subscript operator) for sub-selection

    // todo: append2 for cases other than perfect selection

    public init(node:NodeType) {
        self.nodes = [node]
    }
}

// (internal) InternalParentedSelection represents the common properties and actions
// of a multiple selection
internal class InternalParentedSelection<ParentType, NodeType> {

    /// The parent object is where new objects are created.  This is
    // probably incorrect in the long run; new objects may be created
    // on cascading created objects.
    internal var parent:ParentType // TODO: should be readonly (really?)

    internal init(parent:ParentType) {
        self.parent = parent
    }
}

internal class InternalImperfectSelection<ParentType, NodeType> : InternalParentedSelection<ParentType, NodeType> {

    public var nodes: [NodeType]

    internal init(parent: ParentType, nodes: [NodeType]) {
        self.nodes = nodes

        super.init(parent: parent)
    }
}

// MARK: -

// MultiSelection deals with pre-joined state - SelectAlls.
// MultiSelection can be operated upon as basic selections, or converted
// into a JoinSelection
public class MultiSelection<ParentType, NodeType> : InternalImperfectSelection<ParentType, NodeType> {

    // Convenience Types
    public typealias NodeValueIndexToVoid = (NodeType?,Void,Int) -> ()
    public typealias NodeValueIndexToAny = (NodeType?,Void,Int) -> Any?
    public typealias NodeValueIndexToNode = (NodeType?,Void,Int) -> NodeType

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


}

// MARK: -

/// (internal) JoinedSelection includes the operations that are possible on a bound or pre-joined selection.
// access should be internal but there's a bug in swift : public typealias of a internal class is not visible by public children
public class InternalJoinedSelection<ParentType, NodeType, ValueType> : InternalParentedSelection<ParentType, NodeType> {

    // Convenience Types
    public typealias NodeValueIndexToVoid = (NodeType?,ValueType,Int) -> ()
    public typealias NodeValueIndexToAny = (NodeType?,ValueType,Int) -> Any?
    public typealias NodeValueIndexToNode = (NodeType?,ValueType,Int) -> NodeType

    internal typealias NodeValuePairType = NodeValuePair<NodeType, ValueType>

    // Properties
    internal var nodesValues:[NodeValuePairType]

    // TODO: return data - strip out missing results, perhaps? or return ValueType?
    fileprivate var data:[ValueType] { return [] } // this TYPE only makes sense for multiply selected things

    internal init(parent: ParentType, nodesValues:[NodeValuePairType]) {
        self.nodesValues = nodesValues
        super.init(parent: parent)
    }
}

// MARK: -

// PerfectSelection is a Node-Data join that has values for both sides
// (assuming someone hasn't futzed with the node graph or metadata)
// Child types: ExitSelection (WHAT?) and UpdateSelection
// mainly used as a hook for extensions - has no specific behaviour.
// could be internal but append2 currently visits it
public class PerfectSelection<ParentType, NodeType, ValueType> : InternalJoinedSelection<ParentType, NodeType, ValueType> {
}

// MARK: -

// Join Selection deals with data-bound node?s only
// This is a precursor to Enter, Exit and Update selections
// ultimately it's not really a selection at all, and should not be!
final public class JoinPreSelection<ParentType, NodeType, ValueType>
where ParentType : TreeNavigable, NodeType : NodeMetadata, ParentType.ChildType == NodeType  {

    // Convenience types
    private typealias NodeValuePairType = NodeValuePair<NodeType, ValueType>

    // Debug Properties

    // this is just to make unit tests work - i'm not sure having data like this is meaningful
    internal let debugNewData:[ValueType] // this TYPE only makes sense for multiply selected things

    // computed accessor to get managed nodes & data
    internal var debugNodes:[NodeType] {
        // the enter (before append) is empty by definition - just get update
        return updateSelection.nodes
    }

    // Properties

    // required for addition operation
    internal let parent:ParentType

    // update is the set of nodes that existed before AND after
    private let updateSelection:(pairs: [NodeValuePairType], nodes: [NodeType])

    /// Vector of (missing) Node / Data pairs for existing nodes
    private let enterValues: [ValueType]

    // for the exit selection
    private let exitNodes:[NodeType]

    // List of vague thoughts:
    // * Note that the selections need to act upon the original data and node objects, in place, even in the face of mutation of a different selection - ie the enterSelection needs to act upon the same nodes that selection acts upon (later)
    // * How can I maintain a stable index?  perhaps store it in the userData?
    // * is the enter index based upon the master selection order or the enter
    // * selection order?  Is the exit index stable?  I can't see how unless it's only local

    // unkeyed version of join init
    fileprivate init(parent:ParentType, nodes initialSelection:[NodeType], data boundData: [ValueType]) {

        debugNewData = boundData

        var updateNodes: [NodeType] = []
        var updatePairs: [NodeValuePairType] = []

        // count up how many nodes to preserve, how many to create and how many to destroy.
        // note that for simple indexed joins, we either create OR destroy, not both
        let boundCount = boundData.count
        let retainedCount = min(boundCount, initialSelection.count)

        updateNodes.reserveCapacity(retainedCount)
        updatePairs.reserveCapacity(boundData.count)

        // handle the Simple index case - where unique keys have not been supplied

        // grab the retained selection - those nodes we are going to keep that already exist

        for (var nodeToUpdate, valueToUpdateWith) in zip(initialSelection, boundData) {

            // may want to re-order these 3 statements, depending, when nodeToUpdate is immutable
            updateNodes.append(nodeToUpdate)

            updatePairs.append(.init(node: nodeToUpdate,
                                     value: valueToUpdateWith))

            // write the new metadata for the updated node only.
            // TODO: consider handling the old value somehow, too.
            // TODO: work out if we can extract this from here?
            nodeToUpdate.metadata = valueToUpdateWith
        }

        // grab the enter selection, which has no nodes yet
        let enterValues = boundData.dropFirst(initialSelection.count)

        // grab the exit selection
        let exitNodes = initialSelection.dropFirst(boundData.count)

        updateSelection = (pairs: updatePairs,
                           nodes: updateNodes)

        self.exitNodes = Array(exitNodes)

        self.enterValues = Array(enterValues)

        self.parent = parent
    }

    // keyed version of join init
    fileprivate init<KeyType:Hashable>(parent:ParentType, nodes initialSelection:[NodeType], data boundData: [ValueType], keyFunction:((ValueType,Int) -> KeyType)) {

        debugNewData = boundData

        var updateNodes: [NodeType] = []
        var updatePairs: [NodeValuePairType] = []
        var exitNodes: [NodeType] = []
        var enterValues: [ValueType] = []

        // count up how many nodes to preserve, how many to create and how many to destroy.
        // note that for simple indexed joins, we either create OR destroy, not both
        let retainedCount = min(boundData.count,initialSelection.count)

        updateNodes.reserveCapacity(retainedCount)
        updatePairs.reserveCapacity(boundData.count)
        exitNodes.reserveCapacity(max(0,initialSelection.count - boundData.count))
        enterValues.reserveCapacity(max(0,boundData.count - initialSelection.count))

        // handle the keyed case
        // incoming data must be bound to the correct nodes

        // the set of node keys that will be exited
        var boundDataDictionary: [KeyType:ValueType] = [:]
        var boundNodeDictionary: [KeyType:NodeType] = [:]

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
                updateNodes.append(node)

                updatePairs.append(NodeValuePairType(node: node,
                                                     value: updatedValue))

                node.metadata = updatedValue
            } else {
                exitNodes.append(node)

            }
        }

        // update the enter selection by searching for
        // unbound data keys in the nodes.  bind as appropriate
        for (key, updatedValue) in boundDataDictionary {
            if let _ = boundNodeDictionary[key] {

            } else {
                enterValues.append(updatedValue)
            }
        }

        updateSelection = (pairs:updatePairs,
                           nodes:updateNodes)

        self.exitNodes = exitNodes

        self.enterValues = enterValues

        self.parent = parent
    }

    // Enter returns the limited selection matching only missing nodes.
    // it is passed our nodeData object so new nodes are visible.
    // see also update - which extracts a concrete set of nodes at any time
    public func enter() -> EnterPreSelection<ParentType, ValueType> {
        return .init(parent: parent, data: enterValues)
    }

    // Update creates a new selection containing only valid node:value pairs
    // this needs clarifying (and unit testing - can update include enter or not?)
    public func update() -> UpdateSelection<ParentType, NodeType, ValueType> {
        return .init(parent: parent, nodesValues: updateSelection.pairs)
    }

    // Return the Exit selection
    // this should only be a method on initialSelection
    public func exit() -> ExitSelection<ParentType, NodeType, ValueType> {

        // let's take in on faith that exitnodes have values.  not necessarily true.
        // FIXME: metadata! is untenable here - exit might not have data value?
        // d is now !, not ?; so we don't check.  Perhaps we ONLY exit managed nodes (with metadata?)
        // that doesn't work if we expect to execute on arrays.  But it would work if we always work on
        // selections - even for reselection.
        let exitNodeData:[NodeValuePairType] = self.exitNodes.map { (node:NodeType) in
            NodeValuePairType(node: node, value: node.metadata as! ValueType)
        }

        return .init(parent: parent, nodesValues: exitNodeData)
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
where ParentType : TreeNavigable {

    public func merge(with enterSelection:AppendedSelection<ParentType, NodeType, ValueType>) -> UpdateSelection<ParentType, NodeType, ValueType> {

        let combinedNodeData = self.nodesValues + enterSelection.nodesValues

        return UpdateSelection<ParentType, NodeType, ValueType>(parent: self.parent, nodesValues: combinedNodeData)
    }

}

// Enter Pre Selection becomes a selection when append is run.
final public class EnterPreSelection<ParentType, ValueType>
where ParentType : TreeNavigable {

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
    where ParentType.ChildType == NewNodeType, NewNodeType : TreeNavigable & NodeMetadata {

        // Convenience types
        typealias NewNodeValuePairType = NodeValuePair<NewNodeType, ValueType>

        var newNodesValues:[NewNodeValuePairType] = []

        for (i, value) in data.enumerated() {

            var newNode = constructorFn(value, i)
            newNodesValues.append(NewNodeValuePairType(node: newNode, value: value))

            newNode.metadata = value

            parent.add(child:newNode)
        }

        return .init(parent: parent, nodesValues: newNodesValues)
    }
}

// MARK: -

// Exit Selection deals with exiting nodes only
// is it joined?... it's prejoined.  we can rejoin it?
// ExitSelection is not definitely a PerfectJoin - if the initial join is applied
// to an imperfect join.  We may be able to transmit this information, maybe not.
final public class ExitSelection<ParentType, NodeType, ValueType> : PerfectSelection<ParentType, NodeType, ValueType>
where ParentType : TreeNavigable, ParentType.ChildType == NodeType {

    /// Remove nodes from the document
    // unusually, this function doesn't chain - since the represented nodes are now dead
    public func remove() -> Void {
        for nodeValue in nodesValues {
            parent.remove(child: nodeValue.node!)
//            nodeValue.node = nil // hmm.
        }

        // should kill the selection when this is done.
    }
}

final public class AppendedSelection<ParentType, NodeType, ValueType> : PerfectSelection<ParentType, NodeType, ValueType>
where ParentType : TreeNavigable { }

// MARK: -

// extensions

#if true
    extension PerfectSelection where NodeType : NodeMetadata {

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
    where NewNodeType==NodeType.ChildType, NodeType : TreeNavigable, NewNodeType : NodeMetadata {

        // Convenience types
        typealias NewNodeValuePairType = NodeValuePair<NewNodeType, ValueType>

        var newNodes:[NewNodeType] = []
        var newNodesValues:[NewNodeValuePairType] = []

        for (i, oldNodesValues) in nodesValues.enumerated() {
            // MARK: WORKING FACE

            let oldNode = oldNodesValues.node!
            var newNode = constructorFn(oldNode, oldNodesValues.value, i)

            newNodesValues.append(.init(node: newNode,
                                        value: oldNodesValues.value))

            newNode.metadata = nodesValues[i].value

            newNodes.append(newNode)
            oldNode.add(child: newNode)
        }

        // It's too hard to fit parents into this model, so I'm just throwing up my hands.  There's no parent.
        return .init(parent: (), nodesValues: newNodesValues)

        //
    }
}
#endif
