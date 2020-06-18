<%--  emxInfoTableInclude.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--
  $Archive: /InfoCentral/src/infocentral/emxInfoTableInclude.inc $
  $Revision: 1.3.1.3$
  $Author: ds-mbalakrishnan$

--%>

<%--
 *
 * $History: emxInfoTableInclude.inc $
 * 
 * *****************  Version 36  *****************
 * User: Shashikantk  Date: 2/10/03    Time: 5:31p
 * Updated in $/InfoCentral/src/infocentral
 * Now sorting will be done on TNR basis
 * 
 * ************************************************
--%>

<script language="JavaScript">

function createRequestObject() {
    var tmpXmlHttpObject;
    
    //depending on what the browser supports, use the right way to create the XMLHttpRequest object
    if (window.XMLHttpRequest) { 
        // Mozilla, Safari would use this method ...
        tmpXmlHttpObject = new XMLHttpRequest();
	
    } else if (window.ActiveXObject) { 
        // IE would use this method ...
        tmpXmlHttpObject = new ActiveXObject("Microsoft.XMLHTTP");
    }
    
    return tmpXmlHttpObject;
}

//call the above function to create the XMLHttpRequest object
var http = createRequestObject();

function makeGetRequest(inputId) {
    //make a connection to the server ... specifying that you intend to make a GET request 
    //to the server. Specifiy the page name and the URL parameters to send

	http.open('get', 'DSCCommonUtil.jsp?mode=DECCompareStructure&selectedOid=' + inputId);
    //assign a handler for the response
    http.onreadystatechange = processResponse;
	
    //actually send the request to the server
    http.send(null);
}

function processResponse() {
    //check if the response has been received from the server
    if(http.readyState == 4){
	
        //read and assign the response from the server
        var response = http.responseText;
		
        //do additional parsing of the response, if needed
		
        //in this case simply assign the response to the contents of the <div> on the page. 
       // document.getElementById('description').innerHTML = response;
		
        //If the server returned an error message like a 404 error, that message would be shown within the div tag!!. 
        //So it may be worth doing some basic error before setting the contents of the <div>
    }
}

//Added on 27/3/2004 for AEF style toolbar change - start
// Methods for Tracking the selections
function register(strID) {

	var toolBarFrame;
	if (parent.frames){
		toolBarFrame = findFrame(parent, "listHead");
		if (!toolBarFrame){
			toolBarFrame = parent.frames[0];
		}
	}

	var selectedIDsList = parent.ids;
	if(window.frameName == "navigateFrame")
	{
		selectedIDsList = ids;
	}

    if (!selectedIDsList) {
		selectedIDsList = "~";
    }

    if (selectedIDsList.indexOf(strID + "~") == -1) {
		selectedIDsList += strID + "~";
    }

	if(window.frameName == "navigateFrame")
		ids = selectedIDsList;
	else{
		parent.ids = selectedIDsList;
			makeGetRequest(strID);
		}

	if (toolBarFrame && toolBarFrame.toolbars && toolBarFrame.toolbars.setListLinks) {
    	toolBarFrame.toolbars.setListLinks( selectedIDsList.length > 1);
	}
}

function unregister(strID) {
    var strTemp = parent.ids;
	var toolBarFrame;

	if(window.frameName == "navigateFrame")
	{
		strTemp = ids;
	}

	if (parent.frames){
		toolBarFrame = findFrame(parent, "listHead");
		if (!toolBarFrame){
			toolBarFrame = parent.frames[0];
		}
	}

    if (strTemp.indexOf("~" + strID + "~") > -1) {
		strTemp = strTemp.replace(strID + "~", "");

		if(window.frameName == "navigateFrame")
			ids = strTemp;
		else
			parent.ids = strTemp;
    }

    if (toolBarFrame && toolBarFrame.toolbars && toolBarFrame.toolbars.setListLinks) {
        toolBarFrame.toolbars.setListLinks( strTemp.length > 1);
    }
}

function doCheckboxClick(objCheckbox) {
    if (objCheckbox.checked)
        register(objCheckbox.value);
    else
        unregister(objCheckbox.value);
}

