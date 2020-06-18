/*!================================================================
 *  JavaScript Portal Component
 *  emxUIPortal.js
 *  Version 1.0
 *  Requires: emxUICore.js, jquery-1.4.js n-splitter.js
 * 
 *  Last Updated: 2010-09-14, GIQ
 *
 *  This file contains the definition of a JavaScript portal.
 *
 *  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
 *  This program contains proprietary and trade secret information 
 *  of MatrixOne,Inc. Copyright notice is precautionary only
 *  and does not evidence any actual or intended publication of such program
 * 
 *  static const char RCSID[] = $Id: emxUIPortal.js.rca 1.10.2.2 Fri Nov 14 07:57:02 2008 ds-arajendiran Experimental $
 *=================================================================
 */
 
 var isMaximised = false; 
 var pvContainerOverFlowStyle;
 var uiAutomation = emxUIConstants.UI_AUTOMATION;
 var SPLITTER_WIDTH = 13;
 var PORTALNAME;
 
//! Class emxUIPortal
//!     This class represents a portal page layout.
function emxUIPortal() { 
        this.superclass = emxUIObject;
        this.superclass();
        delete this.superclass;
        this.rows = new Array;                  
        this.emxClassName = "emxUIPortal";      
} 
emxUIPortal.prototype = new emxUIObject;
emxUIPortal.IMG_TABSET_ARROW = emxUIConstants.DIR_IMAGES + "utilTabsetArrow.gif";
emxUIPortal.ROW_HEIGHT = emxUIConstants.STR_PORTAL_MIN_HEIGHT;
emxUIPortal.WIDE_CHANNEL_TAB_LIMIT = 4;
emxUIPortal.THIN_CHANNEL_TAB_LIMIT = 2;
emxUIPortal.MAX_TAB_WIDTH = 167; // this is assumed as the maximum pixel for the tab
//
// Code for enabling/disabling cache
// When this is set to false, on each click on the portal tab, the tab contents will be reloaded.
//
emxUIPortal.ENABLE_CACHE = false;

//! Private Method emxUIPortal.addRow()
//!     This method adds a row to the portal.
emxUIPortal.prototype.addRow = function _emxUIPortal_addRow(objRow) {
        if (!(objRow instanceof emxUIPortalRow)) {
                emxUICore.throwError("Required parameter objRow is null or not of type emxUIPortalRow. (emxUIPortal.prototype.addRow)");
        } 
        this.rows.push(objRow);
        objRow.portal = this;
        return objRow;
}; 


//! Private Method emxUIPortal.buildDOM()
//!     This method builds the DOM layout for the portal.
emxUIPortal.prototype.buildDOM = function _emxUIPortal_buildDOM() {
	if (this.rows.length == 0) {
			emxUICore.throwError("The portal must contain at least one row. (emxUIPortal.prototype.buildDOM)");
	}  

	this.element = document.createElement("div");
	this.element.className = "pv-container";
	this.element.id = "divPowerView";
	PORTALNAME = this.rows[0].containers[0].portalName;	
	var windowHeight = emxUICore.getWindowHeight();
	 var unit= "px";
	 var heightInPercent= [];
	 var nRows = this.rows.length;
	 for(var w=0; w<nRows; w++){
	 	heightInPercent[w]=Number(this.rows[w].height);
	 }
	var totalHeight=0;
	for(var w=0; w< nRows ;w++){
	 	totalHeight += heightInPercent[w]; 
	}
	//if total height is Zero in the initial load:Divide the height equally among the rows.
	if(totalHeight <= 0){
		var pvRowHeight=Number(100 / this.rows.length);
	 	for(var w=0;w< nRows ;w++){
	 		this.rows[w].height = pvRowHeight;
	 		heightInPercent[w]=pvRowHeight;
	 	}
		totalHeight = 100;
	 }
	 		
	var resizeRqd=false;
	for(var w=0; w<nRows ;w++){
			//if one of the row height is Zero, set the rowheight to 240px
			if(this.rows[w].height <= 0 ){
				this.rows[w].height = emxUIPortal.ROW_HEIGHT ;
				heightInPercent[w]= emxUIPortal.ROW_HEIGHT * 100 / windowHeight ;
			}
			else{
	 			this.rows[w].height= heightInPercent[w] * windowHeight /100 ;
	 				if(this.rows[w].height < emxUIPortal.ROW_HEIGHT){
	 				resizeRqd=true;
	 				}
	 		}
	 }
	if(resizeRqd===true){
	 		//find the minimum height row.
	 		var min = this.rows[0].height;
	 		var minRowIdx = min;
	 		for(var w=0; w<nRows ;w++){
	 			if(this.rows[w].height <= min){
	 				min = this.rows[w].height;
	 				minRowIdx=w;
	 			}
	 		}
	 		var minRowPrcnt=heightInPercent[minRowIdx];
	 		
	 		//adjusting  the heights to support minimum Height and maintain proportionality..
	 		this.rows[minRowIdx].height=emxUIPortal.ROW_HEIGHT;
	 		for(var w=0; w < nRows ;w++){
	 			if(w!=minRowIdx){
	 				this.rows[w].height= emxUIPortal.ROW_HEIGHT * heightInPercent[w]/minRowPrcnt ;
	 			}
	 		}
	 
			//Recalculate the height in percent
			for(var w=0; w< nRows ;w++){
	 		heightInPercent[w]= (this.rows[w].height*100) / windowHeight ;
	 		}
	 		totalHeight=0;
			for(var w=0; w< nRows ;w++){
	 			totalHeight += heightInPercent[w]; 
			}
	}
	//if total height is less than 100% first row gets the remaining difference 
	if(totalHeight < 100){
		var diffHeight= 100 - totalHeight;
	 	heightInPercent[0] += diffHeight ;
	 	this.rows[0].height = heightInPercent[0]* windowHeight/100;
	}
	var rowGroup = this.isVerticalGroupEnabled(nRows);	
	var lsChannelMap = localStorage.getItem("ls-"+PORTALNAME);
	lsChannelMap = lsChannelMap == null ? {}:JSON.parse(lsChannelMap);
	for (var i=0; i < nRows ; i++) {
		var objRow = document.createElement("div");
		objRow.className = "pv-row";
		objRow.id = "divPvRow-" + (i+1);
		objRow.style.height = this.updateOrGetValue(lsChannelMap, objRow.id, this.rows[i].height + unit);
		
		// The following prevents user resizing to less than minimum size
		// However, IMO we don't want to do that - GIQ
		objRow.setAttribute("minsize", emxUIPortal.ROW_HEIGHT);
		
		//if the noOfColumns in a row is 0 then no need to draw the row
		var noOfColumns=0;		
		for(var col=0; col < this.rows[i].containers.length; col++){
			if(this.rows[i].containers[col].drawContainer==true){
				noOfColumns++;
			}
		}
		if(noOfColumns==0){
			continue;
		}		
		
		for (var j=0; j < this.rows[i].containers.length; j++) {
			
			//show minimize button only when the no of channels are morethan 2.
			if(noOfColumns> 2 && j ==(noOfColumns-1) ){
				//to add vertical div to show the minimized channel information.
				var closedCols = document.createElement("div");
				closedCols.className = "pv-col closed-cols hidden";
				var closedChannel = document.createElement("div");
				closedChannel.className = "rotate90";
				closedCols.appendChild(closedChannel);
				closedCols.id = "pv-closed-col-id-"+(i+1)+"-"+(j+1);
				objRow.appendChild(closedCols);
			}
			var channelIndex = 1;
			var rowData =  new Array;
			if(this.rows[i].containers[j].drawContainer == true){
				rowData.push(this.rows[i].containers[j]);				
				var objCol;
				if(rowGroup){
					var tagName = this.rows[i].containers[j].verticalGroup;
					objCol = document.createElement("div");
					objCol.className = "pv-col";		
					objCol.id = "divPvRowCol-" + (i+1)+"-"+ (j+1);					
					objCol.style.width = this.updateOrGetValue(lsChannelMap, objCol.id, (100 / noOfColumns).toFixed() + "%");
					
					var strChanId = "divPvChannel-" + (i+1) + "-" + (j+1)+"-"+channelIndex;
			this.rows[i].containers[j].elementID = strChanId;

			var objChan = document.createElement("div");
			objChan.className = "pv-channel complex";
			objChan.id = strChanId;
					//objChan.style.width = "100%";
			objCol.appendChild(objChan);
			if(tagName != ""){
				for(var rowCount = i+1 ;rowCount < nRows; rowCount++){
					//if(this.rows[i+1] && this.rows[i+1].containers.length > 0){
					for(var nextCol = 0; nextCol< this.rows[rowCount].containers.length; nextCol++){
						if(this.rows[rowCount].containers[nextCol].verticalGroup == tagName && this.rows[rowCount].containers[nextCol].drawContainer== true){
							rowData.push(this.rows[rowCount].containers[nextCol]);
							channelIndex++;
							this.rows[rowCount].containers[nextCol].drawContainer = false;
							var strChanId = "divPvChannel-" + (i+1) + "-" + (j+1)+"-"+channelIndex;
							this.rows[rowCount].containers[nextCol].elementID = strChanId;

							var objVerChan = document.createElement("div");
							objVerChan.className = "pv-channel complex";
							objVerChan.id = strChanId;
							objVerChan.style.width = "100%";
							objCol.appendChild(objVerChan);							
						}
					}						
				}
				}					

			}else{				
				var strChanId = "divPvChannel-" + (i+1) + "-" + (j+1);
				this.rows[i].containers[j].elementID = strChanId;

				objCol = document.createElement("div");
				objCol.className = "pv-channel complex";
				objCol.id = strChanId;					
					if(this.rows[i].containers.length>1)
					objCol.style.width =this.updateOrGetValue(lsChannelMap, strChanId,(100 / noOfColumns).toFixed() + "%");
					else
						objCol.style.width = 100 + "%";
				objCol.style.height = 100 + "%";	
				objCol.style.cssFloat = "left";
			}

				// this keeps the right column stuck to right edge
			// during animation of mazimize of left channel
			if ( j ==  this.rows[i].containers.length - 1) {
					objCol.style.styleFloat = "right"; // IE
					objCol.style.cssFloat = "right"; // FF
			}
			
				objRow.appendChild(objCol);
			if (this.rows[i].containers.length > 1) {
				this.rows[i].containers[j].tabLimit = emxUIPortal.THIN_CHANNEL_TAB_LIMIT;
			} else {
				this.rows[i].containers[j].tabLimit = emxUIPortal.WIDE_CHANNEL_TAB_LIMIT;
			} 
		}
		}
		
		this.element.appendChild(objRow);
	} 
	localStorage.setItem("ls-"+PORTALNAME, JSON.stringify(lsChannelMap));
	this.element.setAttribute("data-portalName",PORTALNAME);
    document.body.appendChild(this.element);
};


