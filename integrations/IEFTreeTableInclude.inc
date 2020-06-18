<%--  IEFTreeTableInclude.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
//Include information related to browser and client platform
<%@ include file ="scripts/IEFUIConstants.js" %>
<%@ include file ="scripts/IEFUIModal.js"%>
<%@ include file ="scripts/MCADUtilMethods.js"%>

//Global Variables Start
var treeControlObject			= new TreeControl();
var integrationFrame			= getIntegrationFrame(this);
var appletObject = null;
if(integrationFrame != null && integrationFrame)
{
	if (typeof integrationFrame.getAppletObject === "function") 
	{
		appletObject = integrationFrame.getAppletObject(); 
	} 
}
var cancelOperation			    = true;
var popupWindow					= null;
var modalDialog					= null;
var timer						= null;
var scrollPositionTaken			= "";
var scrollPosition				= "";
var scrollCheckTimeIntervel		= 100; //In milli seconds
var extraRows					= 5; //To avoid visibility of empty row
var maxRowLimit					= 1;
var minRowLimit					= 0;
var indvRowHeight				= 25;
var totalTableRowHeight			= 25;
var cellContent					= new Array();
var checkBoxSelectionDataTable  = new Array();
var tabNameHeaderSelectAllTable = new Array();
var isFirstRefresh				= true;
var isScrollRunning				= false;
var isRefreshing				= false; //isRefreshing is maintained to avoid some issues for Mozilla old versions (1.7 or below).
//var isIE11 = !!navigator.userAgent.match(/Trident\/7\./);
//Global Variables End

//Constants Start
var TRUE	= "true";
var FALSE	= "false";
//Constants End

//Global Classes Start
//Baseline document class Start
function jsDocument() 
{
	this.text = new Array();		//array to store the string
	this.write = function (str) { this.text[this.text.length] = str; }
	this.writeln = function (str) { this.text[this.text.length] = str + "\n"; }
	this.toString = function () { return this.text.join(""); }

	this.writeHTMLHeader = function () 
	{
		this.write("<html><head>");
		this.writeln("");
		this.writeln("<link rel='stylesheet' href='emxTreeTable.css' type='text/css'>");
		this.writeln("<link rel='stylesheet' href='./styles/emxIEFCommonUI.css' type='text/css'>");
		this.writeln("</style>");
		this.writeln("");
		this.write("</head>");
	}
		this.writeDIV = function () 
	{
		
this.write("<div id=\"scrolldiv\" onmouseover=\"parent.scrollRefresh()\" onmousewheel=\"parent.scrollRefresh()\" >"); 
	
	}
	this.writeBody = function (style) { this.writeln("<body" + (style ? " class=\"" + style + "\"" : "") + " >"); }
	this.writeHTMLFooter = function () { this.writeln("</body></html>"); }
}

//create string holder
var d = new jsDocument;

//write the header
d.writeHTMLHeader();

d.write("<body leftmargin='0' marginwidth='0' onresize=\"parent.reloadTable(this)\" onscroll=\"parent.scrollRefresh()\" >");
//Baseline document class End
if(isIE)
{
d.writeDIV();
}

function callTreeTableUIObject( methodname, argument)
{	
if(appletObject == null)
{
	var boolbar = false;
	var response = "";
	var xhttp = new XMLHttpRequest();		
	xhttp.open("POST", "/3DSpace/servlet/IEFCommandsServlet?"+methodname+"=xyz&Command="+methodname+"&appletfree=true", false);
	xhttp.setRequestHeader("Content-type", "application/octet-stream");
	xhttp.send(argument); 

	if (xhttp.status === 200) {
		response = xhttp.responseText;
	}
	return response;
}
else
{
return appletObject.callTreeTableUIObject(methodname, argument);
}
}

