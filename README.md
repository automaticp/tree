# Tree

is a tree data structure written in MATLAB. Interaction with the tree happens through the tree nodes - `TNode` objects. 

`TNode` contains three properties: `data` attached to the node, node's `parent` and node's `children`.

In its implementation, tree uses a reference array of nodes - `TList`, which both serves as the identity of the tree and trivializes traversal and searching through the whole tree.

Description of each of the `TNode`'s methods can be found in `TNode.m`.

# Quickstart

*Disclaimer: Quickstart guide is not meant to be a viewed as documentation. Refer to the descriptions found in `TNode.m` for full information on availiable methods, their arguments, output and guarantees.*

### Tree Creation

Create a single `TNode` with the specified data: 

```MATLAB
    my_data = struct('my_string', 'hello', 'my_value', 42);
    root_node = TNode(my_data);
```

Access the data attached to the node:

```MATLAB
    >> root_node.data
    
    ans = 
      struct with fields:

        my_string: 'hello'
         my_value: 42
```

Currently, our node has no children. We can attach existing `TNode` objects using `attach_child(existing_node)` or create new ones from data using `make_child(data)`.

```MATLAB
    my_node = TNode(); 
    root_node.attach_child(my_node);
    
    my_other_data = struct('my_string', 'yep', 'my_value', -1);
    root_node.make_child(my_other_data);
```

```MATLAB
    >> root_node
    
    root_node = 
      TNode with properties:

            data: [1×1 struct]
          parent: [0×0 TNode]
        children: [1×2 TNode]
```

We can add children to children using:
```MATLAB
    root_node.children(2).make_child(struct('my_string', 'nope', 'my_value', 0))
```
or `attach_child()` equivalently.

### Listing and Display

If we want to access the list of all nodes in the tree, irrespective of their hierarchy, we can use the `list()` method

```MATLAB
    >> root_node.list()
    
    ans = 
      1×4 TNode array with properties:

        data
        parent
        children  
```


In order to display the tree we can use `display_tree()` method, which will print the tree structure in console and highlight the node it was called from with angled brackets `<>`

```MATLAB
    >> root_node.display_tree()
    
    [0](1/1) <TNode>
        [1](1/2) TNode
        [1](2/2) TNode
            [2](1/1) TNode
```

Here square brackets `[]` delimit the depth of the hierarchy and parentesis `()` show the number of the child in `children` array as compared to the total number of children.

In order to access nested children in hierarchy, we can use `root_node.children(2).children(1)` or `root_node.descendant(2, 1)`:

```MATLAB 
    >> root_node.descendant(2, 1).display_tree()
    
    [0](1/1) TNode
        [1](1/2) TNode
        [1](2/2) TNode
            [2](1/1) <TNode>
```

`display_tree()` accepts one optional argument - a function which transforms data in each node to a string, which is then displayed for each node.

When we created one of the children - `my_node`, we called the `TNode` constructor with no arguments, which caused data to be set to an empty value `[]`. We can inspect which nodes contain empty data using `display_tree()`.

```MATLAB
    >> root_node.display_tree(@(data)( string(isempty(data)) ))

    [0](1/1) <false>
        [1](1/2) true
        [1](2/2) false
            [2](1/1) false            
```

Let's attach a struct with the same fields as others to this node 

```MATLAB
    root_node.descendant(1).data = struct('my_string', 'hey', 'my_value', 99);
```

We can then display contents of each struct using an anonymous function as before

```MATLAB
    >> root_node.display_tree(@(data)( string(data.my_string) + ", " + string(data.my_value) ))
    
    [0](1/1) <hello, 42>
        [1](1/2) hey, 99
        [1](2/2) yep, -1
            [2](1/1) nope, 0
```

### Search and Node Inspections

Searching through the tree can be done using the `find_if()` method which accepts a single argument - a function which accepts the node as its argument and returns a boolean indicating whether this node should be returned after search.

```MATLAB
    >> found_nodes = root_node.find_if(@(node)( node.data.my_value > 0 ))
    
    found_nodes = 
      1×2 TNode array with properties:

        data
        parent
        children        
```

A number of built-in inspections are availiable for arrays of nodes

```MATLAB
    >> found_nodes.depth()
    ans =
        0     1

    >> found_nodes.has_children() 
    ans =
      1×2 logical array
       1   0
```
and so on.

### Subtrees and `*_from_this` Methods

Some of the methods of the `TNode` class come with their counterparts whoose names end with `_from_this`. These methods operate on *subtrees* whoose root is assumed to be the node the methods were called from. 

For example, for a complex hierarchy

```MATLAB
    >> root_node.display_tree()
    
    [0](1/1) <TNode>
        [1](1/4) TNode
            [2](1/2) TNode
            [2](2/2) TNode
        [1](2/4) TNode
            [2](1/2) TNode
                [3](1/3) TNode
                [3](2/3) TNode
                [3](3/3) TNode
            [2](2/2) TNode
        [1](3/4) TNode
        [1](4/4) TNode
```
we can display the subtree at `root_node.children(2)` as:
```MATLAB
    >> root_node.children(2).display_from_this()
    
        [1](2/4) <TNode>
            [2](1/2) TNode
                [3](1/3) TNode
                [3](2/3) TNode
                [3](3/3) TNode
            [2](2/2) TNode
```