emxUIPortal.prototype.isVerticalGroupEnabled= function _isVerticalGroupEnabled(nRows) {
	var groupNameValue=[];
	for (var i=0; i < nRows ; i++) {
		for (var j=0; j < this.rows[i].containers.length; j++) {
			if(this.rows[i].containers[j].verticalGroup){
				var settingValue = this.rows[i].containers[j].verticalGroup;				
				if(groupNameValue.indexOf(settingValue)==-1){
					groupNameValue.push(settingValue);					
				}else{
					return true;
                        } 
        } 
}
	}
	return false;                          
};

emxUIPortal.prototype.updateOrGetValue= function _updateOrGetValue(lsChannelMap, key, value) {	
	var lsValue = lsChannelMap[key];
	if(lsValue == null || lsValue!=value){
		lsChannelMap[key]=value;
		lsValue = value;
	}
	return lsValue;	
};




//! Protected Method emxUIPortal.init()
//!     This method initializes the portal control.
emxUIPortal.prototype.init = function _emxUIPortal_init() {
        if (this.rows.length == 0) {
                emxUICore.throwError("The portal has no rows. Rows must be added before the portal is initialized. (emxUIPortal.prototype.init)");
        } 
        this.buildDOM();
        for (var i=0; i < this.rows.length; i++) {
                this.rows[i].init();
        } 
        var objThis = this;


        this.fireEvent("load");
}; 
//! Class emxUIPortalRow
//!     This class represents a portal page layout.
function emxUIPortalRow(intHeight) { 
        this.superclass = emxUIObject;
        this.superclass();
        delete this.superclass;
        this.containers = new Array;            
        this.emxClassName = "emxUIPortalRow";   
        this.height = intHeight || emxUIPortal.ROW_HEIGHT;   
        this.table = null;                      
} 
emxUIPortalRow.prototype = new emxUIObject;
//! Private Method emxUIPortalRow.addContainer()
//!     This method adds a container to the portal.
emxUIPortalRow.prototype.addContainer = function _emxUIPortalRow_addContainer(objContainer) {
        if (!(objContainer instanceof emxUIPortalContainer)) {
                emxUICore.throwError("Required parameter objContainer is null or not of type emxUIPortalContainer. (emxUIPortalRow.prototype.addContainer)");
        } 
        this.containers.push(objContainer);
        objContainer.portal = this;
        return objContainer;
}; 
emxUIPortalRow.prototype.getContainer = function _emxUIPortalRow_getContainer(channelName) {
        for(var i=0; i<this.containers.length; i++) {
        	if (channelName == this.containers[i].channelName) {
        		return this.containers[i];
        	}
        }
        return null;
};





//! Private Method emxUIPortalRow.init()
//!     This method initializes the portal row.
emxUIPortalRow.prototype.init = function _emxUIPortalRow_init() {
        if (this.containers.length == 0) {
                emxUICore.throwError("The portal has no containers. Containers must be added before the portal is initialized.");
        } 

        for (var i=0; i < this.containers.length; i++) {
                this.containers[i].init();
        } 

    

        this.fireEvent("load");
}; 
//! Private Method emxUIPortalRow.setHeight()
//!     This method sets the height of the portal row. This
//!     must be used before the portal is initialized.
emxUIPortalRow.prototype.setHeight = function _emxUIPortalRow_setHeight(intHeight) {
       this.height = intHeight;
}; 
//! Class emxUIPortalContainer
//!     This class represents a container on the portal page.
function emxUIPortalContainer() { 
        this.superclass = emxUIObject;
        this.superclass();
        delete this.superclass;
        this.channels = new Array;                      
        this.element = null;                            
        this.channelName = null;
        this.elementID = null;                          
        this.emxClassName = "emxUIPortalContainer";     
        this.portal = null;                             
        this.verticalGroup;
        this.portalName;
        this.drawContainer = true;
} 
emxUIPortalContainer.prototype = new emxUIObject;
//! Private Method emxUIPortalContainer.addChannel()
//!     This method adds a channel to the container.
emxUIPortalContainer.prototype.addChannel = function _emxUIPortalContainer_addChannel(objChannel) {
        if (!(objChannel instanceof emxUISimpleChannel)) {
                emxUICore.throwError("Required parameter objChannel is null or not of type emxUISimpleChannel. (emxUIPortalContainer.prototype.addChannel)");
        } 
        objChannel.index = this.channels.length;
		objChannel.channelIndex = this.channels.length;
        objChannel.container = this;
        this.channels.push(objChannel);
        return objChannel;
}; 
//! Private Method emxUIPortalContainer.buildDOM()
//!     This method builds the DOM representation of the container.
emxUIPortalContainer.prototype.buildDOM = function _emxUIPortalContainer_buildDOM() {
        this.element.appendChild(this.channels[0].getDOM());
        this.channels[0].element.style.height = this.element.style.height;

}; 




