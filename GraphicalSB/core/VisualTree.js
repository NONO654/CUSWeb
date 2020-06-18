/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ui = swv6.ui || {};

(function () {
    /**
     * @class swv6.ui.VisualTree
     * @extends swv6.data.Tree
     * A visual representation of a data tree.
     */
    'use strict';
    var CLASS,
        BASE = swv6.data.Tree;

    CLASS =
        swv6.ui.VisualTree =
        function (config) {

            config = config || {};

            CLASS.base.ctor.call(this, config);

            this.visualConnectorCtor = config.visualConnectorCtor || this.visualConnectorCtor;

            /**
             * @event sizeChanged
             * Triggered when the dimensions of the tree change.
             * @param {swv6.ui.VisualTree} this
             * @param {Number} width The new width of the tree.
             * @param {Number} height The new height of the tree.
             */
            this.addEvent('sizeChanged');

            /**
             * @event originChanged
             * Triggered when the origins of the tree change.
             * @param {swv6.ui.VisualTree} this
             * @param {Number} x The new x origin of the tree.
             * @param {Number} y The new y origin of the tree.
             */
            this.addEvent('originChanged');

            /**
             * @event isolatedChanged
             * Triggered when the isolated node of the tree changes.
             * @param {swv6.ui.VisualTree} this
             */
            this.addEvent('isolatedChanged');

            this.setLayout(config.layout);

            this.selected = [];

            this.el = new swv6.html.Div({
                parent: config.parent,
                cls: 'tree'
            });

        };

    swv6.util.inherit(CLASS, BASE, {

        /**
         * @cfg {swv6.ui.VisualLayout} layout
         * The VisualLayout that will manage the positioning of the tree's nodes.
         */
        layout: undefined,
        /**
         * @cfg {Function} visualConnectorCtor
         * A function that will return a swv6.ui.VisualConnector.  Function expects an object
         * containing parent and child members.
         */
        visualConnectorCtor: function (config) {
            return new swv6.ui.VisualConnection(config);
        },

        width: 0,
        height: 0,
        x: 0,
        y: 0,

        selected: null,
        isolated: null,

        /**
         * Sets the VisualLayout that will manage the positioning of the tree's nodes.
         * @param {swv6.ui.VisualLayout} layout The VisualLayout.
         */
        setLayout: function (layout) {
            if (this.layout) {
                this.layout.unsub('layoutChanged', this, this.handleLayoutChanged);
            }

            this.layout = layout;
            if (this.layout) {
                this.layout.setTree(this);
                this.layout.sub('layoutChanged', this, this.handleLayoutChanged);
            }
        },

        /**
         * Gets the VisualLayout that will manage the positioning of the tree's nodes.
         * @return {swv6.ui.VisualLayout} The VisualLayout.
         */
        getLayout: function () {
            return this.layout;
        },

        /**
         * @inheritdoc 
         */
        nodeCtor: function (config) {
            return new swv6.ui.VisualNode(config);
        },

        // private
        createVisualConnector: function (config) {
            return this.visualConnectorCtor(config);
        },

        /**
         * Gets the x origin of this tree.
         * @return {Number} The x origin.
         */
        getX: function () {
            return this.isolated ? this.isolated.getSubtreeX() : this.root.getSubtreeX();
        },

        /**
         * Gets the y origin of this tree.
         * @return {Number} The y origin.
         */
        getY: function () {
            return this.isolated ? this.isolated.getSubtreeY() : this.root.getSubtreeY();
        },

        /**
         * Gets the width of this tree.
         * @return {Number} The width.
         */
        getWidth: function () {
            return this.isolated ? this.isolated.getSubtreeWidth() : this.root.getSubtreeWidth();
        },

        /**
         * Gets the height of this tree.
         * @return {Number} The height.
         */
        getHeight: function () {
            return this.isolated ? this.isolated.getSubtreeHeight() : this.root.getSubtreeHeight();
        },

        handleLayoutChanged: function () {
            var update = function (node) { 
                var i, child,
                    L, R, T, B,
                    l, r, t, b;

                // initialize extents
                L = node.getX();
                R = L + node.getWidth();
                T = node.getY();
                B = T + node.getHeight();

                for (i=0; i<node.getChildCount(); i++) {
                    child = node.getChild(i);
                    update(child);
                    
                    l = child.getSubtreeX();
                    r = l + child.getSubtreeWidth();
                    t = child.getSubtreeY();
                    b = t + child.getSubtreeHeight();
    
                    if (L > l) {
                        L = l;
                    }
                    if (R < r) {
                        R = r;
                    }
                    if (T > t) {
                        T = t;
                    }
                    if (B < b) {
                        B = b;
                    }

                }

                node.setSubtreeOrigin(L, T);
                node.setSubtreeSize(R-L, B-T);
            };

            update(this.root);
        },

        /**
         * Returns the child nodes of this tree contained inside the provided bounding rectangle.
         * @param {Number} x The x coordinate of the bounding rectangle.
         * @param {Number} y The y coordinate of the bounding rectangle.
         * @param {Number} width The width of the bounding rectangle.
         * @param {Number} height The height of the bounding rectangle.
         */
        findInside: function (x, y, width, height) {
            var found = [],
                right = x + width,
                bottom = y + height;

            this.forEach(function (node) {
                if ((node.getX() > x) &&
                        (node.getY() > y) &&
                        (node.getX() + node.getWidth() < right) &&
                        (node.getY() + node.getHeight() < bottom)) {
                    found.push(node);
                }
            });
            return found;
        },

        /**
         * TODO: Documentation
         */
        saveState: function () {
            var state;

            if (this.root) {
                state = this.root.saveState();
            }

            if (this.isolated) {
                state.isolated = this.isolated.getIndexPath();
            }

            return state;
        },

        /**
         * TODO: Documentation
         */
        loadState: function (state) {
            var r,
                isolated = null;

            if (this.root) {
                r = this.root.loadState(state);
            }

            if (state.isolated) {
                isolated = this.nodeFromIndexPath(state.isolated);
            }
            this.setIsolated(isolated);

            return r;
        },

        /**
         * TODO: Documentation
         */
        setSelected: function (nodes) {
            var i;
            
            for (i=0; i<this.selected.length; i++) {
                this.selected[i].g.removeClass('selected');
            }

            this.selected = nodes;

            for (i=0; i<this.selected.length; i++) {
                this.selected[i].g.addClass('selected');
            }
        },

        /**
         * TODO: Documentation
         */
        getSelected: function () {
            return this.selected;
        },

        /**
         * TODO: Documentation
         */
        setIsolated: function (node) {
            var l, r, t, b,
                L, R, T, B,
                root = node ? node : this.getRoot();

            this.isolated = node;

            this.publish('isolatedChanged', this);
        },

        /**
         * TODO: Documentation
         */
        getIsolated: function () {
            return this.isolated;
        },

        setSearchActive: function (value) {
            this.el[!value ? 'removeClass' : 'addClass']('search-active');
        },

        /**
         * TODO: Documentation
         */
        search: function (term, searchFn) {
            var results = [],
//                regex,
                data,
                nodeMap = {},
                nodeArray = [],
                testFn,
                root;

            if (term) {

                root = this.isolated || this.root;

                this.searchString = term;

//                regex = this.parseSearchString(term);

                // build node list and mark all nodes as collapsed.
                root.forEach(
                    function (node) {
                        var parent = node.getParent();

                        data = {
                            node: node,
                            expanded: false,
                            parent: parent ? nodeMap[parent.id] : null
                        };

                        nodeMap[node.id] = data;
                        nodeArray.push(data);
                    },
                    true /*deep*/
                );

                // determine which nodes need to be expanded.
                nodeArray.forEach(
                    function (data) {
                        var node = data.node,                            
                            parent;

                        if (searchFn(term, node)) {
                            results.push(node);

                            parent = data.parent;
                            while (parent && !parent.expanded) {
                                parent.expanded = true;
                                parent = parent.parent;
                            }
                        }

                    }
                );

                // update the expanded/collapsed state of each node.
                nodeArray.forEach(
                    function (data) {
                        var node = data.node,
                            expanded = data.expanded;

                        if (node.getExpanded() !== expanded) {
                            node.setExpanded(expanded, false);
                        }
                    }
                );

                this.markSearchResults(results);
            } else {
                this.markSearchResults(null);
            }


            return results;
        },

        /**
         * TODO: Documentation
         */
        clearSearchResults: function () {
            // remove 'search-result' class from tree nodes.
            this.setSearchActive(false);

            this.root.forEach(
                function (node) {
                    var parentCxn = node.getParentCxn();
                    if (parentCxn) {
                        parentCxn.setSearchPath(false);
                    }

                    node.setSearchPath(false);
                    node.setSearchResult(false);
                },
                true /*deep*/
            );

        },

        /**
         * TODO: Documentation
         */
        // pass in 'null' to clear results.
        markSearchResults: function (nodes) {
            var clearFn,
                parent,
                parentCxn;

            this.clearSearchResults();

            if (nodes !== null) {
                this.setSearchActive(true);

                nodes.forEach(function (node) {
    
                    node.setSearchResult(true);
    
                    // expand this node's ancestors.
                    parentCxn = node.getParentCxn();
                    parent = node.getParent();
                    while (parent) {
                        if (parentCxn) {
                            parentCxn.setSearchPath(true);
                        }

                        parent.setSearchPath(true);
                        parentCxn = parent.getParentCxn();
                        parent = parent.getParent();
                    }
                });
            }
        }

    });

}());

