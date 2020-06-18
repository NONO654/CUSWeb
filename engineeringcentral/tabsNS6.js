//=================================================================
// JavaScript Tab Structure
// DOM-Compliant Browser Version (IE 5.5, Netscape 6.0)
// by Nicholas C. Zakas
//=================================================================

//=================================================================
// Part 1: Tab Control Object Methods
//=================================================================
// This section defines the methods that control the tab control
// and should not be modified in any way.  Doing so could cause
// the tab control to malfunction.
//=================================================================

//-----------------------------------------------------------------
// Function _jsTabControl_draw()
// This function draws the tree.
//
// Parameters:
//	d (jsDocument) - the document object to write to.
//	tab (jstab) - the tab to draw for.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTabControl_draw() {

	//calculate tabsperstrip
	this.tabsPerStrip = parseInt((window.innerWidth - IMG_BTN_MORE.width - IMG_BTN_LESS.width) / this.tabWidth);

	//calculate number of strips needed
	var numStrips = Math.ceil(this.tabs.length / this.tabsPerStrip);
	
	//draw each strip
	for (i=0; i < numStrips; i++)
		this.createStrip(0 + (this.tabsPerStrip * i), this.tabsPerStrip + (this.tabsPerStrip * i));

}

//-----------------------------------------------------------------
// Method jsTabControl.init()
// This function initializes the tab control to have the given tab
// selected.
//
// Parameters:
//	tabID (String|int) - the tab key for the tab to make selected.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTabControl_init(tabID) {

	//draw it
	this.draw();

	//get the unique tabID
	var iTabID = this.tabs[tabID].id;
	
	//set all tabs to be off
	for (i=0; i < this.tabs.length; i++)
		if (i == iTabID) {
			clickTab(i);
			var q = this.getTabStrip(iTabID);
			this.switchTo('strip' + q, 'strip0');
		} else
			this.turnTabOff(i);
}


//-----------------------------------------------------------------
// Method _jsTabControl_getTabStrip()
// This function finds which trip a given tab is on.
//
// Parameters:
//	tabID (int) - the ID of the tab to find.
// Returns:
//	The string ID of the tab to find.
//-----------------------------------------------------------------
function _jsTabControl_getTabStrip(tabID) {

	return (Math.floor(tabID / this.tabsPerStrip) ); 

}

//-----------------------------------------------------------------
// Method _jsTabControl_createStrip()
// This function draws a set number of tabs onto a jsDocument.
//
// Parameters:
//	start (int) - the index of the tab to start with.
//	stop (int) - the index of the tab to stop on.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTabControl_createStrip(start, stop) {
 
	//figure out the strip name and info
	var isPrev = (start > 0);
	var isNext = (stop < this.tabs.length);
	var strName = "strip" + this.strips.length;
	var curLeft = 0;
	
	//variables used in DOM-compliant browsers only
	var bodyNode, divStrip;

	//add the strip name to the array
	this.strips[this.strips.length] = strName;
	
	//get the body node
	bodyNode = document.getElementsByTagName("body")[0];
		
	//create the strip
	divStrip = document.createElement("div");
	
	//add it into the DOM
	bodyNode.appendChild(divStrip);
	
	//assign its ID
	divStrip.setAttribute("id", strName);
	
	//make the position absolute
	with (divStrip.style) {
		position = "absolute";
		top = isPrev ? -1000 : this.top;
		left = this.left;
		width = ((this.tabWidth * this.tabsPerStrip) + IMG_BTN_MORE.width + IMG_BTN_LESS.width) + "px";
	}
		
	//begin table
	var objTable = document.createElement("table");
	with (objTable) {
		setAttribute("border", "0");
		setAttribute("cellspacing", "0");
		setAttribute("cellpadding", "0");
	}
	
	var objTR = document.createElement("tr");
	objTable.appendChild(objTR);
	divStrip.appendChild(objTable);	
			
	//check for "less" button
	if (isPrev) {
	
		var dp = new jsDocument;

		//create cell
		var objTD = document.createElement("td");
		objTD.style.verticalAlign = "top";
			
		//add it to the first layer
		objTR.appendChild(objTD);
			
		//write arrow HTML
		dp.write("<a href=\"javascript:localTC.switchTo('");
		dp.write(this.strips[this.strips.length - 2]);
		dp.write("', '");
		dp.write(strName);
		dp.write("')\"><img src=\"");
		dp.write(IMG_BTN_LESS.filename);
		dp.write("\" border=\"0\"></a>");
		
		//now close the layer
		objTD.innerHTML = dp;
	}
	
	//Create all the tab layers
	for (var i=start; i < this.tabs.length && i < stop; i++) {
		//create cell
		var objTD = document.createElement("td");
		objTR.appendChild(objTD);
		this.drawTab(this.tabs[i], objTD);
	} 

	//check for "more" button
	if (isNext) {
	
		//new string buffer
		var dn = new jsDocument;
		
		//create cell
		var objTD = document.createElement("td");
		objTD.style.verticalAlign = "top";
		
		//add it to the first layer
		objTR.appendChild(objTD);

		//write arrow HTML
		dn.write("<a href=\"javascript:localTC.switchTo('strip");
		dn.write(this.strips.length);
		dn.write("', '");
		dn.write(strName);
		dn.write("')\"><img src=\"");
		dn.write(IMG_BTN_MORE.filename);
		dn.write("\" border=\"0\"></a>");
		
		objTD.innerHTML = dn;
	}	

}

