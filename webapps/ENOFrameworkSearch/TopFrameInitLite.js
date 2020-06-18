/**
 * 
 */

define('DS/ENOFrameworkSearch/TopFrameInitLite', [
		'UWA/Class/Debug',
		'UWA/Controls/Abstract',
		'UWA/Class/Listener', 
		'DS/TopFrame/TopFrame', 
		'css!DS/TopBar/TopBar', 
		'DS/ENOFrameworkSearch/SearchUIContainer', 
		'DS/ENOFrameworkSearch/Search',
		'DS/ENOFrameworkSearch/Tagger',
	    'css!DS/UWA2/assets/css/inline.css',
	    'DS/SNInfraUX/SearchCom'
], function (
    		UWADebug,
    		UWAAbstract,
    		Listener, 
			TopFrame, 
			cssTopBar, 
			SearchUIContainer, 
			Search,
			Tagger,
		    inlineCss,
		    SearchCom) {

    'use strict';
    var TopFrameInit = UWAAbstract.extend(UWADebug, Listener, {
    	init: function (completeURL, clntbaseHtmlPath, passportURL, proxyTicketURL, url, openPropertiesPage, searchInitCallBack, tenant, appURL) {
		var userName;
		var userId=emxUIConstants.CURRENT_ID;
		
			var about3DExpBuildId;
			var about3DExpDeployId;
			var personImage;
		var curTenant = tenant == "" || tenant == null ? "OnPremise" : tenant;
			var popupoptions={
	            userId: userId,
				envId:curTenant,
				tenant:curTenant,
	            startupParams: {cstorage: [{id: curTenant , displayName: 'OnPremise', url: completeURL}], 
	            				search: [{id: curTenant , displayName: 'OnPremise', url: url}],
	            				tagger: [{id: curTenant, displayName:'OnPremise', url:completeURL}]},
	            
	            lang: emxUIConstants.BROWSER_LANGUAGE,
	            
	            proxyTicketUrl: proxyTicketURL,
	            tagsServerUrl: completeURL,
	            myAppsBaseURL: appURL,

	            searchParams :{
	                open: function(openOptions){
	                   getTopWindow().SnN.is3DSearchActive=true;
	                	var popup;
	                	var container;
						var isInContext = openPropertiesPage ? false : true;
	            		container = new SearchUIContainer(getTopWindow(), isInContext);
									if(typeof getTopWindow().clntlang=="undefined" ){
										getTopWindow().clntlang = emxUIConstants.BROWSER_LANGUAGE;
									}
				jQuery('#closeWidget').bind('click', function(){
					getTopWindow().SnN.is3DSearchActive=false;
					disableTopBarSearchAndTagger();
				});
	            		openOptions.searchcontent = "searchResultsContainer";
						if(!openPropertiesPage){
							//if(getTopWindow().location.href.indexOf("targetLocation=popup") != -1){
								jQuery('.column').css({'top': '43', 'height':'100%-43px'});
							//} 
	                        jQuery('#searchContainer').css('top', '0');						
						} 
	            		var tagger = new Tagger();
	            		var search = new Search(openOptions);
	                },

	               
	                isOpen: function(){
	                	return jQuery("div#searchContainer").is(':visible');
	                },
					close:function(option){
						jQuery('#searchContainer').fadeOut(); 
						jQuery('#searchResultsContainer').empty(); 
						jQuery('.column-left').css('z-index', '1'); 
						jQuery("div#layerOverlayRight").css('display', 'none').removeClass('group-right-topbar').addClass('group-right');
						jQuery("div#layerOverlay").css('left', '0');
						jQuery('#closeWidget').click();
						if(!openPropertiesPage && option.command_id == 'in_app_cancel'){
							getTopWindow().closeWindow();
						} 
						getTopWindow().SnN.is3DSearchActive=false;
					},
					hide:function(){
					},
					onSearchInit: searchInitCallBack,
	                enable_search_in_this_tab : false
	            },
	            events: {
		            tagger: function () {
		            },
		            search: function(){},
		            clearSearch:function(){}
		        },
			
	        };
			popupoptions.topMenus=[];
			popupoptions.lockedAppMode=true;
			TopFrame.init(popupoptions);
			TopFrame.addEvent('onLeftPanelOpened', function () {
				
				var leftTaggerWidth = document.getElementById("tagnavigator").parentElement.parentElement.clientWidth +"px";
				var leftStyle= ((typeof isMobile)!="undefined")? (isMobile==true)?"300px":leftTaggerWidth : "25%";
				if(typeof jQuery("#divExtendedHeaderContent") != 'undefined'){
					jQuery("#divExtendedHeaderContent").css('left', '25%');
				}
				jQuery("div#searchContainer").addClass('push-right');
				
				jQuery("div#pageContentDiv").animate({'left': leftStyle, 'right' : '0px'}, 200);
			});
			TopFrame.addEvent('onLeftPanelClosed', function () {
			
				jQuery("div#searchContainer").removeClass('push-right');
				var leftStyle = jQuery("div#pageContentDiv").position().left+'px';
				jQuery("div#pageContentDiv").animate({'left': leftStyle, 'right' : '0px'}, 200);
			});
			jQuery(".topbar-access").css("display","none")
			
    	},
   	 showTaggerOnPopup : function(){
			TopFrame.toggleTagger(true);
		}
    });
    return TopFrameInit;
});