//! Private Method emxUIPortalContainer.init()
//!     This method initializes the portal control.
emxUIPortalContainer.prototype.init = function _emxUIPortalContainer_init() {
        this.element = document.getElementById(this.elementID);
        if (!this.element) {
                emxUICore.throwError("Container element \'" + this.elementID + "\' not found. (emxUIPortalContainer.prototype.init)");
        } else if (this.element.style.height.length == 0) {
                emxUICore.throwError("Container element \'" + this.elementID +"\' must have a height specified such as style=\"height: 220px\". (emxUIPortalContainer.prototype.init)");
        } else if (this.channels.length == 0) {
                emxUICore.throwError("Container must contain one channel. (emxUIPortalContainer.prototype.init)");
        } 
        this.channels[0].init();
        this.buildDOM();               
        var objThis = this;

}; 
//! Class emxUITabbedPortalContainer
//!     This class represents a container on the portal page.
function emxUITabbedPortalContainer(channelName) { 
        this.superclass = emxUIPortalContainer;
        this.superclass();
        delete this.superclass;
        this.emxClassName = "emxUITabbedPortalContainer";     
        this.channelName = channelName;  
        this.tabset = new emxUIPortalTabset;            
} 
emxUITabbedPortalContainer.prototype = new emxUIPortalContainer;
//! Private Method emxUITabbedPortalContainer.buildDOM()
//!     This method builds the DOM representation of the container.
emxUITabbedPortalContainer.prototype.buildDOM = function _emxUITabbedPortalContainer_buildDOM() {
        this.tabset.container = this.element;
        var maxlength = this.element.clientWidth - 60;
        var availablelength = maxlength;  
        //create a Dummy Div
        var xDiv = document.createElement("div");
        xDiv.style.visibility ="hidden";
        var objTable = document.createElement("table");
        xDiv.appendChild(objTable);
        var objTBody = document.createElement("tbody");
        objTable.appendChild(objTBody);
        var objTR = document.createElement("tr");
        objTBody.appendChild(objTR);
        document.body.appendChild(xDiv);
        var tabsetWidth = 0;
        var overflow = false;
        for (var i=0; i < this.channels.length; i++) {
        	if(!overflow){
        		var newTab = new emxUIPortalTab(this.channels[i]);
                var objTab = this.tabset.addTab(newTab);
                objTR.appendChild(this.tabset.tabs[i].getDOM());
                tabsetWidth = jQuery(objTR).width();
                if(availablelength < tabsetWidth ){
                	overflow = true;
					newTab.isMenuCommand = true;
                	var objItem = this.tabset.menu.addItem(new emxUIPortalTabItem(this.channels[i]));
                }
            } else {
				var newTab = new emxUIPortalTab(this.channels[i]);
				newTab.isMenuCommand = true;
				this.tabset.addTab(newTab);
                var objItem = this.tabset.menu.addItem(new emxUIPortalTabItem(this.channels[i]));
				objItem.channelIndex = this.tabset.tabs.length;
            } 
        } 
        if(this.tabset.tabs.length <= 0){
        	this.tabset.addTab(new emxUIPortalTab(this.channels[0]));
        }
      //Destroy the dummy div
        document.body.removeChild(xDiv);
        while(xDiv.hasChildNodes()){
			if(xDiv.firstChild){
				xDiv.removeChild(xDiv.firstChild);
			}
        }
        xDiv.innerhtml = "";
        xDiv = null;
        
        this.element.appendChild(this.tabset.getDOM());
        this.tabset.element.className = "pv-channel-tabs";
        this.tabset.element.id = "pvChannelTabs";
        for (var i=0; i < this.channels.length; i++) {        
                this.element.appendChild(this.channels[i].getDOM());
//				alert((parseInt(this.element.style.height) - this.tabset.element.offsetHeight) + "px" + "; " + (this.element.clientWidth - this.tabset.element.offsetHeight).toFixed() + "px");
//                this.channels[i].element.style.height = (parseInt(this.element.style.height) - this.tabset.element.offsetHeight) + "px";
//				this.channels[i].element.style.height = (this.element.clientHeight - this.tabset.element.offsetHeight).toFixed() + "px";
                this.channels[i].element.style.display = "none";

        } 
		
        var objImgProgress = document.createElement("div");
        objImgProgress.className = "progress-image";
        objImgProgress.id = "imgProgressDivChannel";
        objImgProgress.style.visibility = "hidden";
		
		var loadingTextDiv = document.createElement("div");
		loadingTextDiv.id="txtProgressDivChannel";
		var loadingText = document.createTextNode(emxUIConstants.STR_LOADING);
		loadingTextDiv.appendChild(loadingText);
		
		objImgProgress.appendChild(loadingTextDiv);
		
        this.tabset.element.appendChild(objImgProgress);
		
		var objBtnDom = document.createElement("div");
		if(uiAutomation == "true"){
			var channalID = this.elementID;
			var buttonID = "btn-maximize" + channalID.substr(12,channalID.length);
			objBtnDom.setAttribute("data-aid",buttonID);
		}
		objBtnDom.className = "window-size btn-maximize";
		this.tabset.element.appendChild(objBtnDom);

        if(this.channels.length == 1 && this.channels[0].tabName =="emxDummyTab"){
        	this.element.style.display = "none";
        }else{
        	this.element.style.display = "";
        }
        this.tabset.init();
}; 
//! Private Method emxUITabbedPortalContainer.init()
//!     This method initializes the portal control.
emxUITabbedPortalContainer.prototype.init = function _emxUITabbedPortalContainer_init() {
        this.element = document.getElementById(this.elementID);
        if(uiAutomation == "true"){
        	this.element.setAttribute("data-aid",this.channelName);
        }
        if (!this.element) {
                emxUICore.throwError("Container element \'" + this.elementID + "\' not found. (emxUITabbedPortalContainer.prototype.init)");
        } else if (this.channels.length == 0) {
                emxUICore.throwError("Container must contain one channel. (emxUIPortalContainer.prototype.init)");
        } 
        for (var i=0; i < this.channels.length; i++) {
                this.channels[i].init();
        } 
        this.buildDOM();               
        var objThis = this;

}; 
//! Class emxUISimpleChannel
//!     This class represents a channel on the portal page.
function emxUISimpleChannel(strText, strID) { 
        this.superclass = emxUIObject;
        this.superclass();
        delete this.superclass;
        this.container = null;                          
        this.data = null;                               
        this.dataID = strID;                            
        this.element = null;                            
        this.emxClassName = "emxUISimpleChannel";       
        this.index = -1;                                
		this.channelIndex = -1; 
        this.text = strText;                            
} 
emxUISimpleChannel.prototype = new emxUIObject;
//! Private Method emxUISimpleChannel.getDOM()
//!     This method returns the channel in DOM form.
emxUISimpleChannel.prototype.getDOM = function _emxUISimpleChannel_getDOM() {
        this.element = document.createElement("div");
        this.element.className = "pv-channel simple";
        this.element.appendChild(this.data);
        return this.element;
}; 



