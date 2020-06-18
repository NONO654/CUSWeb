define('DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptAndHistoryExplorerNodeEdgeViews',
	[
		'UWA/Core', 
		'UWA/Element', 
		'DS/UIKIT/Mask'
	],
	function(UWA,Element
		,Mask){
		
		'use strict';

		var views={};
		
		views.NodeTemplate=function(options){

				/*
				options{
					node_context_menu_button:true/false
					node_ui_controller
				}
				*/
			    var elem = [
					'<div class="eno-lifecycle-node">',
					' <div class="node-content">',
					'  <div class="image-div">',
					'	<img/>',
					'	<div class="comment-icon">',
					'		<span class="fonticon fonticon-2x fonticon-comment"></span>',
					'	</div>',
					'  </div>',
					'  <div class="node-label">',
					'   <div class="node-text">',
					'   </div>',
					'   <div class="node-button">',
					'		<span class="fonticon fonticon-2x fonticon-down-open-mini"></span>',
					'   </div>',
					'  </div>',
					' </div>',
					'</div>',
			    ].join('\n');

			    

			  	var templateDiv=document.body.querySelector('div.eno-lifecycle-templates');
			  	if (!templateDiv)
			  	{
			  		UWA.createElement('div',{
			  			'class':'eno-lifecycle-templates'
			  		}).inject(UWA.extend(document.body));
			  		var templateDiv=document.body.querySelector('div.eno-lifecycle-templates');
			  	}

			  	if(!templateDiv.querySelector('div.eno-lifecycle-node'))
			  	{
			  		templateDiv.innerHTML=elem;
			  		elem=templateDiv.querySelector('div.eno-lifecycle-node')
			  	}

			    //remove context menu button if option.node_context_menu_button is false
			    if(options && options.node_context_menu_button===false)
			    {
			    	 var button=elem.querySelector('div.node-button');
			    	 if (button)
			    	 {
			    	 	button.parentElement.remove(button);
			    	 }
			    }
			    else
			    {
			    	elem.querySelector('div.node-text').style.paddingRight='30px';
			    }

			    //retriving the actual DOM element from jQuery
			    this.element=elem.cloneNode(true);

			//Node Controller
			this.onSetNodeData=function(data)
			{
				var ele=UWA.extendElement(this);
				ele.getElement("div.node-text").setHTML(data.name);
                ele.getElement("div.image-div img").setAttributes({
                	src: data.imageurl
                });
                
                if(data.comments.length)
                {
                	ele.getElement(".comment-icon").show();
                }
                else
                {
                	ele.getElement(".comment-icon").hide();	
                }
                
                if (data.type=="leaf")
                {
                	ele.addClassName('leaf');
                	ele.getElement(".node-content").addClassName("leaf-node");
                }
                else
                {
                	ele.addClassName('node');
                }

                ele.setAttributes({
                	title:data.name
                });

            
                if (data.status === 'deleted') {
                    Mask.mask(ele, widget.localize ? widget.localize.deleted : "Deleted");
                    ele.getElement('.spinner').hide();
                    ele.isMasked = true;
                }
                else if (data.status === 'none' && ele.isMasked === true) {
                    Mask.unmask(ele);
                    ele.isMasked = false;
                }

                if (options && options.node_ui_controller)
                {
                	options.node_ui_controller.apply(this,data);
                }
                
			};

			this.width=function(){
				//Will have to return the proper width
				templateDiv.style.display="block";
				var w = elem.offsetWidth;
				templateDiv.style.display="none";
				return w;
			};

			this.height = function(){
				//Will have to return the proper width
				templateDiv.style.display="block";
				var h = elem.offsetHeight;
				templateDiv.style.display="none";
				return h;
			};
		}
	    return views;
	}
);
