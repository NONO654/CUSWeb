/*
 * Shortcut: BPS Component
 * emxUIShortcut.js
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 * emxUIShortcut Object
 * Draws and controls different facets such as Recently Viewed, Clipboard and other collections in shortcut panel
 * 
 */

var emxUIShortcut = {
	shortcutFrame:window,
    template: { 
    	facet:function(id,len){
    		var facet = jQuery('<div id=facet'+id+' class="facet shortcuts collapsed"></div>');
    		if(len==0){
    			facet.addClass("empty");
    		}
    		facet.hover(function(){
    			jQuery(this).toggleClass("hover");
    		});
    		return facet; 
    	},
        facet_head: function (facet_Info) {
        	var title = jQuery('<div class="facet-title"><button></button>'+ facet_Info.name + '</div>');
        	var head = jQuery('<div class="facet-head"></div>');
        	head.append(title); 
        	if(facet_Info.showClearButton == true && facet_Info.items.length > 0){
	        	var removeAll = jQuery('<div class="facet-functions"><ul><li><button class="remove-column" objectIds='+facet_Info.objectIds+'></button></li></ul></div>');
	        	head.append(removeAll);
	        	jQuery("button",removeAll).hover(function(){
	        		jQuery(this).attr("title", getTopWindow().emxUIConstants.SHORTCUT_REMOVEALL_BUTTON);
	        		jQuery(this).toggleClass("active");
	        	});
	        	jQuery("button",removeAll).click(function(e){
	        		if(!confirm(getTopWindow().emxUIConstants.SHORTCUT_REMOVEALL_MESSAGE)){
	        			return false;
	        		}
	        		var elem = jQuery(e.target);
	        		var facet = elem.parents('div.facet');
	        		var facetHead = elem.parents('div.facet-head');
	        		var facetContent = facetHead.siblings('div.facet-content');
	        		elem.closest('div.facet').addClass("empty");
	        		jQuery("div.facet-attr",facetContent).each(function() {
	        			var idArr = jQuery(this).attr("id");
	        			if(jQuery.inArray(idArr, getTopWindow().shortcut) > -1){
	        				getTopWindow().shortcut = emxUIShortcut._removeFromArray(idArr, getTopWindow().shortcut);
	        			}
	        		});
	        		
	        		var objectids =jQuery(this).attr("objectIds");
	            	var url="emxShortcutGetData.jsp?action=removeObject&objectId="+objectids;
	            	jQuery.ajax({  
	        		    url : url, 
	        		    cache: false
	        		}) 
	        		.success( function(json){ 
	            		facetContent.remove();
	        		});
	        	});
        	}
        	jQuery("button",title).click(emxUIShortcut._toggleContent);
        	return head;
        },
        facet_content: function() {
        	
        	return jQuery('<div class="facet-content"></div>');
        },
        facet_body: function() {
        	
        	return jQuery('<div class="facet-body"></div>');
        },
        
        facet_attr: function (id) {            
        	var attr = jQuery('<div id='+id+' class="facet-attr collapsed"></div>');
        	attr.hover(function(){
        		jQuery(this).toggleClass("hover");
        	});
        	return attr;
        	
        },
        facet_attr_head: function (itemObj, showClearButton) {
        	
        	var head = jQuery('<div class="facet-attr-head"></div>');
        	head.append(this.facet_attr_head_title(itemObj));
        	if(showClearButton == true) {
        		head.append(this.facet_attr_head_title_removeButton());
        	}
        	return head;
        },
        facet_attr_body: function () { 
        	
        	var attrBody =jQuery('<div class="facet-attr-body"></div>');
        	return attrBody;
        },
        facet_attr_body_category:function(categoryList,ulObj){
        	
        	for(var i=0;i<categoryList.length;i++)
        	{
        		var url = categoryList[i].url;
        		var label =categoryList[i].label;
        		if(label){
        			var icon = jQuery('<li url="'+url+'"><span class="icon"></span>'+label+'</li>');
        			if(url){
        			icon.click(emxUIShortcut._launchURLInContent);
        			}
        		}
        		ulObj.append(icon);
        		if(categoryList[i].categoryList){
        			var ul =this.facet_ul();
        			ulObj.append(ul);
        			this.facet_attr_body_category(categoryList[i].categoryList,ul);
        		}
        		
        		
        	}	
        
    	},
    	facet_attr_head_title: function (itemObj) {
        	var title = jQuery('<div class="facet-title"></div>');
        	var button = jQuery('<button id="'+itemObj.objectId+'"></button>');

        	button.click(emxUIShortcut._showCategory);
        	var icon = jQuery('<span class="icon"><img src="'+itemObj.icon+'"/></span>');
			var link = jQuery('<label class="link" url="'+itemObj.url+'">'+itemObj.label+'</label>');
			link.click(emxUIShortcut._launchURLInContent);
			     	
			title.append(button);
			title.append(icon);
			title.append(link);
			
        	return title;
        },
        facet_ul:function(){
        	return jQuery('<ul></ul> ');
        },
        facet_attr_head_title_removeButton: function () {
        	var rmfunction = jQuery('<div class="facet-functions"></div>');
        	
        	var liButton = jQuery('<li><button class="remove-column"></button></li> ');
        	jQuery("button",liButton).hover(function(e){
        		jQuery(this).attr("title", getTopWindow().emxUIConstants.SHORTCUT_REMOVE_BUTTON);
        		jQuery(this).toggleClass("hover");
        	});
			
        	liButton.click(function(e){
        		var elem = jQuery(e.target);
        		var facetbody = elem.closest("div.facet-body");
        		var facet = elem.closest("div.facet");
        		var idArr = elem.closest("div.facet-attr").attr("id");
        		if(jQuery("div.facet-attr", elem.parents("div.facet-body")).length == "1"){
        			facet.addClass("empty");
        		}
        		if(jQuery.inArray(idArr, getTopWindow().shortcut) > -1){
        			getTopWindow().shortcut = emxUIShortcut._removeFromArray(idArr, getTopWindow().shortcut);
        		}
        		var objectid =jQuery(' div.facet-title button',elem.closest('div.facet-attr-head')).attr("id");
            	var url="emxShortcutGetData.jsp?action=removeObject&objectId="+objectid;
            	jQuery.ajax({  
        		    url : url, 
        		    cache: false
        		}) 
        		.success( function(json){ 
        			elem.closest('div.facet-attr').remove();
        		});
        	});
        	
        	var ul =this.facet_ul();
        	rmfunction.append(ul);
        	ul.append(liButton);
			
        	return rmfunction;
        }
        
    },
    init: function (data) {   
    	this._processData(data);        
    	this._updateFacetState();
    	this._initializeOuterControls();
        
        
    },
    _processData:function(data){
    	if(data)
    	{
    		this._drawFacets(data);
    	}
    },
    _drawFacets: function (data) { //call draw for all quadrants
        
        for (var i=0;i<data.recentlyViewed.length;i++) {            
            this._drawFacet_section(data.recentlyViewed[i],0,data.recentlyViewed[0].items.length);
            
        }
        
        for (var i=0;i<data.collections.length;i++) {            
            this._drawFacet_section(data.collections[i],i+1,data.collections[i].items.length);
        }
    },
    _drawFacet_section: function (key,id,len) { //draw a single facet
    	var shortcutScetion = jQuery('div#divPageBody', this.shortcutFrame.document);
    	var facet = this.template.facet(id,len);
    	
    	facet.append(this.template.facet_head(key));
    	var facetContent = this.template.facet_content();
    	var facetBody = this.template.facet_body();
    	for(var i = 0;i<key.items.length;i++){
    	
    		var facetAttr = this.template.facet_attr('facet'+id+'_'+key.items[i].objectId);
	    	facetAttr.append(this.template.facet_attr_head(key.items[i], key.showClearButton));
	    	facetAttr.append(this.template.facet_attr_body());
	    	facetBody.append(facetAttr);
    	}
    	
    	facetContent.append(facetBody);
    	facet.append(facetContent);
    	shortcutScetion.append(facet);

    },
    _initializeOuterControls: function () { 
        jQuery('a.action-close').click(function (event) {
            event.preventDefault();
            try {
            	
                getTopWindow().closeShortcutDialog();                
            } catch (e) {
            }
        });
        jQuery('td#Shortcuts h2').text(getTopWindow().emxUIConstants.STR_SHORTCUTS);
        jQuery('a.action-close:odd').find("button").text(getTopWindow().emxUIConstants.STR_AUTO_FILTER_CLOSE);
		jQuery('a#helpLink').attr("title", emxUIConstants.STR_HELP_ICON);
    },
    _launchURLInContent:function(e){
    	var elem = e.target;
    	
    	var objectId =jQuery('div.facet-title button', jQuery(elem).closest('div.facet-attr-head')).attr("id");
    	if(objectId == null || objectId == "undefined"){
    		objectId = jQuery('div.facet-title button', jQuery(elem).parents('div.facet-attr-body').siblings('div.facet-attr-head')).attr("id");
    	}
    	emxUIShortcut._objectExists(elem,objectId,false);
    },
    _showCategory:function(e){
    	var elem = e.target;
    	var objectid =jQuery(elem).attr("id");
    	emxUIShortcut._objectExists(elem,objectid,true);
    	
    },
    _updateCategory:function(categoryJson,elem){
    	var facetAttr = jQuery(elem).parents('div.facet-attr');
    	var body = jQuery("div.facet-attr-body",facetAttr);
    	var ulObj = emxUIShortcut.template.facet_ul();
    	emxUIShortcut.template.facet_attr_body_category(categoryJson,ulObj);
    	body.append(ulObj);
    },
    _objectExists:function(elem,objectid,expand){
    	var url="emxShortcutGetData.jsp?action=doesObjectExist&objectId="+objectid;
    	jQuery.getJSON(url, function(json) {
    		var facetAttr = jQuery(elem).parents('div.facet-attr');
    		if(json.exists=="false"){    			
    			alert(getTopWindow().emxUIConstants.NO_OBJECT_ERROR);
    			jQuery(facetAttr).remove(); 
    	    }
    		else{
    			if(expand){
    				var body = jQuery("div.facet-attr-body",facetAttr);
    		    	var facetAttrId = facetAttr.attr("id");
	    			if(body.html()=="")
			    	{
			        	var url="emxShortcutGetData.jsp?action=getCategory&objectId="+objectid;
			        	jQuery.getJSON(url, function(json) {
			        		emxUIShortcut._updateCategory(json,elem);
			        	});
			        }
			    	
			    	facetAttr.toggleClass("expanded").toggleClass("collapsed");
			    	// Here we are pushing the objectid just expanded into the array 'getTopWindow().shortcut' which will be used to persist 
			    	//the expand/collapse status
			    	if(facetAttr.hasClass("expanded")){
			    		if(jQuery.inArray(facetAttrId, getTopWindow().shortcut)==-1){
			    				emxUIShortcut._addToArray(facetAttrId, getTopWindow().shortcut);// add the id into array
			    		}
			    	}
			    	else{
			    		if(jQuery.inArray(facetAttrId, getTopWindow().shortcut)> -1){
			    			getTopWindow().shortcut = emxUIShortcut._removeFromArray(facetAttrId, getTopWindow().shortcut);
			    		}
			    	}
    			}
    			else{
    				var url = jQuery(elem).attr("url");
    	    		getTopWindow().jQuery("iframe#content").attr("src",url);
    			}
    		}
    	});
    	
    },
    _toggleContent:function(){
    		var facet = jQuery(this).closest("div.facet");
    		var id =facet.attr('id');
    		// Here we are pushing the facetId just expanded into the array 'getTopWindow().shortcut' which will be used to persist 
        	//the expand/collapse status
    		if(jQuery.inArray(id, getTopWindow().shortcut) > -1){
    			getTopWindow().shortcut = emxUIShortcut._removeFromArray(id, getTopWindow().shortcut);
    		} else {
    				emxUIShortcut._addToArray(id, getTopWindow().shortcut);// add the id into array
    		}    		
    		facet.toggleClass("collapsed").toggleClass("expanded");
    },
    _updateFacetState:function(){
    	if(getTopWindow().shortcut.length == 0){
    			emxUIShortcut._addToArray("facet1", getTopWindow().shortcut);
    	}
		for(var i=0; i < getTopWindow().shortcut.length; i++){
			var facetid = getTopWindow().shortcut[i];
			var facet = jQuery("div[id=\""+facetid+"\"]");
			emxUIShortcut._expand(facet);
		}
    },
    _expand: function(elem){
    	
    	if(elem.hasClass("facet"))
    	{
    		elem.toggleClass("collapsed").toggleClass("expanded");
    	}
    	else if(elem.hasClass("facet-attr")){
    		jQuery("div.facet-title button",elem).click();	 
    	}
    },
    _removeFromArray: function(value, arr) { 
        return jQuery.grep(arr, function(elem, index) { 
            return elem !== value; 
        }); 
    },
    _addToArray: function(value, arr) { 
        return getTopWindow().shortcut[arr.length] = value ; 
    }
};

//LOAD
// This method id called during load event
// Here we read from the shortcut status bean and update the array getTopWindow().shortcut
function updateShortcutArray(shortcutList){
	getTopWindow().shortcut=shortcutList;
}


//UNLOAD
// This method is called during unload event
// Here we read from the array getTopWindow().shortcut and update the shortcut status bean
function updateShortcutPanelState(){
	var id= "";
	for(var i=0; i < getTopWindow().shortcut.length; i++){
			if(id==""){
				id=getTopWindow().shortcut[i];
			} else {
				id = id+"|"+getTopWindow().shortcut[i];
		}
	}
	updateShortcutMap("facetState",id);
}


