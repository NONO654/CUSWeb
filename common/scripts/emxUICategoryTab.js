/**
 * JavaScript Methods for Category items tabs
 * emxUICategoryTab.js
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * AUTHOR: Anup Patel (AP3) 27/08/13
 */

var emxUICategoryTab = {

		init : function(catObj){
			var opts = {};
			opts.currTab = 0;
			opts.nextTab = 1;
			this.menu.options = opts;
			
			//display the tab bar.

			//creating the tab and overflow menu
			if(catObj.objectId){
				this.menu.createDOMPanel(catObj);
			}
			if(jQuery('#ExtpageHeadDiv').attr("class")=="page-head-mini"){
				jQuery('#ExtpageHeadDiv').css("height","");
			}

			var extpageHeadDiv = jQuery("#ExtpageHeadDiv");
			if(extpageHeadDiv.hasClass("page-head")){
			jQuery(".mini").addClass("hide");
			jQuery(".full").removeClass("hide");
			}
			else{
				
				
				jQuery(".full").addClass("hide");
				jQuery(".mini").removeClass("hide");
			}			
			
			//setting the current category object
			emxUICategoryTab.catObj = catObj;
			var divph = getTopWindow().document.getElementById("ExtpageHeadDiv");
			//var objheaderurl = "";
			var hasCatMenu = true;
			if(catObj.objectId && catObj.objectId != "null"){
					divph.style.display='block';
					if(getTopWindow().isfromIFWE){
						getTopWindow().toppos = jQuery('#ExtpageHeadDiv').height();
						divph.style.top = "0px";
					} else {
						if(emxUIConstants.TOPFRAME_ENABLED){
							getTopWindow().toppos = jQuery('#topbar').height() + jQuery('#navBar').height() + jQuery('#ExtpageHeadDiv').height();
							divph.style.top = jQuery('#topbar').height() && jQuery('#navBar').height() ? jQuery('#topbar').height() + jQuery('#navBar').height() + "px" : "0px";
						}else{
							getTopWindow().toppos = jQuery('#pageHeadDiv').height() + jQuery('#ExtpageHeadDiv').height();
							divph.style.top = jQuery('#pageHeadDiv').height() ? jQuery('#pageHeadDiv').height() + "px" : "0px";
						}
					}
			} else {				
				divph.style.display='none';
				if(getTopWindow().isfromIFWE){
					getTopWindow().toppos = 0;
				} else {
					if(emxUIConstants.TOPFRAME_ENABLED){
							getTopWindow().toppos = jQuery('#topbar').height() + jQuery('#navBar').height();
						}else{
							getTopWindow().toppos = jQuery('#pageHeadDiv').height();
						}
				}
				if(jQuery("div#catMenu > ul > li").length <= 0) {
					hasCatMenu = false;
					jQuery("div#leftPanelMenu").css('display',"none");				
					jQuery("div#catMenu").css('display',"none");
					jQuery("div#mydeskpanel").css('display',"block");
					jQuery("div#mx_divGrabber").css('display',"none");
					jQuery("div#pageContentDiv").css('left', jQuery("div#mydeskpanel").width() + jQuery("div#panelToggle").width() +'px');
					
				} 
			}
			if(hasCatMenu) {
				jQuery("div#mydeskpanel").css('display',"none");
				jQuery("div#leftPanelMenu").css('display',"block");
				jQuery("div#mx_divGrabber").css('display',"block");					
				
				if(getTopWindow().objStructureFancyTree && getTopWindow().objStructureFancyTree.fromActivateNode){
					getTopWindow().objStructureFancyTree.fromActivateNode = false;
				}else{
				var leftwidth = localStorage.getItem("userWidth");
				if(typeof leftwidth != 'undefined' && leftwidth != null ){
					jQuery("div#leftPanelMenu").css("width",leftwidth+"px");
					jQuery("#leftPanelTree").css("width", leftwidth+"px");
				}else{
					jQuery("div#leftPanelMenu").css("width", "195px");
				}
				var pageContentDivLeft = jQuery("div#leftPanelMenu").width() + jQuery("div#panelToggle").width();
				jQuery("div#pageContentDiv").css('left', jQuery("div#leftPanelMenu").width() + jQuery("div#panelToggle").width() +'px');
				jQuery("div#leftPanelMenu").css('left', '16px');
				jQuery("div#mx_divGrabber").css('left',jQuery("div#pageContentDiv").css("left"));
				if(isMobile){
					jQuery("div#pageContentDiv").css('left',pageContentDivLeft+17+'px');
				}
				}
				if(getTopWindow().objStructureFancyTree.isActive && jQuery("button#catButton").hasClass("toggle-inactive")){
					jQuery("div#catMenu").css('display',"none");
				} else {
					jQuery("div#catMenu").css('display',"block");
				}
			}
			jQuery("div#pageContentDiv").css('top',getTopWindow().toppos);
			jQuery("div#leftPanelMenu").css('top',getTopWindow().toppos);
			jQuery("div#panelToggle").css('top',getTopWindow().toppos);
			jQuery("div#GlobalMenuSlideIn").css('top',getTopWindow().toppos);
			
			jQuery("div#rightSlideIn").css('top',getTopWindow().toppos);
			jQuery("div#leftSlideIn").css('top',getTopWindow().toppos);


			/*var objheadcntfrm = getTopWindow().findFrame(getTopWindow(), "objHeadcontent");
			if(objheadcntfrm){
			objheadcntfrm.location.href = objheaderurl;
			}*/
			//events for closing and destroying the tabs
			var contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
			jQuery(contentFrame).bind('unload', function(){
				getTopWindow().emxUICategoryTab.destroy();
			});

				if(catObj.objectId && catObj.objectId != 'null'){
					
					jQuery(contentFrame).bind('resize', function(){
						if(getTopWindow().emxUICategoryTab)
							getTopWindow().emxUICategoryTab.redrawPanel();
					});

					this.redrawPanel();
				}
				jQuery('#buttonAppMenu').prop('title', typeof getTopWindow().brandName != "undefined" ? getTopWindow().brandName+" "+getTopWindow().appNameForHomeTitle+" " + emxUIConstants.APPLICATION_MY_DESK_MENU : getTopWindow().appNameForHomeTitle+" " + emxUIConstants.APPLICATION_MY_DESK_MENU);
		},


		redrawPanel : function(){
			// extended header Changes START
			var minHeaderView =localStorage.getItem("minHeaderView");
			if(!minHeaderView){
			jQuery("div#divExtendedHeaderImage").show();
			jQuery("div#divExtendedHeaderDescription").show();
			jQuery("div#divExtendedHeaderDetails").show();
			jQuery("div#divExtendedHeaderDocuments").show();			
				jQuery("div#divExtendedHeaderName span.extendedHeader").not(".extendedHeader.name").show();
				jQuery("div#divExtendedHeaderDetails span.extendedHeader").not(".extendedHeader.state").show();
			}else{
				//hiding content as per the CSS
				jQuery("div#divExtendedHeaderImage").hide();
				jQuery("div#divExtendedHeaderDescription").hide();
				jQuery("div#divExtendedHeaderDocuments").hide();
				jQuery("div#divExtendedHeaderName span.extendedHeader").not(".extendedHeader.name").hide();
				jQuery("div#divExtendedHeaderDetails span.extendedHeader").not(".extendedHeader.state").hide();
			}

			var widthTabBar 		= jQuery("div#ExtpageHeadDiv").width();			
			if(jQuery('#appsPanel').is(":visible")){				
				widthTabBar -= jQuery('#appsPanel').innerWidth();
			}
			if(jQuery('#rightSlideIn').is(":visible")){				
				widthTabBar -= jQuery("div#rightSlideIn").innerWidth();
			}	
			if(jQuery('#leftSlideIn').is(":visible")){				
				widthTabBar -= jQuery("div#leftSlideIn").innerWidth();
			}
			
			var widthImage 			= 100;
			var widthName 			= jQuery("div#divExtendedHeaderName").innerWidth();
			var widthDescription 	= jQuery("div#divExtendedHeaderDescription").innerWidth();
			var widthDetails 		= jQuery("div#divExtendedHeaderDetails").innerWidth();
			var widthDocuments 		= jQuery("div#divExtendedHeaderDocuments").innerWidth();
			var widthNavButtons		= jQuery("div#divExtendedHeaderNavigation").innerWidth();
			var widthAll 			= widthImage + widthName + widthDescription + widthDetails + widthDocuments +widthNavButtons;

			if(widthAll > widthTabBar) {
				jQuery("div#divExtendedHeaderDescription").hide();
				widthAll -= widthDescription;
				if(widthAll > widthTabBar) {
					jQuery("div#divExtendedHeaderDocuments").hide();
					widthAll -= widthDocuments;
					if(widthAll > widthTabBar) {
						jQuery("div#divExtendedHeaderDetails").hide();
						widthAll -= widthDetails;
						if(widthAll > widthTabBar) {
								jQuery("div#divExtendedHeaderImage").hide();
								widthAll -= widthName;
						}
					}
				}
			}
			if(minHeaderView && widthName + widthDetails + widthNavButtons < widthTabBar){
				jQuery("div#divExtendedHeaderDetails").show();
				jQuery("div#divExtendedHeaderDetails .extendedHeader").not(".state").hide();
				jQuery("div#divExtendedHeaderDetails .extendedHeader.state").show();
			}
			
			var homeTitle = typeof getTopWindow().brandName != "undefined" ? getTopWindow().brandName+" "+getTopWindow().appNameForHomeTitle+" " + emxUIConstants.STR_BC_LABEL_HOME : getTopWindow().appNameForHomeTitle+" " + emxUIConstants.STR_BC_LABEL_HOME;
			jQuery("div#divExtendedHeaderNavigation").find(".field.share.button").hide();
			
			//Hide navigation icons in case of popup
			//OPENEROK
			if(getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener() == getTopWindow().opener)
			{
				jQuery("div",jQuery("div#divExtendedHeaderNavigation")).not("div.field.previous.button, div.field.next.button,div.field.refresh.button , div.field.resize-Xheader.button, div#collab-space-id").hide();
				jQuery("div#divExtendedHeaderNavigation").find(".field.share.button").show();
			}
			
			// EXTENDED HEADER Changes END
		},

		redraw : function(){
			var tab = jQuery('ul','div#tabBar');
			//removing all the cloned item from overflow menu
			jQuery('li[cloned="true"]','div.menu-panel.overflow').remove();
			//displaying all the hidden items
			jQuery('li:hidden','div.menu-panel.overflow').show();
			// only visible tabs in category tab bar.
			var tabs = jQuery('li:visible','div#tabBar');

			//taking the selected tab and making it visible (if item is selected from overflow items)
			var selectedTab = jQuery('li.active','div#tabBar');			
			var liTab;
			var totalWidth = selectedTab.outerWidth()+ parseInt(selectedTab.css('margin-right'));
			var overflowButton = jQuery('li.icon-only','div#tabBar');
			for(var inc=0; inc < tabs.length; inc++){
				liTab = jQuery(tabs.get(inc));

				if(liTab.get(0) == overflowButton.get(0)){
					//starting the iteration again with hidden items
					inc = -1;
					tabs = jQuery('li:hidden','div#tabBar');
					continue;
				}

				if(liTab.get(0) != selectedTab.get(0)){
					totalWidth += (liTab.outerWidth() + parseInt(liTab.css('margin-right')));
				}
				if(tab.width() > (totalWidth + overflowButton.outerWidth())){
					liTab.show();
					var catElem = jQuery('li[name="'+liTab.attr('name')+'"]','div.menu-panel.overflow').removeClass("overflow");
					//if displayed items is in overflow then make a clone of it and put above the first one of the overflow item
					// and hide the original one
					if(catElem.prev().hasClass('overflow')){
						catElem.clone(true).attr("cloned","true").insertBefore(jQuery('li.overflow','div.menu-panel.overflow').get(0)).get(0).item = catElem.get(0).item;
						catElem.hide();
					}
				}else{
					//if the item is not displayed in category tab bar, then hiding it.
					liTab.hide();
					jQuery('li[name="'+liTab.attr('name')+'"]','div.menu-panel.overflow').addClass("overflow");
				}
			}

			selectedTab.show();
			var catElem = jQuery('li[name="'+selectedTab.attr('name')+'"]','div.menu-panel.overflow').removeClass("overflow");
			if(catElem.prev().hasClass('overflow') || catElem.prev().css('display') == 'none'){
				var cloneExist = false;
				var dummyElement = catElem.next();
				while(dummyElement.length > 0){
					if(dummyElement.css('display') == 'none'){
						cloneExist = true;
						break;
					}
					dummyElement = dummyElement.next();
				}
				if(cloneExist){
					catElem.clone(true).attr("cloned","true").insertBefore(jQuery('li[cloned="true"]','div.menu-panel.overflow').get(0)).get(0).item = catElem.get(0).item;
				}else{
					catElem.clone(true).attr("cloned","true").insertBefore(jQuery('li.overflow','div.menu-panel.overflow').get(0)).get(0).item = catElem.get(0).item;
				}
				catElem.hide();
			}

			if(tab.width() > (totalWidth + overflowButton.outerWidth())){
				overflowButton.hide();
			}else{
				overflowButton.show();
			}
		},

		destroy : function(){
			jQuery('div#catMenu').html("");
			jQuery('div#catMenu').hide();
			jQuery("#divExtendedHeaderContent").remove();
		},

		//to reload the tabs for new toolbar object
		reloadTabs : function(category){
			category = category ? category : emxUICategoryTab.catObj.category; 
			jQuery.ajax({
				url: "emxLoadToolbar.jsp?toolbar="+emxUICategoryTab.catObj.items[0].dynamicName+"&objectId="+emxUICategoryTab.catObj.items[0].objectId,
				dataType:"html",
				cache:false
			}).done(function(data){
				var catObj = emxUICore.parseJSON(data);
				if(!catObj.objectId){
					catObj.objectId = category.objectId;
				}
				catObj.category = category;
				jQuery('ul','div#tabBar').html("");
				jQuery('div.menu-panel.overflow').remove();
				getTopWindow().emxUICategoryTab.init(catObj);
				var currbc = getTopWindow().bclist.getCurrentBC();
				if(currbc && currbc.categoryObj){
					currbc.categoryObj = catObj;
				}
			});
		},

		//to change the root node label	
		changeRootLabel : function(label){
			var rootNode = jQuery('label','div#catMenu').get(0);
			var rootNodeLabel = rootNode.parentNode && rootNode.parentNode.title ? rootNode.parentNode.title : rootNode.innerHTML;
			if(rootNodeLabel != label){
				if(label.length > emxUIConstants.CATEGORY_TAB_Width){
					rootNode.parentNode.title = label;
					label = label.substr(0,emxUIConstants.CATEGORY_TAB_Width - 3) + "...";
				}else if(rootNode.parentNode && rootNode.parentNode.title){
					rootNode.parentNode.title = "";
				}
				rootNode.innerHTML = label;
			}
		},
		
		//event registration on frames to close the overflow div
		closeOverflowEvent : function (){
			var objRootWindow =  getTopWindow().findFrame(getTopWindow(),emxUICategoryTab.closeEventWindow);
			emxUICore.iterateFrames(function (objFrame) {
				if(objFrame){
					jQuery(objFrame.document).bind("mousedown",function(e){
						if(jQuery(e.target).closest('.menu-panel.overflow').length == 0){
							jQuery('div.menu-panel.overflow').hide();
						}
					});
				}
			}, objRootWindow);
			emxUICategoryTab.addCloseEvent = false;
		},

		menu : {

			options : {},

			template : {
				menuBorder : function(){
					return jQuery('<div class="menu-panel overflow" style="display : none"><div class="menu-content"><ul></ul></div></div>');
				},
				menuItem : function(text,name){
					return jQuery('<li name="'+name+'"><a href="javascript:void(0);"><span></span><span class="icon"></span><label>'+ getXSSEncodedValue({"value":text,"encodeType":"html"}) +'</label></a></li>');
				},
				tabItem : function(text, name){
					var label = text;
					var item = jQuery('<li class="menu text-only" name="'+name+'"><label>'+ getXSSEncodedValue({"value":label, "encodeType":"html"}) +'</label><span class="close"></span></li>');
					item.attr('title', text);	
					return item;
				},
				tabItemThick : function(text, name){
					var label = text;
					var item = jQuery('<li class="menu text-only divider" name="'+name+'"><label>'+ getXSSEncodedValue({"value":label, "encodeType":"html"}) +'</label><span class="close"></span></li>');
					item.attr('title', text);	
					return item;
				},				
				overflow: function () { 
					//template for overflow icon
					return jQuery('<li class="menu icon-only"><span class="overflow"><img src="../common/images/utilCateroriesTabOverflowChevron.png"></span></li>');
				},
				menu_group_category_expanded:function(expand){
		        	return jQuery('<li class="menu expanded" style="display:block"></li>');
		        },
				menu_group_head : function(){
		        	return jQuery('<a href="javascript:void(0)" class="selected"></a>');
		        },
				menu_ul:function(){
		        	return jQuery('<ul></ul> ');
		        },
				menu_separator: function(){
					return jQuery('<li class="menu text-only divider"></li>');
				}
			},

			itemClick : function(item, isMD){

				var target = item.target;
				var contentFrame = findFrame(getTopWindow(), "content");
            getTopWindow().taggerCtx = (new Date()).getTime() + "taggerCtx";
				var selectedTab = null;
				if(isMD && target == 'detailsDisplay'){
					target = 'content';

					/*if(isMD){
					var objheadcntfrm = getTopWindow().findFrame(getTopWindow(), "objHeadcontent");
					if(objheadcntfrm){
						objheadcntfrm.location.href = "../widget/bpsWidget.jsp?bps_widget=PRG_Experience_Project_Label&fromIFWE=true&label=" + item.text;;
					}
					}*/

				emxUICore.link(item.url, target);
				}else{
					target = item.target; //+ this.options.nextTab;
                    
                    if(getTopWindow().CACHE_CATEGORIES_COUNT === 0){
						emxUICore.link(item.url, target);
					}else{
                        var matchFound = false;
                    	var tabNameMatchFound = false;
                    var tmpTab, tmpFrame, taggerContextId, currentTagger;
                        for(var ii = 0; ii < getTopWindow().CACHE_CATEGORIES_COUNT ; ii++){
                            tmpTab = contentFrame.document.getElementById("unique"+ii);
                        tmpFrame = tmpTab.firstChild;
                        currentTagger = tmpFrame.contentWindow.bpsTagNavSBInit && tmpFrame.contentWindow.bpsTagNavSBInit.tnID;
                        taggerContextId = currentTagger && currentTagger.options.contextId;
                            tmpTab.style.display='none';
                            var tabName = tmpTab.getAttribute('tab-name');
                            var cachePage = tmpTab.getAttribute('cachePage');
                            if(tabName == item.dynamicName){
								tabNameMatchFound = true;
								selectedTab = ii;
                                if("true" == cachePage){
                                matchFound = true;
                            	}
                                tmpTab.style.display='block';
                            tmpFrame.name = "detailsDisplay";
                            tmpFrame.contentWindow.name = "detailsDisplay";
                            if (currentTagger) {
                                var tagger = getTopWindow().topFrameTagger.get6WTagger(taggerContextId);
                                tagger.setAsCurrent();
                                currentTagger.activate();
                                getTopWindow().taggerCtx = taggerContextId;
                            }
                                
                                this.options.nextTab = ii + 1;
                                if(this.options.nextTab >= getTopWindow().CACHE_CATEGORIES_COUNT){
                                    this.options.nextTab = 0;
                                }
                                jQuery('button.refresh', '.field.button').toggleClass('refresh').toggleClass('refresh-with-cache');                               
                            } else {
                            tmpFrame.name = "detailsDisplay" + ii;
                            tmpFrame.contentWindow.name = "detailsDisplay" + ii;
                            if (currentTagger) {
                                currentTagger.deactivate();
                            }
                            }
                        }
                        if(!matchFound){
							if(!tabNameMatchFound){
                            if(this.options.nextTab < getTopWindow().CACHE_CATEGORIES_COUNT){
                                var currTab = contentFrame.document.getElementById("unique"+(this.options.nextTab));
                                contentFrame.document.getElementById('unique'+this.options.nextTab).firstChild.name = "detailsDisplay";
                                contentFrame.document.getElementById('unique'+this.options.nextTab).firstChild.contentWindow.name="detailsDisplay";
                                currTab.style.display='block';
                                currTab.setAttribute('tab-name',item.dynamicName);
                                contentFrame.document.getElementById('unique'+this.options.nextTab).firstChild.src = item.url;
                                contentFrame.document.getElementById('unique'+this.options.nextTab).setAttribute('cachePage','true');
                                this.options.nextTab = this.options.nextTab + 1;
                                if(this.options.nextTab >= getTopWindow().CACHE_CATEGORIES_COUNT){
                                    this.options.nextTab = 0;
                                }
                                jQuery('button.refresh-with-cache', '.field.button').toggleClass('refresh-with-cache').toggleClass('refresh');
                            }
							}else {
								jQuery('button.refresh-with-cache', '.field.button').toggleClass('refresh-with-cache').toggleClass('refresh');
								emxUICore.link(item.url, target);
								if(selectedTab != null){
									var currTab = contentFrame.document.getElementById("unique"+selectedTab);
									currTab.setAttribute('tab-name',item.dynamicName);
									currTab.setAttribute('cachePage','true');
								}
							}
                        }
                        
                        tmpTab = contentFrame.document.getElementById("unique6");					
                        tmpTab.style.display='none';
                    }
				}
				
				if(emxUICategoryTab.addCloseEvent === false){
					emxUICategoryTab.closeEventWindow = target;
				}
				emxUICategoryTab.addCloseEvent = true;
			},

			addOverflow : function(){

				var tab = jQuery('ul','div#tabBar');

				var overflow = this.template.overflow();				
				if(emxUIConstants.UI_AUTOMATION == 'true'){
					overflow.attr('data-aid', 'Overflow-Icon');
				}
				tab.append(overflow);
				emxUICategoryTab.addCloseEvent = true;
				//binding the click event on overflow button
				overflow.bind("click",function(){
					var categoryDiv = jQuery('div.menu-panel.overflow');
					var overflowTop = jQuery('div#globalToolbar').height() + jQuery('div#navBar').height() + jQuery('div#tabBar').height();
					categoryDiv.css('top', overflowTop +'px');
					var left = jQuery(this).offset().left - categoryDiv.outerWidth() + overflow.outerWidth() + "px"; 
					categoryDiv.css('left', left);
					categoryDiv.show();
					//to adjust the height of the overflow div
					var reqheight = jQuery(window).height() - overflowTop - 10;
					if(categoryDiv.height() >= reqheight){
						jQuery('div.menu-content', categoryDiv).height(reqheight);
					}else{
						jQuery('div.menu-content', categoryDiv).height(jQuery('ul', categoryDiv).height());
					}
					if(emxUICategoryTab.addCloseEvent){
						emxUICategoryTab.closeOverflowEvent();
					}
				});

				var image = jQuery('img',overflow);
				setTimeout(function(){
					if(!image.get(0).complete){
						image.load(function(){
							emxUICategoryTab.redraw();
						});
					}},1);
			},

			activateTab: function(elemobj){
				var elemName = jQuery(elemobj).attr('name');
				jQuery('li.active','div#tabBar').removeClass("active");
				jQuery('li.active','div.menu-panel.overflow').removeClass("active");
				jQuery('span.checked','div.menu-panel.overflow').removeClass("checked");
				jQuery('li[name="'+elemName+'"]','div#tabBar').addClass("active");
				jQuery('li[name="'+elemName+'"]','div.menu-panel.overflow').addClass("active");
				jQuery('li[name="'+elemName+'"] span[class != "icon"]','div.menu-panel.overflow').addClass('checked');
				jQuery('div.menu-panel.overflow').hide();
				emxUICategoryTab.catObj.category = elemobj.item.text;
			},

			activatePanel: function(elemobj){
				var elemName = jQuery(elemobj).attr('name');
				jQuery('li.active','div#catMenu').removeClass("active");
				jQuery('li[name="'+elemName+'"]','div#catMenu').addClass("active");

				jQuery('li.more','div#catMenu').removeClass("active");

				emxUICategoryTab.catObj.category = elemobj.item.text;
			},

			createDOMPanel : function(menuObj){
				var uiAutomation = emxUIConstants.UI_AUTOMATION;
				var lfm = getTopWindow().jQuery("div#catMenu");
				lfm.html("<ul></ul>");
				var tab =   jQuery('ul','div#catMenu');
				var objli, objMenuLi, objThis;
				var  catObj = this;

				// setting tab-name and cachePage on first load of issue details
				if(menuObj.objectId != "null" && typeof menuObj.objectId != 'undefined' ){
					var defaultCategory;
					if(menuObj.defaultObjCategoryName){
	 					defaultCategory = menuObj.defaultObjCategoryName;
					}
					var contentFrame1 = getTopWindow().findFrame(getTopWindow(), "content");
					var currTab = contentFrame1.document.getElementsByName("detailsDisplay")[0];
	
					if(defaultCategory != "null" && typeof defaultCategory != 'undefined' ){
						currTab.parentElement.setAttribute('tab-name', defaultCategory);
					}else{
						currTab.parentElement.setAttribute('tab-name',menuObj.items[0].dynamicName);
					}
					
				}
				
				var lastTab;
				
				for (var cmd=0; cmd < menuObj.items.length; cmd++) {
					objThis = menuObj.items[cmd];
					if(objThis.grayout == "true"){
						continue;
					}

					if(objThis.isHeader == "true"){

						var divph = getTopWindow().document.getElementById("ExtpageHeadDiv");
						divph.innerHTML= objThis.text;
						continue;
					}

						/*Separator*/
					if(objThis.dynamicName == "separator"){
						if( lastTab != undefined && lastTab instanceof Object && lastTab.length > 0 && lastTab.get(0).className !="menu text-only divider"){
							objli = this.template.menu_separator();
							tab.append(objli);
							lastTab = objli;
						}
							continue;
					}
					
					/*end of separator*/
					if(objThis.items){
						 var mGroup = this.template.menu_group_category_expanded();
						 mGroup[0].setAttribute('id',objThis.text);
						 var dynamicName = objThis.dynamicName;
						 var mGroupHead = this.template.menu_group_head();
						 var headData;
					     if (objThis.text != undefined && objThis.text != "") {
							headData = jQuery('<label>' + objThis.text + '</label>');
							headData.attr('title', objThis.text);	
						 } else {
							headData = jQuery('<label>' + objThis.dynamicName + '</label>');
							headData.attr('title', objThis.dynamicName);	
						 }
						 
						 mGroupHead.attr("id",objThis.text);
						 mGroup.click(function(e){
								e.stopPropagation();
								e.preventDefault();

								emxUICore.addToClientCache(this);

								jQuery(this).closest(".menu").toggleClass("collapsed").toggleClass("expanded");
								adjustMenuHeight(jQuery(this).closest(".text-only"));
							});
						 mGroupHead.append(headData);
						 mGroup.append(mGroupHead);
						 mGroup.bind('expand',function(){
							jQuery(this).closest(".menu").toggleClass("collapsed").toggleClass("expanded");
							adjustMenuHeight(jQuery(this).closest(".text-only"));
						 });
						 
						 var grpUl = this.template.menu_ul();
						 for(var j=0; j < objThis.items.length; j++){
							 var childMenuITM = objThis.items[j]
							 label = childMenuITM.text;
							 var li;
							 if(childMenuITM.dynamicName == "separator"){
							 li = this.template.menu_separator();
							 }
							 else{
							 li= this.template.tabItem(childMenuITM.text, 'li_'+childMenuITM.dynamicName);
							 li.get(0).item = childMenuITM ;
							 li.click(function(e){
								e.stopPropagation();
								catObj.activatePanel(this);
								if(menuObj.isMD){
									getTopWindow().bclist.changeCategory('MyDesk',this);
								}else{
									getTopWindow().bclist.changeCategory(menuObj.objectId,this);
								}
								emxUICategoryTab.menu.itemClick(this.item, menuObj.isMD);
							});
							if(childMenuITM.text == menuObj.category){
								li.addClass('active');
							}}
							grpUl.append(li);
						 } 
						 mGroup.append(grpUl);
						 
						 objli = mGroup;
					}
					else{
						objli = this.template.tabItem(objThis.text, 'li_'+objThis.dynamicName);
						if(uiAutomation == 'true'){
							objli.attr('data-aid', objThis.dynamicName);
						}
						//objli.insertBefore(overflowButton);
						objli.get(0).item = objThis;
						objli.click(function(){
							catObj.activatePanel(this);
							if(getTopWindow().setUWAPref){
							getTopWindow().setUWAPref('DefaultCategory',this.item.dynamicName);
							}
							if(menuObj.isMD){
								getTopWindow().bclist.changeCategory('MyDesk',this);
							}else{
								getTopWindow().bclist.changeCategory(menuObj.objectId,this);
							}
							emxUICategoryTab.menu.itemClick(this.item, menuObj.isMD);
						});
						if(objThis.text == menuObj.category || (cmd == 0 && (menuObj.category == emxUIConstants.STR_BC_LABEL_HOME || typeof menuObj.category == 'undefined'))){
							objli.addClass('active');
						}
					}
					tab.append(objli);
					lastTab = objli;
				}
			},

			createDOM : function(menuObj){
				var uiAutomation = emxUIConstants.UI_AUTOMATION;
				//Add Overflow menu
				var menuBorder = this.template.menuBorder();
				jQuery('body').append(menuBorder);
				//Add overflow button
				this.addOverflow();

				var objul = jQuery('div.menu-panel.overflow').find("ul");
				var tab =   jQuery('ul','div#tabBar');
				var overflowButton = jQuery('li.icon-only','div#tabBar');
				var objli, objMenuLi, objThis;
				var  catObj = this;
				menuObj.totalWidth = overflowButton.outerWidth();
				for (var cmd=0; cmd < menuObj.items.length; cmd++) {
					objThis = menuObj.items[cmd];
					if(objThis.grayout == "true"){
						continue;
					}
					objli = this.template.tabItem(objThis.text, 'li_'+objThis.dynamicName);
					if(uiAutomation == 'true'){
						objli.attr('data-aid', objThis.dynamicName);
					}
					objli.insertBefore(overflowButton);
					objli.get(0).item = objThis;
					objli.click(function(){
						catObj.activateTab(this);
						getTopWindow().setUWAPref('DefaultCategory',this.item.dynamicName);
						emxUICategoryTab.menu.itemClick(this.item);
					});
					menuObj.totalWidth += (objli.outerWidth() + parseInt(objli.css('margin-right')));
					objMenuLi = this.template.menuItem(objThis.text, 'li_'+objThis.dynamicName);
					if(uiAutomation == 'true'){
						objMenuLi.attr('data-aid', objThis.dynamicName);
					}
					objul.append(objMenuLi);
					if(objThis.text == menuObj.category || (cmd == 0 && (menuObj.category == emxUIConstants.STR_BC_LABEL_HOME || typeof menuObj.category == 'undefined'))){
						objli.addClass('active');
						objMenuLi.addClass('active');	
						jQuery('span[class != "icon"]',objMenuLi).addClass('checked');
					}
					objMenuLi.get(0).item = objThis;
					objMenuLi.click(function(){
						catObj.activateTab(this);
						getTopWindow().setUWAPref('DefaultCategory',this.item.dynamicName);
						emxUICategoryTab.menu.itemClick(this.item);
						if(jQuery(this).hasClass("overflow") > -1){
							emxUICategoryTab.redraw();
						}
					});
					if(tab.width() < (menuObj.totalWidth)){
						objli.hide();
						objMenuLi.addClass("overflow");
					}  
				}
			}
		}
};