function doRadioClick(objRadio){
    var currentId=objRadio.value;
    var registeredIdList=parent.ids;
    if(typeof(registeredIdList)=="undefined" && objRadio.checked)
    {
         register(objRadio.value);
    }
    else
    {
         var allIds=registeredIdList.split("~");
         for(var i=0;i<allIds.length;i++)
         {
             if(currentId!=allIds[i] && allIds[i]!="")
             {
                 unregister(allIds[i]);  
             }
          }   
          if (objRadio.checked)
          {
             register(objRadio.value);
          }
     }
}

function doSelectAllCheck()
{
    var checkAll = true;
    var objForm = document.forms["emxTableForm"];
	if(!objForm)
	{
		var tableFrame = findFrame(parent, "listDisplay");		
		objForm = tableFrame.document.forms['emxTableForm'];
	}

    if (objForm && objForm.emxTableRowId)
    {
        if (objForm.emxTableRowId[0])
        {
            for (var i = 0; i < objForm.emxTableRowId.length; i++)
            {
                if(!objForm.emxTableRowId[i].checked)
                {
                  checkAll=false;
                  break;
                }
            }
        } else {

                if(!objForm.emxTableRowId.checked)
                 {
                    checkAll=false;
                 }
        }

      objForm.chkList.checked=checkAll;
    }
}
//Added on 27/3/2004 for AEF style toolbar change - End

    function findHiddenFrame(objWindow, strName) {

        if( ! objWindow.frames )
            return null;
        var objFrame = objWindow.frames[strName];
        if (!objFrame) {
            for (var i=0; i < objWindow.frames.length && !objFrame; i++)
            {
                objFrame = findFrame(objWindow.frames[i], strName);
            }
        }

        return objFrame;
    }

	function updateCheck()
	{
		var objForm = document.forms[0];
		var chkList = objForm.chkList;
		chkList.checked = false;
	}


    function checkAll()
    {
		var objForm = document.emxTableForm;
		if(!objForm)
		{
			var tableFrame = findFrame(parent, "listDisplay");
			objForm = tableFrame.document.forms['emxTableForm'];
		}

		if ( objForm && objForm.emxTableRowId)
		{
		  for (var i = 0; i < objForm.elements.length; i++)
		  {
			  var checkbox = objForm.elements[i];

			  if ((checkbox.name == 'emxTableRowId') && (checkbox.type == 'checkbox'))
			  {
				  checkbox.checked = objForm.chkList.checked;
				  var strID = checkbox.value;
				  if (checkbox.checked)
					register(strID);
				  else
					unregister(strID);
			  }
		  }
		}
    }

    function reloadTable(sortKey, nextSortDirection, isWSType)
    {
        var url;
        if( isWSType != null && isWSType == "true" )
            url = "emxInfoTableWSBody.jsp?page=1";
        else
            url = "emxInfoTableAdminBody.jsp?page=1";

        if (nextSortDirection != null)
            url = url + "&sortDirection=" + nextSortDirection;

        // Change the sortColumnName in footer
        parent.listFoot.document.footerForm.sortColumnName.value = sortKey;
        parent.listFoot.document.footerForm.reSortKey.value = sortKey;
        var footerUrl = "emxInfoTableFooter.jsp?page=1&sortColumnName=" + sortKey;
        document.emxTableForm.action = footerUrl;
        document.emxTableForm.target = "listFoot";
        document.emxTableForm.submit();
        document.emxTableForm.reSortKey.value = sortKey;
        document.emxTableForm.sortColumnName.value = sortKey;
        document.emxTableForm.action = url;
        document.emxTableForm.target = "_self";
        document.emxTableForm.submit();
    }

	function reloadDashboardTable()
    {
	 var toolBarFrame;
	 if (parent.frames){
		toolBarFrame = findFrame(parent, "listHead");
		if (!toolBarFrame){
			toolBarFrame = parent.frames[0];
		}
	 }
	 if(window.frameName == "navigateFrame")
		ids = "";
	 else
		parent.ids = "";

	 if (toolBarFrame && toolBarFrame.toolbars && toolBarFrame.toolbars.setListLinks) {
		toolBarFrame.toolbars.setListLinks( false);
	 }
		document.emxTableForm.action = "emxInfoTableAdminBody.jsp?page=current&refresh=false";
		document.emxTableForm.target = "_self";
		document.emxTableForm.submit();
    }

    function emxTableColumnLinkClick(href, width, height, modal, target)
    {
        var url = href;
        var windowObject;
        var targetFrame;

        if (target == "popup")
        {
            if (modal == "true")
                windowObject = showModalDialog(url, width, height);
            else
                windowObject = showNonModalDialog(url, width, height);
        } else {

            targetFrame = findFrame(top, target);

            //if there is a target, assign the form's target to it
            if (targetFrame)
            {
                document.emxTableForm.target = targetFrame.name;

                //assign the URL to the form's action (NCZ, 1/15/02)
                document.emxTableForm.action = href;

                //submit the form (NCZ, 1/15/02)
                document.emxTableForm.submit();
            }
            else //check if the frame is in the parent window
            {
                if( parent.window.opener )
                    targetFrame = findFrame(parent.window.opener, target);

                if(targetFrame)
                {
                    //Modified to fix the issue related to multiple windows
                    //opened and the table always refreshing the original window

                    //document.emxTableForm.target = targetFrame.name;

                    //assign the URL to the form's action
                    //document.emxTableForm.action = href;

                    //submit the form
                    //document.emxTableForm.submit();

                    targetFrame.location = href;

                }
		else 
		{
		
		   if( top.opener.top )
			targetFrame = findFrame(top.opener.top, target);
		    
		    if(targetFrame)
		    {
			targetFrame.location = href;
		    }
                else 
		{
                    //alert("Unable to find the target frame : " + target);
                    windowObject = showNonModalDialog(url, '750', '600');
		}
                }
		
            }
        }
    }

    function onWSFilterOptionChange(){
        refresh();
    }

    function onFilterOptionChange(){
        var newInquiry= document.tableHeaderForm.filterTable.options[document.tableHeaderForm.filterTable.selectedIndex].value;
        var currentURL = parent.document.location.href;
        currentURL=removeFromUrl(currentURL,"selectedFilter");
        var newPageURL = "";
        if (currentURL.indexOf("?") == -1)
            newPageURL = currentURL + "?selectedFilter=" + newInquiry;
        else
            newPageURL = currentURL + "&selectedFilter=" + newInquiry;
        parent.document.location.href = newPageURL;
        return;
    }

    function refresh()
    {
        var pageUrl="";
        if( document.tableHeaderForm.workSpaceTable.selectedIndex == 0) //first option is choosen which is Admin table
        {
           pageUrl="emxInfoTable.jsp?IsAdminTable=true";
        }
        else //Choosesn table is Workspace table
        {
            //Resort column type is hard coded to "type" ( object ) for WS tables
            var newTable = document.tableHeaderForm.workSpaceTable.options[document.tableHeaderForm.workSpaceTable.selectedIndex].value;
            document.tableHeaderForm.WSTable.value=newTable;
            pageUrl="emxInfoTable.jsp?reSortKey=type";
        }
        var toFrom="*";
        if(document.tableHeaderForm.toDirection && document.tableHeaderForm.toDirection.checked)
        {
            toFrom="to";
        }
        if(document.tableHeaderForm.fromDirection && document.tableHeaderForm.fromDirection.checked)
        {
          if(toFrom=="*"){
            toFrom="from";
           }
          else {
            toFrom="*";
           }
        }
        pageUrl+="&toFrom=" + toFrom+"&page=1";
        document.tableHeaderForm.action = pageUrl;
        document.tableHeaderForm.target = "_parent";
        document.tableHeaderForm.submit();
        return;
    }

    function removeFromUrl(currentURL,key)
    {
        while(currentURL.indexOf(key)!=-1){
            var filterPoint = currentURL.indexOf(key);
            if (filterPoint > -1){
                var remainingURL = currentURL.substring(filterPoint,currentURL.length);
                var leftSideURL = currentURL.substring(0, filterPoint);
                var amppoint = remainingURL.indexOf("&");
                if(amppoint > -1)
                    remainingURL = remainingURL.substring(amppoint+1, remainingURL.length);
                else
                    remainingURL = "";
                currentURL = leftSideURL + remainingURL;
            }
        }
        return currentURL;
    }

    function refreshForConfigTable()
    {       		
	var pageUrl="";
        var contentFrame = parent.frames["listDisplay"];
        var tableNameWithoutPrefix = document.tableHeaderForm.workSpaceTable.options[document.tableHeaderForm.workSpaceTable.selectedIndex].value;
	var isAdminTable = contentFrame.document.emxTableForm.IsAdminTable.value;
        if(isAdminTable == "true") //Choosen table is admin table
        {
           pageUrl="emxInfoTable.jsp?IsAdminTable=true&selectedTable=" + tableNameWithoutPrefix;
        }
        else //Choosesn table is Workspace table
        {
            //Resort column type is hard coded to "type" ( object ) for WS tables
            //document.tableHeaderForm.WSTable.value=newTable;
            pageUrl="emxInfoTable.jsp?reSortKey=type&selectedTable=" + tableNameWithoutPrefix;
        }
        var toFrom="*";
        if(document.tableHeaderForm.toDirection.checked)
        {
            toFrom="to";
        }
        if(document.tableHeaderForm.fromDirection.checked)
        {
          if(toFrom=="*"){
            toFrom="from";
           }
          else {
            toFrom="*";
           }
        }
        pageUrl+="&toFrom=" + toFrom+"&page=1";
        document.tableHeaderForm.action = pageUrl;
        document.tableHeaderForm.target = "_parent";
        document.tableHeaderForm.submit();
        return;
    }

    //Function to update the table body when the table option is changed
    function onWSTableOptionChange(tableType, integrationName)
    {
		var curHref			= parent.window.location.href;
		var hrefArray		= curHref.split('?');
		var hrefParams		= '';
		var paramArray		= null;
		var filteredParams	= '';

		if (hrefArray)
		{
		   hrefParams = hrefArray[1];
		}
		
		if (hrefParams && hrefParams != 'hrefParams')
		{ 
			paramArray = hrefParams.split('&');

			if (null != paramArray)
			{
				 for (var i = 0; i < paramArray.length; i++)
				 {
				   var paramNameValueArray = paramArray[i].split('=');
						
				   if (paramNameValueArray)
				   {
						var paramName	= paramNameValueArray[0];
						var paramValue	= paramNameValueArray[1];

						if(paramName == 'integrationName')
						{
							paramValue = integrationName;
						}

						if (paramName == null || paramName == '' || paramName == 'IsAdminTable' || paramName == 'selectedTable' || paramName == 'reSortKey') 
							continue;
					
						filteredParams += '&' + paramName + '=' + paramValue;
				   }
				}
			}
		}
		
		//XSSOK
		var relatedPage='<%=emxGetSessionParameter(request, "RelatedPage")%>';		
        if(relatedPage=="true")
            refreshForConfigTable();
        else
		{
		if(document.tableHeaderForm.workSpaceTable.selectedIndex == 0)
         {
var tableNameWithoutPrefix	= "DSCDefault";
          }	
		  else{
			var contentFrame	= parent.frames["listDisplay"];	
			var pageUrl			= "";

			var tableNameWithoutPrefix	= document.tableHeaderForm.workSpaceTable.options[document.tableHeaderForm.workSpaceTable.selectedIndex].value;
			var isAdminTable			= contentFrame.document.emxTableForm.IsAdminTable.value;
			}
			if(isAdminTable == "true")
			{
			   pageUrl="emxInfoTable.jsp?IsAdminTable=true&selectedTable=" + tableNameWithoutPrefix;			   
			}
			else
			{
				pageUrl="emxInfoTable.jsp?reSortKey=type&selectedTable=" + tableNameWithoutPrefix;
			}

			document.tableHeaderForm.action = pageUrl + filteredParams;
			document.tableHeaderForm.target = "_parent";
			document.tableHeaderForm.submit();
        }
        return;
    }

    // Printer Friendly window variable.
    var printDialog = null;

    function openPrinterFriendlyPage()
    {
        var strURL = "";
        if (parent.frames[0] && parent.frames[0].name == 'listFilter')
	 currentURL = parent.frames[2].document.location.href;
        else
        currentURL = parent.frames[1].document.location.href;
        if (currentURL.indexOf("?") == -1)
            strURL = currentURL + "?PFmode=true";
        else
            strURL = currentURL + "&PFmode=true";
           //make sure that there isn't a window already open
        if (!printDialog || printDialog.closed) {

            var strFeatures = "scrollbars=yes,toolbar=yes,location=no,resizable=yes";
            printDialog = window.open("emxBlank.jsp", "PF" + (new Date()).getTime(), strFeatures);

            //set focus to the dialog
            printDialog.focus();

        } else {
                    //if there is already a window open, just bring it to the forefront (NCZ, 6/4/01)
            if (printDialog) printDialog.focus();
        }

        strTarget = printDialog.name;
        // alert("strTarget : " + strTarget);

        // var pageUrl = "emxTableBody.jsp?PFmode=true";
        var pageUrl = strURL;
        parent.listDisplay.document.emxTableForm.action = pageUrl;
        parent.listDisplay.document.emxTableForm.target = strTarget;
        parent.listDisplay.document.emxTableForm.submit();
    }


    function openWindow(strURL)
    {
        window.open(strURL);
    }

	function displayLockUnLock(strURL)
	{
	   //alert(strURL);
	   var targetFrame = findHiddenFrame(top, "hiddenTableFrame");	   	   
	   if(targetFrame != null)
		targetFrame.location.href=strURL;
	}

	function synchEBOM(integrationName, paramList)
	{
	   var msg = callCommandHandler(integrationName, "sendRequestToServerForBrowserCommands", paramList);
	   alert(msg);
	}

	//added to support preview in Purge page by alok.
	function previewObject(busId, previewFormatName, previewFileName)
	{
	  window.open("", "previewWindow", "height=500,width=600,left=0,top=0,toolbar=0,status=0,menubar=0,scrollbars=1,resizable=1");
	 
	  document.forms['previewForm'].BusObjectId.value = busId;    
	  document.forms['previewForm'].FormatName.value = previewFormatName;
	  document.forms['previewForm'].FileName.value = previewFileName;
	  document.forms['previewForm'].target = "previewWindow";
	  document.forms['previewForm'].submit();
	}
