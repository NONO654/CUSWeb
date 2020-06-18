define('DS/ENOLifecycleConceptExplorer/ENOLifecycleConceptExplorerNodeContextMenu',
	[
		'UWA/Core', 
		'DS/UIKIT/Dropdown'
	],
	function(UWA, Dropdown){

		"use strict";
		
		var NodeContextMenu=function(nodeData)
		{
			
			var rmbmenuitems=nodeData.rmbmenuitems;
			var ctxMenu=document.createElement('div');
			var	ul=document.createElement('ul');
			ul.setAttribute('class','context-menu');
			
			ctxMenu.appendChild(ul);
			
			for(var i=0; i<rmbmenuitems.length;i++)
			{
				if (rmbmenuitems[i].id==0)
				{
					ul.appendChild(addSeparator());
				}
				    //terrible hack for displaying merge on the active product for 2016x. This is for SWX merge features only
				    // Will do it correctly for 2017x
				else if (!(rmbmenuitems[i].uniqueid && nodeData.active))
				{
					ul.appendChild(addMenuItem(rmbmenuitems[i],nodeData));
				}
			}
			
            //if the last item is a separator remove it
			if (ul.children[ul.children.length - 1].className.indexOf('separator') > -1) {
			    ul.removeChild(ul.children[ul.children.length - 1]);
			}
			
			var nodeDropdown = new Dropdown({
				    body: ctxMenu,
				    target: document.body,
				    className:'context-menu-div',
				    position: 'bottom right',
				    removeOnHide: true,
				    bound: false,
				    closeOnClick: true,
				    events: {
				        onClickOutside: function (e) {
				            var options = this.options,
                                target = UWA.Event.getElement(e);

				            if (target !== options.target) {
				                this.hide();
				            }
				        },
				    }
				});

			// nodeDropdown.options.altPosition={x:x, y:y};
			// nodeDropdown.updatePosition();

			nodeDropdown.hideAllMenus=function()
			{
				//A hack to make sure none of the menus are visible
				var allMenus=document.querySelectorAll("div.context-menu-div");
				if (allMenus)
				{
					for(var i=0;i<allMenus.length; i++)
						allMenus[i].style.display="none";
				}
			}

			function addSeparator()
			{
				//Create the new Line Item
				var el=document.createElement('li');
				el.setAttribute('class','context-menu-item separator');
				return el;
			}

			function addMenuItem(menuItem,nodeData)
			{
				//Create the new Line Item
				var el=document.createElement('li');
				el.setAttribute('class','context-menu-item');

				//create the button and add its content
				var button=document.createElement('button');
				
				//Set the icon
				if (menuItem.icon)
				{
					var icon=document.createElement('div');
					icon.setAttribute('class','icon');
					icon.innerHTML='<img src="' + menuItem.icon + '"/>';
					button.appendChild(icon);
				}
				else if(menuItem.fonticon)
				{
					var icon=document.createElement('div');
					icon.setAttribute('class','icon');
					icon.innerHTML='<span class="fonticon fonticon-2x fonticon-' + menuItem.fonticon + '"/>';
					button.appendChild(icon);
				}
				
				//set the text
				if (menuItem.text)
				{
					var text=document.createElement('div');
					if (menuItem.icon)text.setAttribute('class','content');
					else text.setAttribute('class','fonticon-content');
					text.innerHTML=menuItem.text;
					//Special sauce for comments
					// Display the number of comments with the menu
					if (menuItem.text=="Comments")
					{
						text.innerHTML+= " (" + nodeData.comments.length + ")";
					}
					//
					button.appendChild(text);
				}

				//Add the button to the line item
				el.appendChild(button);

				//Add the click handler as a closure function;
				button.onmousedown = (function(nID)
				{
					var nodeID=nID;

					return function(evt){
						menuItem.fn(nodeID);
						//default onclick closes the dropdown
						//nodeDropdown.onClick();
						//nodeDropdown.hideAllMenus();
						
					};
				})(nodeData.id);
				
				return el;
			}

			return nodeDropdown;
		}

		return NodeContextMenu;
	});