jQuery(document).ready(function() {
	
	function addListener(element, type, callback, capture) {
	    if (element.addEventListener) {
	        element.addEventListener(type, callback, capture);
	    } else {
	        element.attachEvent("on" + type, callback);
	    }
	}
	
	function draggable(element) {
	    var dragging = null;
		
		if(!getTopWindow().isIE){
			addListener(element,"pointerdown",function(e){
				var e = window.event || e;
				element.setPointerCapture(e.pointerId);
				dragging = {
					mouseX: e.clientX,
					mouseY: e.clientY,
					startX: parseInt(element.style.left),
					startY: parseInt(element.style.top)
				};
				if (element.setCapture) element.setCapture();
				e.preventDefault();
			});
			addListener(document,"pointerup",function(e){
				var e = window.event || e;
				dragging = null ;
				var elemName = document.getElementById("mx_divGrabber")
				elemName.releasePointerCapture(e.pointerId);
				if (document.releaseCapture) document.releaseCapture();
				e.preventDefault();
			},true);
			var dragTarget = element.setCapture ? element : document;
			addListener(dragTarget, "pointermove", function(e) {
				if (!dragging) return;
				
				var e = window.event || e;
				var top = dragging.startY + (e.clientY - dragging.mouseY);
				var left = dragging.startX + (e.clientX - dragging.mouseX);
				localStorage.setItem("userWidth", left);
				jQuery("#leftPanelMenu").css("width", left+"px");
				jQuery("#leftPanelTree").css("width", left+"px");
				jQuery( "#mx_divGrabber" ).draggable({ containment: "#leftPanelTree" });
				if(isMobile){
					jQuery("#pageContentDiv").css("left", left + jQuery('#mx_divGrabber').get(0).clientWidth + 27 + 'px');
				}else{
				jQuery("#pageContentDiv").css("left", left + jQuery('#mx_divGrabber').get(0).clientWidth + 10 + 'px');
				}
				jQuery("#mx_divGrabber").css("left", left + jQuery('#mx_divGrabber').get(0).clientWidth + 12 + 'px');
				
			}, true);
			addListener(element, "pointerout", function(e) {
				var e = window.event || e;
				dragging = null ;
				var elemName = document.getElementById("mx_divGrabber")
				elemName.releasePointerCapture(e.pointerId);
				if (element.releaseCapture) element.releaseCapture();
			});
		}//end of not IE browser
	    addListener(element, "mousedown", function(e) {
	        var e = window.event || e;
	        dragging = {
	            mouseX: e.clientX,
	            mouseY: e.clientY,
	            startX: parseInt(element.style.left),
	            startY: parseInt(element.style.top)
	        };
	        if (element.setCapture) element.setCapture();
	    });
		addListener(element, "losecapture", function() {
			dragging = null;
			if (element.releaseCapture) element.releaseCapture();
		});
	 
	    addListener(document, "mouseup", function() {
	        dragging = null;
			if (document.releaseCapture) document.releaseCapture();
	    }, true);
	 
	   var dragTarget = element.setCapture ? element : document;
	 
	    addListener(dragTarget, "mousemove", function(e) {
	        if (!dragging) return;
	 
	        var e = window.event || e;
	        var top = dragging.startY + (e.clientY - dragging.mouseY);
	        var left = dragging.startX + (e.clientX - dragging.mouseX);
			localStorage.setItem("userWidth", left);
	        //element.style.top = (Math.max(0, top)) + "px";
	        //element.style.left = (Math.max(0, left)) + 16 + "px";
	        
	        jQuery("#leftPanelMenu").css("width", left+"px");
			jQuery("#leftPanelTree").css("width", left+"px");
			if(isMobile){
				jQuery("#pageContentDiv").css("left", left + jQuery('#mx_divGrabber').get(0).clientWidth + 27 + 'px');
			}else{
			jQuery("#pageContentDiv").css("left", left + jQuery('#mx_divGrabber').get(0).clientWidth + 10 + 'px');
			}
			jQuery("#mx_divGrabber").css("left", left + jQuery('#mx_divGrabber').get(0).clientWidth + 12 + 'px');
	        
	    }, true);
	};
	 
	draggable(document.getElementById("mx_divGrabber"));
});