//TreeControl Class Start
function TreeControl()
{
	//properties
	this.scrollX		= 0;
	this.scrollY		= 0;
	this.activeTabName	= "";

	//methods
	this.setAttributes								= TreeControl_setAttributes;
	this.refreshInnerTable							= TreeControl_refreshInnerTable;
	this.refresh									= TreeControl_refresh;
	this.toggleExpand								= TreeControl_toggleExpand;
	this.setSelectedNode							= TreeControl_setSelectedNode;
	this.changeNodeSelection						= TreeControl_changeNodeSelection;
	this.getActiveTabName					        = TreeControl_getActiveTabName;
	this.changeNodeLockSelection					= TreeControl_changeNodeLockSelection;
	this.changeLockSelectionForAll					= TreeControl_changeLockSelectionForAll;
	this.changeSelectionForAll						= TreeControl_changeSelectionForAll;
	this.changeSelectionForModified					= TreeControl_changeSelectionForModified;
	this.changeSelectionForMust						= TreeControl_changeSelectionForMust;
	this.changeNodeCellValue						= TreeControl_changeNodeCellValue;
	this.getPreviewObjectDetails					= TreeControl_getPreviewObjectDetails;
	this.getViewsDetails							= TreeControl_getViewsDetails;
	this.submitPage									= TreeControl_submitPage;
	this.selectedViews								= TreeControl_selectedViews;
	this.getCheckoutObjectDetails					= TreeControl_getCheckoutObjectDetails;
	this.clean										= TreeControl_clean;
	this.getHeaderPage								= TreeControl_getHeaderPage;
	this.getContentPage								= TreeControl_getContentPage;
	this.getFooterPage								= TreeControl_getFooterPage;
	this.changeUnrecognizedNodeSelection			= TreeControl_changeUnrecognizedNodeSelection;
	this.changeUnrecognizedNodeSelectionForAll		= TreeControl_changeUnrecognizedNodeSelectionForAll;
	this.changeUnrecognizedNodeCellValue			= TreeControl_changeUnrecognizedNodeCellValue;
	this.changeRecognitionStatus					= TreeControl_changeRecognitionStatus;
	this.showOnlyNodesCurrentlyUnrecognized			= TreeControl_showOnlyNodesCurrentlyUnrecognized;
	this.sortUnrecognizedNodesColumn				= TreeControl_sortUnrecognizedNodesColumn;
	this.recognizeNode								= TreeControl_recognizeNode;
	this.executeRecognitionProgram					= TreeControl_executeRecognitionProgram;
	this.getShowOnlyNodesCurrentlyUnrecognizedFlag	= TreeControl_getShowOnlyNodesCurrentlyUnrecognizedFlag;
	this.getIntegrationName							= TreeControl_getIntegrationName;
	this.getIntegrationPreferenceValue				= TreeControl_getIntegrationPreferenceValue;
	this.getGlobalPreferenceValue					= TreeControl_getGlobalPreferenceValue;
	this.changeFormFieldValue						= TreeControl_changeFormFieldValue;
	this.setNewSaveAsName							= TreeControl_setNewSaveAsName;
	this.getAllNamesForRegularExpression			= TreeControl_getAllNamesForRegularExpression;
	this.updateFooterPageOptions					= TreeControl_updateFooterPageOptions;
	this.changeObsoleteNodeSelection				= TreeControl_changeObsoleteNodeSelection;
	this.changeObsoleteNodeSelectionForAll			= TreeControl_changeObsoleteNodeSelectionForAll;
	this.changeDeselectCheckinForAll				= TreeControl_changeDeselectCheckinForAll;
	this.sortObsoleteNodesColumn					= TreeControl_sortObsoleteNodesColumn;
	this.changeLocalCheckoutSelectionForAll			= TreeControl_changeLocalCheckoutSelectionForAll;
	this.changeNodeLocalCheckoutSelection			= TreeControl_changeNodeLocalCheckoutSelection;
	this.reloadTabData								= TreeControl_reloadTabData;
	this.selectedCustomView							= TreeControl_selectedCustomView;
	this.applyCues									= TreeControl_applyCues;
	this.csvExport									= TreeControl_csvExport;
	this.implementSelectionLogic					= TreeControl_implementSelectionLogic;
	this.toggleRevisionVersionBox					= TreeControl_toggleRevisionVersionBox;
	this.submitConflictUUIDPage                     = TreeControl_submitConflictUUIDPage;
	this.lockObject	                                = TreeControl_lockObject;
	this.storeFrameCoordinates						= TreeControl_storeFrameCoordinates;
	this.setSaveAsAutoName							= TreeControl_setSaveAsAutoName;
	this.setSelectedPart							= TreeControl_setSelectedPart;
	this.getFirstNodeIDforObjectID						= TreeControl_getFirstNodeIDforObjectID;
}

