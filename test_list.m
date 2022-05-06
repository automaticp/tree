function node = test_list(max_children, max_depth, current_depth)
    arguments
        max_children = 4;
        max_depth = 4;
        current_depth = 0;
    end
    
    node = TNode();
    
    if current_depth >= max_depth
       return 
    end
    
    num_children = randi([0, max_children]);
    for i = 1:num_children
        node.attach_child(test_list(max_children, max_depth, current_depth + 1));
    end
    
end
