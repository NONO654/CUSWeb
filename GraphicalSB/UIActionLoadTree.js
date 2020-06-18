(function () {
    /**
     * @class swv6.ui.Action.LoadTree
     * @extends swv6.ui.Action.Camera
     * TODO: description
     */
//    'use strict';
    var CLASS,
        BASE = swv6.ui.Action.Camera;

    CLASS =
        swv6.ui.Action.LoadTree =
        function (config) {
            var vt = config.state.visualTree, // visual tree
                layout = vt.getLayout();

            CLASS.base.ctor.apply(this, arguments);

            this.rootLocation = config.rootLocation || 'Top';
            this.oldRootLocation = layout.getLocation();

            // save the old data tree.
            this.oldTree = this.state.tree;

            // load up the new data tree.
            this.newTree = this.loadDataTree();

        };

    swv6.util.inherit(CLASS, BASE, {
        undo: function () {
            // load old tree and restore its state
            this.loadVisualTree(this.oldTree, this.oldRootLocation, undefined, false);

            this.state.setTree(this.oldTree);

            return CLASS.base.undo.apply(this, arguments);
        },

        redo: function () {
            // reload new tree
            this.loadVisualTree(this.newTree, this.rootLocation, undefined, true);

            this.state.setTree(this.newTree);

            return CLASS.base.redo.apply(this, arguments);
        },

        run: function () {
            this.store('tree');
            this.store('search tree');

            return CLASS.base.run.apply(this, arguments);
        },

        loadDataTree: function () {
        },

        loadVisualTree: function (tree, rootLocation, position, loading) {
            var that = this,
                ns = [],
                n,
                i,
                count,
                child,
                r,
                vt = this.state.visualTree, // visual tree
                layout = vt.getLayout(),
                dtn, // data tree node
                vtn; // visual tree node

            vt.g.el.style.visibility = 'hidden';

            if (loading) {
                layout.suppressLayout(true);
            }

            layout.setLocation(rootLocation);

            vt.clear();

            r = this.addVisualTreeChild(
                null, 
                tree.getRoot()
            );

            ns.push( [r, tree.getRoot()] );

            while (ns.length !== 0) {
                n = ns.shift();
                vtn = n[0];
                dtn = n[1];
                if (vtn.getChildrenLoaded()) {
                    count = dtn.getChildCount();
                    for (i = 0; i < count; i++) {
                        child = dtn.getChild(i);
    
                        ns.push([
                            this.addVisualTreeChild(vtn, child), 
                            child
                        ]);
                    }
                }
            }

            if (!loading) {
                vt.g.el.style.visibility = '';
            } else {

                layout.suppressLayout(false);

                vt.g.el.style.visibility = '';
    
                layout.layout(0).then(
                    function () {
                        var camera = that.state.camera,
                            position;

                        position = camera.createPosition({
                            type: 'fit',
                            el: camera.scene,
                            padding: camera.padding
                        });

                        if (position.getZoom() > 1) {
                            position = position.zoom(1);
                        }

                        camera.setPosition(position);


                        setTimeout(
                            function () {
                                var layout = that.state.visualTree.getLayout(),
                                    x = camera.viewport.offsetWidth / 2,
                                    y = camera.viewport.offsetHeight / 2;

                                switch(layout.getLocation()) {
                                case 'Top':
                                    y = 0;
                                    break;

                                case 'Bottom':
                                    y = camera.viewport.offsetHeight;
                                    break;

                                case 'Left':
                                    x = 0;
                                    break;

                                case 'Right':
                                    x = camera.viewport.offsetWidth;
                                    break;
                                }
                                camera.zoom(1, x, y, false, 500);
                            },
                            500
                        );
    
                    }
                );
            }
        },

        addVisualTreeChild: function (parent, data) {
            var vt = this.state.visualTree,
                n = parent ? parent.addChild({ data: data }) : vt.setRoot({ data: data });

            n.setChildrenLoaded(data.getChildrenLoaded());

            return n;
        }
    });

}());
