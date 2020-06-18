
define('DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptExplorerWidget',
	[
		'UWA/Core', 
		'UWA/Controls/Abstract',
		'UWA/Element', 
		'DS/ENOLifecycleTreeView/ENOLifecycleTreeView',
		'DS/ENOLifecycleTreeView/ENOLifecyleNodeEdgeViewCreator',
		'DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptAndHistoryExplorerNodeEdgeViews',
		'DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptExplorerMainController',
		'DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptExplorerNodeUIController',
		//'DS/UIKIT/Alert'
	],
	function(Core, Abstract, Element,
		EnoviaLifecycleTreeView,creator,CENodeEdgeViews,ENOLifeCycleConceptExplorerMainController,
		ENOLifecycleConceptExplorerNodeUIController/*, Alert*/)
	{
		'use strict';

		var CEWidget=Abstract.extend({
			
			CETreeView:null,
			widget:null,
			alert:null,
	
			init:function(widget, options)
			{
				var that=this;

				this.widget=widget;

				this._parent(options);

				this._localize();
				
				this._buildSkeleton();

				var nodeTemplate=new CENodeEdgeViews.NodeTemplate();
				this.treeOptions={
					NodeView: creator.ENOLifecyleNodeViewCreator(
						{
							node_elem: nodeTemplate.element,
							onSetNodeData: nodeTemplate.onSetNodeData
						}
					),
					container: that.elements.container.getElement(".viewport"),
					siblingPadding:30,
					rowPadding:20,
					nodeWidth:nodeTemplate.width(),
					nodeHeight:nodeTemplate.height(),
					minimapContainer:that.elements.container.getElement(".minimap-container")
				};

				this.NodeUIController=new ENOLifecycleConceptExplorerNodeUIController({widget:that.widget,multiSelectNodes:false});
				this.CETreeView=new EnoviaLifecycleTreeView(this.treeOptions);
				

				this.MainController=new ENOLifeCycleConceptExplorerMainController({
					CETree:that.CETreeView,
					CENodeUIController:this.NodeUIController,
					widget:that.widget,
					iconPath:this.options.iconPath
				});

				//making the MainController accessible for C++
				this.widget.MainController=this.MainController;
				this._attachHeaderCommandHandlers();

				if (typeof (Storage) !== "undefined") {
				    if (localStorage.showMinimap == "yes") {
				        UWA.Event.dispatchEvent(this.widget.body.getElement('.menuShowMinimap'), "click");
				    }
				    else {
				        UWA.Event.dispatchEvent(this.widget.body.getElement('.menuHideMinimap'), "click");
				    }
				    if (localStorage.mapAlignment == "latestAtBottom") {
				        UWA.Event.dispatchEvent(this.widget.body.getElement('.menuLatestAtBottom'), "click");
				    }
				    else {
				        UWA.Event.dispatchEvent(this.widget.body.getElement('.menuLatestOnTop'), "click");
				    }
				} else {
				    UWA.Event.dispatchEvent(this.widget.body.getElement('.menuHideMinimap'), "click");
				    UWA.Event.dispatchEvent(this.widget.body.getElement('.menuLatestOnTop'), "click");
				}
			},

			_buildSkeleton:function()
			{
				var that=this;
				/*var headerContent=[
					'<span class="fonticon fonticon-home header-buttons menuHome" title="Home"></span>',
	            	'<span class="fonticon fonticon-arrows-ccw header-buttons menuRefresh" title="Refresh"></span>',
	            	'<img width="20" height="20" alt="" src="./assets/icons/SWXUiTreeViewZoomControlRules.png" title="" />',
	            	'<span class="fonticon fonticon-2x fonticon-plus-squared header-buttons menuExpandAll" title="Expand All"></span>',
	            	'<span class="fonticon fonticon-2x fonticon-minus-squared header-buttons menuCollapseAll" title="Collapse All"></span>',
				].join('\n');
				this.widget.elements.header.empty(true);
				this.widget.elements.header.setHTML(headerContent);*/
				var globalDivHtml=[
				'<div class="headerContent">',
					// '<span class="fonticon fonticon-home header-buttons menuHome" title="Home"></span>',
	    //         	'<span class="fonticon fonticon-arrows-ccw header-buttons menuRefresh" title="Refresh"></span>',
	    //         	'<img width="20" height="20" alt="" src="./assets/icons/SWXUiTreeViewZoomControlRules.png" title="" />',
	    //         	'<span class="fonticon fonticon-2x fonticon-plus-squared header-buttons menuExpandAll" title="Expand All"></span>',
	    //         	'<span class="fonticon fonticon-2x fonticon-minus-squared header-buttons menuCollapseAll" title="Collapse All"></span>',
	    //         	'<span class="fonticon fonticon-2x fonticon-down-open header-buttons menuShowMinimap" title="Show Minimap"></span>',
	    //         	'<span class="fonticon fonticon-2x fonticon-up-open header-buttons menuHideMinimap" title="Hide Minimap"></span>',
	    			'<div class="header-buttons menuHome" title="Home"><img src="./assets/icons/ENOLifecycleConceptExplorerHome.png"/></div>',
	            	'<div class="header-buttons menuRefresh" title="Refresh" style="margin-right:0"><img src="./assets/icons/ENOLifecycleConceptExplorerRefresh.png"/></div>',
	            	'<img width="20" height="20" alt="" src="./assets/icons/SWXUiTreeViewZoomControlRules.png"/>',
	            	'<div class="header-buttons menuExpandAll" title="Expand All" style="display:none;"><img src="./assets/icons/ENOLifecycleConceptExplorerExpandAll.png"/></div>',
	            	'<div class="header-buttons menuCollapseAll" title="Collapse All" style="display:none;"><img src="./assets/icons/ENOLifecycleConceptExplorerCollapseAll.png"/></div>',
	            	'<div class="header-buttons menuShowMinimap" title="Show Minimap"><img src="./assets/icons/ENOLifecycleConceptExplorerMinimap.png"/></div>',
	            	'<div class="header-buttons menuHideMinimap" title="Hide Minimap"><img src="./assets/icons/ENOLifecycleConceptExplorerMinimap.png" style="border:1px gray #b7b7b7;"/></div>',
                    '<div class="header-buttons menuLatestOnTop" title="Newest at top"><img src="./assets/icons/SWXUIMapViewCurrentTop.png"/></div>',
                    '<div class="header-buttons menuLatestAtBottom" title="Newest at Bottom"><img src="./assets/icons/SWXUIMapViewCurrentBottom.png"/></div>',
            	'</div>',
            	
            	'<div class="viewport-container">',

            		'<div class="viewport">',
            			
            			'<div class="minimap-container">',
            			'</div>',
            		
            		'</div>',

            		'<div class="properties-panel">',
            		'</div>',

            	'</div>',

            	'<div class="create-concept-point-button-div">',
            		
            		'<div class="title-div">',
            		'</div>',
            		'<div class="spacer-div">',
            		'</div>',
            		'<div class="text-div">',
            		'</div>',
            		'<div class="button-div-create-concept-point">',
            			'<button>',
            				'<img src="./assets/icons/ENOLifecycleCreateConceptPoint.png"/>',
            			'</button>',
            		'</div>',

            	'</div>',

	            '<div class="blank-div">',

					'<div class="blank-div-inner">',	            		
	            		
	            		'<div class="spacer-div">',
	            		'</div>',

	            		'<div class="alert-div">',
		            		'<div class="text-spacer-div" style="float:left;">',
		            		'</div>',
		            		'<div class="text-div">',
		           			'</div>',
		            		'<div class="text-spacer-div" style="float:right;">',
		            		'</div>',
	            		'</div>',

	            	'</div>',

            	'</div>',
            	
            	'<div class="modal modal-root display-alert">',
	            	'<div class="modal-wrap display-alert-wrap">',
		            	'<div class="modal-content display-alert-content">',

		            	   	'<div class="modal-body display-alert-body">',
		            	   		'<p></p>',
			            	'</div>',

			            	'<div class="modal-footer alert-div-buttons">',
			            		'<button type="button" class="btn-primary btn btn-root alert-ok"></button>',
			            	'</div>',
		            	'</div>',
	            	'</div>',
            	'</div>',


            	
				].join('\n');
				
				var globalDiv = this.elements.container = UWA.createElement('div', {
				    'class': 'global-div',
				    html: globalDivHtml,
				    events: {

				        contextmenu: function (event) {
				            UWA.Event.stop(event);
				        }
				    }
				});

				//hide the no map div to start with
				this.elements.container.getElement('.create-concept-point-button-div').hide();
				this.widget.elements.edit.destroy();
				this.widget.elements.header.destroy();
				this.widget.elements.footer.destroy();
				this.inject(this.widget.body.empty(true));
				
			},

			_attachHeaderCommandHandlers:function()
			{
				var that=this;

				//Refresh Command Handler
				this.widget.body.getElement('.menuRefresh').addEvents({
					click:function(evt){
						that.MainController.invokeCommand([0],102);
					}
				});

				this.widget.body.getElement('.menuHome').addEvents({
					click:function(evt){
						that.CETreeView.reframeAll();
					}
				});

				this.widget.body.getElement('.menuExpandAll').addEvents({
					click:function(evt){
						that.MainController.expandAll();
					}
				});

				this.widget.body.getElement('.menuCollapseAll').addEvents({
					click:function(evt){
						that.MainController.collapseAll();	
					}
				});

				this.widget.body.getElement('.menuShowMinimap').addEvents({
				    click: function (evt) {

					    that.CETreeView.showMinimap();
						UWA.extendElement(this).hide();
						that.widget.body.getElement(".menuHideMinimap").show();
					}
				});

				this.widget.body.getElement('.menuHideMinimap').addEvents({
				    click: function (evt) {

					    that.CETreeView.hideMinimap();
						UWA.extendElement(this).hide();
						that.widget.body.getElement(".menuShowMinimap").show();
					}
				});

				this.widget.body.getElement('.menuLatestAtBottom').addEvents({
				    click: function (evt) {

				        if (that.CETreeView) {
				            that.CETreeView.verticallyAlign(false);
				            UWA.extendElement(this).addClassName('button-clicked');
				            that.widget.body.getElement('.menuLatestOnTop').removeClassName('button-clicked');
				            if (typeof (Storage) !== "undefined") {
				                localStorage.mapAlignment = "latestAtBottom";
				            }
				        }
				    }
				});

				this.widget.body.getElement('.menuLatestOnTop').addEvents({
				    click: function (evt) {

				        if (that.CETreeView) {
				            that.CETreeView.verticallyAlign(true);
				            UWA.extendElement(this).addClassName('button-clicked');
				            that.widget.body.getElement('.menuLatestAtBottom').removeClassName('button-clicked');
				            if (typeof (Storage) !== "undefined") {
				                localStorage.mapAlignment = "latestOnTop";
				            }
				        }
				    }
				});


				//function to remove all selections when the viewport is clicked
				this.widget.body.getElement('.viewport').addEvents({
					click:function(evt){
						
						if (!(UWA.extendElement(evt.target).hasClassName('.eno-lifecycle-node')
							|| UWA.extendElement(evt.target).getParent('.eno-lifecycle-node')))

							that.MainController.clearNodeSelections();

							//Destroying any open context menus
							var cmenu=UWA.extendElement(document.body).getElements('.dropdown.context-menu-div');
							if(cmenu.length)
							{
								for (var i=0;i<cmenu.length;i++)
									cmenu[i].destroy();
							}

					}
				});

				//Create concept point button from the no concept points view button
				this.widget.body.
				getElement('.create-concept-point-button-div .button-div-create-concept-point button')
				.addEvents({
					click:function(evt){
						that.MainController.invokeCommand([0],5);
					}
				});

				document.addEventListener("hideMinimap", function (evt) {
				    UWA.extendElement(this).hide();
				    that.widget.body.getElement(".menuShowMinimap").show();
				}, false);
			},

			_localize: function () {
			    /*****Data localize**/
			    var language = navigator.systemLanguage || navigator.browserLanguage || navigator.userLanguage || navigator.language,
				      		path = "./assets/nls", name, value;
			    if (language.length > 2) {
			        language = language.substring(0, 2);
			    }

			    //language ='de';
			   /* switch (language) {
			        case 'en':
			            path += 'en-us';
			            break;
			        case 'fr':
			            path += 'fr-fr';
			            break;
			        case 'zh':
			            path += 'zh-cn';
			            break;
			        case 'de':
			            path += 'de-de';
			            break;
			        case 'ja':
			            path += 'ja-jp';
			            break;
			        default:
			            path += 'en-us';
			            language = 'en';
			            break;
			    }*/

			    function load_json(src) {
			        var head = document.getElementsByTagName('head')[0];

			        //use class, as we can't reference by id
			        var element = head.getElementsByClassName("json")[0];

			        try {
			            element.parentNode.removeChild(element);
			        } catch (e) {
			        }

			        var script = document.createElement('script');
			        script.type = 'text/javascript';
			        script.src = src;
			        script.className = "json";
			        script.async = false;
			        head.appendChild(script);
			    }

			    load_json(path + "/" + "ENOLifeCycleConceptExplorerUIText_" + language + ".js");
			}

		});

		return CEWidget;

	});
