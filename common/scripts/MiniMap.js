/*jslint plusplus:true*/
/*globals window*/

var swv6 = swv6 || {};
swv6.ui = swv6.ui || {};

(function () {
    /**
     * @class swv6.ui.MiniMap
     * @extends swv6.util.Publisher
     * 
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.Publisher;

    CLASS =
        swv6.ui.MiniMap =
        function (config) {
            var that = this;

            CLASS.base.ctor.apply(this, arguments);

            this.el = new swv6.html.Div({
                parent: config.parent,
                cls: 'mini-map'
            });

            this.marqueeBg = new swv6.html.Div({
                parent: this.el,
                cls: 'marquee-bg'
            });

            this.canvas = new swv6.html.Element({
                parent: this.el,
                tag: 'canvas'
            });

            this.marquee = new swv6.html.Div({
                parent: this.el,
                cls: 'marquee'
            });

            this.tree = config.tree;
            this.camera = config.camera;
            this.ctx = this.canvas.el.getContext('2d');

            this.marquee.sub('onmousedown', this, this.onMarqueeMouseDown);
            this.marquee.sub('onmousemove', this, this.onMarqueeMouseMove);
            this.marquee.sub('onmouseout', this, this.onMarqueeMouseOut);
            this.marquee.sub('ondragstart', this, function (evt) { return false; });

            this.camera.subscribe('change', this, function (matrix) {
                this.cameraChanged();
            });

            this.tree.sub('nodeAdded', this, function (tree, parent, child) {
                if ((parent === null) && (child === tree.getRoot())) {
                    // we have a new root node.
                    this.setRoot(tree.getIsolated() || tree.getRoot());
                }
            });

            this.tree.sub('isolatedChanged', this, function (tree) {
                this.setRoot(tree.getIsolated() || tree.getRoot());
            });

            this.tree.getLayout().sub('layoutChanged', this, function (layout) {
                this.refresh();
            });

//            this.div.onresize = function () {
//                that.updateClientLimits();
//            };

            this.updateClientLimits();

        };

    swv6.util.inherit(CLASS, BASE, {

        root: undefined,
        canvas: undefined,
        marquee: undefined,
        marqueeBg: undefined,
        ctx: undefined,
        div: undefined,
        clientLimits: undefined,

        cursors: {
            'tl': 'nw-resize',
            'tc': 'n-resize',
            'tr': 'ne-resize',
            'ml': 'w-resize',
            'mc': 'move',
            'mr': 'e-resize',
            'bl': 'sw-resize',
            'bc': 's-resize',
            'br': 'se-resize'
        },

        setRoot: function (root) {
            this.root = root;
            if (root) {
                this.refresh();
            }
        },

        refresh: function () {
            var rv, rc, fov;

            this.clear();

            this.updateClientLimits();

            fov = this.camera.getFitFOV();

            rv = fov.width / fov.height;
            rc = this.canvas.el.offsetWidth / this.canvas.el.offsetHeight;

            this.zm = 
                (rc < rv) 
                ? this.canvas.el.offsetWidth / fov.width
                : this.canvas.el.offsetHeight / fov.height;

            if (this.zm > 1) {
                this.zm = 1;
            }

            this.ctx.scale(this.zm, this.zm);

            // translate to center of canvas
            this.tx = -fov.x + (this.canvas.el.offsetWidth / this.zm - fov.width) / 2;
            this.ty = -fov.y;

            this.ctx.translate(this.tx, this.ty);

            // draw nodes
            this.drawNodes(this.ctx, this.root);

            // TODO:
            // draw edges
            // this.drawConnectors(this.ctx, this.tree);

            this.cameraChanged();
        },

        updateClientLimits: function () {
            var x, y, parent;

            x = y = 0;
            parent = this.el;
            while (parent) {
                x += parent.offsetLeft;
                y += parent.offsetTop;
                parent = parent.offsetParent;
            }
            this.clientLimits = {
                x1: x,
                y1: y,
                x2: x + this.el.el.offsetWidth,
                y2: y + this.el.el.offsetHeight
            };
        },

        clear: function () {
            var w = this.canvas.el.parentNode.offsetWidth,
                h = this.canvas.el.parentNode.offsetHeight;

            this.canvas.el.width = 1;
            this.canvas.el.width = w;
            this.canvas.el.height = h;
        },

        drawNode: function (ctx, node) {
            ctx.fillRect(
                node.getX(),
                node.getY(),
                node.getWidth(),
                node.getHeight()
            );
        },

        drawNodes: function (ctx, root) {
            var that = this,
                i, node;

            ctx.save();

            ctx.fillStyle = '#c0c0c0';

            root.forEach( function (node) {
                if (node.getVisible()) {
                    that.drawNode(ctx, node);
                }
            });

            ctx.restore();
        },
/*
        drawConnectors: function (ctx, tree) {
            var j;

            tree.forEach( function (node) {
                var cxns = node.getChildCxns();

                for (j = 0; j < cxns.length; j++) {
                    var connector = cxns[j],
                        xa = connector.pointA.x,
                        ya = connector.pointA.y,
                        xb = connector.pointB.x,
                        yb = connector.pointB.y,
                        xc = connector.pointC.x,
                        yc = connector.pointC.y,
                        xd = connector.pointD.x,
                        yd = connector.pointD.y,
                        lineType = config.edgeType;
    
                    ctx.save();
                    ctx.beginPath();
                    ctx.fillStyle = 'blue';
                    ctx.strokeStyle = '#c0c0c0';
                    ctx.lineWidth = 4;
    
                    switch(lineType) {
                    case "M":
                        ctx.moveTo(xa, ya);
                        ctx.lineTo(xb, yb);
                        ctx.lineTo(xc, yc);
                        ctx.lineTo(xd, yd);
                        break;
    
                    case "Q":
                        ctx.moveTo(xa, ya);
                        ctx.quadraticCurveTo(xc, yc, xd, yd);
                        break;
                    default:
                        ctx.moveTo(xa, ya);
                        ctx.bezierCurveTo(xb, yb, xc, yc, xd, yd);
                        break;
    
                    }
                    ctx.stroke();
                    ctx.restore();
                }

            });
        },
*/
        marqueeCoordsFromEvent: function (evt) {
            var pt;

            pt = {
                x: evt.offsetX || evt.layerX,
                y: evt.offsetY || evt.layerY
            };

            if (evt.target !== this.marquee.el) {
                pt.x += evt.target.offsetLeft;
                pt.y += evt.target.offsetTop;
            }

            return pt;
        },

        onMarqueeMouseDown: function (el, evt) {
            var that = this,
                pt = this.marqueeCoordsFromEvent(evt), // figure out where in the marquee the click occurred.
                s = this.getMarqueeRegion(pt.x, pt.y);

            this.dragRegion = s;

            // store original mouse handlers.
            this.fnMouseMove = window.onmousemove;
            this.fnMouseUp = window.onmouseup;

            this.ptDragStart = {
                x: evt.clientX,
                y: evt.clientY
            };
            this.boxDragStart = this.fov;
        
            document.body.style.cursor = this.cursors[s];
            window.onmousemove = function (evt) { that.onMouseMove(evt); };
            window.onmouseup = function (evt) { that.onMouseUp(evt); };
        },

        onMarqueeMouseMove: function (el, evt) {
            var pt,
                s;

            if (!this.ptDragStart) {
                pt = this.marqueeCoordsFromEvent(evt);
                if ((pt.x > -2) && (pt.x < this.marquee.el.offsetWidth + 2) &&
                    (pt.y > -2) && (pt.y < this.marquee.el.offsetHeight + 2)) {
                    s = this.getMarqueeRegion(pt.x, pt.y);
                    this.marquee.el.style.cursor = this.cursors[s];
                } else {
                    this.marquee.el.style.cursor = '';
                }
            }
        },

        onMarqueeMouseOut: function (el, evt) {
            var isChild = evt.relatedTarget && (evt.relatedTarget.offsetParent === this.marquee.el);
            if (!this.ptDragStart && !isChild) {
                this.marquee.el.style.cursor = '';
            }
        },

        onMouseUp: function (evt) {
            delete this.ptDragStart;
            document.body.style.cursor = '';

            // restore original mouse handlers.
            window.onmousemove = this.fnMouseMove;
            window.onmouseup = this.fnMouseUp;
        },

        onMouseMove: function (evt) {
            var dx = evt.clientX - this.ptDragStart.x,
                dy = evt.clientY - this.ptDragStart.y,
                x = this.boxDragStart.x,
                y = this.boxDragStart.y,
                width = this.boxDragStart.width,
                height = this.boxDragStart.height,
                minFOV = this.camera.getMinFOV(),
                maxFOV = this.camera.getMaxFOV(),
                ar = width / height,
                tmp,
                v, h;

            if (this.dragRegion === 'mc') {
                // contain pannable area to mini-map window.
                if (evt.clientX < this.clientLimits.x1) {
                    dx = this.clientLimits.x1 - this.ptDragStart.x;
                } else if (evt.clientX > this.clientLimits.x2) {
                    dx = this.clientLimits.x2 - this.ptDragStart.x;
                }
                if (evt.clientY < this.clientLimits.y1) {
                    dy = this.clientLimits.y1 - this.ptDragStart.y;
                } else if (evt.clientY > this.clientLimits.y2) {
                    dy = this.clientLimits.y2 - this.ptDragStart.y;
                }
                x += dx / this.zm;
                y += dy / this.zm;                
            } else {
                v = this.dragRegion[0];
                h = this.dragRegion[1];
                
                width = this.boxDragStart.width;
                height = this.boxDragStart.height;

                if (h === 'l') {
                    x += dx / this.zm;
                    width -= dx / this.zm;
                    if (width < minFOV.width) {
                        x += (width - minFOV.width);
                        width = minFOV.width;
                    }
                    if (width > maxFOV.width) {
                        x += (width - maxFOV.width);
                        width = maxFOV.width;
                    }
                } else if (h === 'r') {
                    width += dx / this.zm;
                    if (width < minFOV.width) {
                        width = minFOV.width;
                    }
                    if (width > maxFOV.width) {
                        width = maxFOV.width;
                    }
                }

                if (v === 't') {
                    y += dy / this.zm;
                    height -= dy / this.zm;
                    if (height < minFOV.height) {
                        y += (height - minFOV.height);
                        height = minFOV.height;
                    }
                    if (height > maxFOV.height) {
                        y += (height - maxFOV.height);
                        height = maxFOV.height;
                    }
                } else if (v === 'b') {
                    height += dy / this.zm;
                    if (height < minFOV.height) {
                        height = minFOV.height;
                    }
                    if (height > maxFOV.height) {
                        height = maxFOV.height;
                    }
                }
                
                if (v === 'm') {
                    tmp = height;
                    height = width / ar;
                    y += (tmp - height) / 2;
                }
                if (h === 'c') {
                    tmp = width;
                    width = height * ar;
                    x += (tmp - width) / 2;
                }

                switch (this.dragRegion) {
                case 'tl':
                case 'tr':
                case 'bl':
                case 'br':
                    // maintain aspect ratio.
                    if ((width / height) < ar ) {
                        width = height * ar;
                        if (h === 'l') {
                            x = this.boxDragStart.x + this.boxDragStart.width - width;
                        }
                    } else {
                        height = width / ar;
                        if (v === 't') {
                            y = this.boxDragStart.y + this.boxDragStart.height - height;
                        }
                    }
                    break;
                }
            }
            
            this.camera.zoomToBox(x, y, width, height, false);
        },

        getMarqueeRegion: function (x, y) {
            var s,
                corner = 10;

            if (y <  corner) {
                s = 't';
            } else if (y > (this.marquee.el.offsetHeight -  corner)) {
                s = 'b';
            } else {
                s = 'm';
            }

            if (x <  corner) {
                s += 'l';
            } else if (x > (this.marquee.el.offsetWidth -  corner)) {
                s += 'r';
            } else {
                s += 'c';
            }

            return s;
        },
        
        cameraChanged: function () {
            var l, t, w, h;

            this.fov = this.camera.getFOV();
            
            l = this.canvas.el.offsetLeft + (this.tx + this.fov.x) * this.zm - 1 + 'px'; // -1 for border
            t = this.canvas.el.offsetTop + (this.ty + this.fov.y) * this.zm - 1 + 'px';   // -1 for border
            w = this.fov.width * this.zm + 'px';
            h = this.fov.height * this.zm + 'px';

            this.marquee.el.style.left = this.marqueeBg.el.style.left = l;
            this.marquee.el.style.top = this.marqueeBg.el.style.top = t;
            this.marquee.el.style.width = this.marqueeBg.el.style.width = w;
            this.marquee.el.style.height = this.marqueeBg.el.style.height = h;
        }

    });

}());
