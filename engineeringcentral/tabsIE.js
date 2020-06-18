//=================================================================
// JavaScript Tab Structure
// Internet Explorer Version
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

	//create string holder
	var d = new jsDocument;
	
	//calculate tabsperstrip
	this.tabsPerStrip = parseInt((document.body.clientWidth - IMG_BTN_MORE.width - IMG_BTN_LESS.width) / this.tabWidth);

	//calculate number of strips needed
	var numStrips = Math.ceil(this.tabs.length / this.tabsPerStrip);

	//draw each strip
	for (i=0; i < numStrips; i++)
		this.createStrip(d, 0 + (this.tabsPerStrip * i), this.tabsPerStrip + (this.tabsPerStrip * i));

	//draw to the frame
	document.body.insertAdjacentHTML("afterBegin", d);
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
//	d (jsDocument) - the document object to write to.
//	start (int) - the index of the tab to start with.
//	stop (int) - the index of the tab to stop on.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTabControl_createStrip(d, start, stop) {
 
	//figure out the strip name and info
	var isPrev = (start > 0);
	var isNext = (stop < this.tabs.length);
	var strName = "strip" + this.strips.length;
	var curLeft = 0;
	
	//variables used in DOM-compliant browsers only
	var bodyNode, divStrip;

	//add the strip name to the array
	this.strips[this.strips.length] = strName;
	
	//this works for Netscape 4.x and IE 4.x
	d.write("<div id=\"");
	d.write(strName);
	d.write("\" style=\"position: absolute; top: " + this.top + "px; left: " + this.left + "px; visibility: " + (isPrev ? "hidden" : "visible")+ "; width: " + ((this.tabWidth * this.tabsPerStrip) + IMG_BTN_MORE.width + IMG_BTN_LESS.width) +"px\">");

	d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr>");

	//check for "less" button
	if (isPrev) {
	
		var dp = new jsDocument;
		
		d.write("<td>");
			
		//write arrow HTML
		dp.write("<a href=\"javascript:localTC.switchTo('");
		dp.write(this.strips[this.strips.length - 2]);
		dp.write("', '");
		dp.write(strName);
		dp.write("')\"><img src=\"");
		dp.write(IMG_BTN_LESS.filename);
		dp.write("\" border=\"0\"></a>");
		
		//now close the layers
		d.write(dp);
		d.write("</td>");
		
		curLeft += IMG_BTN_LESS.width;
	}
	
	//Create all the tab layers
	for (var i=start; i < this.tabs.length && i < stop; i++) {
		d.write("<td>");
		this.drawTab(d, this.tabs[i]);
		d.write("</td>");
		curLeft += this.tabWidth;
	} 

	//check for "more" button
	if (isNext) {
	
		//new string buffer
		var dn = new jsDocument;
		
		//DOM browsers
		d.write("<td>");
			
		//write arrow HTML
		dn.write("<a href=\"javascript:localTC.switchTo('strip");
		dn.write(this.strips.length);
		dn.write("', '");
		dn.write(strName);
		dn.write("')\"><img src=\"");
		dn.write(IMG_BTN_MORE.filename);
		dn.write("\" border=\"0\"></a>");
		d.write(dn);
		d.write("</td>");
		
		curLeft += IMG_BTN_MORE.width;
	}	
	d.write("</tr></table>");
	d.writeln("</div>");

}

//-----------------------------------------------------------------
// Method _jsTabControl_drawTab()
// This function draws an individual tab onto a jsDocument.
//
// Parameters:
//	d (jsDocument) - the document object to write to.
//	tab (jstab) - tab to draw image for.
// Returns:
//	nothing.
//-----------------------------------------------------------------
function _jsTabControl_drawTab(d, tab) {
	d.write("<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\"><tr><td><img src=\"");
	d.write(IMG_TAB_OFF[0].filename);
	d.write("\" border=\"0\" height=\"");
	d.write(IMG_TAB_OFF[0].height);
	d.write("\" width=\"");
	d.write(IMG_TAB_OFF[0].width);
	d.write("\" id=\"tab");
	d.write(tab.id);
	d.write("left\" /></td><td id=\"tab");
	d.write(tab.id);
	d.write("text\" class=\"tabText\" width=\"");
	d.write(this.tabWidth - IMG_TAB_OFF[2].width - IMG_TAB_OFF[0].width);
	d.write("\"><a class=\"tabLink\" href=\"javascript:clickTab(");
	d.write(tab.id);
	d.write(")\">");
	d.write(tab.text);
	d.write("</a></td><td><img src=\"");
	d.write(IMG_TAB_OFF[2].filename);
	d.write("\" border=\"0\" height=\"");
	d.write(IMG_TAB_OFF[2].height);
	d.write("\" width=\"");
	d.write(IMG_TAB_OFF[2].width);
	d.write("\"id=\"tab");
	d.write(tab.id);
	d.write("right\" /></td></tr></table>");
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
	document.all['tab' + tabID + 'text'].style.backgroundImage = "url(" + IMG_TAB_ON[1].filename + ")";
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
	document.all['tab' + tabID + 'text'].style.backgroundImage = "url(" + IMG_TAB_OFF[1].filename + ")";
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
	document.all[idFrom].style.visibility = "hidden";
	document.all[idTo].style.visibility = "visible";
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
