BPSTopBar = {
	loadTopBar:function(){
		require(['UWA/Core', 
		'DS/TopFrame/TopFrame', 
		'DS/TopBar/TopBar', 
		'DS/TopBarProxy/TopBarProxy', 
		'DS/SNSearchUX/SearchUX_TopBar', 
		'css!DS/TopBar/TopBar', 
		'DS/UWPClientCode/PublicAPI', 
		'DS/ENOFrameworkSearch/SearchUIContainer', 
		'DS/ENOFrameworkSearch/Search',
		'DS/ENOFrameworkSearch/Tagger',
		'DS/TagNavigator/TagNavigator',
		'DS/TagNavigatorProxy/TagNavigatorProxy',
		'DS/ENOFrameworkSearch/TopFrameInit'], 
		function (Core, 
		TopFrame, 
		TopBar, 
		TopBarProxy, 
		SearchTopBar,
		cssTopBar, 
		PublicAPI, 
		SearchUIContainer, 
		Search,
		Tagger,
		TagNavigator,
		TagNavigatorProxy,
		TopFrameInit) {
		    'use strict';
			Core.Data.proxies.ajax = donwloadpf;
		    var search;
			var fedsearchURL;
		    var path = window.location.pathname.split('/')[1];
		    var url = getTopWindow().searchURL;
		    var homeData = [];
            var collabSpaceData = [];
		    var completeURL = window.location.protocol + "//" + window.location.host + "/" +  path;
		    if(getTopWindow().curTenant != ""){
				fedsearchURL = (window.location.protocol + "//" + window.location.host).replace("space.", "fedsearch.");
			}
		    url = fedsearchURL != undefined && fedsearchURL != "" ? fedsearchURL : url;
		    var topFrameInit = new TopFrameInit(completeURL, clntbaseHtmlPath, passportURL, proxyTicketURL, url, true, undefined, getTopWindow().curTenant, getTopWindow().myAppsURL);
		    var thisCommandProvider = {};
		    thisCommandProvider.topBarProxy = new TopBarProxy({
		        id: 'CommandProvider1'
		    });
		    
		    TopBar.MainMenuBar.setActiveMenuProviders("CommandProvider1");
			var appHomePageURL = TopBar.getTitleMenuElement();
			var appHomePageTitle = getTopWindow().emxUIConstants.STR_APPHOMEPAGE;
			appHomePageURL.onclick = function(){
				getTopWindow().launchHomePage();
			}
			TopBar.view.$appName.title = appHomePageTitle;
		    var callback = thisCommandProvider.callback = function (menuItem) {
		    	var url = menuItem.get('url');
		    	var targetLocation = (menuItem.get('targetLocation') == 'popup' || menuItem.get('targetLocation') == 'slidein') ? undefined : menuItem.get('targetLocation');
				if(url != null && !url.startsWith("javascript:") && menuItem.get('targetLocation') == "slidein"){
		    		var slideinWidth = menuItem.get('slideinWidth');
		    		if (menuItem.get('isPopupModal'))
	                {
		    			url = "javascript:getTopWindow().showSlideInDialog('"+url+"', true";
	                }
	                else
	                {
	                	url = "javascript:getTopWindow().showSlideInDialog('"+url+"', false";

	                }
	            	
	            	if(slideinWidth != null && slideinWidth != ""){
	            		url += ", '$OPENERFRAME$','right'," + slideinWidth + ")";
	            	} else {
	            		url += ",'$OPENERFRAME$')";
	                }
		    	} else if(url != null && !url.startsWith("javascript:") && menuItem.get('targetLocation') == "popup")
				{
					if (menuItem.get('isPopupModal'))
	                {
		    			url += "&isPopupModal=true";
	                }					
				}
		    	emxUICore.link(url, targetLocation);
		    };
		    var ajaxGobalMenuURL = '../resources/bps/menu/GlobalActionMenu';
            var addCallbackAndMenuType = function (data, type) {
                data.forEach(function (item) {
                    if (item.submenu) {
                        item.submenu.forEach(function (subItem) {
							addCallbackAndMenuType(item.submenu, type);
                        });
			
                    } else {
                        item.onExecute = callback;
                        item.menuType = type;
                    }
                });
                return data;
            };
            var topbarGlobalMenuComplete = function (data) {
            	var startTime=new Date().getTime();
            	topbarAjaxActionsComplete(data.add);
            	topbarAjaxProfileComplete(data.profile);
            	topbarShareComplete(data.share);
            	topbarMyHomeComplete(data.home);
            	topbarHelpComplete(data.help);
            	defaultCollabSpace(data);
            	var time = (new Date().getTime() - startTime);
            	console.log("<<<<<<<topbarGlobalMenuComplete time>>>>>>>>");
            	console.log(time);
            	console.log("<<<<<<<topbarGlobalMenuComplete END>>>>>>>>");
            };
            var topbarAjaxActionsComplete = function (data) {
                var cbData = addCallbackAndMenuType(data, "add");
                thisCommandProvider.topBarProxy.addContent({
                    add: cbData
                    
                });
            };

            var topbarAjaxProfileComplete = function (data) {
                var cbData = addCallbackAndMenuType(data, "profile");
                thisCommandProvider.topBarProxy.addContent({
                    profile: cbData
                });
            };

            
            var topbarShareComplete = function (data) {
                var cbData = addCallbackAndMenuType(data, "share");
				if(cbData.length==1){
                thisCommandProvider.topBarProxy.setContent({
                    share: []
                });
			TopBar.MainMenuBar.get('share').set('onExecute',function () { javascript:emailPageURL(); })  ;
				}else{
					thisCommandProvider.topBarProxy.addContent({
                    share: cbData
                });
				}
            };
			
			
            var topbarMyHomeComplete = function (data) {
                var cbData = addCallbackAndMenuType(data, "home");
                var i = 0;
                var j = 0;
                cbData.forEach(function(homeCommand){
                	if((!homeCommand.url.contains("changeSecurityContextDialog"))){
                		homeData[i++]=homeCommand;
                	}else{
                		collabSpaceData[j++]=homeCommand;
                	}
                });
				collabSpaceData[j++]=homeData[1];
                var homedatasingle = homeData[0];
                thisCommandProvider.topBarProxy.setContent({
                    home: []
                });
				TopBar.MainMenuBar.get('home').set('onExecute', function () { javascript:emxUICore.link(homedatasingle.url, homedatasingle.targetLocation); }) ;
            };
            var topbarHelpComplete = function (data) {
            	data.forEach(function(helpCommand){
            		if(!helpCommand.url.contains("openHelpPage")){
            			data.remove(helpCommand);
            		}
            	});
                var cbData = addCallbackAndMenuType(data, "help");
                thisCommandProvider.topBarProxy.addContent({
                    help: cbData
                });
            };
            var defaultCollabSpace = function(data){
    			   require(['TopBar', 'DS/W3DXNavigationMenu/NavigationMenu'], function (TopBar, NavigationMenu) {
    					// Initialization
    					var rightMenuHandlers = TopBar.setRightMenuContext({
    						title: data.currentCollabSpace
    					});
    					// Create a dropdown menu
    					var collabSpaceInfo=BPSTopBar.prepareCollabSpaceInfo(collabSpaceData);
						var target = rightMenuHandlers.getTarget().addClassName('topbar-app-menu');
						var menu = new NavigationMenu.create({
           					target: target.getParent(),
							itemActions:{},
							globalActions:{},
                     		items:collabSpaceInfo,
                     		nls: { tooltipMenu: data.currentCollabSpace }
       					});
						menu.addEvent('onObjectSelect', function (itemId) {
    						for(var i=0; i<collabSpaceData.length; i++){
    							if(itemId.replace("collabspace-","") == i){
    								emxUICore.link(collabSpaceData[i].url);
    							}
    						}
						});
						menu.addEvent('onShow', function () {
							collabSpaceInfo.forEach(function(collabSpace, index){
								var itemId= "collabspace-"+index;
								if(collabSpace.name == data.currentCollabSpace){
									NavigationMenu.setCurrentSelectedObject(collabSpace.modelId);
								}
							});
    					});
    				});
		   }
            jQuery.ajax({
    		   url: ajaxGobalMenuURL,
    		   dataType: 'json',
    		   success: topbarGlobalMenuComplete,
               cache:false
    		});
            
			var toppos = jQuery("div#ExtpageHeadDiv")[0].hasChildNodes() ? jQuery('#topbar').height() + jQuery('#navBar').height() + jQuery('#ExtpageHeadDiv').height() : jQuery('#topbar').height() + jQuery('#navBar').height();
			getTopWindow().toppos = toppos;
            jQuery("div#pageContentDiv").css('top',toppos);
			jQuery("div#leftPanelMenu").css('top',toppos);
			jQuery("div#mydeskpanel").css('top',toppos);
			jQuery("div#panelToggle").css('top',toppos);
			jQuery("div#GlobalMenuSlideIn").css('top',toppos);
			
			jQuery("div#rightSlideIn").css('top',toppos);
			jQuery("div#leftSlideIn").css('top',toppos);
			jQuery("div#GlobalMenuSlideIn").css('top',toppos);
			jQuery(".app-content").hide();
			require(['i3DXCompass/i3DXCompass', 'DS/i3DXCompassServices/i3DXCompassPubSub'], function(Compass, i3DXCompassPubSub){ 
				getTopWindow().ds = {};
				getTopWindow().ds.Compass = Compass;
				i3DXCompassPubSub.subscribe('compassPanelOnShow', function() {
        				getTopWindow().ds.isCompassOpen = true;
					emxUICore.setIdtoCompass();
    				});
				i3DXCompassPubSub.subscribe('compassPanelOnHide', function() {
        				getTopWindow().ds.isCompassOpen = false;
    				});
				
			});
		});
			
	},
	prepareCollabSpaceInfo:function(collabSpaceData){
		var rightContextMenuItems=[];
		collabSpaceData.forEach(function(collabSpace, index){
			var itemId= "collabspace-"+index;
			rightContextMenuItems[index]={text:collabSpace.label, title:collabSpace.label, name:collabSpace.label, modelId:itemId};
		});
		return rightContextMenuItems;
	}
	
};
//BPSTopBar.loadTopBar();
