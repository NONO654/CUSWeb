/**
 * 
 */

define('DS/ENOFrameworkSearch/TopFrameInit', [
		'UWA/Drivers/Alone',
    		'UWA/Core',
    		'UWA/Class/Debug',
    		'UWA/Controls/Abstract',
    		'UWA/Class/Listener', 
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
                                              'css!DS/UWA2/assets/css/inline.css',
                                              'DS/SNInfraUX/SearchCom'
], function (UWAAlone,
    		UWACore,
    		UWADebug,
    		UWAAbstract,
    		Listener, 
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
                                            		  inlineCss,
                                            		  SearchCom) {

    'use strict';
    var TopFrameInit = UWAAbstract.extend(UWADebug, Listener, {
    	init: function (completeURL, clntbaseHtmlPath, passportURL, proxyTicketURL, url, openPropertiesPage, searchInitCallBack, tenant, appURL) {
		var userName;
		var userId;
			var about3DExpBuildId;
			var about3DExpDeployId;
			var personImage;
		var curTenant = tenant == "" || tenant == null ? "OnPremise" : tenant;
		jQuery.ajax({
 		   url: '../resources/bps/menu/profileImage',
 		   dataType: 'json',
 		   async:false,
 		   success: function (data){
 			  personImage = data.imageURL;
 		   }
		});
		jQuery.ajax({
    		   url: '../resources/bps/menu/appName',
    		   dataType: 'json',
    		   async:false,
			   cache: false,
    		   success: function (data){
    			   userName = data[0].userName;
				   userId = data[0].userId;
				   about3DExpBuildId = data[1].buildid;
				   about3DExpDeployId = data[1].deployid;
				   if(isIE || isIE11){
						var customEvent = document.createEvent("Event");
						customEvent.initEvent("onTopFrameLoad", true, true);
						top.dispatchEvent(customEvent);  
					}else{
						top.dispatchEvent(new Event('onTopFrameLoad')); 
					}
					var client_socket_id = UWA.Utils.getUUID();  
					var searchcom_socket = SearchCom.createSocket({
						socket_id: client_socket_id,
						clientInfo: '3DSpace'
					});

					searchcom_socket.addListener('Selected_global_action', function(data){
						var link = data.command_data.url;
						var strTraget = data.command_data.targetLocation;
						var relId = "";
						var rowId = "";
						var parentOID = "";
						var phyIds = new Array();
						var selected_object_details = data.selected_objects;
						if(selected_object_details.length>0){

							var submitForm = document.createElement('form');
							submitForm.method = "POST";

							selected_object_details.forEach(function(selected_object_detail){
								phyIds.push(selected_object_detail.id);
							});
							$.ajax({
								url: '../resources/bps/PhyIdToObjId/phyIds',
								dataType: 'json',
								contentType:'application/json; charset=utf-8',
								data:JSON.stringify({phyIds : phyIds}),
								method:'POST',
								success: function (data){
									data.ObjIds.forEach(function(selectedObjId){
										var selectedObjectDetails = relId + "|" + selectedObjId + "|" + parentOID + "|" + rowId;
										var input = document.createElement('input');
										input.type = "hidden";
										input.name = "emxTableRowId";
										input.value = selectedObjectDetails;
										submitForm.appendChild(input);
									});

									submitForm.target = strTraget;
									submitForm.action = link;
									addSecureToken(submitForm);
									document.body.appendChild(submitForm);
									submitForm.submit();
									removeSecureToken(submitForm);
								}
							});
						}else{
							getTopWindow().showTransientMessage(emxUIConstants.SELECTION_ALERT, 'warning', 'alert-right-search','4000');
						}
					});               

					function enableTopBarSearchAndTagger(){
						jQuery("div#topbar.slide-in-context").removeClass("slide-in-dialog");
					}
					function disableTopBarSearchAndTagger(){
						jQuery("div#topbar.slide-in-context").addClass("slide-in-dialog");
					}
					
    var options = {
            userId: userId,
			envId:curTenant,
			tenant:curTenant,
            startupParams: {cstorage: [{id: curTenant , displayName: 'OnPremise', url: completeURL}], 
            				search: [{id: curTenant , displayName: 'OnPremise', url: url}],
            				tagger: [{id: curTenant, displayName:'OnPremise', url:completeURL}]},
            appId: "IFWE",
            baseAppletPath: "../../WebClient/",
            baseImgPath: "../../webapps/i3DXCompass/assets/images",
            baseHtmlPath: clntbaseHtmlPath,
            activateInstantMessaging : false,
            passportUrl: passportURL,
            proxyTicketUrl: proxyTicketURL,
            tagsServerUrl: completeURL,
            myAppsBaseURL: appURL,
            userName: userName,
            brand: getTopWindow().brandName,
            lang: emxUIConstants.BROWSER_LANGUAGE,
            application:getTopWindow().appNameForHomeTitle,
			brandAbout: emxUIConstants.COPYRIGHT_INFO + (about3DExpBuildId || '') + (about3DExpDeployId || ''),
			picture:personImage,
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
				var previousTagger = TagNavigator.get6WTagger("context1");
	    		previousTagger.setAsCurrent();
			});
            		openOptions.searchcontent = "searchResultsContainer";
					if(!openPropertiesPage){
						if(getTopWindow().location.href.indexOf("targetLocation=popup") != -1){
							jQuery('.column').css({'top': '43', 'height':'100%-43px'});
						} else{							
						jQuery('.column').css({'top': '0', 'height':'100%'});
					}
                        jQuery('#searchContainer').css('top', '0');						
					} 
            		var tagger = new Tagger();
            		var search = new Search(openOptions);
            		enableTopBarSearchAndTagger();
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
					disableTopBarSearchAndTagger();
				},
				hide:function(){
				},
				onSearchInit: searchInitCallBack,
                enable_search_in_this_tab : false,
				pqAccessEvalcallback: function(args){
                    var PQ = args.PQ;
                     $.ajax({
                         url: '../resources/bps/pqAccess/pqAccessDetails',
                         dataType: 'json',
                         contentType:'application/json; charset=utf-8',
                         data:JSON.stringify({PQ : PQ}),
                         method:'POST',
                         success: function (data){
                             args.onComplete.call(undefined, data);
                         },
                         error: function (err){
                             var data = {};
                             args.onComplete.call(undefined, data);
                         }
                
                     });

                }, 

								searchHelper: function(args){
									var requestedInfos = args.PQ.requested_info;
									var response = {};

									requestedInfos.forEach(function(requestedInfo){
										if(requestedInfo == 'access'){
											if(emxUIConstants.STORAGE_SUPPORTED){
												var accessCache = localStorage.getItem('accessCache');
												if(typeof accessCache=="undefined" || !accessCache){
													computeAccessForPQs(args);
													response = args;

												}else{
													var accessCacheArgs =  jQuery.parseJSON(localStorage.getItem('accessCache'));
													response = accessCacheArgs;
												}
											}
										} else if(requestedInfo == 'global_actions'){
											computeGlobalActionsForPQs(args);
											response = args;
										} else if(requestedInfo == 'datagridview_columns'){
											computeDataGridViewColumnPQs(args);
											response = args;
										}
									});

									args.onComplete.call(undefined, response);
								}
            },
            events: {
	            tagger: function () {
	            },
	            search: function(){},
	            clearSearch:function(){}
	        },
		
        };
			if(getTopWindow().location.href.indexOf("targetLocation=popup") != -1){
						options.topMenus=[];
						options.lockedAppMode=true;
	        }

					TopFrame.init(options);
					function computeAccessForPQs(args){

						var PQ = args.PQ.PQ;
						$.ajax({
							url: '../resources/bps/pqAccess/pqAccessDetails',
							dataType: 'json',
							contentType:'application/json; charset=utf-8',
							async : false,
							data:JSON.stringify({PQ : PQ}),
							method:'POST',
							success: function (data){
								var PQs = args.PQ.PQ;
								var PQData ={};
								PQs.forEach(function(pq){
									if(!pq.viewData){
										pq.viewData ={};
									}
									var  ref = pq.pqid;

									pq.viewData ={'access': data[ref],
									};    
								}); 
								//cached access info
								localStorage.setItem('accessCache',JSON.stringify(args));
							},
							error: function (err){
								var data = {};
								args.onComplete.call(undefined, data);
							}
						});
					}

					function computeGlobalActionsForPQs(args){

						var PQs = args.PQ.PQ;

						if(!PQs[0].viewData.global_actions){
							PQs[0].viewData.global_actions ={};
						}
						var searchCollectionEnabledValue = "true";
						if(PQs[0].appData){
						searchCollectionEnabledValue = PQs[0].appData["searchCollectionEnabled"] ? PQs[0].appData["searchCollectionEnabled"] : "true";
						}
						if(searchCollectionEnabledValue == "true"){
							PQs[0].viewData.global_actions = {

										'actions':[{"id" : "AEFAddToClipboardCollection",
											"title" : emxUIConstants.ADD_TO_CLIPBOARD_LABEL,
											"icon" : "fonticon fonticon-clipboard",
											"overflow" : false,
											command_data :{
												"targetLocation" : "listHidden",
												"url" : "../common/emxCollectionsAddToProcess.jsp?mode=Clipboard",
												"label" : emxUIConstants.ADD_TO_CLIPBOARD_LABEL}
										},
										{"id" : "AEFNewAddToCollections",
											"title" : emxUIConstants.ADD_TO_COLLECTION_LABEL,
											"icon" : "fonticon fonticon-list-add",
											"overflow" : false,
											command_data :{
												"targetLocation" : "listHidden",
												"url" : "../common/emxCollectionsAddToProcess.jsp",
												"label" : emxUIConstants.ADD_TO_COLLECTION_LABEL }
										}
										],

									'app_socket_id':client_socket_id 
							};  
						}
					}
					function computeDataGridViewColumnPQs(args){

						var PQ = args.PQ.PQ;
						$.ajax({
							url: '../resources/bps/pqAccess/pqTableColumns',
							dataType: 'json',
							contentType:'application/json; charset=utf-8',
							async : false,
							data:JSON.stringify({PQ : PQ[0].appData }),
							method:'POST',
							success: function (data){
								var PQs = args.PQ.PQ;

								if(!PQs[0].viewData){
									PQs[0].viewData ={};
								}

								if(typeof data.dataGridViewColumns != "undefined"){
									PQs[0].viewData ={
											datagridview_columns :data.dataGridViewColumns
							};  
						}
							},
							error: function (err){
								var data = {};
								args.onComplete.call(undefined, data);
							}
						});
					}

		TopFrame.addEvent('onLeftPanelOpened', function () {
			if(typeof emxUISlideIn !== 'undefined' && !emxUISlideIn.is_closed && emxUISlideIn.current_slidein.dir === "left"){
					emxUISlideIn.current_slidein[0].style.zIndex=0
				}
				var leftTaggerWidth = document.getElementById("tagnavigator").parentElement.parentElement.clientWidth +"px";
				var leftStyle= ((typeof isMobile)!="undefined")? (isMobile==true)?"300px":leftTaggerWidth : "25%";
				if(typeof jQuery("#divExtendedHeaderContent") != 'undefined'){
					jQuery("#divExtendedHeaderContent").css('left', '25%');
				}
				jQuery("div#searchContainer").addClass('push-right');
				
				jQuery("div#pageContentDiv").animate({'left': leftStyle, 'right' : '0px'}, 200);
		});
		TopFrame.addEvent('onLeftPanelClosed', function () {
			if(typeof emxUISlideIn !== 'undefined' && !emxUISlideIn.is_closed && emxUISlideIn.current_slidein.dir === "left"){
					emxUISlideIn.current_slidein[0].style.zIndex=250;
					var slideInWidth = emxUISlideIn.current_slidein[0].offsetWidth;
					jQuery("div#pageContentDiv").css('left', slideInWidth+'px');
			}else{
			if(getTopWindow().isPanelOpen){
				getTopWindow().openPanel();
			} else if(getTopWindow().closePanel != undefined){
				getTopWindow().closePanel();
			} else if(getTopWindow().closeWindow != undefined){
				getTopWindow().closeWindow();
			}
			}
			jQuery("div#searchContainer").removeClass('push-right');
			var leftStyle = jQuery("div#pageContentDiv").position().left+'px';
			jQuery("div#pageContentDiv").animate({'left': leftStyle, 'right' : '0px'}, 200);
		});
    	}
    });
    	},
   	 showTaggerOnPopup : function(){
			TopFrame.toggleTagger(true);
		}
    });
    return TopFrameInit;
});
