/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ui = swv6.ui || {};

(function () {
    /**
     * @class swv6.ui.HybridVisualTree
     * @extends swv6.ui.VisualTree
     * A visual representation of a data tree.
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.VisualTree;

    CLASS =
        swv6.ui.HybridVisualTree =
        function (config) {

            config = config || {};

            CLASS.base.ctor.call(this, config);

            this.svg = new swv6.svg.SVG({
                parent: this.el,
                cls: 'tree-svg',
                attr: {
//                    width: viewport.el.offsetWidth,
//                    height: viewport.el.offsetHeight
                }
            });

            this.g = new swv6.svg.G({
                attr: {
                }
            });

            this.div = new swv6.html.Div({
                parent: this.el,
                cls: 'tree-div'
            });

            this.svg.el.appendChild(this.g.el);

        };

    swv6.util.inherit(CLASS, BASE, {
        
        /**
         * @cfg {swv6.svg.Element} svg
         * The svg element to render this tree's connections into.
         */
        svg: undefined,

        /**
         * @cfg {swv6.html.Element} el
         * The html element to render this tree's nodes into.
         */
        el: undefined,

        /**
         * @inheritdoc 
         */
        setRoot: function (root) {
            root = CLASS.base.setRoot.apply(this, arguments);
            
            if (root) {
                this.g.addChild(root.g);
                this.div.addChild(root.div);
            }

            return root;
        },

        /**
         * @inheritdoc 
         */
        clear: function () {
            if (this.root) {
                this.g.removeChild(this.root.g);
                this.div.removeChild(this.root.div);
            }

            CLASS.base.clear.call(this);
        },

        /**
         * @inheritdoc 
         */
        nodeCtor: function (config) {
            return new swv6.ui.HybridVisualNode(config);
        },

        /**
         * @inheritdoc 
         */
        setSize: function (width, height) {
/*
            CLASS.base.setSize.apply(this, arguments);

            this.svg.setSize(width, height);
            this.el.setSize(width, height);
*/
        },

        handleLayoutChanged: function () {
            var width, height;

            CLASS.base.handleLayoutChanged.apply(this, arguments);

            width = this.isolated ? this.isolated.getSubtreeWidth() : this.root.getSubtreeWidth();
            height = this.isolated ? this.isolated.getSubtreeHeight() : this.root.getSubtreeHeight();

            this.svg.setSize(this.root.getSubtreeWidth(), this.root.getSubtreeHeight());
            this.el.setSize(width, height);
        },

        /**
         * @inheritdoc 
         */
        setSelected: function (nodes) {
            var i;
            
            for (i=0; i<this.selected.length; i++) {
                this.selected[i].div.removeClass('selected');
            }

            CLASS.base.setSelected.apply(this, arguments);

            for (i=0; i<this.selected.length; i++) {
                this.selected[i].div.addClass('selected');
            }
        },


        /**
         * @inheritdoc 
         */
        setIsolated: function (node) {
            var root = this.getRoot();

            if (this.isolated) {
                this.isolated.g.removeClass('isolated');
                this.isolated.div.removeClass('isolated');
            }

            CLASS.base.setIsolated.apply(this, arguments);

            if (node) {
                node.g.addClass('isolated');
                node.div.addClass('isolated');
            }

            if (root) {
                root.g[(node? 'add' : 'remove') + 'Class']('isolated-root');
                root.div[(node? 'add' : 'remove') + 'Class']('isolated-root');
            }

        }

    });

}());

