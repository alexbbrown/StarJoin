//
//  Selection.swift
//  StarJoinSelector
//
//  Created by alex on 19/08/2014.
//  Copyright (c) 2014 Alex B Brown. All rights reserved.
//

// Issues

// TODO:[new]
// Where's my state machine?
// handle node structures which are not shallow heirarchies
// handle data structures which are not arrays
// handle data structures which are non linear
// handle data structures which are generic collections
// look at adding rebind
// todo: add initialisers for other kinds of searching, and
// handle filters and partial selections and partial removals
// add a select method (which is also a subscript operator) for sub-selection of multi-selections
// todo: append2 for cases other than perfect selection
// am I actually using metadata any more?

// TODO:[old]
// Allow data function to be a dictionary, which is auto-keyed. Perhaps a common ancestor of Array, Dictionary

import Foundation

// NodeValuePair carries Node, Value pairs,
// even if Node is missing.  Note that live
// nodes keep a reference to their data, too
// is this just a convenience or is it critical?
// is this really a map?  or even a weak map?
public struct NodeValuePair<NodeType, ValueType> {
    var node:NodeType?
    var value:ValueType
}

/// Starting point : make the initial selection of the root node
public class StarJoin {
    public class func select<NodeType>(only node: NodeType) -> SingleSelection<NodeType> {
        return SingleSelection(node: node)
    }
}

/// SingleSelection selects a single node.
/// example: use StarJoin.select(only: rootNode) to construct a SingleSelection
/// Selections are a selection of a single node, although subclasses handle
/// Single Selections allow you to select children using `select(all:` which builds a new selection.
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

    public init(node:NodeType) {
        self.nodes = [node]
    }
}

/// (internal) InternalParentedSelection represents the common properties and actions of a selection with a parent
public class _InternalParentedSelection<ParentType> {

    /// The parent object is where new objects are created.  This is
    // probably incorrect in the long run; new objects may be created
    // on cascading created objects.
    final internal var parent: ParentType // TODO: should be readonly (really?)

    internal init(parent: ParentType) {
        self.parent = parent
    }
}

/// Imperfect selections only have nodes, but no data
public class _InternalImperfectSelection<ParentType, NodeType> : _InternalParentedSelection<ParentType> {

    final public var nodes: [NodeType]

    internal init(parent: ParentType, nodes: [NodeType]) {
        self.nodes = nodes

        super.init(parent: parent)
    }
}

/// MultiSelection is a selection of zero or more nodes, and is the result of a `Select(all:`
/// MultiSelection can be operated upon as basic selections, or combined with data using the function cluster `join` `enter` and `update`
public class MultiSelection<ParentType, NodeType> : _InternalImperfectSelection<ParentType, NodeType> {

    /// Combine each element of this selection with a data item
    /// Note: the selection can have more or fewer nodes than the supplied data
    /// @param keyFunction extracts a unique identity from a data value, allowing precise matching of new and existing data, allowing nodes to be smoothly animated in the presence of enter/append and exit/remove operations.
    /// @return a JoinPreSelection which provides the `enter/append`, `exit/remove` and `update/merge` selections
    public func join<ValueType,KeyType:Hashable>(_ data:[ValueType], keyFunction:(ValueType,Int) -> KeyType) -> JoinPreSelection<ParentType, NodeType, ValueType> {
        return .init(parent: self.parent,
                     nodes: self.nodes,
                     data: data,
                     keyFunction: keyFunction)
    }

    /// Combine each element of this selection with a data item
    /// Note: the selection can have more or fewer nodes than the supplied data
    /// @return a JoinPreSelection which provides the `enter/append`, `exit/remove` and `update/merge` selections
    public func join<ValueType>(_ data: [ValueType]) -> JoinPreSelection<ParentType, NodeType, ValueType> {
        return .init(parent: self.parent,
                     nodes: self.nodes,
                     data: data)
    }
}

/// (internal) JoinedSelection includes the operations that are possible on a bound or pre-joined selection.
// access should be internal but there's a bug in swift : public typealias of a internal class is not visible by public children
public class InternalJoinedSelection<ParentType, NodeType, ValueType> : _InternalParentedSelection<ParentType> {