function TreeControl_refresh() 
{
	isRefreshing = true;

	if(isFirstRefresh)
	{
		totalTableRowHeight = window.frames["tableDisplay"].window.innerHeight;

		maxRowLimit = minRowLimit + Math.round(totalTableRowHeight/indvRowHeight);
		maxRowLimit = maxRowLimit + extraRows + extraRows;//Since minRowLimit is zero
		isFirstRefresh = false;
	}
	
	var activeTabDetails = this.activeTabName;
	activeTabDetails = this.activeTabName + "|" + minRowLimit + "|" + maxRowLimit;
	var response = "";			
	response = callTreeTableUIObject("getPageContent",activeTabDetails);
			
	//Get table header to paint
	var pageContent =  response;
	//draw to the frame
	with (frames[1].document) 
	{
		open();

		write(d);
		write(pageContent);
		write("<div id=\"tooltip\" style=\"position:absolute;visibility:hidden;border:1px solid black;width:250px;font-family: verdana, helvetica, arial, sans-serif; font-size: 8pt;color:#003366\" ></div>");
		if(isIE){
			write("</div></body></html>");
		} else {
		write("</body></html>");
		}

		if(!isIE)
		{
			close();
		}
	}

	frames[1].scrollTo(this.scrollX, this.scrollY);
	closeProgressBar();

	setTimeout("resetSelectAllCheckBox()", 10);	
	return;
}

function TreeControl_setAttributes(htmlObj,xmlObj)
{
	var atrName	= "";
	var atrValue	= "";
	if(xmlObj.attributes != null)
	for(var z=0; z<xmlObj.attributes.length; z++)
	{
		atrName		= xmlObj.attributes[z].name;
		atrValue	= xmlObj.attributes[z].value;
		htmlObj.setAttribute(atrName,atrValue);
	}
}

