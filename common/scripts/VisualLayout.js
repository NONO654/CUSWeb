/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ui = swv6.ui || {};

(function () {
    /**
     * @class swv6.ui.VisualLayout
     * @extends swv6.util.Publisher
     * Manages the layout of the Product Structure tree.
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher,
        NodeJW,
        TreeJW,
        JW;

    CLASS =
        swv6.ui.VisualLayout =
        function (config) {
            config.location = config.location || 'Top';

            this.config = config || {};

            CLASS.base.ctor.call(this, this.config);

            this.addEvent('layoutChanged');

            this.jw = new JW();
            this.jwNodes = {};
            this.manual = {};

            if (config.tree) {
                this.setTree(config.tree);
            }

        };

    swv6.util.inherit(CLASS, BASE, {

        tree: undefined,
        treeJW: undefined,
        jw: undefined,
        jwView: undefined,
        lastNodeId: 0,
        jwNodes: undefined,
        manual: undefined,
        layoutTimeoutId: undefined,

        deferred: undefined,

        /**
         * TODO: Documentation
         */
        suppressLayout: function (value) {
            this._suppressLayout = value;
        },

        /**
         * TODO: Documentation
         */
        setLocation: function (value) {
            this.config.location = value;
            this.jw.setData({location: value});
        },

        /**
         * TODO: Documentation
         */
        getLocation: function () {
            return this.config.location;
        },

        /**
         * TODO: Documentation
         */
        setTree: function (tree) {
            var root;

            this.tree = tree;
            root = tree.getRoot();
            if (root) {
                this.setRoot(root);
            }

            this.tree.sub('nodeAdded', this, this.onNodeAdded); 
            this.tree.sub('nodeRemoved', this, this.onNodeRemoved);
            this.tree.sub('nodeMoved', this, this.onNodeMoved);
        },

        /**
         * TODO: Documentation
         */
        setRoot: function (root) {
            var jwRoot = this.getNodeJWFromNode(root);
            this.treeJW = new TreeJW(jwRoot);

            this.jw.setData({
                tree: this.treeJW,
                minorGapBetweenNodes: this.config.minorGapBetweenNodes || 10,
                majorGapBetweenNodes: this.config.majorGapBetweenNodes || 20,
                gapBetweenLevels: this.config.gapBetweenLevels || 240,
                location: this.config.location || 'Top',
                alignmentInLevel: this.config.alignmentInLevel || 'TowardsRoot'
            });
            this.jwView = this.jw.getView();

            return jwRoot;
        },

        /**
         * TODO: Documentation
         */
        layout: function (automate) {
            var that = this;

            if (!this.deferred) {
                this.deferred = new swv6.util.Deferred();
            }

            // if _suppressLayout is on, layout should be called manually after turning it off.
            if (!this.layoutTimeoutId && !this._suppressLayout) {
                this.layoutTimeoutId = setTimeout(
                    function () {
                        delete that.layoutTimeoutId;
                        that.doLayout(automate);
                    },
                    0
                );
            }

            return this.deferred;
        },

        // private
        doLayout: function (automate) {
            var track = [],
                t, i, interval,
                that = this,
                layoutFn,
                dims = { // tracks change in tree width during layout.
                    start: {
                        width: this.treeJW.width,
                        height: this.treeJW.height
                    },
                    diff: {}
                };

            automate = (automate !== undefined) ? automate : 500;

            this.treeJW.forEach(function (node) {
                var w, h,
                    nn = node.node;

                node.hidden =
                    node.parent
                        ? node.parent.hidden || !node.parent.node.getExpanded()
                        : false;

                node.hide = (node.hidden && nn.getVisible());

                node.unhide = (node.parent && !node.hidden && !nn.getVisible());
                if (node.unhide) {
                    // unhide *before* we calculate node dimensions, in case element visibility is required
                    // for these calculations.
                    nn.setVisible(true);
                }

                if (nn.getExpandedWidth) {
                    w = nn.getExpanded() ? nn.getExpandedWidth() : nn.getCollapsedWidth();
                    h = nn.getExpanded() ? nn.getExpandedHeight() : nn.getCollapsedHeight();
                } else {
                    w = nn.getWidth();
                    h = nn.getHeight();
                }

                node.w = w;
                node.h = h;
            });

            this.jwView.layout();

            dims.diff.width = this.treeJW.width - dims.start.width;
            dims.diff.height = this.treeJW.height - dims.start.height;

            this.treeJW.forEach(function (node) {
                var nx,
                    ny,
                    nw = node.w,
                    nh = node.h,
                    nn = node.node,
                    nnx = nn.getRelX(),
                    nny = nn.getRelY(),
                    nnw = nn.getWidth(),
                    nnh = nn.getHeight(),
                    move, hide, unhide;

                if (node.hidden) {
                    node.x = node.parent.x + (node.parent.w / 2) - (nw / 2);
                    node.y = node.parent.y + (node.parent.h / 2) - (nh / 2);
                }

                nx = node.x - (node.parent ? node.parent.x : 0);
                ny = node.y - (node.parent ? node.parent.y : 0);

                move = (nnx !== nx) || (nny !== ny) || (nw && (nnw !== nw)) || (nh && (nnh !== nh));

                if (move || hide || unhide) {

                    track.push({
                        node: node,
                        start: { x: nnx, y: nny, w: nnw, h: nnh },
                        finish: { x: nx, y: ny, w: nw, h: nh },
                        hide: hide,
                        unhide: unhide
                    });
                }
            });

            layoutFn = function (pct) {
                var x, y, w, h,
                    nn,
                    i,
                    id, manual;

                for (id in that.manual) {
                    if (that.manual.hasOwnProperty(id)) {
                        manual = that.manual[id];
                        // allow nodes with manual layout to adjust themselves.
                        if (manual.layout) {
                            manual.layout(pct);
                        }
                    }
                }

                for (i=0; i<track.length; i++) {
                    t = track[i];
                    nn = t.node.node;
                    x = t.start.x + (t.finish.x - t.start.x) * pct;
                    y = t.start.y + (t.finish.y - t.start.y) * pct;
                    nn.setRelPosition(x, y);

                    w = t.start.w + (t.finish.w - t.start.w) * pct;
                    h = t.start.h + (t.finish.h - t.start.h) * pct;
                    nn.setSize(w, h);

                    if ((pct === 1) && t.node.hide) {
                        nn.setVisible(false);
                    }
                }

//                that.tree.setSize(dims.start.width + dims.diff.width * pct, dims.start.height + dims.diff.height * pct);

                that.publish('layoutChanged', that);

                that.deferred.notify({
                    layout: that,
                    pct: pct
                });

                if (pct === 1) {
                    that.deferred.resolve(that);
                    that.deferred = undefined;
                }

            };

            if (automate) {
                swv6.animation.animation(
                    automate,
                    layoutFn,
                    'layout'
                );
            } else {
                layoutFn(1);
            }

        },

        /**
         * TODO: Documentation
         */
        getTree: function () {
            return this.tree;
        },

        // private
        isNodeIgnored: function (node) {
            var parent = node.getParent(),
                ignore = false;

            while (parent) {
                if (!parent.layoutChildren) {
                    ignore = true;
                    break;
                }
                parent = parent.getParent();
            }

            return ignore;
        },

        // private
        onNodeAdded: function (tree, parent, child) {
            var nodeJW;

            if (!this.isNodeIgnored(child)) {
                child.setRelPosition(0, 0);
    
                if (tree.getRoot() === child) {
                    nodeJW = this.setRoot(child);
                } else {
                    nodeJW = this.getNodeJWFromNode(child, this.jwNodes[parent.id]);
                }

                if (parent) {
                    this.reorderChildren(parent);
                }

                this.layout();
    
                child.sub('expandedChanged', this, function (node, expanded) {  
                    this.layout();
                });
            } 
            
            if (!child.layoutChildren) {
                this.manual[child.id] = child;
            }
        },

        // private
        onNodeRemoved: function (tree, parent, child) {
            var p, i;

            if (this.jwNodes[child.id]) {
                this.treeJW.forEach(function (node) {
                    if (node.node === child && parent !== undefined) {
                        p = node.parent;
                        for (i = 0; i < p.children.length; ++i) {
                            if (p.children[i].id === node.id) {
                                p.children.splice(i, 1);
                                break ;
                            }
                        }
                    }
                });
    
                delete this.jwNodes[child.id];

                this.reorderChildren(parent);
    
                this.layout();
            }

            if (this.manual[child.id]) {
                delete this.manual[child.id];
            }
        },

        reorderChildren: function (node) {
            var p = this.jwNodes[node.id],
                count = node.getChildCount(),
                cn = [],
                n,
                i;

            for (i=0; i<count; i++) {
                n = this.jwNodes[node.getChild(i).id];
                n.idx = i;
                cn.push(n);
            }

            p.children = cn;
        },

        onNodeMoved: function (tree, node) {
            if (!this.isNodeIgnored(node)) {
                this.reorderChildren(node.getParent());
    
                this.layout();
            }
        },

        // private
        getNodeJWFromNode: function  (node, parentJW) {
            var nodeJW,
                i,
                count;

            nodeJW = {
                id: this.lastNodeId++,
                x: undefined, // output
                y: undefined, // output
                parent: parentJW,
                children: [],
                node: node,
                level: parent ? parent.level + 1 : 0
            };
            this.jwNodes[node.id] = nodeJW;

            if (parentJW) {
                parentJW.children.push(nodeJW);
            }

            if (node.layoutChildren) {
                count = node.getChildCount();
                for (i=0; i<count; i++) {
                    this.getNodeJWFromNode(node.getChild(i), nodeJW);
                }
            }

            return nodeJW;
        }

    });

    ////
    // TreeJW.js
    ////
    // Tree applicable to any type of tree node.
    // To create a tree you must provide the root of the tree. Then you can incrementally
    // construct the tree by adding children to the root or other nodes of the tree
    // (see {@link #addChild(Object, Object)} and
    // {@link #addChildren(Object, Object...)}).
    //
    // @param <NodeJW>
    ////
    TreeJW = function (root) {

        //public variables
        this.root = root;
        this.width = 0;
        this.height = 0;

        ////
        // Returns the the root of the tree
        // Time Complexity: O(1)
        //
        // @return the root of the tree
        ////
        this.getRoot = function () {
            return this.root;
        };
        ////
        // Returns the parent of a node, if it has one.
        // <p>
        // Time Complexity: O(1)
        //
        // @param node
        // @return [nullable] the parent of the node, or null when the node is a
        //         root.
        ////
        this.getParent = function (node) {
            return node.parent;
        };
        ////
        // Returns the children of a parent node.
        // <p>
        // Time Complexity: O(1)
        //
        // @param parentNode
        //            [!isLeaf(parentNode)]
        // @return the children of the given parentNode, from first to last
        ////
        this.getChildren = function (parentNode) {
            return (parentNode)
                ? parentNode.node.getExpanded()
                    ? parentNode.children
                    : []
                : [];
        };
        ////
        // Returns the children of a parent node, in reverse order.
        // <p>
        // Time Complexity: O(1)
        //
        // @param parentNode
        //            [!isLeaf(parentNode)]
        // @return the children of given parentNode, from last to first
        ////
        this.getChildrenReverse = function (parentNode) {
            return this.getChildren(parentNode).reverse();
        };
        ////
        // Returns the first child of a parent node.
        // <p>
        // Time Complexity: O(1)
        //
        // @param parentNode
        //            [!isLeaf(parentNode)]
        // @return the first child of the parentNode
        ////
        this.getFirstChild = function (parentNode) {
            return parentNode.children[0];
        };
        ////
        // Returns the last child of a parent node.
        // <p>
        //
        // Time Complexity: O(1)
        //
        // @param parentNode
        //            [!isLeaf(parentNode)]
        // @return the last child of the parentNode
        ////
        this.getLastChild = function (parentNode) {
            return parentNode.children[parentNode.children.length - 1];
        };
        ////
        // Tells if a node is a leaf in the tree.
        // <p>
        // Time Complexity: O(1)
        //
        // @param node
        // @return true if node is a leaf in the tree, i.e. has no children.
        ////
        this.isLeaf = function (node) {
            return (node.children.length === 0) || !node.node.getExpanded();
        };
        ////
        // Tells if a node is a child of a given parentNode.
        // <p>
        // Time Complexity: O(1)
        //
        // @param node
        // @param parentNode
        // @return true if the node is a child of the given parentNode
        ////
        this.isChildOfParent = function (node, parentNode) {
            return (node.parent === parentNode);
        };

        this.forEach = function (fn, expandedOnly) {
            var ns = [this.root],
                n;
            while (ns.length !== 0) {
                n = ns.shift();
                fn(n);
                if ((!expandedOnly && n.children) || (expandedOnly && !this.isLeaf(n))) {
                    ns = ns.concat(n.children);
                }
            }
        };

    };

    JW = function () {

        //
        // For easier reference the same names/similar names as in the paper of Buchheim C, 
        // Jünger M, Leipert S are used in this implementation. 
        // The implementation also supports tree layouts with the root at the left (or right) side. 
        // Also the y coordinate is not the level but directly refers the y coordinate of a level, 
        // taking node's height and gapBetweenLevels into account. When the root is at the left or right side 
        // the y coordinate actually becomes an x coordinate.
        // Instead of just using a constant "distance" to calculate the position to the next node we refer to the "size" 
        // (width or height) of the node and a "gapBetweenNodes".
        //
        var instantiated, 
            tree, 
            config = {};

        function setConfig(cfg) {
            var p;

            for (p in cfg) {                
                if (cfg.hasOwnProperty(p)) {
                    config[p] = cfg[p];
                }
            }            
        }
        function setTree(treeData) {
            tree = treeData;
        }
        function init() {
            // ------------------------------------------------------------------------
            // These variables are used to hold computed data
            var mod = {}, prelim = {},
                change = {}, shift = {},
                ancestor = {}, thread = {},
                numberA = [],
                finalPositions = [],
                sizeOfLevel = [],
                // ------------------------------------------------------------------------
                Location = {
                    'Top': 'Top',
                    'Left': 'Left',
                    'Bottom': 'Bottom',
                    'Right': 'Right'
                },
                AlignmentInLevel = {
                    'Center': 'Center',
                    'TowardsRoot': 'TowardsRoot',
                    'AwayFromRoot': 'AwayFromRoot'
                };

            function isLevelChangeInYAxis() {
                return (config.location === Location.Top || config.location === Location.Bottom);
            }
            function getLevelChangeSign() {
                return (config.location === Location.Bottom || config.location === Location.Right) ? -1 : 1;
            }
            // ------------------------------------------------------------------------
            // node
            function getNodeHeight(node) {
                return node.h;
            }
            function getNodeWidth(node) {
                return node.w;
            }
            function getWidthOrHeightOfNode(node, returnWidth) {
                return returnWidth ? getNodeWidth(node) : getNodeHeight(node);
            }

            ////
            // When the level changes in Y-axis (i.e. root location Top or Bottom) the
            // height of a node is its thickness, otherwise the node's width is its
            // thickness.
            // The thickness of a node is used when calculating the locations of the
            // levels.
            //
            // @param treeNode
            // @return
            ////
            function getNodeThickness(treeNode) {
                return getWidthOrHeightOfNode(treeNode, !isLevelChangeInYAxis());
            }
            ////
            // When the level changes in Y-axis (i.e. root location Top or Bottom) the
            // width of a node is its size, otherwise the node's height is its size.
            // 
            // The size of a node is used when calculating the distance between two
            // nodes.
            //
            // @param treeNode
            // @return
            ////
            function getNodeSize(treeNode) {
                return getWidthOrHeightOfNode(treeNode, isLevelChangeInYAxis());
            }
/*
            function getConnectorSize(treeNode) {
                var cxns = treeNode.node.getChildCxns(),
                    height = 0,
                    i;

                for (i=0; i<cxns.length; i++) {
                    if (height < cxns[i].getHeight()) {
                        height = cxns[i].getHeight();
                    }
                }
                return height;
            }
*/
            // ------------------------------------------------------------------------
            // size of level
            function calcSizeOfLevels() {
                tree.forEach(function (node) {
                    var size = getNodeThickness(node); // + getConnectorSize(node);
                    
                    node.level = node.parent ? (node.parent.level + 1) : 0;
                    
                    while (sizeOfLevel.length <= node.level) {
                        sizeOfLevel.push(0);
                    }
                    
                    if (sizeOfLevel[node.level] < size) {
                        sizeOfLevel[node.level] = size;
                    }
                    
                }, true);
            }
    
            ////
            // Returns the number of levels of the tree.
            //
            // @return [level > 0]
            ////
            function getLevelCount() {
                return sizeOfLevel.length;
            }
            ////
            // Returns the size of a level.
            // 
            // When the root is located at the top or bottom the size of a level is the
            // maximal height of the nodes of that level. When the root is located at
            // the left or right the size of a level is the maximal width of the nodes
            // of that level.
            //
            // @param level
            // @return the size of the level level >= 0 && level < levelCount
            ////
            function getSizeOfLevel(level) {
                if (level < 0) {
                    return 'level must be >= 0';
                }
                if (level >= getLevelCount()) {
                    return 'level must be < levelCount';
                }
                return sizeOfLevel[level];
            }
    
            function getMod(node) {
                return mod[node.id] || 0;
            }
            function setMod(node, d) {
                mod[node.id] = d;
            }
            function getThread(node) {
                return thread[node.id] || null;
            }
            function setThread(node, threadNode) {
                thread[node.id] = threadNode;
            }
            function getAncestor(node) {
                return ancestor[node.id] ||node;
            }
            function setAncestor(node, ancestorNode) {
                ancestor[node.id] = ancestorNode;
            }
            function getPrelim(node) {
                return prelim[node.id] || 0;
            }
            function setPrelim(node, d) {
                prelim[node.id] = d;
            }
            function getChange(node) {
                return change[node.id] || 0;
            }
            function setChange(node, d) {
                change[node.id] = d;
            }
            function getShift(node) {
                return shift[node.id] || 0;
            }
            function setShift(node, d) {
                shift[node.id] = d;
            }
            ////
            // The distance of two nodes is the distance of the centers of both noded.
            //
            // I.e. the distance includes the gap between the nodes and half of the
            // sizes of the nodes.
            //
            // @param v
            // @param w
            // @return the distance between node v and w
            ////
            function getDistance(v, w) {
                var sizeOfNodes = getNodeSize(v) + getNodeSize(w),
                    p1 = tree.getParent(v),
                    p2 = tree.getParent(w),
                    distance = sizeOfNodes / 2 + ((p1 === p2) ? config.minorGapBetweenNodes : (Math.abs(p2.idx-p1.idx) * config.majorGapBetweenNodes) );
//                    distance = sizeOfNodes / 2 + config.minorGapBetweenNodes;
                return distance;
            }
            function nextLeft(v) {
                return tree.isLeaf(v) ? getThread(v) : tree.getFirstChild(v);
            }
            function nextRight(v) {
                return tree.isLeaf(v) ? getThread(v) : tree.getLastChild(v);
            }
            ////
            //
            // @param node
            //            [tree.isChildOfParent(node, parentNode)]
            // @param parentNode
            //            parent of node
            // @return
            ////
            function getNumber(node, parentNode) {
                var n = numberA[node.id],
                    children, child, i;
                if (!n) {
                    children = tree.getChildren(parentNode);
                    for (i = 0; i < children.length; i++) {
                        child = children[i];
                        numberA[child.id] = i;
                    }
                    n = numberA[node.id];
                }
                return n;
            }
    
            ////
            //
            // @param vIMinus
            // @param v
            // @param parentOfV
            // @param defaultAncestor
            // @return the greatest distinct ancestor of vIMinus and its right neighbor
            //  
            ////
            function ancestorgd(vIMinus, v, parentOfV, defaultAncestor) {
                // when the ancestor of vIMinus is a sibling of v (i.e. has the same
                // parent as v) it is also the greatest distinct ancestor vIMinus and
                // v. Otherwise it is the defaultAncestor
                return tree.isChildOfParent(getAncestor(vIMinus), parentOfV) ? getAncestor(vIMinus) : defaultAncestor;
            }
    
            function moveSubtree(wMinus, wPlus, parent, shiftVal) {
                var subtrees = Math.abs(getNumber(wPlus, parent) - getNumber(wMinus, parent));
                setChange(wPlus, (getChange(wPlus) - shiftVal / subtrees));
                setShift(wPlus, (getShift(wPlus) + shiftVal));
                setChange(wMinus, (getChange(wMinus) + shiftVal / subtrees));
                setPrelim(wPlus, (getPrelim(wPlus) + shiftVal));
                setMod(wPlus, (getMod(wPlus) + shiftVal));
            }
    
            ////
            // @param v
            // @param defaultAncestor
            // @param leftSibling
            //            [nullable] the left sibling v, if there is any
            // @param parentOfV
            //            the parent of v
            // @return the (possibly changes) defaultAncestor
            ////
            function apportion(v, defaultAncestor, leftSibling, parentOfV) {
                var w = leftSibling,
                    vOPlus, vIPlus, vIMinus, vOMinus,
                    sOPlus, sIPlus, sIMinus, sOMinus,
                    nextRightVIMinus,
                    nextLeftVIPlus,
                    shiftVal;

                if (!w) {
                    // v has no left sibling
                    return defaultAncestor;
                }
                // v has left sibling w
                // The following variables "v..." are used to traverse the contours to
                // the subtrees. "Minus" refers to the left, "Plus" to the right
                // subtree. "I" refers to the "inside" and "O" to the outside contour.
                vOPlus = v;
                vIPlus = v;
                vIMinus = w;

                // get leftmost sibling of vIPlus, i.e. get the leftmost sibling of
                // v, i.e. the leftmost child of the parent of v (which is passed in)
                vOMinus = tree.getFirstChild(parentOfV);
                sIPlus = getMod(vIPlus);
                sOPlus = getMod(vOPlus);
                sIMinus = getMod(vIMinus);
                sOMinus = getMod(vOMinus);
                nextRightVIMinus = nextRight(vIMinus);
                nextLeftVIPlus = nextLeft(vIPlus);
                    
                while (nextRightVIMinus && nextLeftVIPlus) {
                    vIMinus = nextRightVIMinus;
                    vIPlus = nextLeftVIPlus;
                    vOMinus = nextLeft(vOMinus);
                    vOPlus = nextRight(vOPlus);
                    setAncestor(vOPlus, v);
                    shiftVal = (getPrelim(vIMinus) + sIMinus) - (getPrelim(vIPlus) + sIPlus)
                    + getDistance(vIMinus, vIPlus);
                    if (shiftVal > 0) {
                        moveSubtree(ancestorgd(vIMinus, v, parentOfV, defaultAncestor), v, parentOfV, shiftVal);
                        sIPlus = sIPlus + shiftVal;
                        sOPlus = sOPlus + shiftVal;
                    }
                    sIMinus = sIMinus + getMod(vIMinus);
                    sIPlus = sIPlus + getMod(vIPlus);
                    sOMinus = sOMinus + getMod(vOMinus);
                    sOPlus = sOPlus + getMod(vOPlus);
    
                    nextRightVIMinus = nextRight(vIMinus);
                    nextLeftVIPlus = nextLeft(vIPlus);
                }
                if (nextRightVIMinus && !nextRight(vOPlus)) {
                    setThread(vOPlus, nextRightVIMinus);
                    setMod(vOPlus, getMod(vOPlus) + sIMinus - sOPlus);
                }
                if (nextLeftVIPlus && !nextLeft(vOMinus)) {
                    setThread(vOMinus, nextLeftVIPlus);
                    setMod(vOMinus, getMod(vOMinus) + sIPlus - sOMinus);
                    defaultAncestor = v;
                }
                return defaultAncestor;
            }
            ////
            //
            // @param v
            //            [!tree.isLeaf(v)]
            ////
            function executeShifts(v) {
                var shiftVal = 0,
                    changeVal = 0,
                    list = tree.getChildrenReverse(v),
                    key, w;
                    
                for (key in list) {
                    if (list.hasOwnProperty(key)) {
                        w = list[key];
                        changeVal = changeVal + getChange(w);
                        setPrelim(w, (getPrelim(w) + shiftVal));
                        setMod(w, (getMod(w) + shiftVal));
                        shiftVal = shiftVal + getShift(w) + changeVal;
                    }
                }
                //reverse back
                list.reverse();
            }
            ////
            // In difference to the original algorithm we also pass in the leftSibling
            // (see {@link #apportion(Object, Object, Object, Object)} for a motivation).
            //
            // @param v
            // @param leftSibling
            //            [nullable] the left sibling v, if there is any
            ////
            function firstWalk(v, leftSibling) {
                var key, w, defaultAncestor, list, previousChild, midpoint;
                if (tree.isLeaf(v)) {
                    // No need to set prelim(v) to 0 as the getter takes care of this.
                    w = leftSibling;
                    if (w) {
                        // v has left sibling
                        setPrelim(v, getPrelim(w) + getDistance(v, w));
                    }
                } else {
                    // v is not a leaf
                    defaultAncestor = tree.getFirstChild(v);
                    previousChild = null;
                    list = tree.getChildren(v);
                    for (key in list) {
                        if (list.hasOwnProperty(key)) {
                            w = list[key];
                            firstWalk(w, previousChild);
                            defaultAncestor = apportion(w, defaultAncestor, previousChild, v);
                            previousChild = w;
                        }
                    }
                    executeShifts(v);
                    midpoint = (getPrelim(tree.getFirstChild(v)) + getPrelim(tree.getLastChild(v))) / 2.0;
                    w = leftSibling;
                    if (w) {
                        // v has left sibling               
                        setPrelim(v, getPrelim(w) + getDistance(v, w));
                        setMod(v, getPrelim(v) - midpoint);
                    } else {
                        // v has no left sibling
                        setPrelim(v, midpoint);
                    }
                }
            }
    
            ////
            // In difference to the original algorithm we also pass in extra level
            // information.
            //
            // @param v
            // @param m
            // @param level
            // @param levelStart
            ////
            // construct the position from the prelim & level information
            // The Root Location ( Top, Bottom, Left or Right) affects the way how x and y are changed and in what direction.
            /////////////////////////////////////////////////////////
            //                   *********
            //                   //       *
            //                   ****A****
            //                       *
            //                       *
            //           C***********B***************C
            //           *           *               *
            //           *           *               *
            //       ****D****   ****D****       ****D****
            //       *       *   *       *       *       *
            //       *********   *********       *********
            // 
            /////////////////////////////////////////////////////////

            function secondWalk() {
                var levelChangeSign = getLevelChangeSign(),
                    levelChangeOnYAxis = isLevelChangeInYAxis(),
                    alignment = config.alignmentInLevel,
                    levelStart = [],
                    i,
                    offset,
                    xs = [], ys = [],
                    xMin, xMax,
                    yMin, yMax;

                levelStart.push(0);
                for (i=1; i<getLevelCount(); i++) {
                    levelStart.push(levelStart[i-1] + levelChangeSign * (getSizeOfLevel(i-1) + config.gapBetweenLevels));
                }

                tree.forEach(function (node) {
                    var parent = node.parent,
                        level = node.level,
                        x,
                        y;

                    if (!node.hidden) {
    
                        // For some reason Firebug couldn't debug after previous switch statement here.
                        // This was changed to if statements to compensate.
                        if (alignment === AlignmentInLevel.Center) {
                            offset = levelChangeSign * (getSizeOfLevel(level) / 2);
                        } else if (alignment === AlignmentInLevel.TowardsRoot) {
                            offset = levelChangeSign * (getNodeThickness(node) / 2);
                        } else {
                            offset = getSizeOfLevel(level) - levelChangeSign * (getNodeThickness(node) / 2);
                        }
                        
                        node.m = parent ? parent.m + getMod(parent) : -getPrelim(node);
    
                        x = getPrelim(node) + node.m;
                        y = levelStart[level] + offset;
                        
                        node.x = levelChangeOnYAxis ? x : y;
                        node.y = levelChangeOnYAxis ? y : x;
                        
                        node.x -= getNodeWidth(node) / 2;
                        node.y -= getNodeHeight(node) / 2;
                        
                        xs.push(node.x);
                        xs.push(node.x + getNodeWidth(node));
                        ys.push(node.y);
                        ys.push(node.y + getNodeHeight(node));
                    }
                });

                xMin = Math.min.apply(null, xs);
                xMax = Math.max.apply(null, xs);
                yMin = Math.min.apply(null, ys);
                yMax = Math.max.apply(null, ys);

                // move all nodes into positive territory.
                tree.forEach(function (node) {
                    node.x -= xMin;
                    node.y -= yMin;
                });

                tree.width = xMax - xMin;
                tree.height = yMax - yMin;
            }

            //public API
            return {
                layout: function () {
                    
                    var r = tree.getRoot();

                    mod = {};
                    prelim = {};
                    change = {};
                    shift = {};
                    ancestor = {};
                    thread = {};
                    numberA = [];
                    finalPositions = [];
                    sizeOfLevel = [];
                                    
                    firstWalk(r, null);
                    calcSizeOfLevels(r, 0);
                    secondWalk(r, -getPrelim(r), 0, 0);
                    //secondWalk();
                },
                getTree: function () {
                    return tree;
                },
                getConfiguration: function () {
                    return config;
                },
                setTree: function (ntree) {
                    tree = ntree;
                },
                setConfiguration: function (cfg) {
                    config = cfg;
                }
            };
        }
        return {
            getView: function () {
                instantiated = init();
//                instantiated.layout();
                return instantiated;
            },
            setData: function (config) {
                setConfig(config);
                
                if (config.tree) {
                    setTree(config.tree);
                }
            }
        };
    };


}());
