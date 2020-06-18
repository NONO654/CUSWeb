
<%--  emxCommonSelectObjects.jsp  -

   Intermediate JSP to update the fields by the object Id of the selected Object

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonSelectObjects.jsp.rca 1.17 Wed Oct 22 16:18:42 2008 przemek Experimental przemek $";
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file="emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.common.Search"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>

<%!
  private static final String COMPONENT_FRAMEWORK_BUNDLE = "emxComponentsStringResource";
  private static final String ALERT_MSG = "emxComponents.Search.Error.24";
  
%>
<%
/* Modified by <Infosys> On <26th MAY 2003>
   For the following Bug
   <Proper display of Error Message when the operation fails>
   Fixed as Follows:
   <The corrresponding Errors are caught and added to Session>
*/

/* Modified by <Infosys> On <12th AUG 2003>
   For the following Bug
   <Product : When click Submit in a find select screen  with no item checked  getting an error: business type "" does not exist>
   Fixed as Follows:
   <Added a condition and throwing exception if no row is selected>
*/
%>

<%
try
{
  String timeStamp = emxGetParameter(request, "timeStamp");
  HashMap requestMap = new HashMap();
  String uiType = emxGetParameter(request, "uiType");
  if("structureBrowser".equalsIgnoreCase(uiType)){
  	requestMap = (HashMap)indentedTableBean.getRequestMap(timeStamp);
  }else{
  	requestMap = (HashMap)tableBean.getRequestMap(timeStamp);
  }
  String strFrameName = (String)requestMap.get(Search.REQ_PARAM_FRAME_NAME);
  String strFormName = (String)requestMap.get(Search.REQ_PARAM_FORM_NAME);
  String strFieldNameDisplay = (String)requestMap.get(Search.REQ_PARAM_FIELD_NAME_DISPLAY);
  String strFieldNameActual = (String)requestMap.get(Search.REQ_PARAM_FIELD_NAME_ACTUAL);
  String strFieldNameActualOID = strFieldNameActual + "OID";
  
  String strObjname = "";
  String[] strTableRowIds = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));  
  String strTableRowId = "";
  String strObjectId = "";
  String strIds = "";
  String strAllObjectNames = "";
  StringList slTokens = null;
  String strShowRevision = (String)requestMap.get("ShowRevision");
  
  if ((strTableRowIds == null)||(strTableRowIds.equals("null"))||(strTableRowIds.equals("")))
  {
	    
		i18nNow i18nInstance = new i18nNow();
		String strLang = request.getHeader("Accept-Language");
		String strRetMsg = i18nInstance.GetString(COMPONENT_FRAMEWORK_BUNDLE, acceptLanguage,ALERT_MSG);
		throw new FrameworkException(strRetMsg);
  }
  else {
		for (int i = 0; i < strTableRowIds.length; i++) {
    
    strTableRowId = strTableRowIds[i];
    slTokens = FrameworkUtil.split(strTableRowId,",");
    strObjectId = (String)slTokens.get(0);
    if(strTableRowIds.length>1)
    {
        strObjectId+=",";
        strIds+= strObjectId;
            
    }
    else
    {
        strIds = strObjectId;
    }
        strTableRowId = strTableRowId.trim();
  		Search search = new Search();
			
			if(((strShowRevision != null) && (!strShowRevision.equalsIgnoreCase("")) && !("null".equalsIgnoreCase(strShowRevision))) && (strShowRevision.equalsIgnoreCase("true")))
			{
				strObjname = search.getObjectNameWithRevision(context, strTableRowId);//This is to get obj name & rev.
				strObjname+=",";
				strAllObjectNames+= strObjname;
			}
			else {
				
				if(!"".equals(strAllObjectNames))
				{
					strAllObjectNames+=",";
				}
				strObjname = search.getObjectName(context, strTableRowId); //This has to be read from the bean method.
				strAllObjectNames+= strObjname;
				
			
			}
		}
	}
