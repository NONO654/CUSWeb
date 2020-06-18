/*
 * Compass Refinements BPS Component *** customized ***
 * emxUIAutoFilter.js
 * version 1.2.4
 *
 * Copyright (c) 1992-2013 Dassault Systemes.
 * All Rights Reserved.
 * This program contains proprietary and trade secret information of Dassault Systemes
 * Copyright notice is precautionary only
 * and does not evidence any actual or intended publication of such program
 * ------------------------------------------------------------------------
 * emxUIAutoFilter Object
 * Controls filtering of structure browser data via facets and
 * compass sectors (who, what, why/how, when and where)
 *
 * Requires:
 * emxUICore.js and other standard BPS common js libraries,
 * jQuery v1.6.2 or later
 * and a valid structure browser instance with reference(e.g. top.sb)
 *
 */
var sbWindow = top.sb ? top.sb : (top.opener.top.sb ? top.opener.top.sb : null);
var emxUIAutoFilter = {
    id: null, // uid for the current slidein
    sb_id: null, // this id is to link ids with the SB timeStamp
    sb: null, // pointer to structure browser window
    constants: null, // pointer to emxUIConstants object
    slideInFrame: window, // this window
    current_color_btn: null, // the currently active color control
    //sbMode: isIE ? (emxUICore.selectSingleNode(sbWindow.oXML, "/mxRoot/setting[@name = 'sbMode']")).text : getRequestSetting("sbMode"),
    sbMode: isIE ? (emxUICore.selectSingleNode(sbWindow.oXML, "/mxRoot/setting[@name = 'sbMode']")).text : (emxUICore.selectSingleNode(sbWindow.oXML, "/mxRoot/setting[@name = 'sbMode']")).textContent,

    colIdxSelectedItemsMap: {},	
    		
    		
    _set_id: function (id) {
        this.id = id;
    },
    _get_id: function () {
        return this.id;
    },
    template: { //html templates for the filters
        facet: function () {
            return jQuery('<div id="Refinement" class="facet"></div>');
        },
        facet_form: function (id) {
            return jQuery('<div id='+id+' class="facet form"></div>');
        },
        facet_content: function () {
            return jQuery('<div class="facet-content"></div>');
        },
        facet_body: function (data) {
        	var custname = data ? "id="+data.name :"";
            return jQuery('<div class="facet-body" '+custname+'></div>');
        },
        facet_attr: function (obj) {
            return jQuery('<div class="facet-attr ' + obj.state + '" col-index="' + obj.index + '"></div>');
        },
        facet_attr_head: function (value) {
            return jQuery('<div class="facet-attr-head"><div class="facet-title"><button></button><label>' + value + '</label></div></div>');
        },
        /*facet_attr_body: function () {
            return jQuery('<div class="facet-attr-body"></div>');
        },*/
        facet_attr_body: function (id) {
            return jQuery('<div class="facet-attr-body" id="' + id + '" ></div>');
        },
        
        facet_select_all: function (label) {
            return jQuery('<span class="select-all"><a class="checkbox"></a><label>' + label + '</label></span>');
        },
        facet_list: function () {
            return jQuery('<ul></ul>');
        },
        facet_list_item: function (obj) {
            return jQuery('<li><a class="checkbox ' + obj.checked + '" columnIndex="' + obj.columnIndex + '" valueIndex="' + obj.valueIndex + '"></a><label><span class="value">' + obj.value + '</span> (' + obj.count + ')</label></li>');
        },
        facet_list_item_more: function (obj) {
            return jQuery('<li><a class="checkbox" column="' + obj.column + '"></a><label><span class="value">' + obj.label + '</span></label></li>');
        },
        facet_list_item_from_progHtml: function (obj) {
            return jQuery('<li><a class="checkbox ' + obj.checked + '" columnIndex="' + obj.columnIndex + '" valueIndex="' + obj.valueIndex + '"></a><div class="prg-html">' + obj.value + ' (' + obj.count + ') </div></li>');
        }
        
        
        ,
        facet_search_panel: function () {
            return jQuery('<div ></div>');
        },
        facet_search_input: function (id) {
            return jQuery('<input type="text" id="' + id + '" />');
        },
        facet_selected_tag: function (name, colIdx) {
            return jQuery('<div style="border:1px solid grey;border-radius:4px;display:inline;margin-left:2px;padding-left:2px;" colIdx=' + colIdx + ' >' + name + '<img src="../common/images/buttonMiniDeleteParam.gif"  /></div>');
        }
        
    },
    init: function () {
        this._initPointers(); //set external pointers on the top window e.g. top.sb
        this._initLocals(); //local pointers to sb and constants within emxUIAutoFilter
        this._setupStateListeners();
        this.sb.bpsSBFilter.rebuildFacets(this.sb.oXML);
        this._drawUI();
        this._initializeOuterControls(); //initialize reset, and close controls
        this._reDrawSB();
        
        setTimeout(function(){
        	emxUIAutoFilter.cmdEnableDisableByMode(emxUIAutoFilter.sbMode);
        },1);
    },
    
    columnIndx:null,
    columnkeyInValue:null,
    		
    _set_keyIn_colIdx: function(colIdx){
    	this.columnIndx = colIdx;
    },
    _set_keyIn_columnkeyInValue: function(columnkeyInValue){
    	this.columnkeyInValue = columnkeyInValue;
    },
    
    _get_keyIn_colIdx: function(){
    	return this.columnIndx;
    },
    _get_keyIn_columnkeyInValue: function(){
    	return this.columnkeyInValue;
    },
    
    
    getRefinementColumns: function (objXml) {
        var columnChilds = emxUICore.selectNodes(objXml, "/mxRoot/columns/column[settings/setting[@name='" + this.sb.bpsSBFilter.autoFilterSetting + "']/text() != 'false']");
        //var columnChilds = emxUICore.selectNodes(objXml, "/mxRoot/columns/column[settings/setting[not ( @name='" + 
        //		this.sb.bpsSBFilter.autoFilterSetting + "' ) ]]");
        //var columnChilds3 = emxUICore.selectNodes(objXml, "/mxRoot/columns/column[settings/setting[@name='" + 
        //		this.sb.bpsSBFilter.autoFilterSetting + "']/text() == undefined || @name='" + 
        	//	this.sb.bpsSBFilter.autoFilterSetting + "']/text() != 'false']");
        return columnChilds;
    },
    _initPointers: function () { //initialize pointers to components
        if (!top.sb && top.opener.top.sb) { //tests if we are in a popup
            top.sb = top.opener.top.sb;
            top.emxUIConstants = top.opener.top.emxUIConstants;
            top.closeSlideInDialog = function () {
                top.close();
            };
        }
        top.autoFilterWindow = window;
    },
    _initLocals: function () { //local pointers
        this.sb = top.sb;
        this.constants = top.emxUIConstants;
        this.closeSlideInDialog = top.closeSlideInDialog;
    },
    _setupStateListeners: function () { //Event pooling for commonly updated states
        var objThis = this;
        jQuery(this.sb.document).bind('UPDATE_FACET_ATTR_STATE', function (e, data) {
            objThis._updateFacetAttrState(e, data);
        });
    },
    _syncFilterToSB: function (binder, data) { // check if this is the right filter for the current SB
        if (data && data.timeStamp) {
            if (data.timeStamp !== this.sb_id){
                top.sb = data;
                this.refreshFilterView();
            }
        }
    },
    _updateFacetAttrState: function (binder, data) { //update the oXML "model" with the column(facet attribute)'s state
        var index = parseInt(data.attr('col-index')) + 1,
            className = data.hasClass('expanded') ? 'expanded' : 'collapsed';
        var column = this.sb.emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/columns/column[" + index + "]");
        column.setAttribute('state', className);
    },
    _drawUI: function (fromReset) { //this is our view. Draw quadrants which in turn draw their own sections
        this._drawRefinements(fromReset);
        this._initializeInnerControls();
        this._linkToSB();
        this._retainKeyIn();
    },
    _linkToSB: function () {
        this.sb_id = this.sb.timeStamp;
    },
    _retainKeyIn: function (fromReset) {
    	if(this.columnkeyInValue != "undefined" && this.columnkeyInValue != null && this.columnkeyInValue != "null"){
    		var temp_colIndex = window.document.getElementById(this.columnIndx); 
    		if(temp_colIndex != null)temp_colIndex.value = this.columnkeyInValue;
    		if(temp_colIndex != null && temp_colIndex.value!= ""){
            	$(temp_colIndex).keyup();
    		}
    	}
    },
    _drawRefinements: function (fromReset) {
    	//To Reset the Custom Filters to their initial values
    	if(fromReset && fromReset == true){
    	}
    	
    	//Clear all the Refinments
    	jQuery('div#Refinement').remove();
    	
        var quadrant_DOM = this.template.facet_body();
        //build a quadrant and pass the quadrant_DOM to the filter drawing method
        var templateDiv = jQuery(this.template.facet().append(this.template.facet_content().append(quadrant_DOM)));
        
        var custToolbarDiv = jQuery('div#FilterBody', this.slideInFrame.document);       
        
        var isTypeFilterDrawn = jQuery('div#TypeRelFilter').html()? true : false;
        
        if(!isTypeFilterDrawn){
       
        var isTypeRelFilterPassed = false;
        var typeFilterSetting = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/requestMap/setting[@name='typeFilter']");
        var typeFilter;
        if(typeFilterSetting) {
        	typeFilter = isIE ? typeFilterSetting.text : typeFilterSetting.textContent;
        }
        
        var relFilterSetting = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/requestMap/setting[@name='relationshipFilter']");
        var relFilter;
        if(relFilterSetting) {
        	relFilter = isIE ? relFilterSetting.text : relFilterSetting.textContent;
    		}
        
        var dirFilterSetting = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/requestMap/setting[@name='directionFilter']");
        var dirFilter;
        if(dirFilterSetting) {
        	dirFilter = isIE ? dirFilterSetting.text : dirFilterSetting.textContent;
        }
        
        if(typeFilter == "true" || relFilter == "true" || dirFilter == "true"){

        	//Create JSON data reading the values and pass to _drawCustToolbar()
        	var toolbarJsonArr  = [{"name":"TypeRelFilterBody", "items":[]}];
        	
        	var data1 = this._getTypeRelFilterData(toolbarJsonArr, typeFilter, relFilter, dirFilter);

        	for(i=0; i <data1.length; i++){ 
	        	var toolbarItems1 = emxCustomToolbar.template.facet_ul();
				var form1 = jQuery(this.template.facet_form("TypeRelFilter"));
				var foot1 = jQuery(emxCustomToolbar.template.facet_foot());
				var body1 =jQuery(this.template.facet_body(data1[i]));
				form1.append(body1.append(toolbarItems1));
				form1.append(foot1);
				custToolbarDiv.append(form1);
				emxCustomToolbar._drawCustToolbarItems(toolbarItems1, foot1, data1[i]);
			}
        }
       }//isTypeFilterDrawn
		
		custToolbarDiv.append(templateDiv);
        this._drawFilterSections(quadrant_DOM, fromReset);
    },
    _getTypeRelFilterData: function(toolbarJsonArr, typeFilter, relFilter, dirFilter){
   	
    	var label;
    	var inpType;
    	var defaultValue;
    	
    	// typefilter
    	if(typeFilter){
    		var comboboxOptions = [];
    		var comboValues = emxUICore.selectNodes(this.sb.oXML, "/mxRoot/tableControlMap/setting[@name='TypeFilter']/items/item");
    		
    		var TypeL = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/tableControlMap/setting[@name='Labels']/items/item[@name='Type']/value");
    		var typeLabel = isIE ? TypeL.text : TypeL.textContent;
    		
    		var defaultValueSettings = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/requestMap/setting[@name='selectedType']");
    		var defaultValue;
    		if(defaultValueSettings){
    			defaultValue = isIE ? defaultValueSettings.text : defaultValueSettings.textContent;
            }                
    	
    		for(var i=0; i<comboValues.length; i++){
    			var value = isIE ? comboValues[i].text : comboValues[i].textContent;
    			var label = comboValues[i].getAttribute("name");
    			
    			if(!emxCustomToolbar.isNotNullOrEmpty(defaultValue)){
    				if(value == "*" || value.indexOf(",") > 0 ){
    					defaultValue = label;
    				}
    			}
    			comboboxOptions.push({
    				"fieldChoiceDisplay":label,
    				"fieldChoice":value
    			});	
            }
    		
    		var controlParams = {
            		"displayText": typeLabel,
            		"defaultValue": defaultValue
            	};
    		
    		toolbarJsonArr[0].items.push({ 
                "name" : "select_type",
                "inpType" : "combobox",
                "comboboxOptions" : comboboxOptions,
                "controlParams" :controlParams
            });        	
    	}
    	
    	// relFilter
    	if(relFilter){
    		
    		var comboboxOptions = [];
    		var comboValues = emxUICore.selectNodes(this.sb.oXML, "/mxRoot/tableControlMap/setting[@name='RelationshipFilter']/items/item");
    		
    		var relationL = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/tableControlMap/setting[@name='Labels']/items/item[@name='Relationship']/value");
    		var relLabel = isIE ? relationL.text : relationL.textContent;
    		var defaultValueSettings = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/requestMap/setting[@name='selectedRelationship']");
    		var defaultValue;
    		if(defaultValueSettings){
    			defaultValue = isIE ? defaultValueSettings.text : defaultValueSettings.textContent;
    		}
    		
    		for(var i=0; i<comboValues.length; i++){
    			var value = isIE ? comboValues[i].text : comboValues[i].textContent;
    			var label = comboValues[i].getAttribute("name");
    			
    			if(!emxCustomToolbar.isNotNullOrEmpty(defaultValue)){
    				if(value == "*" || value.indexOf(",") > 0 ){
    					defaultValue = label;
    				}
    			}
    			
    			comboboxOptions.push({
    				"fieldChoiceDisplay":label,
    				"fieldChoice":value
    			});	
    		}
    		
    		var controlParams = {
            		"displayText": relLabel,
            		"defaultValue": defaultValue
            	};
    		
    		toolbarJsonArr[0].items.push({ 
                "name" : "select_relationship",
                "inpType" : "combobox",
                "comboboxOptions" : comboboxOptions,
                "controlParams" :controlParams
            });        	
    		}    		
    	
    	// dirFilter
    	if(dirFilter){
    		var tLabel = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/tableControlMap/setting[@name='Labels']/items/item[@name='to']/value");
    		var toLabel = isIE ? tLabel.text : tLabel.textContent;
    		var fLabel = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/tableControlMap/setting[@name='Labels']/items/item[@name='from']/value");
    		var fromLabel = isIE ? fLabel.text : fLabel.textContent;
    		
    		var direction = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/requestMap/setting[@name = 'direction']");
    		var directionValue;
    		if(direction){
    			directionValue = isIE ? direction.text : direction.textContent;
    		}
    		var defaultValue = (("both" == directionValue) || ("to"==directionValue))? "true" : "false";
    		
    		var controlParams = {
            		"defaultValue": defaultValue,
            		"displayText": toLabel,
            		"typeRelFilter": "true"
            	};
    		
    		toolbarJsonArr[0].items.push({ 
                "name" : "to",
                "inpType" : "checkbox",
                "controlParams" :controlParams
            });
    		
    		defaultValue = ("from"==directionValue)? "true": "false";
    		var controlParams = {
            		"defaultValue": defaultValue,
            		"displayText": fromLabel,
            		"typeRelFilter": "true"
            	};
    		
    		toolbarJsonArr[0].items.push({ 
                "name" : "from",
                "inpType" : "checkbox",
                "controlParams" :controlParams
            });
    		
    		
    	}
    	
    	// Submit button
    	var buttonLabel = emxUICore.selectSingleNode(this.sb.oXML, "/mxRoot/tableControlMap/setting[@name='Labels']/items/item[@name='Refresh']/value");
    	var label = isIE ? buttonLabel.text : buttonLabel.textContent;
    	var controlParams = {
        		"defaultValue": label,
        		"title": label,
        		"displayText": label,
        		"typeRelFilter": "true"
        	};
		
		toolbarJsonArr[0].items.push({ 
            "name" : "",
            "inpType" : "submit",
            "controlParams" :controlParams
        }); 
		
		
    	
    	return toolbarJsonArr;
    },
    _drawFilterSections: function (quadrant, fromReset) { // generate AF unique values per AF column.
        // loop through top.sb.oXML/and column map to draw filters
        var columnChilds = jQuery.makeArray(this.getRefinementColumns(this.sb.oXML));
        var colLen = columnChilds.length,
            i = 0;
        
        var AFObj = this;
        var colIdxItemsMap = {};
        
        
        for (; i < colLen; i++) { //get or set column state for expand/collapse of facet section
            var column = columnChilds[i];
            var column_state = column.getAttribute('state');
            if (!column_state) {
                column_state = 'expanded';
                column.setAttribute('state', 'expanded');
            }
            //create the section DOM parts
            var uniqueValues = this.sb.emxUICore.selectSingleNode(column, "uniquevalues");
            if (!uniqueValues){
                continue;
            }
            var colIndex = uniqueValues.getAttribute('index'); //this is the column index
            var section = this.template.facet_attr({
                index: colIndex,
                state: column_state
            });
            var heading_label = column.getAttribute('label').replace(/&lt;/g, "<").replace(/&gt;/g, ">");
            var heading = this.template.facet_attr_head(heading_label);
            var content_body = this.template.facet_attr_body("body_" + colIndex);
            //var select_all = this.template.facet_select_all(this.constants.STR_AUTO_FILTER_SELECT_ALL);
            var list = this.template.facet_list();
            
            var searchPanel = this.template.facet_search_panel();
            var searchInput = this.template.facet_search_input(colIndex);
            
            //build a section from DOM parts
            
            //section.append(heading).append(content_body);
            section.append(heading).append(searchPanel);
            section.append(content_body);
            
            searchPanel.append(searchInput);
            
                        
            var allItemList = [];
            
            
            //content_body.append(select_all);
            content_body.append(list);
            //add unique list items to this section
            var values = this.sb.emxUICore.selectNodes(uniqueValues, "c"),
                j = 0,
                valLen = values.length;
            for (; j < valLen; j++) {
                var selected = values[j].getAttribute("selected");
                var count = values[j].getAttribute("count");
                if (count == 0) {
                    continue;
                }
                var cellValue = this.sb.getCellValue(values[j]) || this.constants.STR_AUTO_FILTER_BLANK;
                var checked = "";
                if (selected != null && selected == "yes") {
                    checked = "selected";
                }
                var listItem,
                    objListItem = {
                    'columnIndex': colIndex,
                    'valueIndex': j,
                    'value': cellValue,
                    'count': count,
                    'checked': checked
                };
                
                var columnType = column.getAttribute('type');
                if (columnType == "programHTMLOutput") {
                    listItem = this.template.facet_list_item_from_progHtml(objListItem);
                } else {
                    listItem = this.template.facet_list_item(objListItem);
                }

                list.append(listItem);
                
                
                allItemList.push(listItem);
                
            }
            colIdxItemsMap[colIndex] = allItemList;
            
            searchInput.keyup(function (event) {
                //event.preventDefault();
                var colIdx = this.id;
                AFObj._set_keyIn_colIdx(colIdx);
                
                var listContainer = jQuery('#body_' + colIdx);
                listContainer.empty();
                var newList = AFObj.template.facet_list();
                listContainer.append(newList);
                
                var origItemsList = colIdxItemsMap[colIdx];
                var listLen = origItemsList.length;
            	var convertedStr = AFObj._getConvertedStrForSearch(this.value);
            	AFObj._set_keyIn_columnkeyInValue(this.value);
            	for (var indx = 0; indx < listLen; indx++) {
            			jQuery(origItemsList[indx]).hide();
                }
            	
                for (var indx = 0; indx < listLen; indx++) {
                	//alert(jQuery(origItemsList[indx]).find('span').text());
                	var re = new RegExp(convertedStr, "i");
                	if (re.test(jQuery(origItemsList[indx]).find('span').text())) {//bug: TODO: consider proghtml also
                		jQuery(origItemsList[indx]).show();
                	}
                		newList.append(origItemsList[indx]);
                	}
                	Newcolindex = 	AFObj.columnIndx;
                
                	
                
                	jQuery('div.facet-attr-body ul li a.checkbox').each(function(item){
                		if($(this).attr("columnindex") == Newcolindex)
                		$(this).click(function (event) {
                    event.preventDefault();                    
                    AFObj._checkUncheckBoxes(this);
                });
                	})         
                
            });
            
            if(fromReset)
            {
            	this.colIdxSelectedItemsMap = {};
            }
            else
            {
            	var selectedItems = this.colIdxSelectedItemsMap[colIndex];
                if(selectedItems != null){
                	 for(var tagIdx = 0; tagIdx < selectedItems.length; tagIdx++){
                		 
                		 var currentoptiontorender =selectedItems[tagIdx];
                		 var listLen = colIdxItemsMap[colIndex].length;
                		 var found = false;
                		 for (var indx1 = 0; indx1 < listLen; indx1++) {
                 			 if( currentoptiontorender == jQuery(colIdxItemsMap[colIndex][indx1]).find('span').text())found = true;
                     }
                		 
                		 
                		 if(found == false){
                			 //var index = selectedItems.indexOf(currentoptiontorender);
                			 //this.colIdxSelectedItemsMap[colIndex].splice(index,1);
                			 continue;}
                		 var tagItem = this.template.facet_selected_tag(selectedItems[tagIdx], colIndex);
                		 searchPanel.append(tagItem);
                		 
                		 tagItem.click(function (event) {
                             event.preventDefault();
                             
                             //alert(this.getAttribute("colIdx"));
                             var colIdx = this.getAttribute("colIdx");
                             
                             var origItemsList = colIdxItemsMap[colIdx];
                             var listLen = origItemsList.length;
                             var eventhandled= true;
                             for (var indx = 0; indx < listLen; indx++) {
                             	if (jQuery(origItemsList[indx]).find('span').text() == jQuery(this).text()) {//bug: TODO: consider proghtml also
                             		jQuery(origItemsList[indx]).find('a.checkbox').triggerHandler("click");       
                             		eventhandled = false;
                             	}
                             }                 
                             if(eventhandled == true)
                            	 {
                            	 AFObj._setFilterIcons();
                            	 AFObj._reDrawSB();
                            	 AFObj._drawUI();                           	 
                            	 }
                         });
                     }
                }
            }
            
            
            //add the section to the quadrant
            quadrant.append(section.get(0));
        }
    },
    
    
    _getConvertedStrForSearch: function (str) {
    	if(str == '')
    		return str;
        return ".*" + str.replace(/\*/g, '.*') + ".*";
    },
    
    
    
    _initializeInnerControls: function () { //initializes all facet actions
        var objThis = this;
        // toggle the inner sections
        jQuery('div.facet-attr-head div.facet-title button').click(function (event) {
            event.preventDefault();
            jQuery(this).closest('div.facet-attr').toggleClass('expanded').toggleClass('collapsed');
            jQuery(document).trigger('UPDATE_FACET_ATTR_STATE', [jQuery(this).closest('div.facet-attr')]);
        });
        // set colorize click controls
        jQuery('div.facet-functions button.colorize').click(function (event) {
            event.preventDefault();
            var isActive = jQuery(this).hasClass('active');
            //remove all facet-functions active states
            jQuery('div.facet-functions button.colorize.active, div.facet-functions.active').removeClass('active hover');
            if (isActive) { //turning current button off
                objThis.current_color_btn = null;
                jQuery(this).addClass('hover');
            } else { //turning current button on
                objThis.current_color_btn = this;
                jQuery(this).addClass('active')
                        .closest('div.facet-functions').addClass('active');
            }
            objThis.sb.bpsSBFilter.applyFacetColors(objThis.sb.oXML, this.getAttribute('colIndex'));
            objThis._reDrawSB();
        });
        // set colorize hover controls
        jQuery('div.facet-functions button.colorize').hover(function () {
            if (objThis.current_color_btn !== this) { //don't hover on current button
                jQuery(this).toggleClass('hover');
            }
        });
        // set show hide for facet functions
        jQuery('div.facet-attr').hover(function () {
            jQuery(this).toggleClass('hover');
        });
        // check / uncheck boxes
        jQuery('div.facet-attr-body ul li a.checkbox').click(function (event) {
            event.preventDefault();
            
            objThis._checkUncheckBoxes(this);
            
           /* jQuery(this).toggleClass("selected");
            // set select all accordingly
            var section = jQuery(this).closest('div.facet-attr-body');
            // if the checkbox.length = checkbox.selected.length then select all
            jQuery('span.select-all a.checkbox', section).toggleClass('selected', (jQuery('li a.checkbox', section).length == jQuery('li a.checkbox.selected', section).length));
            objThis._applyFilterSelections(this);*/
        });
        // check or uncheck via label
        jQuery('div.facet-attr-body ul li a.checkbox + label').click(function (event) {
            event.preventDefault();
            jQuery(this).prev('a.checkbox').triggerHandler("click");
        });
        // set filter body's top, just below the header
        jQuery('#FilterBody').css("top", jQuery('.page-head').children().height());
    },
    
    
    _checkUncheckBoxes: function (checkboxElem) {
    	 jQuery(checkboxElem).toggleClass("selected");
    	 
    	 //alert(jQuery(checkboxElem).closest('li').find('span').text());
    	 //alert(jQuery(checkboxElem).hasClass("selected"));
    	 //alert(checkboxElem.getAttribute("columnIndex"));
    	 
    	 var selectedItems = this.colIdxSelectedItemsMap[checkboxElem.getAttribute("columnIndex")];
		 if(selectedItems == null){
			 selectedItems = [];
			 this.colIdxSelectedItemsMap[checkboxElem.getAttribute("columnIndex")] = selectedItems;
		 }
		 var newSelectedOne = jQuery(checkboxElem).closest('li').find('span').text();
		 
		 if(jQuery(checkboxElem).hasClass("selected")){    		 
    		 selectedItems.push(newSelectedOne);
        }
    	 else{
    		 selectedItems.splice( selectedItems.indexOf(newSelectedOne), 1 );
    	 }
    	 
    	 //alert(checkboxElem.getAttribute("valueIndex"));
    	 
         // set select all accordingly
         var section = jQuery(checkboxElem).closest('div.facet-attr-body');
         
         
    	 
         
         // if the checkbox.length = checkbox.selected.length then select all
         jQuery('span.select-all a.checkbox', section).toggleClass('selected', (jQuery('li a.checkbox', section).length == jQuery('li a.checkbox.selected', section).length));
         this._applyFilterSelections(checkboxElem);
    },
    
    
    _initializeOuterControls: function () { //initializes controls like reset and close on the slidein
        // close slide-in
        var objThis = this;
        jQuery('a.action-close').click(function (event) {
            event.preventDefault();
            try {
                objThis.closeSlideInDialog();
            } catch (e) {
                // do nothing
                // this is to trap a jquery defect and does not effect functionality
            }
        });
        // reset the page
        jQuery('a.action-reset').click(function (event) {
            event.preventDefault();
            jQuery('a.selected').removeClass('selected');
            emxUIAutoFilter.sb.bpsSBFilter.resetFacets(emxUIAutoFilter.sb.oXML);
            emxUIAutoFilter._set_keyIn_columnkeyInValue("");
            emxUIAutoFilter._drawUI("true");
            emxUIAutoFilter._setFilterIcons();
            emxUIAutoFilter._reDrawSB();
        });
        // set localized strings

        if("" == this.sb.FreezePaneUtils.getCurrentChannelName()){
        jQuery('td#refinementTitle h2').text(this.constants.STR_AUTO_FILTER_SELECTIONS);
        }else{
        	jQuery('td#refinementTitle h2').text(this.sb.FreezePaneUtils.getCurrentChannelName() +" - "+ this.constants.STR_AUTO_FILTER_SELECTIONS);
        }
        jQuery('a.action-reset:odd').text(this.constants.STR_AUTO_FILTER_RESET);
        jQuery('a.action-close:odd').text(this.constants.STR_AUTO_FILTER_CLOSE);
        jQuery('a#helpLink').attr("title",this.constants.STR_HELP_ICON);
    },
    _applyFilterSelections: function (obj) { //build a map of checkbox objects and pass to filtering method
        /*var selectionObj = {
                'columnIndex': obj.getAttribute("columnIndex"),
                'select': jQuery(obj).hasClass('selected'),
                'valueIndex': obj.getAttribute("valueIndex")
            }*/
		var selectionObj = [];
    		selectionObj.push({
                'columnIndex': obj.getAttribute("columnIndex"),
                'select': jQuery(obj).hasClass('selected'),
                'valueIndex': obj.getAttribute("valueIndex")
                });
            	
        this.sb.bpsSBFilter.processNewUserSelections(this.sb.oXML, selectionObj);
        this._setFilterIcons();
        this._reDrawSB();
        this._drawUI();
    },
    _setFilterIcons: function () {
        jQuery('td.filtered.status',[top.sb.editableTable.divListHead, top.sb.editableTable.divTreeHead]).removeClass('filtered status');
        var filteredCols = jQuery('column[userfiltered = "true"]', top.sb.oXML);
        if (filteredCols.length > 0){
            filteredCols.each(function(){
                var colName = this.getAttribute('name');
                jQuery('th[id="' + colName + '"]', [top.sb.editableTable.divListHead, top.sb.editableTable.divTreeHead]).find('td[id="' + colName + '_filter"]').addClass('filtered status');
            });
        }
    },
    _reDrawSB: function () { //process user clicks as selections are made.
        // selectionMap should include all column selections
        // even if none were selected in order to properly update xml with current selections.
        //clear filter icons first
		//need to add timeout to wait for loading the new SB
    	setTimeout(function () {
        this.sb.FreezePaneUtils.adjustTableColumns();
        this.sb.processRowGroupingToolbarCommand();
// needs a small timeout for the iPad
        this.sb.rebuildView();
			}, 100);
    },
    refreshFilterView: function () {
        this._initPointers(); //set external pointers on the top window e.g. top.sb
        this._initLocals(); //local pointers to sb and constants within emxUIAutoFilter
        this.sb.bpsSBFilter.rebuildFacets(this.sb.oXML);
        this._drawUI();
    },
    isRefined: function () {  //check if refinements have been made to the xml.
        this._initPointers(); //set external pointers on the top window e.g. top.sb
        this._initLocals(); //local pointers to sb and constants within emxUIAutoFilter
        return this.sb.bpsSBFilter.isDataRefined(this.sb.oXML);
    },
    cmdEnableDisableByMode: function(mode){
    	if(mode == "view"){
    		this.commandEnable(top.sb.emxCustomToolbar.viewModeCmds);
    		this.commandDisable(top.sb.emxCustomToolbar.editModeCmds);
    	}else{
    		this.commandEnable(top.sb.emxCustomToolbar.editModeCmds);
    		this.commandDisable(top.sb.emxCustomToolbar.viewModeCmds);
    	}
    },
    commandEnable: function(cmdList){
    	for(var i=0; i < cmdList.length; i++){ 
			var id = "#"+cmdList[i];
			var element = jQuery(id);
			if(element.is('button')){
				element.removeAttr('disabled');
			}else{
			element.removeClass('disabled');
			element.addClass('enabled');
			jQuery(":input",element).removeAttr('disabled');
			
			var anchorElement = jQuery('a', element);
			if(anchorElement != "undefined" && anchorElement != null && anchorElement != "null"){
				var hrefBackup = anchorElement.attr('href_bak');
				if(emxCustomToolbar.isNotNullOrEmpty(hrefBackup)){
					anchorElement.attr('href', hrefBackup);
					anchorElement.removeAttr('href_bak');
					if(hrefBackup.indexOf("javascript:showCalendar") > -1){
			        	jQuery('img', anchorElement).attr('src', '../common/images/iconSmallCalendar.gif');
			        }
				}    
			}
		}
		}
    },
    commandDisable: function(cmdList){
    	for(var i=0; i < cmdList.length; i++){
			var id = "#"+cmdList[i];
			var element = jQuery(id);
			if(element.is('button')){
				element.attr('disabled','true');
			}else{
			element.removeClass('enabled');
			element.addClass('disabled');
			jQuery(":input",element).attr('disabled','true');
			
			var anchorElement = jQuery('a', element);
			if(anchorElement != "undefined" && anchorElement != null && anchorElement != "null"){
				var href = anchorElement.attr('href');
				if(emxCustomToolbar.isNotNullOrEmpty(href)){
					anchorElement.attr('href_bak', href);
		        	anchorElement.removeAttr('href');
			        if(href.indexOf("javascript:showCalendar") > -1){
			        	jQuery('img', anchorElement).attr('src', '../common/images/iconSmallCalendarDisabled.gif');
			        }
				}
			}
			}
		}
    }
};

// onload initialization
jQuery(document).ready(function (jQuery) {
    try {
        emxUIAutoFilter.init();
    } catch (e) {
        alert(e);
    }
});
