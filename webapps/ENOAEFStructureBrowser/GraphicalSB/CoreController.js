/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.sp = swv6.sp || {};


(function () {
    /**
     * @class swv6.ui.Controller
     * @extends swv6.util.Publisher
     * The Space Planner Controller.
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.ui.Controller =
        function (config) {
            var that = this;

            CLASS.base.ctor.call(this, config);

//            this.view = config.view;

            this.svg = config.tree.svg;
            this.viewport = config.viewport;
            this.scene = config.tree.el;
            this.camera = config.camera;
            this.tree = config.tree;
//            this.sidebar = config.view.sidebar;
            this.dataTree = config.tree;
            this.marquee = config.marquee;
            this.minimap = config.minimap;
//            this.search = config.search;
            this.history = config.history;
            this.state = config.state;

            this.nodeEvents = {};

            this.dataTree.sub('nodeAdded', this, function (tree, parent, node) {
                var ev = that.getNodeEvents(node);

                ev.onclick = function (element, evt) {
                        that.handleNodeClick(node, evt);
                    };
                ev.ontouchstart = function (element, evt) {
                    that.handleNodeClick(node, evt);
                };
                ev.oncontextmenu = function (element, evt) {
                    that.handleNodeContextMenu(node, evt);
                };
                ev.ondblclick = function (element, evt) {
                    that.handleNodeDoubleClick(node, evt);
                };
                ev.onmousemove = function (element, evt) {
                    that.handleNodeMouseMove(node, evt);
                };
                ev.onmouseleave = function (element, evt) {
                    that.handleNodeMouseLeave(node, evt);
                };

                node.body.sub('onclick', this, ev.onclick);
                node.body.sub('ontouchstart', this, ev.ontouchstart);
                node.body.sub('oncontextmenu', this, ev.oncontextmenu);
                node.body.sub('ondblclick', this, ev.ondblclick);
                node.body.sub('onmousemove', this, ev.onmousemove);
                node.body.sub('onmouseleave', this, ev.onmouseleave);

            });

            this.dataTree.sub('nodeRemoved', this, function (tree, parent, node) {
                var ev = that.getNodeEvents(node);

                if (ev) {
                    node.body.unsub('onclick', this, ev.onclick);
                    node.body.unsub('ontouchstart', this, ev.ontouchstart);
                    node.body.unsub('oncontextmenu', this, ev.oncontextmenu);
                    node.body.unsub('ondblclick', this, ev.ondblclick);
                    node.body.unsub('onmousemove', this, ev.onmousemove);
                    node.body.unsub('onmouseleave', this, ev.onmouseleave);
                }
            });

            this.viewport.sub('onmousedown', this, this.handleMouseDown);
            this.viewport.sub('oncontextmenu', this, this.handleContextMenu);

            document.ev.sub('onmouseup', this, this.handleMouseUp);
            document.ev.sub('onmousemove', this, this.handleMouseMove);
            this.viewport.sub('onmousewheel', this, this.handleMouseWheel);
            this.viewport.sub('onDOMMouseScroll', this, this.handleMouseWheel);

            this.viewport.sub('onclick', this, this.handleClick);
            this.viewport.sub('ontouchstart', this, this.handleTouchStart);
            this.viewport.sub('ontouchmove', this, this.handleTouchMove);
            this.viewport.sub('ontouchend', this, this.handleTouchEnd);

            if (this.minimap) {
                this.minimap.el.sub('onmousewheel', this, this.handleMouseWheel);
                this.minimap.el.sub('onDOMMouseScroll', this, this.handleMiniMapMouseWheel);
            }

        };

    swv6.util.inherit(CLASS, BASE, {

        thwart: function (e) {
            if(e.preventDefault) {
                this.thwart = function (e) {
                    e.preventDefault();
                };
            } else {
                this.thwart = function (e) {
                    e.returnValue = false;
                };
            }
            this.thwart(e);
        },

        burst: function (e) {
            if(e.stopPropagation) {
                this.burst = function (e) {
                    e.stopPropagation();
                };
            } else {
                this.burst = function (e) {
                    e.cancelBubble = true;
                };
            }
            this.burst(e);
        },

        getNodeEvents: function (node) {
            var ev = this.nodeEvents[node.id];

            if (!ev) {
                ev = this.nodeEvents[node.id] = {};
            }

            return ev;
        },

        handleNodeClick: function (node, evt) {
            this.burst(evt);
            this.tree.setSelected([node]);
        },

        handleNodeDoubleClick: function (node, evt) {
            this.burst(evt);
            this.thwart(evt);

            // TODO: expand/collapse w/ assoc'd camera movements.
            (new swv6.ui.Action.DblClickExpand({
                type: (node.getExpanded() ? 'Collapse' : 'Expand'),
                state: this.state,
                node: node
            })).run();

        },

        handleNodeContextMenu: function (n, evt) {
            this.burst(evt);
            this.thwart(evt);
        },

        handleNodeMouseMove: function(node, evt) {
        },

        handleNodeMouseLeave: function(node, evt) {
        },

        handleClick: function (el, evt) {
            this.tree.setSelected([]);
        },

        handleMouseDown: function (el, evt) {
            var button = evt.button;

            this.stateMouseDown = true;
            if ((button === 2) && evt.ctrlKey) {
                // ctrl + left click appears as right click?
                button = 0;
            }

            switch (button) {
            case 1: // left mouse button
                this.mode = evt.ctrlKey ? 'select' : 'zoom';
                this.stateOrigin = this.getEventPoint(evt);
                this.stateMarqueeActivated = false;
                this.setMarqueePosition(this.stateOrigin.x, this.stateOrigin.y, 0, 0);

                break;

            case 0: // middle mouse button

                // Pan mode
                this.mode = 'pan';
                this.stateTf = this.camera.getCTM();
                this.stateTfInv = this.camera.getCTM().inverse();
                this.stateOrigin = this.getEventPoint(evt).matrixTransform(this.stateTfInv);
                this.viewport.el.style.cursor = 'move';

                this.action = new swv6.ui.Action.Camera({
                    state: this.state
                });

                this.thwart(evt);
                break;
            }

        },

        handleMouseUp: function(evt) {
            var pt1, pt2, m, tmp, nodes, action;

            this.stateMouseDown = false;
            switch (this.mode) {
                case 'zoom':
                case 'select':
                    if (this.stateMarqueeActivated) {
                        m = this.camera.getCTM().inverse();
                        pt1 = this.stateOrigin.matrixTransform(m);
                        pt2 = this.getEventPoint(evt).matrixTransform(m);
                        // ensure pt1 is above and to the left of pt2 for zoomToBox function.
                        if (pt1.x > pt2.x) {
                            tmp = pt1.x;
                            pt1.x = pt2.x;
                            pt2.x = tmp;
                        }
                        if (pt1.y > pt2.y) {
                            tmp = pt1.y;
                            pt1.y = pt2.y;
                            pt2.y = tmp;
                        }

                        if (this.mode === 'zoom') {
//                            this.camera.zoomToBox(pt1.x, pt1.y, pt2.x - pt1.x, pt2.y - pt1.y);
                            (new swv6.ui.Action.Camera({
                                state: this.state,
                                position: {
                                    type: 'box',
                                    x: pt1.x,
                                    y: pt1.y,
                                    width: pt2.x - pt1.x,
                                    height: pt2.y - pt1.y
                                },
                                duration: 500
                            })).run();
                        } else {
                            nodes = this.dataTree.findInside(pt1.x, pt1.y, pt2.x - pt1.x, pt2.y - pt1.y);
                            this.dataTree.setSelected(nodes);
                        }

                        this.setMarqueeVisible(false);
                        this.viewport.el.style.cursor = 'default';

                    }
                    this.mode = '';


                    break;

                case 'pan':
                    this.viewport.el.style.cursor = 'default';
                    this.mode = '';
                    
                    this.action.setPosition(this.camera.getPosition());
                    this.action.run();
                    this.action = undefined;

                    break;
            }

        },

        handleContextMenu: function (el, evt) {
            this.burst(evt);
            this.thwart(evt);
        },

        handleMouseMove: function (evt) {
            var p, pt1, pt2, width, height;

            switch (this.mode) {
                case 'zoom':
                case 'select':

                    pt1 = this.stateOrigin;
                    pt2 = this.getEventPoint(evt);

                    width = pt2.x - pt1.x;
                    height = pt2.y - pt1.y;

                    if (!this.stateMarqueeActivated && ((Math.abs(width) > 10) || (Math.abs(height) > 10))) {
                        this.stateMarqueeActivated = true;

                        this.setMarqueeVisible(true);
                        this.viewport.el.style.cursor = 'crosshair';
                    }

                    if (this.stateMarqueeActivated) {
                        this.setMarqueePosition(this.stateOrigin.x, this.stateOrigin.y, width, height);
                    }

                    break;

                case 'pan':
                    p = this.getEventPoint(evt).matrixTransform(this.stateTfInv);
                    this.camera.setCTM(this.stateTf.translate(p.x - this.stateOrigin.x, p.y - this.stateOrigin.y));

                    break;

            }

        },

        handleMouseWheel: function (el, evt) {
            var delta, zm, f, p;

            if (true /*this.currentState.zoomAllowed*/) { //TODO:
                this.thwart(evt);

                if (evt.wheelDelta) {
                    delta = evt.wheelDelta / 90;
                    // Webkit, Opera
                } else {
                    delta = evt.detail / -3;
                    // Mozilla, Opera
                }

                if (evt.altKey) {
                    delta *= this.options.fastZoomMultiplier;
                }

                ///zooming factor
                f = Math.pow(1 + 0.15, delta);

                p = this.getEventPoint(evt);

                zm = (this.inZoom ? this.cameraProperties.zoom : this.camera.getCurrentZoom());
                this.camera.zoom(zm*f, p.x, p.y, false, false);

                if (!this.action || (this.action !== this.zoomAction)) {
                    this.action = 
                        this.zoomAction = 
                        new swv6.ui.Action.Camera({
                            state: this.state
                        });
                    this.action.run();
                }

                this.action.setPosition(this.camera.getPosition());
            }
        },

        handleMiniMapMouseWheel: function(el, evt) {
            var delta, zm, f, p;

            this.thwart(evt);

            if (evt.wheelDelta) {
                delta = evt.wheelDelta / 90;
                // Webkit, Opera
            } else {
                delta = evt.detail / -3;
                // Mozilla, Opera
            }

            if (evt.altKey) {
                delta *= this.options.fastZoomMultiplier;
            }

            ///zooming factor
            f = Math.pow(1 + 0.15, delta);
            
            p = this.getEventPoint(evt);
            
            zm = this.camera.getCurrentZoom();
            this.camera.zoom(zm*f, undefined, undefined, false, false);

        },

        setMarqueeVisible: function (visible) {
            this.marquee.el.style.display = visible ? '' : 'none';
        },

        setMarqueePosition: function (x, y, width, height) {
            this.marquee.el.style.left = ((width >= 0) ? x : x + width) + 'px';
            this.marquee.el.style.top = ((height >= 0) ? y : y + height) + 'px';
            this.marquee.el.style.width = Math.abs(width) + 'px';
            this.marquee.el.style.height = Math.abs(height) + 'px';
        },

        getAction: function (touches) {
            var action;

            switch (touches) {
            case 0:
                break;
            case 1:
                action = new swv6.ui.PanAction({
                    svg: this.svg,
                    camera: this.camera
                });
                break;
            case 2:
                action = new swv6.sp.ZoomAction({
                    svg: this.svg,
                    camera: this.camera
                });
                break;
            }

            return action;
        },

        handleTouchStart: function (el, evt) {
            this.burst(evt);
//            this.thwart(evt);

            if (this.action) {
                this.action.end();
            }

            this.action = this.getAction(evt.touches.length);
            if (this.action) {
                this.action.start(evt);
            }
        },

        handleTouchMove: function (el, evt) {
            if (this.action) {
                this.action.update(evt);
                this.burst(evt);
                this.thwart(evt);
            }
        },

        handleTouchEnd: function (el, evt) {
            if (!this.sidebar.dragManager.dragging) {
                if (this.action) {
                    this.action.end();
                }

                this.action = this.getAction(evt.touches.length);
                if (this.action) {
                    this.action.start(evt);
                }

                this.burst(evt);
//                this.thwart(evt);
            }
        },

        setCamera: function (zoom, x, y) {
            var that = this,
                currentZoom,
                currentPt,
                tmp;

                this.camera.zoom(zoom, x, y, false, false);
        },

        getEventPoint : function (evt) {
            var p = this.svg.el.createSVGPoint();

            p.x = evt.clientX - this.viewport.el.offsetLeft;
            p.y = evt.clientY - this.viewport.el.offsetTop;

            return p;
        }

    });

}());