//! Private Method emxUISimpleChannel.init()
//!     This method returns the channel in DOM form.
emxUISimpleChannel.prototype.init = function _emxUISimpleChannel_init() {
        this.data = document.getElementById(this.dataID);
        if (!this.data) {
                emxUICore.throwError("No element with ID \'" + this.dataID + "\' was found on the page. (emxUISimpleChannel.prototype.init)");
        } 
        var objThis = this;

}; 
//! Class emxUIComplexChannel
//!     This class represents a channel on the portal page.
function emxUIComplexChannel(strDisplayText, strFullText, strURL, strCategoryID,strTabName) { 
        this.superclass = emxUISimpleChannel;
        this.superclass(strDisplayText);
        delete this.superclass;
        this.categoryID = strCategoryID;                
        this.dataID = emxUICore.getUniqueID();          
        this.emxClassName = "emxUIComplexChannel";      
        this.fulltext 	  = strFullText.htmlDecode();
        this.url = strURL;
        //added for bug 346636
        this.tabName = strTabName;
} 
emxUIComplexChannel.prototype = new emxUISimpleChannel;
//! Private Method emxUIComplexChannel.getDOM()
//!     This method returns the channel in DOM form.
emxUIComplexChannel.prototype.getDOM = function _emxUIComplexChannel_getDOM() {
		this.data = null;
		if(isIE && isMaxIE8){
	    	this.data = document.createElement('<iframe name="'+this.tabName+'">');
	    }else{
	    	this.data = document.createElement('iframe');
	    	this.data.name = this.tabName;
	    }
        this.data.src = "about:blank";
        this.data.allowTransparency = true;
        this.data.frameBorder = 0;
        this.data.border = 0;
        this.data.width = "100%";
        this.element = document.createElement("div");
/*
	     * Code modified for PowerView Enhancement Feature.
         * The getDOM method is modified to have a DIV,Classname[stylesheet-emxUIPortal.css],display style for every iframe.
         * The default display style for DIV is 'none'	
		 * 16 Aug 2007
		 */      
        this.tabdiv = document.createElement("div");
        this.tabdiv.className = "tab-header";  
        this.tabdiv.style.display = 'none';       
        this.element.className = "pv-channel-content";
        this.element.appendChild(this.tabdiv);
        this.element.appendChild(this.data);
        return this.element;
}; 


