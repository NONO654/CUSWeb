define('DS/ENOLifecycleTreeView/ENOLifecycleTreeView',
		[
			'UWA/Core', 
			'UWA/Controls/Abstract',
			'UWA/Element', 
			'DS/etree/tree',
			'DS/etree/widget',
			'WebappsUtils/WebappsUtils',
			'DS/egraph/iact',
			'DS/egraph/overview',
			'DS/egraph/utils'
		 ], 
function(UWA, Abstract, Element, etree, etreewidget,WebappsUtils,iact,overview, utils) {
	
	'use strict';
	var treeView=Abstract.extend({
		NodeView: null,
		treeData:{},
		container:null,
		siblingPadding:30,
		rowPadding:30,
		widget:null,
		setCustomNodeData:null,
		minimapContainer:null,
        events: [
            'showMinimap',
            'hideMinimap'
		],

		init:function(options){

			/*
				options={
					NodeView: Use the ENOLifecyleNodeViewCreator to create node view
					container: DOM element containing the tree
					siblingPadding: padding between columns
					rowPadding:padding between rows
					nodeWidth: Width of Node
					nodeHeight: Height of Node
					minimapContainer: The container of the minimap
				}
			*/
			var that=this;

			this.minimapContainer=options.minimapContainer;
			this._parent(options);

			
			this.widget = new etreewidget.EGraphTree(this.options.container, {
		    	
	            nodeWidth: this.options.nodeWidth,
	            nodeHeight: this.options.nodeHeight,
	            rowPadding: this.options.rowPadding,
	            siblingPadding: this.options.siblingPadding,
	            nodeViewCtor: this.options.NodeView,
	            drawing: etree.Drawing.BRANCHED,
	            movePredicate: function alwaysfalse() {
		            // node dragging for BRANCHED_2 is not supported,
		            // deactivate it
		            return false;
		        }

	        });

			var minimapInnerHTML = [
							//'<div class="minimap-container-div"',
								'<div class="minimap">',
	                            '</div>',
                                '<div class="minimap-close">',
                                    '<span class="fonticon fonticon-cancel" style="font-size:22px"></span>',
	                            '</div>',
								'<div class="minimap-toolbar">',
	                                '<div class="minimap-icon zoomin"><img src="../ENOLifecycleTreeView/assets/icons/ENOLifecycleMinimapTreeViewZoomIn.png"></div>',
	                                '<div class="minimap-icon zoomout"><img src="../ENOLifecycleTreeView/assets/icons/ENOLifecycleMinimapTreeViewZoomOut.png"></div>',
	                                '<div class="minimap-icon zoomtofit"><img src="../ENOLifecycleTreeView/assets/icons/ENOLifecycleMinimapTreeViewZoomToFit.png"></div>',
	                           	'</div>',
                           //'</div>',
                           ].join('\n');

            this.minimapContainer.setHTML(minimapInnerHTML);
             this.minimapContainer.addClassName('minimap-panel');

            var minimap=this.minimapContainer.getElement('.minimap');
            minimap.setStyle("min-width",
            	this.minimapContainer.clientWidth-this.minimapContainer.getElement('.minimap-toolbar').clientWidth + 'px');
            minimap.setStyle("max-width",
            	this.minimapContainer.clientWidth-this.minimapContainer.getElement('.minimap-toolbar').clientWidth + 'px');
      		this.widget.document.addView2('minimap', new overview.GraphView(minimap, this.widget.document.gr.views.main,
				{
					width: (minimap.clientWidth),
					height: minimap.clientHeight,
					hole:{
						className:"marquee",
					},
					background:"#ffffff",
					nodeFill:"#797979",
					maxScale:0.2
				}), {
				// use a factory that always returns true so that 
				// each node is visible in the overview
				newNodeView: function nnv(node) { return true; }
			});

      		minimap.setStyle('min-width', (minimap.clientWidth-2) + 'px');
      		minimap.setStyle('max-width', (minimap.clientWidth-2) + 'px');
			  // add a state machine to handle interactions with the overview
  			var sm=new iact.StateMachine(this.widget.document.gr, null, 
  				new overview.RootState(), this.widget.document.gr.views.minimap);

			// make sure the main view size follows the size of the window 
			// (the main view occupy the whole window area so it is resized 
			// when the window is resized)
			
			var gr=this.widget.document.gr;
			
			window.addEventListener('resize', function resized() {
				// tell the main view to get the actual size of the DOM 
				// Element; not optimal but only happens at window resize
				gr.views.main.setSize();
			});
			
			this.options.container.addEventListener('resize', function resized() {
				// tell the main view to get the actual size of the DOM 
				// Element; not optimal but only happens at window resize
				gr.views.main.setSize();
			});
			
			this.minimapContainer.getElement(".zoomin").addEvents({
				click:function(evt)
				{
					that.zoom(1);		
				}
			});

			this.minimapContainer.getElement(".zoomout").addEvents({
				click:function(evt)
				{
					that.zoom(-1);		
				}
			});

			this.minimapContainer.getElement(".zoomtofit").addEvents({
			    click: function (evt) {
			        that.reframeAll();
			    }
			});

			this.minimapContainer.getElement(".minimap-close").addEvents({
			    click: function (evt) {
			        UWA.Event.dispatchEvent(widget.body.getElement('.menuHideMinimap'), "click");
			    }
			});
		},

		loadTree:function(treeData)
		{
			// This function can also accept tree data
			var that = this;
			if (treeData)
			{
				this.treeData=treeData;
			}

			that.widget.document.withLockedUpdate(function buildtree() {

				that.widget.document.clear();
			 	var nodeArray=[];

			 	//Create all the nodes and pass the node data
			 	for (var i=0;i<treeData.nodes.length;i++)
			 	{
			 		nodeArray[i]=new etree.Node({nodeData:treeData.nodes[i]});
			 	}
			 	//Append the first node to the root document
			 	that.widget.document.appendChild(nodeArray[0]);

			 	//Connect the remaining nodes
			 	for (var j=0;j<treeData.connections.length;j++)
			 	{
			 		var cnx=treeData.connections[j];
			 		nodeArray[cnx.src-1].appendChild(nodeArray[cnx.trg-1]);
			 	}

			 	 // expand the tree (by default a node is collapsed)
			    for (var c = that.widget.document.first; c; c = c.dftNext(that.widget.document)) {
			      c.setExpanded(true);
			    }

			    //Prevent animation of the initial expand of nodes
	    		that.widget.document.vetoUpdateAnimation();

			});

		},

		expandAll:function()
		{
			var that=this;

			that.widget.document.withLockedUpdate(function expandAll(){
				for (var c = that.widget.document.first; c; c = c.dftNext(that.widget.document)) 
				{
		      		c.setExpanded(true);
		    	}
			});
		},

		collapseAll:function()
		{
			var that=this;

			that.widget.document.withLockedUpdate(function collapseAll(){
				for (var c = that.widget.document.first; c; c = c.dftNext(that.widget.document)) 
				{
		      		c.setExpanded(false);
		    	}
			});
		},

		reframeAll:function() 
		{
	        // reframe the main view of the graph to fill the available space
	        var doc=this.widget.document;
	        doc.gr.views.main.setViewpoint(
	            utils.reframeViewpoint(
	               doc.gr.views.main.getSize(),
	                doc.getBounds(), // use the bounds of all nodes already computed by last update
	                {
	                    padding: 15,    // add a padding around the viewport
	                    maxScale: 1,    // don't zoom above 1, if enough space
	                                    // available simply recenter the nodes
	                    minScale: 0.25, // don't zoom out too much
	                    aliasing: 0,    // make sure at zoom 1 the nodes won't
	                                    // be blurred
	                    vertical: -1,    // put the root node at top of the
	                                    // viewport if enough space
	                    defaultVpt: doc.gr.views.main.vpt
	                }));
		},

		zoom:function(inc)
		{
			this.widget.document.gr.views.main.zoominc(inc);
		},

		showMinimap: function () {

		    this.minimapContainer.show();

		    if (typeof (Storage) !== "undefined")
		        localStorage.showMinimap = "yes";
		},

		hideMinimap: function () {

		    this.minimapContainer.hide();
		    if (typeof (Storage) !== "undefined")
		        localStorage.showMinimap = "no";
		    document.dispatchEvent(new Event("hideMinimap"));
		},

		verticallyAlign: function (leavesOnTop) {

		    var doc = this.widget.document;
		    var dontFlip = false;
		    var newModifiers;

		    if (leavesOnTop) {

		        dontFlip = doc.drawingModifiers & etree.DrawingModifiers.MIRROR_DEPTH;
		        newModifiers = doc.drawingModifiers | etree.DrawingModifiers.MIRROR_DEPTH
		    }
		    else {
		        dontFlip = !(doc.drawingModifiers & etree.DrawingModifiers.MIRROR_DEPTH);
		        newModifiers = doc.drawingModifiers & ~etree.DrawingModifiers.MIRROR_DEPTH
		    }
		    if (!dontFlip) {
		        doc.withLockedUpdate(function changedrawingmodifier() {
		            doc.setDrawing(undefined, newModifiers);
		        });
		        this.reframeAll();
		    }
		},

	});

	return treeView;
});
