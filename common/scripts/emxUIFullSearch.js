/*=================================================================
 *  JavaScript Full Search Object
 *  emxUIFullSearch.js
 *  Version 1.0
 *  Requires: emxUIConstants.js, emxUICore.js, json.js
 *
 *  This file contains the FullSearch object which encapsulates its functionality.
 * 
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information 
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 * 
 *  static const char RCSID[] = $Id: emxUIFullSearch.js.rca 1.43.4.2.2.1 Fri Nov  7 09:44:06 2008 ds-kvenkanna Experimental $
 *=================================================================
 */
ElapsedTimer.timeCheck("before loading emxUIFullSearch.js");
var URL_GET_CALENDAR_LOAD = "../common/emxCalendarLoad.jsp";
var isTableDataload = true;
var TAG_TYPE_IMPLICIT = "implicit";
var TAG_TYPE_EXPLICIT = "explicit";

//FullSearch object to encapsulate page logic
var FullSearch = {

	// DOM variables
	header: null,
	body: null,
	nav: null,
	navTypes: null,
	navAttributes: null,
	footer: null,
	results: null,
	form: null,
	formView: null,
	formReset: null,
	inputFormBasedMode: null,
	inputRangeLimit: null,
	btnChooser: null,
	typeChooser: null,
	reset: null,
	button: null,
	textbox: null,
	saveSearchName: null,
	workspaceBtnDiv: null,
	libBtnDiv: null,
	typeBtnDiv: null,
	// Variables
	pageUrl: null,
	firstTimeFormLoad: "false",
	contentUrl: null,
	cancelUrl: null,
	objParameter: new Object(),
	buffer: null,
	filters: new Object(),
	dynaTaxonomy: new Object(),
	dynaName: null,
	dynaValue: null,
	inputDiv: null,
	floatingDiv: null,
	objFrame: null,
	elementDiv: null,
	firstTimeView: null,
	currSaveName: null,
	JSONdata: null,
	navAttrData: null,
	search: location.search.substring(1),
	taxonomies: new Object(),
	taxonomyDispValues: new Object(),
	showInitialResults: true,
	fieldSeperator: ":",
	immediateMode: false,
	resultsCount: null,
	noCountsThreshold: null,
	includeCounts: null,
	searchtimeStamp: null,
	firstRequest : true,
	//clearDefault : true,
	clearSearchTimeStamp :false,
	defaultValues : [],
	inputControlObject : new Object(),
	inputControlFilter : new Object(),
	allowSearchWithminReqCharsVoilation : true,
	enableSearchButton : false,
	initialFilterJSONString: null,
	selRowsXML : null,
	rememberSelection : false,
	switchedNavMode: false,
	customAction : false,
	caseSensitiveSearch: null,
	refinementMode:false,
	pageSize: null,
	tagsSummaryJSON:{},
	//constants
	PARAM_TYPE: "TYPES",
	PARAM_SEARCH_MODE: "viewFormBased",
	PARAM_TAGS_MODE: "Tags Mode",
	PARAM_VIEW_FORM_BASED: "viewFormBased",
	PARAM_SEARCH_TIME_STAMP: "fullTextSearchTimestamp",
	PARAM_FORM_INCLUSION_LIST: "formInclusionList",
	PARAM_MANDATORYSEARCH: "mandatorySearchParam",
	PARAM_FIELD: "field",
	PARAM_COLLECTION: "COLLECTION",
	PARAM_CASE_SENSITIVE: "caseSensitiveSearch",
	DATA_URL: "emxFullSearchGetData.jsp",
	PROGRAM: "program",
	PROGRAM_ATTRIBUTE: null,
	PROGRAM_TYPE: null,
	LEFT_NAV_XSL: emxUICore.GetXSLRemote("emxFullSearchLeftNav.xsl"),
	LEFT_NAV_WIDGET_XSL: emxUICore.GetXSLRemote("emxFullSearchLeftNavWidget.xsl"),
	FORM_XSL: emxUICore.GetXSLRemote("emxFullSearchForm.xsl"),
	FORM_WIDGETS_XSL: emxUICore.GetXSLRemote("emxFullSearchFormWidgets.xsl"),
	SUGGESTIONS_XSL: emxUICore.GetXSLRemote("emxSuggestions.xsl"),
	FILTER_NAME: "filter_name",
	FILTER_VALUE: "filter_val",
	FILTER_DISPLAYVALUE: "filter_DisplayValue",
	FILTER_FIELDNAME: "ftsFilters",
	SELECTED: "selected",
	STR_TYPE: "TYPES",
	SEARCH_RANGE_LIMIT: "rangeLimit",
	TEXT_SEARCH: "txtTextSearch",
	PROGRAM_CLEARCACHE: null,
	PROGRAM_VALIDATE_POLICY_STATE:null,
	MINIMUM_WIDTH: 1000,
	MINIMUM_HEIGHT: 500,
	LEFT_NAV_WIDTH: "201px",
	OPERATOR: "operator",
	QUERY_TYPE: "queryType",
	QUERY_LIMIT: "queryLimit",
	PARAM_INCLUDECOUNTS: "includeCounts",
	FIRST_PAGE: 1,
	scrollPosition: 0,
	refreshDynaTree : true,	
	searchCriteriaChanged : true,
	//WS_EXPAND: "true",
	//LIB_EXPAND: "true",
	//TYPES_EXPAND: "true",
	//ATTR_EXPAND: "true",	
	TOGGLE_STATUS : { WORKSPACES : "true", LIBRARIES : "true", TYPES : "true", attributes : "true" },
	//methods
	init: function _init(cacheClear){
		
		ElapsedTimer.timeCheck("begin init()");
		this.initDOMVars();

		this.enforceGeometryMinimums();
		
		ElapsedTimer.timeCheck("after initDOMVars");
		this.objectifyParams();
		this.initialFilterJSONString = emxUICore.toJSONString(this.filters);
		ElapsedTimer.timeCheck("after objectify");
		
		this.setLayout(true);

		jQuery(this.navTypes).append(this.facetTemplate('Taxonomies',emxUIConstants.STR_TAXONOMIES));
		jQuery(".facet-content", jQuery('div#Taxonomies')).append(jQuery('<div class="facet-body"></div>'));

		ElapsedTimer.timeCheck("after setLayout");
		
		if (cacheClear) {
			//this.clearCache();
			ElapsedTimer.timeCheck("after clearCache");
		}
		this.loadContent(this.getFormBasedMode() == "false" && this.getQueryType() != "Real Time");
		ElapsedTimer.timeCheck("after loadContent");
		
		if (this.getFormBasedMode() == "false" && this.typeChooser) {
			this.typeChooser.style.display = "none";
		}
		jQuery('[name=mx_reset]').attr("onclick","javascript:void(0);");	
        
        this.selRowsXML = emxUICore.createXMLDOM();
        this.selRowsXML.loadXML("<mxRoot/>");
        emxUICore.addEventHandler(window, isIE ? "unload" : "beforeunload", function() { FullSearch.browserClose(); } );
        if(!emxUICore.findFrame(window.parent,"windowShadeFrame")){
        	window.frameElement ?(window.frameElement.name =="windowShadeFrame" ? "" :jQuery('a.btn').hide()):jQuery('a.btn').hide();
      	
        }
	},
	/* We want this UI to come up with some minimum dimensions       */
	/* but the initial size is controlled by the many UI commands    */
	/* that invoke it.  So here we override initial size if need be. */
	enforceGeometryMinimums: function _enforceGeometryMinimums(){
		try {
            //IR-097274    No need to resize windows if the search is launched within the window shade frame.
            if (window.frames.name == "windowShadeFrame")
                return;
            if(parent && parent.name == "portalDisplay"){
            	return;
            }
			var minW = this.MINIMUM_WIDTH;
			var minH = this.MINIMUM_HEIGHT;
			var w = getWindowWidth();
			var h = getWindowHeight();
			if (w <= minW || h <= minH) {
				// Note:resizeTo() does the wrong thing; must use resizeBy()
				//alert(w + "x" + h + "  ->  +" + (w < minW ? minW - w: 0) + "x+" +(h < minH ? minH - h : 0));
				parent.resizeBy(w <=minW ? minW - w : 0, h <= minH ? minH - h : 0);
				//For IR-038689V6R2011
				parent.moveTo(w<=minW ? (screen.availWidth-minW)/2 : (screen.availWidth-w)/2 ,h <= minH ? (screen.availHeight-minH)/2:(screen.availHeight-h)/2);
			}
		} catch (e) {
		}
	},
	
	getFirstPage: function _getFirstPage(){
		return this.FIRST_PAGE;
	},
	setSearchtimeStamp: function _setSearchtimeStamp(sts){
		this.searchtimeStamp =  sts;
	},	
	setFirstPage: function _setFirstPage(fpg){
		this.FIRST_PAGE = fpg;
	},	
	setProgram : function _setProgram(program){
		program = program.split(":");
		if(program[0] == null || program[0] == "null" || program[0] == "") {
			program[0] = "emxAEFFullSearch";
		}
		this.PROGRAM_ATTRIBUTE  = program[0] + ":getAttributeCounts";
		this.PROGRAM_TYPE       = program[0] + ":getTaxonomyCounts";
		this.PROGRAM_DYNA_TYPE  = program[0] + ":getDynaTaxonomyCounts";
		this.PROGRAM_CLEARCACHE = program[0] + ":clearCache";
		this.PROGRAM_VALIDATE_POLICY_STATE = program[0] + ":validatePolicyAndState";
	},
	setAllowSearchWithminReqCharsVoilation: function _setAllowSearchWithminReqCharsVoilation(aswmrcv){
		this.allowSearchWithminReqCharsVoilation= aswmrcv;
	},
	getAllowSearchWithminReqCharsVoilation: function _getAllowSearchWithminReqCharsVoilation(){
		return this.allowSearchWithminReqCharsVoilation;
	},
	setCaseSensitiveSearch: function _setCaseSensitiveSearch(value){
		if(this.caseSensitiveSearch != null){
			this.caseSensitiveSearch.value = value;
		}
	},
	getCaseSensitiveSearch: function _getCaseSensitiveSearch(){
		return this.caseSensitiveSearch != null ? this.caseSensitiveSearch.value : null;
	},
	getSwitchedNavMode: function _getSwitchedNavMode(){
		return this.switchedNavMode;
	},
	setSwitchedNavMode: function _setSwitchedNavMode(switchedNavMode){
		this.switchedNavMode = switchedNavMode;
	},
	getCustomAction: function _getCustomAction(){
		return this.customAction;
	},
	setCustomAction: function _setCustomAction(custom){
		 this.customAction = custom;
	},
		setEnableSearchButton: function _setEnableSearchButton(aswmrcv){
		this.enableSearchButton = aswmrcv;
	},
	getEnableSearchButton: function _getEnableSearchButton(){
		return this.enableSearchButton;
	},

	appendToSelRows: function _appendToSelRows(oid){
		if(this.getRememberSelection()) {
			var root = this.selRowsXML.documentElement;
			var tempxml = emxUICore.createXMLDOM();
			tempxml.loadXML("<mxRoot><r o='" + oid + "'/></mxRoot>");
			var selr = emxUICore.selectSingleNode(tempxml, "/mxRoot/r[@o = '" + oid + "']");
			root.appendChild(selr);
		}
	},
	removeSelRows: function _removeSelRows(oid){
		if(this.getRememberSelection()) {
			var rowNodes = emxUICore.selectNodes(this.selRowsXML, "/mxRoot/r[@o = '" + oid + "']");
			if(rowNodes != null) {
				var root = this.selRowsXML.documentElement;
			    for(var k=0; k<rowNodes.length; k++) {
					root.removeChild(rowNodes[k]);
				}
			}
		}
	},
	checkEnter: function _checkEnter(objEvent){		
			if(!objEvent){
				objEvent = emxUICore.getEvent();
			}
			objEvent.currentTarget.focus();
			var keyPressed = document.all ? objEvent.keyCode : objEvent.which;
		        if(keyPressed==13){
		            this.formSearch();
		            objEvent.stopPropagation();
		            objEvent.preventDefault();
		        }		
	},
	setIncludeListParam: function _setIncludeListParam(){
		var strField = this.getField();
		//create a copy of strField
		var excludeField = strField;
		if(excludeField != null && excludeField.length > 0){
			//find TYPES!= in excludeField and add it to exclusionList
			if(excludeField.indexOf("Type!=") > -1){
				var startNot = excludeField.indexOf("Type!=");
				var endNot = excludeField.indexOf(this.getFieldSeperator(),startNot);
				if (endNot < 0) {
					excludeField = excludeField.substring(startNot+6);
				} else {
					excludeField = excludeField.substring(startNot+6, endNot);
				}
				//xsl:variable[@name='inclusionList'] in this.FORM_XSL
				if(isIE){
					this.FORM_XSL.setProperty("SelectionNamespaces", "xmlns:xsl='http://www.w3.org/1999/XSL/Transform'");
				}
				var exclusionListNode = emxUICore.selectSingleNode(this.FORM_XSL.documentElement, "/xsl:stylesheet/xsl:variable[@name = 'exclusionList']");
        		emxUICore.setText(exclusionListNode, excludeField);
			}
			//find TYPES= in strField and add it to inclusionList
			if(strField.indexOf("TYPES=") > -1){
				var start = strField.indexOf("TYPES=");
				var end = strField.indexOf(this.getFieldSeperator(),start);
				if (end < 0) {
					strField = strField.substring(start+6);
				} else {
					strField = strField.substring(start+6, end);
				}
				//xsl:variable[@name='inclusionList'] in this.FORM_XSL
				if(isIE){
					this.FORM_XSL.setProperty("SelectionNamespaces", "xmlns:xsl='http://www.w3.org/1999/XSL/Transform'");
				}
				var oNode = emxUICore.selectSingleNode(this.FORM_XSL.documentElement, "/xsl:stylesheet/xsl:variable[@name = 'inclusionList']");				
        		emxUICore.setText(oNode, strField);
			}
			
		}
	},
	
	refresh: function _refresh(){
		if(this.getTagsMode() != "true"){
			this.closeTagNavigation();
		}
		if (this.getFormBasedMode() == "true") {
			this.loadForm();
		} else {
			this.loadNavData();
		}
		this.setFieldValues();
		this.formSearch();
		this.setLayout();
	},
	
	initDOMVars: function _initDOMVars(){
		//NOFORMAT
        //dom
        this.header                 = document.getElementById("searchHead");
        this.body                   = document.getElementById("bd");
        this.splashFrame            = document.getElementById("splash_frame");
        this.nav                    = document.getElementById("leftNav");
        this.navTypes               = document.getElementById("types");
        this.navAttributes          = document.getElementById("attributes");
        this.footer                 = document.getElementById("searchFoot");
        this.results                = document.getElementById("structure_browser");
        this.form                   = document.getElementById("full_search");
        this.formHidden             = document.getElementById("full_search_hidden");
        this.formHiddenFilters      = document.getElementById("ftsFilters");
        this.formReset              = document.getElementById('full_search_reset');
        this.formSplash	            = document.getElementById('full_search_splash');
        this.formView               = document.getElementById("searchBody");
        this.options                = document.getElementById("searchOptions");
        this.btnChooser             = document.getElementById("btnChooser");
        this.typeChooser            = document.getElementById("mxform_div");
        this.reset                  = document.getElementById("mx_reset");
        this.workspaceBtnDiv        = document.getElementById("workspaceBtnDiv");
        this.typeBtnDiv             = document.getElementById("typeBtnDiv");
        this.libBtnDiv              = document.getElementById("libBtnDiv");
        this.Suggestions            = document.getElementById("Suggestions");
        this.inputFormBasedMode		= document.getElementById("hidFormBased");
        this.inputRangeLimit		= document.getElementById("rangeLimit");
        this.textSearch             = document.getElementById("txtTextSearch");
        this.queryLimit				= document.getElementById("QueryLimit");
        this.caseSensitiveSearch    = document.getElementById("caseSensitiveSearch");
		//FORMAT
	},
	setLayout: function _setLayout(doLoadForm){

		adjustSearchLeftPanelLayout(window);

		//NOFORMAT
        if(this.results) {
            this.results.style.position = this.body.style.position  = "absolute";
            this.results.style.top      =  "0px";
        }
        if(this.body){
        	this.body.style.top         = "0px";
        	this.body.style.right       = "0px";
        }

        jQuery('div#pageContentDiv').css('top', '0px');
        jQuery('div#pageHeadDiv').css('display','none');
        if (this.isFormBasedMode()) {
        	if(doLoadForm){
        		this.loadForm();
        	}
            if(this.nav){ 
				this.nav.style.display = "none";
			}
            this.formView.style.display = "block";
            if(this.getQueryType() == "Indexed" && document.getElementById("breadcrumb")){
            	document.getElementById("breadcrumb").style.display = "none";
            }
            this.formView.style.top = this.header.offsetHeight + this.options.offsetHeight + "px";
        }else if ("true"==this.getTagsMode()) {        	
            if(this.nav){ 
				this.nav.style.display = "none";
			}
            FullSearch.openTagNavigation();            
            
        }else {
        	if(this.results) {
            this.results.style.top      = "0px";
            }

			if(this.formView){
            	this.formView.style.display = "none";
			}
            
            this.nav.style.display		= "block";
			this.nav.style.top = this.header.offsetHeight + this.options.offsetHeight + 3 +"px";
			this.nav.style.width = this.nav.parentNode.offsetWidth + "px";
        }

		this.splashFrame.style.position = "absolute";
		this.splashFrame.style.left   = "0px"; this.body.style.left;
		this.splashFrame.style.top    = "0px"; this.body.style.top;
		this.splashFrame.style.width  = this.body.style.width;
		this.splashFrame.style.height = this.body.style.height;

		this.navTypes.style.display = "block";
		this.navAttributes.style.display = "block";
		//changeView('TagsMode');
		//FORMAT
	},
	clearCache: function _clearCache(){
		this.getServerData(this.getClearCacheUrl());
	},
	browserClose : function _browserClose(event) {
		this.clearCache();
		this.invokeCancelUrl();
	},
	invokeCancelUrl : function _invokeCancelUrl()  {
		if(this.cancelUrl != null)
		{
			var objTableFrame = findFrame(getTopWindow(), "structure_browser");
			var postdata      = this.getPageUrl();
		    if(objTableFrame != null && objTableFrame.document.emxTableForm != null)
	    	{
	    		var qb = new Query();
	    		var form = objTableFrame.document.emxTableForm;
				for (var i = 0; i < form.elements.length; i++) {
					var el = form.elements[i];
					if(el.type == "hidden") {
						qb.append(el.name, el.value);
					}
				}
				postdata = qb.toString().substr(1) + "&" + postdata;
	    	}
			try
			{
				var jsonResp = emxUICore.getDataPost(this.cancelUrl, postdata);
				jsonResp     = eval('(' + jsonResp + ')');
				jsonResp.main();
			}catch(e) {
			}
    	}
	},
	busy: function _busy(str) {
		turnOnProgress();
	// TODO: need to handle parallel activities, probably need a stack of some kind
	// TODO: need to implement optional delay to suppress brief busy messages
	//       careful, if busy is processing, not asynch request, delay may not be possible
		if (!str) {
			str = "Busy...";
		}
		if (this.busyDiv) {
			this.busyDiv.parentNode.removeChild(this.busyDiv);
		}
		this.busyDiv = document.createElement("div");
		this.busyDiv.name = "busyDiv";
		this.busyDiv.className = "busyLayer";
		this.busyDiv.style.position = "absolute";
		this.busyDiv.style.bottom = "1px";
		this.busyDiv.style.right = "1px";
		this.busyDiv.style.visibility = "visible";
		this.busyDiv.style.background = "#eeeeee";
		this.busyDiv.style.border = "1px solid black";
		this.busyDiv.style.paddingLeft = "4px";
		this.busyDiv.style.paddingRight = "4px";
		this.busyDiv.innerHTML = str;

		if(isIE && !this.busyFrame) {
			//create an iframe to allow the popup div to go over iframes in IE
			//this is needed because we have to add this popup to the DOM before
			//the content iframe(popup needs to be added to the form for calendar controls to work)
			this.busyFrame = document.createElement("IFRAME");
			this.busyFrame.setAttribute("name", "busyFrame");
			this.busyFrame.setAttribute("id", "busyFrame");
			this.busyFrame.frameBorder = 0;
			this.busyFrame.src = "emxBlank.jsp";
			// document.forms["full_search"].appendChild(this.busyFrame);
		}
		
		document.forms["full_search"].appendChild(this.busyDiv);
		
		if (isIE) {
			this.busyFrame.style.width = this.busyDiv.offsetWidth;
			this.busyFrame.style.height = this.busyDiv.offsetHeight;
			this.busyFrame.style.right = this.busyDiv.style.right;
			this.busyFrame.style.bottom = this.busyDiv.style.bottom;
			this.busyFrame.style.position = "absolute";
			
			//this.busyFrame.style.border = "1px solid red";

			this.busyFrame.style.display = "block";
		}
	},
	notBusy: function _notBusy() {
		if (this.busyDiv) {
			this.busyDiv.parentNode.removeChild(this.busyDiv);
			this.busyDiv = null;
			turnOffProgress();
		}
		if (this.busyFrame) {
			this.busyFrame.style.display="none";
    	}
	},
	getServerData: function _getServerData(url, fnCallback, busyStr, blocking){
		if (busyStr) {
			this.busy(busyStr);
		}
		if (blocking) {
			// mask UI
		}
		var q = new Query(url);
		var baseUrl = q.getBaseUrl();
		var search = q.getSearch();
		
		if (fnCallback) {
			emxUICore.getDataPost(baseUrl, search, function _getServerDataCB(responseText) {
				try {
					var data = eval('(' + responseText + ')');
					FullSearch.handleServerException(data);
					fnCallback(data);
				} finally {
					if (busyStr) {
						FullSearch.notBusy();
					}
					if (blocking) {
						// unmask UI
					}
				}
			} );
		} else {
			ElapsedTimer.enter();
			try {
				var data = eval('(' + emxUICore.getDataPost(baseUrl, search) + ')');
				this.handleServerException(data);
				return data;
			} finally {
				if (busyStr) {
					this.notBusy();
				}
				ElapsedTimer.exit();
			}
		}
	},
	loadContent: function _loadContent(doSearch) {
		if(this.filters[this.TEXT_SEARCH] != null){
			var value = this.filters[this.TEXT_SEARCH].toString();
			if (value.indexOf("|") > -1) {
				value = value.split("|")[1];
			}
			if(this.textSearch != null){
				this.textSearch.value = value.replace(/%25/g,"%");
				this.textSearch.textContent = this.textSearch.value;
			}
        }
		if(this.showInitialResults != "false"){
			var qb = new Query(this.getContentUrl());
			qb.set("txtNoSearch", doSearch == false);
			qb.set("ftsFilters", emxUICore.toJSONString(this.filters));
			// this.results.src removed for 460731
			this.formSearch();
			if("true"==FullSearch.getTagsMode()){
				this.loadNavigationContent();
			}
		}else{
			//377539
			var strURL = "emxFullSearchShowInitialResults.jsp?viewFormBased="+this.getFormBasedMode() + "&queryType=" + this.getQueryType() + "&" + this.getPageUrl();
			this.submitLongURL(strURL, "splash");
			this.splashFrame.style.display="none";
			this.loadNavigationContent();
			turnOffProgress();
		}		
	},
	handleServerException: function _handleServerException(data){
		if (data.EXCEPTION) { // Un-handled server side exceptions
			if (getTopWindow().console) {
				getTopWindow().console.error(data.STACKTRACE);
			}
			throw new Error(data.EXCEPTION);
		} else if (data.ERROR) { // handled server-side exceptions
			if (data.CLASS == "MALFORMED_TEXT_SEARCH") {
				this.removeFilter(this.TEXT_SEARCH);
			}
			throw new Error(data.ERROR);
		} else if (data.LOGOUT) {
			if (window.getWindowOpener()) {
				window.getWindowOpener().location.reload(); // closes all windows and goes to emxLogin.jsp
			} else {
				try {
					closeAllChildWindows();
					window.closeWindow();
				} catch (e) {}
			}
		}
	},
	loadNavigationContent: function _loadNavigationContent(){
		//For initial loading of iframe, we dont need loadNavData
		//377539
		/*if (document.getElementById("structure_browser").src.match("emxBlank.jsp") != null) {
			return;
		}*/
		//Retry to see if the Structure Browser has set the total counts
		if (this.getImmediateMode() && this.getResultsCount() == null) {
			//alert('delaying loadNavigationContent');
			setTimeout(function _loadNavContent(){
				FullSearch.loadNavigationContent();
				}, 100);
			return;
		}
		
		var old = this.getIncludeCounts();
		this.setCountsOrNoCountsMode();
		// in immediate mode, this is the only place where nav data gets updated
		// so must load now.
		// in non-immediate mode, nav data was already updated by now, but now
		// we may be able to include counts, so re-load if that's the case
		if (this.getImmediateMode() || this.getIncludeCounts() != old) {
		this.loadNavData();
		}
		
		setTimeout(function _loadNavContent_setToggleButtonLabel(){
				FullSearch.setToggleButtonLabel();
			}, 500);
	},
	setCountsOrNoCountsMode: function _setCountsOrNoCountsMode(bIgnoreResultsCount){
		if(this.getNoCountsThreshold() == -1){
			this.setIncludeCounts(true);
		}else if(this.getNoCountsThreshold() == 0){
			this.setIncludeCounts(false);
		} else if (!bIgnoreResultsCount && this.getResultsCount() <= this.getNoCountsThreshold()) {
			this.setIncludeCounts(this.getResultsCount() > 0); // zero means no query was run
		} else {
			this.setIncludeCounts(false);
		}
	},
	loadNavData: function _loadNavData(){
		try {
			if(this.getTagsMode() == "true"){
				// this.loadTaxonomies();
			} else if (this.getFormBasedMode() != "false") {
				this.setIncludeListParam();
				var noSuggestions = this.setJSONdata();
				ElapsedTimer.timeCheck("after setJSONData");
				if (noSuggestions != false && this.firstTimeFormLoad == "false") {
					this.drawTaxonomyButtons();
					this.formView.style.top = this.header.offsetHeight + this.options.offsetHeight + 2+ "px";
					//this.loadForm();
					this.firstTimeFormLoad = "true";
					ElapsedTimer.timeCheck("after loadForm");
				}
			} else {
				ElapsedTimer.timeCheck("Start loadNavData");
				if(FullSearch.searchCriteriaChanged) {
					updateSearchCriteria(false);
				}
				else {
				this.loadTaxonomies();
				}
				ElapsedTimer.timeCheck("after loadTaxonomies");
			}
			return true;
		} catch (err) {
			alert(err.message);
			return false;
		}
	},
	drawTaxonomyButtons: function _drawTaxonomyButtons(){
		var taxonomyArray = this.JSONdata.objs;
		var buttonHTML = "";
		for(var index = 0; index < taxonomyArray.length; index ++){
			var taxonomyObj = taxonomyArray[index];
			var taxonomyLabel = taxonomyObj.field;
			var taxonomyName = taxonomyLabel;
			for(key in taxonomyObj){
				taxonomyName = key;
				if(typeof taxonomyObj[key] == "object"){
					break;
				}
			}
			var fieldName = taxonomyName + "ActualDisplay";
			var fieldValue = this.taxonomyDispValues[taxonomyName];
			if(!fieldValue){
				fieldValue = "";
			}
			var btnName = "btnChooser"+taxonomyName;
			//this.setTaxonomyDispValues(taxonomyName,fieldValue);
			
			buttonHTML += "<li id=\""+taxonomyName+"BtnDiv\">";
			buttonHTML += "<span class=\"input small\">";
			buttonHTML += "<input type=\"text\" readonly name=\""+fieldName+"\" id=\""+fieldName+"\" value=\""+fieldValue+"\"/>";
			buttonHTML += "</span>";
			buttonHTML += "<input type=\"button\" name=\""+btnName+"\" id=\""+btnName+"\"  value=\""+taxonomyLabel+"\" onClick=\"showTypeHierarchyPopup('"+fieldName+"','"+taxonomyName+"')\" />";
			buttonHTML += "</li>";
		}
		//buttonHTML += "<input type=\"hidden\" name=\"TypeActual\" id=\"TypeActual\" value=\"\" />";
		//buttonHTML += "<input type=\"hidden\" name=\"txtTypeValue\" id=\"txtTypeValue\" value=\"\" />";
		if(this.typeChooser){
			this.typeChooser.innerHTML += buttonHTML;
		}
	},
	facetAttrTemp: function _facetAttrTemp(id, label){
		return jQuery('<div class="facet-attr expanded"><div class="facet-attr-head">'+
					'<div class="facet-title"><button onclick="FullSearch.expand(this)"></button><label>'+label+'</label></div></div>'+
					'<div id="'+id+'" class="facet-attr-body"></div></div>');
	},
	loadTaxonomies: function _loadTaxonomies(data){
		if (!data) {
			var isTagMode= this.getTagsMode();
			this.getServerData(this.getDynaTaxonomiesUrl()+"&TagsView="+isTagMode, this.loadTaxonomies, emxUIConstants.STR_LOADING_TAXONOMIES);
			return;
		} else if (this != FullSearch) {
			FullSearch.loadTaxonomies(data);
			return;
		}
		
		this.setJSONdata(data);
		if(this.getTagsMode()=="true"){
			var summaryData = [];
			var intial =data.attributes.obj.attributes.length;
			for(var k=0;k<data.attributes.obj.attributes.length;k++){
				var loc = data.attributes.obj.attributes;			
					for(var p=2;loc[k].values&&p<loc[k].values.length;p++){		 			 
						 var summary = {
								 	"object": loc[k].values[p].value,
				    				"dispValue": loc[k].values[p].displayValue,
				    				"sixw": change6WPredicates(loc[k].sixw),									
				    				"count": loc[k].values[p].count,
				    				"type": loc[k].values[p].dataType,
				    				"field":loc[k].values[p].field
				    			};						 	
				    			summaryData.push(summary);					 					
					}				
				}
				for(var m=0;m<summaryData.length;m++){
					data.attributes.obj.attributes.push(summaryData[m]);
				}
				data.attributes.obj.attributes=  {};
				data.attributes.obj.attributes = summaryData;
				
				var FullSearchTags = function (data) {
					console.dir(data);
					}
				var vall = {};
				if(FullSearch.results && FullSearch.results.contentWindow && FullSearch.results.contentWindow.editableTable){
					var tempSearchUrl = this.getURL()+"&TagsView="+true;				
					var searchParamsForTag = tempSearchUrl.replace("emxFullSearchGetData.jsp?","");
					vall  = FullSearch.results.contentWindow.editableTable.handleDrawTagsFTS(searchParamsForTag); 
				}
				FullSearch.tagsSummaryJSON = data.attributes.obj.attributes ;
				if(this.tnID){
					this.tnID.setTags((typeof vall == "undefined") ? null:JSON.parse(JSON.stringify(vall)) , data.attributes.obj.attributes);
				}
				
				//this.tnID.setTags(vall, data.attributes.obj.attributes); 
		}else{
			var dataNodes = new Array;
			var dynaData = new Array;
			//if(!this.dynaTaxonomy.children){
				this.dynaTaxonomy = data;
			//}
				
				var taxonomyDivList = jQuery(".facet-attr-body");
				for(var k=0;k<taxonomyDivList.length;k++){
					var obj = taxonomyDivList[k];
					var flag = true;
					if(this.dynaTaxonomy && this.dynaTaxonomy.children){
						for(var i=0; i < this.dynaTaxonomy.children.length ; i++){
							if(obj.id === this.dynaTaxonomy.children[i].taxonomy){
								flag = false;
							}
						}
						if(flag){
							jQuery('div#'+obj.id).parent().remove();
						}
					}
				}
				
			for(var i=0; i < this.dynaTaxonomy.children.length ; i++){
				var dynaNode = this.dynaTaxonomy.children[i];
				var id = dynaNode.taxonomy;
				var label = dynaNode.title;	
				dynaNode.onActivate = activeDynaNode;
				dynaNode.onSelect   = selectDynaNode;
				dynaNode.checkbox = true;
				dynaNode.selectMode = 2;
				if(!document.getElementById(id)){
					jQuery(".facet-body", jQuery('div#Taxonomies')).append(this.facetAttrTemp(id, label));
					$('div#'+id).dynatree(dynaNode).dynatree("getRoot").sortChildren(null,true);
				}else{
					if (this.refreshDynaTree && emxUIConstants.REFRESH_TAXONOMIES){
						$('div#'+id).dynatree("destroy");
						$('div#'+id).dynatree(dynaNode).dynatree("getRoot").sortChildren(null,true);
					}else{
						var taxonomyDiv=jQuery(".facet-body", jQuery('div#Taxonomies'));
						if(!(jQuery("div#"+id,taxonomyDiv))) {
							taxonomyDiv.append(jQuery("div#"+id).parent());
						} 
				}				
			}
			}
			//loading Attributes
			this.loadAttributes(data.attributes);
			if(!data.suggestions){
				this.body.style.display = "block";
				this.Suggestions.style.display = "none";
				this.navAttributes.style.display = "block";
				this.navTypes.style.height = "auto";	
			}
			this.refreshDynaTree=true;
		}
		
	},
	validateBadChars: function _validateBadChars(){
		var fldObj_name = document.forms[0].elements["NAME"];
		if(fldObj_name)
			{
				if(fldObj_name.value)
					{
					var badChar = checkFieldForChars(fldObj_name, emxUIConstants.STR_BADCHAR, true);
					if(badChar.length > 0)
						{	
							alert(emxUIConstants.BAD_CHAR + badChar);							
							turnOffProgress();
							return false;
						}
					}
			}
		return true;
	},
	facetTemplate : function _facetTemplate(id, label){
		return jQuery('<div id='+id+' class="facet expand"><div class="facet-head"><div class="facet-title">'+
				'<button id='+id+' onclick="FullSearch.expand(this)"></button>'+label+
				'</div></div><div class="facet-content"></div></div>');
	},
	scrollToQuadrant: function _scrollToQuadrant(id){
        var a = jQuery('#' + id, this.nav).get(0);
        if (a) {
        	this.nav.scrollTop = a.offsetTop;
        }
	},
	loadAttributes: function _loadAttributes(data){
		if (!data) {
			this.getServerData(this.getAttributeUrl(), this.loadAttributes, emxUIConstants.STR_LOADING_ATTRIBUTES);
			return;
		} else if (this != FullSearch) {
			FullSearch.loadAttributes(data);
			return;
		}

		this.navAttrData = data;
		
		var Breadcrumbs = {
				obj : {
					breadcrumbs:[]
				}
		};
		var objXML = null;
		if(data.obj.breadcrumbs && data.obj.breadcrumbs.length > 0){
			Breadcrumbs.obj.breadcrumbs = data.obj.breadcrumbs;
		    objXML = this.convertJSONtoXML(Breadcrumbs);		
		    jQuery('#breadcrumb', this.options).html(this.transformToText(objXML, this.LEFT_NAV_XSL));
			data.obj.breadcrumbs = [];
		}else{
			jQuery('#breadcrumb', this.options).html('');
		}

			var dataField = data.obj.field;
			$(this.navAttributes).html("");
			$(this.navAttributes).append(this.facetTemplate("Attributes", dataField));
			var objXML = this.convertJSONtoXML(data);		
			jQuery('.facet-content', jQuery('div#Attributes')).html(this.transformToText(objXML, this.LEFT_NAV_XSL));
		var objComplexControlDiv = document.getElementById("complex-control");
		var objBreadcru = document.getElementById("breadcrumb");
		var ccHeight = this.options.offsetHeight;
		if (document.getElementById("complex-control") != null && objComplexControlDiv != null) {
			document.getElementById("complex-control").innerHTML = objComplexControlDiv.innerHTML;
			if (objComplexControlDiv.innerHTML != "" && objComplexControlDiv.innerHTML != "&nbsp;") {
				document.getElementById("complex-control").style.display = "block";
			}else{
				if ((objComplexControlDiv.innerHTML == "" || objComplexControlDiv.innerHTML == "&nbsp;")  && (objBreadcru!= null && objBreadcru.innerHTML == "" || objBreadcru.innerHTML == "&nbsp;")){
					ccHeight = 0;
				}
			}
		}
		this.nav.style.top = this.header.offsetHeight + ccHeight + 3 +"px";
	},
	loadForm: function _loadForm(){
		var data = this.getServerData(this.getAttributeUrl());
		this.defaultValues = [];
		
		this.navAttrData = data;
		var objXML = this.convertJSONtoXML(data);
		
		// below code is added to show name in search, if its not coming for global search
		if(isIE){
			this.FORM_XSL.setProperty("SelectionNamespaces", "xmlns:xsl='http://www.w3.org/1999/XSL/Transform'");
		}
		var oNode = emxUICore.selectSingleNode(this.FORM_XSL.documentElement, "/xsl:stylesheet/xsl:variable[@name = 'searchPopup']");
		emxUICore.setText(oNode, (getTopWindow().jQuery('#AEFGlobalFullTextSearch').length == 0 ? "true" : "false"));
	
		var aNode1 = emxUICore.selectSingleNode(this.FORM_XSL.documentElement, "/xsl:stylesheet/xsl:variable[@name = 'Indexed']");
		emxUICore.setText(aNode1, ((this.getQueryType() == "Indexed")? "true" : "false"));
		
		if (data.suggestions != null) {
			this.formView.innerHTML = emxUIConstants.STR_SUGGESTIONS;
			if(getTopWindow().isMobile){
				setTimeout(function _delayed_transform() {
					//FullSearch.formView.innerHTML = FullSearch.transformToText(objXML, FullSearch.FORM_XSL);
					FullSearch.Suggestions.innerHTML = FullSearch.transformToText(objXML, FullSearch.SUGGESTIONS_XSL);
				}, 100);
			}
			else{
				this.Suggestions.innerHTML = this.transformToText(objXML, this.SUGGESTIONS_XSL);
			}
			this.body.style.display = "block";
			this.Suggestions.style.display = "block";
		} else {
			this.body.style.display = "block";
			this.Suggestions.style.display = "none";
			this.setIncludeListParam();
			if(getTopWindow().isMobile){
				setTimeout(function _delayed_transform() {
					FullSearch.formView.innerHTML = FullSearch.transformToText(objXML, FullSearch.FORM_XSL);	
				}, 100);
			}
			else{
				this.formView.innerHTML = this.transformToText(objXML, this.FORM_XSL);	
			}
			
			
		}
	},
	transformToText: function _transformToText(objXML, objXSL){
		if (typeof objXML != "undefined" && objXML.documentElement.hasChildNodes()) {
			return emxUICore.transformToText(objXML, objXSL);
		} else {
			return "";
		}
	},
	convertJSONtoXML: function _convertJSONtoXML(data){
		var objXML = emxUICore.createXMLDOM();
		var nRoot = objXML.createElement("mxRoot");
		objXML.appendChild(nRoot);
		this.jsonObjectToXML(objXML, nRoot, data);
		return objXML;
	},
    setJSONdata:function _setJSONdata(data){
        if(data){
            this.JSONdata = data;
		} else {
            this.JSONdata = this.getServerData(this.getTaxonomiesUrl());
        }
        if (this.JSONdata.suggestions != null) {
        	var objXML = this.convertJSONtoXML(this.JSONdata);
        	
        	var textVal =emxUICore.toJSONString(this.filters["txtTextSearch"]);   
        	var aTemp = objXML.createElement("txtTextSearch");
        	var aTemp1 = objXML.createElement("txtTextSearch");          	
        	var aTempSetting = objXML.createElement("setting");        	
        	aTempSetting.setAttribute("name","txtTextSearch");
        	aTemp1.appendChild(aTempSetting);
        	aTemp.appendChild(aTemp1);
        	emxUICore.setText(aTempSetting, textVal.substring(9,textVal.length-2));        	
        	objXML.documentElement.appendChild(aTemp);
			
			this.Suggestions.innerHTML = this.transformToText(objXML, this.SUGGESTIONS_XSL);
			this.body.style.display = "block";
			this.results.style.display = "none";
			this.splashFrame.style.display = "none";		
			this.Suggestions.style.display = "block";
			return false;
		} else if(this.getQueryType == "Indexed"){
			this.Suggestions.style.display = "none";
	        if(this.getFirstTimeFormBased() == "true" && this.JSONdata.suggestions == null){
		        if(this.JSONdata.objs){
		        this.typeBtnDiv.style.display = "none";
		        this.libBtnDiv.style.display = "none";
		        this.workspaceBtnDiv.style.display = "none";
					var len = this.JSONdata.objs.length;
					for(var i = 0; i < len; i++){
						if(typeof this.JSONdata.objs[i].TYPES == "object"){
							this.typeBtnDiv.style.display = "inline";
						}else if(typeof this.JSONdata.objs[i].LIBRARIES == "object"){
							this.libBtnDiv.style.display = "inline";
						}else if(typeof this.JSONdata.objs[i].WORKSPACES == "object"){
							this.workspaceBtnDiv.style.display = "inline";
						}
					}
				}
	        }
        }
    },
	isFormBasedMode: function _isFormBasedMode() {
		return this.getFormBasedMode() == "true";
	},
	getJSONdata: function _getJSONdata(){
		return this.JSONdata;
	},
	
	setContentUrl: function _setContentUrl(url){
		this.contentUrl = url;
	},
	getContentUrl: function _getContentUrl(){
		return this.contentUrl;
	},
	//set the pageUrl to emxFullSearch.jsp
	setPageUrl: function _setPageUrl(url){
		this.pageUrl = url;
		// TODO we don't need search field and need to be cleaned up
		this.search = url;
	},
	setCancelUrl : function _setCancelUrl(url){
		this.cancelUrl = (url != null && url != "" && url != "null") ? url : null;
	},
	getPageUrl: function _getPageUrl(){
		return this.pageUrl;
	},
	setType: function _setType(strField, strValue){
		if (strField == null) {
			for (t in this.taxonomies) {
				this.taxonomies[strField] = "";
			}
		} else {
			this.taxonomies[strField] = strValue;
		}
		//this.objParameter[this.PARAM_TYPE] = strField;
	},
	getField: function _getField(){
		return this.objParameter[this.PARAM_FIELD];
	},
	setField: function _setField(strField){
		this.objParameter[this.PARAM_FIELD] = strField;
	},
	setFormBasedMode: function _setFormBasedMode(strVal){
		if (strVal && strVal != "") {
			this.objParameter[this.PARAM_SEARCH_MODE] = strVal;
		} else {
			this.objParameter[this.PARAM_SEARCH_MODE] = this.inputFormBasedMode.value;
		}
	},
	getFormBasedMode: function _getSearchMode(){
		return this.objParameter[this.PARAM_SEARCH_MODE];
	},
	setTagsMode: function _setTagsMode(strVal){
		if (strVal && strVal != "") {
			this.objParameter[this.PARAM_TAGS_MODE] = strVal;
		} else {
			this.objParameter[this.PARAM_TAGS_MODE] = this.inputFormBasedMode.value;
		}
	},
	getTagsMode: function getTagsMode(){
		return this.objParameter[this.PARAM_TAGS_MODE];
	},	
	setFirstTimeFormBased: function _setFirstTimeFormBased(strVal){
		if (strVal && strVal != "") {
			this.firstTimeView = strVal;
		}
	},
	getFirstTimeFormBased: function _getFirstTimeFormBased(){
	
		return this.firstTimeView;
	},	
	getFormInclusionList: function _getFormInclusionList(){
		return this.objParameter[this.PARAM_FORM_INCLUSION_LIST];
	},
	setFormInclusionList: function _setFormInclusionList(formInclusionList){
		this.objParameter[this.PARAM_FORM_INCLUSION_LIST] = formInclusionList;
	},
	getMandatorySearchParam: function _getMandatorySearchParam(){
		return this.objParameter[this.PARAM_MANDATORYSEARCH];
	},
	setMandatorySearchParam: function _setMandatorySearchParam(formInclusionList){
		this.objParameter[this.PARAM_MANDATORYSEARCH] = formInclusionList;
	},
	getCollection: function _getCollection(){
		return this.objParameter[this.PARAM_COLLECTION];
	},
	setCollection: function _setCollection(strCollection){
		this.objParameter[this.PARAM_COLLECTION] = strCollection;
	},
	getQueryType: function _getQueryType(){
		return this.objParameter[this.QUERY_TYPE];
	},
	setQueryType: function _setQueryType(strVal){
		if (strVal && strVal != "") {
			this.objParameter[this.QUERY_TYPE] = strVal;
		} else {
			this.objParameter[this.QUERY_TYPE] = "Real Time";
		}
	},
	getShowInitialResults: function _getShowInitialResults(){
		return this.showInitialResults;
	},
	setShowInitialResults: function _setShowInitialResults(showResults){
		this.showInitialResults = showResults;
	},
	setFieldSeperator: function _setFieldSeperator(fieldSeperator){
		this.fieldSeperator = fieldSeperator;
	},
	getFieldSeperator: function _getFieldSeperator(){
		return this.fieldSeperator;
	},
	getRememberSelection: function _getRememberSelection(){
		return this.rememberSelection;
	},
	setRememberSelection: function _setRememberSelection(rememberSel){
		this.rememberSelection = rememberSel;
	},

	getResultsCount: function _getResultsCount(){
		return this.resultsCount;
	},
	setResultsCount: function _setResultsCount(setCount){
		this.resultsCount = setCount;
	},
	getNoCountsThreshold: function _getNoCountsThreshold(){
		return this.noCountsThreshold;
	},
	setNoCountsThreshold: function _setNoCountsThreshold(noCountsThresholdValue){
		this.noCountsThreshold = noCountsThresholdValue;
	},
	getIncludeCounts: function _getIncludeCounts(){
		return this.includeCounts;
	},
	setIncludeCounts: function _setIncludeCounts(includeCountsValue){
		this.includeCounts = includeCountsValue;
	},
	getImmediateMode: function _getImmediateMode(){
		return this.immediateMode;
	},
	setImmediateMode: function _setImmediateMode(setMode) {
		this.immediateMode = setMode;
	},
	/* Allow caller to override hard-coded minimum width and height setting. */
	setMinimumWidth: function _setMinimumWidth(minimumWidth){
		this.MINIMUM_WIDTH = minimumWidth;
	},
	setMinimumHeight: function _setMinimumHeight(minimumHeight){
		this.MINIMUM_HEIGHT = minimumHeight;
	},
	focusUnFocus : function focusUnFocus(aSBRowNodes){
	
		if(aSBRowNodes.length > 0) {
			this.tnID.focusOnSubjects(JSON.parse(JSON.stringify(aSBRowNodes)));
		} else {
			this.tnID.unfocus();
		}
	},
	//This method sets the button label to "Navigation View" if page is in formbased mode and label to "FormBased View" if the page is in Navigation mode
	setToggleButtonLabel: function _setToggleButtonLabel(){
		/*#372790 I am getting toggle button label wrong while switching*/
		var queryType = this.getQueryType();
		var isformBased = this.getFormBasedMode();
		var splashFrame = findFrame(getTopWindow(), "splash_frame");
		var objTableFrame = findFrame(getTopWindow(), "structure_browser");
		var toggleButton = null;
		if (this.splashFrame.style.display != "none") {
			toggleButton = splashFrame.document.getElementById("AEFFullSearchToggle");
			var splashArea = splashFrame.document.getElementById("splashArea");
			if(splashArea) {
				if(queryType == "Real Time" && isformBased == "true"){
					splashArea.innerHTML = emxUIConstants.STR_DISPLAY_MESSAGE_REALTIME_FORMBASEDVIEW;
				} else if (isformBased == "false") {
					splashArea.innerHTML = emxUIConstants.STR_DISPLAY_MESSAGE_NAVIGATIONVIEW;
		}else{
					splashArea.innerHTML = emxUIConstants.STR_DISPLAY_MESSAGE_FORMBASEDVIEW;
				}
			}
		}else{
			toggleButton = objTableFrame.document.getElementById("AEFFullSearchToggle");
		}

			if (toggleButton) {
			if (isformBased == "false" || this.refinementMode) 
			{
				toggleButton.title = emxUIConstants.STR_FORMBASEDVIEW;
					toggleButton.innerHTML = emxUIConstants.STR_FORMBASEDVIEW;
				} else {
				toggleButton.title = emxUIConstants.STR_NAVIGATIONVIEW;
					toggleButton.innerHTML = emxUIConstants.STR_NAVIGATIONVIEW;
				}
			if(queryType == "Real Time" && jQuery("#refinementPanel").html() == ""){
				$(toggleButton).addClass('button-disabled');
			}else{
				$(toggleButton).removeClass('button-disabled');
			}
		}
	},
	objectifyParams: function _objectifyParams(){
		var aParms = this.search.split("&");
		var len = aParms.length;
		var fordefault = false;
		var mode = this.getFormBasedMode();
		var queryType = this.getQueryType();
		for (var i = 0; i < len; i++) {
			aParms[i] = aParms[i].indexOf("field=") == -1 ? decodeURIComponent(aParms[i]) : aParms[i];
			if (aParms[i].indexOf("field=") >-1 || aParms[i].indexOf("default=") >-1) {
				fordefault =  aParms[i].indexOf("default=") >-1;
				var index = aParms[i].indexOf("=");
				this.objParameter[aParms[i].substring(0, index)] = aParms[i].substring(index + 1);				
				//For bug 374237
				//if((mode == null || mode == "false")){
					var fieldList = aParms[i].substring(index + 1).split(this.getFieldSeperator());
					for(var j = 0; j < fieldList.length; j++){
						var field = fieldList[j];
						var isNameParam =  field.indexOf("NAME=")!= -1;
						var op = "=";
						var opStr = "Equals";
						if(field.indexOf("!=") > -1){
							op = "!=";
							opStr = "NotEquals";
						}else if(field.indexOf(">") > -1 && !isNameParam){
							op = ">";
							opStr = "Greater";
						}else if(field.indexOf("<") > -1 && !isNameParam){
							op = "<";
							opStr = "Less";
						}else if(field.indexOf("=") > -1){
							op = "=";
							opStr = "Equals";
						}
						if(field.indexOf(op) > -1){
							var fieldName = field.split(op)[0];
							var fieldValues = field.split(op)[1];
							//bug fix - 369347
							if(isValidDate(fieldValues)){
							    fieldValues = fieldValues.replace(",",", ");
								if(this.filters[fieldName] == null){
									this.addToFilters(fieldName,fieldValues,opStr,true);
								}else{
									this.appendToFilters(fieldName,fieldValues,opStr);
								}
								continue;
							}
							var fieldValues = field.split(op)[1].split(",");
							//this.addToFilters(fieldName,fieldValues,opStr);
							for(var k = 0; k < fieldValues.length; k++){
								if(this.filters[fieldName] == null){
									this.addToFilters(fieldName,fieldValues[k],opStr,true);
								}else{
									this.appendToFilters(fieldName,fieldValues[k],opStr);
								}									
							}
							if(fordefault)
								this.defaultValues.push(fieldName);
						}
					}
				//}
			} else if(aParms[i].indexOf("ftsFilters=") == 0){
			    var index = aParms[i].indexOf("=");
				this.filters = eval('(' + aParms[i].substring(index + 1) + ')');
			}else if(aParms[i].indexOf(this.TEXT_SEARCH) == 0){
				var tmp = aParms[i].split("=");
				if (tmp.length == 2) {
					this.addToFilters(tmp[0],tmp[1],null);
					this.objParameter[tmp[0]] = tmp[1];
				}
			} else {
				var tmp = aParms[i].split("=");
				if (tmp.length == 2) {
					this.objParameter[tmp[0]] = tmp[1];
				}
			}
		}
		/* commented while merging from HF40 to 2010
		var url = this.getContentUrl();
		if(url != null && url.indexOf("filters=") > -1){
			var tempStr = url.substring(url.indexOf("filters"),url.length);
			var filterStr = "";
			if(tempStr != null && tempStr.indexOf("&") > -1){
				filterStr = tempStr.substring(0,tempStr.indexOf("&"));
			}else{
				filterStr = tempStr.substring(0,tempStr.length);
			}
			url = url.replace(filterStr,"");
			this.setContentUrl(url);
			this.form.action = url;
		}*/
		var mode = this.getFormBasedMode();
		if (mode == null || mode == "") {
			this.setFormBasedMode();
		}	
	},
	getTaxonomiesUrl: function _getTaxonomiesUrl(){
		return this.getURL(this.PROGRAM_TYPE);
	},
	getDynaTaxonomiesUrl: function _getDynaTaxonomiesUrl(){
		return this.getURL(this.PROGRAM_DYNA_TYPE);
	},
	getAttributeUrl: function _getAttributeUrl(){
		var url = this.getURL(this.PROGRAM_ATTRIBUTE)+ "&firstRequest=" + this.firstRequest;
		this.firstRequest = false;
		return url;
		
	},
	getClearCacheUrl: function _getClearCacheUrl(){
		return this.getURL(this.PROGRAM_CLEARCACHE);
	},
	getURL: function _getURL(strProg){
		var qb = new Query(this.DATA_URL + "?" + this.search);
		qb.replace(this.PROGRAM, strProg, true);
		qb.replace(this.PARAM_FIELD, this.getField(), true);
		//qb.replace(this.FILTER_FIELDNAME, encodeURIComponent(this.filters.toJSONString()), true);
		qb.replace(this.FILTER_FIELDNAME, emxUICore.toJSONString(this.filters), true);
		qb.replace(this.PARAM_VIEW_FORM_BASED, this.getFormBasedMode(), true);
		qb.replace(this.PARAM_COLLECTION, this.getCollection(), true);
		qb.replace(this.PARAM_SEARCH_TIME_STAMP, this.searchtimeStamp, true);
		
		var counts = (this.getIncludeCounts() == true)? "true" : "false";
		qb.append(this.PARAM_INCLUDECOUNTS, counts);
		qb.set(this.PARAM_CASE_SENSITIVE, this.getCaseSensitiveSearch());
		return qb.toString();
	},
	
	jsonObjectToXML: function _jsonObjectToXML(root, currentNode, obj){
		for (var key in obj) {
			switch (typeof obj[key]) {
				case "object":
					var newNode = root.createElement(typeof obj[key]);
					//if(key == 'WORKSPACES') {
					if(typeof this.TOGGLE_STATUS[key] != "undefined") {
						newNode.setAttribute("isExpanded", this.TOGGLE_STATUS[key]);
					} else if(this.TOGGLE_STATUS[key] == null){
						newNode.setAttribute("isExpanded", "true");
					}
					
					newNode.setAttribute("id", key);
					currentNode.appendChild(newNode);
					this.jsonObjectToXML(root, newNode, obj[key]);
					break;
				case "string":
				case "number":
					if (key != 'valuesList' && key != 'dataType' && key != 'field') {
						var newNode = root.createElement(typeof obj[key]);
					} else {
						var newNode = root.createElement(key);
					}
					newNode.setAttribute("id", key);
					currentNode.appendChild(newNode);
					newNode.appendChild(root.createTextNode(obj[key]));
					break;
				case "boolean":
					currentNode.setAttribute(key, (obj[key] == 0) ? "false" : "true");
					break;
				case "function":
					break;
				default:
					alert(key + " = " + typeof obj[key]);
			}
		}
	},

	resetField: function _resetField(fName, defaultFieldValue, selectedValue){
		//var fName = objElm.getAttribute(this.FILTER_NAME);
		if(isIE){
		selectedValue =	utf8Decode(selectedValue);
		}
		if (this.filters[fName] || this.isFormBasedMode()) {
			if(fName == "TYPE" && this.getQueryType().toLowerCase() != "indexed"){
				delete this.filters["TYPES"];
			}else{
			delete this.filters[fName];
			}
			delete this.inputControlFilter[fName];
			//var defaultFieldValue = objElm.getAttribute('defaultFieldValue');
			if(isValidDate(defaultFieldValue)){
				defaultFieldValue = defaultFieldValue.replace(",",", ");
			}
			if(defaultFieldValue == '' || defaultFieldValue == null || defaultFieldValue == 'undefined') {
				defaultFieldValue = '';
			} else {
				if(defaultFieldValue.indexOf("!") == 0){
					this.addToFilters(fName,defaultFieldValue.substring(1),"NotEquals");
				} else {
					this.addToFilters(fName,defaultFieldValue);
				}
			}
			document.getElementById(fName).value = selectedValue;
			
			//revision field will not contain the hidden value, verify before assigning the value to hidden field
			var fieldHiddenValue = document.getElementById("hidden_" + fName);
			if(fieldHiddenValue) {
				fieldHiddenValue.value=selectedValue;	
			}		
		}		
		this.toggleSearchButton();		
	},
	
	showValuesHierarchy: function _showValuesHierarchy(objElm, data){
		var fName = objElm.getAttribute(this.FILTER_NAME);

		// TODO: for attributes that are not parametric, or dates, do not call getNewAttrData
		// This may require an XSL change to mark parametric vs. non-parametric attributes
		// as well as their data types (perhaps as additional attributes on objElm, otherwise
		// as global data obtained from the last call to loadAttributeData
		
		if (data == undefined) {
			this.getNewAttrData(fName, function _showValuesHierCB(data) {
				FullSearch.showValuesHierarchy(objElm, data);
			});
		}

		var allAttrData = data;
		
		if (allAttrData == null) {
			return;
		}

		var oneAttrData = null;
		with (allAttrData.obj) {
			for (var i = 0; i < attributes.length; i++) {
				if (attributes[i].attribute == fName) {
					oneAttrData = attributes[i];
					break;
				}
			}
		}
		if (this.floatingDiv) {
			this.removeFloatingDiv();
		}
		var outerDiv = document.createElement("div");
		outerDiv.setAttribute("class", "popup form multi-list");
		
		if (!this.isFormBasedMode()) {
			this.elementDiv = objElm.parentNode.parentNode;
			this.elementDiv.style.background = "#CCCCCC";
		}
		
		document.forms["full_search"].appendChild(outerDiv);
		
		if (!oneAttrData) {
			alert(emxUIConstants.STR_JS_NoDataFor + fName);
			return;
		}
		
		//In form based mode by default list box with default values will be shown
		if (oneAttrData.values != null && oneAttrData.values.length > 0 && oneAttrData.dataType != "timestamp") {
				oneAttrData.dataType = "default";
		}else if(oneAttrData.dataType == 'string' && this.isFormBasedMode()){
			var objElement = document.getElementById(fName);
			objElement.setAttribute("Delimiter",",");
			objElement.setAttribute("isReadOnly","true");
			this.displayDynamicTextarea(objElement);
			return;
		}
		
		// XSL template looks for 'fName', not 'attribute' for some reason
		oneAttrData.fName = oneAttrData.attribute; 
		
		var filt = this.filters[fName];
		if (filt && oneAttrData.values) {
			for (var i = 0; i < oneAttrData.values.length; i++) {
				if (filt.find("Equals|" + oneAttrData.values[i].value) >= 0) {
					oneAttrData.values[i].selected = "true";
				}
			}
		}else if(filt && oneAttrData.fieldSeparator){
			for (var i = 0; i < oneAttrData.complexValues.length; i++) {
				var fieldName = oneAttrData.complexValues[i].option;
				var objRangeValues = oneAttrData.complexValues[i];
				for(var j = 0; j < objRangeValues.rangeValues.length; j++){
					var fieldValue = objRangeValues.rangeValues[j].value;
					var matchString = "Equals|" + fieldName + oneAttrData.fieldSeparator + fieldValue;
					if (filt.find(matchString) >= 0) {
						objRangeValues.rangeValues[j].selected = "true";
					}
				}
			}
		}
		var attrObj = {};
		var attrDispObj = {};
		var allAttrString = "";
		var allAttrDispString = "";
		var count = {};		
		if(oneAttrData.fieldSeparator){
			for (var i = 0; i < oneAttrData.values.length; i++) {
				var attrValues = oneAttrData.values[i].value.split(oneAttrData.fieldSeparator);
				var attrDispValues = oneAttrData.values[i].displayValue.split(oneAttrData.fieldSeparator);
				if(allAttrString == ""){
					allAttrString = oneAttrData.values[i].value;
					allAttrDispString = oneAttrData.values[i].displayValue;
				}else{
					allAttrString += "|" + oneAttrData.values[i].value;
					allAttrDispString += "|" +  oneAttrData.values[i].displayValue;
				}
				var attrPrevValues = null;
				if(i > 0){
					attrPrevValues = oneAttrData.values[i-1].value.split(oneAttrData.fieldSeparator);
				}
                var tempLength = 30;
				for(var j = 0; j < attrValues.length; j++){
					if(attrObj[j] == null){
						attrObj[j] = {};
						attrDispObj[j] = {};
						attrObj[j] = attrValues[j];
						attrDispObj[j] = attrDispValues[j];
                        tempLength = attrValues[j].length;
					}else{
						if(attrValues[j] != attrPrevValues[j]){
							attrObj[j] += "|"+ attrValues[j];
							attrDispObj[j] += "|"+ attrDispValues[j];
							var tempLength1 = tempLength;
							tempLength = attrValues[j].length;
							if (tempLength<tempLength1){
							tempLength = tempLength1;
							}
						}						
					}
				}
			}
			var objComplex = document.createElement("DIV");
			var objTable = document.createElement("ul");
			var objSPAN1 = document.createElement("span");
			var objSPAN2 = document.createElement("span");
			var objTD1 = document.createElement("li");
			var objTD2 = document.createElement("li");
			objTD2.setAttribute("id","complex-controls-td");
			objSPAN1.setAttribute("class","input");
			objSPAN2.setAttribute("class","input list");
			objTable.appendChild(objTD1);
			objTable.appendChild(objTD2);
			objComplex.appendChild(objTable);
			var objTextBox = document.createElement("INPUT");
			objTextBox.setAttribute("name",fName);
			objTextBox.setAttribute("id",fName);
			objTextBox.setAttribute("value","*");
			var tmpCurrAttrVal = attrObj["0"].replace(/\'/g,"\\\'");
			objTextBox.setAttribute("onkeyup","FullSearch.refineListBox(this,'"+tmpCurrAttrVal+"','"+oneAttrData.levels+"','"+fName+"','"+oneAttrData.fieldSeparator+"');");
			objTD1.appendChild(objSPAN1);
			objSPAN1.appendChild(objTextBox);

				eval("var objSelect"+0+"= null;");
				var currSelect = eval("objSelect"+0);
				
				currSelect = document.createElement("SELECT");
				currSelect.setAttribute("multiple","yes");
				currSelect.setAttribute("id",fName+"_0");
				currSelect.setAttribute("name",fName+"_0");
				currSelect.setAttribute("level",0);
				var tmpAllAttrVal = allAttrString.replace(/\'/g,"\\\'");
				allAttrDispString = allAttrDispString.replace(/\'/g,"\\\'");
				currSelect.setAttribute("onchange","FullSearch.refreshNextField(this,'"+tmpAllAttrVal+"','"+allAttrDispString+"','"+(parseInt(0)+1)+"','"+oneAttrData.levels+"','"+fName+"','"+oneAttrData.fieldSeparator+"')");
				var attrValues = attrObj[0].split("|");
				var attrDispValues = attrDispObj[0].split("|");
				var attrSize = 10;
				
				currSelect.setAttribute("size",attrSize);
				var flag = false;
				for(var j = 0; j < attrValues.length; j++){
					var key = attrDispValues[j];
					var value = attrValues[j].substring(attrValues[j].indexOf(oneAttrData.fieldSeparator)+1,attrValues[j].length);
					currSelect.options[currSelect.options.length] =  new Option(key,value);		
				}
				objTD2.appendChild(objSPAN2);
				objSPAN2.appendChild(currSelect);
		}
		
		if(oneAttrData.dataType == 'timestamp' && this.isFormBasedMode()) {
			oneAttrData.operator = "";
			var dateval = document.getElementById(fName).value;
			if(dateval != '' && dateval != null)
			{
				if(dateval.indexOf('<') == 0) {
					oneAttrData.operator = "Less";
					oneAttrData.fromvalue = dateval.substring(2);
				} else if(dateval.indexOf('>') == 0) {
					var lesind = dateval.indexOf('<');
					if(lesind > 0) {
						oneAttrData.operator = "Between";
						oneAttrData.fromvalue = dateval.substring(2, lesind - 2);
						oneAttrData.tovalue = dateval.substring(lesind + 2);
					} else {
						oneAttrData.operator = "Greater";
						oneAttrData.fromvalue = dateval.substring(2);
					}
				} else {
					oneAttrData.operator = "Equals";
					oneAttrData.fromvalue = dateval;
				}
				//IR-128271V6R2013
				if(oneAttrData.fromvalue){
					oneAttrData.frommsvalue = this.getMSValue(oneAttrData.fromvalue);
				}
				if(oneAttrData.tovalue){
					oneAttrData.tomsvalue = this.getMSValue(oneAttrData.tovalue);
				}
			}
		}
		var oneAttrXML = this.convertJSONtoXML(oneAttrData);
		//IR-014268V6R2010x
		if(isIE){
			this.FORM_WIDGETS_XSL.setProperty("SelectionNamespaces", "xmlns:xsl='http://www.w3.org/1999/XSL/Transform'");
		}
		var formMode = emxUICore.selectSingleNode(this.FORM_WIDGETS_XSL.documentElement, "/xsl:stylesheet/xsl:variable[@name = 'formMode']");
        emxUICore.setText(formMode, FullSearch.isFormBasedMode());
		if(oneAttrData.fieldSeparator){
			outerDiv.innerHTML = this.transformToText(oneAttrXML, this.FORM_WIDGETS_XSL);
			var complexDiv = document.getElementById("complex_"+fName);
			complexDiv.innerHTML = objComplex.innerHTML;
			var hrefValue = "";
			var displayValue = "";
			var valueToBeReplaced = "";
			var applyBreadCrumbs = document.getElementById("applyBreadCrumbs");
			if(applyBreadCrumbs){
				hrefValue = document.getElementById("applyBreadCrumbs").attributes['onclick'].value;
				displayValue = hrefValue.split("','")[4];
				valueToBeReplaced = displayValue.replace(/\'/g,"\\\'");
				valueToBeReplaced = valueToBeReplaced.substring(0,valueToBeReplaced.length-3);
				hrefValue = hrefValue.replace(displayValue,valueToBeReplaced+"')");
				applyBreadCrumbs.attributes['onclick'].value = hrefValue;
			}
			
		}else{
			outerDiv.innerHTML = this.transformToText(oneAttrXML, this.FORM_WIDGETS_XSL);
		}
		
	/* Mx361263 */
	if(oneAttrData.fName == 'VAULT' && !(this.getQueryType().toLowerCase() == "indexed")) {
		var selectedVault = document.getElementById(fName).value;
		if(selectedVault != "" || selectedVault != null) {
			var vaultOptions = document.getElementsByName("vaultSelction");
			for(var i = 0; i < vaultOptions.length; i++) {
				if(vaultOptions[i].value == selectedVault) {
					vaultOptions[i].checked = "checked";
					disableVaultSelectionList();
					break;
				}
			}
		}
	}
	/* end Mx361263 */
	
		this.floatingDiv = outerDiv;
		
		var typeIn = document.getElementById('input_' + fName);
		if (typeIn)	{
			typeIn.focus();
		}
		
		if (this.isFormBasedMode()) {
			var fName = objElm.getAttribute("filter_name");
			var referenceElem = document.getElementById(fName);
			if (!referenceElem) {
				referenceElem = objElm;
			}
			//adding a left border for form view, need to move this logic to the css
			//this.floatingDiv.style.borderLeft = "1px solid gray";
			//calculate y offsets so widgets don't go off screen
			var y = (findPosY(referenceElem) - this.formView.scrollTop - (this.floatingDiv.offsetHeight - referenceElem.offsetHeight)/2);
			this.floatingDiv.style.top = y + "px";
			//calculate x offsets so widgets don't go off screen
			var x = findPosX(objElm)+ objElm.offsetWidth + 10 - this.formView.scrollLeft;
			this.floatingDiv.style.left = x + "px";
			var minWidth = referenceElem.offsetWidth + objElm.offsetWidth;
			if (this.floatingDiv.offsetWidth < minWidth && oneAttrData.fieldSeparator == null) {
				this.floatingDiv.style.width = minWidth + "px";
				var selWidget = document.getElementById("select_" + fName);
				if (selWidget) {
					selWidget.style.width= "100%";
				}
			}
			referenceElem.parentNode.parentNode.className = "active";
		} else {//Nav mode
			var y = (findPosY(objElm) - this.nav.scrollTop - 1);
			this.floatingDiv.style.top = y -(this.floatingDiv.offsetHeight - objElm.offsetHeight)/2 + "px";	
			this.floatingDiv.style.left =  "330px";
		}
		var wh = getWindowHeight();
		if(this.floatingDiv.offsetHeight + this.floatingDiv.offsetTop > wh){
			var y = this.floatingDiv.offsetTop;
			this.floatingDiv.style.top = wh - this.floatingDiv.offsetHeight + "px";
			this.floatingDiv.style.paddingBottom = (this.floatingDiv.offsetHeight + y - wh)*2 + "px";
		}
	    var reqDiv = document.getElementById("complex_"+fName);
	    if(reqDiv){
	    	var actDivWidth = jQuery(reqDiv).width();
			adjustComplexControlDiv(reqDiv,actDivWidth);
	    }

	},
	
	//IR-128271V6R2013
	//calculate millisec value of the date string passed.
	getMSValue: function _getMSValue(dateStr){
		var strURL = URL_GET_CALENDAR_LOAD;
		strURL = addURLParam(strURL, "date=" + escape(dateStr));
		var strData = emxUICore.getData(strURL);
        var arrData = strData.split("|");
        var timeInMSVal = new Date(parseInt(arrData[0]), parseInt(arrData[1]), parseInt(arrData[2])).getTime();
        var dateValMS = timeInMSVal + 12 * 60 * 60 * 1000 + "";
        return dateValMS;
	},
	
	getNewAttrData: function _getNewAttrData(fName, fnCallback){
		var res = null;
		// Get data from server w/o any filtering on fName
		var savedFilter = this.filters[fName];
		this.filters[fName] = null;
		delete this.filters[fName];
		
		this.setCountsOrNoCountsMode();
		var savedInclCounts = this.includeCounts;
		if (savedFilter != undefined) {
			// includeCounts may have been true because this particular filter
			// made it feasible, but we are now temporarily removing that filter
			// so the safe thing to do is to not include counts.
			this.includeCounts = false;
		}

		try {
			var qb = new Query(this.getAttributeUrl());
			qb.set("currentField",fName);
			qb.set("singleField", fName);
			qb.set("refreshRefinements", "true");
			//qb.remove("field");
			if(FullSearch.clearSearchTimeStamp){
				
				qb.append("refreshRefinements","true");
				
				FullSearch.clearSearchTimestamp = false;
			}
			this.getServerData(qb.toString(), fnCallback, "Getting values");
		} catch (err) {
			alert(err.message);
			return;
		} finally {
			// reset filters back to original
			if (savedFilter != undefined) {
				this.filters[fName] = savedFilter;
			}
			this.includeCounts = savedInclCounts;
		}
	},
	
	removeSearchTimestamp: function _removeSearchTimestamp(textBox,textAreaValue){
		//only for fields like Name,Description
		var isReadOnlyField = textBox.getAttribute("readonly");	
  		if(textBox.getAttribute("value") != textAreaValue && isReadOnlyField!= "true"){
  			FullSearch.clearSearchTimeStamp = true;
  		}		
	},
	
	displayDynamicTextarea: function _displayDynamicTextarea(inputObj){
		if (this.floatingDiv) {
			this.removeFloatingDiv();
		}

		/*var tmpFunc = hideDynamicSetText;
		hideDynamicSetText = function(arg1, arg2){
			var minReqChars = inputObj.getAttribute("minReqChars");
			if(minReqChars != null) {
				arg1.setAttribute("minReqChars", minReqChars);
			}
			
			if(!FullSearch.validateSearchText(arg1, "\n")){
				arg1.focus();
				return;
			}
			tmpFunc(arg1, arg2);
			formReplaceInput(inputObj);
		}*/
		displayDynamicTextarea(inputObj, true);
		
	},
	hideDynamicSetText: function _hideDynamicSetText(textareaElement,Delimiter,inputObj){
		//var inputObj = document.forms[0].elements[elementName];
		var minReqChars = inputObj.getAttribute("minReqChars");
		if(minReqChars != null) {
			textareaElement.setAttribute("minReqChars", minReqChars);
		}
		
		if(!this.validateSearchText(textareaElement, "\n")){
			textareaElement.focus();
			return;
		}
		hideDynamicSetText(textareaElement, Delimiter);
		formReplaceInput(inputObj, Delimiter);
		inputObj.parentNode.parentNode.className="";
	},
	toggle: function _toggle(objElm,fieldSep){
		turnOnProgress();
		ElapsedTimer.reset("--------------  toggle " + objElm.getAttribute(this.FILTER_NAME));
		this.setFirstPage(1);
		if (this.floatingDiv && fieldSep == null) {
			this.removeFloatingDiv();
		}

		var fName, fVal, blnSelected, fDisplayValue, operator;
		fName = objElm.getAttribute(this.FILTER_NAME);
		fVal = objElm.getAttribute(this.FILTER_VALUE);
		blnSelected = (objElm.getAttribute(this.SELECTED) == "true");
		operator = objElm.getAttribute(this.OPERATOR);
		var fIdx = objElm.getAttribute("filter_index");
		if(!this.getImmediateMode() && this.taxonomies[fName] != null){
			if(blnSelected){
				var selectImg = objElm.firstChild;
				selectImg.parentNode.removeChild(selectImg);
				objElm.parentNode.className = "show";
				objElm.setAttribute(this.SELECTED,"");
				if(this.taxonomyDispValues[fName] != null){
					fDisplayValue = objElm.getAttribute(this.FILTER_DISPLAYVALUE);
					if(this.taxonomyDispValues[fName].find(fDisplayValue) > -1){
						this.taxonomyDispValues[fName].remove(fDisplayValue);
					}
				}
				this.setType(fName, fVal);
				this.removeFilter(fName, fVal);
			}else{
				var selectImgTag = document.createElement("IMG");
				var selectImgTag = document.createElement("img");
				selectImgTag.setAttribute('id', "selectImg");
				selectImgTag.setAttribute("src", "../common/images/fullSearchButtonSelected.gif");
				if(objElm.firstChild.tagName == null){
					objElm.insertBefore(selectImgTag,objElm.firstChild);
				}
				objElm.parentNode.className = "selected";
				objElm.setAttribute(this.SELECTED,"true");
				if(this.taxonomyDispValues[fName] == null){
					this.taxonomyDispValues[fName] = [];
				}
				fDisplayValue = objElm.getAttribute(this.FILTER_DISPLAYVALUE);
				this.taxonomyDispValues[fName].push(fDisplayValue);
				this.appendToFilters(fName, fVal, blnSelected);
			}
		}else{
			if (this.isFormBasedMode()) {
				fDisplayValue = objElm.getAttribute(this.FILTER_DISPLAYVALUE);
				getSelectedValue(fName, fVal, fDisplayValue, blnSelected);
				this.setJSONdata();
				ElapsedTimer.timeCheck("after setJSONData");
				this.loadForm();
				ElapsedTimer.timeCheck("after loadForm");
				//bug 369343
				this.toggleSearchButton();
				turnOffProgress();
				return true;
			}
			
			if (fName && fVal) {
					this.filterResults(fName, fVal, blnSelected, operator,fieldSep,fIdx);
				this.toggleSearchButton();
				ElapsedTimer.timeCheck("after filterResults");
			} else {
				this.showValuesHierarchy(objElm);
				ElapsedTimer.timeCheck("after showValuesHier");
			}
		}
		turnOffProgress();
		ElapsedTimer.timeCheck("after toggle");		
	},
	toggleDyna: function _toggleDyna(objElm,select,fieldSep){
		turnOnProgress();
		this.setFirstPage(1);
		if (this.floatingDiv && fieldSep == null) {
			this.removeFloatingDiv();
		}

		var blnSelected, fDisplayValue;
		var searchNode = [];
		var searchNodeDisp = [];
		this.dynaName = objElm.data.taxonomyType;	
		objElm.data.select = true;
			var selectedNodes = objElm.tree.getSelectedNodes();
			for(var i=selectedNodes.length-1; i>=0; i--){
				if(selectedNodes[i].data.hideCheckbox || (selectedNodes[i].parent.data.hideCheckbox != true && selectedNodes.find(selectedNodes[i].parent) > -1)){
					selectedNodes.remove(selectedNodes[i]);
				}
			}

			for(var j=0; j<selectedNodes.length; j++){
				searchNode.push(selectedNodes[j].data.type);
				var nodeTitle = selectedNodes[j].data.title;
				searchNodeDisp.push(nodeTitle.substr(0,nodeTitle.lastIndexOf("(")));
			}
			
			if(searchNode.length > 0){
				this.dynaValue = searchNode.join(emxUIConstants.STR_REFINEMENT_SEPARATOR);
				fDisplayValue = searchNodeDisp.join(emxUIConstants.STR_REFINEMENT_SEPARATOR);
				if(objElm.tree.getActiveNode()){
					objElm.tree.getActiveNode().deactivate();
				}
			}else{
				delete this.filters[this.dynaName];
				delete this.taxonomies[this.dynaName];
				this.dynaValue = objElm.data.type;
				blnSelected = true;
			}
			this.setTaxonomyDispValues(this.dynaName,fDisplayValue);
			if (this.isFormBasedMode()) {
				if(fDisplayValue){
					this.textbox.value = fDisplayValue;	
				}else{
					this.textbox.value = "";
				}
			}
			if (this.dynaName && this.dynaValue) {
				this.filterResults(this.dynaName, this.dynaValue, blnSelected, null,fieldSep);
				this.toggleSearchButton();
				ElapsedTimer.timeCheck("after filterResults");
			} 
		turnOffProgress();
		ElapsedTimer.timeCheck("after toggle");		
	},
	toggleTaxonomyExpand: function _toggleTaxonomyExpand(objThis,taxonomy,value){
		var isExpanded = objThis.getAttribute("expanded") == "true";
		var nextLevel = parseInt(objThis.getAttribute("level")) + 1;
		var hasSibling = objThis.getAttribute("hasSibling");
		
		
		var objParent = objThis.offsetParent;
        var divId = null;
        if(objParent.getAttribute("id") != null && objParent.getAttribute("id") != ""){
        	divId = objParent.getAttribute("id");
        }else if(objParent.parentNode.getAttribute("id") != null && objParent.parentNode.getAttribute("id") != ""){
        	divId = objParent.parentNode.getAttribute("id");
        }
        var objChild = document.getElementById("sub_" + divId);
        if(isExpanded == false){
        	objThis.setAttribute("expanded", "true");
			var qb = new Query(this.getTaxonomiesUrl());
			var filterArr = {};
			filterArr[taxonomy] = [];
			filterArr[taxonomy].push("Equals|"+value);
			qb.set("field", taxonomy+"="+value);
			//qb.set("filters", filterArr.toJSONString());
			qb.set("parentTaxonomy", "true");
			var filterTaxJSON = this.getServerData(qb.toString(), null, emxUIConstants.STR_LOADING_CHILD_TAXONOMIES);
			var childTaxData = null;
			for (var i = 0; i < filterTaxJSON.objs.length; i++) {
				var temp = filterTaxJSON.objs[i];
				for (key in temp) {
					if (key == taxonomy) {
						childTaxData = temp;
					}
				}
			}
			var objXML = this.convertJSONtoXML(childTaxData);
			var objectNode = emxUICore.selectSingleNode(objXML.documentElement,"/mxRoot/object");
			if(objectNode != null){
				objectNode.setAttribute("currLevel", ""+nextLevel);
				objectNode.setAttribute("hasSibling", hasSibling);
			}
			var fieldNode = emxUICore.selectSingleNode(objXML.documentElement,"/mxRoot/field");
			if(fieldNode != null){
				fieldNode.parentNode.removeChild(fieldNode);
			}
			var childHTML = this.transformToText(objXML, this.LEFT_NAV_WIDGET_XSL);
			if (objChild != null) {
				objChild.innerHTML = childHTML;
			}
		}
        
        var objImg = objThis;
		if (objChild != null && objChild.childNodes.length > 1) {
                if (objChild.className == "" || objChild.className == "hide") {
                        objChild.className = "show";
                        for(var i = 0; i < objChild.childNodes.length; i++){
                        	objChild.childNodes[i].className = "show";
                        }
                        objImg.src = objImg.src.replace("Closed", "Open");
                } else {
                        objChild.className = "hide";
                        for(var i = 0; i < objChild.childNodes.length; i++){
                        	objChild.childNodes[i].className = "hide";
                        }
                        objImg.src = objImg.src.replace("Open", "Closed");
                }
        } else if(objChild != null){
			if (objChild.className == "" || objChild.className == "hide") {
                objChild.className = "show";
                for(var i = 0; i < objChild.childNodes.length; i++){
                	objChild.childNodes[i].className = "show";
                }
                objImg.src = objImg.src.replace("Closed", "Open");
            } else {
                objChild.className = "hide";
                for(var i = 0; i < objChild.childNodes.length; i++){
                	objChild.childNodes[i].className = "hide";
                }
                objImg.src = objImg.src.replace("Open", "Closed");
            }
        }
	},
	refreshTaxonomies: function _refreshTaxonomies(btnName,taxonomy){
		this.setJSONdata();
		if(this.isFormBasedMode()){
			this.loadForm();
			var strDispValue = "";
			if(this.taxonomyDispValues[taxonomy] != null){
				var tmpDispArr = this.taxonomyDispValues[taxonomy];
				for(var i = 0; i < tmpDispArr.length; i++){
					if(strDispValue == ""){
						strDispValue = tmpDispArr[i];
					}else{
						strDispValue += emxUIConstants.STR_REFINEMENT_SEPARATOR + tmpDispArr[i];
					}
				}
			}
			this.textbox.value = strDispValue;
			showTypeHierarchyPopup(btnName,taxonomy);
		}else{
			this.loadNavData();
		}
	},
	setTaxonomyDispValues: function _setTaxonomyDispValues(taxonomy,txtValue){
				this.taxonomyDispValues[taxonomy] = [];
				var tmpDispArr = txtValue?txtValue.split(emxUIConstants.STR_REFINEMENT_SEPARATOR):[];
				for(var i = 0; i < tmpDispArr.length; i++){
					this.taxonomyDispValues[taxonomy].push(tmpDispArr[i]);
				}
	},
	addInputToFilters: function _addInputToFilters(fName, dataType, fieldSeparator){
		ElapsedTimer.reset("addInputToFilters " + fName);
		var selectField = "";
		var operator = "";
		var fValue = "";
		var fValue_msValue = "";
		var fValue2 = "";
		var fValue2_msValue = "";
		var fDisplayValue = "";
		var objElm = document.getElementById(fName);
		
		switch (dataType) {
			case 'timestamp':
			operator = document.getElementById(fName + "_operation").value;
				fValue = document.getElementById(fName + "_fromvalue").value;
				fValue_msValue = document.getElementById(fName + "_fromvalue"+"_msvalue").value;
				fDisplayValue = fValue;
				if (fValue == "") {
					alert(emxUIConstants.STR_VALID_DATE_ALERT);
					return;
				}
				if (operator == "Between") {
					fValue2 = document.getElementById(fName + "_tovalue").value;
					fValue2_msValue = document.getElementById(fName + "_tovalue"+"_msvalue").value;
					if(parseInt(fValue2_msValue) > parseInt(fValue_msValue)){
					this.addToFilters(fName, fValue, "Greater");
					this.appendToFilters(fName, fValue2, "Less");
					}else{
						this.addToFilters(fName, fValue2, "Greater");
						this.appendToFilters(fName, fValue, "Less");
					}					
					if (fValue == "" || fValue2 == "") {
						alert(emxUIConstants.STR_VALID_DATE_ALERT);
						return;
					}
				}
				break;
			case 'integer':
			case 'real':
				fValue = document.getElementById("text_" + fName).value;
				if (isNaN(fValue)) {
					alert(emxUIConstants.STR_VALID_NUMERIC_ALERT);
					return;
				}
				var uomValue = document.getElementById(fName + "_uom");
				operator = document.getElementById(fName + "_operation").value;
				if (uomValue) {
					fValue += " " + uomValue.value;
				}
				if (operator == "Between") {
					fValue2 = document.getElementById("text_to_" + fName).value;
					if (isNaN(fValue2)) {
						alert(emxUIConstants.STR_VALID_NUMERIC_ALERT);
						return;
					}
					if (uomValue) {
						fValue2 += " " + uomValue.value;
					}
					this.addToFilters(fName, fValue, "Greater");
					this.appendToFilters(fName, fValue2, "Less");
			}
				fDisplayValue = fValue;
				break;
			case 'string':
			case 'default':
				if (fieldSeparator != null && fieldSeparator != "") {
			if (this.inputControlObject[fName] == null || this.inputControlObject[fName].length <= 0) {
				return;
			}
					var formDispValue = "";
					fValue = emxUICore.toJSONString(this.inputControlFilter);
			for(var itr=0; itr<this.inputControlObject[fName].length; itr++) {
				if (formDispValue == "") {
					formDispValue = this.inputControlObject[fName][itr].displayValue;
				} else {
					formDispValue += emxUIConstants.STR_REFINEMENT_SEPARATOR + this.inputControlObject[fName][itr].displayValue;
				}
			}
			if (!this.isFormBasedMode()) {
				document.getElementById("complex-control").style.display = "none";
				document.getElementById("complex-control").innerHTML = "";
				this.nav.style.top = this.header.offsetHeight + this.options.offsetHeight + 3 + "px";
			}else{
				fDisplayValue = formDispValue;
			}
			this.inputControlObject[fName] = null;
		} else {
			var nothingSelected = true;

			/* Mx361263 */
			var vaultOptions = document.getElementsByName("vaultSelction");
			if(vaultOptions != null && vaultOptions.length > 0) {
				for(var i = 0; i < vaultOptions.length; i++) {
					if(vaultOptions[i].checked) {
						var vaultSelected = vaultOptions[i].value;
						break;
					}
				}
			}

			if(vaultOptions != null && vaultOptions.length > 0 && vaultSelected != 'SELECTED_VAULTS') {
				var fValue = vaultSelected;
				var fDisplayValue = vaultSelected;
			}
			/* end Mx361263 */
			else {
					selectField = document.getElementById("select_" + fName);
					if (selectField != null && selectField != 'undefined') {
			for (var i = 0; i < selectField.options.length; i++) {
				if (selectField.options[i].selected) {
					nothingSelected = false;
					var value = selectField.options[i].value;
					var dispvalue = selectField.options[i].text;
					if (this.getIncludeCounts() && dispvalue != "" && dispvalue.indexOf("(") > -1) {
						/*372962*/
						//dispvalue = dispvalue.substring(0,dispvalue.lastIndexOf("("));
						dispvalue = dispvalue.replace(/\(\d*\)/," ");
					}
					
					if (fValue == "") {
						fValue = value;
						fDisplayValue = dispvalue;
					} else {
						fValue += emxUIConstants.STR_REFINEMENT_SEPARATOR + value;
						fDisplayValue += emxUIConstants.STR_REFINEMENT_SEPARATOR + dispvalue;
					}
				}
			}
					} else {
						selectField = document.getElementById("input_" + fName);
						if(!this.validateSearchText(selectField, ",")) {
							selectField.focus();
							return;
						}						
						var value = selectField.value;
						if (value != '' && value != '*') {
							nothingSelected = false;
							fValue = value;
						}else if("REVISION"==fName){
							selectField1 = document.getElementById("lastRevision_NavMode");
							selectField2 = document.getElementById("latestRevision_NavMode");
							if(selectField1.checked){								
									fName = "LASTREVISION";
									fValue = "TRUE";
									nothingSelected = false;
								}else if(selectField2.checked){
									fName = "LATESTREVISION";
									fValue = "TRUE";
									nothingSelected = false;
								}						
						}
					}
			if (nothingSelected) {
				fValue = "*";
			}
		}
				break;
		}
	}

		blnSelected = true;
		this.removeFloatingDiv();
		
		if (this.isFormBasedMode()) {
			var disValue = "";
			var dbvalue = "";
			if (fValue != null && fValue.length > 0) {
				dbvalue = strReplaceAll(fValue, "|", ",");
			}
			dbvalue = (dbvalue == "" || dbvalue == null) ? fValue : dbvalue;
			disValue = (disValue == "" || disValue == null) ? fDisplayValue : disValue;
			var strTmp = "";
			var txtDateFilter = "";
			switch (operator) {
				case "Greater":
					strTmp = "> ";
					break;
				case "Less":
					strTmp = "< ";
					break;
				case "Between":
					if(parseInt(fValue2_msValue) > parseInt(fValue_msValue)){
						txtDateFilter = "> " + fValue + ", < " + fValue2;
					}else{
						txtDateFilter = "> " + fValue2 + ", < " + fValue;
					}
					document.getElementById(fName).value = txtDateFilter;
					this.toggleSearchButton();
					return;	
				default:
			}
			
			document.getElementById(fName).value = strTmp + disValue;
			this.addToFilters(fName, fValue, operator);
			if(this.getQueryType().toLowerCase() != "indexed"){
				this.validatePolicyAndState(fName);
			}
		} else {
			if (operator == "Between") {
				//this.formSearch();
				
				this.filterResults(fName, fValue, false, operator);
			} else {
				this.filterResults(fName, fValue, false, operator);
			}
			ElapsedTimer.timeCheck("after filterResults");
		}
		this.toggleSearchButton();
		ElapsedTimer.timeCheck("after addInputToFilters");
	},
	createDiv: function _createDiv(objElm, list, dataType){
		this.showValuesHierarchy(objElm);
	},
	removeFloatingDiv: function _removeFloatingDiv(fieldName,fielSep){
		if (this.floatingDiv) {
			this.floatingDiv.parentNode.removeChild(this.floatingDiv);
			this.floatingDiv = null;
		}

		if (this.elementDiv) {
			this.elementDiv.removeAttribute("style");
		}
		if(fielSep){
			var objDiv = document.getElementById("complexcontrol_"+fieldName);
			if (objDiv != null) {
				var objParentDiv = objDiv.parentNode;
				objParentDiv.removeChild(objDiv);
				objParentDiv.style.display = "none";
			}
			this.inputControlObject[fieldName] = null;
		}
		//reset cached calendar controls. Calendars are attached to inputs
		//when input is destroyed we can no longer re-use cached calendar
		localCalendars = new Array();
		jQuery('li.active').removeClass('active');
	},
	enableDateField: function _enableDateField(objElm){
		var objName = objElm.name;
		var toDateField = document.getElementById(objName.substring(0, objName.indexOf("_")) + "_tovalue");
		if (objElm.value == "Between") {
			toDateField.disabled = false;
		} else {
			toDateField.disabled = true;
		}
	},
	
	filterResults: function _filterResults(filterName, filterVal, blnSelected, operator, fieldSep, fIdx){
		//alert('filterResults ' + filterName + " " +filterVal + ' ' + blnSelected + ' ' + operator + ' ' + fieldSep)

		var url = decodeURIComponent(this.form.action);
		if (blnSelected && !this.getImmediateMode()) {
//			this.setIncludeCounts(this.getNoCountsThreshold() == -1);
			// invalidate counts mode that may have been set by prior search
			this.setCountsOrNoCountsMode(true);
		}
		else {		
		    if (this.textSearch && this.textSearch.value != "" && this.textSearch.value != "*") {
			     this.addToFilters(FullSearch.TEXT_SEARCH, this.textSearch.value);
		    } else {
			this.removeFilter(FullSearch.TEXT_SEARCH);
		    }		
		}
		if (this.taxonomies[filterName] != null) {
			if (blnSelected) {
				var jsonXML = this.convertJSONtoXML(this.JSONdata);
				var tempC = emxUICore.selectSingleNode(jsonXML.documentElement,"/mxRoot//object/string[@id = 'type' and text() = '"+filterVal+"']");
				var tempCVal = null;
				if(tempC){
					var tmp = tempC.parentNode.parentNode.parentNode;
					if(tmp && emxUICore.selectSingleNode(tmp,"string[@id = 'type']")){
						tempCVal = emxUICore.getText(emxUICore.selectSingleNode(tmp,"string[@id = 'type']"));
					}			
				}
				this.setType(filterName, filterVal);
				
				this.removeFilter(filterName, filterVal);
				if(tempCVal){
					this.addToFilters(filterName, tempCVal);
				}
			} else {
				this.setType(filterName, filterVal);
				this.removeFilter(filterName);
				this.addToFilters(filterName, filterVal);
			}
			//test for txtType and add or replace value
		} else if (blnSelected) {
			if ((fieldSep != null || fIdx != null) && this.inputControlFilter[filterName] != null) {
					this.removeFilter(filterName, filterVal, operator);
					//removing the filter
					var filterIndexList = fIdx.split(",");
					if(fIdx != "" ){
					this.inputControlFilter[filterName][parseInt(filterIndexList[0])].remove(filterVal);
					if(this.inputControlFilter[filterName][parseInt(filterIndexList[0])].toString().length == 0){
						this.inputControlFilter[filterName].remove(this.inputControlFilter[filterName][parseInt(filterIndexList[0])]);
						if(this.inputControlFilter[filterName].length == 0){
							delete this.inputControlFilter[filterName];						
						}
					}
					}else{
						delete this.inputControlFilter[filterName];	
					}
					//removing the breadcrumb
					if(fIdx != null && fIdx != "" ){
						if(this.inputControlFilter[filterName]!= null){
						this.addToFilters(filterName, emxUICore.toJSONString(this.inputControlFilter), operator);
					}else{
							this.removeFilter(filterName);
						}
						
					}else{
						var tempRemBCArr = new Array();
						var divComplexControl = document.getElementById("complexcontrol_"+filterName);
						if (divComplexControl != null) {
							var objParentDiv = divComplexControl.parentNode;
							objParentDiv.removeChild(divComplexControl);
							objParentDiv.style.display = "none";
						}
						this.inputControlObject[filterName] = null;
					}
			} else {				
				if((filterName == "LATESTREVISION" || filterName == "LASTREVISION") &&
					(operator.toLowerCase() == "equals" ) && (filterVal.toLowerCase() == "true")){
						this.addToFilters(filterName, "false", operator);
					}else{
						this.removeFilter(filterName, filterVal, operator);
					}				
			}
		
		} else if (operator != "Between"){
			this.addToFilters(filterName, filterVal, operator);
			var filterValue = emxUICore.trimWhiteSpace(filterVal);
			if( filterValue == "" || filterValue == "*" )
				return;
		}
		this.currSaveName = null;
		if(url.indexOf("&ftsFilters=") > 0){
			var filtersToBeReplaced = url.substring(url.indexOf("&ftsFilters=")+1);
			filtersToBeReplaced = filtersToBeReplaced.substring(0,filtersToBeReplaced.indexOf("&"));
			url = url.replace(filtersToBeReplaced, "ftsFilters="+emxUICore.toJSONString(this.filters));
		}
		if (url.indexOf("formSearch=") > 0) {						
			url = url.replace(/formSearch=[^&]*/, "");
		}
		var parentFrame = FullSearch.results.contentWindow;
		if(parentFrame.editableTable){
			if(parentFrame.isFillPagesOn()){
		reloadSB1(parent.rng, '', 0, 'first');
			}
		}
		this.form.action = url;
		this.setFieldValues();
		if (this.getImmediateMode()) {
		this.formSearch();
		} else {
			this.loadNavData();
		}
	},
	removeFilter: function _removeFilter(filterName, filterVal, op){
		if (op == null || op == "") {
			op = "Equals";
		}
		if (filterVal != null) {
			var filterValArr = filterVal.split(emxUIConstants.STR_REFINEMENT_SEPARATOR);
			for (var i = 0; i < filterValArr.length; i++) {
				filterVal = filterValArr[i];
			if (this.filters[filterName] && this.filters[filterName].find(op + "|" + filterVal) != -1) {
				this.filters[filterName].remove(op + "|" + filterVal);
				if(this.filters[filterName].toString() == "") {
					delete this.filters[filterName];
				}
			}
		  }
		} else {
			delete this.filters[filterName];
		}
		if (emxUICore.toJSONString(this.filters).length > 2) {
			jQuery('[name=mx_reset]').attr("onclick","resetPage();");
		}
		this.toggleSearchButton();
		
	},
	addToFilters: function _addToFilters(filterName, filterVal, op,allowBlankFilters){
		if (op == null || op == "") {
			op = "Equals";
		}
		var filterValue = emxUICore.trimWhiteSpace(filterVal);
		if (filterValue == "*" || filterValue == "") {
			if(filterValue == "*" || !allowBlankFilters ||this.getQueryType().toLowerCase() == "indexed"){
				delete this.filters[filterName];
				return;
			}
		}
		if(filterName == "TYPE" && this.getQueryType().toLowerCase() != "indexed"){
			filterName = "TYPES";
		}
		this.filters[filterName] = new Array();
		filterVal = filterVal.replace(/%/g,"%25");
		filterVal = filterVal.replace(/E#Q#U#A#L/g,"=");
		if(filterName == "TYPE"){
			this.removeFilter("TYPES");
			var filterItem = strReplaceAll(filterVal, "," , emxUIConstants.STR_REFINEMENT_SEPARATOR);
			var items = filterItem.split(emxUIConstants.STR_REFINEMENT_SEPARATOR);
			for (var i = 0; i < items.length; i++) {
				var itemVal = items[i];
				itemVal = itemVal.replace(/,/g,"\\,");
				if (this.filters[filterName].find(op + "|" + itemVal) == -1) {
					this.filters[filterName].push(op + "|" + itemVal);
				}
			}
		} else if(filterName == this.TEXT_SEARCH){
				filterVal = strReplaceAll(filterVal, emxUIConstants.STR_REFINEMENT_SEPARATOR, " ");
				if (this.filters[filterName].find(op + "|" + filterVal) == -1) {
				this.filters[filterName].push(op + "|" + filterVal);
				}
				if (emxUICore.toJSONString(this.filters).length > 2) {
					jQuery('[name=mx_reset]').attr("onclick","resetPage();");
				}
				return true;
		} else {
			if(this.inputControlFilter[filterName] == null){
					if(isValidDate(filterVal)){
						if (this.filters[filterName].find(op + "|" + filterVal) == -1) {
							this.filters[filterName].push(op + "|" + filterVal);
						}
					}else{
						var filterValRefSep = filterVal.replace("|",emxUIConstants.STR_REFINEMENT_SEPARATOR);
						var items = filterValRefSep.split(emxUIConstants.STR_REFINEMENT_SEPARATOR);
		for (var i = 0; i < items.length; i++) {
							var itemVal = items[i];
							itemVal = itemVal.replace(/,/g,"\\,");
							if (this.filters[filterName].find(op + "|" + itemVal) == -1) {
								this.filters[filterName].push(op + "|" + itemVal);
							}
						}
					}
				}else{
					if (this.filters[filterName].find(op + "|" + filterVal) == -1) {
						this.filters[filterName].push(op + "|" + filterVal);
			}
		}
		}
		
		if (emxUICore.toJSONString(this.filters).length > 2) {
			jQuery('[name=mx_reset]').attr("onclick","resetPage();");
		}

		this.toggleSearchButton();		
	},
	validatePolicyAndState: function _validatePolicyAndState(filterName){
		var url = this.getURL(this.PROGRAM_VALIDATE_POLICY_STATE)+"&currField="+filterName;
		switch (filterName) {
			case "TYPE":
			case "TYPES":
				var respData = this.getServerData(url);
				this.addToFilters("POLICY", respData.POLICY.Actual);
				document.getElementById("POLICY").value = respData.POLICY.Display;
				this.addToFilters("CURRENT", respData.CURRENT.Actual);
				document.getElementById("CURRENT").value = respData.CURRENT.Display;
				break;
			case "POLICY":
				var respData = this.getServerData(url);
				this.addToFilters("CURRENT", respData.CURRENT.Actual);
				document.getElementById("CURRENT").value = respData.CURRENT.Display;
				break;
			case "CURRENT":
				var respData = this.getServerData(url);
				this.addToFilters("POLICY", respData.POLICY.Actual);
				document.getElementById("POLICY").value = respData.POLICY.Display;
				break;
			default:
		}
		return;
	},
	isValidTextSearchValue: function _isValidTextSearchValue(strFilterVal){
		if(strFilterVal != null && strFilterVal != ""){
			var lenSearchTerms = strFilterVal.split(emxUIConstants.STR_REFINEMENT_SEPARATOR).length;
			if(lenSearchTerms != null && lenSearchTerms <= emxUIConstants.NUM_ALLOW_SEARCHTERMS){
				var searchTerms = strFilterVal.split(emxUIConstants.STR_REFINEMENT_SEPARATOR);
				for(var i = 0; i < searchTerms.length; i++){
					var searchTerm = searchTerms[i];
					if(searchTerm != null && searchTerm.length > emxUIConstants.NUM_LENGTH_SEARCHTERMS){
						return false;
					}
				}
			}else{
				return false;
			}
		}else{
			return false;
		}
		return true;
	},
	appendToFilters: function _appendToFilters(filterName, filterVal, op){
		if (op == null || op == "") {
			op = "Equals";
		}
		if (filterVal == "*") {
			return;
		}		
		if(filterName == "TYPE" && this.getQueryType().toLowerCase() != "indexed"){
			filterName = "TYPES";
		}
		if (!this.filters[filterName]) {
			this.filters[filterName] = new Array();
		}
		if(filterName == "TYPE"){
			this.removeFilter("TYPES");
			var filterItem = strReplaceAll(filterVal, "," , emxUIConstants.STR_REFINEMENT_SEPARATOR);
			var items = filterItem.split(emxUIConstants.STR_REFINEMENT_SEPARATOR);
			for (var i = 0; i < items.length; i++) {
				var itemVal = items[i];
				itemVal = itemVal.replace(/,/g,"\\,");
				if (this.filters[filterName].find(op + "|" + itemVal) == -1) {
					this.filters[filterName].push(op + "|" + itemVal);
				}
			}
		} else if(filterName == this.TEXT_SEARCH){
			if (this.filters[filterName].find(op + "|" + filterVal) == -1) {
				this.filters[filterName].push(op + "|" + filterVal);
			}
		} else {
			filterVal = filterVal.replace(/%/g,"%25");
			if(this.inputControlFilter[filterName] == null){
				if(isValidDate(filterVal)){
					if (this.filters[filterName].find(op + "|" + filterVal) == -1) {
						this.filters[filterName].push(op + "|" + filterVal);
					}
				}else{
					var items = filterVal.split(emxUIConstants.STR_REFINEMENT_SEPARATOR);
		for (var i = 0; i < items.length; i++) {
						var itemVal = items[i];
						itemVal = itemVal.replace(/,/g,"\\,");
						if (this.filters[filterName].find(op + "|" + itemVal) == -1) {
							this.filters[filterName].push(op + "|" + itemVal);
						}
					}
				}
			}else{
				if (this.filters[filterName].find(op + "|" + filterVal) == -1) {
					this.filters[filterName].push(op + "|" + filterVal);
				}
			}
		}
		
		if (emxUICore.toJSONString(this.filters).length > 2) {
			jQuery('[name=mx_reset]').attr("onclick","resetPage();");
		}
		this.toggleSearchButton();
	},
	setFieldValues: function _setFieldValues(){
		//create formfield if it doesn't exist
		if (!this.form[this.FILTER_FIELDNAME] || !this.form[this.FILTER_FIELDNAME].nodeType) {
			var field = document.createElement("input");
			field.setAttribute("type", "hidden");
			field.setAttribute("name", this.FILTER_FIELDNAME);
			field.setAttribute("id", this.FILTER_FIELDNAME);
			this.form.appendChild(field);
		}
		//add the array.toJSONString() as the value
		this.form[this.FILTER_FIELDNAME].value = emxUICore.toJSONString(this.filters); //encodeURI(this.filters.toJSONString());
	},
	
	close: function _close(){
		var divValue = document.getElementById("formTypes");
		divValue.style.display = "none";
	},
	submitForm: function _submitForm(){
		if (this.results.contentWindow.editableTable && !this.saveSearchName) {
			/*Fix for immediateMode param*/
			var params = "";
			if(this.getCollection() != null){
				//params = "&COLLECTION="+this.getCollection();
				this.results.contentWindow.resetParameter(this.PARAM_COLLECTION, this.getCollection());
			}
			//Added the extra parameter ?true? for issue # IR-029099V6R2011 Start
			this.results.contentWindow.editableTable.loadTextSearchResults(emxUICore.toJSONString(this.filters),params, true, true);
			//Added the extra parameter ?true? for issue # IR-029099V6R2011 End
			this.splashFrame.style.display="none";
	        this.results.style.display="block";			
			this.loadNavigationContent();
		} else {			
			var urlToSubmit = null;
			if(this.form.action.indexOf("?")!=-1){
				urlToSubmit = this.form.action + "&" +this.getPageUrl();				
			}else{
				urlToSubmit = this.form.action + "?" + this.getPageUrl();
			}
			if(this.getCollection() != null){
				//params = "&COLLECTION="+this.getCollection();
				urlToSubmit = urlToSubmit + "&" +this.PARAM_COLLECTION + "="+encodeURIComponent(this.getCollection());	
			}
			this.submitLongURL(urlToSubmit, 'form');
			//emxUICore.submitLongURL(url,this.results.name);
			
			this.splashFrame.style.display="none";
			this.results.style.display="block";
			/*this.form.submit();
			setTimeout(function _delayed_submitForm() {
				FullSearch.submitForm();
			}, 500);*/
		}
	},
	expand: function _expand(objElm){
		if (objElm && objElm.src) {
			var source = (objElm.src.indexOf("Collapse") == -1) ? ["Expand", "Collapse"] : ["Collapse", "Expand"];
			objElm.src = objElm.src.replace(source[0], source[1]);
			if (source[1] == "Collapse") {
				this.TOGGLE_STATUS[objElm.id] = "true";
			
				for(i=0; i<objElm.parentNode.parentNode.childNodes.length; i++){
					if(objElm.parentNode.parentNode.childNodes[i].className == "hide")
						objElm.parentNode.parentNode.childNodes[i].className = "container";
				}
			} else {
				
				this.TOGGLE_STATUS[objElm.id] = "false";
				
				for(i=0; i<objElm.parentNode.parentNode.childNodes.length; i++){
					if(objElm.parentNode.parentNode.childNodes[i].className == "container")
						objElm.parentNode.parentNode.childNodes[i].className = "hide";
				}
			}
		}else if(objElm.id != null && objElm.id != ""){
			jQuery(objElm).closest('div.facet').toggleClass('expanded').toggleClass('collapsed');
		}else{
			if(jQuery(objElm).closest('div.facet-attr').attr('class') == "facet-attr expanded") {
				scrollPosition=jQuery(jQuery(objElm).closest('div.facet-attr')).find('ul').first().scrollTop();
			jQuery(objElm).closest('div.facet-attr').toggleClass('expanded').toggleClass('collapsed');
			} else {
				jQuery(objElm).closest('div.facet-attr').toggleClass('expanded').toggleClass('collapsed');
				jQuery(jQuery(objElm).closest('div.facet-attr')).find('ul').first().scrollTop(scrollPosition);
			}
		}
	},
	
	save: function _save(){
		if(FullSearch.validateBadChars()){
		if (this.currSaveName == null) {
			this.showSaveDialog();
								
		} else {
			this.saveAs(this.currSaveName);
			alert(emxUIConstants.STR_SEARCH_SAVED + " " + this.currSaveName);
		}
		} else{
			return;
		}
	},
	
	showSaveAsDialog: function _showSaveAsDialog(){
		if(FullSearch.validateBadChars()){
		showModalDialog("emxSearchSaveAsDialog.jsp?namePrefix=.emx", 400, 330, true);
		}else {
			return;
		}
		
	},
	
	showSaveDialog: function _showSaveDialog(){
		showModalDialog("emxSearchSaveDialog.jsp?namePrefix=.emx", 400, 330, true);
	},
	
	isUserRefined: function _isUserRefined(){
		var filterstring = emxUICore.toJSONString(this.filters);
		var userefined = false;
		if(filterstring != this.initialFilterJSONString) {
			userefined = true;
		}
		return userefined;
	},

	toggleSearchButton: function _toggleSearchButton(){
		if(!this.enableSearchButton){
			var srchButt = jQuery("[name=mx_btn-search]");
			var fullsearchinputObj = document.getElementById("txtTextSearch");	
			var srchButtDis = true;
			if (emxUICore.toJSONString(this.filters).length > 2){
				srchButtDis = false;
				var filterstring = emxUICore.toJSONString(this.filters);
				if(filterstring == this.initialFilterJSONString) {
					jQuery('[name=mx_reset]').attr("onclick","javascript:void(0);");
				}
			}else{
				jQuery('[name=mx_reset]').attr("onclick","javascript:void(0);");
			} 
			if(fullsearchinputObj && fullsearchinputObj.value != "" && srchButtDis){
				srchButtDis = false;
			}
			if(this.firstRequest && this.getURL().indexOf("enableSearchButton=false")!=-1){
				srchButt.attr("onclick","javascript:void(0);");
			}else{
				if(srchButtDis){
					srchButt.attr("onclick","javascript:void(0);");
				}
				else{
					srchButt.attr("onclick","FullSearch.formSearch();");
				}
			}
		}
   },

	makeXML: function _makeXML(){
		var state = {
			search: this.search,
			jspName: this.form.action,
			filters: this.filters,
			objParameter: this.objParameter,
			formFields: new Object()
		};
		with (this.form) {
			for (var i = 0; i < elements.length; i++) {
				var f = elements[i];
				if(f.name == "caseSensitiveSearch")
				{
					state.formFields[f.name] = f.checked;
				}else if (f.value) {
					state.formFields[f.name] = f.value;
				}
			}
		}
		
		var strEncState = emxUICore.toJSONString(state);
		var xmlDom = emxUICore.createXMLDOM();
		xmlDom.loadXML("<FullSearch/>");
		
		//root
		var root = xmlDom.documentElement;
		
		//command
		var command = xmlDom.createElement("stuff");
		root.appendChild(command);
		var tn = xmlDom.createTextNode(emxUICore.toJSONString(state));
		command.appendChild(tn);
		
		//build xml doc from formfields
		return xmlDom.xml;
	},
	
	loadXML: function _loadXML(strXml){
		var xmlDom = emxUICore.createXMLDOM();
		xmlDom.loadXML(strXml);
		var root = xmlDom.documentElement;
		var stuff = root.getElementsByTagName("stuff")[0];
		var strJsonVal = stuff.firstChild.xml;
		var state = eval('(' + strJsonVal + ')');
		
		this.setPageUrl(state.search.replace(/&amp;/g,"&"));
		var jspName = state.jspName.replace(/&amp;/g,"&");
		var urlToSubmit = null;
		if(jspName.indexOf("?")!=-1){
			urlToSubmit = jspName + "&" +this.getPageUrl();				
		}else{
			urlToSubmit = jspName + "?" + this.getPageUrl();
		}
		this.setContentUrl(urlToSubmit);
		
		this.search = state.search.replace(/&amp;/g,"&");
		this.filters = state.filters;
		this.objParameter = state.objParameter;
		for (name1 in state.formFields) {
		
			if(name1 == "caseSensitiveSearch")
			{
				this.form.elements[name1].checked = state.formFields[name1];
				this.setCaseSensitiveSearch(state.formFields[name1] + "");
			}else if (this.form.elements[name1]) {
				this.form.elements[name1].value = state.formFields[name1];
			}
		}
	},
	
	saveAs: function _saveAs(strName, mode){
		if (!mode) {
			mode = "save";
		}
		var strNameTrimmed = emxUICore.trimWhiteSpace(strName);
		var strEncName = strNameTrimmed;
		
		var qb = new Query("../common/emxSearchSaveProcessor.jsp");
		qb.append("saveType", mode);
		qb.append("namePrefix", ".emx");
		qb.append("saveName", encodeSaveSearchName(strNameTrimmed));
		
		var request = emxUICore.createHttpRequest();
		request.open("post", qb.toString(), false);
		request.send(this.makeXML());
		return request.responseText;
	},
	
	loadSavedSearch: function _loadSavedSearch(strName, strEncParams){
		var xml = decodeURIComponent(decodeURIComponent(strEncParams));
		this.saveSearchName=strName;
		this.loadXML(xml);
		for (attrFiltr in this.filters) {
			var value = this.filters[attrFiltr].toString();
		    if(value.contains("&amp;"))
		     {
		       value=strReplaceAll(value,"&amp;","&");
		       this.filters[attrFiltr][0]=value;
		     } 
			
			
		}
		if(this.filters[this.TEXT_SEARCH] != null){
			var value = this.filters[this.TEXT_SEARCH].toString();
			if (value.indexOf("|") > -1) {
				value = value.split("|")[1];
			}
			if(this.textSearch != null){
				this.textSearch.value = value.replace(/%25/g,"%");
				this.textSearch.textContent = this.textSearch.value;
				getTopWindow().jQuery('#GlobalNewTEXT').val(this.textSearch.value);
			}
        }
		/* commented while merging from HF40 to 2010
		this.reset.disabled = false;*/
		this.refresh();
	},
	
	validateSearchText: function _validateSearchText(searchTextObj, delimiter){
		if(this.getQueryType().toLowerCase() == "indexed" && this.showInitialResults == "false"){ 
			var minchars = searchTextObj.getAttribute("minReqChars");
			if(minchars != null && minchars != 'undefined') {
			var badStrs = "";
			var items;
			/*if(searchTextObj.value.indexOf(",") >= 0) {
				items = searchTextObj.value.split(",");
			} else if(searchTextObj.value.indexOf("\n") >= 0){
				items = searchTextObj.value.split("\n");
			} else {
				items[0] = searchTextObj.value;
			}*/
			items = searchTextObj.value.split(delimiter);
			for (var itr = 0; itr < items.length; itr++) {
					if(items[itr] && items[itr].length > 0 && !isValidSearchText(items[itr], minchars)){
					badStrs += items[itr] + "\n";
				}	
			}
			if(badStrs != "") {
				var stralert = emxUIConstants.STR_WILDCHARALERT;
				var strConfirm = emxUIConstants.STR_WILDCHARCONFIRM;
				//stralert = stralert.replace(/{WC}/, "*");
				stralert = stralert.replace(/{N}/, minchars);
				stralert = stralert.replace(/{ST}/, badStrs);
				strConfirm = strConfirm.replace(/{N}/, minchars);
				strConfirm = strConfirm.replace(/{ST}/, badStrs);
				if(this.allowSearchWithminReqCharsVoilation) {
					if(!confirm(strConfirm)){
						return false;
					}
				} else {
					alert(stralert);
					//return false;
				}
			}
		}
		}
		return true;
	},
	
	enableFormSearchButton: function _enableFormSearchButton(){
		var srchButt = jQuery("[name=mx_btn-search]");
		srchButt.attr("onclick","FullSearch.formSearch();");
	},
	disableFormSearchButton: function _disableFormSearchButton(){
		var srchButt = jQuery("[name=mx_btn-search]");
		srchButt.attr("onclick","javascript:void(0);");
	},
	formSearch: function _formSearch(){
		turnOnProgress();
		this.disableFormSearchButton();
		setTimeout(function _formSearchTimeOut_2() {
			FullSearch.formSearchTimeOut();
		}, 10);
		jQuery('[name=mx_reset]').attr("onclick","resetPage();");

		//turnOffProgress();
	},
	
    rerunsearch: function _rerunsearch(value1, searchPageURL){
    	this.searchCriteriaChanged = true;
		value1 = decodeURIComponent(value1);
		this.removeFilter("NAME");
		this.removeFilter("txtTextSearch");
		var queryType = FullSearch.getQueryType();
		if(queryType !== "Indexed"){
		this.addToFilters("NAME",value1,"Equals",true);
		this.objParameter['default'] = "NAME="+value1;
		}
		this.addToFilters("txtTextSearch",value1,"Equals",true);
		
		this.objParameter['txtTextSearch'] = value1;
		this.textSearch.innerHTML=value1;
		this.textSearch.value=value1;
		this.setPageUrl(searchPageURL);
		this.formSearch();
	},

	formSearchTimeOut: function _formSearchTimeOut(tagsJSON){
		//turnOnProgress();
		var fldObj_name = document.forms[0].elements["NAME"]?document.forms[0].elements["NAME"]:document.forms[0].elements["Name"];
		if(fldObj_name)
			{
				if(fldObj_name.value)
					{
					var badChar = checkFieldForChars(fldObj_name, emxUIConstants.STR_BADCHAR, true);
					if(badChar.length > 0)
						{	
							alert(emxUIConstants.BAD_CHAR + badChar);
							//this.disableFormSearchButton();
							turnOffProgress();
							return;
						}
					}
			}
		
		if(!validateFullTextSearchString()) {
			turnOffProgress();
			return;
		}
		
		
		if(this.getTagsMode()=="true" && typeof tagsJSON!="undefined" ){
			this.tagsJSON = tagsJSON;
			this.filters = emxUICore.parseJSON(FullSearch.initialFilterJSONString);			
			for(key in tagsJSON.allfilters){			
				var tagType = tagsJSON.allfilters[key];
				for(var tagCount=0;tagCount<tagType.length;tagCount++){
					if(tagType[tagCount].field.length == 1 && tagType[tagCount].field[0] == TAG_TYPE_EXPLICIT ){
						this.addToFilters(tagType[tagCount].object,"TagsAttr_Explicit____"+key);//+"|~|"+"string"
					continue;
				}
					if(tagType[tagCount].field.length == 1 && tagType[tagCount].field[0] == TAG_TYPE_IMPLICIT){
						this.addToFilters(tagType[tagCount].object,"TagsAttr_Implicit____"+tagType[tagCount].type+"____"+key);
				}else{
						for(var j=0;j<tagType[tagCount].field.length;j++) {
							var vall = "TagsAttr_Implicit____"+tagType[tagCount].type+"____"+key;
							this.addToFilters(tagType[tagCount].object, vall);
						}
					}
				}
			}
		}
		
		
		//this.clearCache();
		this.setFirstPage(1);	
		if (this.isFormBasedMode()) {
		this.inputControlFilter = new Object();
		}
		var qb = new Query(this.getContentUrl());
		qb.replace(this.PARAM_SEARCH_TIME_STAMP, this.searchtimeStamp, true);
		if (this.queryLimit && isValidQueryLimit(this.queryLimit)) {
			qb.set(this.QUERY_LIMIT, this.queryLimit.value);
		}else{
			var showAlert = false;
			if(typeof this.getQueryType() == "undefined"){
				if(emxUIConstants.STR_QUERY_TYPE.toLowerCase() != "indexed"){
					showAlert = true;
				}
			}else if(this.getQueryType().toLowerCase() != "indexed"){
				showAlert = true;
			}
			if(showAlert){
				alert(emxUIConstants.STR_MAX_QUERY_ALERT);
				this.enableFormSearchButton();
				turnOffProgress();
				return;		
			}
		}
		/*this.removeFilter(FullSearch.TEXT_SEARCH);*/
		if (this.textSearch && this.textSearch.value != "" && this.textSearch.value != "*") {
			var retValue = this.addToFilters(FullSearch.TEXT_SEARCH, this.textSearch.value);
			if(retValue == false){
				turnOffProgress();
				return;
			}
		}else{
			this.removeFilter(FullSearch.TEXT_SEARCH);
		}
		if (this.isFormBasedMode()) {
			qb.set("formSearch", true);
			qb.set("fromFormSearch", true);			
			qb.remove("filters");
			qb.remove("ftsFilters");
			this.formHiddenFilters.value = emxUICore.toJSONString(this.filters);
		} else {
			//qb.set("filters", emxUICore.toJSONString(this.filters));
			qb.remove("ftsFilters");
			qb.remove("filters");
			this.formHiddenFilters.value = emxUICore.toJSONString(this.filters);
		}
		
		qb.set(this.PARAM_CASE_SENSITIVE, this.getCaseSensitiveSearch());
		if(qb.getValue("fromCtxSearch") == null){
			qb.set("fromCtxSearch", "true");
		}
		// this loads the results frame
		var url = qb.toString();
		if (this.results.contentWindow.editableTable && 
				this.results.contentWindow.editableTable.divListBody != null &&
				this.results.contentWindow.editableTable.divListBody.tblListBody != null) {
			
			this.Suggestions.style.display = "none";
			this.body.style.display = "block";
			
			if(this.getQueryType().toLowerCase() != "indexed") {
				this.results.contentWindow.resetParameter("queryLimit", this.queryLimit.value);
			}
			this.results.contentWindow.resetParameter(this.PARAM_CASE_SENSITIVE, this.getCaseSensitiveSearch());
			var encodedFilters = encodeURIComponent(emxUICore.toJSONString(this.filters));
			this.results.contentWindow.editableTable.loadTextSearchResults(encodedFilters, null, true);
			
			this.loadNavigationContent();
		} else {
			
		
			if(this.getCollection() != null){
				//params = "&COLLECTION="+this.getCollection();
				url = url + "&" +this.PARAM_COLLECTION + "="+this.getCollection();	
			}
			if(this.pageSize){
				url += "&paginationRange="+ this.pageSize ;
			}
			if(this.getTagsMode() != null){			
				url = url + "&TagsView="+this.getTagsMode();	
			}		
			if(FullSearch.results.contentWindow){
				if(typeof FullSearch.results.contentWindow.getRequestSetting=="function"){
					if("true"==FullSearch.results.contentWindow.getRequestSetting("thumbNailView")){
						url = url + "&displayView=thumbnail,details";
					}
					if("false"==FullSearch.results.contentWindow.getRequestSetting("thumbNailView")){
						url = url + "&displayView=details,thumbnail";
					}
				}
			}
			
			this.submitLongURL(url, 'formHidden');
			//emxUICore.submitLongURL(url,this.results.name);
		}
		this.Suggestions.style.display = "none";
		this.splashFrame.style.display="none";
        this.results.style.display="block";
		//turnOffProgress();
	},
	submitLongURL: function _submitLongURL(strURL, formname){
		var formtoSubmit = this.formHidden;
		if(formname == 'form') {
			formtoSubmit = this.form;
		}
		if(formname == 'reset') {
			formtoSubmit = this.formReset;
		}
		if(formname == 'splash') {
			formtoSubmit = this.formSplash;
		}
		//if(isIE && strURL.length > 2048){
			var qb = new Query(strURL);
			var items = qb.getAll();
			if(this.getQueryType().toLowerCase() == "indexed" && emxUIConstants.STR_SHOW_PAGINATION == true)			{				
				items["autoFilter"] = "false";
			}
			//clear old form elements
			for(var name in items)
			{
				if(typeof items[name] != "string"){
					continue;
				}
				for(var id=0; id < formtoSubmit.elements.length; id++)
				{
					if((name == formtoSubmit.elements[id].name)  && (formtoSubmit.elements[id].parentNode == formtoSubmit)){
				  		formtoSubmit.removeChild(formtoSubmit.elements[id]);
				  		id--;
					}
				}
			}
			for(var name in items)
			{
				if(name === "persist" || typeof items[name] != "string"){
					continue;
				}
				var input   = document.createElement('input');
				input.type  = "hidden";
				input.name  = name;
				input.value = items[name];
				formtoSubmit.appendChild(input);
			}
			
			formtoSubmit.appendChild(jQuery('<input type="hidden" name="isFullSearch" value="true"/>').get(0));			
			formtoSubmit.action = qb.getBaseUrl();
			formtoSubmit.submit();				
		/*}else{
			formtoSubmit.action = strURL;
			formtoSubmit.submit();
		}*/
	},
	refreshNextField: function _refreshNextField(objThis,attrObj, attrDispObj, currIndex,lastIndex,fName,fieldSep){
		var objEvent = emxUICore.getEvent();
		var reqDiv = document.getElementById("complex_"+fName);
		var options = objThis.options;
		var selectedValue = "";
		var selectedDispValue = "";
		var childCount = new Object;
		var selectCount = new Object;
		for(var i=0; i < parseInt(currIndex); i++){
			var selectobjs = document.getElementById(fName+"_"+i);
			childCount[i] = 0;
			selectCount[i] = 0;
			for(var l=0; l < selectobjs.options.length; l++){
				var option = selectobjs.options[l];				
				if(option.selected){
					var hasChild = option.getAttribute("hasChild");
					if(hasChild != null && hasChild == "true"){
						childCount[i]++;
					}
					selectCount[i]++;
					if(selectedDispValue == ""){
						selectedDispValue = option.text;
					}else{
						selectedDispValue += fieldSep + option.text;
					}
					if(i == currIndex-1){
					    selectedValue = option.value;
					}
				}else{
					option.removeAttribute("hasChild");
				}
			}			
		}
		var objCurrSelect = document.getElementById(fName+"_"+(parseInt(currIndex)-1));
		if (childCount[(parseInt(currIndex)-1)] > 0) {
			for(var l=0; l<objCurrSelect.options.length; l++) {
				if(objCurrSelect.options[l].selected){
					var hasChild = objCurrSelect.options[l].getAttribute("hasChild");
					if(hasChild != "true"){
						objCurrSelect.options[l].selected = false;
					}
				}
			}
			return;
		}
		if (selectCount[(parseInt(currIndex)-1)] <= 0) {
			return;
		}

		for(var j=parseInt(currIndex); j< parseInt(lastIndex); j++){
			var objDomEle = document.getElementById(fName+"_"+j);
			if (objDomEle != null) {
				var spanElem = objDomEle.parentNode;
				spanElem.removeChild(objDomEle);
				if(spanElem.parentNode != null){
					spanElem.parentNode.removeChild(spanElem);
			}
		}
		}
		jQuery(reqDiv).css("width", "");
		var actDivWidth = jQuery(reqDiv).width();
		var isNextFieldBlank = true;
		
		var objSpan = document.createElement("span");
		objSpan.setAttribute("class","input list");
		var objSelect = document.createElement("SELECT");
		objSelect.setAttribute("multiple","yes");
		objSelect.setAttribute("id",fName+"_"+currIndex);
		objSelect.setAttribute("name",fName+"_"+currIndex);
		objSelect.setAttribute("level",currIndex);
		var tmpCurrAttrVal = attrObj.replace(/\'/g,"\\\'");
		attrDispObj = attrDispObj.replace(/\'/g,"\\\'");
		objSelect.setAttribute("onchange","FullSearch.refreshNextField(this,'"+tmpCurrAttrVal+"','"+attrDispObj+"','"+(parseInt(currIndex)+1)+"','"+lastIndex+"','"+fName+"','"+fieldSep+"')");
		var attrValues = attrObj.split("|");
		var attrDispValues = attrDispObj.split("|");
		var attrSize = 10;
		objSelect.setAttribute("size",attrSize);
		var checkDuplicate = new Object();
		for(var k=0; k< attrValues.length; k++){
			if(attrValues[k].indexOf(selectedValue + fieldSep) > -1 
					&& attrValues[k].indexOf(fieldSep + selectedValue + fieldSep) == -1){
				if (attrValues[k] == selectedValue) {
					continue;
				}
				isNextFieldBlank = false;
				var textVal = attrValues[k].replace(selectedValue + fieldSep,"");
				var textDispVal = attrDispValues[k].replace(selectedDispValue + fieldSep,"");
				if(textVal.indexOf(fieldSep) > -1){
					textVal = textVal.substring(0,textVal.indexOf(fieldSep));
					textDispVal = textDispVal.substring(0,textDispVal.indexOf(fieldSep));
				}
				if(checkDuplicate[textVal] == null){
					checkDuplicate[textVal] = new Object();
					checkDuplicate[textVal] = textVal;
					var key = textDispVal;
					var value = selectedValue + fieldSep + textVal;
					objSelect.options[objSelect.options.length] =  new Option(key,value);
				}
			}
		}
		if (!isNextFieldBlank) {
			var strHTML = "";
			objSpan.appendChild(objSelect);
			document.getElementById("complex-controls-td").appendChild(objSpan);
			var spanWidth = jQuery(objSpan).width();
			actDivWidth = actDivWidth + spanWidth;
			for(var l=0; l<objCurrSelect.options.length; l++) {
				if(objCurrSelect.options[l].selected){
					objCurrSelect.options[l].setAttribute("hasChild","true");
				}
			}
		}
		adjustComplexControlDiv(reqDiv,actDivWidth);
		
	},
	refineListBox: function _refineListBox(objThis,attrObj,level,fName,fieldSep){
		ElapsedTimer.reset("refineListBox");

		// ignore e.g. cursor movement events
		if (objThis.prevVal == objThis.value) {
			return;
		}

		objThis.prevVal = objThis.value;
		
		if (FullSearch.refineListBoxTimeout) {
			clearTimeout(this.refineListBoxTimeout);
		}
		
		var selectListId = objThis.getAttribute("id").replace("input", "select");
		var fieldName = objThis.getAttribute("id").replace("input_", "");
		var objSelect = document.getElementById(selectListId);
		
		// for long lists, try to collapse keystrokes by using a longish timeout
		// for short lists, instant response
		if (objSelect.options != null && objSelect.options.length > 500) {
			var tv = 500;
			setTimeout(function _rlb_Busy() {
//				var div = document.getElementById("control-outer");
//				div.style.cursor="wait";
				objThis.style.background = "#dddddd";
				FullSearch.busy("Filtering");
			}, tv-100);
		} else {
			var tv = 0;
		}
		
		FullSearch.refineListBoxTimeout = setTimeout(function _rlb_Timeout() {
			FullSearch.refineListBoxTimeoutCB(objThis, attrObj, level, fName, fieldSep);
//			var div = document.getElementById("control-outer");
//			div.style.cursor="default";
//			objThis.style.background = "white";
		}, tv);
	},
	sortOptions: function _sortOptions(arrOpts, matchStr){
		if(isIE){
			var exactMatchArr = [];
			var matchAtStartArr = [];
			var matchAnywhereArr = [];
			var nomatchArr = [];
			//sort options alphabetically first			
			arrOpts.sort(function _compareOptions(a, b){
				var nameA = a.text.toLowerCase();
				var nameB = b.text.toLowerCase();
				if (nameA < nameB) {
					return -1;
				} else{
			    	return 1;
			    }
			});
			if(matchStr != ""){				
				//reorder based on match string
				for(var i=0; i< arrOpts.length; i++) {
					var nameA = arrOpts[i].text.toLowerCase();
					if (nameA == matchStr) {
						exactMatchArr.push(arrOpts[i]);
					} else if (nameA.indexOf(matchStr) == 0) {
						matchAtStartArr.push(arrOpts[i]);
					} else if (nameA.indexOf(matchStr) > 0) {
						matchAnywhereArr.push(arrOpts[i]);						
					} else {
						nomatchArr.push(arrOpts[i]);
				    }
				}
				arrOpts = exactMatchArr.concat(matchAtStartArr).concat(matchAnywhereArr).concat(nomatchArr);
			}
		}else{
			arrOpts.sort(function _compareOptions(a, b){
				var nameA = a.text.toLowerCase();
				var nameB = b.text.toLowerCase();
				if (matchStr == "") {
					if (nameA < nameB) {
						return -1;
					} else {
						return 1;
					}
				}
				// Prioritize:
				// 1. exact match
				// 2. match at the beginning
				// 3. match anywhere else
				// 4. lexicographic
				if (nameA == matchStr) {
					return -1;
				} else if (nameB == matchStr) {
					return 1;
				} else if (nameA.indexOf(matchStr) == 0) {
					return -1;
				} else if (nameB.indexOf(matchStr) == 0) {
					return 1;
				} else if (nameA.indexOf(matchStr) > 0) {
					return -1;
				} else if (nameB.indexOf(matchStr) > 0) {
					return 1;
				} else if (nameA < nameB) {
					return -1;
				} else {
					return 1;
			    }
				});
		}
		return arrOpts;
	},
	refineListBoxTimeoutCB: function _refineListBoxTimeoutCB(objThis,attrObj,level,fName,fieldSep){
		ElapsedTimer.enter();
		FullSearch.refineListBoxTimeout = null;
		var matchStr = objThis.value.toLowerCase();

		if (fieldSep != null) {
			for(var j=0; j< level; j++){
				if(document.getElementById(fName+"_"+j)!= null){
					if (j > 0) {
						document.getElementById(fName+"_"+j).parentNode.removeChild(document.getElementById(fName+"_"+j));
					} else {
						document.getElementById(fName+"_"+j).innerHTML = "";
					}
				}
			}
			currSelect = document.getElementById(fName+"_"+0);
			var checkDuplicate = new Object();
	
			var attrValues = attrObj.split("|");
			var flag = false;
			for(var j = 0; j < attrValues.length; j++){
				var val = attrValues[j];
				var ciMaybeVal = val.toLowerCase();
				if (ciMaybeVal.indexOf(matchStr) >= 0) {
					if (checkDuplicate[val] == null) {
						checkDuplicate[val] = val;
						currSelect.options[currSelect.options.length] = new Option(val, val);
					}
				}
			}
			objThis.style.background = (currSelect.options.length>0 || matchStr == "") ? "white" : "pink";

		} else {
			var selectListId = objThis.getAttribute("id").replace("input","select");
			var fieldName = objThis.getAttribute("id").replace("input_","");
			var objSelect = document.getElementById(selectListId);
			var arrOpts = [];
			for(var i=0; i< objSelect.options.length; i++) {
				var opt = objSelect.options[i];
				arrOpts.push( {
					value: opt.value,
					text: opt.text,
					selected: opt.selected
				} );
				}
			ElapsedTimer.timeCheck("Before sorting " + arrOpts.length + " options"	);

			arrOpts = this.sortOptions(arrOpts, matchStr);		
			ElapsedTimer.timeCheck("after sort");
			var bMatched = false;
				
				var innhtml = "";
				for(var i =0; i < arrOpts.length; i++){
					var seltex = (arrOpts[i].selected?'selected ':'');
					var text = arrOpts[i].text.toLowerCase();
					var styletex = ' style=\"font-weight: normal;\"';
					if (matchStr != "" && text.indexOf(matchStr) >= 0) {
						bMatched=true;
						styletex = ' style=\"font-weight: bold;background: #e0ffe0\"';
					}
					innhtml += '<option ' + seltex +'value=\"' + arrOpts[i].value + '\"' + styletex + '>' + arrOpts[i].text + '</option>';
				}
				objSelect.innerHTML = innhtml;
			ElapsedTimer.timeCheck("after rebuilding options list");
			objThis.style.background = (bMatched || matchStr == "") ? "white" : "pink";
			var div = document.getElementById("control-outer");
		}
		this.notBusy();
		ElapsedTimer.exit();
	},
	applyToBreadcrumbs: function _applyToBreadcrumbs(fName,dataType,fieldSep,levels,displayValue){		
		var inputBreadCrumbs = new Object();
		var levels = parseInt(levels);
		inputBreadCrumbs["complex-control"] = new Object;
		inputBreadCrumbs["complex-control"]["breadcrumbs"] = new Object;
		inputBreadCrumbs["complex-control"]["breadcrumbs"][fName] = new Object;
		var currLevel = 0;
		var strDispString = "";
		for(var i=0; i < levels; i++){
			var selectobjs = document.getElementById(fName+"_"+i);
			if (selectobjs == null) {
				continue;
			}else{
				for(var k=0; k < selectobjs.options.length; k++){
					if (selectobjs.options[k].selected == true) {
						strDispString += selectobjs.options[k].text + fieldSep;
					}
				}
			}
			currLevel++;
		}
		strDispString = strDispString.substring(0, strDispString.lastIndexOf(fieldSep));
		var lastSelectobj = document.getElementById(fName+"_"+(currLevel-1));
		if (this.inputControlObject[fName] == null) {
			this.inputControlObject[fName] = new Array();
			this.inputControlObject[fName]["displayValue"] = displayValue;
			this.inputControlObject[fName]["value"] = fName;
			this.inputControlObject[fName]["fieldSeparator"] = fieldSep;
		}		
		if (this.inputControlFilter[fName] == null) {
			this.inputControlFilter[fName] = new Array();
		}
		var tempFilter = new Array();
		for(var k=0; k < lastSelectobj.options.length; k++){
			if (lastSelectobj.options[k].selected == true) {
				var strQueryString = lastSelectobj.options[k].value;
				var node = new Object();
				node["displayValue"] = strDispString;
				node["value"] = strQueryString;
				node["operator"] = "Equals";
				node["index"] = this.inputControlFilter[fName].length+","+k;
				//node["level"] = (i+1);
				var isDuplicate = false;
				for(var l=0; l<this.inputControlObject[fName].length; l++) {
					if (this.inputControlObject[fName][l].value == node.value) {
						isDuplicate = true;
						break;
					}
				}
				if (!isDuplicate) {
					this.inputControlObject[fName].push(node);
					tempFilter.push(strQueryString);
				}				
			}
		}
		this.inputControlFilter[fName].push(tempFilter);
		inputBreadCrumbs["complex-control"]["breadcrumbs"] = this.inputControlObject;
		if (this.isFormBasedMode()) {
			var disValue = "";
			for(var j=0; j<this.inputControlObject[fName].length; j++) {
				if (disValue == "") {
					disValue = node.displayValue;
				} else {
					disValue += emxUIConstants.STR_REFINEMENT_SEPARATOR + node.displayValue;
				}
			}		
			document.getElementById(fName).value = disValue;
		} else {
			var complexBreadcrumbXML = this.convertJSONtoXML(inputBreadCrumbs);
			var divComplexControl = document.getElementById("complex-control");
			divComplexControl.innerHTML = this.transformToText(complexBreadcrumbXML, this.LEFT_NAV_XSL);
			if (this.inputControlObject[fName] != null && this.inputControlObject[fName].length > 0) {
				divComplexControl.style.display = "block";
			}
			this.nav.style.top = this.header.offsetHeight + this.options.offsetHeight + 3 +"px";
		}
	},
	enableToDateField : function _enableToDateField(objThis,fName){
		var selectedValue = "";
		for(var i=0; i<objThis.options.length; i++) {
			if (objThis.options[i].selected) {
				selectedValue = objThis.options[i].value;
			}
		}
		var objToCal = document.getElementById(fName+"_tovalue_cal");
		var objToCalImg = document.getElementById(fName+"_tovalue_cal_img");
		var objToInput = document.getElementById(fName+"_tovalue");
		var objToNum = document.getElementById("text_to_"+fName);
		if (selectedValue.toLowerCase() == "between") {
			if (objToCal && objToInput) {
				objToCal.setAttribute("href","javascript:showCalendar('full_search','"+fName+"_tovalue','"+objToInput.value+"')");
				objToCalImg.setAttribute("src","images/iconSmallCalendar.gif");
			}else if(objToNum){
				objToNum.disabled = false;
			}
		}else{
			if (objToCal && objToInput) {
				objToCal.setAttribute("href","javascript:;");
				objToCalImg.setAttribute("src","images/iconSmallCalendarDisabled.gif");
				//Hack to show the empty textbox. First enable the textbox, reset and disable again.
				objToInput.disabled = false;
				objToInput.value = "";
				objToInput.disabled = true;
			}else if(objToNum){
				objToNum.disabled = true;
			}
		}
	},
	
	reloadPage : function _reloadPage(action, pagenum){
	},
	
	evaluateFirstPage : function _evaluateFirstPage(currentPage, action){
			var numpagesshown = 10;
			var displayedStartPagenum = this.getFirstPage();		
			displayedStartPagenum = displayedStartPagenum * 1;
			currentPage = currentPage *1;
	
			if(action == 'Next'){
				if(currentPage % numpagesshown == 1) {
					var nextPagetToShow = (numpagesshown / 2)+1;					
					displayedStartPagenum += nextPagetToShow;
				}					
				if((currentPage-displayedStartPagenum)>=10){					
					displayedStartPagenum =currentPage-4;					
				}
			}else if(action == 'NextGroup'){
				displayedStartPagenum += numpagesshown;
			} else if(action == 'Prev') {
					if(currentPage == 999) {
						displayedStartPagenum = 990;
					} else if(currentPage % numpagesshown <= currentPage) {					
						var prePageToShow = (numpagesshown / 2)+1;	
						displayedStartPagenum -= prePageToShow;
					}
					if((currentPage-displayedStartPagenum)>=10){
						displayedStartPagenum =currentPage-4;
					}
			} else if(action == 'PrevGroup') {
					displayedStartPagenum -= numpagesshown;
			}
			
			if(displayedStartPagenum<1){
				displayedStartPagenum=1;
		}	
		this.setFirstPage(displayedStartPagenum);			
	},
	
	doPagination : function _doPagination(totalCnt, currentPage, action, objCount, cselobj, paginationRange){
		var output = '';
		var windowshade = false;
		var frame = emxUICore.findFrame(window.parent,"windowShadeFrame");
		/* following code is to get the window shade reference in case of saved searches */
		windowshade = frame ? true :(window.frameElement ?(window.frameElement.name =="windowShadeFrame" ? true :false):false);
		
        if(this.getQueryType().toLowerCase() != "indexed"){
			output += emxUIConstants.STR_RESULTOBJECTS + ": " + objCount + cselobj;
        } else if(emxUIConstants.STR_SHOW_PAGINATION == false) {
	        if(objCount<totalCnt){
	            output += emxUIConstants.STR_RESULTOBJECTS + ": " + objCount + " " + emxUIConstants.STR_OF + " " + totalCnt + cselobj;
	        }
	        else{
	            output += emxUIConstants.STR_RESULTOBJECTS + ": " + objCount + cselobj;
	        }
        } else {
	
			if(totalCnt <= 0){
				if(windowshade){
				output += '<a class = "btn close" onclick="getTopWindow().closeWindowShadeDialog()" href="#"></a>';
				}				
				return output;
//				output += '<table class=\'results-bar\' cellpadding=\'0\' cellspacing=\'0\' border=\'0\' width=\'100%\' class=\'resultsPaginationTable\'>';
//				output += '<tr><td class=\'resultsText\'><img src=\'../common/images/iconStatusMulti.gif\'  class=\'resultsNotFoundIcon\' width=\'16\' height=\'16\' alt=\'\' border=\'0\'>'+emxUIConstants.STR_JS_NoResults +'</td>';
//				output +=  '<td class=\'resultsPaginationText\'></td></tr></table>';
			}
			if(currentPage == '' || currentPage == null || currentPage == 'null' || currentPage == 'undefined') {
				currentPage = 1;
			}

			paginationRange = paginationRange * 1;
			var strUrl = '<a href=\"javascript:reloadSB(' + paginationRange + ',';
			var numpagesshown = 10;
			var displayedStartPagenum = this.getFirstPage();		
			displayedStartPagenum = displayedStartPagenum * 1;
			currentPage = currentPage *1;
	
			var totalPages = Math.floor(totalCnt / paginationRange);
			var rem = totalCnt % paginationRange;
			if(rem > 0) {
				totalPages++;
		        }
		
			var disprev = false;
			var disnext = false;
			var disprevgroup = false;
			var disnextgroup = false;
			
			if(currentPage == 1)
			{
				disprev = true;
				disprevgroup = true;
		        }
			
			if(currentPage == totalPages)
			{
				disnext = true;
				disnextgroup = true;
			}

			if(displayedStartPagenum == 1)
			{
				disprevgroup = true;
			}

			if((totalPages - displayedStartPagenum) < numpagesshown)
			{
				disnextgroup = true;
			}
					
			var strresultsPageCurrent = '<li class=\'current-page\'>';		
				
			output += "<table class='results-bar'>";
			output += "<tr>";
			output += "<td class='result-count'>";
				var strtobjnum = ((currentPage - 1) * paginationRange) + 1;
				var endobjnum;
				if(currentPage == totalPages) {
					if(rem == 0) {
						endobjnum = strtobjnum + paginationRange - 1;				
					} else {
						endobjnum = strtobjnum + rem - 1;
					}
				} else {
					endobjnum = strtobjnum + paginationRange - 1;
				}
			output += strtobjnum + ' - ' + endobjnum + ' ';
			output += emxUIConstants.STR_OF + ' ';
				output += totalCnt + ' ';
				output += emxUIConstants.STR_RESULTS;
			output += "</td>";			
			output += "<td>";
			output += "<table>";
			output += "<tr>";
			output += "<td>"+emxUIConstants.STR_PAGESIZE+"</td>";
			output += "<td><input size=\'4\' type=\'textbox\' id=\'numobjsperpage\' name=\'numobjsperpage\' value=\'";
			output += paginationRange;
			output += "'/></td>";
			output += "<td><a href='javascript:changePaginationRange()'><img border='0' src='../common/images/utilResultsListNext.gif' alt='Apply'/></a></td>";
			output += "<td>("+emxUIConstants.STR_JS_MaxValue + " ";
			output += emxUIConstants.STR_MAX_QUERY_LIMIT + ")</td>";			
			output += "</tr></table>";
			output += '<td class=\"pagination-control\">';
				output += '<ul>';
	
				var prevpage = currentPage - 1;
				var nextpage = currentPage + 1;			

			if(currentPage < 1000) {
				if(disprevgroup) {
					output += "<li><a class='btn first-result disabled'></a></li>";
				} else {
					output += "<li>" + strUrl + '\'PrevGroup\', ';
					var prevpagegrnum = displayedStartPagenum - 1;
					output += prevpagegrnum;
					output += ')\" class="btn first-result"></a></li>';
				}
			}

			if(disprev) {
					output += "<li><a class='btn previous-result disabled'></a></li>";
				} else {
					output += "<li>" + strUrl + '\'Prev\', ';
					output += prevpage;
					output += ')\" class="btn previous-result"></a></li>';
				}
				
				if(currentPage >= 1000) {
				output += "<li>";
					output += currentPage; 
					output += '</li>';
				} else {
				var endpgnum = displayedStartPagenum + numpagesshown - 1;
					if(endpgnum > totalPages) {
						endpgnum = totalPages;
					}
					
					for(var temp = displayedStartPagenum; temp <= endpgnum; temp++){
						if(temp == currentPage) {
							output += strresultsPageCurrent;
							output += currentPage; 
							output += '</li>';
						} else {
							output += "<li>" + strUrl + '\'\', ';
							output += temp; 
							output += ')\">' + temp + '</a></li>';
						}
					}
				}
				

			if(disnext)
			{
					output += "<li><a class='btn next-result disabled'></a></li>";
				} else {
					output += '<li>' + strUrl + '\'Next\', ';
					output += nextpage; 
					output += ')\" class="btn next-result"></a></li>';
				}
				
			if(currentPage < 1000) {
				if(disnextgroup) {
					output += '<li><a class="btn last-result disabled"></a></li>';
				} else {
					output += '<li>' + strUrl + '\'NextGroup\', ';
					var nextpagegrnum = displayedStartPagenum + numpagesshown;;
					output += nextpagegrnum;
					output += ')\" class="btn last-result"></a></li>';
				}
			}
					output += '</ul></td>';
					output += '</tr></table>';
				//this.setFirstPage(displayedStartPagenum);
		}
        if(windowshade){
        output += '<a class = "btn close" onclick="getTopWindow().closeWindowShadeDialog()" href="#"></a>';
        }
		return output;
	},
	
	/* Added for Autonomy Search fill page feature */
	doNewPagination : function _doNewPagination(totalCnt, currentPage, action, objCount, cselobj, paginationRange, nextFTSIndex, prevFTSIndex, curFTSIndex, curPageCtr){
		var output = '';
		var urlparams = this.contentUrl;
		var windowshade = false;
		
		if(urlparams && urlparams.indexOf("targetLocation=windowshade")>-1 ){
			windowshade = true;
		}
				
		if(this.getQueryType().toLowerCase() != "indexed"){
			output += emxUIConstants.STR_RESULTOBJECTS + ": " + objCount + cselobj;
		} else if(emxUIConstants.STR_SHOW_PAGINATION == false) {
			if(objCount<totalCnt){
				output += emxUIConstants.STR_RESULTOBJECTS + ": " + objCount + " " + emxUIConstants.STR_OF + " " + totalCnt + cselobj;
			}
			else{
				output += emxUIConstants.STR_RESULTOBJECTS + ": " + objCount + cselobj;
			}
		} else {

			if(totalCnt <= 0){
				if(windowshade){
				output += '<a class = "btn close" onclick="getTopWindow().closeWindowShadeDialog()" href="#"></a>';
				}	
				return output;
				//output += '<table class=\'results-bar\' cellpadding=\'0\' cellspacing=\'0\' border=\'0\' width=\'100%\' class=\'resultsPaginationTable\'>';
				//output += '<tr><td class=\'resultsText\'><img src=\'ematrix/common/images/iconStatusMulti.gif\'  class=\'resultsNotFoundIcon\' width=\'16\' height=\'16\' alt=\'\' border=\'0\'>No results found.</td>';
				//output +=  '<td class=\'resultsPaginationText\'></td></tr></table>';
			}
			if(curPageCtr == '' || curPageCtr == null || curPageCtr == 'null' || curPageCtr == 'undefined') {
				curPageCtr = 1;
			}

			paginationRange = paginationRange * 1;
			var strUrl = 'href=\"javascript:reloadSB1(' + paginationRange + ',';

			curPageCtr = curPageCtr *1;

			var enablePrevious = false;
			var enableNext = false;
			var enableFirst = false;

			if(nextFTSIndex > 0 && nextFTSIndex < totalCnt) {
				enableNext = true;
			}

			if(curFTSIndex > 0) {
				enableFirst = true;
				enablePrevious = true;
			}
			var strresultsPageCurrent = '<li class=\'current-page\'>';		

			output += "<table class='results-bar'>";
			output += "<tr>";
			output += "<td class='result-count'>";
			
			var strtobjnum = ((curPageCtr - 1) * paginationRange) + 1;
			var endobjnum = strtobjnum + paginationRange - 1;
			if(endobjnum > totalCnt) {
				endobjnum = totalCnt;
			}
			
			output += strtobjnum + ' - ' + endobjnum + ' ';
			
			output += emxUIConstants.STR_OF + ' ';
			output += totalCnt + ' ';
			output += emxUIConstants.STR_RESULTS;
			output += "</td>";			
			output += "<td>";
			output += "<table border='0' cellpadding='0' cellspacing='0'>";
			output += "<tr>";
			output += "<td>"+emxUIConstants.STR_PAGESIZE+"</td>";
			output += "<td><input size=\'4\' type=\'textbox\' id=\'numobjsperpage\' name=\'numobjsperpage\' value=\'";
			output += paginationRange;
			output += "'/></td>";
			output += "<td><a href='javascript:changePaginationRange()'><img border='0' src='../common/images/utilResultsListNext.gif' alt='Apply'/></a></td>";
			output += "<td>(Max Value: ";
			output += emxUIConstants.STR_MAX_QUERY_LIMIT + ")</td>";			
			output += "</tr></table>";
			output += '<td class=\"pagination-control\">';
			output += '<ul>';
	
			if(enableFirst) {
				output += "<li><a class=\"btn first-result\" " + strUrl + '\'\',\'0\'' + ',\'first\')\">' + "</a></li>";
			} else {
				output += "<li><a class=\"btn first-result disabled\"></a></li>";
			}
			
			if(enablePrevious) {
				output += "<li><a class=\"btn previous-result\" " + strUrl + "\'\',\'" + prevFTSIndex*1 + "\',\'previous\')\">"+ "</a></li>";
			} else {
				output += "<li><a class=\"btn previous-result disabled\"></a></li>";
			}
			
			if(enableNext) {
				output += "<li><a class=\"btn next-result\" " + strUrl + "\'\',\'" + nextFTSIndex*1 + "\',\'next\')\">" + "</a></li>";
			} else {
				output += "<li><a class=\"btn next-result disabled\"></a></li>";
			}
			
			output += '</ul></td>';
			output += '</tr></table>';
		}
		if(windowshade){
		output += '<a class = "btn close" onclick="getTopWindow().closeWindowShadeDialog()" href="#"></a>';
		}	
		return output;
	},

	getFiltersJSONString : function _getFiltersJSONString(){
	    return emxUICore.toJSONString(this.filters);
	},

openTagNavigation: function _openTagNavigation() {
	var othis = this;
	this.tnWin =  bpsTagNavConnector.getTNWindow();
	require(['DS/TagNavigator/TagNavigator','DS/TagNavigatorProxy/TagNavigatorProxy' ], function(TagNavigator, TagNavigatorProxy) {
		//Tagger
		var tagger, path = window.location.pathname.split('/')[1],
			options = {
			cStorageService : window.location.protocol + "//" + window.location.host + "/" + path,
			tenant: "onpremise",
			lang: getTopWindow().clntlang
			};
		TagNavigator.set6WTaggerOptions(options);
		tagger = TagNavigator.get6WTagger("context2");
		othis.TagNavigator = TagNavigator;
		TagNavigator.create6WTaggerView(tagger, "tn-target", undefined, true);
		//IR-297093-3DEXPERIENCER2015x, below call is not required here.
		//othis.tnWin.jQuery(othis.tnWin.document).trigger("TN_LAUNCHED");
		//end Tagger
		//TaggerProxy
		var options2 = {
			contextId: "context2",
			filteringMode: 'FilteringOnServer',
			rightParentWindow: window
		};


		if(!othis.tnID) {
			//setup listeners
			//when a tag is clicked in TN
			othis.tnID = TagNavigatorProxy.createProxy(options2);
			
			othis.tnID.addFilterChangeListener(bpsTagNavSBInit.handleFilterFTS, bpsTagNavSBInit, false);
		}
		
		//end TaggerProxy
		jQuery('#searchPanel').append(jQuery('#tn-target'));
		jQuery('#tn-target').show();
		othis.loadTaxonomies();
	});
},
closeTagNavigation : function _closeTagNavigation(){
	jQuery('#tn-target').hide();
	}
}; // END FullSearch object

//Dyna Tree functions
function selectDynaNode(select, node){
	FullSearch.refreshDynaTree=false;
	FullSearch.toggleDyna(node, select);
}

function activeDynaNode(node){
	if(!node.data.hideCheckbox){
        node.toggleSelect();
        node.deactivate();
        }
	else{
		node.deactivate();
		}
}
// emxSaveSearchAsDialog wants this
var pageControl = {
	setSavedSearchName: function _setSavedSearchName(name){
		FullSearch.currSaveName = name;
	}
};

function saveSearch(name, type){
	return FullSearch.saveAs(name, type);
}

//
// The save search name is encoded with the unicode values separated with . (dot)
// Ex. if the save search name is 'ABC' then the encoded name will be '65.66.67'
//
function encodeSaveSearchName(strSaveSearchName){
	if (strSaveSearchName == null) {
		return null;
	}
	
	var chars = [];
	for (var i = 0; i < strSaveSearchName.length; i++) {
		chars.push(strSaveSearchName.charCodeAt(i));
	}
	
	return chars.join(".");
}

//utility methods
function initializer(){
	FullSearch.init(true);
	if(FullSearch.showInitialResults == "false") {
		FullSearch.results.style.display="none";
        FullSearch.splashFrame.style.display="block";		
	} else {
		FullSearch.splashFrame.style.display="none";
        FullSearch.results.style.display="block";
	}
}

function typeChange(){
	//Need to update other values also before filtering the values
	FullSearch.filterResults(FullSearch.STR_TYPE, document.getElementById("TypeActual").value, false);
}

/*
function StringBuffer(){
	this.buffer = [];
}
StringBuffer.prototype.append = function append(string){
	this.buffer.push(string);
	return this;
}
StringBuffer.prototype.toString = function toString(){
	return this.buffer.join("");
}
*/

var typeDiv = null;
//var iframeObj = null;
function showTypeHierarchyPopup(btnName,taxonomy){
	var btValue = document.getElementById(btnName);
	jQuery('div#imgdiv').parent().css('display','none');
	if (btValue.typeDiv) {
		if(FullSearch.searchCriteriaChanged) {
			updateSearchCriteria(true);
		}
		if(document.getElementById(taxonomy) && jQuery('div#'+taxonomy, $(btValue.typeDiv)).length == 0){
			if(!jQuery(btValue.typeDiv)){
				jQuery('div#'+btnName).append(jQuery('<div class="facet-content"><div class="facet-body"></div></div>'));
			}
			jQuery('div.facet-body', $(btValue.typeDiv)).append(jQuery('div#'+taxonomy).parent());
		}
		btValue.typeDiv.style.display = "block";
		FullSearch.textbox = document.getElementById(taxonomy+"ActualDisplay");
		FullSearch.button = "btnChooser"+taxonomy;
	} else {
		createTypeDiv(btnName, taxonomy);
	}
}

function createTypeDiv(btnName,taxonomy){
	/* Use preceding text field rather than btn as reference for positioning popup */
	/* for consistency with other widgets, and to prevent clipping off to right of window */
	var btValue = document.getElementById(btnName);
	var btHeight = 0;
	var btWidth = 0;

	
	var topdiv = document.createElement('div');
	topdiv.setAttribute('id', btnName);
	topdiv.setAttribute('class', "facet expanded");
	
	btHeight = btValue.offsetHeight;
	btWidth = btValue.offsetWidth;
	topdiv.style.top = findPosY(btValue) + btHeight + "px";
	var divX = findPosX(btValue);
	topdiv.style.left = divX + "px";
	topdiv.style.zIndex = 10;
	topdiv.style.minWidth = "150px";
	topdiv.style.position = "absolute";
	
	var imageDiv = document.createElement('div');
	imageDiv.setAttribute('id', "imgdiv");
	imageDiv.style.display = "block";
	imageDiv.style.textAlign = "right";
	if(!FullSearch.getImmediateMode()){
		var aTag = document.createElement("a");
		aTag.setAttribute("href", "javascript:FullSearch.refreshTaxonomies('"+btnName+"','"+taxonomy+"')");
		var imgDone = document.createElement("img");
		imgDone.setAttribute('id', "imgNonImmediateFilter");
		imgDone.setAttribute("src", "../common/images/buttonMiniDone.gif");
		aTag.appendChild(imgDone);
		imageDiv.appendChild(aTag);
	}
	var anchorTag = document.createElement("a");
	anchorTag.setAttribute("href", "javascript:hideTypeDiv('"+btnName+"')");
	var imgCheck = document.createElement("img");
	imgCheck.setAttribute('id', "imgCheck");
	imgCheck.setAttribute("src", "../common/images/buttonMiniCancel.gif");
	anchorTag.appendChild(imgCheck);
	
	imageDiv.appendChild(anchorTag);
	topdiv.appendChild(imageDiv);
	
	var dv = document.createElement('div');
	dv.setAttribute('id', "formTypes");
	var data;
	
	var searchURL = FullSearch.getDynaTaxonomiesUrl();
	if(FullSearch.searchCriteriaChanged) {
		updateSearchCriteria(true);
	}
	data = FullSearch.getServerData(searchURL);
	
	if(!FullSearch.dynaTaxonomy.children){
		FullSearch.dynaTaxonomy = data;
	}else{
		data = FullSearch.dynaTaxonomy;
	}
	FullSearch.taxonomies[taxonomy] = "";
	
		var taxData = {objs:[]};

		if(data.children){
			var len = data.children.length;
			for(var i = 0; i < len; i++){
				if(data.children[i].taxonomy == taxonomy){
					taxData.objs[0] = data.children[i];
				}
			}
		}
	var objXML;
		
	FullSearch.textbox = document.getElementById(taxonomy+"ActualDisplay");
	FullSearch.button = "btnChooser"+taxonomy;
	objXML = FullSearch.convertJSONtoXML(taxData.objs);
	
	document.full_search.appendChild(topdiv);
	if(taxData.objs[0]){
	taxData.objs[0].onActivate = activeDynaNode;
	taxData.objs[0].onSelect   = selectDynaNode;
	taxData.objs[0].checkbox = true;
	taxData.objs[0].selectMode = 2;
	jQuery('div#'+btnName).append(jQuery('<div class="facet-content"><div class="facet-body"></div></div>'));
    if(jQuery('div#'+taxonomy).length == 0){
    	jQuery('.facet-body','div#'+btnName).append(FullSearch.facetAttrTemp(taxData.objs[0].taxonomy, taxData.objs[0].title));
    	jQuery('div#'+taxonomy).dynatree(taxData.objs[0]);
    }else{
    	jQuery('.facet-body','div#'+btnName).append(jQuery('div#'+taxonomy).parent());
     }
	}
	btValue.typeDiv = topdiv;
}

function hideTypeDiv(btnName){
	var btValue = document.getElementById(btnName);
	btValue.typeDiv.style.display = "none";
//	this.iframeObj.style.display = "none";
}

function getSelectedValue(fName, fVal, fDisplayValue, blnSelected){
	document.full_search.TypeActual.value = fVal;
	if (blnSelected) {
		if(FullSearch.filters[fName]){
			FullSearch.filters[fName].remove("Equals|"+fVal);
			FullSearch.textbox.value = FullSearch.filters[fName].join(",").replace(/Equals\|/g,"");
		}else{
			FullSearch.textbox.value = "";
		}
	} else {
		FullSearch.textbox.value = fDisplayValue;
	}
	FullSearch.setType(fName, fVal);
	FullSearch.filterResults(fName, fVal, blnSelected);
}

function findPosX(obj){
	var curleft = 0;
	if (obj.offsetParent) {
		while (obj.offsetParent) {
			curleft += obj.offsetLeft;
			obj = obj.offsetParent;
		}
	} else 
		if (obj.x) {
			curleft += obj.x;
		}
	return curleft;
}

function findPosY(obj){
	var curtop = 0;
	if (obj.offsetParent) {
		while (obj.offsetParent) {
			curtop += obj.offsetTop;
			obj = obj.offsetParent;
		}
	} else 
		if (obj.y) {
			curtop += obj.y;
		}
	return curtop;
}

/**
 *To toggle the views between formbased and Navigation Refinement
 */
function changeView(currentMode){
	var myObj = FullSearch.typeChooser;
	var queryType = FullSearch.getQueryType();
	if (myObj == null) {
		myObj = document.getElementById("mxform_div");
	}
	var outDiv = jQuery('div.popup').get(0);
	if(outDiv){
		FullSearch.removeFloatingDiv();
	}
	jQuery('div#imgdiv').parent().css('display','none');
	
	if(queryType == "Real Time" && jQuery("#refinementPanel").html() == ""){
		return;
	}
	
	if(FullSearch.dynaTaxonomy.children){
		for(var i=0; i < FullSearch.dynaTaxonomy.children.length ; i++){
			var dynaNode = FullSearch.dynaTaxonomy.children[i];
			var id = dynaNode.taxonomy;
			jQuery("div#"+id).parent().remove();
		}
	}
	
		if (currentMode=="NavigationMode") {
			FullSearch.closeTagNavigation();	
			if("true"==FullSearch.getTagsMode()){
				FullSearch.filters = FullSearch.navFilters ? emxUICore.parseJSON(FullSearch.navFilters) : emxUICore.parseJSON(FullSearch.initialFilterJSONString);
				//If there is no initial search result then it should not do the search. It should display the splash screen only
				if(FullSearch.results.style.display=="block"){
					FullSearch.formSearch();
				}				
			}
			FullSearch.setFormBasedMode("false");
			FullSearch.setTagsMode("false");
			FullSearch.setLayout();
			FullSearch.setSwitchedNavMode(true);
			FullSearch.searchCriteriaChanged = true;
			FullSearch.loadNavData();
			myObj.style.display = "none";
			jQuery('.applied-filters').css('display','block');
		}
		if(currentMode=="TagsMode"){
			// If switching from tag to other mode then storing the filter in a different object and filters will be initialized with the stored filter when we come back from tag mode
			var isTagMode = "true"!=FullSearch.getTagsMode();
			if(isTagMode){
				FullSearch.navFilters = emxUICore.toJSONString(FullSearch.filters);
				FullSearch.filters = emxUICore.parseJSON(FullSearch.initialFilterJSONString);
			}
			FullSearch.setFormBasedMode("false");
			FullSearch.setTagsMode("true");
			if(isTagMode && FullSearch.results.style.display=="block"){
				FullSearch.formSearchTimeOut(FullSearch.tagsJSON);
			}
			FullSearch.setLayout(true);
			FullSearch.loadNavData();
			FullSearch.openTagNavigation();
			return;
		}
		else {
			FullSearch.closeTagNavigation();
			if(currentMode!="FormBasedMode"){
				return;
			}
			if("true"==FullSearch.getTagsMode()){
				FullSearch.filters = FullSearch.navFilters ? emxUICore.parseJSON(FullSearch.navFilters) : emxUICore.parseJSON(FullSearch.initialFilterJSONString);
				if(FullSearch.results.style.display=="block"){
					FullSearch.formSearch();
				}	
			}
			FullSearch.setFormBasedMode("true");
			FullSearch.setTagsMode("false");
			FullSearch.searchCriteriaChanged = true;
			FullSearch.loadNavData();
			var types = "";
			types = FullSearch.taxonomyDispValues["TYPES"];		
			var typesName = document.getElementById("TYPESActualDisplay");
			
			if(types && typesName)
			{
				  var typevalues = [];
				  for(var item=0; item < types.length; item++)
				  {
					  var singleValue = types[item];
					  var value = singleValue.substring(singleValue.indexOf('|')+1);
					  typevalues.push(value);
				  }			  
				  typesName.value = typevalues.join('|');
			}
			FullSearch.setSwitchedNavMode(false);
			myObj.style.display = "inline";
			jQuery('.applied-filters').css('display','none');
			FullSearch.setLayout(true);
			
		}	
	FullSearch.setToggleButtonLabel();
}

function resetPolicyAndStateFields()
{
	var policyElement = document.getElementById("POLICY");
	var currentElement = document.getElementById("CURRENT");
	/*var policyElement = document.getElementById("POLICY");
	if (policyElement && !policyElement.disabled) {
	    policyElement.value = "";
	    FullSearch.addToFilters("POLICY", "*");				
	}
	var currentElement = document.getElementById("CURRENT");
	if (currentElement && !currentElement.disabled) {
	    currentElement.value = "";
	    FullSearch.addToFilters("CURRENT", "*");				
	}*/
	if (policyElement && !policyElement.disabled && currentElement && !currentElement.disabled) {
		FullSearch.validatePolicyAndState("TYPES");
	}
}
/**
 * reset a parameter in urlParameters
 * @param parm The querystring parameter
 * @param val The parameter value
 */
function resetParameter(parm, val){
	var currentPageUrl = FullSearch.getPageUrl();
	var qb = new Query(FullSearch.getPageUrl());
	qb.replace(parm, val, true);
	return qb.toString();
}

function disableRevision(param1,param2){
	var control = document.getElementById(param1);
	var revision = document.getElementById("REVISION");
	if (control.checked) {
		FullSearch.addToFilters(param1.toUpperCase().replace("_NAVMODE",""), "TRUE");
		control = document.getElementById(param2);
		control.checked = false;
		FullSearch.removeFilter(param2.toUpperCase().replace("_NAVMODE","")); 
		//FullSearch.addToFilters(param2.toUpperCase().replace("_NAVMODE",""), "FALSE");
	} else {
		//For IR-048890V6R2011x 		
		FullSearch.addToFilters(param1.toUpperCase().replace("_NAVMODE",""), "false");
		//FullSearch.removeFilter(param1.toUpperCase().replace("_NAVMODE","")); 
		FullSearch.removeFilter(param2.toUpperCase().replace("_NAVMODE","")); 
	}
	//bug 369343
	FullSearch.toggleSearchButton();
}

function formReplaceInput(formObj,Delimiter){
	if (formObj) {
		FullSearch.removeFilter(formObj.name);
		var items = formObj.value.split(Delimiter);
		for (var itr = 0; itr < items.length; itr++) {
			if(items[itr] && items[itr].length > 0){
				FullSearch.appendToFilters(formObj.name, items[itr]);
			}	
		}
		FullSearch.toggleSearchButton();
	}
}

function formAddInput(formObj){
	FullSearch.clearSearchTimeStamp = true;
	if (formObj) {
		if(!FullSearch.validateSearchText(formObj, ",")){
			formObj.focus();
			return;
		}
		var value = (formObj.value == "") ? "*" : formObj.value;
		FullSearch.addToFilters(formObj.name, value);
		FullSearch.toggleSearchButton();		
	}
}

function resetPage(){
	var url = "../common/emxFullSearch.jsp?" + FullSearch.getPageUrl();
	var istop   = true;
	if(url.indexOf("emxFullSearch.jsp") == -1){
		//For non top search window, we will not have top referencing to Search window. So, this.locaion should be used to reference to Search window
		url = this.location.href;
		istop   = false;
	}
	
	var modeToReplace = "switchedNavMode=" + FullSearch.getSwitchedNavMode();
	if(FullSearch.getSwitchedNavMode() == true){
		url = strReplaceAll(url, "&Tags Mode=true", "");
	}	
	if(url.indexOf("switchedNavMode=") == -1 && FullSearch.getSwitchedNavMode() == true){
		url += "&switchedNavMode=" + FullSearch.getSwitchedNavMode();
	} else if(url.indexOf("switchedNavMode=true") != -1 && FullSearch.getSwitchedNavMode() == false){
		url = strReplaceAll(url, "switchedNavMode=true", modeToReplace);
	} else if (url.indexOf("switchedNavMode=false") != -1 && FullSearch.getSwitchedNavMode() == true){
		url = strReplaceAll(url, "switchedNavMode=false", modeToReplace);
	}
	var qb = new Query(url);
	qb.replace(FullSearch.PARAM_VIEW_FORM_BASED, FullSearch.getFormBasedMode(), true);	

	var resetTXT = qb.getValue('txtTextSearch');
	var currentTXT = getTopWindow().jQuery('#GlobalNewTEXT').val();
	if(!istop){
		//For non top search window, we will not have top referencing to Search window. So, this.locaion should be used to reference to Search window
		FullSearch.submitLongURL(qb.toString(),'reset');
	} else {
		FullSearch.submitLongURL(qb.toString(),'reset');
	}
	if(currentTXT && resetTXT && resetTXT != currentTXT){
		getTopWindow().jQuery('#GlobalNewTEXT').val(resetTXT);
		getTopWindow().gTypeSea = resetTXT;
	}
}
//an alias of String.fromCharCode
function chr(code)
{
	return String.fromCharCode(code);
}
//it is a private function for internal use in utf8Decode function 
function _utf8Decode(utf8str)
{	
	var str = new Array();
	var code,code2,code3,code4,j = 0;
	for (var i=0; i<utf8str.length; ) {
		code = utf8str.charCodeAt(i++);
		if (code > 127) code2 = utf8str.charCodeAt(i++);
		if (code > 223) code3 = utf8str.charCodeAt(i++);
		if (code > 239) code4 = utf8str.charCodeAt(i++);
		
		if (code < 128) str[j++]= chr(code);
		else if (code < 224) str[j++] = chr(((code-192)<<6) + (code2-128));
		else if (code < 240) str[j++] = chr(((code-224)<<12) + ((code2-128)<<6) + (code3-128));
		else str[j++] = chr(((code-240)<<18) + ((code2-128)<<12) + ((code3-128)<<6) + (code4-128));
	}
	return str.join('');
}

//Decodes a UTF8 formated string
function utf8Decode(utf8str)
{
	var str = new Array();
	var pos = 0;
	var tmpStr = '';
	var j=0;
	while ((pos = utf8str.search(/[^\x00-\x7F]/)) != -1) {
		tmpStr = utf8str.match(/([^\x00-\x7F]+[\x00-\x7F]{0,10})+/)[0];
		str[j++]= utf8str.substr(0, pos) + _utf8Decode(tmpStr);
		utf8str = utf8str.substr(pos + tmpStr.length);
	}
	
	str[j++] = utf8str;
	return str.join('');
}

function suggestions_Search(value){
	if (isIE){
		FullSearch.textSearch.value = utf8Decode(value);
		//FullSearch.textSearch.value = decodeURI(value);
	}
	else{
		FullSearch.textSearch.value =value;
	}
	FullSearch.Suggestions.style.display = "none";
	FullSearch.body.style.display = "block";
	FullSearch.formSearch();
}

function strReplaceAll(str, from, to){
	if(from == to){
		return str;
	}
	if (str != null && str != "") {
		var ind = str.indexOf(from);
		while (ind > -1) {
			str = str.replace(from, to);
			ind = str.indexOf(from);
		}
	}
	return str;
}

function searchWithinCollection(strName){
	var url = decodeURIComponent(FullSearch.form.action);
	var qb = new Query(url);
	qb.replace(FullSearch.FILTER_FIELDNAME, emxUICore.toJSONString(FullSearch.filters), true);
	qb.replace(FullSearch.PARAM_COLLECTION, strName, true);
	if (FullSearch.queryLimit && isValidQueryLimit(FullSearch.queryLimit)) {
		qb.set(FullSearch.QUERY_LIMIT, FullSearch.queryLimit.value);
	}
	FullSearch.setCollection(strName);
	FullSearch.reset.disabled = false;
	FullSearch.form.action = qb.toString();
	if (FullSearch.getFormBasedMode() == "false") {
		FullSearch.loadNavData();
	} else {
		FullSearch.loadForm();
	}
	FullSearch.submitForm();
	
}

/*
 ** Get window height
 */
function getWindowHeight(objWin){
	objWin = (objWin == null ? window : objWin);
	if (isIE) {
		return objWin.document.documentElement.clientHeight || objWin.document.body.clientHeight;
	} else {
		return objWin.innerHeight;
	}
}

/*
 ** Get window width
 */
function getWindowWidth(objWin){
	objWin = (objWin == null ? window : objWin);
	if (isIE) {
		return objWin.document.documentElement.clientWidth || objWin.document.body.clientWidth;
	} else {
		return objWin.innerWidth;
	}
}

/*
 ** watch field for changes
 */
function watchForChange(name,val){
	frmField = document.getElementById(name);
	frmFieldHidden = document.getElementById("hidden_" + name);
	/* commented while merging HF40 to 2010
	var tempfrmFieldHidden = frmFieldHidden.value;
	frmFieldHidden.value=tempfrmFieldHidden.replace(/,/g, "|");	*/
    if(frmField.value == val){
        setTimeout(function _watchForChange(){
            watchForChange(name, val);
        },100);
    }else{
    	//if(name == "TYPE"){name = "TYPES"}
		frmFieldHidden.value=frmFieldHidden.value.replace(/,/g , emxUIConstants.STR_REFINEMENT_SEPARATOR);
        FullSearch.addToFilters(name, frmFieldHidden.value);
    }
}

function checkEnterKeyPressed(event, url, currentField){
	var pK = document.all?window.event.keyCode:event.which;
	//var strURL = url+"&callbackFunction=setValuesToRespectiveFields"
	var strURL = url;
    if(pK==13)
    {
    	showFullSearchChooser(url,currentField);
    }
}

function showFullSearchChooser(url,currentField){
	//if the currentField has blank value, then it is treated as *
	formAddInput(currentField);	
	var isFullSearch = false;
	var isDefaultDefined = false;
	var macros;
	var macrosArray = new Array();
	var defaultValueURL = "";
	var additionaldefaultParameters = "";
	var start = url.indexOf("default=");
	var filtersArray = new Array();
	if(start >-1){
		isDefaultDefined = true;
	}
	//if url startswith ../common/emxFullSearch.jsp?
	if(url.indexOf('../common/emxFullSearch.jsp?') == 0){
		isFullSearch = true;		
	}
	//updateFilters(currentField.name,currentField.value,true);
	if(isDefaultDefined){		
		var subString1 = url.substring(start);
		var end = subString1.indexOf("&");		
		macros = subString1.substring(subString1.indexOf("=")+1,end);		
		var macroList = macros.split(FullSearch.getFieldSeperator());
		for(var i=0; i<macroList.length; i++) {
			var input = macroList[i].split('=');
			var fieldName;
			var fieldValue;		
			if(input.length > 1){
				fieldName  = input[0];
				fieldValue = input[1];
				var macroValue = "";		
				var isMacro = (fieldValue.indexOf("$") >= 0)?true:false;
				if(isMacro){
					var lookForField = "";
					if(fieldValue.length >2){
						lookForField = fieldValue.substring(2, fieldValue.length-1);				
					}			
					if(typeof FullSearch.filters[lookForField] != 'undefined' ){
						macroValue = FullSearch.filters[lookForField];
					}else{
						macroValue = "";
					}
				}else{
					macroValue = resolveDefaultValue(fieldValue);
				}
				macrosArray[macrosArray.length]= {name:fieldName,value:macroValue};
				filtersArray[filtersArray.length]= {name:fieldName,value:fieldValue};
			}else{
				//either > or <
				//multiple values are not allowed
				// field>${field} is not allowed
				additionaldefaultParameters += FullSearch.getFieldSeperator()+macroList[i];
				var field = macroList[i];
				var op = "=";
				var opStr = "Equals";
				var macroFieldName = "";
				var macroFieldValue = "";				
				if(field.indexOf(">") > -1){
					op = ">";
					opStr = "Greater";
				}else if(field.indexOf("<") > -1){
					op = "<";
					opStr = "Less";
				}
				macroFieldName = field.split(op)[0];
				macroFieldValue = field.split(op)[1];
				if(isValidDate(macroFieldValue)){
					macroFieldValue = macroFieldValue.replace(",",", ");
				}
				appendToAdditionalFilters(macroFieldName,macroFieldValue,opStr);
			}
		}
	}
	//we are not certain that the current field will be present or not. Hence user should configure macros such that
	//if current field is present, values should be carried forward
	//defaultValueURL = appendCurrentFieldValue(defaultValueURL,currentField,isMACRODefined);
	if(macrosArray.length > 0){
		defaultValueURL = createDefaultValueURL(macrosArray);
	}
	defaultValueURL += additionaldefaultParameters;
	if(isDefaultDefined){
		url = url.replace(macros,defaultValueURL);		
	}	
	if(isFullSearch){
		checkResultCount(url,currentField,filtersArray);
	}else{
		showModalDialog(url, 700, 500, true);		
	}	
}

var additionalFilters = new Object();

function appendToAdditionalFilters(macroFieldName,macroFieldValue,opStr){
	
	additionalFilters[macroFieldName] = new Array();
	if (additionalFilters[macroFieldName].find(opStr + "|" + macroFieldValue) == -1) {
		additionalFilters[macroFieldName].push(opStr + "|" + macroFieldValue);
	}
}

function checkResultCount(url,currentField,filtersArray){
	var responseXML = null;
	url = url.replace("/emxFullSearch.jsp?","/emxAEFCheckUniqueResult.jsp?");
	var fieldname = currentField.name;
	var hiddenFieldName = "hidden_"+currentField.name;
	//update filters with current field
	//filters should be redefined and then append them in the url
	var duplicateFilters = getRedefinedFilters(filtersArray);
	//responseXML = emxUICore.getTextXMLDataPost(url+"&filters="+FullSearch.filters.toJSONString(),"");
	responseXML = emxUICore.getTextXMLDataPost(url+"&filters="+emxUICore.toJSONString(duplicateFilters),"");
	try {
		var root = responseXML.documentElement;
		var objectCount = emxUICore.getText(emxUICore.selectSingleNode(root,"objectCount"));
		if(objectCount == 1){			
			var dispName = emxUICore.getText(emxUICore.selectSingleNode(root,"displayName"));
			var actualValue = emxUICore.getText(emxUICore.selectSingleNode(root,"actualName"));
			var OID = emxUICore.getText(emxUICore.selectSingleNode(root,"actualName"));
			document.getElementById(fieldname).value = dispName;
			document.getElementById(hiddenFieldName).value = actualValue;
			//reseting filter values
			updateFilters(fieldname,dispName, false);
		}else{			
			//append fullTextSearchTimestamp and checkStoredResult = true
			var searchTimeStamp = emxUICore.getText(emxUICore.selectSingleNode(root,"searchTimeStamp"));
			url = url.replace("/emxAEFCheckUniqueResult.jsp?","/emxFullSearch.jsp?");			
			url += "&fullTextSearchTimestamp="+searchTimeStamp;
			url += "&checkStoredResult="+"true";
			showModalDialog(url, 700, 500, true);
		}
	} catch (e) {
		// TODO: handle exception
		alert(e.message);
	}
}

function getRedefinedFilters(filtersArray){
	var dupFiltersArray = new Object();
	for(var i=0; i<filtersArray.length; i++) {
		var isMacro = (filtersArray[i].value.indexOf("$") >= 0)?true:false;		
		if(isMacro){
			var lookForField = "";
			if(filtersArray[i].value.length >2){
				lookForField = filtersArray[i].value.substring(2, filtersArray[i].value.length-1);				
			}
			if(FullSearch.filters[lookForField]){
				dupFiltersArray[filtersArray[i].name] = FullSearch.filters[lookForField];
			}			
		}else{
			dupFiltersArray[filtersArray[i].name] = resolveDefaultValue(filtersArray[i].value);			
		}
	}
	//append additionalFilters to dupFiltersArray
	for(var fieldName in additionalFilters) {
		if(typeof additionalFilters[fieldName] != "function"){
			dupFiltersArray[fieldName] = new Array();
			if(dupFiltersArray[fieldName].find(additionalFilters[fieldName][0]) != null){
				dupFiltersArray[fieldName].push(additionalFilters[fieldName][0]);
			}
		}
	}	
	return dupFiltersArray;
}

function resolveDefaultValue(values){
	//!= is not supported
	var operator = "Equals";
	var valueArray = new Array();
	if(isValidDate(values)){
		values = values.replace(",",", ");
		if(valueArray.find(operator + "|" + values) == -1){
			valueArray.push(operator + "|" + values);					
		}
	}else{
		var valueList = values.split(",");
		for(var i=0; i<valueList.length; i++) {
			if(valueArray.find(operator + "|" + valueList[i]) == -1){
				valueArray.push(operator + "|" + valueList[i]);					
			}						
		}		
	}	
	return valueArray;
}

function updateFilters(fieldname,dispName, isCurrentField){
	var operator = "Equals";
	//When user enters value for first time, filters array may not have current field in it
	if(!FullSearch.filters[fieldname] || 
		(typeof isCurrentField != 'undefined' && isCurrentField)){
		FullSearch.filters[fieldname] = new Array();						
	}
	var items = dispName.split("|");
	for (var i = 0; i < items.length; i++) {				
		if(FullSearch.filters[fieldname].find(operator + "|" + items[i]) == -1){
			FullSearch.filters[fieldname].push(operator + "|" + items[i]);					
		}
	}
}

function createDefaultValueURL(macrosArray){
	var defaultURL ="";
	for(var i=0; i<macrosArray.length; i++) {
		var fieldName = macrosArray[i].name;
		var value = macrosArray[i].value;
			if(typeof value != 'undefined' && value != ""){
			if(i==0){
				defaultURL += fieldName;
			}else{
				defaultURL += FullSearch.getFieldSeperator()+fieldName;
			}
			for(var j=0; j<value.length; j++) {
				var fieldValues = value[j].split("|");
				var operator = fieldValues[0];
				var fieldValue = fieldValues[1];
				//bug fix - 369347
				if(isValidDate(fieldValue)){
					fieldValue = fieldValue.replace(",",", ");					
				}
				switch (operator) {
					case "Equals":
							if(j==0){
								defaultURL += "="+fieldValue;
							}else{
								defaultURL += ","+fieldValue;
							}						
						break;
					case "Greater":
							if(j==0){
								defaultURL += ">"+fieldValue;
							}else{
								//case Between
								defaultURL += FullSearch.getFieldSeperator()+fieldName;
								defaultURL += ">"+fieldValue;																
							}							
						break;
					case "Less":
							if(j==0){
								defaultURL += "<"+fieldValue;
							}else{
								//case Between
								defaultURL += FullSearch.getFieldSeperator()+fieldName;
								defaultURL += "<"+fieldValue;								
							}							
						break;					
					default:
						break;
				}
			}
		}		
	}	
	return defaultURL;
	
}

function appendCurrentFieldValue(defaultURL, currentField,isMACRODefined){
	if(isMACRODefined){
		defaultURL += FullSearch.getFieldSeperator()+currentField.id+"="+currentField.value;		
	}else{
		defaultURL += "default="+currentField.id+"="+currentField.value;		
	}	
	return defaultURL;
}

function validateFullTextSearchString(){
	if(FullSearch.getQueryType().toLowerCase() == "indexed" && FullSearch.showInitialResults == "false"){ 
		var fullTextInputObj = document.getElementById("txtTextSearch");		
		if(fullTextInputObj.value != "" && !FullSearch.validateSearchText(fullTextInputObj, " ")){
			fullTextInputObj.focus();
			return false;
		}
	}
	return true;
}
function enableSearchButton() {
	if(!FullSearch.getEnableSearchButton() && FullSearch.getQueryType().toLowerCase() == "indexed" && FullSearch.showInitialResults == "false"){ 
		var srchButt = jQuery("[name=mx_btn-search]");
		var fullsearchinputObj = document.getElementById("txtTextSearch");		
		if(fullsearchinputObj.value != ""){
			var str = fullsearchinputObj.value;
			while(str.indexOf(" ")>=0) {
				str = str.replace(" ","");
			}
			if(str != "") {
				srchButt.attr("onclick","FullSearch.formSearch();");
			}
		} else {
			FullSearch.removeFilter(FullSearch.TEXT_SEARCH);
			//srchButt.disabled = !FullSearch.isUserRefined();
		}
	}
}
function isValidSearchText(searchText, minchars){	
	if(searchText.length > 0) {
		if(searchText.indexOf("*") >= 0 || searchText.indexOf("?") >= 0) {
			while(searchText.indexOf("*") >= 0){
				searchText = searchText.replace("*", "");
			}
	
			while(searchText.indexOf("?") >= 0){
				searchText = searchText.replace("?", "");
			}
			
			if(searchText.length < minchars) {
				return false;
			}
		}
	}
	return true;	
}
/*
 ** validates the query limit
 */
function isValidQueryLimit(queryLimit){
	var retStatus = true;		
	if(queryLimit != null){
		queryLimit = queryLimit.value;
	}else{
		retStatus = false;
	}	
	var maxQueryLimit = parseInt(emxUIConstants.STR_MAX_QUERY_LIMIT);
	if(isNaN(queryLimit)){
		retStatus = false;
	}else{
		if(emxUICore.toJSONString(queryLimit).indexOf(".") != -1){
			retStatus = false;
		}
		if(!(queryLimit > 0) || !(queryLimit <= maxQueryLimit)){
			retStatus = false;
		}
    }
    
	return retStatus ;
}

function toggleCaseSensitive(){
	var objCheckbox = document.getElementById("caseSensitiveSearch");
	if(objCheckbox != null && objCheckbox.checked == true){
		FullSearch.setCaseSensitiveSearch("true");
	}else{
		FullSearch.setCaseSensitiveSearch("false");
	}
    if(emxUICore.findFrame(window.parent,"windowShadeFrame")){
    	FullSearch.getServerData(FullSearch.DATA_URL+"?updateCaseSensitivePreference=True&caseSensitiveSearch="+FullSearch.getCaseSensitiveSearch());
    }	

}

//bug fix - 369347
function isValidDate(dateValue)
{
	if (dateValue.indexOf(", ") != -1) {
		dateValue = dateValue.replace(", ",",");
	}
    var thisDate=new Date(dateValue);
    if (thisDate.valueOf() > 0)
    {
        return true;
    }else {
        return false;
    }
}
/* Mx361263 */
function enableVaultSelectionList()
{
	document.getElementById("select_VAULT").removeAttribute("disabled");
}
function disableVaultSelectionList()
{
	selectField = document.getElementById("select_VAULT");
	if (selectField != null && selectField != 'undefined') {
		selectField.setAttribute("disabled","disabled");
	}
	for (var i = 0; i < selectField.options.length; i++) {
			selectField.options[i].selected = false;
	}
}

/*This is just to avoid the functional breakage 
  when we open slidin from full search page*/
function showSlideInDialog(url, isModal){
	var winWidth = "600";
	var winHeight = "500";
	var strPopupSize = "Medium";
	if(isModal){
	  showModalDialog(url, winWidth, winHeight, true,strPopupSize);
	}else{
	  showNonModalDialog(url, winWidth, winHeight,true,true,strPopupSize);
	}
}
/* end Mx361263 */

/* Called to reload autonomy search page when fill page mode is off */
function reloadSB(paginationRange, action, pagenum){ // TODO: rename method
	turnOnProgress();
	FullSearch.busy(emxUIConstants.STR_LOADING_PAGE +" "+ pagenum);
	FullSearch.evaluateFirstPage(pagenum, action);
	var parentFrame = FullSearch.results.contentWindow;
	if(parentFrame.editableTable){
		parentFrame.oImageXML = null;
		parentFrame.resetParameter("pgAction", action);
		parentFrame.resetParameter("currentPage", pagenum);
		parentFrame.resetParameter("filters", emxUICore.toJSONString(FullSearch.filters));
		parentFrame.resetParameter("checkStoredResult", "false");
		parentFrame.resetParameter("paginationRange", paginationRange);
	
		if(parentFrame.isFillPagesOn()) {
			parentFrame.resetParameter("curFTSIndex", pagenum);
		}
	
		parentFrame.editableTable.loadTextSearchResults(emxUICore.toJSONString(FullSearch.filters),null,false);
		reloadTagsPanel();
	}
	FullSearch.notBusy();	
	turnOffProgress();
}
/**Added to Reload the tags based on the pagination results 
 * */
function reloadTagsPanel(){
	if("true"==FullSearch.getTagsMode()){		
		FullSearch.tnID.setTags(FullSearch.results.contentWindow.editableTable.handleDrawTagsFTS(), FullSearch.tagsSummaryJSON);
	}
}
/* Called to reload autonomy search page when fill page mode is on */
function reloadSB1(paginationRange, action, pagenum, btnClicked){ // TODO: rename method
    if(isTableDataload) {
		isTableDataload = false;
		turnOnProgress();
		FullSearch.busy(emxUIConstants.STR_LOADING_PAGE);
		var parentFrame = FullSearch.results.contentWindow;
		if(parentFrame.editableTable){
			parentFrame.oImageXML = null;
			parentFrame.resetParameter("pgAction", action);
			parentFrame.resetParameter("currentPage", pagenum);
			parentFrame.resetParameter("filters", emxUICore.toJSONString(FullSearch.filters));
			parentFrame.resetParameter("checkStoredResult", "false");
			if(!paginationRange){
				paginationRange = getPaginationRange();
				paginationRange = paginationRange * 1;
			}
		parentFrame.resetParameter("paginationRange", paginationRange);
		if(parentFrame.isFillPagesOn()) {
			parentFrame.resetParameter("curFTSIndex", pagenum);
			if(btnClicked == "next") {
				parentFrame.curPageCounter += 1 ;
			} else if(btnClicked == "previous") {
				parentFrame.curPageCounter -= 1;
			} else if (btnClicked == "first") {
				parentFrame.curPageCounter = 1;
			}
		}
		parentFrame.editableTable.loadTextSearchResults(emxUICore.toJSONString(FullSearch.filters),null,false);
		reloadTagsPanel();
		}
		FullSearch.notBusy();	
		turnOffProgress();
		isTableDataload = true;
		} else {
			return;
		}
		
}

function getPaginationRange(){
    var inbox = document.getElementById("numobjsperpage");
    return inbox.value;
}

function changePaginationRange(){
    var paginationrng = emxUIConstants.STR_PAGE_SIZE;
    var rng = getPaginationRange();
    //fix for IR377885V6R2011
    //if(rng == '' || rng == 'undefined' || rng == null || isNaN(rng)) {
    if(rng == '' || rng == 'undefined' || rng == null || isNaN(rng) || rng.indexOf('.') !=-1) {
        alert(emxUIConstants.STR_VALID_NUMBER_ALERT);
        return;
    }
    rng = rng * 1;
    var mql = emxUIConstants.STR_MAX_QUERY_LIMIT;
    mql = mql * 1;
    if(rng <= 0) {
        alert(emxUIConstants.STR_ZEROORLESS_ALERT);
        return;
    } else if(rng > mql) {
        alert(emxUIConstants.STR_MAX_LIMIT_ALERT + " " + mql);
        return;
    }
    FullSearch.pageSize = rng;
  if(FullSearch.results.contentWindow.isFillPagesOn()) {
        reloadSB1(rng, '', 0, 'first');
    } else {
        reloadSB(rng, 'On', 1);
    }
}

function change6WPredicates(predicate){
	predicate = strReplaceAll(predicate,"DS6W_","ds6w:");
	if(predicate.indexOf("ds6w:W") == 0){
		predicate = predicate.replace(/ds6w:W/, "ds6w:w");
	}
	if(predicate.indexOf("ds6w:H") == 0){
		predicate = predicate.replace(/ds6w:H/, "ds6w:h");
	}
	return predicate;
}
				
function adjustComplexControlDiv(reqDiv,actDivWidth){
	var divleft = jQuery(reqDiv).offset().left;
	var winWidth = emxUICore.getWinWidth() ;

	if((actDivWidth + divleft) > winWidth){
		var diff =  actDivWidth + divleft - winWidth;
		jQuery(reqDiv).width(actDivWidth - diff - 100);
	}else{
		jQuery(reqDiv).width(actDivWidth);
	}
}
function updateSearchCriteria(updateFilter) {
	var searchURL = FullSearch.getDynaTaxonomiesUrl();
	searchURL = updateURLParameter(searchURL, "fullTextSearchTimestamp", new Date().getTime());
	if(updateFilter){
		var newSearchValue=FullSearch.textSearch.value;
		newSearchValue= strReplaceAll(newSearchValue, emxUIConstants.STR_REFINEMENT_SEPARATOR, " ");
    	FullSearch.addToFilters("txtTextSearch",newSearchValue);
		FullSearch.searchCriteriaChanged = false;
	}
	FullSearch.loadTaxonomies(FullSearch.getServerData(searchURL));
}

//set onload
window.onload = initializer;
ElapsedTimer.timeCheck("after loading emxUIFullSearch.js");
