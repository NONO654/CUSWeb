/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.sp = swv6.sp || {};


(function () {
    /**
     * @class swv6.sp.NodeDragManager
     * @extends swv6.util.DragManager
     * The Space Planner Controller.
     */
    'use strict';
    var CLASS,
        BASE = swv6.util.DragManager;

    CLASS =
        swv6.sp.NodeDragManager =
        function (config) {
            var that = this;

            CLASS.base.ctor.call(this, config);

            this.tree = config.tree;
            this.camera = config.camera;

            this.targetMeta = null;
            this.sameTarget = false;
            this.enterCount = 0;

            this.sub('ondragstart', this, this.onDragStart);
            this.sub('ondragend', this, this.onDragEnd);
            this.sub('ondragcancel', this, this.onDragCancel);
            this.sub('ondrag', this, this.onDrag);
            this.sub('ondrop', this, this.onDrop);
            this.sub('ondragenter', this, this.onDragEnter);
            this.sub('ondragleave', this, this.onDragLeave);

        };

    swv6.util.inherit(CLASS, BASE, {

        handleMouseMove: function (evt) {
            var converted = this.convertEvt(evt),
                width = (this.mode === 'node') ? this.node.getWidth() : this.block.el.offsetWidth,
                height = (this.mode === 'node') ? this.node.getHeight() : this.block.el.offsetHeight;

            CLASS.base.handleMouseMove.call(this, converted);
        },

        handleMouseUp: function (evt) {
            var converted = this.convertEvt(evt),
                width = (this.mode === 'node') ? this.node.getWidth() : this.block.el.offsetWidth;

            converted.clientX += (width/2 - this.offsets.x);

            CLASS.base.handleMouseUp.call(this, converted);
        },

        // convert the event coordinates from viewport space to scene space
        convertEvt: function (evt) {
            var pos = this.camera.getPosition().fromViewportToScene(evt.clientX, evt.clientY),
                e = {},
                attr;

            for (attr in evt) {
                e[attr] = evt[attr];
            }

            e.clientX = pos.x;
            e.clientY = pos.y;

            return e;
        },

        getSiblingTargets: function (node, previous, next, hMin, hMax, vMin, vMax, vertical) {
            var nodePreviousEdge, // position of the node's edge, closest to previous node.
                nodeNextEdge, // position of the node's edge, closest to next node.
                pEdge, // position of the previous node's edge, closest to node.
                nEdge, // position of the next node's edge, closest to node.
                pBoundary, // the midway point between previous node and node.
                nBoundary, // the midway point between next node and node.
                middle, // the middle point of node.
                l1, r1, t1, b1,
                l2, r2, t2, b2;

            middle = vertical
                ? node.getY() + node.getHeight() / 2
                : node.getX() + node.getWidth() / 2;

            if (previous) {
                pEdge = vertical
                    ? previous.getY() + previous.getHeight()
                    : previous.getX() + previous.getWidth();
                nodePreviousEdge = vertical
                    ? node.getY()
                    : node.getX();
                pBoundary = pEdge + (nodePreviousEdge - pEdge) / 2;
            } else {
                pBoundary = vertical ? vMin : hMin;
            }

            if (next) {
                nEdge = vertical
                            ? next.getY()
                            : next.getX();
                nodeNextEdge = vertical
                    ? node.getY() + node.getHeight()
                    : node.getX() + node.getWidth();
                nBoundary = nEdge + (nodeNextEdge - nEdge) / 2;
            } else {
                nBoundary = vertical ? vMax : hMax;
            }

            l1 = vertical ? hMin : pBoundary;
            r1 = vertical ? hMax : middle;
            t1 = vertical ? pBoundary : vMin;
            b1 = vertical ? middle : vMax;

            this.addTarget(
                {
                    getBounds: function () {
                        return {
                            x: l1,
                            y: t1,
                            l: l1,
                            r: r1,
                            t: t1,
                            b: b1
                        };
                    }
                },
                { node: node, parent: node.getParent(), previous: previous, next: node }
            );
//console.log (t1, b1);
            l2 = vertical ? hMin : middle;
            r2 = vertical ? hMax : nBoundary;
            t2 = vertical ? middle : vMin;
            b2 = vertical ? nBoundary : vMax;

            this.addTarget(
                {
                    getBounds: function () {
                        return {
                            x: l2,
                            y: t2,
                            l: l2,
                            r: r2,
                            t: t2,
                            b: b2
                        };
                    }
                },
                { node: node, parent: node.getParent(), previous: node, next: next }
            );
//console.log (t2, b2);

        },

        getMissingChildrenTargets: function (first, last, count, hMin, hMax, vMin, vMax, vertical) {
            var layout = this.tree.getLayout(),
                minorGap = layout.config.minorGapBetweenNodes,
                majorGap = layout.config.majorGapBetweenNodes,
                leading = first.getNeighbor(true),
                trailing = last.getNeighbor(),
                l = leading ? leading.getChild(leading.getChildCount()-1) : null,
                t = trailing ? trailing.getChild(0) : null,
                le = l ? (l.getX() + l.getWidth()) : null, // leading edge
                te = t ? t.getX() : null, // trailing edge
                w = count * majorGap,
                m,
                start,
                i,
                e,
                b,
                n;

            if (l && t) {
                m = le + ((te - le) / 2);
                start = m - w/2;
            } else if (l) {
                start = le;
            } else {
                start = te - count * majorGap;
            }

            e = start;
            n = first;
            do {

                b = {
                    l: vertical ? hMin : e,
                    r: vertical ? hMax : e + majorGap,
                    t: vertical ? e : vMin,
                    b: vertical ? e + majorGap : vMax
                };

                if ((i===0) && (!l)) {
                    if (vertical) {
                        b.t = vMin;
                    } else {
                        b.l = hMin;
                    }
                }
                if ((i===(count-1)) && (!t)) {
                    if (vertical) {
                        b.t = vMin;
                    } else {
                        b.l = hMin;
                    }
                }

                this.addTarget(
                    {
                        getBounds: function () {
                            return {
                                x: b.l,
                                y: b.t,
                                l: b.l,
                                r: b.r,
                                t: b.t,
                                b: b.b
                            };
                        }
                    },
                    { parent: n }
                );

                start += majorGap;

            } while ((n !== last) && ((n = n.getNeighbor()) !== null));

        },

        getNodeTarget: function (node) {

            var b = {
                l: node.getX(),
                r: node.getX() + node.getWidth(),
                t: node.getY(),
                b: node.getY() + node.getHeight()
            };

            this.addTarget(
                {
                    getBounds: function () {
                        return {
                            x: b.l,
                            y: b.t,
                            l: b.l,
                            r: b.r,
                            t: b.t,
                            b: b.b
                        };
                    }
                },
                { parent: node }
            );

        },

        createParentTarget: function (n) {
            return {
                getBounds: function () {
                    return {
                        x: n.getX(),
                        y: n.getY(),
                        l: n.getX(),
                        r: n.getX() + n.getWidth(),
                        t: n.getY(),
                        b: n.getY() + n.getHeight()
                    };
                }
            };
        },

        indexNodes: function () {
            var that = this;

            // gets an ordered list of all nodes in a given level.
            this.index = [];
            this.map = {};

            this.tree.forEach(function (n) {
                if ((n.ctor === that.node.ctor) && (n !== that.node)) {
                    that.map[n.id] = that.index.length;
                    that.index.push(n);
                }
            });
        },

        endDropFromOutside: function (evt, node) {
                var parent = node.data.data;
                var idTarget = parent.getAttribute("o");
                var idForm = null;
                var idDiv = null;
                var levelTarget = parent.getAttribute("id");
                var parentDrop = "parent";
                var typeDrop = "Part";
                var types = "Part";
                var relationships = "EBOM";
                var attributes = "";
                var directions = "from";
                var typesStructure = "Workspace Vault";
                var refresh = "id[level]=" + levelTarget + ".expandRow";
                var validator = null;
                var dragInfo = JSON.parse(evt.dataTransfer.getData('text'));
                var event = {
                              preventDefault: function () {},
                              stopPropagation: function () {},
                              dataTransfer: {
                                                files: new Array(),
                                                getData: function() {
                                                    var dragLevel = dragInfo.id;
                                                    var dragDiv = "Drag" + dragLevel.replace(",", "_");
                                                    var dragId = dragInfo.oid;
                                                    var dragRel = dragInfo.rid;
                                                    var dragParent = "parent";
                                                    var dragType = "Part";
                                                    var kindDrag = "Part";
                                                    return "URL" + "_param=" + dragDiv + "_param=" + dragId + "_param=" + dragRel + "_param=" + dragLevel + "_param=" + dragParent + "_param=" + dragType+ "_param=" + kindDrag + "_param=";
                                                }
                                            },
                              ctrlKey: false,
                              target: new Object()
                              
                          }

                FileSelectHandler(event, idTarget, idForm, idDiv, refresh, levelTarget, parentDrop, typeDrop, types, relationships, attributes,directions,typesStructure,validator, "dropAreaColumn");
        },
        
        startNodeDrag: function (element, evt, node) {
						console.log("startNodeDrag");

            var position = this.camera.getPosition(),
                coords = position.fromViewportToScene(evt.clientX, evt.clientY);

            this.offsets = {
                x: coords.x - node.getX(),
                y: coords.y - node.getY()
            };

            this.mode = 'node';

            this.moving = !evt.ctrlKey && !evt.metaKey;
            this.node = node;
            this.originalParent = node.getParent();
            if (node.getSiblingIndex() === node.getParent().getChildCount()-1) {
                this.originalReference = undefined;
            } else {
                this.originalReference = node.getNeighbor();
            }

            this.start();
        },

        startPlacementDrag: function (block, dragBlock, evt, viewport) {
			console.log("startPlacementDrag");
            var bb = block.getBBox(),
                parent;

            parent = block.el.offsetParent;
            while (parent) {
                bb.x += parent.offsetLeft;
                bb.y += parent.offsetTop;
                parent = parent.offsetParent;
            }

            this.blockOffsets = {
                x: evt.clientX - bb.x,
                y: evt.clientY - bb.y
            };

            this.offsets = this.blockOffsets;

            this.mode = 'placement';
            this.node = null;

            this.block = dragBlock;
            this.viewport = viewport;

            this.start();
        },

        onDragStart: function () {
			console.log("onDragStart");
            var layout = this.tree.getLayout(),
                cxn;

            this.tree.el.addClass('node-drag-in-progress');
            layout.suppressLayout(true);

            this.clearTargets();

            switch (this.mode) {

            case 'node':
                this.placeholder = this.cloneNode(this.node, this.node.getParent(), this.node);

//                this.node.div.el.style.opacity = 0.7;
                if (this.node.getParentCxn()) {
                    this.node.getParentCxn().path.addClass('target');
                }
                this.node.div.addClass('dragged-node');
//                this.node.div.addClass('drag-node');

                cxn = this.placeholder.getParentCxn();
                if (this.moving) {
                    this.placeholder.div.addClass('move-source');
                    if (cxn) {
                        cxn.path.addClass('move-source-cxn');
                    }
                } else {
                    this.placeholder.div.addClass('copy-source');
                    if (cxn) {
                        cxn.path.addClass('copy-source-cxn');
                    }
                }

                //if (this.node instanceof swv6.ui.SpacePlannerSpaceNode) {
                    //this.dragSpaceNode(this.node);
               // } else {
                    this.dragRegularNode(this.node);
                //}
                break;

            case 'placement':
                this.dragPlacement(this.node);

                this.block.removeClass('hidden');

//                this.viewport.addChild(this.block);


                break;

            }
        },

        dragRegularNode: function (node) {
            var f, p, n,
                first,
                last,
                ns,
                count;


            // Add targets for empty parents. ===========================

            // first, let's find the first node at this node's *parent* level.
            f = node.getParent();
            while ((p = f.getNeighbor(true)) !== null) {
                f = p;
            }

            n = f;
            do {
                if (n.getChildCount() === 0) {
                    first = last = n;

                    // find the next node that has children.
                    count = 1;
                    while (((n = n.getNeighbor()) !== null) && (n.getChildCount() === 0)) {
                        count++;
                        last = n;
                    }
                    this.getMissingChildrenTargets(
                        first,
                        last,
                        count,
                        Number.NEGATIVE_INFINITY,
                        Number.POSITIVE_INFINITY,
                        Number.NEGATIVE_INFINITY,
                        Number.POSITIVE_INFINITY,
                        false
                    );
                }
            } while (n && (n = n.getNeighbor()) !== null);

            // ==========================================================

            // Add sibing targets. ======================================

            // first, let's find the first node at this level.
            f = node;
            while ((p = f.getNeighbor(true)) !== null) {
                f = p;
            }

            // build a list of all targetable nodes at this level.  (Creating this list avoids add'l calls to getNeighbor later.)
            ns = [];
            n = f;
            do {
                if (n !== node) {
                    ns.push(n);
                }
            } while ((n = n.getNeighbor()) !== null);

            // now create the sibling level targets.
            ns.forEach(
                function (node, index, array) {
                    var p = array[index-1],
                        n = array[index+1];

                    this.getSiblingTargets(
                        node,
                        p,
                        n,
                        Number.NEGATIVE_INFINITY,
                        Number.POSITIVE_INFINITY,
                        Number.NEGATIVE_INFINITY,
                        Number.POSITIVE_INFINITY,
                        false
                    );
                },
                this
            );

            // ==========================================================

        },

        dragSpaceNode: function (node) {
            var f, p, n,
                first,
                last,
                ns,
                count;

            // Add space targets for empty subdepartments. ===========================

            // first, let's find the first node at this node's *parent* level.
            f = node.getParent();
            while ((p = f.getNeighbor(true)) !== null) {
                f = p;
            }

            n = f;
            do {
                if (n.getChildCount() === 0) {
                    this.getNodeTarget(n);
                }
            } while (n && ((n = n.getNeighbor()) !== null));


            // Add space sibing targets. ======================================

            // first, let's find the first node at this level.
            f = node;
            while ((p = f.getNeighbor(true)) !== null) {
                f = p;
            }

            // build a list of all targetable nodes at this level.  (Creating this list avoids add'l calls to getNeighbor later.)
            ns = [];
            n = f;
            do {
                if (n !== node) {
                    ns.push(n);
                }
            } while ((n = n.getNeighbor()) !== null);

            // now create the sibling level targets.
            ns.forEach(
                function (node, index, array) {
                    var p = array[index-1],
                        n = array[index+1],
                        parent = node.getParent();

                    if (p && (p.getParent() !== parent)) {
                        p = null;
                    }

                    if (n && (n.getParent() !== parent)) {
                        n = null;
                    }

                    this.getSiblingTargets(
                        node,
                        p,
                        n,
                        parent.getX(),
                        parent.getX() + parent.getWidth(),
                        parent.getY(),
                        parent.getY() + parent.getHeight(),
                        true
                    );
                },
                this
            );
        },

        dragPlacement: function () {
            var that = this,
                f, p, n,
                first, last,
                ns,
                count,
                building,
                dept,
                subdept,
                space,
                maxSubDept,
                minX, maxX,
                layout = this.tree.getLayout(),
                gapBetweenLevels = layout.config.gapBetweenLevels;

            this.tree.forEach(function (n) {
                var target,
                    p = n.getParent(),
                    s,
                    lEmptySiblingCount = 0,
                    rEmptySiblingCount = 0,
                    si,
                    nodeL = null,
                    nodeR = null,
                    l, r, t, b;

                if (!building && (n.ctor === swv6.ui.SpacePlannerBuildingNode)) {
                    building = n;
                }

                if (!dept && (n.ctor === swv6.ui.SpacePlannerDepartmentNode)) {
                    // ensure this is the left-most dept.
                    f = n;
                    while ((p = f.getNeighbor(true)) !== null) {
                        f = p;
                    }
                    dept = f;
                }

                if (!subdept && (n.ctor === swv6.ui.SpacePlannerSubdepartmentNode)) {
                    maxSubDept = n.getY();

                    // ensure this is the left-most subdept.
                    f = n;
                    while ((p = f.getNeighbor(true)) !== null) {
                        f = p;
                    }
                    subdept = f;
                }

                if (!space && (n.ctor === swv6.ui.SpacePlannerSpaceNode)) {
                    // ensure this is the left-most space.
                    f = n;
                    while ((p = f.getNeighbor(true)) !== null) {
                        f = p;
                    }
                    space = f;
                }

                if (n.ctor === swv6.ui.SpacePlannerDepartmentNode) {
                    that.getNodeTarget(n);
                }
            });

            minX = -building.getWidth() - layout.config.minorGapBetweenNodes;
            maxX = this.tree.getWidth() + building.getWidth() + layout.config.minorGapBetweenNodes;

            maxSubDept -= gapBetweenLevels / 2;

            // *******************************************************************

            // Add targets for empty building node. ===========================
            n = building;
            do {
                if (n.getChildCount() === 0) {
                    first = last = n;

                    // find the next node that has children.
                    count = 1;
                    while (((n = n.getNeighbor()) !== null) && (n.getChildCount() === 0)) {
                        count++;
                        last = n;
                    }
                    this.getMissingChildrenTargets(
                        first,
                        last,
                        count,
                        minX,
                        maxX,
                        Number.NEGATIVE_INFINITY,
                        maxSubDept,
                        false
                    );
                }
            } while (n && (n = n.getNeighbor()) !== null);


            // Add department sibing targets. ======================================

            // build a list of all targetable nodes at this level.  (Creating this list avoids add'l calls to getNeighbor later.)
            ns = [];
            n = dept;
            do {
                ns.push(n);
            } while ((n = n.getNeighbor()) !== null);

            // now create the sibling level targets.
            ns.forEach(
                function (node, index, array) {
                    var p = array[index-1],
                        n = array[index+1];

                    this.getSiblingTargets(
                        node,
                        p,
                        n,
                        minX,
                        maxX,
                        Number.NEGATIVE_INFINITY,
                        maxSubDept,
                        false
                    );
                },
                this
            );

            // *******************************************************************

            // Add space targets for empty subdepartments. ===========================
            n = subdept;
            do {
                if (n.getChildCount() === 0) {
                    this.getNodeTarget(n);
                }
            } while (n && ((n = n.getNeighbor()) !== null));

            // Add space sibing targets. ======================================

            // build a list of all targetable nodes at this level.  (Creating this list avoids add'l calls to getNeighbor later.)
            ns = [];
            n = space;
            do {
                ns.push(n);
            } while ((n = n.getNeighbor()) !== null);

            // now create the sibling level targets.
            ns.forEach(
                function (node, index, array) {
                    var p = array[index-1],
                        n = array[index+1],
                        parent = node.getParent();

                    if (p && (p.getParent() !== parent)) {
                        p = null;
                    }

                    if (n && (n.getParent() !== parent)) {
                        n = null;
                    }

                    this.getSiblingTargets(
                        node,
                        p,
                        n,
                        parent.getX(),
                        parent.getX() + parent.getWidth(),
                        parent.getY(),
                        parent.getY() + parent.getHeight(),
                        true
                    );
                },
                this
            );


            // *******************************************************************

            // Add targets for empty departments. ===========================
            n = dept;
            do {
                if (n.getChildCount() === 0) {
                    first = last = n;

                    // find the next node that has children.
                    count = 1;
                    while (((n = n.getNeighbor()) !== null) && (n.getChildCount() === 0)) {
                        count++;
                        last = n;
                    }

                    this.getMissingChildrenTargets(
                        first,
                        last,
                        count,
                        minX,
                        maxX,
                        maxSubDept,
                        Number.POSITIVE_INFINITY,
                        false
                    );
                }

            } while (n && (n = n.getNeighbor()) !== null);


            // Add subdepartment sibing targets. ======================================

            // build a list of all targetable nodes at this level.  (Creating this list avoids add'l calls to getNeighbor later.)
            ns = [];
            n = subdept;
            do {
                ns.push(n);
            } while ((n = n.getNeighbor()) !== null);

            // now create the sibling level targets.
            ns.forEach(
                function (node, index, array) {
                    var p = array[index-1],
                        n = array[index+1];

                    this.getSiblingTargets(
                        node,
                        p,
                        n,
                        minX,
                        maxX,
                        maxSubDept,
                        Number.POSITIVE_INFINITY,
                        false
                    );
                },
                this
            );

        },

        onDragEnd: function () {
			console.log("onDragEnd");
            var layout = this.tree.getLayout(),
                cxn;

            layout.suppressLayout(false);
            layout.layout(500);

            this.tree.el.removeClass('node-drag-in-progress');

            switch (this.mode) {
            case 'node':
//                this.node.div.el.style.opacity = '';
                if (this.node.getParentCxn()) {
                    this.node.getParentCxn().path.removeClass('target');
                }
//                this.node.div.removeClass('drag-node');

                //clean up.
                if (this.parent) {
                    this.parent.div.removeClass('target');
                }
                break;
            case 'placement':
//                this.viewport.removeChild(this.block);

                if (this.parent) {
                    this.parent.div.removeClass('target');
                }

                this.block.addClass('hidden');

                break;
            }

            if (this.node) {
                this.node.div.removeClass('dragged-node');

                //if (this.node instanceof swv6.ui.SpacePlannerSpaceNode) {
                    //this.node.div.el.style.left = '';
                    //this.node.div.el.style.top = '';
                    //this.node.getParent().layout();
                    //this.node.getParent().updateSize();
                //}

            }

            if (this.mode === 'node') {
                if (this.moving) {

                    var pp = this.placeholder.getParent();
                    pp.removeChild(this.placeholder);

                    //if (this.node instanceof swv6.ui.SpacePlannerSpaceNode) {
                        //pp.layout();
                        //pp.updateSize();
                    //}

                } else {
                    this.placeholder.div.removeClass('copy-source');
                    cxn = this.placeholder.getParentCxn();
                    if (cxn) {
                        this.placeholder.getParentCxn().path.removeClass('copy-source-cxn');
                    }
                }
            }

            if (this.mode === 'node') {
                var row = this.node.data.data;
                var parent = this.parent.data.data;
                var evt = {
                              preventDefault: function () {},
                              stopPropagation: function () {},
                              dataTransfer: {
                                                files: new Array(),
                                                getData: function() {
                                                    var dragLevel = row.getAttribute("id");
                                                    var dragDiv = "Drag" + dragLevel.replace(",", "_");
                                                    var dragId = row.getAttribute("o");
                                                    var dragRel = row.getAttribute("r");
                                                    var dragParent = "parent";
                                                    var dragType = "Part";
                                                    var kindDrag = "Part";
                                                    return "URL" + "_param=" + dragDiv + "_param=" + dragId + "_param=" + dragRel + "_param=" + dragLevel + "_param=" + dragParent + "_param=" + dragType+ "_param=" + kindDrag + "_param=";
                                                }
                                            },
                              ctrlKey: false,
                              target: new Object()
                              
                          }
                var idTarget = parent.getAttribute("o");
                var idForm = null;
                var idDiv = null;
                var levelTarget = parent.getAttribute("id");
                var parentDrop = "parent";
                var typeDrop = "Part";
                var types = "Part";
                var relationships = "EBOM";
                var attributes = "";
                var directions = "from";
                var typesStructure = "Workspace Vault";
                var refresh = "id[level]=" + levelTarget + ".expandRow";
                var validator = null;

                FileSelectHandler(evt, idTarget, idForm, idDiv, refresh, levelTarget, parentDrop, typeDrop, types, relationships, attributes,directions,typesStructure,validator, "dropAreaColumn");
            }
            if (this.node) {
                delete this.node;
            }

            if (this.previous) {
                this.previous.div.removeClass('target-previous');
                delete this.previous;
            }

            if (this.next) {
                this.next.div.removeClass('target-next');
                delete this.next;
            }

        },

        onDragCancel: function () {
			console.log("onDragCancel");
            if (this.mode === 'node') {
                this.node.move(this.originalParent, this.originalReference);
            }
        },

        changeTarget: function (evt) {
            var meta,
                parent,
                previous,
                next;

            if (this.over.length !== 0) {
                meta = this.over[0][1];
                parent = meta.parent;
                if (meta.previous) {
                    previous = meta.previous;
                } else {
                    previous = undefined;
                }
                if (meta.next) {
                    next = meta.next;
                } else {
                    next = undefined;
                }
            } else {
                parent = null;
            }

            if (parent !== this.parent) {

                if (this.parent) {
                    this.parent.div.removeClass('target');

                    if ((this.mode === 'placement') && this.node) {
                        this.node.getParent().removeChild(this.node);
                        delete this.node;
                    }
                }
                this.parent = parent;

                if (parent) {
                    if (this.mode === 'node') {
                        this.node.move(parent, undefined);
                        if (this.node.getParentCxn()) {
                            this.node.getParentCxn().path.addClass('target');
                        }
                    } else {
                        if (parent instanceof swv6.ui.SpacePlannerBuildingNode) {
                            this.node = parent.addChild({data: {data: { name: 'new department', type: 'department', children: [] }}});
                        }
                        if (parent instanceof swv6.ui.SpacePlannerDepartmentNode) {
                            this.node = parent.addChild({data: {data: { name: 'new subdepartment', type: 'subdepartment', children: [] }}});
                        }
                        if (parent instanceof swv6.ui.SpacePlannerSubdepartmentNode) {
                            this.node = parent.addChild({data: {data: { name: 'new space', type: 'space'}}});
                        }
                        this.node.div.addClass('dragged-node');

                        this.offsets = {
                            x: 0,
                            y: 5
                        };

                    }

                    this.node.div.el.style.zIndex = '';

                    this.parent.div.addClass('target');
                }

                if (this.mode === 'placement') {
                    if (parent) {
                        this.block.addClass('hidden');
                    } else {
                        this.block.removeClass('hidden');
                    }

//                    this.block.el.style.visibility = parent ? 'hidden' : '';
                    if (!parent) {
                        this.offsets = this.blockOffsets;
                    }
                }

            }

            if (previous !== this.previous) {
                if (this.previous) {
                    this.previous.div.removeClass('target-previous');
                }
                this.previous = previous;
                if (this.previous) {
                    this.previous.div.addClass('target-previous');
                }
            }

            if (next !== this.next) {
                if (this.next) {
                    this.next.div.removeClass('target-next');
                }
                this.next = next;
                if (this.next) {
                    this.next.div.addClass('target-next');
                }
            }

        },

        onDragEnter: function (evt, target, meta) {
			console.log("onDragEnter");
            this.changeTarget(evt);
        },

        onDragLeave: function (evt, target, meta) {
			console.log("onDragLeave");
            this.changeTarget(evt);
        },

        onDrag: function (evt) {
			console.log("onDrag");
            switch (this.mode) {
            case 'node':
                this.node.setPosition(
                    evt.clientX - this.offsets.x,
                    evt.clientY - this.offsets.y
//                    evt.clientX - this.node.getWidth()/2,
//                    evt.clientY - this.node.getHeight()/2 //this.offsets.y /*this.node.getY()*/
                );
                break;

            case 'placement':
                var pos = this.camera.getPosition().fromSceneToViewport(evt.clientX, evt.clientY);

                this.block.el.style.left = (pos.x - this.offsets.x) + 'px';
                this.block.el.style.top = (pos.y - this.offsets.y) + 'px';

                if (this.node) {
                    this.node.setPosition(evt.clientX - this.node.getWidth()/2, evt.clientY - this.offsets.y /*this.node.getY()*/);
                }

                break;

            }
        },

        onDrop: function (evt, targets, metas) {
			console.log("onDrop");
            var that = this,
                added,
                meta,
                parent,
                next;

            this.changeTarget(evt);

            if (this.parent) {

                meta = metas[0];

                if (meta.next && (meta.next.getParent() === this.parent)) {
                    next = meta.next;
                } else {
                    next = undefined;
                }

                this.node.move(this.parent, next);

            }

/*
            switch (this.mode) {
            case 'node':
                if (this.parent) {

                    meta = metas[0];

                    if (meta.next && (meta.next.getParent() === this.parent)) {
                        next = meta.next;
                    } else {
                        next = undefined;
                    }

                    this.node.move(this.parent, next);

                    this.node.div.removeClass('dragged-node');

                }


                if (this.moving) {
                    var pp = this.placeholder.getParent();
                    pp.removeChild(this.placeholder);

                    if (this.node instanceof swv6.ui.SpacePlannerSpaceNode) {
                        pp.layout();
                        pp.updateSize();
                    }

                } else {
                    this.placeholder.div.el.style.opacity = 1;
                }

                if (this.node instanceof swv6.ui.SpacePlannerSpaceNode) {
                    this.node.div.el.style.left = '';
                    this.node.div.el.style.top = '';
                    this.node.getParent().layout();
                    this.node.getParent().updateSize();
                }

                break;

            case 'placement':
                if (this.parent) {

                    meta = metas[0];

                    if (meta.next && (meta.next.getParent() === this.parent)) {
                        next = meta.next;
                    } else {
                        next = undefined;
                    }

                    this.node.move(this.parent, next);

                    this.node.div.removeClass('dragged-node');

                    if (this.node instanceof swv6.ui.SpacePlannerSpaceNode) {
                        this.node.div.el.style.left = '';
                        this.node.div.el.style.top = '';
                        this.node.getParent().layout();
                        this.node.getParent().updateSize();
                    }

                }
                break;
            }
*/
        },

        cloneNode: function (node, parent, reference) {
            var i,
                clone;

            clone = node.clone();
            parent.insertChild(clone, reference);
            if (clone.layout) {
                clone.layout(1);
            }

//            clone = parent.insertChild(node.config, reference);

            //if (!(this.node instanceof swv6.ui.SpacePlannerSpaceNode)) {
                clone.setPosition(node.getX(), node.getY());
            //}

//            for (i=0; i<node.getChildCount(); i++) {
//                this.cloneNode(node.getChild(i), clone);
//            }

            return clone;
        },

        evtToSceenCoords: function (evt) {
            return this.camera.getPosition().fromViewportToScene(evt.clientX, evt.clientY);
        }

    });

}());