(function () {
    /**
     * @class swv6.ui.VisualNode
     * @extends swv6.data.Node
     * A visual representation of a data node.
     */
    'use strict';
    var CLASS,
        BASE = swv6.data.Node;

    CLASS =
        swv6.ui.VisualNode =
        function (config) {
            config = config || {};

            CLASS.base.ctor.call(this, config);

            this.cxns = [];

            this.collapsedCount = this.getExpanded() ? 0 : 1;

            /**
             * @event positionChanged
             * Triggered when the position of the node changes.
             * @param {swv6.ui.VisualNode} this
             * @param {Number} x The new x position of the node.
             * @param {Number} y The new y position of the node
             */
            this.addEvent('positionChanged');

            /**
             * @event sizeChanged
             * Triggered when the dimensions of the node change.
             * @param {swv6.ui.VisualNode} this
             * @param {Number} width The new width of the node.
             * @param {Number} height The new height of the node.
             */
            this.addEvent('sizeChanged');

            /**
             * @event expandedChanged
             * Triggered when the node is expanded or collapsed.
             * @param {swv6.ui.VisualNode} this
             * @param {Boolean} value True if the node is now expanded, false otherwise.
             */
            this.addEvent('expandedChanged');

            /**
             * @event expandedChanged
             * Triggered when the node is expanded or collapsed.
             * @param {swv6.ui.VisualNode} this
             * @param {Boolean} value True if the node is now expanded, false otherwise.
             */
            this.addEvent('visibilityChanged');

            /**
             * @event collapsedCountChanged
             * Triggered when the number of collapsed children is changed.
             * @param {swv6.ui.VisualNode} this
             * @param {Number} value The number of collapsed children.
             */
            this.addEvent('collapsedCountChanged');


            this.childrenNode = 
                new swv6.svg.G({
                    attr: {
                        'class': 'children'
                    }
                });

            this.g = new swv6.svg.G({
                attr: {
                    'class': 'expanded ' + (config.cls || '')
//                    'style': "filter:url(\'#dropshadow\')" TODO:add dropshadow filter back in.
                },
                children: [ this.childrenNode ]
            });

        };

    swv6.util.inherit(CLASS, BASE, {

        x: 0,
        y: 0,
        relX: 0,
        relY: 0,
        width: 1,
        height: 1,
        subtreeX: 0,
        subtreeY: 0,
        subtreeWidth: 0,
        subtreeHeight: 0,
        cxns: undefined,
        parentCxn: null,
        expanded: true,
        expanding: false,
        collapsedCount: 0,

        visible: true,

        /**
         * @cfg {Boolean} layoutChildren
         * Set to false if to prevent the layout manager from layout out this node's children.
         */
        layoutChildren: true,


        /**
         * @cfg {Boolean} noConnectors
         * Set to true to prevent the creation of connectors between this node and its children.
         */
        noConnectors: false,

        // override
        handleAddChild: function (child, reference) {
            var added = CLASS.base.handleAddChild.apply(this, arguments),
                cxn;

            if (added !== null) {
                if (!this.noConnectors) {
                    cxn = new this.tree.visualConnectorCtor({
                        parent: this, 
                        child: added
                    });
                    this.cxns.push(cxn);
                    added.parentCxn = cxn;
                }

                this.updateCollapsedCount(this.collapsedCount + added.collapsedCount);
                added.sub('collapsedCountChanged', this, this.onChildCollapsedCountChanged);
if (!this.getExpanded()) {
    added.setVisible(false);
}


            }
            return added;
        },

        // override
        handleRemoveChild: function (node){
            var removed = CLASS.base.handleRemoveChild.call(this, node),
                index;

            if (removed) {
                if (!this.noConnectors) {
                    if (node.parentCxn && this.cxns) {
                        index = this.cxns.indexOf(node.parentCxn);
                        if (index !== -1) {
                            this.cxns.splice(index, 1);
                        }
                    }
                    node.parentCxn = undefined;
                }

                this.updateCollapsedCount(this.collapsedCount - removed.collapsedCount);
                removed.unsub('collapsedCountChanged', this, this.onChildCollapsedCountChanged);
            }

            return node;
        },

        /**
         * Gets the x position of this node.
         * @return {Number} The x coordinate.
         */
        getX: function () {
            if (!this.x) {
                this.x = (this.parent ? this.parent.getX() : 0) + this.relX;
            }
            return this.x;
        },

        /**
         * Gets the y position of this node.
         * @return {Number} The y coordinate.
         */
        getY: function () {
            if (!this.y) {
                this.y = (this.parent ? this.parent.getY() : 0) + this.relY;
            }
            return this.y;
        },

        /**
         * Gets the x position of this node relative to its parent.
         * @return {Number} The x coordinate.
         */
        getRelX: function () {
            return this.relX;
        },

        /**
         * Gets the y position of this node relative to its parent.
         * @return {Number} The y coordinate.
         */
        getRelY: function () {
            return this.relY;
        },

        /**
         * Gets the width of this node.
         * @return {Number} The width.
         */
        getWidth: function () {
            return this.width;
        },
        
        /**
         * Gets the height of this node.
         * @return {Number} The height.
         */
        getHeight: function () {
            return this.height;
        },

        /**
         * Sets the position of this node.
         * @protected
         * @param {Number} x The x coordinate.
         * @param {Number} y The y coordinate.
         */
        setPosition: function (x, y) {

            if ((this.getX() !== x) || (this.getY() !== y)) {
                this.x = x;
                this.y = y;

                this.relX = x - (this.parent ? this.parent.getX() : 0);
                this.relY = y - (this.parent ? this.parent.getY() : 0);

                this.publish('positionChanged', this, x, y);
                this.forEach(function (node) { delete node.x; delete node.y; });
            }
        },

        /**
         * Sets the position of this node relative to its parent.
         * @protected
         * @param {Number} x The x coordinate.
         * @param {Number} y The y coordinate.
         */
        setRelPosition: function (x, y) {
            if ((this.getRelX() !== x) || (this.getRelY() !== y)) {
                this.relX = x;
                this.relY = y;
                delete this.x;
                delete this.y;

                this.publish('positionChanged', this, this.getX(), this.getY());
                this.forEach(function (node) { delete node.x; delete node.y; });
            }
        },
        
        /**
         * Sets the size of this node.
         * @protected
         * @param {Number} width The width of the node.
         * @param {Number} height The width of the node.
         */
        setSize: function (width, height) {
            if ((this.width !== width) || (this.height !== height)) {
                this.width = width;
                this.height = height;
                this.publish('sizeChanged', this, width, height);
            }
        },

        /**
         * TODO: Documentation
         */
        getSubtreeX: function () {
            return this.subtreeX;
        },

        /**
         * TODO: Documentation
         */
        getSubtreeWidth: function () {
            return this.subtreeWidth;
        },

        /**
         * TODO: Documentation
         */
        getSubtreeY: function () {
            return this.subtreeY;
        },

        /**
         * TODO: Documentation
         */
        getSubtreeHeight: function () {
            return this.subtreeHeight;
        },

        /**
         * TODO: Documentation
         */
        setSubtreeOrigin: function (x, y) {
            if ((this.subtreeX !== x) || (this.subtreeY !== y)) {
                this.subtreeX = x;
                this.subtreeY = y;
//                this.publish('originChanged', this, x, y);
            }
        },

        /**
         * TODO: Documentation
         */
        setSubtreeSize: function (width, height) {
            if ((this.subtreeWidth !== width) || (this.subtreeHeight !== height)) {
                this.subtreeWidth = width;
                this.subtreeHeight = height;
//                this.publish('sizeChanged', this, width, height);
            }
        },

        /**
         * Gets the connection between this node and its parent.
         * @return {swv6.ui.VisualConnection} The connection.
         */
        getParentCxn: function () {
            return this.parentCxn;
        },

        /**
         * Gets the connections between this node and its children.
         * @return {swv6.ui.VisualConnection[]} The connections.
         */
        getChildCxns: function () {
            return this.cxns;
        },

        /**
         * TODO: Documentation
         */
        canExpand: function () {
            return (!this.getExpanded() && !this.getExpanding());
        },

        /**
         * TODO: Documentation
         */
        canCollapse: function () {
            return (this.getExpanded() && !this.getExpanding());
        },

        /**
         * TODO: Documentation
         */
        canExpandAll: function () {
            var layout = this.tree.getLayout();

            return (this.hasGrandChildren() && (this.collapsedCount !== 0) && !this.getExpanding());
        },

        // private
        onChildCollapsedCountChanged: function (node, count, change) {
            this.updateCollapsedCount(this.collapsedCount + change);
        },

        // private
        onCollapsedCountChanged: function (count, change) {
            this.publish('collapsedCountChanged', this, count, change);
        },

        // private
        updateCollapsedCount: function (count) {
            var change = count - this.collapsedCount; 
            if (change !== 0) {
                this.collapsedCount = count;

                this.onCollapsedCountChanged(count, change);
            }
        },

        /**
         * Gets the expanded state of this node.
         * @return {Boolean} The expanded state.
         */
        getExpanded: function () {
            return this.expanded;
        },

        /**
         * Sets the expanded state of this node.
         * @param {Boolean} value The expanded state.
         * @param {Boolean} deep True to set this state for all children, false otherwise.
         */
        setExpanded: function (value, deep) {
            var same = (value === this.getExpanded());

            this.expanded = value;
            this.publish('expandedChanged', this, value);

            if (deep) {
                this.forEach(function (node) {
                    node.setExpanded(value, false);
                },
                true);
            }

            if (!same) {
                this.updateCollapsedCount(this.collapsedCount + (value ? -1 : 1));
            }

        },

        /**
         * Gets the expanding state of this node.  Useful for async operations.
         * @return {Boolean} The expanded state.
         */
        getExpanding: function () {
            return this.expanding;
        },

        /**
         * Sets the expanding state of this node.  Useful for async operations.
         * @param {Boolean} value The expanded state.
         */
        setExpanding: function (value) {
            this.expanding = value;
        },

        /**
         * Gets the visible state of this node.
         * @return {Boolean} value The visible state.
         */
        getVisible: function () {
            return this.visible;
        },

        /**
         * Sets the visible state of this node.
         * @param {Boolean} value The visible state.
         * @param {Boolean} [deep=false] True if visibility should be applied to children and beyond, false otherwise.
         */
        setVisible: function (value, deep) {

            if (deep === undefined) {
                deep = false;
            }

            if (deep) {
                this.forEach(function (node) {
                    node.setVisible(value, false);
                },
                true);
            } else {
                if (this.visible !== value) {
                    this.visible = value;
    
                    this.publish('visibilityChanged', this, value);

                    this.handleSetVisible(value);
                }
            }
        },

        // private
        handleSetVisible: function (value) {
        },

        /**
         * Determine if this node has grandchildren.
         * @param {Boolean} value True if grandchildren exist, false otherwise.
         */
        hasGrandChildren: function () {
            var isGrandParent = false;
            this.forEach(function (node) {
                isGrandParent = isGrandParent || ((node.getChildrenLoaded()) && (node.getChildCount() !== 0));
                return !isGrandParent;
            });
            return isGrandParent;
        },

        /**
         * TODO: Documentation
         */
        saveState: function () {
            var that = this,
                state = {
                    expanded: this.expanded,
                    visible: this.visible,
                    cn: []
                },
                cn = state.cn;

            this.forEach(
                function (node) {
                    if (node !== that) {
                        cn.push(node.saveState());
                    }
                },
                false
            );

            return state;
        },

        /**
         * TODO: Documentation
         */
        loadState: function (state) {
            var i,
                cn = state.cn;

            this.setExpanded(state.expanded);
            if (state.visible === true) {
                this.setVisible(state.visible);
            }

            for (i=0; i<cn.length; i++) {
                this.children[i].loadState(cn[i]);
            }
        },

        setSearchPath: function (value) {
            
        },

        setSearchResult: function (value) {
            
        }

    });

}());

