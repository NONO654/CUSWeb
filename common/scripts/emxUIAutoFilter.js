/*
 * Compass Refinements BPS Component
 * emxUIAutoFilter.js
 * version 1.2.4
 *
 * Copyright (c) 1992-2018 Dassault Systemes.
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
 * and a valid structure browser instance with reference(e.g. getTopWindow().sb)
 *
 */
var sbWindow = getTopWindow().sb ? getTopWindow().sb : (getTopWindow().getWindowOpener().getTopWindow().sb ? getTopWindow().getWindowOpener().getTopWindow().sb : null);
var collapsedFacets =sbWindow && sbWindow.collapsedFacets ? sbWindow.collapsedFacets : [];
var emxUIAutoFilter = {
    id: null, // uid for the current slidein
    sb_id: null, // this id is to link ids with the SB timeStamp
    sb: null, // pointer to structure browser window
    constants: null, // pointer to emxUIConstants object
    slideInFrame: window, // this window
    current_color_btn: null, // the currently active color control
    sbMode: isIE ? (emxUICore.selectSingleNode(sbWindow.oXML, "/mxRoot/setting[@name = 'sbMode']")).text : (emxUICore.selectSingleNode(sbWindow.oXML, "/mxRoot/setting[@name = 'sbMode']")).textContent,

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
        facet_attr_head: function (isColorRequired,isColorButtonPressed, value, indexObj) {
        	var colorButtonDetails = "";
        	if(isColorRequired !== null){
        		if(isColorRequired.data === "false"){
        			colorButtonDetails = "";
        		}else if(isColorRequired.data === "true" && isColorButtonPressed === "yes"){
        			colorButtonDetails = "<button class='btn-colorize-active'></button>";
        		}else{
        			colorButtonDetails = "<button class='btn-colorize-inactive'></button>";
        		}
        	}
        	return jQuery('<div class="facet-attr-head"><div class="facet-title"><button class="arrow"></button><label>' + value + '</label>'+colorButtonDetails+'<button class="btn-filter-inactive" col-index="' + indexObj.index + '"></button></div>');
        },
        facet_attr_body: function () {
            return jQuery('<div class="facet-attr-body"></div>');
        },
        facet_select_all: function (label) {
            return jQuery('<span class="select-all"><a class="checkbox"></a><label>' + label + '</label></span>');
        },
        facet_list: function () {
            return jQuery('<ul></ul>');
        },
        facet_list_item: function (obj) {
        	if(obj.filtered === "yes")
        	{
        		return jQuery('<li class="' + obj.classProp + '">' + '<a class="checkbox ' + obj.checked +' '+ obj.colorDefined + ' applied" columnIndex="' + obj.columnIndex + '" valueIndex="' + obj.valueIndex + '"></a><label><span class="value">' + obj.value + '</span> (' + obj.count + ')</label></li>');
        	}else{
			    return jQuery('<li class="' + obj.classProp + '">' + '<a class="checkbox ' + obj.checked + '" columnIndex="' + obj.columnIndex + '" valueIndex="' + obj.valueIndex + '"></a><label><span class="value">' + obj.value + '</span> (' + obj.count + ')</label></li>');
        	}
        },
        facet_list_item_more: function (obj) {
        	if(obj.filtered === "yes")
        	{
        		return jQuery('<li><a class="checkbox ' + obj.checked +' '+ obj.colorDefined + ' applied" column="' + obj.column + '"></a><label><span class="value">' + obj.label + '</span></label></li>');
        	}else{
            return jQuery('<li><a class="checkbox" column="' + obj.column + '"></a><label><span class="value">' + obj.label + '</span></label></li>');
        	}
        },
        facet_list_item_from_progHtml: function (obj) {
        	if(obj.filtered === "yes")
        	{
        		return jQuery('<li class="' + obj.classProp + '">' + '<a class="checkbox ' + obj.checked +' '+ obj.colorDefined + ' applied" columnIndex="' + obj.columnIndex + '" valueIndex="' + obj.valueIndex + '"></a><div class="prg-html">' + obj.value + ' (' + obj.count + ') </div></li>');
        	}else{
                return jQuery('<li class="' + obj.classProp + '">' + '<a class="checkbox ' + obj.checked + '" columnIndex="' + obj.columnIndex + '" valueIndex="' + obj.valueIndex + '"></a><div class="prg-html">' + obj.value + ' (' + obj.count + ') </div></li>');
        	}	
        }
    },
    init: function () {
        this._initPointers(); //set external pointers on the top window e.g. getTopWindow().sb
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
    getRefinementColumns: function (objXml) {
        var columnChilds = emxUICore.selectNodes(objXml, "/mxRoot/columns/column[settings/setting[@name='" + this.sb.bpsSBFilter.autoFilterSetting + "']/text() != 'false']");
        return columnChilds;
    },
    _initPointers: function () { //initialize pointers to components
        if (!getTopWindow().sb && getTopWindow().getWindowOpener().getTopWindow().sb) { //tests if we are in a popup
            getTopWindow().sb = getTopWindow().getWindowOpener().getTopWindow().sb;
            getTopWindow().emxUIConstants = getTopWindow().getWindowOpener().getTopWindow().emxUIConstants;
            getTopWindow().closeSlideInDialog = function () {
                getTopWindow().closeWindow();
            };
        }
        getTopWindow().autoFilterWindow = window;
    },
    _initLocals: function () { //local pointers
        this.sb = getTopWindow().sb;
        this.constants = getTopWindow().emxUIConstants;
        this.closeSlideInDialog = getTopWindow().closeSlideInDialog;
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
                getTopWindow().sb = data;
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
		this._scrollToLastSelectedFilter();
    },
    _linkToSB: function () {
        this.sb_id = this.sb.timeStamp;
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
        var typeFilterSetting = this.sb.getRequestSetting("typeFilter");
        var typeFilter;
        if(typeFilterSetting) {
        	typeFilter = typeFilterSetting;
        }

        var relFilterSetting = this.sb.getRequestSetting("relationshipFilter");
        var relFilter;
        if(relFilterSetting) {
        	relFilter = relFilterSetting;
    		}

        var dirFilterSetting = this.sb.getRequestSetting("directionFilter");
        var dirFilter;
        if(dirFilterSetting) {
        	dirFilter = dirFilterSetting;
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

        //add multi select option
        if(jQuery(quadrant_DOM).find('#multi-select').length == 0){
        	var cbClass = "checkbox";
        	if(this.sb.isMultiSelect){
        		cbClass = cbClass + " selected";
        	}
        	quadrant_DOM.append(jQuery('<div id="multi-select" class="filter-mode"><ul><li><a id="multi-select-checkbox" class="'+cbClass+'"></a><label><span class="value">'+emxUIConstants.STR_AUTO_FILTER_MULTI_SELECT+'</span></label></li></ul></div>'));	
        }

		custToolbarDiv.append(templateDiv);
        this._drawFilterSections(quadrant_DOM);
    },
	
	_scrollToLastSelectedFilter: function (){
        if(this._lastSelectionColIndex || this._lastSelectionValueIndex){
			if(this._lastSelectionValueIndex){
			    var filterValueSelector = "a[columnIndex='" + this._lastSelectionColIndex +"'][valueindex='" + this._lastSelectionValueIndex + "']";				
		        var filterBody = $('#FilterBody', this.slideInFrame.document);
	            if($(filterValueSelector).size() == 1){ 	            	
	            	$('#FilterBody', this.slideInFrame.document).scrollTop(this._filterBodyScrollTop);
	            	$(filterValueSelector).offsetParent().offsetParent().scrollTop(this._ulScrollTop);
	            }
			}
		}		
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

    		var defaultValueSettings = this.sb.getRequestSetting("selectedType");
    		var defaultValue;
    		if(defaultValueSettings){
    			defaultValue = defaultValueSettings;
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
    		var defaultValueSettings = this.sb.getRequestSetting("selectedRelationship");
    		var defaultValue;
    		if(defaultValueSettings){
    			defaultValue = defaultValueSettings;
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

    		var direction = this.sb.getRequestSetting("direction");
    		var directionValue;
    		if(direction){
    			directionValue = direction;
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
    _drawFilterSections: function (quadrant) { // generate AF unique values per AF column.
        // loop through getTopWindow().sb.oXML/and column map to draw filters
        var columnChilds = jQuery.makeArray(this.getRefinementColumns(this.sb.oXML));

        var colLen = columnChilds.length,
            i = 0;
        for (; i < colLen; i++) { //get or set column state for expand/collapse of facet section
            var column = columnChilds[i];
            
            var enableColorFilter = emxUICore.selectSingleNode(column, "settings/setting[@name='"+this.sb.bpsSBFilter.colorFilterSetting+"']/text()");
            var column_state = column.getAttribute('state');
            var filtered = column.getAttribute('colorize');
            var uniqueValues = this.sb.emxUICore.selectSingleNode(column, "uniquevalues");
            var colValues = this.sb.emxUICore.selectNodes(uniqueValues, "c");
            if (!uniqueValues){
                continue;
            }
            var colIndex = uniqueValues.getAttribute('index'); //this is the column index

            if(collapsedFacets.find(colIndex) > -1){
            	column_state = "collapsed";
            }
            if (!column_state) {
                column_state = 'expanded';
                column.setAttribute('state', 'expanded');
            }
            //create the section DOM parts
            var indexObj = {
                index: colIndex,
                state: column_state
                };

            var section = this.template.facet_attr(indexObj);
            var heading_label = column.getAttribute('label').replace(/&lt;/g, "<").replace(/&gt;/g, ">"),
            group = emxUICore.selectSingleNode(column, "settings/setting[@name='Group Header']/text()");
            if (group != null) {
                heading_label += " (" + group.nodeValue + ")";
            }
            var heading = this.template.facet_attr_head(enableColorFilter,filtered,heading_label,indexObj);
            var content_body = this.template.facet_attr_body();
            var select_all = this.template.facet_select_all(this.constants.STR_AUTO_FILTER_SELECT_ALL);
            var list = this.template.facet_list();
            //build a section from DOM parts
            section.append(heading).append(content_body);
            //hide the buttons
            if(!this.sb.isMultiSelect){
            	jQuery(heading).find('button.btn-filter-inactive').hide();
            }
            //add unique list items to this section
            var values = this.sb.emxUICore.selectNodes(uniqueValues, "c"),
                j = 0,
                valLen = values.length;
		    var zeroCountArray = [];
            this._values = values;
            var selectAllCount = this.sb.emxUICore.selectNodes(uniqueValues, "c[@count != '0']").length;
            if(selectAllCount > 2){
            	content_body.append(select_all);
            }
            /*if(!this.sb.isMultiSelect){
            	jQuery(select_all).hide();
            }*/
            content_body.append(list);
            var hasSelected = false;
			var selectCount = 0;
            for (; j < valLen; j++) {
                var selected = values[j].getAttribute("selected");
                var count = values[j].getAttribute("count");
				var classProp = count == 0 ? "disableFilterSelection" : "";                
                var colorDefined = ""+jQuery(colValues[j]).attr("facetColoring");
                /*if (count == 0) {
                    continue;
                }*/
                var cellValue = this.sb.getCellValue(values[j]) || this.constants.STR_AUTO_FILTER_BLANK;
                /*
        		if(colorFilterType === "numeric" && values[j].getAttribute("numericExpression") !== null){
        			if(colorLabels[j]){
        				cellValue = expressionLabelMap["'"+values[j].getAttribute("numericExpression").trim()+"'"];
        			}else{
        				cellValue = values[j].getAttribute("numericExpression");
        			}
        		}
        		*/
                var checked = "";
                if (selected != null && selected == "yes" && count != 0) {
                    checked = "selected";
                    hasSelected = true;
					selectCount++;
                }
                var listItem,
                    objListItem = {
                    'columnIndex': colIndex,
                    'valueIndex': j,
                    'value': cellValue,
                    'filtered': filtered,
                    'checked': checked,
                    'count': count,
                    'colorDefined': colorDefined,
                    'classProp': classProp
                };
                var columnType = column.getAttribute('type');
                if (columnType == "programHTMLOutput") {
                    listItem = this.template.facet_list_item_from_progHtml(objListItem);
                } else if(columnType == "File" || columnType == "Image"){
                    listItem = this.template.facet_list_item(objListItem);
                } else {
                	var tempValue = objListItem.value;
                	objListItem.value = tempValue.htmlEncode();
                    listItem = this.template.facet_list_item(objListItem);
                }
                 if(count == 0){
                	zeroCountArray.push(listItem);
                }else{
                list.append(listItem);
            }
            }
            if(hasSelected){
            	jQuery(heading).find('button.btn-filter-inactive').attr('class','btn-filter-inactive applied');
            }
			if(selectCount == selectAllCount){
				jQuery('a.checkbox',select_all).toggleClass('selected');
			}
			valLen = zeroCountArray.length;
            j=0;
            for(; j < valLen; j++){
            	list.append(zeroCountArray[j]);
            }
            //add the section to the quadrant
            quadrant.append(section.get(0));
        }
    },
    _initializeInnerControls: function () { //initializes all facet actions
        var objThis = this;
        // toggle the inner sections
        jQuery('div.facet-attr-head button.arrow').click(function (event) {
            event.preventDefault();
            var selection_div = jQuery(this).closest('div.facet-attr');
            selection_div.toggleClass('expanded').toggleClass('collapsed');
            var colIndex = selection_div.attr("col-index");
            if(selection_div.hasClass('collapsed')){
            	collapsedFacets.push(colIndex);
            }else{
            	collapsedFacets.remove(colIndex);
            }
            sbWindow.collapsedFacets = collapsedFacets;
            jQuery(document).trigger('UPDATE_FACET_ATTR_STATE', [jQuery(this).closest('div.facet-attr')]);
        });
        jQuery('button.btn-filter-inactive, button.btn-filter-active').click(function (event) {
        	if(jQuery(this).hasClass('btn-filter-inactive')){
        		return;//no change in the filter criteria
        	}
        	var colIndex = jQuery(this).attr('col-index');
        	var section = jQuery(this).closest('div.facet-attr');
        	
        	var checkboxSelected = jQuery(section).find("a.checkbox");
        	var selectionArray = [];
            for (k = 0; k < checkboxSelected.length; k++) {
            	var currElem = checkboxSelected[k];
            	if(currElem.getAttribute("columnIndex") != null){
            		selectionArray.push({
                        'columnIndex': currElem.getAttribute("columnIndex"),
                        'select': jQuery(currElem).hasClass('selected'),
                        'valueIndex': currElem.getAttribute("valueIndex")
                    });
            	}
            }
            //console.log(selectionArray);
        	objThis._applyFilterSelections(this,selectionArray);
        });
        // set colorize click controls
        //jQuery('div.facet-functions button.colorize').click(function (event) {
        jQuery('button.btn-colorize-inactive, button.btn-colorize-active').click(function (event) {
        	var prevState = jQuery(this).attr('class');
            var prevActiveButtons = jQuery('button.btn-colorize-active');
            prevActiveButtons.removeClass('btn-colorize-active');
            prevActiveButtons.addClass('btn-colorize-inactive');
            if(prevState !== 'btn-colorize-active'){
            	jQuery(this).removeClass('btn-colorize-inactive');
            	jQuery(this).addClass('btn-colorize-active');
            }
            var currentButtonStyle = jQuery(this).attr("class");
            var checklistsection = jQuery(this).closest(".facet-attr").children()[1];
            //Clear previously selected legends
            var checklistContainer = jQuery(this).closest(".facet-body");
            var checklistApplied = jQuery(checklistContainer).find("a.checkbox.applied");
            for (k = 0; k < checklistApplied.length; k++) {
            	var colorsApplied = objThis.sb.bpsSBFilter.color_css;
            	for(l=0;l<colorsApplied.length;l++){
            		jQuery(checklistApplied[k]).removeClass(colorsApplied[l]);
            	}
            	jQuery(checklistApplied[k]).removeClass("applied");
            }
            var selectionCriterias = jQuery(checklistsection).find('a.checkbox');
            var selectionCriteriasValue = jQuery(checklistsection).find('span.value');
            //Get values from the SB.
            var parentActualIndex =  jQuery(this).closest(".facet-attr").attr("col-index");            

            
            var column = objThis.sb.emxUICore.selectNodes(objThis.sb.oXML, "/mxRoot/columns/column")[parentActualIndex];
            var valuesSelectedColumn = objThis.sb.emxUICore.selectNodes(column, "uniquevalues/c"); 
            if(currentButtonStyle === 'btn-colorize-active'){
            	for (j = 0; j < selectionCriterias.length; j++) {
                	var colorDefined = ""+jQuery(valuesSelectedColumn[jQuery(selectionCriterias[j]).attr("valueindex")]).attr("facetColoring");
                	jQuery(selectionCriterias[j]).addClass(colorDefined);
                	jQuery(selectionCriterias[j]).addClass("applied");
                }
            }
            objThis.sb.bpsSBFilter.applyFacetColors(objThis.sb.oXML, parentActualIndex);
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
        jQuery('div.facet-body div#multi-select ul li a#multi-select-checkbox').click(function (event) {
        	jQuery(this).toggleClass('selected');
        	//objThis.isMultiSelect = jQuery(this).hasClass('selected');
        	objThis.sb.isMultiSelect = jQuery(this).hasClass('selected');
        	if(!objThis.sb.isMultiSelect){
        		jQuery(this).closest(".facet-body").find('button.btn-filter-inactive, button.btn-filter-active').hide();
        		//jQuery(this).closest(".facet-body").find('span.select-all').hide();
				jQuery(this).closest(".facet-body").find('button.btn-filter-active').each(function(index, value){
					if(jQuery(value).hasClass('applied')){
						jQuery(value).attr('class', 'btn-filter-inactive applied');
					}else{
						jQuery(value).attr('class', 'btn-filter-inactive');
					}
				});
				
				jQuery(this).closest(".facet-body").find('div.facet-attr-body ul li a.checkbox.selected').each(function(index, value){
					//console.log(index + ": " + value.getAttribute('columnindex'));
					var colIndex = value.getAttribute('columnindex');
					var valIndex = parseInt(value.getAttribute('valueindex')) + 1;
					var selectedItemLength = emxUICore.selectNodes(objThis.sb.oXML, "/mxRoot/columns/column//uniquevalues[@index = '"+colIndex+"']//c[@selected = 'yes' and position() = "+valIndex+"]").length;
					if(selectedItemLength <= 0){
						jQuery(this).removeClass('selected');
					}
				});
            }else{
            	jQuery(this).closest(".facet-body").find('button.btn-filter-inactive, button.btn-filter-active').show();
            	//jQuery(this).closest(".facet-body").find('span.select-all').show();
            }
        });
        //select all check/uncheck
        jQuery('div.facet-attr-body span.select-all a.checkbox').click(function (event) {
        	jQuery(this).toggleClass('selected');
        	var header = jQuery(this).closest('div.facet-attr');
	    	jQuery(header).find('button.btn-filter-inactive').attr('class', 'btn-filter-active');
        	if(jQuery(this).hasClass('selected')){
        		jQuery(this).closest('div.facet-attr-body').find('ul li a.checkbox').not('ul li.disableFilterSelection a.checkbox').addClass('selected');
        	}else{
        		jQuery(this).closest('div.facet-attr-body').find('ul li a.checkbox').not('ul li.disableFilterSelection a.checkbox').removeClass('selected');
        	}
            
            var section = jQuery(this).closest('div.facet-attr');
        	
        	var checkboxSelected = jQuery(section).find("a.checkbox");
        	var selectionArray = [];
            for (k = 0; k < checkboxSelected.length; k++) {
            	var currElem = checkboxSelected[k];
            	if(currElem.getAttribute("columnIndex") != null){
            		selectionArray.push({
                        'columnIndex': currElem.getAttribute("columnIndex"),
                        'select': jQuery(currElem).hasClass('selected'),
                        'valueIndex': currElem.getAttribute("valueIndex")
                    });
            	}
            }
            //console.log(selectionArray);
            if(!objThis.sb.isMultiSelect){
        	    objThis._applyFilterSelections(this,selectionArray);
            }
        });
        // check / uncheck boxes
        jQuery('div.facet-attr-body ul li a.checkbox').click(function (event) {
		    if(this.offsetParent.className == "disableFilterSelection"){
        		return;
        	}
            event.preventDefault();
            jQuery(this).toggleClass("selected");
			objThis._lastSelectionColIndex = $(this).attr("columnIndex");
            objThis._lastSelectionValueIndex = $(this).attr("valueindex");
            objThis._ulScrollTop = $(this).offsetParent().offsetParent().scrollTop();            
            objThis._filterBodyScrollTop = $('#FilterBody', objThis.slideInFrame.document).scrollTop();
            // set select all accordingly
            var section = jQuery(this).closest('div.facet-attr-body');
            // if the checkbox.length = checkbox.selected.length then select all
            jQuery('span.select-all a.checkbox', section).toggleClass('selected', (jQuery('li a.checkbox', section).length == jQuery('li a.checkbox.selected', section).length));
            var isMultiSelect = jQuery('div.facet-body div#multi-select ul li a#multi-select-checkbox').hasClass('selected');  
			if(!objThis.sb.isMultiSelect){   
			//if(isMultiSelect){
            objThis._applyFilterSelections(this);
		    }else{
		    	var header = jQuery(this).closest('div.facet-attr');
		    	var filterBtn = jQuery(header).find('button.btn-filter-inactive');
		    	if(filterBtn.hasClass('applied')){
		    		filterBtn.attr('class', 'btn-filter-active applied');
		    	}else{
		    		filterBtn.attr('class', 'btn-filter-active');
		    	}
		    }
        });
        // check or uncheck via label
        jQuery('div.facet-attr-body ul li a.checkbox + label').click(function (event) {
            event.preventDefault();
            jQuery(this).prev('a.checkbox').triggerHandler("click");
        });
        // set filter body's getTopWindow(), just below the header
        //jQuery('#FilterBody').css("top", jQuery('.page-head').children().height());
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

        jQuery('a.action-reset:odd').find("button").text(this.constants.STR_AUTO_FILTER_RESET);
        jQuery('a.action-close:odd').find("button").text(this.constants.STR_AUTO_FILTER_CLOSE);
        jQuery('a#helpLink').attr("title",this.constants.STR_HELP_ICON);
    },
    _applyFilterSelections: function (obj, selectionArray) { //build a map of checkbox objects and pass to filtering method
    	var selectionObj = null;
    	if(selectionArray != null){
    		selectionObj = selectionArray;
    	}else{
    		selectionObj = [];
    		selectionObj.push({
                'columnIndex': obj.getAttribute("columnIndex"),
                'select': jQuery(obj).hasClass('selected'),
                'valueIndex': obj.getAttribute("valueIndex")
                });
            }
        this.sb.bpsSBFilter.processNewUserSelections(this.sb.oXML, selectionObj);
        this._setFilterIcons();
        this._reDrawSB();
        this._drawUI();
    },
    _setFilterIcons: function () {
        jQuery('td.filtered.status',[getTopWindow().sb.editableTable.divListHead, getTopWindow().sb.editableTable.divTreeHead]).removeClass('filtered status');
        var filteredCols = jQuery('column[userfiltered = "true"]', getTopWindow().sb.oXML);
        if (filteredCols.length > 0){
            filteredCols.each(function(){
                var colName = this.getAttribute('name');
                jQuery('th[id="' + colName + '"]', [getTopWindow().sb.editableTable.divListHead, getTopWindow().sb.editableTable.divTreeHead]).find('td[id="' + colName + '_filter"]').addClass('filtered status');
            });
        }
    },
    _reDrawSB: function () { //process user clicks as selections are made.
        // selectionMap should include all column selections
        // even if none were selected in order to properly update xml with current selections.
        //clear filter icons first
		//need to add timeout to wait for loading the new SB
    	setTimeout(function () {
    	//special handling to show colorization column in tblTreeHead as rebuldView doesn't refresh it
    	if(jQuery('button.btn-colorize-active').length > 0){ 
        	jQuery(this.sb.editableTable.tblTreeHead).attr("colorize", "yes");
    	}else{
    		jQuery(this.sb.editableTable.tblTreeHead).attr("colorize", "no");
    	}
    	
        this.sb.FreezePaneUtils.adjustTableColumns();
        this.sb.processRowGroupingToolbarCommand();
// needs a small timeout for the iPad
        this.sb.reloadGSB = true;
        this.sb.rebuildView();
			}, 100);

    },
    refreshFilterView: function () {
        this._initPointers(); //set external pointers on the top window e.g. getTopWindow().sb
        this._initLocals(); //local pointers to sb and constants within emxUIAutoFilter
        this.sb.bpsSBFilter.rebuildFacets(this.sb.oXML);
        this._drawUI();
    },
    isRefined: function () {  //check if refinements have been made to the xml.
        this._initPointers(); //set external pointers on the top window e.g. getTopWindow().sb
        this._initLocals(); //local pointers to sb and constants within emxUIAutoFilter
        return this.sb.bpsSBFilter.isDataRefined(this.sb.oXML);
    },
    cmdEnableDisableByMode: function(mode){
    	if(mode == "view"){
    		this.commandEnable(getTopWindow().sb.emxCustomToolbar.viewModeCmds);
    		this.commandDisable(getTopWindow().sb.emxCustomToolbar.editModeCmds);
    	}else{
    		this.commandEnable(getTopWindow().sb.emxCustomToolbar.editModeCmds);
    		this.commandDisable(getTopWindow().sb.emxCustomToolbar.viewModeCmds);
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
        if(!getTopWindow().sb.parent.FullSearch){
            getTopWindow().sb.doAttachDitachCustTLB();
        }
    } catch (e) {
        alert(e);
    }
});