</script>

<%!

//This function is used to sort objects in Admin Tables
static public MapList sortObjects(Context context, MapList relBusObjList, HashMap sortColumMap, String Direction, HashMap paramMap)
{
	/* IEF additions Start */
	//All JPOs access programMap to get GCOTable and LocaleLanguage. Hence putting
	//these params in programMap and removing from paramMap

	HashMap programMap = new HashMap();
	
	if(paramMap != null)
	{
		Object globalConfigObjectTable = paramMap.get("GCOTable");
		if(globalConfigObjectTable != null)
		{
			programMap.put("GCOTable", globalConfigObjectTable);
			paramMap.remove("GCOTable");
		}

		Object languageName = paramMap.get("LocaleLanguage");
		if(languageName != null)
		{
			programMap.put("LocaleLanguage", languageName);
			paramMap.remove("LocaleLanguage");
		}
	}
	/* IEF additions End */


    Vector sortColumnResult = new Vector(relBusObjList.size());
    UITable emxTableObject = new UITable();

    try {

        String sortKey = emxTableObject.getName(sortColumMap);
        String sortType = "string";

        if (emxTableObject.isSortAlpha(sortColumMap) )
            sortType = "string";
        else if ( emxTableObject.isSortNumeric(sortColumMap) )
            sortType = "integer";

        String sortColumnprogramName = "";
        String sortColumnfunctionName = "";

        String sortColumnSelect = emxTableObject.getBusinessObjectSelect(sortColumMap);
        String sortColumnType = emxTableObject.getSetting(sortColumMap, "Column Type");

        if (sortColumnType != null && sortColumnType.length() > 0 )
        {
            if (sortColumnType.startsWith("program") )
            {
                sortColumnSelect = emxTableObject.getSetting(sortColumMap, "program");
                if (sortColumnSelect != null && sortColumnSelect.trim().length() > 0)
                {
                    sortColumnprogramName = emxTableObject.getSetting(sortColumMap, "program");
                    sortColumnfunctionName = emxTableObject.getSetting(sortColumMap, "function");
                }
                String format = emxTableObject.getSetting(sortColumMap, "format");
                if (null != format && format.length() > 0)
                   sortType = format;
            }
        } else {

            if (sortColumnSelect != null && sortColumnSelect.trim().length() > 0)
            {
                sortColumnType = "businessobject";
                sortColumnSelect = UIExpression.substituteValues(context, sortColumnSelect);
            } else {
                sortColumnSelect = emxTableObject.getRelationshipSelect(sortColumMap);

                if (sortColumnSelect != null && sortColumnSelect.trim().length() > 0)
                {
                    sortColumnType = "relationship";
                    sortColumnSelect = UIExpression.substituteValues(context, sortColumnSelect);
                }
            }
        }

        if (sortKey != null && sortKey.length() != 0)
        {
            String selectString = sortColumnSelect;
            String selectType = sortColumnType;
            StringList sl = null;
            if(sortColumnSelect.compareToIgnoreCase("object") == 0){
                //incase of Object Link the column is sorted on "TNR" basis
                sl = new StringList(3);
                sl.addElement("type");
                sl.addElement("name");
                sl.addElement("revision");
            }else{
                sl = new StringList(1);
                sl.addElement(selectString);
            }

            if (selectType != null && selectType.equalsIgnoreCase("businessobject"))
            {
                String bol_array[] = new String[relBusObjList.size()];
                HashMap elementMap = new HashMap();

                for (int i = 0; i < relBusObjList.size(); i++)
                    bol_array[i] = (String)((HashMap)relBusObjList.get(i)).get("id");


                // context.setTrace ("SQLTrace_05292002.log", "SQL", true, false);
                // context.setTrace ("SQLTrace2.log", "SQL", true, false);
                // long time2Check = System.currentTimeMillis();
		   BusinessObjectWithSelectList bwsl = BusinessObjectWithSelect.getSelectBusinessObjectData(context, bol_array, sl);
                   if(sortColumnSelect.compareToIgnoreCase("object") == 0){
                       //incase of Object Link the column is sorted on "TNR" basis
                       for (int i = 0; i < relBusObjList.size(); i++)
                        ((HashMap)relBusObjList.get(i)).put("sortColumn", bwsl.getElement(i).getSelectData("type")+bwsl.getElement(i).getSelectData("name")+bwsl.getElement(i).getSelectData("revision") );
                    }else{
                       for (int i = 0; i < relBusObjList.size(); i++)
                        ((HashMap)relBusObjList.get(i)).put("sortColumn", bwsl.getElement(i).getSelectData(selectString) );
                    }


            } else if (selectType != null && selectType.equalsIgnoreCase("relationship")) {
                String rel_array[] = new String[relBusObjList.size()];
                //HashMap elementMap = new HashMap();
                for (int i = 0; i < relBusObjList.size(); i++)
                {
                    rel_array[i] = (String)((HashMap)relBusObjList.get(i)).get("id[connection]");
                }
		RelationshipWithSelectList rwsl = Relationship.getSelectRelationshipData(context, rel_array, sl);
                for (int i = 0; i < relBusObjList.size(); i++)
                {
                    RelationshipWithSelect rws = (RelationshipWithSelect)rwsl.elementAt(i);
                    Hashtable columnInfo = rws.getRelationshipData();
                    ((HashMap)relBusObjList.get(i)).put("sortColumn", (String)columnInfo.get(selectString) );
                }
            } else if (selectType != null && selectType.startsWith("program")) {

                if (sortColumnprogramName != null && sortColumnfunctionName != null)
                {
                    programMap.put("objectList", relBusObjList);
					programMap.put("paramList", paramMap);

                    String[] methodargs = JPO.packArgs(programMap);

                    sortColumnResult = (Vector)JPO.invoke(context, sortColumnprogramName, null, sortColumnfunctionName, methodargs, Vector.class);

                    if (sortColumnResult != null && sortColumnResult.size() > 0)
                    {
                        for (int i = 0; i < relBusObjList.size(); i++)
                            ((HashMap)relBusObjList.get(i)).put("sortColumn", (String)sortColumnResult.elementAt(i) );
                    }
                }
            }
        }

		//Bug fix:285519 date column sorting -start
		if(sortColumnSelect != null   ) {
			try{
				//handle column expression with attribute of type date
				if( sortColumnSelect.indexOf("attribute[") != -1 ) {
					int indexOfAttribute = sortColumnSelect.lastIndexOf("attribute[");
					int indexOfBracket = sortColumnSelect.lastIndexOf("]");
					String attributeName = sortColumnSelect.substring(indexOfAttribute+10,indexOfBracket);
					AttributeType attrType = new AttributeType(attributeName);
					attrType.open(context);
					String typeOfAttr =  attrType.getDataType();
					if("timestamp".equals(typeOfAttr)) {
						sortType = "date";
					}
					else if("real".equals(typeOfAttr)) {
						sortType = "real";
					}
					else if("integer".equals(typeOfAttr)) {
						sortType = "integer";
					}

				} else if(sortColumnSelect.equalsIgnoreCase("modified") || sortColumnSelect.equalsIgnoreCase("originated")){
					sortType = "date";	
				}	
			} catch(Exception err ) {}
		}
		//Bug fix:285519 date colum sorting -end

        relBusObjList.sortStructure("sortColumn", Direction, sortType);

        // Rmove the sort column details
        for (int i = 0; i < relBusObjList.size(); i++)
            ((HashMap)relBusObjList.get(i)).remove("sortColumn");

    } catch (Exception ex) {
        System.out.println("emxTable:sortObjects Error- " + ex.toString());
        return relBusObjList;
    }

    return relBusObjList;
}

