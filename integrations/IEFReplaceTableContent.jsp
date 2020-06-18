<%--  IEFReplaceTableContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import = "com.matrixone.MCADIntegration.server.beans.*, com.matrixone.MCADIntegration.utils.*" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<html>
<head>
</head>
<script language="JavaScript" src="scripts/IEFUIConstants.js"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%

MCADIntegrationSessionData intSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
Context context = intSessionData.getClonedContext(session);
MCADServerResourceBundle srvResourceBundle	= intSessionData.getResourceBundle();
String replaceSelectDesign					= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceSelectDesign");
String replaceDesignNotValid				= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignNotValid");
String replaceDesignSameAsCurrent			= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignSameAsCurrent");
String replaceDesignCircularRef				= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignCircularRef");
String replaceDesignNotValidForReplace		= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignNotValidForReplace");
String replaceSelectParentDesign			= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceSelectParentDesign");
String replaceSelectParentDesignAtleastOne	= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceSelectParentDesignAtleastOne");
String replaceDesignsNotValid				= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignsNotValid");
String replaceDesignConfirmation			= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignConfirmation");
String replaceAllDesignsInValid				= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceAllDesignsInValid");
String replaceDesignInValid					= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignInValid");
String replaceDesignIsLocked				= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignIsLocked");
String replaceDesignCannotSelect			= srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignCannotSelect");

%>

<body onload="javascript:onLoad()">
<form name="WhereUsedVersions">
<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<link rel="stylesheet" href="../integrations/styles/emxIEFCommonUI.css" type="text/css">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION::DSCDerivedOutput.jsp");
%>
<input type=hidden name=mode value="">
<table cellpadding="0" cellspacing="0" width="100%">

<tr>
 <th class=sorted colspan="5" width="35%">
 <!--XSSOK-->
 <table cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.CurrentDesignDetails")%></th></tr>
 </table>
 </th>
 <th class=sorted colspan="5" width="65%">
 <!--XSSOK-->
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.ParentDesignDetails")%></th></tr>
 </table>
 </th>
</tr>
<tr>
 <th width="5%" class=sorted><input name="selectAll" type=checkbox onClick="onTopCheckBox()">&nbsp;</th>
 <th class=sorted>
 <!--XSSOK-->
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Type")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <!--XSSOK-->
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Name")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <!--XSSOK-->
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Title")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <!--XSSOK-->
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Revision")%></th></tr>
 </table>
 </th>
  <th class=sorted>
  <!--XSSOK-->
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Type")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <!--XSSOK-->
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Name")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <!--XSSOK-->
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Title")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <!--XSSOK-->
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Revision")%></th></tr>
 </table>
 </th>
 <th class=sorted>
 <!--XSSOK-->
 <table border="0" cellspacing="0" cellpadding="0"> <tr><th><%=srvResourceBundle.getString("mcadIntegration.Server.ColumnName.Remarks")%></th></tr>
 </table>
 </th>
</tr>


