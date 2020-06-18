/*jslint sloppy:true, plusplus:true */
/*globals console, lbtree, less*/

var swv6 = swv6 || {};


(function () {
    /**
     * @class swv6.sp.View
     * @extends swv6.util.Publisher
     * The Space Planner View.
     */
//    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.sp.View =
        function (config) {
            CLASS.base.ctor.apply(this, arguments);

            var that = this,
                viewport = new swv6.html.Div({
                    cls: 'viewport',
                    parent: document.getElementsByClassName('content-container')[0]
                }),
                scene = new swv6.html.Div({
                    cls: 'scene',
                    style: {
                        'transformOrigin': 'left top',
                        'webkitTransformOrigin': 'left top',
                        'msTransformOrigin': 'left top'
                    }
                }),
                svg = new swv6.svg.SVG({
                    parent: scene,
                    cls: 'tree-svg',
                    attr: {
                        width: viewport.el.offsetWidth,
                        height: viewport.el.offsetHeight
                    }
                }),
                layout = new swv6.ui.VisualLayout({
                    groupNodePadding: 20,
                    minorGapBetweenNodes: 60,
                    majorGapBetweenNodes: 120,
                    gapBetweenLevels: 240,
                    groupLabelHeight: 30,
                    location: 'Top',
                    alignmentInLevel: 'TowardsRoot',
                    edgeType: 'M'
                }),
                tree = new swv6.ui.SpacePlannerTree({
                    svg: svg,
                    el: scene,
                    layout: layout
                }),
                camera,
                marquee = new swv6.html.Div({ // the dashed zoom/select box
                    parent: viewport,
                    style: {
                        border: '1px dashed black',
                        position: 'absolute',
                        display: 'none',
                        MozBoxSizing: 'border-box',
                        boxSizing: 'border-box',
                    }
                }),
                controller,
                sidebar,
                textRule = swv6.util.createRule(
                    'text',
                    {
                        'font-family': 'arial',
                        stroke: 'none',
                        fill: 'black',
                        'font-size': '14px',
                        visibility: 'visible',
                        opacity: 1
                    }
                ),
                history = new swv6.ui.History();

//            document.getElementsByClassName('content-container')[0].appendChild(viewport.el);

            viewport.insertChild(scene, marquee);
//            scene.addChild(svg);
//            scene.addChild(el);
    
            camera = new swv6.ui.Camera({
                svg: svg,
                scene: scene,
                viewport: viewport.el,
                padding: {
                    left: 210,
                    right: 10,
                    top: 10,
                    bottom: 10
                }
            });

            // handle window resize
            window.onresize = function() {
                svg.setSize(viewport.el.offsetWidth, viewport.el.offsetHeight);
    
                camera.refresh();
    
//                miniMap.refresh();
    
//                slider.setBounds(camera.minZoom * 100, camera.maxZoom * 100);
            };

            history.sub('navigate', this, function (history) {
    /*
                swv6.$('historyBack').style.opacity = history.canUndo() ? 1 : 0.3;
                swv6.$('historyForward').style.opacity = history.canRedo() ? 1 : 0.3;
    
                cmHistoryBack.el.style.opacity = history.canUndo() ? 1 : 0.3;
                cmHistoryForward.el.style.opacity = history.canRedo() ? 1 : 0.3;
    */
            });

            sidebar = new swv6.sp.SideBar({
                dragArea: viewport,
                parent: viewport
            });
            sidebar.dragManager.sub('ondragenter', this, function (evt, el, data) {
    
            });
            sidebar.dragManager.sub('ondragleave', this, function (evt, el, data) {
    
            });
            sidebar.dragManager.sub('ondrop', this, function (evt, el, data) {
                if (data instanceof swv6.ui.SpacePlannerBuildingNode) {
                    this.addChild(data, {data: { name: 'new department', type: 'department', children: [] }});
                }
                if (data instanceof swv6.ui.SpacePlannerDepartmentNode) {
                    this.addChild(data, {data: { name: 'new subdepartment', type: 'subdepartment', children: [] }});
                }
                if (data instanceof swv6.ui.SpacePlannerSubdepartmentNode) {
                    this.addChild(data, {data: { name: 'new space', type: 'space'}});
                }
            });
    
            tree.sub('nodeAdded', null, function (tree, parent, child) {
                // listen for changes in the dimensions of the tree.
                that.publish('onnodeadded', that, child);
            });
    
            tree.sub('sizeChanged', null, function (tree, width, height) {
                // listen for changes in the dimensions of the tree.
            });
    
            camera.subscribe('change', undefined, function (matrix) {
                // listen for changes to the camera.
                var s = "matrix(" + matrix.a + "," + matrix.b + "," + matrix.c + "," + matrix.d + "," + matrix.e + "," + matrix.f + ")";
                tree.g.setAttribute("transform", s);

                tree.div.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.e, matrix.f);
            });
    
            camera.subscribe('zoom', undefined, function (value, old) {
                // listen for changes to the camera's zoom.

                if (value < 0.5) {
                    if (old >= 0.5) { 
                        textRule.style.visibility = 'hidden';
                    }
                } else if (value >= 0.5) { 
                    if (old < 0.5) {
                        textRule.style.visibility = 'visible';
                    }
    
                    if (value < 0.6) {
                        // fade text in between 0.5 and 0.6
                        textRule.style.opacity = (Math.round((value - 0.5) * 1000) / 100).toString();
                    } else if (old < 0.6) {
                        textRule.style.opacity = 1;
                    }
                }
    
            });
    
            layout.sub('layoutChanged', this, function (layout) {
//                // notify camera of changes to the tree's size.
//                camera.refresh();
//                if (camera.isFitToWindow) {
//                    camera.fitWindow(false);
//                }
            });
    
            layout.sub('focusNodeChanged', null, function (layout, node, oldX, oldY) {
                // ensure node doesn't move while it's children are being expanded/collapsed.
                var center = camera.getCenter();
    
                center.x -= oldX - node.getX();
                center.y -= oldY - node.getY();
    
                camera.setCenter(center.x, center.y, 0);
            });

    
            (function () {
                // load the tree

    
            }());


            this.selected = [];



            //TODO: clean-up?
            this.tree = tree;
            this.svg = svg;
            this.viewport = viewport;
            this.scene = scene;
            this.camera = camera;
            this.sidebar = sidebar;
            this.marquee = marquee;
            this.layout = layout;
            this.zi = zi;
            this.zo = zo;

        };

    swv6.util.inherit(CLASS, BASE, {

        /**
         * @event onnodeadded
         * Triggered when a node is added to the tree.
         * @param {swv6.svg.Element} this
         * @param {Object} node The added node.
         */
        /**
         * @event onnoderemoved
         * Triggered when a node is removed from the tree.
         * @param {swv6.svg.Element} this
         * @param {Object} node The removed node.
         */
        events: {
            onnodeadded: true,
            onnoderemoved: true
        },

        setSelected: function (nodes) {
            for (i=0; i<this.selected.length; i++) {
                this.selected[i].div.removeClass('selected');
            }

            this.selected = nodes;

            for (i=0; i<this.selected.length; i++) {
                this.selected[i].div.addClass('selected');
            }
        },

        setMarqueeVisible: function (visible) {
            this.marquee.el.style.display = visible ? '' : 'none';
        },

        setMarqueePosition: function (x, y, width, height) {
//            this.marquee.update(x, y, width, height);
            this.marquee.el.style.left = ((width >= 0) ? x : x + width) + 'px';
            this.marquee.el.style.top = ((height >= 0) ? y : y + height) + 'px';
            this.marquee.el.style.width = Math.abs(width) + 'px';
            this.marquee.el.style.height = Math.abs(height) + 'px';
        },

        load: function () {
            var that = this,
                root = lbtree, // lbtree defined in data/root.json
                ns,
                n,
                i,
                child,
                count = 0,
                max = Number.MAX_VALUE;

this.tree.g.el.style.visibility = 'hidden';
            this.layout.suppressLayout(true);

            ns = [this.addChild(null, { data: root })];
            count++;
            while ((ns.length !== 0) && (count < max)) {
                n = ns.shift();
                if (n.data.children) {
                    for (i = 0; i < n.data.children.length && (count < max); i++) {
                        child = n.data.children[i];
//                        if (child.type !== 'space') {
                            ns.push(this.addChild(n, { data: child }));
                            count++;
//                        }
                    }
                }
            }

            this.layout.suppressLayout(false);

            this.layout.layout(0).then(
                function () {
                    var camera = that.camera,
                        position;

                    camera.fitWindow();

                    position = camera.createPosition({
                        type: 'fit',
                        el: camera.scene,
                        padding: camera.padding
                    });

                    if (position.getZoom() > 1) {
                        position = position.zoom(1);
                    }

                    camera.setPosition(position);

                    that.tree.g.el.style.visibility = '';

                    setTimeout(
                        function () {
                            var x = camera.padding.left + (camera.viewport.offsetWidth - camera.padding.left - camera.padding.right) / 2,
                                y = camera.viewport.offsetHeight / 2;

                            switch(that.layout.getLocation()) {
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
                        1000
                    );

                }
            );

        },

        addChild: function (parent, data) {
            var n = parent ? parent.addChild(data) : this.tree.setRoot(data);

            return n;
        }

    });

}());

window.onload = function() {
    'use strict';

    try {
        var view = new swv6.sp.View(),
            controller = new swv6.sp.Controller({
                view: view
            });

        view.load();
    }
    catch (e) {
        debugger;
    }
};
