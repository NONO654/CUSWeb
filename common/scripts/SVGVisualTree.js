/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ui = swv6.ui || {};

(function () {
    /**
     * @class swv6.ui.SVGVisualTree
     * @extends swv6.ui.VisualTree
     * A visual representation of a data tree.
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.VisualTree;

    CLASS =
        swv6.ui.SVGVisualTree =
        function (config) {

            config = config || {};

            CLASS.base.ctor.call(this, config);

            this.svg = new swv6.svg.SVG({
                parent: this.el,
                cls: 'tree-svg'
            });

            this.g = new swv6.svg.G({
                parent: this.svg
            });

        };

    swv6.util.inherit(CLASS, BASE, {
        
        /**
         * @cfg {swv6.svg.Element} svg
         * The svg element to render this tree into.
         */
        svg: undefined,

        /**
         * @inheritdoc 
         */
        setRoot: function (root) {
            root = CLASS.base.setRoot.call(this, root);
            
            if (root) {
                this.g.el.appendChild(root.g.el);
            }

            return root;
        },

        /**
         * @inheritdoc 
         */
        clear: function () {
            if (this.root) {
                this.g.el.removeChild(this.root.g.el);
            }

            CLASS.base.clear.call(this);
        },

        /**
         * @inheritdoc 
         */
        nodeCtor: function (config) {
            return new swv6.ui.SVGVisualNode(config);
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
        setIsolated: function (node) {
            var root = this.getRoot();

            if (this.isolated) {
                this.isolated.g.removeClass('isolated');
            }

            CLASS.base.setIsolated.apply(this, arguments);

            if (node) {
                node.g.addClass('isolated');
            }

            if (root) {
                root.g[(node? 'add' : 'remove') + 'Class']('isolated-root');
            }

        },
        /**
         *add svg defs to svg element  
         */
		setSVGDefs: function (dom){
			this.svg.addChild(dom);
		}
    });

}());

(function () {
    /**
     * @class swv6.ui.SVGVisualNode
     * @extends swv6.ui.VisualNode
     * A visual representation of a data node.
     */
    'use strict';
    var CLASS,
        BASE = swv6.ui.VisualNode;

    CLASS =
        swv6.ui.SVGVisualNode =
        function (config) {
            config = config || {};

            CLASS.base.ctor.call(this, config);

            this.childrenNode = 
                new swv6.svg.G({
                    attr: {
                        'class': 'children'
                    }
                });

            this.body = new swv6.svg.G({
                cls: 'body'
            });

            this.g = new swv6.svg.G({
                cls: 'node expanded ' + (config.cls || '') + (this.layoutChildren ? '' : ' no-layout'),
                children: [
                    this.childrenNode,
                    this.body
                ]
            });

        };

    swv6.util.inherit(CLASS, BASE, {

        // override
        handleAddChild: function (child, reference) {
            var added = CLASS.base.handleAddChild.apply(this, arguments),
                cxn;

            if (added !== null) {
                if (added.parentCxn) {
                    this.childrenNode.addChild(added.parentCxn.path);
                }
                if (reference) {
                    this.childrenNode.addChild(added.g, reference.g);
                } else {
                    this.childrenNode.addChild(added.g);
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
                    this.childrenNode.removeChild(cxn.path);
                }
                this.childrenNode.removeChild(node.g);
            }

            return node;
        },

        /**
         * @inheritdoc 
         */
        setPosition: function (x, y) {
            CLASS.base.setPosition.apply(this, arguments);

            this.g.el.setAttribute('transform', 'translate(' + this.relX + ',' + this.relY + ')');
        },

        /**
         * @inheritdoc 
         */
        setRelPosition: function (x, y) {
            CLASS.base.setRelPosition.apply(this, arguments);

            this.g.el.setAttribute('transform', 'translate(' + this.relX + ',' + this.relY + ')');
        },

        /**
         * @inheritdoc 
         */
        setExpanded: function (value, deep) {
            CLASS.base.setExpanded.apply(this, arguments);

            this.g.addClass(value ? 'expanded' : 'collapsed');
            this.g.removeClass(!value ? 'expanded' : 'collapsed');
        },

        // private
        handleSetVisible: function (value) {
            CLASS.base.handleSetVisible.apply(this, arguments);
            this.g[value ? 'removeClass' : 'addClass']('hidden');
        },

        setSearchPath: function (value) {
            this.g[!value ? 'removeClass' : 'addClass']('search-path');
        },

        setSearchResult: function (value) {
            this.g[!value ? 'removeClass' : 'addClass']('search-result');
        }

    });

}());