function TreeControl_refreshInnerTable()
{
	var tdElement		= frames[1].document.getElementById("tableOuter");
	var tbodyElement	= frames[1].document.getElementById("tbody");
	
	if(tdElement && tbodyElement)
	{
		var activeTabDetails	= this.activeTabName;
		activeTabDetails	= this.activeTabName + "|" + minRowLimit + "|" + maxRowLimit;

		//Get table header to paint
		var pageContent		= callTreeTableUIObject("getPageContent", activeTabDetails) + "";
		var startIndex		= pageContent.indexOf('<td id=')+20;
		var endIndex		= pageContent.indexOf('</table></td></tr>',startIndex)+8;
		var tableContent	= pageContent.substr(startIndex,endIndex);
			
		tableContent		= tableContent.replace("</td></tr></table>","");
		startIndex		= tableContent.indexOf('<tbody id=')+18;
		endIndex		= tableContent.indexOf('</tbody>')
		var tbody		= tableContent.substr(startIndex,endIndex);
		tbody			= tbody.replace("</tbody></table>","");

		
			tbody			= "<tbody>" + tbody + "</tbody>";

			var objDOMParser	= new DOMParser();
			var serializer		= new XMLSerializer();

			var objDoc			= null;
			var root			= null;

			tbody				= tbody.replace(/&/g,"&amp;");

			objDoc				= objDOMParser.parseFromString(tbody, "text/xml");
			root				= objDoc.documentElement;
			
			if(root.nodeName == "parsererror")
				alert(root.firstChild.nodeValue); 

			//Variables
			var htmlObj		= null;
			var xmlObj		= null;
			var j			= 0;
			var atrHeight	= 0;
			var htmlContent	= "";
			var startIndex	= 0;
			var endIndex	= 0;
			//Variables

			if(tbodyElement.childNodes.length == root.childNodes.length)
			{
				var newRowNo = root.childNodes[1].getAttribute("id");
				var oldRowNo = tbodyElement.childNodes[1].getAttribute("id");
				var rowDiff	= (newRowNo - oldRowNo);
				
				if(rowDiff == 0);//No updation
				else if(rowDiff > 0 && root!=null) //scrolling down
				{
					atrHeight = root.firstChild.firstChild.getAttribute("height");
					tbodyElement.firstChild.firstChild.setAttribute("height",atrHeight);
					
					atrHeight = root.lastChild.firstChild.getAttribute("height");
					tbodyElement.lastChild.firstChild.setAttribute("height",atrHeight);
					
					for(var i=0;i<tbodyElement.childNodes.length;i++)
					{
						htmlObj		= tbodyElement.childNodes[i];
						xmlObj		= root.childNodes[i];
						j			= i+(2*rowDiff);
						
						if(htmlObj.id == "line" || htmlObj.id == "empty");
						else if(j+2 < tbodyElement.childNodes.length)
						{
							tbodyElement.insertBefore(tbodyElement.childNodes[j],tbodyElement.childNodes[i]);
							tbodyElement.insertBefore(tbodyElement.childNodes[j+1],tbodyElement.childNodes[i+1]);
						}
						else
						{
							htmlContent	= serializer.serializeToString(xmlObj);
							startIndex	= htmlContent.indexOf('>');
							endIndex	= htmlContent.indexOf('</tr>');

							if(endIndex == -1)
								htmlContent	= htmlContent.substr((startIndex+1));
							else
								htmlContent	= htmlContent.substr((startIndex+1), endIndex);

							this.setAttributes(htmlObj,xmlObj);
							htmlObj.innerHTML = htmlContent;
						}
					}
				}//close for down scroll loop
				else if(root!=null) //scrolling up
				{
					atrHeight = root.firstChild.firstChild.getAttribute("height");
					tbodyElement.firstChild.firstChild.setAttribute("height",atrHeight);
					
					atrHeight = root.lastChild.firstChild.getAttribute("height");
					tbodyElement.lastChild.firstChild.setAttribute("height",atrHeight);
					
					for(var i=(tbodyElement.childNodes.length-1);i>-1;i--)
					{
						htmlObj		= tbodyElement.childNodes[i];
						xmlObj		= root.childNodes[i];
						j			= i+(2*rowDiff);
						
						if(htmlObj.id == "line" || htmlObj.id == "empty");
						else if(j > 0)
						{
							tbodyElement.insertBefore(tbodyElement.childNodes[j],tbodyElement.childNodes[i+2]);
							tbodyElement.insertBefore(tbodyElement.childNodes[j],tbodyElement.childNodes[i+2]);
						}
						else
						{
							htmlContent	= serializer.serializeToString(xmlObj);
							startIndex	= htmlContent.indexOf('>');
							endIndex	= htmlContent.indexOf('</tr>');

							if(endIndex == -1)
								htmlContent	= htmlContent.substr((startIndex+1));
							else
								htmlContent	= htmlContent.substr((startIndex+1), endIndex);

							this.setAttributes(htmlObj,xmlObj);
							htmlObj.innerHTML = htmlContent;
						}
					}
				}//close for up scroll loop
			}//close for number of rows check

		//close loop for non-IE

		setTimeout("resetSelectAllCheckBox()", 10);

	}//clos check for tbody element
}

function TreeControl_storeFrameCoordinates()
{
	//Store frame coordinates in order to restore the frame position after refresh
	if (frames[1].document.layers) 
	{
		this.scrollX = frames[1].pageXOffset;
		this.scrollY = frames[1].pageYOffset;
	} 
	else if (frames[1].document.all) 
	{
		this.scrollX = frames[1].document.body.scrollLeft;
		this.scrollY = frames[1].document.body.scrollTop;
	}
	else
	{
		this.scrollX = frames[1].pageXOffset;
		this.scrollY = frames[1].pageYOffset;
	}

}

function TreeControl_lockObject(nodeID)
{
    this.storeFrameCoordinates();

    var response = callTreeTableUIObject("lockObject", nodeID);
	if(response == TRUE)
    {
		this.refresh();
    }
    return response;
}

function TreeControl_toggleExpand(strNodeID) 
{
   this.storeFrameCoordinates();
    	
	var response = callTreeTableUIObject("toggleExpand", strNodeID);
        
	if(response && response != "" && response != "true")
		alert(response);
	return;
}