//! Private Method emxUIComplexChannel.init()
//!     This method returns the channel in DOM form.
emxUIComplexChannel.prototype.init = function _emxUIComplexChannel_init() {
        var objThis = this;

}; 
//! Class emxUIPortalTabset
//!     This class represents a tabset. A tabset can be placed anywhere
//!     on a page by specifying its container.
function emxUIPortalTabset() { 
        this.superclass = emxUITabset;
        this.superclass();
        delete this.superclass;
        this.emxClassName = "emxUIPortalTabset";
        this.menu = new emxUIPortalTabMenu(this);       
} 
emxUIPortalTabset.prototype = new emxUITabset;
//! Public Method emxUIPortalTabset.getDOM()
//!     This method gets the DOM representation of the tabset.
emxUIPortalTabset.prototype.getDOM = function _emxUIPortalTabset_getDOM() {
        this.element = document.createElement("div");
        this.element.className = "pv-channel-tabs";
        var objTable = document.createElement("table");
        objTable.cellPadding = 0;
        objTable.cellSpacing = 0;
        objTable.border = 0;		
        this.element.appendChild(objTable);
        var objTBody = document.createElement("tbody");
        objTable.appendChild(objTBody);
        var objTR = document.createElement("tr");
        objTBody.appendChild(objTR);
        var objThis = this;
        for (var i=0; i < this.tabs.length; i++) {
			if(!this.tabs[i].isMenuCommand){
                objTR.appendChild(this.tabs[i].getDOM());
        } 
        } 
        this.button = document.createElement("td");
        this.button.className = "tabset-button";
        this.button.style.visibility = "hidden";
        this.button.innerHTML = "<img src=\"" + emxUIPortal.IMG_TABSET_ARROW + "\" border=\"0\" />";
        objTR.appendChild(this.button);
        return this.element; 
}; 
//! Private Method emxUIPortalTabset.hideButton()
//!     This function hides the button on the tabset.
emxUIPortalTabset.prototype.hideButton = function _emxUIPortalTabset_hideButton() {
        emxUICore.hide(this.button);
}; 
//! Protected Method emxUIPortalTabset.init()
//!     This function gathers the required information for the
//!     tabset object.
emxUIPortalTabset.prototype.init = function _emxUIPortalTabset_init() {
	
		var reloadSB = arguments.length == 1 ? arguments[0] : true ;
        for (var i=0; i < this.tabs.length; i++) {
                if (this.selectedID == i) {
                        this.tabs[i].bringToFront(reloadSB);
                } else {
					if(this.tabs[i].isMenuCommand == false){
                        this.tabs[i].sendToBack();
                } 
        } 
        } 
        var matchFound = false;
        if(this.lastTab != null){
	        for (var i=0; i < this.tabs.length; i++) {
	        	if(this.tabs[i].tabName == this.lastTab.tabName){
	        		this.selectedID = i;
		        	this.tabs[i].bringToFront(reloadSB);
		        	matchFound = true;
		        } else if(this.tabs[i].isMenuCommand == false){
		            this.tabs[i].sendToBack();
		        }
	        }
	        if(!matchFound){
	        	this.selectedID = 0;
		        this.tabs[0].bringToFront(reloadSB);
	        }
        }
        if (this.menu.items.length > 0) {
                this.menu.init();
                this.showButton();
                var objThis = this;
                this.button.onclick = function () {
                        objThis.menu.show(this, "channel-overflow");
                }
                if(isIE){
	                window.addEventListener("unload", function(){
	                	objThis.button.onclick = null;
	                	objThis = null;
	                }, false);                
                }

                
        } 
}; 
//! Private Method emxUIPortalTabset.showButton()
//!     This function shows the button on the tabset.
emxUIPortalTabset.prototype.showButton = function _emxUIPortalTabset_showButton() {
        emxUICore.show(this.button);
}; 
//! Class emxUIPortalTab
//!     This class represents a tab on the tab set.
function emxUIPortalTab(objChannel) {
        this.superclass = emxUITab;
        this.superclass(objChannel.text);
        delete this.superclass;
        this.channel = objChannel;                              
        this.emxClassName = "emxUIPortalTab";                   
        this.fulltext = objChannel.fulltext;                    
        this.tabName = objChannel.tabName;
		this.isMenuCommand = false;
} 
emxUIPortalTab.prototype = new emxUITab;
//! Private Method emxUIPortalTab.bringToFront()
//!     This method brings the tab to the front of the other tabs.
emxUIPortalTab.prototype.bringToFront = function _emxUIPortalTab_bringToFront() {
        try{
            emxUICore.iterateFrames(function (objFrame) { objFrame.noListSubmission = false; }
                           , this.channel.element.getElementsByTagName("IFRAME")[0].contentWindow);  
        }catch(e){}
        this.element.className = "tab-active";
        this.channel.element.style.display = "";
        var blnFirstTime = false;
        
        /*
         * Bug: Some versions of Mozilla change a URL in the window from having a
         *      relative path to an absolute path, making the comparison between the 
         *      stored and actual URLs always return false. This causes the error and
         *      an infinite loop, which causes the Powerview to display incorrectly and
         *      freeze.282795 
         * Fix: Only test the file portion of the URL, not the full path.
         * MxMx: Bug 282795 0
         * (NCZ, 1-Mar-04)
         */
        var strChannelDataSrc = this.channel.data.src || "";
        strChannelDataSrc = strChannelDataSrc.substring(strChannelDataSrc.lastIndexOf("/") + 1);
        var strChannelURL = this.channel.url;
        strChannelURL = strChannelURL.substring(strChannelURL.lastIndexOf("/")+1);
        
		var reloadSB = (arguments.length == 1 && arguments[0] === false) ? arguments[0] : true ;
		
        if (reloadSB && this.channel instanceof emxUIComplexChannel && strChannelDataSrc != strChannelURL) {
                this.channel.data.src = this.channel.url;
                this.channel.url = this.channel.data.src;
                blnFirstTime=true;
        }
        
        //
        // Code to enable/disable cache
        //
        // For the first time, the page will be loaded freshly. For the next subsequent times we will consider the 
        // emxUIPortal.ENABLE_CACHE flag.
        if (!blnFirstTime && reloadSB) {
        	if (!emxUIPortal.ENABLE_CACHE) {
        		this.channel.data.src = this.channel.url;
        	}	
        }
 

	//to handle the resize when we switch between tabs
	if (isMaxIE8){
		if(isMaximised === false){
			jQuery('.pv-row').resize(function () {
				jQuery(">*", this).each(function () {
					jQuery(this).css("height", this.parentNode.clientHeight + "px");
				});
			}).trigger('resize');
		}else{
			// to handle the  chanel and iframe during maximise
			jQuery('.pv-container').css("overflow-y", "hidden");
			jQuery('.pv-row').resize(function () {
				jQuery(">*", this).each(function () {
					jQuery(this).css("height", "100%");
				});
			}).trigger('resize');
		}	
	}
	//to handle the resize when we switch between tabs
	this.isMenuCommand = false;
       
};  
//! Private Method emxUIPortalTab.getDOM()
//!     This method creates the DOM representation of the tab.
emxUIPortalTab.prototype.getDOM = function _emxUIPortalTab_getDOM() {
        this.element = document.createElement("td");
        if(uiAutomation == "true"){
        	this.element.setAttribute("data-aid",this.tabName);
        }
        this.element.className = "tab-inactive";
        addEvent(this.element, "selectstart", cancelEvent);
        this.element.style.MozUserSelect = "none";
        addEvent(this.element, "contextmenu", cancelEvent);
        var objThis = this;
        addEvent(this.element, "click", function () { objThis.click(); });
        this.refresh();
        return this.element;
}; 
//! Private Method emxUIPortalTab.refresh()
//!     This method refreshes the view of the tab.
emxUIPortalTab.prototype.refresh = function _emxUIPortalTab_refresh() {
        this.element.title = this.channel.fulltext;
        this.element.innerHTML = "<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td class=\"text\" nowrap=\"nowrap\">" + this.channel.text + "</td><td class=\"corner\"><img src=\"" + IMG_SPACER + "\" width=\"16\" height=\"1\" /></td></tr></table>";
}; 
//! Private Method emxUIPortalTab.sendToBack()
//!     This method sends the tab to the back of the other tabs.
emxUIPortalTab.prototype.sendToBack = function _emxUIPortalTab_sendToBack() {
        this.channel.element.style.display = "none";
		this.channel.data.src ="";
        try{
            emxUICore.iterateFrames(function (objFrame) { objFrame.noListSubmission = true; }
                             , this.channel.element.getElementsByTagName("IFRAME")[0].contentWindow);  
        }catch(e){}
        this.element.className = "tab-inactive";
}; 
//! Class emxUIPortalTabItem
//!     This object represents an actionbar item.
function emxUIPortalTabItem(objChannel) {
        this.superclass = emxUICoreMenuLink;
		//! Modified for Bug No 323209 Dated 6/21/2007 Begin
        this.superclass(null,objChannel.text, objChannel.url,null);
		//! Modified for Bug No 323209 Dated 6/21/2007 Ends
        delete this.superclass;
        this.channel = objChannel;                              
        this.element = null;                                    
        this.text = objChannel.text;                            
        this.url = objChannel.url;                              
} 
emxUIPortalTabItem.prototype = new emxUICoreMenuLink;
//! Private Method emxUIPortalTabItem.click()
//!     This method simulates a click on the link.
emxUIPortalTabItem.prototype.click = function _emxUIPortalTabItem_click() {
	 if(isIE && !this.parent.visible){
        this.parent.layer.style.display = "none";
     }
     this.parent.hide();
     var currentChannel = this.parent.tabset.selectedID;
	 var selectedChannel = this.channel.index;
	 
	 
	 var curTab = this.parent.tabset.tabs[currentChannel];
	 curTab.channel.element.style.display = "none";
	 
	 var tabChannel = this.parent.tabset.tabs[currentChannel].channel;
	 
	 //Start: Code to swap the Tabset elements 
	 this.parent.tabset.tabs[currentChannel] = this.parent.tabset.tabs[selectedChannel];
	 this.parent.tabset.tabs[currentChannel].channelIndex = this.parent.tabset.selectedID; //this.parent.tabset.tabs[selectedChannel].channelIndex;
	 this.parent.tabset.tabs[currentChannel].index = this.parent.tabset.selectedID ; //this.parent.tabset.tabs[selectedChannel].index;
	 this.parent.tabset.tabs[currentChannel].isMenuCommand = false;
	 this.parent.tabset.tabs[currentChannel].channel = this.parent.tabset.tabs[selectedChannel].channel;
	  
	 
	 this.parent.tabset.tabs[selectedChannel] = curTab;
	 this.parent.tabset.tabs[selectedChannel].channelIndex = selectedChannel;
	 this.parent.tabset.tabs[selectedChannel].index = selectedChannel;
	 this.parent.tabset.tabs[selectedChannel].isMenuCommand = true;
	 this.parent.tabset.tabs[selectedChannel].channel = tabChannel;
	 //Start: Code to swap the Tabset elements 
	 
	 this.parent.tabset.lastTab = this.parent.tabset.tabs[currentChannel];
	 this.channel.data.src = this.channel.url;
 
	 //to chang the order of the menu items
	 curTab.channel.index = this.channel.index;
	 this.parent.tabset.menu.items[this.index] = new emxUIPortalTabItem(curTab.channel);
	 this.parent.tabset.menu.items[this.index].parent = this.parent.tabset.menu;
	 this.parent.tabset.menu.items[this.index].index = this.index;
	 
	 redrawTabsetItems();	 
}; 
//! Private Method emxUIPortalTabItem.refresh()
//!     This method refreshes the view of the menu link to represent
//!     the channel it
emxUIPortalTabItem.prototype.refresh = function _emxUIPortalTabItem_refresh() {
	if(this.rowElement.firstChild && this.rowElement.firstChild.lastChild){
		try{
        	this.rowElement.firstChild.lastChild.innerHTML = this.channel.text;
        	this.rowElement.firstChild.lastChild.title = this.channel.fulltext;
		}
		catch(e){
			
		}
	}
}; 
//! Class emxUIPortalTabMenu
//!     This object represents an actionbar as a pop up menu.
function emxUIPortalTabMenu(objTabset) {
        this.superclass = emxUICorePopupMenu;
        this.superclass();
        delete this.superclass;
        this.cssClass = "tabset";                               
        this.emxClassName = "emxUIPortalTabMenu";               
        this.stylesheet = emxUICore.getStyleSheet("emxUIPortal");
        this.tabset = objTabset;                                
} 
emxUIPortalTabMenu.prototype = new emxUICorePopupMenu;

