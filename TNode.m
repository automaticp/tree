classdef TNode < handle
	properties
		data = []
	end
	properties (SetAccess = private, GetAccess = public)
		parent			TNode {mustBeScalarOrEmpty} = TNode.empty() 
		children (1,:)	TNode = TNode.empty() 
	end
	properties (Access = private)
		ref_list (1,1)	TList
	end
	
	methods
		function obj = TNode(data)
			arguments
				data = []
			end
			obj.data = data;
			obj.ref_list = TList();
			obj.ref_list.add_nodes(obj);
		end
		
		% Child Attaching and Creation
		
		function obj = attach_child(obj, child)
			% Attaches existing TNode object to this node as a child.
			arguments
				obj	TNode
				child (1,1) TNode
			end
			
			assert(~obj.is_same_tree_as(child), ...
				'Tree already contains specified TNode instance.');
			
			assert(~child.has_parent(), ...
				'Specified TNode is not a root node. Detach it from parent first.');
			
			child.parent = obj;
			obj.children(end + 1) = child;
			
			obj.ref_list.add_nodes(child.ref_list.list); 
			for node = child.ref_list.list
				node.ref_list = obj.ref_list;
			end
		end
		
		function obj = make_child(obj, data)
			% Creates a new child TNode object with the specified data.
			arguments
				obj TNode
				data = []
			end
			new_child = TNode(data);
			obj.attach_child(new_child);
		end
		
		% Child Detaching
		
		function [obj, child] = detach_child(obj, child)
			% Detaches specified child node from this node.
			%	Creates a new tree with the detached node as its root.
			%	Returns this node and the detached node.
			arguments
				obj TNode
				child TNode
			end
			
			assert(child.parent == obj,	'TNode contains no specified child.');
			
			obj.children(obj.children == child) = [];
			child.parent = TNode.empty();
			
			detached_nodes = child.list_from_this();
			obj.ref_list.remove_nodes(detached_nodes); 
			
			new_list = TList(detached_nodes);
			for node = detached_nodes
				node.ref_list = new_list;
			end
			
		end
		
		function [obj, parent] = detach_from_parent(obj)
			% Detaches this node from its parent.
			%	Creates a new tree with the detached node as its root.
			%	Returns detached node and its ex-parent node.
			assert(obj.has_parent(), ... 
				'This TNode instance has no parent to detach from.');
			parent = obj.parent.detach_child(obj);			
		end

		% Node Relationships
		
		function root_node = root(obj)
			% Returns the root node of the tree.
			arguments
				obj (1,1) TNode
			end
			
			this = obj;
			while this.has_parent
				this = this.parent;
			end
			root_node = this;
		end
		
		function bool = is_descendant_of(obj, other)
			% Checks whether this node is a descendant of the specified node.
			bool = false;
			this = obj;
			while this.has_parent
				this = this.parent; % obj skips itself.
				if this == other
					bool = true;
					return
				end
			end
		end
		
		function bool = is_ancestor_of(obj, other)
			% Checks whether this node is an ancestor of the specified node.
			bool = is_descendant_of(other, obj);
		end
		
		% Node Inspections
		
		function bool = has_parent(obj)
			bool = ~cellfun(@isempty, {obj.parent});
		end
		
		function bool = has_children(obj)
			bool = ~cellfun(@isempty, {obj.children});
		end
		
		function n = depth(obj)
			% Returns the distance from this node to the root node. Zero-based.
			n = arrayfun(@depth_scalar, obj);
		end
		
		function bool = is_same_tree_as(obj, node)
			% Checks whether this node belongs to the same tree as the other node.
			bool = obj.ref_list == node.ref_list;
		end
		
		% Search and Traversal
		
		function nodes = find_if(obj, predicate)
			% Finds nodes of the tree that satisfy the predicate.
			%	Searches through the whole tree 
			%	and returns an array of nodes for which predicate(node) == true.
			nodes = obj.ref_list.list(arrayfun(predicate, obj.list()));
		end
		
		function nodes = find_if_from_this(obj, predicate)
			% Finds nodes of a subtree that satisfy the predicate.
			%	Searches through a subtree starting at the current node (including it) 
			%	and returns an array of nodes for which predicate(node) == true.
			arguments
				obj TNode
				predicate function_handle
			end
			
			if predicate(obj)
				nodes = obj;
			else
				nodes = TNode.empty();
			end
			
			if ~obj.has_children()
				return
			end
			
			for child = obj.children
				nodes = [nodes, child.find_if_from_this(predicate)];
			end
		end
		
		% Listing
		
		function tree_list = list(obj)
			% Lists all nodes in a tree.
			%	Returns an array of all nodes in current tree structure.
			%	Time complexity: Constant.
			tree_list = obj.ref_list.list;
		end
		
		function nodes = list_from_this(obj)
			% Lists all nodes of a subtree starting from this node.
			%	Returns an array of all nodes in a subtree.
			%	Time complexity: O(n), where n - number of elements in the subtree.
			%	
			%	Use find_if_from_this() to search for elements in a subtree directly.
			nodes = find_if_from_this(obj, @(~)( true ));
		end
		
	end
	
	methods (Access = private)		
		function n = depth_scalar(obj)
			n = 0;
			this = obj;
			while this.has_parent
				this = this.parent;
				n = n + 1;
			end
		end
	end
	
end

