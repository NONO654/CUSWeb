/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.data = swv6.data || {};

(function () {
    /**
     * @class swv6.data.Tree
     * @extends swv6.util.Publisher
     * A tree data structure.
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.data.Tree =
        function (config) {
            config = config || {};
            
            CLASS.base.ctor.call(this, config);

            this.nodeCtor = config.nodeCtor || this.nodeCtor;

            /**
             * @event nodeAdded
             * Triggered when a node is added to this tree.
             * @param {swv6.data.Tree} this
             * @param {swv6.data.Node} parent The parent of the added node (or null if added node is the root).
             * @param {swv6.data.Node} child The added node.
             */
            this.addEvent('nodeAdded');

            /**
             * @event nodeRemoved
             * Triggered when a node is removed from this tree.
             * @param {swv6.data.Tree} this
             * @param {swv6.data.Node} parent The parent of the removed node (or null if removed node is the root).
             * @param {swv6.data.Node} child The removed node.
             */
            this.addEvent('nodeRemoved');

            /**
             * @event nodeMoved
             * Triggered when a node is moved within this tree.
             * @param {swv6.data.Tree} this
             * @param {swv6.data.Node} node The moved node.
             */
            this.addEvent('nodeMoved');

            /**
             * @event nodeUpdated
             * Triggered when a node in the tree is updated.
             * @param {swv6.data.Tree} this
             * @param {swv6.data.Node} child The updated node.
             */
            this.addEvent('nodeUpdated');
        };

    swv6.util.inherit(CLASS, BASE, {

        root: null,

        /**
         * Returns a node to be used with the passed config.
         * @protected
         * @param {String} config The config data for the node.
         * @return {swv6.data.Node} The node representation for the given config.
         */
        nodeCtor: function (config) {
            return new swv6.data.Node(config);
        },

        /**
         * Gets the root node of this tree.
         * @return {swv6.data.Node} The root node.
         */
        getRoot: function () {
            return this.root;
        },

        /**
         * Sets the root node of this tree.
         * @param {swv6.data.Node} root The node to use as root of this tree.
         */
        setRoot: function (root) {
            var canAdd = true,
                added = null;

            if (this.root) {
                this.clear();
            }

            if (!(root instanceof swv6.data.Node)) {
                root = this.createNode(root);
                canAdd = (root !== null);
            }

            if (canAdd) {
                this.root = root;
                root.setTree(this);
                root.setSiblingIndex(0);
                this.onNodeAdded(null, root);
                added = root;
            }

            return added;
        },

        /**
         * Clears all nodes from this tree.
         * @param {swv6.data.Node} root The node to use as root of this tree.
         */
        clear: function () {
            if (this.root) {
                this.root.setTree(null);
                this.root = null;
            }
        },

        // private
        createNode: function (config) {
            return this.nodeCtor(config);
        },

        /**
         * Performs the provided function on each node in the tree.
         * @param {Function} fn The function to apply to each node.
         */
        forEach: function (fn) {
            var ns = this.root ? [this.root] : [],
                n,
                i,
                count;

            while (ns.length !== 0) {
                n = ns.shift();
                fn(n);

                if (n.getChildrenLoaded()) {
                    count = n.getChildCount();
                    for (i = 0; i < count; i++) {
                        ns.push(n.getChild(i));
                    }
                }
            }
        },

        // private
        onNodeAdded: function (parent, child) {
            child.sub('childAdded', this, this.onNodeAdded);
            child.sub('childRemoved', this, this.onNodeRemoved);
            child.sub('moved', this, this.onNodeMoved);
            child.sub('updated', this, this.onNodeUpdated);

            this.publish('nodeAdded', this, parent, child);
        },

        // private
        onNodeRemoved: function (parent, child) {
            child.unsub('childAdded', this, this.onNodeAdded);
            child.unsub('childRemoved', this, this.onNodeRemoved);
            child.unsub('moved', this, this.onNodeMoved);
            child.unsub('updated', this, this.onNodeUpdated);

            this.publish('nodeRemoved', this, parent, child);
        },

        // private
        onNodeMoved: function (node) {
            this.publish('nodeMoved', this, node);
        },

        // private
        onNodeUpdated: function (node) {
            this.publish('nodeUpdated', this, node);
        },

        /**
         * TODO: Documentation
         */
        nodeFromIndexPath: function (path) {
            var i,
                node = this.root;

            for (i=0; i<path.length; i++) {
                node = node.getChild(path[i]);
            }
            
            return node;
        }

    });

}());