%>



<%!
static public String parseTableHeader(ServletContext application, Context context, String header, String objectId, String suiteKey, String langStr)
{

    String registeredSuite = "";
    String suiteDir = "";
    String stringResFileId = "";

    try {

        if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
            registeredSuite = suiteKey.substring(13);
        else if( suiteKey != null)
             registeredSuite = suiteKey;
    

        if ( (registeredSuite != null) && (registeredSuite.trim().length() > 0 ) )
        {
          suiteDir = UINavigatorUtil.getRegisteredDirectory(application, registeredSuite);
          stringResFileId = UINavigatorUtil.getStringResourceFileId(application, registeredSuite);
        }

        if( header != null && header.trim().length() > 0 )
        {
            // Get the label from string resource, if it does not contain macros.
            header = UINavigatorUtil.getI18nString(header, stringResFileId , langStr);

            // Then if the label contain macros, parse them
            if (header.indexOf("$") >= 0 )
            {
                if (objectId != null && objectId.length() > 0 )
                {
                    header = UIExpression.substituteValues(context, header, objectId);
                } else {
                    header = UIExpression.substituteValues(context, header);
                }
            }
        }
    } catch (Exception ex) {
        System.out.println("emxTable:parseTableHeader - error : " + ex.toString() );
        return header;
    }

    return header;
}

%>

<%!
    static public String emxGetSessionParameter(HttpServletRequest request, String parameter)
    {
        String parameterValue = emxGetParameter(request,parameter);
        if(parameterValue==null || parameterValue.equals("null")){
        String timeStamp = Request.getParameter(request, "timeStamp");
        if(timeStamp!=null && timeStamp.trim().length()>0 && !timeStamp.equals("null")){
        HttpSession session = request.getSession();
        HashMap map = (HashMap)session.getAttribute("ParameterList" + timeStamp);
        if(map!=null)
        parameterValue =(String) map.get(parameter);
        }
        }
        return parameterValue;
     }

     public static HashMap getHashMap(Object map)
     {
         HashMap objMap = null;
         try
         {
              objMap = (HashMap)map;
              return objMap;
         }
         catch (ClassCastException e)
         {
              objMap = new HashMap();
              objMap.putAll((Map)map);
              return objMap;
         }
    }

%>