<%
   	String objectID								=Request.getParameter(request,"objectId");
	String headerKey							=Request.getParameter(request,"header");
	String target								=Request.getParameter(request,"targetFrame");
	String selectedRows							=Request.getParameter(request,"selectedRows");
	String integrationName						= "";
	String headerString							= "";
	MCADMxUtil util								= null;
	Context _context							= Framework.getFrameContext(session);
	MCADGlobalConfigObject globalConfigObject	= null;

	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String acceptLanguage						= request.getHeader("Accept-Language");

	if(integSessionData == null)
	{
		MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(acceptLanguage);
        String errorMessage								= serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");

		emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{
		if(target == null || "null".equalsIgnoreCase(target))
			target = "popup";

		util				= new MCADMxUtil(_context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
		integrationName		= util.getIntegrationName(_context, objectID);
		headerString		= integSessionData.getStringResource(headerKey);
		globalConfigObject	= integSessionData.getGlobalConfigObject(integrationName, _context);
	}

	Enumeration enumParamNames	= emxGetParameterNames(request);
	HashMap paramMap			= new HashMap();

	while(enumParamNames.hasMoreElements())
	{
		String paramName	= (String) enumParamNames.nextElement();
		String paramValue	= (String)emxGetParameter(request, paramName);

		if (paramValue != null && paramValue.trim().length() > 0 )
			paramMap.put(paramName, paramValue);
	}

	paramMap.put("languageStr",acceptLanguage);
	HashMap gcoMap = new HashMap();

	gcoMap.put(integrationName, globalConfigObject);
	paramMap.put("selectedRows", selectedRows);
	paramMap.put("objectId", objectID);
	paramMap.put("GCOTable", gcoMap);
	paramMap.put("IntegrationName",integrationName);
	String[] intArgs = new String[]{};

	Hashtable whereUsedVersionsTable = (Hashtable)JPO.invoke(_context, "DSCReplaceWhereUsedParents", intArgs, "getWhereUsedChildrenVsParentsSelection", JPO.packArgs(paramMap), Hashtable.class);


	BusinessObject busObj = new BusinessObject(objectID);
	busObj.open(_context);
	String objName = busObj.getName();
	busObj.close(_context);

	int i									= 0;
	String parentMajorID					= "";
	String currentVersionMajorObjectType	= "";
	String currentVersionMajorObjectId		= "";
	String currentVerParentObjId			= "";
    String languageStr = request.getHeader("Accept-Language");
	if(whereUsedVersionsTable.size() != 0)
	{
		Enumeration otherCurrentVersionsList	= whereUsedVersionsTable.keys();
		String parentRemark						= "";
		BusinessObject majorObj					= null;
		BusinessObject minorObj					= null;
		boolean checkifMajorExists				= false;

		while(otherCurrentVersionsList.hasMoreElements())
		{
			String otherVersionId				= (String)otherCurrentVersionsList.nextElement();
			BusinessObject otherVersionObject	= new BusinessObject(otherVersionId);
			otherVersionObject.open(_context);

			String otherVersionObjectType		= otherVersionObject.getTypeName();
			String otherVersionObjectName		= otherVersionObject.getName();
			String otherVersionObjectRevision	= otherVersionObject.getRevision();
			String otherVersionObjectTitle		= util.getAttributeForBO(_context, otherVersionId, MCADMxUtil.getActualNameForAEFData(_context, "attribute_Title"));

			//We need to find out the type of the current biz obj( for its major and minors)
			majorObj  = util.getMajorObject(_context,otherVersionObject);

			if(majorObj == null)
			{
				minorObj						= otherVersionObject;
				checkifMajorExists				= false;
				currentVersionMajorObjectType	= otherVersionObject.getTypeName();
			}
			else
			{
			    majorObj.open(_context);
				checkifMajorExists = true;
				//Append the minor object type to the major;
				currentVersionMajorObjectType = majorObj.getTypeName();
			}

			Vector parentRemarks	= (Vector)whereUsedVersionsTable.get(otherVersionId);
			String parentId			= "";

			for ( int k=0; k<parentRemarks.size();k++)
			{
				Hashtable parentVsRemark	= (Hashtable) parentRemarks.get(k);
				Enumeration parentsList		=  parentVsRemark.keys();

				while( parentsList.hasMoreElements())
				{
					parentId				= (String) parentsList.nextElement();
					currentVerParentObjId	= parentId;
					String evenOrOdd		= (i%2 == 0 ? "even" : "odd");
					BusinessObject parentVersionObject = new BusinessObject(parentId);
					parentVersionObject.open(_context);

					String parentVersionObjectType		= parentVersionObject.getTypeName();
					String parentVersionObjectName		= parentVersionObject.getName();
					String parentVersionObjectRevision	= parentVersionObject.getRevision();
					String parentVersionObjectTitle		= util.getAttributeForBO(_context, parentId, MCADMxUtil.getActualNameForAEFData(_context, "attribute_Title"));
					parentRemark						= (String)parentVsRemark.get(parentId);
					i++;
					String childParentId = otherVersionId + "|" + parentId;
 %>
       <!--XSSOK-->
	   <tr class="<%= evenOrOdd %>">
	   <td width="10%" class=node>
	   <!--XSSOK-->
	   <input name="selectParent" id="<%=childParentId%>" type="checkbox" title="<%=parentRemark%>" onClick="onRowSelect(this)" ></td>

	   <!--XSSOK-->
       <td align="center" class=node>&nbsp;<%=MCADMxUtil.getNLSName(_context, "Type", otherVersionObjectType, "", "", languageStr)%></td>
	   <!--XSSOK-->
	   <td align="center" class=node>&nbsp;<%=otherVersionObjectName%></td>
	   <!--XSSOK-->
	   <td align="center" class=node>&nbsp;<%=MCADUtil.escapeStringForHTML(otherVersionObjectTitle) %></td>
	   <!--XSSOK-->
	   <td align="center" class=node>&nbsp;<%=otherVersionObjectRevision%></td>
	   <!--XSSOK-->
       <td align="center" class=node>&nbsp;<%=MCADMxUtil.getNLSName(_context, "Type",parentVersionObjectType, "", "", languageStr)%></td>
	   <!--XSSOK-->
	   <td align="center" class=node>&nbsp;<%=parentVersionObjectName%></td>
	   <!--XSSOK-->
	   <td align="center" class=node>&nbsp;<%=MCADUtil.escapeStringForHTML(parentVersionObjectTitle)%></td>
	   <!--XSSOK-->
	   <td align="center" class=node>&nbsp;<%=parentVersionObjectRevision%></td>
	   <!--XSSOK-->
	   <td align="center" class=node>&nbsp;<%=parentRemark%></td>
	  </tr>
	 <%
					parentVersionObject.close(_context);
				}
			}

		   otherVersionObject.close(_context);
		}

		StringBuffer minorsMajorBuf = new StringBuffer();
		Vector majorMinorList = null;
		if(checkifMajorExists == true)
		{
		  majorMinorList = util.getRevisionBoIdsOfAllStreams(_context,majorObj.getObjectId(),false);
		}
		else
		{
		  majorMinorList = util.getRevisionBoIdsOfAllStreams(_context,minorObj.getObjectId(),false);
		}

		if(majorObj != null)
		{
			majorObj.close(_context);
		}

		for(int k=0;k<majorMinorList.size();k++)
		{
			String id = (String) majorMinorList.get(k);
			if(k!= majorMinorList.size()-1 )
			{
				id = id + "|";
			}
			currentVersionMajorObjectId += id;
		}

		BusinessObject currVerParObject		= new BusinessObject(currentVerParentObjId);
		currVerParObject.open(_context);
		BusinessObject parentMajorObj		= util.getMajorObject(_context,currVerParObject);
		currVerParObject.close(_context);

		Vector parentMajorMinorList = null;
		if(parentMajorObj == null) // The major object is the currentVerParentObjId
		{
			parentMajorID = currentVerParentObjId;
		}
		else
		{
			parentMajorID = parentMajorObj.getObjectId(_context);
			//Obtained the major object id
		}

		parentMajorMinorList	=  util.getRevisionBoIdsOfAllStreams(_context,parentMajorID,false);
		String currParentID		= "";
		for(int z=0;z<parentMajorMinorList.size();z++)
		{
			String tempID	= (String) parentMajorMinorList.get(z);
			currParentID	= currParentID + tempID + "|";
		}
		parentMajorID				= currParentID;
		StringBuffer parentIDBuf	= new StringBuffer(parentMajorID);
		parentIDBuf.deleteCharAt(parentMajorID.length()-1);
		parentMajorID = parentIDBuf.toString();
	}
	else
	{
		Hashtable msgTable = new Hashtable();
		msgTable.put("objName", objName);
		String errMsg = integSessionData.getStringResource("mcadIntegration.Server.Message.ReplaceDesignNotFound", msgTable);
		%>
			<script type="text/javascript">
			alert("<%=errMsg%>");
			parent.window.close();
			 </script>
		<%
	}
 %>
<input type=hidden name="generatedRows" value="<%=i%>">
<!--XSSOK-->
<input type=hidden name="currentObjectType" value="<%=currentVersionMajorObjectType%>" id="<%=currentVersionMajorObjectId%>" >
<!--XSSOK-->
<input type=hidden name="parentObjectIds"   id="<%=parentMajorID%>" >
</table>
<input type=hidden name="objectID" value ="<xss:encodeForHTMLAttribute><%=objectID%></xss:encodeForHTMLAttribute>">
</form>
<FORM METHOD=POST ACTION="">
<input type=hidden name="replaceWithObject" value="">
<!-- the value can be designer,collections,manual-->
<input type=hidden name="replaceWithSetter" value="">
</FORM>
<script type="text/javascript">
//This function will be called when the top check box is selected.
//The top check box will select all the remaining check boxes
var totalRows = 0;
var currentRow = 0;

var frameheaderFrame = null;
var framecontentFrame = null;
var framefooterFrame = null;
function init()
{
	frameheaderFrame = findFrame(parent,"headerFrame");
	framecontentFrame = findFrame(parent,"contentFrame");
	framefooterFrame = findFrame(parent,"footerFrame");
}
function onTopCheckBox()
{
	//Get the list of the check boxes
	var field = document.forms[0].selectParent;
	var topField = document.forms[0].selectAll;
	var rowCount =  document.forms[0].generatedRows.value;
	//If the field.length has to be valid then the total no of rows has to be greater than 1
	//Travel the list of the check boxes and set them to the state of the topmost check box.
    totalRows = 0;
    currentRow = 0;
	for (i = 0; (rowCount > 1 && i < field.length); i++)
	{
		//Check if the field is disabled.This could occur for locked/finalised parents.
		if( field[i].disabled == false ) //Field is not disabled.
		{
			//Set the check box state to the value of the topmost check box state;
			field[i].checked = topField.checked;
			if(topField.checked == true)
			{
			    totalRows++;
			    currentRow++;
			}
			else
			{
				totalRows = 0;
				currentRow = 0;
			}
		}
	}
	if(rowCount ==1) //Special handling since row generated is only 1
	{
		//Check if the field is disabled.This could occur for locked/finalised parents.
		if( field.disabled == false ) //Field is not disabled.
		{
			//Set the check box state to the value of the topmost check box state;
			field.checked = topField.checked;
			if(topField.checked == true)
			{
			    totalRows++;
			    currentRow++;
			}
			else
			{
				totalRows = 0;
				currentRow = 0;
			}
		}

	}
}


function onRowSelect(currentField)
{
	    var field = document.forms[0].selectParent;
		var rowCount =  document.forms[0].generatedRows.value;
		//When the form loads initially for the first time count
		//calculate the number of rows which are enabled.
		if(totalRows == 0  )
		{
			for(i=0; (rowCount > 1 && i<field.length); i++)
			{
				if( field[i].disabled == false ) //Field is not disabled.
				{
					//Set the check box state to the value of the topmost check box state;
					totalRows++;
				}
			}
			if(rowCount == 1)
			{
				if( field.disabled == false)
				{
					totalRows++;
				}
			}
		}

		//Check if the selection is made by the user
		if(currentField.checked == true)
		{
		   currentRow++;
		}
		else
		{
			currentRow--;
		}
		if( currentRow == totalRows)
		{
			document.forms[0].selectAll.checked = true;
			//totalRows = 0;
		}
		if( currentRow == 0)
		{
			document.forms[0].selectAll.checked = false;
			totalRows = 0;
		}

	}

function onLoad()
{
	init();
	processRow();
}

function processRow() //Called when the body loads
{
	var field = document.forms[0].selectParent;
	//Special handling for single row since the field.length is undefined  if only 1 row is selected.
	//Here you need to differentiate if the field.length is defined or undefined.
	//So a hidden variable is used in the form for generatedRows so that the exact number of rows
	//generated on the page are calculated.

	var genRows = document.forms[0].generatedRows;
	var genRowCount = genRows.value;

	if(genRowCount > 1)
	{
	  var rows = field.length;
	  for(var i=0; i < rows; i++)
	   {
		 var remark = field[i].title;
		 if(remark.length > 1)
		  {
			field[i].disabled=true;
		  }
	   }
	}
	if(genRowCount ==1)
	{
		var remark = field.title;
		if(remark.length > 1)
		{
			field.disabled = true;
		}
		return;
	}

}
function setSelectedObjIdForReplace(busID)
{
	 document.forms[1].replaceWithObject.value = busID;

	var errorMessage	= "";
	//XSSOK
	var tnrString		= getTNRFromBusID('<%=integrationName%>', busID);
	var tnrArray		= tnrString.split(',');

	var selObjType	= tnrArray[0];
	var selObjName	= tnrArray[1];
	var selObjRev	= tnrArray[2];

	var currentObjMajorType = document.forms[0].currentObjectType.value;
	var currentObjMajorId   = document.forms[0].currentObjectType.id;

	if(selObjType != currentObjMajorType)
	    //XSSOK
		errorMessage = "<%=srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignChooseType")%>" + currentObjMajorType;
	else
	{
		//The currObjMajorId has a list of the majors and the minors.
		var objectIDArray	= currentObjMajorId.split("|");

		for(i=0; i<objectIDArray.length; i++)
		{
		   if(busID == objectIDArray[i])
		   {
		        //XSSOK
				errorMessage = "<%=srvResourceBundle.getString("mcadIntegration.Server.Message.ReplaceDesignSameRevVer")%>";
				break;
		   }
		}
    }

	if(errorMessage == "")
	{
		frameheaderFrame.document.forms['replaceWith'].txtName.value = selObjName;
		frameheaderFrame.document.forms['replaceWith'].txtRev.value	 = selObjRev;
		document.forms[1].replaceWithSetter.value="designer";
	}

	return errorMessage;
}

function setSelectedObjForReplace(busID,selObjType,selObjName,selObjRev)
{
	if(busID && ( selObjType.length==0 || selObjName.length==0 || selObjRev.length==0) )
	{
	   //Set using the collection search flow
       setSelectedObjIdForReplace(busID);
       //XSSOK
	   var tnrString = getTNRFromBusID('<%=integrationName%>', busID);
	   var tnrArray  = tnrString.split(',');

	   var selObjType	= tnrArray[0];
	   var selObjName	= tnrArray[1];
	   var selObjRev	= tnrArray[2];

	   var length = frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.options.length;
		for(var i=0;i<length; i++)
		{
			if(frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.options[i].value == selObjType)
			{
				frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.selectedIndex=i;
			}
		}
		frameheaderFrame.document.forms['replaceWith'].txtName.value=selObjName;
		frameheaderFrame.document.forms['replaceWith'].txtRev.value=selObjRev;
        //The value is set by collections
		document.forms[1].replaceWithSetter.value="collections";

	}
	else //Using the designer search.
	{
		var length = frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.options.length;
		for(var i=0;i<length; i++)
		{
			if(frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.options[i].value == selObjType)
			{
				frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.selectedIndex=i;
			}
		}
		frameheaderFrame.document.forms['replaceWith'].txtName.value=selObjName;
		frameheaderFrame.document.forms['replaceWith'].txtRev.value=selObjRev;
        setSelectedObjIdForReplace(busID);
        //The value is set by designer
		document.forms[1].replaceWithSetter.value="designer";
	}
}
function createChildParentMap(qualifiedRows)
{
    var field = qualifiedRows;
	var childVsParent = new Array();
	if(field.length > 1 )
	{
		for(i=0;i<field.length;i++)
		{
			var id =  field[i].id;
			childVsParent[i] = [ id ] + '~';
		}
	}
	else
	{
		var id =  field[0].id;
		childVsParent[0] = [ id ]+ '~';
    }
	return childVsParent;
}
function isSelfSelectedTNR(type,name,revision)
{
	var result = false;
	var typeSelectedIndex = frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.selectedIndex;
	var selObjType = frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.options[typeSelectedIndex].value;
	if( frameheaderFrame.document.forms['replaceWith'].txtName.value == name &&
		frameheaderFrame.document.forms['replaceWith'].txtRev.value == rev &&
		selObjType == type)
	{
		result = true;
	}

	return result;

}
function getTypeForReplaceWith()
{
	var typeSelectedIndex = frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.selectedIndex;
	var selObjType = frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.options[typeSelectedIndex].value;
	return selObjType;
}
function getNameForReplaceWith()
{
   var name = frameheaderFrame.document.forms['replaceWith'].txtName.value;
   return name;
}
function getRevisionForReplaceWith()
{
   var rev = frameheaderFrame.document.forms['replaceWith'].txtRev.value;
   return rev;
}
function isSelfSelected(selfIDs,replaceWithID)
{
	var result = false;
	var self   = selfIDs.split('|');
	for(i=0;i<self.length;i++)
	{
		var item = self[i];
		if(item == replaceWithID)
		{
			result = true;
		}
	}
	return result;
}
function checkForCircularReference(parentlist,replaceWith)
{
	var result = false;
	var parents = parentlist.split('|');
	for(i=0;i<parents.length;i++)
	{
		var item = parents[i];
		if(item ==  replaceWith)
		{
			result = true;
		}
	}
	return result;
}
//called when the done button is hit.
var currentWindow = null;
function submitData()
{
    //We need to check if all the selected design are invalid. If yes,
	//dont allow the user to proceed further.
	var outcome = checkIfAllDesignAreInvalid();
	if(outcome)
	{
		return;
	}
	if( frameheaderFrame.document.forms['replaceWith'].txtName.value == "" ||
		frameheaderFrame.document.forms['replaceWith'].txtRev.value == "" )
	{
	    //XSSOK
		window.alert("<%=replaceSelectDesign%>");
		return;
	}
	//User typed in manually
	if(document.forms[1].replaceWithSetter.value=="manual")
	{
		var isInputValid = checkUserInput();

		if(isInputValid == "false")
		{
		    //XSSOK
			window.alert("<%=replaceDesignNotValid%>");
			return;
		}
		else
		{
			var id = getInputBusID();
			var lockDetails = isLocked(id);
			var lockArr = lockDetails.split('|');

			if(lockArr[0] == "false")
			{
			    //XSSOK
				window.alert("<%=replaceDesignIsLocked%>"+lockArr[1]+' '+"<%=replaceDesignCannotSelect%>");
				return;
			}
			else if(lockArr[0] == "true" || lockArr[0] == "")
			{
				document.forms[1].replaceWithObject.value = id;
			}

		}
	}

	//Check for the self replacement and avoid it.
	var checkForValidity = framecontentFrame.document.forms[1].replaceWithObject.value;
	var selfIDs        = document.forms[0].currentObjectType.id;
	var isSelfSelected = this.isSelfSelected(selfIDs,checkForValidity);
	if(isSelfSelected)
	{
	    //XSSOK
		alert("<%=replaceDesignSameAsCurrent%>");
		return;
	}

	//Check for the cicular reference.
	var checkForCirRef = framecontentFrame.document.forms[1].replaceWithObject.value;
	var isCircularReference = checkForCircularReference(document.forms[0].parentObjectIds.id,checkForCirRef);
	if(isCircularReference)
	{
	    //XSSOK
		alert("<%=replaceDesignCircularRef%>");
		return;
	}

	var field = document.forms[0].selectParent;
	var genRows = document.forms[0].generatedRows;
	var genRowCount = genRows.value;

	//These are the rows which are qualified for selection
	var rowSelCounter = 0;
	var qualifiedRows = new Array();
	//Special handling for single row.
	if(genRowCount == 1)
	{

		if(field.disabled == true)
		{
		    //XSSOK
			window.alert("<%=replaceDesignNotValidForReplace%>");
			return;
		}
		if(field.checked == false)
		{
		    //XSSOK
			window.alert("<%=replaceSelectParentDesign%>");
			return;
		}
		qualifiedRows[0] = field;
	}
	//Rows are valid only if generatedRows are > 1
	//check if atleast one design is selected for the replace operation.
	if(genRowCount > 1)
	{
		var rows = field.length;
		var disabledRows = 0;

		for(j=0;j<rows;j++)
		{
			if( field[j].checked == true)
			{
				qualifiedRows[rowSelCounter] = field[j];
				rowSelCounter++;
			}
			if( field[j].disabled == true)
			{
				disabledRows = 0;
			}
		}
		if(rowSelCounter == 0)
		{
		    //XSSOK
			window.alert("<%=replaceSelectParentDesignAtleastOne%>");
			return;
		}
		if(disabledRows == rows)
		{
		    //XSSOK
			window.alert("<%=replaceDesignsNotValid%>");
			return;
		}
	}

    //Create a map that holds the childVsParent
	var usrSelectedRows = createChildParentMap(qualifiedRows);
    var usrSelRows  = "";
	for(k=0;k<usrSelectedRows.length;k++)
	{
        usrSelRows = usrSelRows + usrSelectedRows[k];
	}

	var pageURL         = "IEFReplaceResultsFS.jsp"
    replaceWith         = framecontentFrame.document.forms[1].replaceWithObject.value;
	var replaceWithURL  = "?replaceWith=" + replaceWith;


	//Get the type of search
	var searchType = document.forms[1].replaceWithSetter.value;
	var searchTypeURL   ="&searchType=" + searchType;

	var usrSelRowsURL   = "&usrSelRowsForReplace=" + usrSelRows;
	var objectID        = document.forms[0].objectID.value;

	var objectIdURL     = "&objectId=" + objectID;
	var finalParamURL   = replaceWithURL + searchTypeURL + usrSelRowsURL + objectIdURL;
    //XSSOK
	var confirm = window.confirm("<%=replaceDesignConfirmation%>" + getTypeForReplaceWith()+ "   " +  getNameForReplaceWith() + "   " + getRevisionForReplaceWith() );
	if(confirm)
	{
		var fullURL = pageURL + finalParamURL;
		showIEFModalDialog(fullURL, '900', '500');
		quitWindow();

	}
	else
	{
		return;
	}
}
function quitWindow()
{
	if(isIE_M)
	{
   	parent.window.close();
	}
}
function cancelDialog()
{
   parent.window.close();
}
function disableDesigns()
{
	var field = document.forms[0].selectParent;
	var outcome = false;

	if(field[0])
	{
		var disabledRows = 0;
		for(j=0;j<field.length;j++)
		{

			if( field[j].disabled == false)
			{
				field[j].disabled = true;
			}
		}
	}
	else
	{
		if(field.disabled == false)
		{
			field.disabled = true;
		}
	}
	return outcome;
}
function checkIfAllDesignAreInvalid()
{
	var field = document.forms[0].selectParent;
	var outcome = false;
	if(field[0])
	{
		var disabledRows = 0;
		for(j=0;j<field.length;j++)
		{

			if( field[j].disabled == true)
			{
				disabledRows++;
			}
		}
		if(disabledRows == field.length)
		{
			    outcome = true;
				//XSSOK
				window.alert("<%=replaceAllDesignsInValid%>");

		}
	}
	else
	{
		if(field.disabled == true)
		{
			outcome = true;
			//XSSOK
			window.alert("<%=replaceDesignInValid%>");

		}
	}

	return outcome;
}
function showSearchDialog()
{

	//Check if all the rows of the form are disabled , If yes, don't proceed for
	//search operation.
	var outcome  = checkIfAllDesignAreInvalid();
	if(outcome)
	{
		return;
	}
	var currentObjMajorType = document.forms[0].currentObjectType.value;
	var currentObjMajorId   = document.forms[0].currentObjectType.id;
	var partURL = "../iefdesigncenter/DSCReplaceSearchWizardFS.jsp";
	var replaceParam ="?replacedObjectType=";
	var majorObjParam ="&currObjMajorId=";
	var fullURL  = partURL + replaceParam + currentObjMajorType + majorObjParam + currentObjMajorId;

	//Collect the versions of the current designs
	var field = document.forms[0].selectParent;
	showIEFModalDialog(fullURL, '700', '500');
	return;
}

function checkUserInput()
{
	var isObjectExists = "false";
	var typeSelectedIndex	= frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.selectedIndex;
	var selObjType			= frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.options[typeSelectedIndex].value;
	var selObjName			= frameheaderFrame.document.forms['replaceWith'].txtName.value;
	var selObjRev			= frameheaderFrame.document.forms['replaceWith'].txtRev.value;
	//XSSOK
    isObjectExists = validateBusObject('<%=integrationName%>', selObjType, selObjName, selObjRev);
	return isObjectExists;
}
function getInputBusID()
{
	var busID = "";
	var typeSelectedIndex	= frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.selectedIndex;
	var selObjType			= frameheaderFrame.document.forms['replaceWith'].replaceTypeComboControl.options[typeSelectedIndex].value;
	var selObjName			= frameheaderFrame.document.forms['replaceWith'].txtName.value;
	var selObjRev			= frameheaderFrame.document.forms['replaceWith'].txtRev.value;
	//XSSOK
    busID = getBusIDFromTNR('<%=integrationName%>', selObjType, selObjName, selObjRev);
	return busID;
}

function isLocked(busID)
{
	var lockStatus = "false";
	//XSSOK
	lockStatus = checkIfLocked('<%=integrationName%>',busID);
	return lockStatus;
}


 </script>
</body>
</html>