function getChannelTab(displayText,fullText,href,strCategoryID,tabName,isIndentedTable) {
	if(isIndentedTable == 'true' && parent.emxUIComplexChannel){
		return  new parent.emxUIComplexChannel(displayText,fullText,href,strCategoryID,tabName);
	}else if(parent.parent.emxUIComplexChannel){
		return  new parent.parent.emxUIComplexChannel(displayText,fullText,href,strCategoryID,tabName);
	}
};



// The following code deals with dynamic sizing.  It uses
// jquery, plus a JQuery splitter plugin (heavily customized).
// That plugin knows nothing about channels, maximize, restore.
// It's only able to do an n-way horizontal or vertical split.
// More complex layouts are achieved with nested splitters:
//  - a single H splitter for the entire portal, to split the rows
//  - a V splitter for each row, to split channels within a row
// Maximize/restore is handled here, not in splitter.
//
// JQuery based code is purposely segregated from rest of code.
// Older, emxUICore based code is largely untouched, save for the
// emxUIPortal.buildDOM, and the removal of ome obsolete resize 
// event handling.

$(document).ready(function () {
    objPortal.init();
    objPortal.controller = new PortalController();
    objPortal.controller.init(objPortal);
	objPortal.PortalChannelController = new PortalChannelController();
	registerEvents();
	turnOffProgress();
});


function registerEvents(){	
	jQuery(window).resize(function (event) {				
				redrawTabsetItems();
	});	
}
		
function redrawTabsetItems(){							
		
	for(var l = 0; l < objRow.portal.rows.length; l++){	
		var xDiv = document.createElement("div");
		xDiv.style.visibility ="hidden";
		var objTable = document.createElement("table");
		xDiv.appendChild(objTable);
		var objTBody = document.createElement("tbody");
		objTable.appendChild(objTBody);
		var objTR = document.createElement("tr");
		objTBody.appendChild(objTR);
		document.body.appendChild(xDiv);			
	
		for(var ll = 0; ll < objRow.portal.rows[l].containers.length; ll++){						
		
			var channelWidth = jQuery(objRow.portal.rows[l].containers[ll].element).width() - 60 ;							
			var tabset1 = objRow.portal.rows[l].containers[ll].tabset;
			var lastIndex = 0; 
			var adjustMenuOrder = true;
			var i=0;
			var drawMenuItems = false;
			for ( i=0; i < tabset1.tabs.length; i++) {						
				objTR.appendChild(tabset1.tabs[i].getDOM());
				var channelWidth1 = jQuery(objTR).width();										
				if(channelWidth > channelWidth1){									
					if( tabset1.tabs[i].isMenuCommand == true){
						var newTab = new emxUIPortalTab(tabset1.tabs[i].channel);										
						tabset1.tabs[i] = newTab;
						tabset1.tabs[i].parent = tabset1;
						tabset1.tabs[i].channelIndex = i;
						tabset1.tabs[i].isMenuCommand = false;						
					}
					lastIndex = i;				
				} else {
					drawMenuItems = true;
					break;
				}								
			}
			tabset1.menu.items =[];						
			if(drawMenuItems){
				var j = i;				
				for ( ; j < tabset1.tabs.length; j++) {

					if(tabset1.selectedID == j){
						var activeTab = tabset1.tabs[j];
						tabset1.tabs[j] = tabset1.tabs[lastIndex];
						tabset1.tabs[j].index = j;
						tabset1.tabs[j].channel.index = j;
						tabset1.tabs[lastIndex] = activeTab;
						tabset1.tabs[lastIndex].isMenuCommand = false;
						tabset1.tabs[lastIndex].index = lastIndex;
						tabset1.tabs[lastIndex].channel.index = lastIndex;
					} 						

					tabset1.menu.addItem(new emxUIPortalTabItem(tabset1.tabs[j].channel));// removed tabset1.tabs[i].channel
					tabset1.tabs[j].isMenuCommand = true;										

				}					
		}

			var channelId =  objRow.portal.rows[l].containers[ll].elementID;
			var objCol = jQuery("#"+channelId).filter(".pv-channel.complex"); // moved to start of this Method			

			objCol.children().first("div").remove();
			objCol.prepend(tabset1.getDOM());

             for(var sel = 0; sel < tabset1.tabs.length; sel++ ){ 
                 if(tabset1.lastTab && tabset1.lastTab.tabName == tabset1.tabs[sel].tabName){
                     tabset1.selectedID = sel;
                     break;
                 } 
            }
			tabset1.init(false);				

			var objImgProgress = document.createElement("div");
			objImgProgress.className = "progress-image";
			objImgProgress.id = "imgProgressDivChannel";
			objImgProgress.style.visibility = "hidden";
			
			var loadingTextDiv = document.createElement("div");
			loadingTextDiv.id="txtProgressDivChannel";
			var loadingText = document.createTextNode(emxUIConstants.STR_LOADING);
			loadingTextDiv.appendChild(loadingText);
		
			objImgProgress.appendChild(loadingTextDiv);
			
			tabset1.element.appendChild(objImgProgress);	


			var objBtnDom = document.createElement("div");
			if(uiAutomation == "true"){
				var channalID = this.elementID;
				var buttonID = "btn-maximize" + channalID.substr(12,channalID.length);
				objBtnDom.setAttribute("data-aid",buttonID);
	}
			objBtnDom.className = "window-size btn-maximize";
			tabset1.element.appendChild(objBtnDom);	

			if(tabset1.tabs.length == 1 && tabset1.tabs[0].tabName =="emxDummyTab"){
				tabset1.element.style.display = "none";
			}else{
				tabset1.element.style.display = "";
			}
			if (jQuery(".pv-channel").size() == 1) {
				jQuery(".window-size").hide();
			}		

			while( xDiv.hasChildNodes()){
				if(xDiv.firstChild){
					xDiv.removeChild(xDiv.firstChild);
				}
			}
		}				
	}				
	xDiv.innerhtml = "";
	xDiv = null;		
	objPortal.PortalChannelController.init(objPortal);	
}
		