    // Convenience Types
    public typealias NodeValueIndexToAny = (NodeType?,ValueType,Int) -> Any?

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

// PerfectSelection is a Node-Data join that has values for both sides
// (assuming someone hasn't futzed with the node graph or metadata)
// Child types: ExitSelection (WHAT?) and UpdateSelection
// mainly used as a hook for extensions - has no specific behaviour.
// could be internal but append2 currently visits it
public class PerfectSelection<ParentType, NodeType, ValueType> : InternalJoinedSelection<ParentType, NodeType, ValueType> {
}

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
        return updateNodesValues.compactMap { $0.node }
    }

    // Properties

    // required for addition operation
    internal let parent:ParentType

    // update is the set of nodes that existed before AND after
    private let updateNodesValues:[NodeValuePairType]

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

        var updateNodesValues: [NodeValuePairType] = []

        updateNodesValues.reserveCapacity(boundData.count)

        // handle the Simple index case - where unique keys have not been supplied

        // grab the retained selection - those nodes we are going to keep that already exist

        for (var nodeToUpdate, valueToUpdateWith) in zip(initialSelection, boundData) {

            // may want to re-order these 3 statements, depending, when nodeToUpdate is immutable
            updateNodesValues.append(.init(node: nodeToUpdate,
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

        self.exitNodes = Array(exitNodes)

        self.enterValues = Array(enterValues)

        self.updateNodesValues = updateNodesValues

        self.parent = parent
    }

    // keyed version of join init
    fileprivate init<KeyType:Hashable>(parent:ParentType, nodes initialSelection:[NodeType], data boundData: [ValueType], keyFunction:((ValueType,Int) -> KeyType)) {

        debugNewData = boundData

        var updateNodesValues: [NodeValuePairType] = []
        var exitNodes: [NodeType] = []
        var enterValues: [ValueType] = []

        updateNodesValues.reserveCapacity(boundData.count)
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
                updateNodesValues.append(NodeValuePairType(node: node,
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

        self.exitNodes = exitNodes

        self.enterValues = enterValues

        self.updateNodesValues = updateNodesValues

        self.parent = parent
    }

    // Enter returns the limited selection matching only missing nodes.
    // it is passed our nodeValue object so new nodes are visible.
    // see also update - which extracts a concrete set of nodes at any time
    public func enter() -> EnterPreSelection<ParentType, ValueType> {
        return .init(parent: parent, data: enterValues)
    }

    // Update creates a new selection containing only valid node:value pairs
    // this needs clarifying (and unit testing - can update include enter or not?)
    public func update() -> UpdateSelection<ParentType, NodeType, ValueType> {
        return .init(parent: parent, nodesValues: updateNodesValues)
    }

    // Return the Exit selection
    // this should only be a method on initialSelection
    public func exit() -> ExitSelection<ParentType, NodeType, ValueType> {

        // let's take in on faith that exitnodes have values.  not necessarily true.
        // FIXME: metadata! is untenable here - exit might not have data value?
        // d is now !, not ?; so we don't check.  Perhaps we ONLY exit managed nodes (with metadata?)
        // that doesn't work if we expect to execute on arrays.  But it would work if we always work on
        // selections - even for reselection.
        let exitNodesValues:[NodeValuePairType] = self.exitNodes.map { (node:NodeType) in
            NodeValuePairType(node: node, value: node.metadata as! ValueType)
        }

        return .init(parent: parent, nodesValues: exitNodesValues)
    }

}

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

        let combinedNodesValues = self.nodesValues + enterSelection.nodesValues

        return UpdateSelection<ParentType, NodeType, ValueType>(parent: self.parent, nodesValues: combinedNodesValues)
    }

}

// Enter Pre Selection becomes a selection when append is run.
final public class EnterPreSelection<ParentType, ValueType>
where ParentType : TreeNavigable {

    // Properties
    private var data:[ValueType]
    internal var parent:ParentType

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

// MARK Append2 Extension

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
