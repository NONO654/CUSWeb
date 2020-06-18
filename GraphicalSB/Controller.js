/*jslint plusplus:true */
/*globals console*/

var swv6 = swv6 || {};
swv6.sample = swv6.sample || {};
swv6.sp = swv6.sp || {};


(function () {
	/**
	 * @class swv6.sample.Controller
	 * @extends swv6.ui.Controller
	 * The Space Planner Controller.
	 */
	'use strict';
	var CLASS,
	BASE = swv6.ui.Controller;

	CLASS =
		swv6.sample.Controller =
			function (config) {
		var that = this,
		cm,
		cmHistoryBack,
		cmHistoryForward;

		CLASS.base.ctor.call(this, config);
		this.nodeDragManager = new swv6.sp.NodeDragManager({
			tree: this.dataTree,
			camera: this.camera
		});
		this.dataTree.sub('nodeAdded', this, function (tree, parent, node) {
			enableDragging(node.body.el.children[0].children[0]);
			enableDropping(node.body.el.children[0].children[0]);
		});
	};

	swv6.util.inherit(CLASS, BASE, {
		isRightClick: function (evt) {
			var rightClick;

			if (!evt) {
				evt = window.event;
			}

			if (evt.which) {
				rightClick = (evt.which === 3);
			} else if (evt.button) {
				rightClick = (evt.button === 2);
			}

			return rightClick;
		},

		startNodeDrag: function (element, evt, node) {
			console.log("startNodeDrag : Controller");
			if (!this.isRightClick(evt)) {
				//            this.nodeDragManager.mode = 'node';
				this.nodeDragManager.startNodeDrag(element, evt, node);

				this.burst(evt);
				this.thwart(evt);
			}

		},

		getAction: function (touches) {
			var action;

			switch (touches) {
			case 0:
				break;
			case 1:
				action = new swv6.sp.PanAction({
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
//			this.thwart(evt);

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
			if (!this.nodeDragManager.dragging) {
				if (this.action) {
					this.action.end();
				}

				this.action = this.getAction(evt.touches.length);
				if (this.action) {
					this.action.start(evt);
				}

				this.burst(evt);
//				this.thwart(evt);
			}
		},

		handleNodeContextMenu: function (node, evt) {
			CLASS.base.handleNodeContextMenu.apply(this, arguments);

			this.createNodeContextMenu(node, evt);
		},

		handleContextMenu: function (el, evt) {
			CLASS.base.handleContextMenu.apply(this, arguments);

			this.cm.show(evt.clientX, evt.clientY);
		},

		createNodeContextMenu: function (node, evt) {
			var RMBMenu = getParameter("appendRMBMenu");
			clickRight(evt, RMBMenu, node);
		}


	});

}());

(function () {
	/**
	 * @class swv6.sp.Action
	 * @extends swv6.util.Publisher
	 * TODO
	 */
	'use strict';
	var CLASS,
	BASE = swv6.util.Publisher;

	CLASS =
		swv6.sp.Action =
			function (config) {
		CLASS.base.ctor.call(this, config);

	};

	swv6.util.inherit(CLASS, BASE, {

		start: function (evt) {
		},

		update: function (evt) {
		},

		end: function (evt) {
		},

		getPointFromEvent: function () {
		},

		getEventPoints : function (pts) {
			var i, pt, p,
			results = [];

			for (i=0; i<pts.length; pts++) {
				pt = pts[i];
				p = this.svg.el.createSVGPoint();

				p.x = pt.x - this.camera.viewport.offsetLeft;
				p.y = pt.y - this.camera.viewport.offsetTop;

				results.push(p);
			}

			return results;
		},

		/*
        getScreenPoints: function (pts) {
            var i, pt, p,
                results = [],
                box = this.svg.el.getBoundingClientRect();

            for (i=0; i<pts.length; pts++) {
                pt = pts[i];
                p = this.svg.el.createSVGPoint();

                p.x = pt.x - box.left;
                p.y = pt.y - box.top;

                results.push(p);
            }

            return results;
        },
		 */
		getTouches: function (evt) {
			var i, pts = [];

			for (i=0; i<evt.touches.length; i++) {
				pts.push(
						new swv6.sp.Point({
							x: evt.touches[i].clientX,
							y: evt.touches[i].clientY
						})
				);
			}
			return pts;
		},

		setCamera: function (zoom, x, y) {

			this.camera.zoom(zoom, x, y, false, false);
			/*
            var that = this,
                currentZoom,
                currentPt,
                tmp;



            this.cameraProperties = {
                x: x,
                y: y,
                zoom: zoom
            };

            if (!this.inZoom) {
                tmp = this.svg.el.suspendRedraw(1000);
                this.inZoom = true;
                this.camera.zoom(zoom, x, y);
                this.svg.el.unsuspendRedraw(tmp);
                window.requestAnimationFrame(function () {
                    that.inZoom = false;

                    if ((zoom !== that.cameraProperties.zoom) ||
                            (x !== that.cameraProperties.x) ||
                            (y !== that.cameraProperties.y)) {

                        that.setCamera(that.cameraProperties.zoom, that.cameraProperties.x, that.cameraProperties.y);
                    }
                }, 100);
            }
			 */
		}

	});

}());

(function () {
	/**
	 * @class swv6.sp.PanAction
	 * @extends swv6.sp.Action
	 * TODO
	 */
	'use strict';
	var CLASS,
	BASE = swv6.sp.Action;

	CLASS =
		swv6.sp.PanAction =
			function (config) {
		CLASS.base.ctor.call(this, config);

		this.svg = config.svg;
		this.camera = config.camera;
	};

	swv6.util.inherit(CLASS, BASE, {

		svg: undefined,
		camera: undefined,

		startPt: undefined,
		startCenter: undefined,
		startDiff: undefined,

		start: function (evt) {
			this.setStartPoint(this.getTouches(evt)[0]);
		},

		update: function (evt) {
			this.setCurrentPoint(this.getTouches(evt)[0]);
		},

		setStartPoint: function (point) {
			this.startPt = point;
			this.startCenter = (new swv6.sp.Point( this.camera.getCenter() )).scale(this.camera.getCurrentZoom());
			this.startDiff = this.startPt.difference(this.startCenter);
		},

		setCurrentPoint: function (point) {
			var diff = point.difference(this.startPt),
			center = this.startCenter.difference(diff).scale(1/this.camera.getCurrentZoom());

			this.camera.setCenter(center.x, center.y, false);

		}

	});

}());

(function () {
	/**
	 * @class swv6.sp.ZoomAction
	 * @extends swv6.sp.Action
	 * TODO
	 */
	'use strict';
	var CLASS,
	BASE = swv6.sp.Action;

	CLASS =
		swv6.sp.ZoomAction =
			function (config) {
		CLASS.base.ctor.call(this, config);

		this.svg = config.svg;
		this.camera = config.camera;
	};

	swv6.util.inherit(CLASS, BASE, {

		startPts: undefined,
		startDistance: undefined,
		startZoom: undefined,

		start: function (evt) {
			var i;

			this.startPts = this.getTouches(evt);
			this.startDistance = this.startPts[0].distance(this.startPts[1]);

			this.startZoom = this.camera.getCurrentZoom();
		},

		update: function (evt) {
			var touches = this.getTouches(evt),
			distance = touches[0].distance(touches[1]),
			scale = distance / this.startDistance,
			center = new swv6.sp.Point({
				x: (touches[0].x + touches[1].x) / 2,
				y: (touches[0].y + touches[1].y) / 2
			});

			center = this.getEventPoints([center])[0];

			this.setCamera(this.startZoom * scale, center.x, center.y);
		},

		end: function (evt) {
		}

	});

}());

(function () {
	/**
	 * @class swv6.sp.Point
	 * @extends swv6.util.Publisher
	 * TODO
	 */
//	'use strict';

	swv6.sp.Point = swv6.util.inherit({
		x: 0,
		y: 0,

		ctor: function (config) {
			this.x = config.x;
			this.y = config.y;
		},

		add: function (pt) {
			return new swv6.sp.Point({
				x: (this.x + pt.x),
				y: (this.y + pt.y)
			});
		},

		difference: function (pt) {
			return new swv6.sp.Point({
				x: (this.x - pt.x),
				y: (this.y - pt.y)
			});
		},

		scale: function (scalar) {
			return new swv6.sp.Point({
				x: (this.x * scalar),
				y: (this.y * scalar)
			});
		},

		distance: function (pt) {
			var dx = this.x - pt.x,
			dy = this.y - pt.y;
			return Math.sqrt(dx*dx + dy*dy);
		},

		toSVG: function (svg) {
			var pt = svg.createSVGPoint();

			pt.x = this.x;
			pt.y = this.y;

			return pt;
		},

		toScreenCoords: function (el) {
			var box = el.getBoundingClientRect();

			return new swv6.sp.Point({
				x: (this.x + box.left),
				y: (this.y + box.top)
			});
		},

		toLocalCoords: function (el) {
			var box = el.getBoundingClientRect();

			return new swv6.sp.Point({
				x: (this.x - box.left),
				y: (this.y - box.top)
			});
		}

	});

}());