function TreeControl_setSelectedNode(strNodeID) 
{
	var response = callTreeTableUIObject("setSelectedNode", strNodeID);

	if(response == TRUE)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_changeNodeSelection(selectedNodeDetails)
{
    this.storeFrameCoordinates();
    tabNameHeaderSelectAllTable[this.activeTabName] = false;
	var response = callTreeTableUIObject("changeNodeSelection", selectedNodeDetails);

	if(response == TRUE)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_changeNodeLockSelection(selectedNodeDetails)
{
    this.storeFrameCoordinates();
    
	var response = callTreeTableUIObject("changeNodeLockSelection", selectedNodeDetails);

	if(response == TRUE)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_changeSelectionForAll(isSelected)
{
    this.storeFrameCoordinates();
	tabNameHeaderSelectAllTable[this.activeTabName] = isSelected;
    
	var response = callTreeTableUIObject("changeSelectionForAll", isSelected + "");
	
	if(response == TRUE)
		this.refresh();

	return response;
}

function TreeControl_changeSelectionForModified(isSelected)
{
    this.storeFrameCoordinates();
    
	var response = callTreeTableUIObject("changeSelectionForModified", isSelected + "");
	response = response + "";
	if(response.indexOf("true") == 0)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_changeSelectionForMust(isSelected)
{
    this.storeFrameCoordinates();
    
	var response = callTreeTableUIObject("changeSelectionForMust", isSelected + "");
	
	if(response == TRUE)
	{
		this.refresh();
	}

	return;
}

function TreeControl_changeLockSelectionForAll(isSelected)
{
     this.storeFrameCoordinates();
     
	var response = callTreeTableUIObject("changeLockSelectionForAll", isSelected + "");

	response = response +""; 
	var responseString = response.split("|");
	if(responseString.length > 1 )
	{
		alert(responseString[1]);
		response = TRUE;
	}
	if(response == TRUE)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_changeNodeCellValue(selectedNodeDetails)
{
    this.storeFrameCoordinates();
   
	var response = callTreeTableUIObject("changeNodeCellValue", selectedNodeDetails);

	if(response == TRUE)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_submitPage(pageOptions)
{
	var submitStatus = callTreeTableUIObject("submitPage", pageOptions);
	return submitStatus;
}

function TreeControl_selectedViews(selectionDetails)
{
	var response = callTreeTableUIObject("selectedViews", selectionDetails);

	if(response == TRUE)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_getPreviewObjectDetails(nodeID)
{
	var objectDetails = callTreeTableUIObject("getPreviewObjectDetails", nodeID);
	return objectDetails + "";
}

function TreeControl_getViewsDetails()
{
	var viewsDetails = callTreeTableUIObject("getViewsDetails", " ");
	return viewsDetails + "";
}

function TreeControl_getCheckoutObjectDetails()
{
	var checkoutObjectDetails = callTreeTableUIObject("getCheckoutObjectDetails", " ");
	return checkoutObjectDetails + "";
}

function TreeControl_clean()
{ 
    treeControlObject	= null;
}

function TreeControl_getHeaderPage(activeTabName)
{		
	var boolbar = false;
	var response = "";	
	response = callTreeTableUIObject("getHeaderPage",activeTabName);
	
	return response;
}

function TreeControl_getContentPage(activeTabName)
{	
	var boolbar = false;
	var response = "";	
	response = callTreeTableUIObject("getContentPage",activeTabName);	

	return response;
}

function TreeControl_getFooterPage(activeTabName)
{	
	var boolbar = false;
	var response = "";			
	response = callTreeTableUIObject("getFooterPage",activeTabName);		

	return response;
}

function TreeControl_changeUnrecognizedNodeSelection(selectionDetails)
{
	
	var response = callTreeTableUIObject("changeUnrecognizedNodeSelection", selectionDetails + "");
	
	if(response == TRUE)
		this.refresh();
		
	return;
}

function TreeControl_changeUnrecognizedNodeSelectionForAll(isSelected)
{
	var response = callTreeTableUIObject("changeUnrecognizedNodeSelectionForAll", isSelected + "");
	
	if(response == TRUE)
	{
		this.refresh();
	}

	return;
}

function TreeControl_changeUnrecognizedNodeCellValue(selectedNodeDetails)
{
	var response = callTreeTableUIObject("changeUnrecognizedNodeCellValue", selectedNodeDetails);

	if(response != FALSE)
	{
		this.refresh();
	}
     
	return response;
}

function TreeControl_changeRecognitionStatus(isSelected)
{
	var response = callTreeTableUIObject("changeRecognitionStatus", isSelected + "");
	
	if(response == TRUE)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_showOnlyNodesCurrentlyUnrecognized(isSelected)
{
	var response = callTreeTableUIObject("showOnlyNodesCurrentlyUnrecognized", isSelected + "");
	
	if(response == TRUE)
	{
		this.refresh();
	}

	return;
}

function TreeControl_sortUnrecognizedNodesColumn(columnName)
{
	var response = callTreeTableUIObject("sortUnrecognizedNodesColumn", columnName);

	if(response == TRUE)
	{
		this.refresh();
	}

	return;
}

function TreeControl_recognizeNode(objectID)
{
	var response = callTreeTableUIObject("recognizeNode", objectID);
	
	if(response == TRUE)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_getShowOnlyNodesCurrentlyUnrecognizedFlag()
{
	var status = callTreeTableUIObject("getShowOnlyNodesCurrentlyUnrecognizedFlag", "");

	return status;
}

function TreeControl_executeRecognitionProgram(programName)
{
	var response = callTreeTableUIObject("executeRecognitionProgram", programName);

    if(response == TRUE)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_getIntegrationName()
{
	var response = callTreeTableUIObject("getIntegrationName", " ");

	return response;
}

function TreeControl_getIntegrationPreferenceValue(preferenceName)
{
	var response = callTreeTableUIObject("getIntegrationPreferenceValue", preferenceName);

	return response;
}

function TreeControl_getGlobalPreferenceValue(preferenceName)
{
	var response = callTreeTableUIObject("getGlobalPreferenceValue", preferenceName);

	return response;
}

function TreeControl_changeFormFieldValue(selectedFormFieldDetails)
{
	var boolbar = false;
var response = "";
response = callTreeTableUIObject("changeFormFieldValue",selectedFormFieldDetails);	
		
	if(response == TRUE)
	{
		this.refresh();
	}

	return response;
}

function TreeControl_setNewSaveAsName(newIdNameString)
{
	this.storeFrameCoordinates();

	var response  = callTreeTableUIObject("setNewSaveAsName", newIdNameString);	
	if(response == TRUE)
	{
		treeControlObject.refresh();
	}

	return response;
}

function TreeControl_getAllNamesForRegularExpression()
{
	var response  = callTreeTableUIObject("getAllNamesForRegularExpression", "");	
	return response;
}

function TreeControl_updateFooterPageOptions(pageOptionDetail)
{
	var response  = callTreeTableUIObject("updateFooterPageOptions", pageOptionDetail);
	return response;
}

function TreeControl_changeObsoleteNodeSelection(selectionDetails)
{
	var response = callTreeTableUIObject("changeObsoleteNodeSelection", selectionDetails + "");
	
	if(response == TRUE)
		this.refresh();

	return response;
}

function TreeControl_changeObsoleteNodeSelectionForAll(isSelected)
{
	var response = callTreeTableUIObject("changeObsoleteNodeSelectionForAll", isSelected + "");
	
	if(response == TRUE)
		this.refresh();
	
	return response;
}

function TreeControl_changeDeselectCheckinForAll(isSelected)
{
	var response = callTreeTableUIObject("changeDeselectCheckinForAll", isSelected + "");
	
	if(response == TRUE)
		this.refresh();

	return response;
}

function TreeControl_sortObsoleteNodesColumn(columnName)
{
	var response = callTreeTableUIObject("sortObsoleteNodesColumn", columnName);

	if(response == TRUE)
		this.refresh();
}

function TreeControl_changeLocalCheckoutSelectionForAll(isSelected)
{
	var response = callTreeTableUIObject("changeLocalCheckoutSelectionForAll", isSelected + "");
	
	if(response == TRUE)
		this.refresh();

	return response;
}

function TreeControl_changeNodeLocalCheckoutSelection(isSelected)
{ 
	this.storeFrameCoordinates();

	var response = callTreeTableUIObject("changeNodeLocalCheckoutSelection", isSelected + "");
	
	if(response == TRUE)
		this.refresh();

	return response;
}

function TreeControl_reloadTabData()
{
	var response = callTreeTableUIObject("reloadTabData", "");
	if(response == TRUE)
	{
		treeControlObject.refresh();
	}

	return response;
}

function TreeControl_selectedCustomView(tableName, activeTabName)
{
	var response = callTreeTableUIObject("selectedCustomView", tableName);

	if(response!=TRUE && response!=FALSE)
	{
		alert(response);
	}
	else if(response == TRUE)
	{
		treeControlObject.activeTabName = activeTabName;
		treeControlObject.refresh();
	}

	return response;
}

function TreeControl_applyCues(selectedCues, activeTabName)
{
	var response = callTreeTableUIObject("applyCues", selectedCues);
	if(response == TRUE)
	{
		treeControlObject.activeTabName = activeTabName;
		treeControlObject.refresh();
	}

	return response;
}
function TreeControl_submitConflictUUIDPage(pageOptions)
{
	var submitStatus = callTreeTableUIObject("submitConflictUUIDPage", pageOptions);
	activeTabName = "ConflictUUIDNodes";
	if(submitStatus == TRUE || submitStatus == true)
	{
		this.refresh();
	}
	return submitStatus;

}
function TreeControl_getActiveTabName(arguments)
{
	var response = callTreeTableUIObject("getActiveTabName", arguments);

	return response;
}

function TreeControl_csvExport()
{
	var response = callTreeTableUIObject("updateCSVData", "true");
	return response;
}

function TreeControl_implementSelectionLogic(nodeId, formFieldObject)
{
	for(var selectionType in checkBoxSelectionDataTable)
	{
		for(var inputFieldName in checkBoxSelectionDataTable[selectionType])
		{
			if(inputFieldName == formFieldObject.name)
			{
				var selectionLogicFieldList			= checkBoxSelectionDataTable[selectionType]
				var selectionLogicFieldListElements = selectionLogicFieldList[inputFieldName].split('|');
				
				for(var j=0; j<selectionLogicFieldListElements.length; j++)
				{
					var selectionLogicFieldName = selectionLogicFieldListElements[j];
					var selectionLogicField		= frames[1].document.getElementById(nodeId + selectionLogicFieldName);

					if(selectionLogicField != null)
					{
						if(selectionType == 'selectToSelect' && formFieldObject.checked)
							selectionLogicField.checked = true;
						else if(selectionType == 'selectToUnselect' && formFieldObject.checked)
							selectionLogicField.checked = false;
						else if(selectionType == 'unselectToSelect' && !formFieldObject.checked)
							selectionLogicField.checked = true;
						else if(selectionType == 'unselectToUnselect' && !formFieldObject.checked)
							selectionLogicField.checked = false;
					}
				}
			}
		}		
	}
}

function TreeControl_toggleRevisionVersionBox(columnID, objectID)
{
	var toggleDetails	= objectID + "|" + columnID;
	var response		= callTreeTableUIObject("toggleRevisionVersionBox", toggleDetails);
	
	this.refresh();
}

function TreeControl_setSaveAsAutoName(newIdNameString)
{
	this.storeFrameCoordinates();

	var response  = callTreeTableUIObject("setSaveAsAutoName", newIdNameString);	
	if(response == TRUE)
	{
		treeControlObject.refresh();
	}

	return response;
}

function TreeControl_setSelectedPart(arguments)
{
	this.storeFrameCoordinates();
     
	var response = callTreeTableUIObject("setSelectedPart", arguments);	

	return response;
}

//This method is added for Save As page customization for PSA(IBM).
function TreeControl_getFirstNodeIDforObjectID(objectID)
{
     
	var response = callTreeTableUIObject("getFirstNodeIDforObjectID", objectID);	

	return response;
}

//TreeControl Class End
//Global Classes End

//Window event handlers start
function syncFrames(nodeID) 
{
	var extraArguments = getExpandArguments();
	if(extraArguments != "")
		nodeID = nodeID + "|" + extraArguments;

	//expand the given node
	treeControlObject.toggleExpand(nodeID);
	treeControlObject.refresh();

	return;
}

function setActive(strNodeId)
{
	treeControlObject.storeFrameCoordinates();

    var response = treeControlObject.setSelectedNode(strNodeId);

	return;
}

function reloadTable(documentObject)
{
	
		isFirstRefresh = true;
		treeControlObject.storeFrameCoordinates();
	    treeControlObject.refresh();
 
}
var currentTabName = "";
function loadPage(activeTabName)
{
currentTabName = activeTabName;
	treeControlObject.activeTabName = activeTabName;
	treeControlObject.refresh();
}

function closeModalDialog()
{
	cancelOperation = false;
	closeProgressBar();
	window.close();
}

function reloadTabData()
{
    var status = treeControlObject.reloadTabData();
	if(status != TRUE && status != FALSE)
	{		
		alert(status);
	}
}

function csvExport()
{		
	var status = treeControlObject.csvExport();

	if(status.indexOf("ERROR") == -1)
	{	
		var tableURL="IEFTableExport.jsp?timeStamp="+status;
		frames['listHidden'].location.href = tableURL;			
	}
	else
	{
		alert(status);
	}
}

function applyCues(selectedCues)
{
	var status = treeControlObject.applyCues(selectedCues, "CustomView");
	
	if(status != TRUE && status != FALSE)
	{
		alert(status);
	}
}

function selectedCustomView(viewComboControl)
{
    var tableName   = viewComboControl.options[viewComboControl.selectedIndex].value;
    
    var status      = treeControlObject.selectedCustomView(tableName,"CustomView");
	if(status != TRUE && status != FALSE)
	{		
		alert(status);
	}
}

function startTimerIcon()
{
	frames['headerDisplay'].document.imgProgress.src = "./images/utilProgressDialog.gif";
}

function stopTimerIcon()
{
	frames['headerDisplay'].document.imgProgress.src = "./images/utilSpace.gif";		
}

function showProgressBar(queryString)
{
	closeProgressBar();
	showIEFModalDialog("IEFProgressBar.jsp?" + queryString, 410, 120);
	return top.modalDialog.contentWindow;
}

function updateProgressBar(metaCurrentCount, fileCurrentCount)
{
	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		top.modalDialog.contentWindow.updateProgressBar(parseInt(metaCurrentCount), parseInt(fileCurrentCount));
	}
}

function closeProgressBar()
{
	if(top.modalDialog && top.modalDialog.contentWindow && !top.modalDialog.contentWindow.closed)
	{
		i = 0;
		closeIEFModalDialog();
	}
}

function abortOperation()
{
	var integrationName = treeControlObject.getIntegrationName();
	callCommandHandlerSynchronously(integrationName, 'abortOperation', true);
}

function scrollRefresh()
{
	if(!isRefreshing && !isScrollRunning)
	{
		isScrollRunning = true;
		canScroll();
	}
}

function canScroll()
	{
		totalTableRowHeight = window.frames["tableDisplay"].window.innerHeight;
		scrollPosition		= window.frames["tableDisplay"].document.body.scrollTop;
		
	if(scrollPositionTaken == scrollPosition)
	{
		isScrollRunning	= false;
		scrollNow();
	}
	else
	{
		scrollPositionTaken = scrollPosition;
		setTimeout("canScroll()" , scrollCheckTimeIntervel);
	}
}

function scrollNow()
{
		//Vertical Scroll
		var instMinRowLimit		= 0;
		var instMaxRowLimit		= 1;

		instMinRowLimit			= Math.round(scrollPosition/indvRowHeight);
		//To handle the header space
		if(instMinRowLimit<5)
			instMinRowLimit = 0;
		else
			instMinRowLimit = instMinRowLimit-2;

		instMaxRowLimit		= instMinRowLimit + Math.round(totalTableRowHeight/indvRowHeight);

		//To handle extra rows
		instMaxRowLimit	= instMaxRowLimit+extraRows;
		instMinRowLimit	= instMinRowLimit-extraRows;
		if(instMinRowLimit < 0)
		{
			instMaxRowLimit	= instMaxRowLimit-instMinRowLimit;
			instMinRowLimit	= 0;
		}

	if( (instMinRowLimit < minRowLimit) || (instMaxRowLimit > maxRowLimit) ) 
		{
			minRowLimit = instMinRowLimit;
			maxRowLimit = instMaxRowLimit;
				treeControlObject.refreshInnerTable();
	}
}

function resetSelectAllCheckBox()
{
	var tabName = treeControlObject.getActiveTabName();
	var selectAllCheckBoxSelection = tabNameHeaderSelectAllTable[tabName];

	if(frames['tableDisplay'].document.forms["nodeSelectionHeader"])
	{
		if(selectAllCheckBoxSelection)
			frames['tableDisplay'].document.forms["nodeSelectionHeader"].changeSelectionForAll.checked = selectAllCheckBoxSelection;
	}
	isRefreshing = false;
}
//Window event handlers End