(function () {
    /**
     * @class swv6.ui.VisualConnection
     * @extends swv6.util.Publisher
     * A visual representation of the parent-child relationship between two nodes.
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.ui.VisualConnection =
        function (config) {
            config = config || {};

            CLASS.base.ctor.call(this, config);

            this.parent = config.parent;
            this.child = config.child;

            this.path = new swv6.svg.Element({
                tag: 'path',
                attr: {
                    'class': 'edge'
                }
            });

            this.parent.sub('positionChanged', this, this.update);
            this.parent.sub('sizeChanged', this, this.update);
            this.parent.sub('visibilityChanged', this, this.updateVisibility);
            this.child.sub('positionChanged', this, this.update);
            this.child.sub('sizeChanged', this, this.update);
            this.child.sub('visibilityChanged', this, this.updateVisibility);
        };

    swv6.util.inherit(CLASS, BASE, {

        parent: undefined,
        child: undefined,
        path: undefined,

        visible: true,

        getParent: function () {
            return this.parent;
        },

        getChild: function () {
            return this.child;
        },

        getHeight: function () {
            return 100;
        },

        getConnectionPoints: function () {
            var layout = this.parent.getTree().getLayout(),
                location = layout.config.location,
                px = 0,
                py = 0,
                cx = this.child.getRelX(),
                cy = this.child.getRelY();

            switch (location) {
            case 'Top':
                px += this.parent.getWidth() / 2;
                cx += this.child.getWidth() / 2;
                py += this.parent.getHeight();
                break;
            case 'Right':
                py += this.parent.getHeight() / 2;
                cy += this.child.getHeight() / 2;
                cx += this.child.getWidth();
                break;
            case 'Bottom':
                px += this.parent.getWidth() / 2;
                cx += this.child.getWidth() / 2;
                cy += this.child.getHeight();
                break;
            case 'Left':
                py += this.parent.getHeight() / 2;
                cy += this.child.getHeight() / 2;
                px += this.parent.getWidth();
                break;
            }

            return {
                parent: { x: px, y: py },
                child: { x: cx, y: cy }
            };
        },

        update: function () {
    
            /* **********************Top******************************
             *
             *                  ***********
             *                  * parent  *
             *                  *****A*****
             *                       *
             *                       *
             *           C***********B***********C
             *           *           *           *
             *           *           *           *
             *       ****D****   ****D****   ****D****
             *       * child *   * child *   * child *
             *       *********   *********   *********
             *
             * *******************************************************/

            /* ********************Bottom*****************************
             *
             *       *********   *********   *********
             *       * child *   * child *   * child *
             *       ****D****   ****D****   ****D****
             *           *           *           *
             *           *           *           *
             *           C***********B***********C
             *                       *
             *                       *
             *                   ****A****
             *                   *parent *
             *                   *********
             *
             * *******************************************************/

            /* **********************Left*****************************
             *
             *                              *********
             *                    C*********D child *
             *                    *         *********
             *                    *
             * **********         *         *********
             * * parent A*********B*********D child *
             * **********         *         *********
             *                    *
             *                    *         *********
             *                    C*********D child *
             *                              *********
             *
             * *******************************************************/

            var layout = this.parent.getTree().getLayout(),
                cfg = layout.config,
                location = cfg.location,
                edge = cfg.edgeType,
                space = cfg.gapBetweenLevels || 160,
                adjustment = 0.5 * space,
                xAdjustment, yAdjustment,
                pts = this.getConnectionPoints(),
                xa = pts.parent.x,
                ya = pts.parent.y,
                xb, yb,
                xc, yc,
                xd = pts.child.x,
                yd = pts.child.y,
                path = '';

            yAdjustment = (location === 'Top')
                ? (-adjustment)
                : (location === 'Bottom')
                    ? adjustment
                    : 0;
             xAdjustment = (location==='Left')
                ? (-adjustment)
                : (location==='Right')
                    ? adjustment
                    : 0;

            switch (edge) {
                case 'M':
                    //manhattan line
                    if (xAdjustment) {
                        xb = xc = xa - xAdjustment;
                        yb = ya;
                        yc = yd;
                    } else {
                        xb = xa;
                        xc = xd;
                        yb = yc = ya - yAdjustment;
                    }

                    path =
                        ' M' + xa + ',' + ya +
                        ' L' + xb + ',' + yb +  //AB
                        ' L' + xc + ',' + yc +  //BC
                        ' L' + xd + ',' + yd;   //CD

                    break;

                case 'B':
                //bezier curve

                    // 'b' and 'c' coords are control points.
                    if (xAdjustment) {
                        xb = xc = xd + xAdjustment;
                        yb = ya;
                        yc = yd;
                    } else {
                        xb = xa;
                        xc = xd;
                        yb = yc = yd + yAdjustment;
                    }

                    path = 
                        ' M'+ xa + ',' + ya +
                        ' C'+ xb + ',' + yb +
                        ' ' + xc + ',' + yc +
                        ' ' + xd + ',' + yd;

                    break;

                case 'H':
                //bezier curve with drop line

                    if (xAdjustment) {
                        xb = xc = xd + xAdjustment;
                        yb = ya;
                        yc = yd;

                        if ((xAdjustment < 0) ? (xa < xb) : (xa > xb)) {
                            // needs drop line
                            path =
                                ' M' + xa + ',' + ya + 
                                ' L' + xb + ',' + yb;

                            xa = xb;
                        }

                        xb = xc = xa  + (xd - xa) / 2;

                    } else {
                        xb = xa;
                        xc = xd;
                        yb = yc = yd + yAdjustment;

                        if ((yAdjustment < 0) ? (ya < yb) : (ya > yb)) {
                            // needs drop line
                            path =
                                ' M' + xa + ',' + ya + 
                                ' L' + xb + ',' + yb;

                            ya = yb;
                        }

                        yb = yc = ya  + (yd - ya) / 2;

                    }

                    path += 
                        ' M'+ xa + ',' + ya +
                        ' C'+ xb + ',' + yb +
                        ' ' + xc + ',' + yc +
                        ' ' + xd + ',' + yd;

                    break;

                default:
                //direct line
                    path = 
                        ' M' + xa + ',' + ya + 
                        ' T' + xd + ',' + yd;
                    break;
            }

            this.path.el.setAttribute('d', path);
        },

        updateVisibility: function () {
            this.setVisible(this.parent.getVisible() && this.child.getVisible());
        },

        setVisible: function (value) {
            if (this.visible !== value) {
                this.visible = value;
                this.path[value ? 'removeClass' : 'addClass']('hidden');
            }
        },

        setSearchPath: function (value) {
            this.path[!value ? 'removeClass' : 'addClass']('search-path');
        }

    });

}());