(function () {
    /**
     * @class swv6.data.Node
     * @extends swv6.util.Publisher
     * A node within a tree data structure.
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher,
        LASTNODEID = 0;

    CLASS =
        swv6.data.Node =
        function (config) {
            config = config || {};

            this.config = config;

            CLASS.base.ctor.call(this, config);

            this.data = config.data;
            this.generateId();

            this.children = [];

            /**
             * @event childAdded
             * Triggered when a child is added to this node.
             * @param {swv6.data.Node} this
             * @param {swv6.data.Node} child The added node.
             */
            this.addEvent('childAdded');

            /**
             * @event childRemoved
             * Triggered when a node is removed from this node.
             * @param {swv6.data.Node} this
             * @param {swv6.data.Node} child The removed node.
             */
            this.addEvent('childRemoved');

            /**
             * @event moved
             * Triggered when this node is moved.
             * @param {swv6.data.Node} this
             */
            this.addEvent('moved');

            /**
             * @event updated
             * Triggered when this node is updated.
             * @param {swv6.data.Node} this
             */
            this.addEvent('updated');

        };

    swv6.util.inherit(CLASS, BASE, {

        /**
         * @cfg {Object} data
         * Data to be contained in this node.
         */
        data: undefined,

        id: undefined,
        tree: null,
        children: undefined,
        parent: null,
        siblingIndex: undefined,

        childrenLoaded: true, // set to false if node needs to load children async

        /**
         * Retrieves flag indicating whether or not children have been loaded for this node.
         * @return {Boolean} The value of childrenLoaded.
         */
        getChildrenLoaded: function () {
            return this.childrenLoaded;
        },

        /**
         * Sets flag indicating whether or not children have been loaded for this node.
         * @param {Boolean} value The new value for childrenLoaded.
         */
        setChildrenLoaded: function (value) {
            this.childrenLoaded = value;
        },

        // private
        generateId: function () {
            // give each node a unique id.
            this.id = LASTNODEID++;
        },
        
        /**
         * Returns the tree containing this node.
         * @return {swv6.data.Tree} The containing tree.
         */
        getTree: function () {
            return this.tree;
        },

        // private
        // use swv6.data.Tree.setRoot() for the root, and swv6.data.Node.addChild for all further children.
        setTree: function (tree) {
            this.tree = tree;
        },

        /**
         * Returns the parent of this node.
         * @return {swv6.data.Node} The parent (or null if this node is a root node).
         */
        getParent: function () {
            return this.parent;
        },

        // private
        setParent: function (node, addToParent) {
            if (this.parent) {
                this.parent.removeChild(this);
            }
            this.parent = node;
            if (addToParent !== false) {
                node.addChild(this);
            }
        },

        /**
         * Returns the position of this node relative to its siblings.
         * @return {swv6.data.Node} The parent (or null if this node is a root node).
         */
        getSiblingIndex: function () {
            return this.siblingIndex;
        },

        // private
        setSiblingIndex: function (index) {
            this.siblingIndex = index;
        },

        /**
         * Sets the data contained in this node.
         * @param {Object} data The data to be contained in this node.
         */
        setData: function (data) {
            this.data = data;
        },

        /**
         * Retrieves the data contained in this node.
         * @return {Object} The data contained within this node.
         */
        getData: function () {
            return this.data;
        },

        /**
         * Returns the number of children under this node.
         * @return {Number} The child count
         */
        getChildCount: function () {
            if (!this.childrenLoaded) {
                throw('Error: children not loaded.');
            }
            return this.children.length;
        },

        
        /**
         * Returns the child at the given index.
         * @param {Number} index The index of the child that is to be retrieved.
         * @return {swv6.data.Node/undefined} The child node, or undefined if out-of-bounds.
         */
        getChild: function (index){
            if (!this.childrenLoaded) {
                throw('Error: children not loaded.');
            }
            return this.children[index];
        },

        /**
         * Adds the given child node to this node's list of children.
         * @param {swv6.data.Node} child The child node to add.
         * @return {swv6.data.Node} The added child node (or 'null' if addition failed).
         */
        addChild: function (child){
            var added = this.handleAddChild(child);

            if (added) {
                this.publish('childAdded', this, added);
            }

            return added;
        },

        // private
        handleAddChild: function (child, reference) {
            var canAdd = true,
                added = null,
                index = null,
                i;

            if (reference) {
                for (i=0; i<this.children.length; i++) {
                    if (this.children[i] === reference) {
                        index = i;
                        break;
                    }
                }
                if (index === null) {
                    canAdd = false;
                }
            }

            if (canAdd) {
                if (child instanceof swv6.data.Node) {
                    canAdd = !this.isChild(child);
                } else {
                    child = this.tree.createNode(child);
                    canAdd = (child !== null);
                }
            }

            if (canAdd) {
                child.setParent(this, false);
                child.setTree(this.tree);
                if (index === null) {
                    this.children.push(child);
                    child.setSiblingIndex(this.children.length-1);
                } else {
                    this.children.splice(index, 0, child);
                    child.setSiblingIndex(index);
                    for (i=index+1; i<this.children.length; i++) {
                        this.children[i].setSiblingIndex(i);
                    }
                }
                added = child;
            }

            return added;
        },

        /**
         * Inserts a child into this node's list of children before another specified reference node.
         * @param {swv6.data.Node} child The child node to add.
         * @param {swv6.data.Node} reference The child will be added before this node.
         * @return {swv6.data.Node} The added child node (or 'null' if addition failed).
         */
        insertChild: function (child, reference){
            var added = this.handleAddChild(child, reference);

            if (added) {
                this.publish('childAdded', this, added);
            }

            return added;
        },

        /**
         * Removes the given child node from this node's list of children.
         * @param {swv6.data.Node} node The child node to remove.
         * @return {swv6.data.Node} The removed child node (or 'null' if removal failed).
         */
        removeChild: function (node){
            var removed = this.handleRemoveChild(node);

            if (removed) {
                this.publish('childRemoved', this, removed);
            }

            return removed;
        },

        /**
         * Moves a child in this node's list of children before another specified reference node.
         * @param {swv6.data.Node} child The new parent for this node.  May be the same as current parent, or undefined, if 
         * only the node ordering is being changed.
         * @param {swv6.data.Node} reference The child will be moved before this node.
         * If undefined, node will be moved to the end of the child list.
         * @return {swv6.data.Node} The moved child node (or 'null' if move failed).
         */
        move: function (parent, reference) {
            var moved = this.handleMove(parent, reference);

            if (moved) {
                this.publish('moved', this);
            }

            return moved;
        },

        // private
        handleRemoveChild: function (node){
            var fn = function (n) { return n === node; },
                match = this.findChildIndexes(fn),
                removed = null,
                i;

            if (match.length !== 0) {
                node.parent = null;
                node.tree = null;
                this.children.splice(match[0], 1);
                removed = node;

                for (i=match[0]; i<this.children.length; i++) {
                    this.children[i].setSiblingIndex(i);
                }

            }

            return removed;
        },

        // private
        handleMove: function (parent, reference){
            var moved,
                find,
                fn = function (n) { return n === find; },
                match,
                ni, //node index
                ri,
                i; //reference index

            if (!parent || (parent === this.getParent())) {
                // moving within same parent.
                find = this;
                match = this.parent.findChildIndexes(fn);
                ni = (match.length !== 0) ? match[0] : null;
    
                if (reference) {
                    find = reference;
                    match = this.parent.findChildIndexes(fn);
                    ri = (match.length !== 0) ? match[0] : null;
                } else {
                    ri = null;
                }

                if (ni !== null) {
                    moved = this;
    
                    this.parent.children.splice(ni, 1);
                    if (ri !== null) {
                        if (ni < ri) {
                            ri--;
                        }
                        this.parent.children.splice(ri, 0, this);
                    } else {
                        this.parent.children.push(this);
                    }
    
                    // update indexes
                    for (i=0; i<this.parent.children.length; i++) {
                        this.parent.children[i].setSiblingIndex(i);
                    }
    
                }

            } else {
                // reparenting.

                moved = this;

                if (this.parent) {
                    this.parent.removeChild(this);
                }

                if (reference) {
                    parent.insertChild(this, reference);
                } else {
                    parent.addChild(this);
                }

            }

            return moved;
        },

        // private
        isChild: function (node) {
            var fn = function (n) { return n === node; },
                match = this.findChildIndexes(fn);

            return match.length !== 0;
        },

        // private
        findChildIndexes: function (fn) {
            var i, node, matches = [];

            for (i=0; i<this.children.length; i++) {
                node = this.children[i];
                if (fn(node) === true) {
                    matches.push(i);
                }
            }

            return matches;
        },

        /**
         * Searches this node and each of its descendants, returning nodes that satisfy a test function.
         * @param {Function} fn The test function to use on each node.  Returns true if match found.
         * @param {Boolean} [deep=true] True if search should extend to grandchildren and beyond, false otherwise.
         * @returns {swv6.data.Node[]} The nodes satisfying the test function.
         */
        find: function (fn, deep) {
            var matches = [],
                testFn;

            testFn = function (node) {
                if (fn(node)) {
                    matches.push(node);
                }
            };

            this.forEach(testFn, deep);

            return matches;
        },

        /**
         * Performs the provided function on this node, its direct children, and (optionally) each of its descendant nodes.
         * @param {Function} fn The function to apply to each node.  Returns false on failure, terminating further progress.
         * @param {Boolean} [deep=true] True if function should be applied to grandchildren and beyond, false otherwise.
         */
        forEach: function (fn, deep) {
            var ns = [].concat(this, this.children),
                n,
                i,
                count;

            if (deep === undefined) {
                deep = true;
            }

            while (ns.length !== 0) {
                n = ns.shift();
                if (fn(n) === false) {
                    // if the function returns false, stop.
                    break;
                }
                if (deep && (n !== this)) {
                    if (n.getChildrenLoaded()) {
                        count = n.getChildCount();
                        for (i = 0; i < count; i++) {
                            ns.push(n.getChild(i));
                        }
                    }
                }
            }
        },

        /**
         * TODO: Documentation
         */
        getIndexPath: function () {
            var parent = this.parent,
                child = this,
                path = [],
                i,
                count;

            while (parent !== null) {
                path.push(child.getSiblingIndex());
/*                
                count = parent.getChildCount();
                for (i = 0; i < count; i++) {
                    if (parent.getChild(i) === child) {
                        path.push(i);
                        break;
                    }
                }
*/
                child = parent;
                parent = parent.parent;
            }
            return path.reverse();
        },

        /**
         * Finds the next (or previous) node at the same level as the current node, even if it does not share the same parent.
         */
        getNeighbor: function (previous) {
            var si = this.getSiblingIndex(),
                p = this.getParent(),
                psi = p && p.getSiblingIndex(),
                n = null;

            if (p) {
                if (previous) {
                    if (si > 0) {
                        n = p.getChild(si-1);
                    } else {
    
                        while( ((p = p.getNeighbor(true)) !== null) && (p.getChildCount() === 0)) {
                            // do nothing.  while condition will find p.
                        }
    
                        if (p) {
                            n = p.getChild(p.getChildCount()-1);
                        }
                    }
                } else {
                    if (si <= p.getChildCount()-2) {
                        n = p.getChild(si+1);
                    } else {
    
                        while( ((p = p.getNeighbor()) !== null) && (p.getChildCount() === 0)) {
                            // do nothing.  while condition will find p.
                        }
    
                        if (p) {
                            n = p.getChild(0);
                        }
                    }
                }
            }

            return n;
        },
        
        /**
         * TODO: Documentation
         */
        clone: function () {
            // construct
            var i,
                clone = new this.ctor(),
                child;

            clone.setTree(this.getTree());

            for (i=0; i<this.getChildCount(); i++) {
                clone.addChild(this.getChild(i).clone());
            } 

            return clone;
        }

    });

}());