//-----------------------------------------------------------------
// Method _jsTabControl_drawTab()
// This function draws an individual tab onto a jsDocument.
//
// Parameters:
//	tab (jsTab) - the tab to draw.
//	objOwnerTD (jsTab) - the cell to draw onto.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTabControl_drawTab(tab, objOwnerTD) {

	//begin table
	var objTable = document.createElement("table");
	
	with (objTable) {
		setAttribute("border", "0");
		setAttribute("cellspacing", "0");
		setAttribute("cellpadding", "0");
	}
	
	//begin row
	var objTR = document.createElement("tr");
	objTable.appendChild(objTR);
	
	//begin first cell
	var objTD = document.createElement("td");
	var objIMG = document.createElement("img");
	with (objIMG) {
		setAttribute("src", IMG_TAB_OFF[0].filename);
		setAttribute("height", IMG_TAB_OFF[0].height);
		setAttribute("width", IMG_TAB_OFF[0].width);
		setAttribute("id", "tab" + tab.id + "left");
	}
	objTD.appendChild(objIMG);
	objTR.appendChild(objTD);
	
	//begin middle cell
	objTD = document.createElement("td");
	with (objTD) {
		setAttribute("id", "tab" + tab.id + "text");
		setAttribute("class", "tabText");
		setAttribute("width", this.tabWidth - IMG_TAB_OFF[2].width - IMG_TAB_OFF[0].width);
	}
	
	//create link
	var objA = document.createElement("a");
	with (objA) {
		setAttribute("class", "tabLink");
		setAttribute("href", "javascript:clickTab(" +tab.id + ")");
		innerHTML = tab.text;
	}
	objTD.appendChild(objA);
	objTR.appendChild(objTD);
	
	//begin last cell
	objTD = document.createElement("td");
	objIMG = document.createElement("img");
	with (objIMG) {
		setAttribute("src", IMG_TAB_OFF[2].filename);
		setAttribute("height", IMG_TAB_OFF[2].height);
		setAttribute("width", IMG_TAB_OFF[2].width);
		setAttribute("id", "tab" + tab.id + "right");
	}	
	objTD.appendChild(objIMG);
	objTR.appendChild(objTD);

	//add it all to the layer
	objOwnerTD.appendChild(objTable);

}


//-----------------------------------------------------------------
// Method jsTabControl.turnTabOn()
// This function switches a tab into the on state given the tabID.
//
// Parameters:
//	tabID (String) - the ID of the tab to act on.
// Returns:
//	nothing.
//-----------------------------------------------------------------	
function _jsTabControl_turnTabOn(tabID) {
	document.getElementById('tab' + tabID + 'text').style.backgroundImage = "url(" + IMG_TAB_ON[1].filename + ")";
	document.images['tab' + tabID + 'left'].src = IMG_TAB_ON[0].filename;
	document.images['tab' + tabID + 'right'].src = IMG_TAB_ON[2].filename;		
}

//-----------------------------------------------------------------
// Method jsTabControl.turnTabOff()
// This function switches a tab into the off state given the tabID.
//
// Parameters:
//	tabID (String) - the ID of the tab to act on.
// Returns:
//	nothing.
//-----------------------------------------------------------------	
function _jsTabControl_turnTabOff(tabID) {	
	document.getElementById('tab' + tabID + 'text').style.backgroundImage = "url(" + IMG_TAB_OFF[1].filename + ")";
	document.images['tab' + tabID + 'left'].src = IMG_TAB_OFF[0].filename;
	document.images['tab' + tabID + 'right'].src = IMG_TAB_OFF[2].filename;	
}

//-----------------------------------------------------------------
// Method jsTabControl.switchTo()
// This function toggles between the two tab layers.
//
// Parameters:
//	idTo (String) - the ID of the layer to show.
//	idFrom (String) - the ID of the layer to hide.
// Returns:
//	nothing.
//-----------------------------------------------------------------

function _jsTabControl_switchTo(idTo, idFrom) {
	document.getElementById(idFrom).style.visibility = "hidden";
	document.getElementById(idFrom).style.top = "-1000pt";
	document.getElementById(idTo).style.visibility = "visible";
	document.getElementById(idTo).style.top = this.top;	
}

//-----------------------------------------------------------------
// Method jsTabControl.addTab()
// This function adds a tab to the collection.
//
// Parameters:
//	text (String) - the text to be displayed in the tab.
//	url (String) - the url to link to.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTabControl_addTab(text, url) {
	//add the tab in a numeric slot
	this.tabs[this.tabs.length] = new jsTab(text, url);
	
	//add the tab in a key-based slot
	this.tabs[text] = this.tabs[this.tabs.length-1];
	
	//set the id
	this.tabs[this.tabs.length - 1].id = this.tabs.length - 1;
}
