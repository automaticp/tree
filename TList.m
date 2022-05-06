classdef TList < handle
	%TLIST Shared array of tree node references.
	properties (GetAccess = public, SetAccess = private)
		list (1,:) TNode = TNode.empty()
	end
	
	methods 
		function obj = TList(nodes)
			arguments
				nodes (1,:) TNode = TNode.empty()
			end
			obj.append_nodes(nodes);
		end
		
		function append_nodes(obj, nodes)
			arguments
				obj TList
				nodes (1,:) TNode
			end
			assert(~any(ismember(obj.list, nodes)), ...
				'TList alredy contains some of the specified nodes.');
			obj.list = [obj.list, nodes];
		end
		
		function remove_nodes(obj, nodes)
			arguments
				obj TList
				nodes (1,:) TNode
			end
			
			indecies = ismember(obj.list, nodes);
			assert(any(indecies), 'TList contains no specified nodes.');
			
			assert(sum(indecies) == length(nodes), ...
				'TList contains only some of the specified nodes.');
			
			obj.list(indecies) = [];
			
        end
        
        function insert_before(obj, this, inserted)
            arguments
                obj TList
                this (1,1) TNode
                inserted (1,:) TNode
            end
            pos = obj.pre_insert(this, inserted);
            obj.list = [obj.list(1:pos-1), inserted, obj.list(pos:end)];
        end
		
        function insert_after(obj, this, inserted)
            arguments
                obj TList
                this (1,1) TNode
                inserted (1,:) TNode
            end
            pos = obj.pre_insert(this, inserted);
            obj.list = [obj.list(1:pos), inserted, obj.list(pos+1:end)];
        end
    end
    
	methods (Access = protected)
        function pos = pre_insert(obj, this, inserted)
            % Validates insertion arguments and returns the position of 'this' node
            assert(numel(unique(inserted)) == numel(inserted), ...
                'Duplicate nodes in the inserted list.')
            
            assert(~any(ismember(obj.list, inserted)), ...
                'TList already contains some of the specified nodes.');
           
            index = obj.list == this; 
            assert(any(index), 'TList has no specified node to insert before/after.'); 
            
            pos = find(index);

        end
    end
end