PortalController = function () {
	// PRIVATE

	// To enable experimental overflow-y mode, set this to false.
	// In that mode, if > 2 rows, then entire portal becomes scrollable
	// This is partially implemented and needs work.
	var _ALWAYS_FIT = true;
	var _restore;
	var _mask;
	var _splitters = $(); // track all splitter widgets for purposes of pause/resume
	var _objPortal;

	/*
	 * This function records the current channel style settings into _restore object;
	 * then it animates the channel to maximized state
	 */
	function maximize(chan) {
		$(".window-size").toggleClass("btn-maximize btn-minimize");
		// Disable splitters for now to prevent them from interfering
		// with channel sizing while channel is maximized
		_splitters.splitter('pause');
		
//		if (isIE) {
//				pvContainerOverFlowStyle= jQuery('.pv-container').css("overflow-y");
//				jQuery('.pv-container').css("overflow-y", "hidden");
//				jQuery('.pv-row').resize(function () {
//                    jQuery(">*", this).each(function () {
//                    	jQuery(this).css("height", this.parentNode.clientHeight + "px");
//                        if (isMaxIE7) {
//                        	var iFrameHeight = document.getElementById("divPowerView").offsetHeight - document.getElementById("pvChannelTabs").offsetHeight + "px";
//                        	jQuery('.pv-channel-content').css("height",iFrameHeight);
//                        	// furthermore IE7 does not honor iframe height=100% at all, so...
//                            jQuery("iframe", this).each(function () {
//                            	
//                               jQuery(this).css("height", "100%");
//                            });
//                        }
//                        //alert(this.className + ".height=" + jQuery(this).css("height"));
//                    });
//                }).trigger('resize');
//            }
		

		// Compute entire powerview's offets and dimensions;
		// maximized channel will fill this entire space
		var pvOffset = jQuery('#divPowerView').offset();
		var pvBox = {
			top: jQuery('#divPowerView').offset().top + "px",
			left:jQuery('#divPowerView').offset().left + "px",
			right:"0px", //TODO
			bottom: "0px" // TODO
		};

		// Compute channels current size and offsets;
		// these will be animated during maximize and restore
		var chanOffset = jQuery(chan).offset();
		var chanBox = {
			top: chanOffset.top + "px",
			left: chanOffset.left - pvOffset.left + "px",
			right: jQuery('#divPowerView').width() + pvOffset.left - chanOffset.left - jQuery(chan).width()+ "px",
			bottom: jQuery('#divPowerView').height() + pvOffset.top - chanOffset.top - jQuery(chan).height() + "px"
		}

		// Record all current settings of the channel, for later restoration
		_restore = {
			box: chanBox,
			style: chan.style.cssText,
			//temp hack:avoiding window resize method for maximise and minimise button
			//this fails when the window is resized after the channel is maximised 
			winHeight:jQuery(window).height(),
			winWidth :jQuery(window).width()

		};

		// slightly gray out all other channels by overlaying a mask on them
		_mask = jQuery('<div class="mask"></div>')
			.css("width","100%")
			.css("height","100%")
			.css("position","absolute")
			.css("top","0px")
			.css("left", "0px")
			.css("background", "black")
			.css("opacity", "0.25");
		jQuery('#divPowerView').append(_mask[0]);

		// convert channel sizing parameters to fixed t,l,r,b and auto w,h
		// animation will manipulate t,l,r,b
		jQuery(chan).css("position", "fixed")
			.css("top", chanBox.top)
			.css("left", chanBox.left)
			.css("right", chanBox.right)
			.css("bottom", chanBox.bottom)
			.css("width", "auto")
			.css("height", "auto")
			.css("z-index", "10")
			.toggleClass("float")
			;

		// animate channel to size of pv
		jQuery(chan).animate(pvBox, 'fast', function() {
			jQuery(chan).toggleClass("float");
		});
		isMaximised=true;
		// fire the click event on the SB to update filters
		jQuery('body', jQuery('.pv-channel-content:visible iframe', chan).contents().get(0)).trigger("click");
		$(".hide-pv-col-button").hide();
	}

	/*
	 * This function animates channel back down to normal, unmaximized state.
	 * After animation, it restores all styles for the channel back to their
	 * values prior to being maxized.
	 */
	function restore(chan) {
		jQuery(".window-size").toggleClass("btn-maximize btn-minimize");
		//if(!isMaximised){
		//	return;
		//}
//		if (isIE) {
//				jQuery('.pv-container').css("overflow-y", pvContainerOverFlowStyle);
//				jQuery('.pv-row').resize(function () {
//                    jQuery(">*", this).each(function () {
//                    	jQuery(this).css("height", this.parentNode.clientHeight + "px");
//                        if (isMaxIE7) {
//                        	jQuery('.pv-channel-content').css("height","auto");
//                        	// furthermore IE7 does not honor iframe height=100% at all, so...
//                            jQuery("iframe", this).each(function () {
//                            	var off = jQuery(this).position().top;
//                            	jQuery(this).css("height", (this.parentNode.clientHeight - off) + "px");
//                            });
//                        }
//                    });
//                }).trigger('resize');
//            }

		
		jQuery(chan).toggleClass("float");
		// animate channel back to its old box
		jQuery(chan).animate(_restore.box, 'fast', function () {
			// this block runs after animation ends
			jQuery(chan).toggleClass("float");
			_mask.remove();

			// restore styles back to their normal values
			chan.style.cssText = _restore.style;

			// resume normal splitter functioning
			_splitters.splitter('resume');

			// in case window was resized while splitters paused
			var oldWinHeight=_restore.winHeight;
			var oldWinWidth= _restore.winWidth;
			//if(oldWinHeight != jQuery(window).height() && oldWinWidth != jQuery(window).width()){
			setTimeout(function() { jQuery(window).trigger("resize"); }, 100);
			//}
		});
		isMaximised=false;
		$(".hide-pv-col-button").show();
	}

	function updateLSValue(channelID,calcValue) {
    	var channelMap = JSON.parse(localStorage.getItem("ls-"+PORTALNAME));
    	var lsVal = channelMap[channelID];
    	if(lsVal==null){
    		channelMap[channelID]=calcValue;
    		lsVal = calcValue;
    	}
    	return lsVal;
	}
	
    return { // PUBLIC
	
        init: function(objPortal) {
			var SELF = this;
            // each pv-container (representing the entire Portal) will become an H splitter
						
			jQuery(".pv-row").each(function () {
				var colLength = jQuery(".pv-col", this).size();
				if(colLength > 1){
				if(colLength > 2){
						var lastColRef = jQuery(".pv-col:last",this).find(".pv-channel:first");
						var title = lastColRef.find(".tab-active").attr("title");
						var colHideButton = jQuery("<div class='hide-pv-col-button hidden' id='col-"+title+"'><button class='hide-pv-col' id='hide-pv-col-button'></button></div>");
						colHideButton.insertBefore($(".window-size.btn-maximize:last",lastColRef));
					}				
				}else{
					if(jQuery(".pv-channel", this).size()>2){
						var title = $(".pv-channel:last",this).find(".tab-active").attr("title");
						var colHideButton = jQuery("<div class='hide-pv-col-button hidden' id='col-"+title+"'><button class='hide-pv-col' id='hide-pv-col-button'></button></div>");
						colHideButton.insertBefore($(".window-size.btn-maximize:last",this));
					
				}				
				}				
				
			});
				
			
            jQuery(".pv-container").each(function () {
            	var rowData = jQuery(".pv-row", this);
                var numRows = rowData.size();
				rowData.each(function () {                	
                	if(numRows>1 && jQuery(".pv-col", this).not(".pv-col.closed-cols").size()>0){                		
                		jQuery(this).css("height", updateLSValue(jQuery(this).attr("id"), (jQuery(".pv-container").height()/numRows)+"px"));
                	}
                });
                if (numRows > 1) { // but only if it has more than one row
                    jQuery(this).splitter({
                        splitHorizontal: true,
                        fit: _ALWAYS_FIT || numRows <= 2 // fit vs. overflow
                    });
                    _splitters = _splitters.add(this);
                } else { // Single row (possibly multiple channels, but all in one row)
                    // Since not using an H splitter, need to handle sizing manually
					
                	var ht = jQuery(this).attr("minsize") ? jQuery(this).attr("minsize") : 0;
                    ht = Math.max(ht, jQuery(this).height());
                    $(".pv-container").css("overflow-y","hidden");
                    if(jQuery(".pv-col").size()>0){
                    	ht = ht - 2;
                    	rowData.css("height",ht + "px");						
						jQuery(window).resize(function () {
	                	var ht1 = jQuery(".pv-container").attr("minsize") ? jQuery(".pv-container").attr("minsize") : 0;
	                    ht1 = Math.max(ht1, jQuery(".pv-container").height());
	                    ht1 = ht1 -3 ;
						jQuery(".pv-row").css("height", ht1 + "px");
							jQuery(".pv-col").each(function() {
							   jQuery(this).css("height","100%");
							});
						}).resize();
                    }else{
                    ht = ht - 4;
                    	rowData.css("height",ht + "px");						
						jQuery(window).resize(function () {
	                	var ht1 = jQuery(".pv-container").attr("minsize") ? jQuery(".pv-container").attr("minsize") : 0;
	                    ht1 = Math.max(ht1, jQuery(".pv-container").height());
	                    ht1 = ht1 - 4;
						jQuery(".pv-row").css("height", ht1 + "px");
							jQuery(".pv-channel").each(function() {
							   jQuery(this).css("height","100%");
							});
						}).resize();	
                    	
                    }	
                }

                if (!_ALWAYS_FIT) { // EXPERIMENTAL, not finished
                    // If there are more than two rows, make entire portal scrollable
                    if (numRows > 2) {
                        jQuery(this).splitter('pause'); // avoid interference from splitter evt handling
                        jQuery(this).css("overflow-y", "auto"); // allow V scrollbar to appear as needed
                        // Resize each row to at least its minimum height
                        jQuery(".pv-row", this).each(function () {
                            var h = jQuery(this).attr("minsize") ? jQuery(this).attr("minsize") : 0;
                            h = Math.max(h, jQuery(this).height());
                            jQuery(this).css("height", h + "px");
                        });

                        jQuery(this).splitter('resume');
                    }
                }
            });

            // each pv-row becomes a V splitter
            jQuery(".pv-row").each(function () {
            	var colData = jQuery(".pv-col",this).not(".pv-col.closed-cols");
            	if(colData.size() >1){
            		colData.each(function () {
            		jQuery(this).css("width",jQuery(this).width()-SPLITTER_WIDTH);
            	});
            	}          	
            	
                if (jQuery(".pv-col", this).size() > 1) { // but only if it has more than one channel
                    jQuery(this).splitter({
                        splitVertical: true
                    });
                    _splitters = _splitters.add(this);
                }
            });
			
            // each pv-row becomes a V splitter
            jQuery(".pv-row").each(function () {
            	var colData = jQuery(".pv-col",this).not(".pv-col.closed-cols");
            	if(colData.size()>0){
            		colData.each(function () {
            			var channelData  = jQuery(".pv-channel", this);
                    	var noOfChannels = channelData.size();            	
                    	if(noOfChannels>0){
                    		if (noOfChannels > 1) { // but only if it has more than one channel
                    			channelData.each(function() {  
                    				jQuery(this).css("height",updateLSValue(jQuery(this).attr("id"), (($(this).parents(".pv-col").height()-SPLITTER_WIDTH)/noOfChannels)+"px"));
			});
                        		jQuery(this).splitter({
                        			splitHorizontal: true,
                                    //fit: _ALWAYS_FIT || numCols <= 2
                            });
                        		_splitters = _splitters.add(this);
                        }else{
                    			channelData.each(function() { 
                    				var parentHeight = $(this).parents(".pv-col").height();
                    				var perc = ((100 * (parentHeight-4))/parentHeight);
                        			jQuery(this).css("height",perc+"%");
                        		});	
                        	}					   
                    	}

                    }); 
            		jQuery(window).resize(function () {
            			if(jQuery(".pv-row").size()>1){
            				jQuery(".pv-col").each(function(){
                				var column = this;
                				var channels = jQuery(".pv-channel",this);
                				var noOfChannels = channels.size();
                				var channels1=0;
                				var prevChannel =0;
                				if(noOfChannels>1){
                					channels.each(function(){
                						channels1++;
                						if(channels1 == noOfChannels){
                							jQuery(this).css("height",(jQuery(column).height()-prevChannel));
                						}
                						prevChannel= prevChannel + parseInt(jQuery(this).css("height"), 10)+ SPLITTER_WIDTH;                						
							});
                        }
                    });
            }

            		});
            	}else{
            		if (jQuery(".pv-channel", this).size() > 1) { // but only if it has more than one channel
                        jQuery(this).splitter({
                            splitVertical: true
                        });
                        _splitters = _splitters.add(this);
                    }
            	}
            });
            			
			jQuery(".pv-channel").each(function() {
				SELF.sensitizeSizingControls(this);
			});

            
						
            // if there is a single channel in total, hide the maximize button
            if (jQuery(".pv-channel").size() == 1) {
                jQuery(".window-size").hide();
            }
        },
		
		/* This method was made public because there is a use case where external code */
		/* dynamically re-builds an entire channel (emxRefreshChannel.jsp) */
		sensitizeSizingControls: function(chan) {
			//alert("sensitizeSizingControls :" +isMaximised );
    		jQuery(".window-size", chan).each(function () {
    			jQuery(this).click(	
    				function () {
						if(!isMaximised){
							maximize(chan);
						}else{
							restore(chan);
						}
					}
    			);
    		});
		},
        doMaximise: function(chan) {
        	maximize(chan);
        },
		doMinimise:function(chan) {
			restore(chan);
        }
	};
};

PortalChannelController = function () {
	
    return { // PUBLIC
	
        init: function(objPortal) {
			var SELF = this;
            // each pv-container (representing the entire Portal) will become an H splitter
			           			
			jQuery(".pv-channel").each(function() {
				SELF.sensitizeSizingControls(this);
			});

            

            // if there is a single channel in total, hide the maximize button
            if (jQuery(".pv-channel").size() == 1) {
                jQuery(".window-size").hide();
            }
        },
		
		/* This method was made public because there is a use case where external code */
		/* dynamically re-builds an entire channel (emxRefreshChannel.jsp) */
		sensitizeSizingControls: function(chan) {
			//alert("sensitizeSizingControls :" +isMaximised );
    		jQuery(".window-size", chan).each(function () {
    			jQuery(this).click(	
    				function () {
						if(!isMaximised){
							objPortal.controller.doMaximise(chan);
						}else{
							objPortal.controller.doMinimise(chan);
						}
					}
    			);
    		});
		}
	};
};



