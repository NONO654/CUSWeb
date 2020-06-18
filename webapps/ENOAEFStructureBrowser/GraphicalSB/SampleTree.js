/*jslint sloppy:true, plusplus:true */

var swv6 = swv6 || {};
swv6.ui = swv6.ui || {};

var LBMODE = 0;

(function() {
	/**
	 * @class swv6.ui.SampleTree
	 * @extends swv6.ui.HybridVisualTree A sample visual tree
	 */
	'use strict';
	var CLASS, BASE = swv6.ui.HybridVisualTree;

	CLASS = swv6.ui.SampleTree = function(config) {
		CLASS.base.ctor.call(this, config);
	};

	swv6.util.inherit(CLASS, BASE, {

		nodeCtor : function(config) {
			return new swv6.ui.SampleNode(config);
		}

	});

}());

(function() {
	/**
	 * @class swv6.ui.SampleNode
	 * @extends swv6.ui.HybridVisualNode A sample visual node
	 */
	'use strict';
	var CLASS, BASE = swv6.ui.HybridVisualNode;

	CLASS = swv6.ui.SampleNode = function(config) {
		var txt, img;
		CLASS.base.ctor.call(this, config);

		if (config) {
		var cols = emxUICore.selectNodes(config.data.data, "c");
		var expandImgURL = "../common/images/utilGridNodeClose.png";
		var collapseImgURL = "../common/images/utilGridNodeOpen.png";
		var imgURL;
		var expandStatus = config.data.data.getAttribute("display");
		var oid = config.data.data.getAttribute("o");
		var hasChildren = true;

		if (expandStatus == "block") {
			imgURL = expandImgURL;
			var children = emxUICore.selectNodes(config.data.data, "r");
			if (children.length == 0) {
				hasChildren = false;
			}
		} else {
			imgURL = collapseImgURL;
			this.setExpanded(false);
		}
		var imgSrc = "../common/images/icon48x48ImageNotFound.gif";
		if (cols[cols.length - 1].firstChild != null) {
			imgSrc = cols[cols.length - 1].firstChild.getAttribute("src");
		}
	    if(tnTextColumns == null)
	        tnTextColumns = getTextColumnsThumbnail();

		drawThumbnailTileText(config.data.data, this.body.el);
		drawThumbnailTileImage(config.data.data, this.body.el.firstChild);
		var expandImg = new swv6.html.Element({
			tag : 'img',
			attr : {
				src : imgURL,
				class : 'tree-expanded'
			},
			parent : this.body.el
		});
		expandImg.sub('onclick', this, function() {
			var addRow = function(node, row) {
				var childRows = emxUICore.selectNodes(row, "r");
				for (var i = 0; i < childRows.length; i++) {
					var newNode = node.addChild(
												{
													data : {
														data : childRows[i]
													}
												}
												);
					addRow(newNode, childRows[i]);
				}
			};
			var expandStatus = config.data.data.getAttribute("display");
			var alreadyExpanded = config.data.data.getAttribute("expand");
			if (!alreadyExpanded) {
				var id = config.data.data.getAttribute("id");
				var row = toggle3(id);
				var childRows = emxUICore.selectNodes(row, "//r");
				var imageIds = [];
				for (i = 0; i < childRows.length; i++) {
					imageIds.push(childRows[i].getAttribute("id"));
				}
				var imageMap = new Object();
				if (imageIds.length > 0) {
					var responseXML = emxUICore.getXMLDataPost(
							"../common/emxFreezePaneGetData.jsp", getParams()
									+ "&rowIds=" + imageIds.join(":")
									+ "&sbImages=ImageOnly");
					var allrows = emxUICore.selectNodes(responseXML,
							"/mxRoot/rows//r");
					for (i = 0; i < allrows.length; i++) {
						var colNode = emxUICore.selectSingleNode(allrows[i],
								"c");
						imageMap[allrows[i].getAttribute("id")] = colNode;
					}
				}

				for (i = 0; i < childRows.length; i++) {
					childRows[i].appendChild(imageMap[childRows[i].getAttribute("id")]);
				}

				addRow(this, row);
				config.data.data.setAttribute("display", "none");
			}

			var expandAction;
			if (expandStatus == "block") {
				expandAction = "Collapse";
			} else {
				expandAction = "Expand";
			}
			(new swv6.ui.Action.Expand({
				type : expandAction,
				state : window.controller.state,
				node : this
			})).run();
		});

		if (!hasChildren) {
			expandImg.el.style.visibility = "hidden";
		}
		this.sub('expandedChanged', this, function() {
			var expandStatus = config.data.data.getAttribute("display");
			var isExpanded = config.data.data.getAttribute("expand");
			var id = config.data.data.getAttribute("id");
			if (expandStatus == "block") {
				expandImg.el.src = collapseImgURL;
				config.data.data.setAttribute("display", "none");
			} else {
				expandImg.el.src = expandImgURL;
				config.data.data.setAttribute("display", "block");
			}
		});
		this.sub('selected', this, function() {
			alert("hemant");
		});
		}

	};

	swv6.util.inherit(CLASS, BASE, {

	});

}());

(function() {
	/**
	 * @class swv6.ui.SampleSVGTree
	 * @extends swv6.ui.SVGVisualTree A sample visual tree
	 */
	'use strict';
	var CLASS, BASE = swv6.ui.SVGVisualTree;

	CLASS = swv6.ui.SampleSVGTree = function(config) {
		CLASS.base.ctor.call(this, config);
	};

	swv6.util.inherit(CLASS, BASE, {

		nodeCtor : function(config) {
			return new swv6.ui.SampleSVGNode(config);
		}

	});

}());

(function() {
	/**
	 * @class swv6.ui.SampleSVGNode
	 * @extends swv6.ui.SVGVisualNode A sample visual node
	 */
	'use strict';
	var CLASS, BASE = swv6.ui.SVGVisualNode;

	CLASS = swv6.ui.SampleSVGNode = function(config) {
		var h = this.getHeight(), w = this.getWidth(), m = 1; // margin to
																// account for
																// border stroke
																// width

		CLASS.base.ctor.call(this, config);

		this.body.addChild(new swv6.svg.Rect({
			cls : 'bg',
			x : m,
			y : m,
			width : w - m * 2,
			height : h - m * 2,
			rx : 1,
			ry : 1
		}));
		this.body.addChild(new swv6.svg.Text({
			text : config.data.data.text,
			cls : 'text',
			x : w / 2,
			y : h - 10,
			width : w,
			height : h
		}));

	};

	swv6.util.inherit(CLASS, BASE, {
		width : 90,
		height : 30

	});

}());