(function () {
    /**
     * @class swv6.ui.HybridVisualNode
     * @extends swv6.ui.VisualNode
     * A visual representation of a data node.
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.VisualNode;

    CLASS =
        swv6.ui.HybridVisualNode =
        function (config) {
            config = config || {};

            CLASS.base.ctor.call(this, config);

            this.svgChildrenNode = 
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
                children: [ this.svgChildrenNode ]
            });

            this.body = new swv6.html.Div({
                cls: 'body'
            });

            this.htmlChildrenNode = 
                new swv6.html.Div({
                    attr: {
                        'class': 'children'
                    }
                });

            this.div = new swv6.html.Div({
                cls: 'node expanded no-children ' + (config.cls || '') + (this.layoutChildren ? '' : ' no-layout'),
                attr: {
//                    'style': "filter:url(\'#dropshadow\')" TODO:add dropshadow filter back in.
                },
                children: [ 
                    this.body,
                    this.htmlChildrenNode 
                ]
            });

        };

    swv6.util.inherit(CLASS, BASE, {

        g: undefined,
        div: undefined,

        getHeight: function () {
//            console.log(this.body.el.offsetHeight);
            return this.body.el.offsetHeight;
        },

        getWidth: function () {
//            console.log(this.config.data.text + ': ' + this.body.el.offsetWidth);
            return this.body.el.offsetWidth;
        },

        // override
        handleAddChild: function (child, reference) {
            var added = CLASS.base.handleAddChild.apply(this, arguments),
                cxn;

            if (added !== null) {
                if (added.parentCxn) {
                    this.svgChildrenNode.addChild(added.parentCxn.path);
                }
                if (reference) {
                    this.svgChildrenNode.insertChild(added.g, reference.g);
                    this.htmlChildrenNode.insertChild(added.div, reference.div);
                } else {
                    this.svgChildrenNode.addChild(added.g);
                    this.htmlChildrenNode.addChild(added.div);
                }

                if (this.getChildCount() !== 0) {
                    this.div.removeClass('no-children');
                }
            }
            return added;
        },

        // override
        handleRemoveChild: function (node){
            var cxn = node.parentCxn,
                removed = CLASS.base.handleRemoveChild.call(this, node),
                index;

            if (removed) {
                if (cxn) {
                    this.svgChildrenNode.removeChild(cxn.path);
                }
                this.svgChildrenNode.removeChild(node.g);
                this.htmlChildrenNode.removeChild(node.div);

                if (this.getChildCount() === 0) {
                    this.div.addClass('no-children');
                }
            }

            return node;
        },

/*
        // override
        handleMove: function (parent, reference){
            var moved, 
                reparent,
                x, y;

            reparent = (parent !== this.getParent());

            if (reparent) {
                x = this.getX();
                y = this.getY();
            }

            moved = CLASS.base.handleMove.call(this, parent, reference);

            if (reparent) {
                this.setPosition(x, y);
            }

// relocate DOM nodes?

            return moved;
        },
*/

        /**
         * @inheritdoc 
         */
        setPosition: function (x, y) {
            CLASS.base.setPosition.apply(this, arguments);

            this.g.setAttribute('transform', 'translate(' + this.relX + ',' + this.relY + ')');
            this.div.el.style.left = this.relX + 'px';
            this.div.el.style.top = this.relY + 'px';
        },

        /**
         * @inheritdoc 
         */
        setRelPosition: function (x, y) {
            CLASS.base.setRelPosition.apply(this, arguments);

            this.g.el.setAttribute('transform', 'translate(' + this.relX + ',' + this.relY + ')');
            this.div.el.style.left = this.relX + 'px';
            this.div.el.style.top = this.relY + 'px';
        },

        /**
         * @inheritdoc 
         */
        setExpanded: function (value, deep) {
            CLASS.base.setExpanded.apply(this, arguments);

            this.g.addClass(value ? 'expanded' : 'collapsed');
            this.g.removeClass(!value ? 'expanded' : 'collapsed');

            this.div.addClass(value ? 'expanded' : 'collapsed');
            this.div.removeClass(!value ? 'expanded' : 'collapsed');
        },

        // private
        handleSetVisible: function (value) {
            CLASS.base.handleSetVisible.apply(this, arguments);
            this.g[value ? 'removeClass' : 'addClass']('hidden');
            this.div[value ? 'removeClass' : 'addClass']('hidden');
        },

        setSearchPath: function (value) {
            this.g[!value ? 'removeClass' : 'addClass']('search-path');
            this.div[!value ? 'removeClass' : 'addClass']('search-path');
        },

        setSearchResult: function (value) {
            this.g[!value ? 'removeClass' : 'addClass']('search-result');
            this.div[!value ? 'removeClass' : 'addClass']('search-result');
        }

    });

}());