%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript">
  function resetFolderField(objWindow,strName)
  {
	  if("Workspace"==strName)
      {
	      objWindow.document.getElementsByName("WorkspaceFolderDisplay")[0].value="*";
		  objWindow.document.getElementsByName("WorkspaceFolderOID")[0].value="";
		  objWindow.document.getElementsByName("WorkspaceFolder")[0].value="";
		  objWindow.document.getElementsByName("WorkspaceFolderfieldValue")[0].value="";
      }
      
  }
  
  function setAndRefresh()
    {
      
	  var txtTypeDisplay;
      var txtTypeActual;
      var txtTypeActualOID;
      
      var targetFrame = findFrame(getTopWindow().getWindowOpener(), "<%=XSSUtil.encodeForJavaScript(context, strFrameName)%>");
      if(targetFrame !=null){
        txtTypeDisplay=targetFrame.document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameDisplay)%>;
	
        txtTypeActual=targetFrame.document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameActual)%>;
        
        txtTypeActualOID=targetFrame.document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameActualOID)%>;
		
        resetFolderField(targetFrame,txtTypeActual.name);
        
		
      }else{
	  /*
		Control comes here if the search type is Global Search ------
		In case of Global Search the old logic fails as getTopWindow().getWindowOpener().document.location = emxSearch.jsp
		and getTopWindow().getWindowOpener().document.editDataForm.OwnerDisplay is null since emxSearch.jsp does not have <form> editDataForm.
		So we have to find for the "searchContent" in emxSearch.jsp which in turn contains the webform jsp emxFormEditDisplay.jsp
		which contains the <form> editDataForm :		
		*/
		var searchContentFrame = findFrame(getTopWindow().getWindowOpener(), "searchContent");
		
		if(searchContentFrame !=null){
			txtTypeDisplay=searchContentFrame.document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameDisplay)%>;
	        txtTypeActual=searchContentFrame.document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameActual)%>;
	          txtTypeActualOID=searchContentFrame.document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameActualOID)%>;
	         resetFolderField(searchContentFrame,txtTypeActual.name);
	          
		} else {
        txtTypeDisplay = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameDisplay)%>;
        txtTypeActual = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameActual)%>;
        txtTypeActualOID = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameActualOID)%>;
       
        resetFolderField(getTopWindow().getWindowOpener(),txtTypeActual.name);
       
	   }
		
      }

      txtTypeDisplay.value = "<%=XSSUtil.encodeForJavaScript(context, strAllObjectNames)%>";
      txtTypeActual.value = "<%=XSSUtil.encodeForJavaScript(context, strIds)%>";
      if(txtTypeActualOID != null)
      txtTypeActualOID.value = "<%=XSSUtil.encodeForJavaScript(context, strIds)%>";
	  
<%

/////////////////////
String strCommandName = (String)requestMap.get(Search.REQ_PARAM_COMMAND);
String strJSFunction = null;

if(strCommandName != null && !"null".equals(strCommandName) && !"".equals(strCommandName))
{
	HashMap hmCommand = com.matrixone.apps.framework.ui.UIMenu.getCommand(context, strCommandName);

	if(hmCommand != null)
	{
		String strCommandHRef = com.matrixone.apps.framework.ui.UIMenu.getHRef(hmCommand);

		if( strCommandHRef != null )
		{
			int iIndex = strCommandHRef.indexOf("JSFunction");
			if(iIndex != -1)
			{
				strJSFunction = strCommandHRef.substring(iIndex+"JSFunction".length());
				iIndex = strJSFunction.indexOf("&");
				if(iIndex != -1)
				{
					strJSFunction = strJSFunction.substring(0, iIndex);
				}
				iIndex = strJSFunction.indexOf("=");
				if(iIndex != -1)
				{
					strJSFunction = strJSFunction.substring(iIndex+1);
				}
			}
		}
	}
}
		if(strJSFunction != null && !"".equals(strJSFunction))
		{
			%>
			if(searchContentFrame != null)
			{
				try
				{
					searchContentFrame.<%=XSSUtil.encodeForJavaScript(context, strJSFunction)%>();
				}catch(e1){}
			}else
			{
				try
				{
					getTopWindow().getWindowOpener().<%=XSSUtil.encodeForJavaScript(context, strJSFunction)%>();
				}catch(e2){}


			}
			<%
		}

			
/////////////////////////

	%>


	  


      getTopWindow().closeWindow();
    }

</script>

<html>
<body onload=setAndRefresh()>
</body>
</html>

<%
} // End of try
catch(Exception ex) {
   session.putValue("error.message", ex.getMessage());
 } // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
