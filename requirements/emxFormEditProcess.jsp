<%--  emxFormEditProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormEditProcess.jsp.rca 1.24.2.1 Fri Nov  7 09:37:00 2008 ds-kvenkanna Experimental $
--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
      are added under respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview LX6 QYG 04 Mar 2013  IR-196576V6R2014  "STP: Lock and Unlock command displays an error message on structure view and structure content editor " 
     @quickreview HAT1 ZUD IR-335960-3DEXPERIENCER2015x	Requirement : Reserve/Unreserve function freeze with a big structure 
     @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
     @quickreview      ZUD 16:08:17 : Reserve/UnReserve Command for RMT Types in attribute Tab
--%>
<html>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductVariables.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>

<head>
    <title>form processing</title>
    <script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
    <script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
    <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
    <script language="javascript" src="../common/scripts/emxUIFormUtil.js"></script>
</head>

<%
String isPopup = emxGetParameter(request, "isPopup");
String portalMode = emxGetParameter(request, "portalMode");
String form = emxGetParameter(request, "form");
String objectId = emxGetParameter(request, "objectId");
String relId = emxGetParameter(request, "relId");
String timeStamp = emxGetParameter(request, "timeStamp");
String postProcessURL = emxGetParameter(request, "postProcessURL");
String postProcessJPO = emxGetParameter(request, "postProcessJPO");
String languageStr = request.getHeader("Accept-Language");
String suiteKey = emxGetParameter(request,"suiteKey");
String targetLocation = emxGetParameter(request, "targetLocation");

String emxSuiteDirectory = emxGetParameter(request, "emxSuiteDirectory");
if (emxSuiteDirectory == null || emxSuiteDirectory.length() == 0) {
    emxSuiteDirectory = emxGetParameter(request, "SuiteDirectory");
}
String strRootNodeLabel="";
String newObjectId = "";
boolean isPortal = (portalMode != null && "true".equalsIgnoreCase(portalMode));
String sessionRemove= emxGetParameter(request, "sessionRemove");
String wrongURL = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.FormComponent.WrongURLForPostProcessURL");

// time zone to be used for the date fields
HashMap returnMap =  new HashMap();
String action  = "CONTINUE"; // Default Action is Continue - Commits transaction
String message = "";
String fieldallowKeyableDates="";

boolean updateComplete = true;
boolean errorFromDate = true;
String invaliddate = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Common.InvalidDate");
String allowKeyableDates = "false";
long msvalue1=0;
try {
                allowKeyableDates = EnoviaResourceBundle.getProperty(context, "emxFramework.AllowKeyableDates");
} catch(Exception e) {
        allowKeyableDates = "false";
}
String typeAheadEnabled = "true";
    try
    {
        typeAheadEnabled = EnoviaResourceBundle.getProperty(context, "emxFramework.TypeAhead");
    }
    catch (Exception e)
    {
    }

try {
        MapList fields = formEditBean.getFormFields(timeStamp);
        for (int k = 0; k < fields.size(); k++)
        {
                HashMap field = (HashMap)fields.get(k);
                if(formEditBean.isDateField(field) && formEditBean.isFieldEditable(field)) {
                        fieldallowKeyableDates = (String)formEditBean.getSetting(field, "Allow Manual Edit");
                        if((allowKeyableDates != null && "true".equalsIgnoreCase(allowKeyableDates)) || (fieldallowKeyableDates != null && "true".equalsIgnoreCase(fieldallowKeyableDates))) {
                                String fieldName = formEditBean.getName(field);
                                java.text.DateFormat df = java.text.DateFormat.getDateInstance(eMatrixDateFormat.getEMatrixDisplayDateFormat(), request.getLocale());
                                df.setLenient(false);
                                String fieldValue = emxGetParameter(request, fieldName);
                                if( (fieldValue == null || fieldValue.equals("")) && (!formEditBean.isFieldRequired(field)) )
                                    continue;
                                java.util.Date formattedDate = df.parse(fieldValue);
                        }
                }
        }
        errorFromDate = false;

        // save field values to store
        HashMap field;
        String fieldName;
        for (int k = 0; k < fields.size(); k++)
        {
            field = (HashMap) fields.get(k);
            fieldName = formEditBean.getName(field);
            // add the type ahead javascript if the feature is enabled
            String strTypeAheadSetting=formEditBean.getSetting(field,"TypeAhead");
            String rangeHelperURL = formEditBean.getRangeHelperURL(field);

            if (strTypeAheadSetting==null||"null".equals(strTypeAheadSetting)||"".equals(strTypeAheadSetting))
                {
                    strTypeAheadSetting="true";
                }
            if (((formEditBean.isTextBoxField(field) && formEditBean.isFieldEditable(field))
                ||(formEditBean.isFieldManualEditable(field) && rangeHelperURL != null && rangeHelperURL.length() > 0)
                || (formEditBean.isDateField(field) && formEditBean.isFieldManualEditable(field))) && "true".equalsIgnoreCase(typeAheadEnabled) && "true".equalsIgnoreCase(strTypeAheadSetting))
            {
                String tagTypeAheadSavedValuesLimit = formEditBean.getSetting(field, "TypeAhead Saved Values Limit");
                String tagDisplayFieldValue;
                String tagHiddenFieldValue;

                if (rangeHelperURL != null && rangeHelperURL.length() > 0)
                {
                    tagDisplayFieldValue = emxGetParameter(request, fieldName + "Display");
                    tagHiddenFieldValue = emxGetParameter(request, fieldName);
                }
                else
                {
                    tagDisplayFieldValue = emxGetParameter(request, fieldName);
                    tagHiddenFieldValue = "";
                    if (formEditBean.isDateField(field))
                    {
                        tagHiddenFieldValue = emxGetParameter(request, fieldName+"_msvalue");
                        if (tagDisplayFieldValue!=null && !"".equals(tagDisplayFieldValue) && !"".equals(tagDisplayFieldValue)){
                        if ((fieldallowKeyableDates != null && "true".equalsIgnoreCase(fieldallowKeyableDates))) {
                                    int iDateFormat = eMatrixDateFormat.getEMatrixDisplayDateFormat();
                                    double iClientTimeOffset = (new Double(timeZone)).doubleValue();
                                    long msvalue=DateUtil.getMilliseconds(context, tagDisplayFieldValue, iDateFormat, iClientTimeOffset, request.getLocale());
                                    Long lgMsvalue=new Long(msvalue);
                                    tagHiddenFieldValue=lgMsvalue.toString();
                             }
                        }
                    }
                }
%>
                <emxUtil:saveTypeAheadValues
                    context="<%=context%>"
                    form="<xss:encodeForHTMLAttribute><%=form%></xss:encodeForHTMLAttribute>"
                    field="<xss:encodeForHTMLAttribute><%=fieldName%></xss:encodeForHTMLAttribute>"
                    displayFieldValue="<xss:encodeForHTMLAttribute><%=tagDisplayFieldValue%></xss:encodeForHTMLAttribute>"
                    hiddenFieldValue="<xss:encodeForHTMLAttribute><%=tagHiddenFieldValue%></xss:encodeForHTMLAttribute>"
                    count="<xss:encodeForHTMLAttribute><%=tagTypeAheadSavedValuesLimit%></xss:encodeForHTMLAttribute>"
                />
<%
            }
        }

    // commit the type ahead values
%>
    <%-- START : LX6 IR-196576V6R2014  "STP: Lock and Unlock command displays an error message on structure view and structure content editor " --%>
    <emxUtil:commitTypeAheadValues context="<%=context%>" />
    <%-- END : LX6 IR-196576V6R2014  "STP: Lock and Unlock command displays an error message on structure view and structure content editor " --%>
<%
    ContextUtil.startTransaction(context, true);

    String objectBased = emxGetParameter(request, "objectBased");

    if (form != null)
    {
        if (objectBased == null || !objectBased.equalsIgnoreCase("false"))
        {
            newObjectId = formEditBean.commitFields(request, context, objectId, relId, timeZone);
            // commitFields(application, session, request, context, objectId, relId);
        }
        else
        {
            newObjectId = objectId;
        }

    }

    //added condition to handle the postProcessURL parameter by Ranganath
    if(postProcessURL!= null && !"".equals (postProcessURL))
    {
        request.setAttribute("context", context);

        //Added for BUG:347348
        String tempURL = postProcessURL;
        int valIndex   = tempURL.indexOf("?");
        if(valIndex!=-1){
            tempURL = tempURL.substring(0,valIndex);
        }

        //Modified for bugs 369162 & 014937
        if(postProcessURL.indexOf("/")==-1){
            tempURL = "/common/"+tempURL;
        }else{
            tempURL = FrameworkUtil.findAndReplace(tempURL,"../","/");
        }

        ServletContext servletContext  = getServletConfig().getServletContext();
        InputStream inputStream        = servletContext.getResourceAsStream(tempURL);

        if(inputStream!= null){
            %><jsp:include page = "<xss:encodeForHTMLAttribute><%=postProcessURL%></xss:encodeForHTMLAttribute>" flush="true" /><%
        }else{
            throw new com.matrixone.apps.domain.util.FrameworkException(wrongURL);
        }
    }
    //added condition to handle the postProcessJPO parameter by Ranganath
    if(postProcessJPO != null && !"".equals(postProcessJPO) && postProcessJPO.indexOf(":") > 0)
    {
         HashMap programMap = new HashMap(6);
         HashMap paramMap = new HashMap(6);

         Enumeration paramNames = emxGetParameterNames(request);
         while(paramNames.hasMoreElements()) {
          String paramName = (String)paramNames.nextElement();
          String paramValue = emxGetParameter(request,paramName);
          paramMap.put(paramName, paramValue);
         }
         //Added EditAction paramter
         paramMap.put("EditAction", "done");
         programMap.put("requestMap", UINavigatorUtil.getRequestParameterMap(pageContext));
         programMap.put("requestValuesMap", UINavigatorUtil.getRequestParameterValuesMap(request));
         programMap.put("paramMap", paramMap);
         HashMap formMap = formEditBean.getFormData(timeStamp);
         programMap.put("formMap", formMap);

         // ++ HAT1 ZUD IR-335960-3DEXPERIENCER2015x fix 
             Map requestMap = (Map) programMap.get("requestMap");
             String key     = (String) requestMap.get("key");
             requestMap.put("rowIds", session.getAttribute(key));
             session.removeAttribute(key);
         // -- HAT1 ZUD IR-335960-3DEXPERIENCER2015x fix 
         
         String[] methodargs = JPO.packArgs(programMap);
         String strJPOName = postProcessJPO.substring(0, postProcessJPO.indexOf(":"));
         String strMethodName = postProcessJPO.substring (postProcessJPO.indexOf(":") + 1, postProcessJPO.length());
         try {
          returnMap = (HashMap)JPO.invoke(context, strJPOName, null, strMethodName, methodargs, HashMap.class);
         } catch (Exception exJPO) {
               throw (new FrameworkException(exJPO.toString()));
         }
         if(returnMap != null && returnMap.size() > 0)
         {
            message = (String)returnMap.get("Message");
            action  = (String)returnMap.get("Action");
            if(message != null && !"".equals(message))
            {

               String registeredSuite = suiteKey;

               if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
                 registeredSuite = suiteKey.substring("eServiceSuite".length());

               String stringResFileId = UINavigatorUtil.getStringResourceFileId(context,registeredSuite);
               if(stringResFileId == null || stringResFileId.length()==0)
                 stringResFileId="emxFrameworkStringResource";

               String alertMessage = EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(), message); 
               if ((alertMessage == null) || ("".equals(alertMessage)))
               {
                  alertMessage = message;
               }

               alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\n","\\n");
               alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\r","\\r");
               alertMessage = FrameworkUtil.findAndReplace(alertMessage,"\"", "\\\"");

%>
<script language="javascript" type="text/javaScript">
alert("<xss:encodeForJavaScript><%=alertMessage%></xss:encodeForJavaScript>");
</script>
<%
            }
         }
     }

    if(action!=null && action.equalsIgnoreCase("continue"))
    {
        ContextUtil.commitTransaction(context);
        updateComplete = true;
    }
    else
    {
        ContextUtil.abortTransaction(context);
        updateComplete = false;
    }

} catch (Exception ex) {
    ContextUtil.abortTransaction(context);
    if(errorFromDate) {
            emxNavErrorObject.addMessage(invaliddate);
    } else if (ex.toString() != null && (ex.toString().trim()).length() > 0) {
            emxNavErrorObject.addMessage(ex.toString().trim());
    }
    updateComplete = false;

} finally {
       // Clean the session HashMap for this entry with timestamp
    //if (!isPortal && updateComplete && "true".equalsIgnoreCase(isPopup))
    if (!isPortal && updateComplete && !"false".equalsIgnoreCase(sessionRemove))
    {
        formEditBean.removeFormData(timeStamp);
    }

}


String stMenuName="";
UIMenu emxMenu = new UIMenu();
HashMap objMenuMap = new HashMap();
HashMap menuJSNodeMap=new HashMap();
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="JavaScript">

<%
if(targetLocation.equalsIgnoreCase("popup"))
{
	isPopup = "true";
}
if (!isPortal && updateComplete && "true".equalsIgnoreCase(isPopup))
{
    //get the tree information to update the tree
    stMenuName=UITreeUtil.getTreeMenuName(application, session, context, newObjectId, emxSuiteDirectory);
    objMenuMap = emxMenu.getMenu(context, stMenuName);
    menuJSNodeMap = UITreeUtil.getJSNodeMap(application, session, request, context, objMenuMap, newObjectId, relId);
    strRootNodeLabel = (String)menuJSNodeMap.get("nodeLabel");
    //To fix 362564
    if (strRootNodeLabel != null) {
    	strRootNodeLabel = FrameworkUtil.findAndReplace(strRootNodeLabel, "\n", " ");
    }

    // In the case of non-object based forms, we need to
    // be able to control the submit action.

    String submitAction = emxGetParameter(request, "submitAction");
    if (submitAction != null && submitAction.equalsIgnoreCase("refreshCaller"))
    {
%>
  //KIE1 ZUD TSK447636 
if(getTopWindow().getWindowOpener().emxEditableTable && getTopWindow().getWindowOpener().emxEditableTable.isRichTextEditor){
	//richtexteditor
	getTopWindow().getWindowOpener().refreshSCE();
}
else if(getTopWindow().getWindowOpener().emxEditableTable){
	// Structure Browser
	getTopWindow().getWindowOpener().emxEditableTable.refreshStructureWithOutSort(); //IR-061663V6R2011x
}
else if(findFrame(getTopWindow().getWindowOpener().parent.getTopWindow(), "RMTRequirementProperties"))
{
	getTopWindow().getWindowOpener().close();	
	getTopWindow().getWindowOpener().parent.document.location.href = getTopWindow().getWindowOpener().parent.document.location.href;
	
}
<%
    }
    else if (submitAction != null && submitAction.equalsIgnoreCase("doNothing"))
    {
        //do nothing
    }
    else
    {
%>
    var contextTree = null;
    var contextStructureTree = null;
    var objNode = null;
    var structureNode = null;
    var treeFrameExist = false;
    try
    {
      //KIE1 ZUD TSK447636 
    if (findFrame(getTopWindow().getWindowOpener().getTopWindow(), "treeDisplay"))
    {
        treeFrameExist = true;
        contextTree = getTopWindow().getWindowOpener().getTopWindow().objDetailsTree;
        contextStructureTree = getTopWindow().getWindowOpener().getTopWindow().objStructureTree;
        if(contextTree)
        {
                contextTree.doNavigate = true;
                objNode = contextTree.findNodeByObjectID("<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>");
        }
        if(contextStructureTree)
        {
            contextStructureTree.doNavigate = true;
            structureNode = contextStructureTree.findNodeByObjectID("<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>");
        }
    }


  //KIE1 ZUD TSK447636 
    //var formUrl = getTopWindow().getWindowOpener().parent.document.location.href;
    var formUrl = getTopWindow().getWindowOpener().document.location.href;
    //Remove the duplicate object id parameters and append the one got from request
    var newURL = formUrl;
        if(newURL.indexOf("objectId") < 0)
        {
            newURL += (newURL.indexOf('?') > -1 ? '&' : '?') + "objectId=<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>";
        }


    var changeOBJID = false;
      //KIE1 ZUD TSK447636 
    if (getTopWindow().getWindowOpener() != null && !getTopWindow().getWindowOpener().closed)
    {
        if (getTopWindow().getWindowOpener() && getTopWindow().getWindowOpener().getTopWindow().modalDialog)
        {
            if(!(getTopWindow().getWindowOpener().getTopWindow().modalDialog.contentWindow.closed))
            {
                getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
            }
        }
    }
<%
    if (objectId != null && newObjectId != null && !objectId.equals(newObjectId))
    {
%>
    changeOBJID = true;
<%
  }
%>

  var arrURLParts = newURL.split("?");
  if(changeOBJID)
  {
        newURL = removeObjectIDParam(formUrl);
      arrURLParts[1]="objectId=<xss:encodeForJavaScript><%=newObjectId%></xss:encodeForJavaScript>&"+arrURLParts[1];
      newURL=arrURLParts.join("?");

<%
    if (relId != null && !"".equals(relId))
    {
%>

    if (newURL.indexOf('relId=') == -1)
    {
      newURL += (newURL.indexOf('?') > -1 ? '&' : '?') + "relId=<xss:encodeForJavaScript><%=relId%></xss:encodeForJavaScript>";
    }
<%
    }
%>

  }

}

catch (e)
{
	 if(-2146828218 != e.number && -2147418094 != e.number)
	  {
		alert("An exception occurred in the script. Error name: " + e.name
		+ ". Error number: " + e.number
		+ ". Error message: " + e.message)
      }
}

  if(objNode)
  {
    if(changeOBJID)
    {
      if(structureNode)
      {
         contextStructureTree.doNavigate = true;
         structureNode.changeObjectName("<xss:encodeForJavaScript><%=strRootNodeLabel%></xss:encodeForJavaScript>",true);
         structureNode.changeObjectID("<xss:encodeForJavaScript><%=newObjectId%></xss:encodeForJavaScript>");
      }
      contextTree.doNavigate = true;
      objNode.changeObjectID("<xss:encodeForJavaScript><%=newObjectId%></xss:encodeForJavaScript>");
      objNode.changeObjectName("<xss:encodeForJavaScript><%=strRootNodeLabel%></xss:encodeForJavaScript>",true);
    }
    else
    {
  	//KIE1 ZUD TSK447636 
        var formOpener = getTopWindow().getWindowOpener().document.location.href;
        var pMode = formOpener.indexOf("portalMode=true");
        if((formOpener.indexOf("emxForm.jsp")>-1 || formOpener.indexOf("emxTable.jsp") >-1 ||  formOpener.indexOf("emxIndentedTable.jsp") >-1) && (pMode > -1))
        {
            getTopWindow().getWindowOpener().document.location.href = formOpener;
        }
        else
        {

	  //KIE1 ZUD TSK447636 
            var formOpenerParent = getTopWindow().getWindowOpener().parent.document.location.href;
            pMode = formOpenerParent.indexOf("portalMode=true");
            if((formOpenerParent.indexOf("emxForm.jsp")>-1 || formOpenerParent.indexOf("emxTable.jsp") >-1 ||  formOpenerParent.indexOf("emxIndentedTable.jsp") >-1) && (pMode > -1))
            {
                getTopWindow().getWindowOpener().parent.document.location.href = formOpenerParent;
            }else {
                if(structureNode)
                {
                     structureNode.changeObjectName("<xss:encodeForJavaScript><%=strRootNodeLabel%></xss:encodeForJavaScript>",true);
                }
                objNode.changeObjectName("<xss:encodeForJavaScript><%=strRootNodeLabel%></xss:encodeForJavaScript>",true);
            }
        }
    }
  }
  else
  {
    //KIE1 ZUD TSK447636 
    try
    {
    if(getTopWindow().getWindowOpener().parent)
    {
        var openerURL="";
        var isIndentedTablePage=false;
        if(getTopWindow().getWindowOpener().document.location.href.indexOf("emxIndentedTable.jsp")>-1)
        {
            openerURL = getTopWindow().getWindowOpener().document.location.href;
            isIndentedTablePage=true;
        }
        else
        {
            openerURL = getTopWindow().getWindowOpener().parent.document.location.href;
        }
      if(openerURL.indexOf("emxTable.jsp") >= 0)
      {
        var reloadURL = getTopWindow().getWindowOpener().parent.frames[1].document.location.href;
        reloadURL += "&clearValuesMap=true";
        getTopWindow().getWindowOpener().parent.frames[1].document.location.href = reloadURL;
      }
      else
      {

           if(getTopWindow().getWindowOpener().parent.FullSearch)
		  {
				getTopWindow().getWindowOpener().parent.FullSearch.formSearch();
		   }
        	else if(isIndentedTablePage)
          {
              getTopWindow().getWindowOpener().document.location.href = openerURL;
          }
          else
          {
            //getTopWindow().getWindowOpener().parent.document.location.href = newURL;
            getTopWindow().getWindowOpener().document.location.href = newURL;
          }
	    //KIE1 ZUD TSK447636 
      }
    }
  }
catch (e)
{
	if(-2146828218 != e.number && -2147418094 != e.number)
	 {
		alert("An exception occurred in the script. Error name: " + e.name
		+ ". Error number: " + e.number
		+ ". Error message: " + e.message)
     }
}
}
<%
}
}
%>

  /*var formFooterFrame = findFrame(parent,"formEditFooter");
  formFooterFrame.setFormSubmitAction(true);*/
  setFormSubmitAction(true);

<%
    if (!isPortal && updateComplete && "true".equalsIgnoreCase(isPopup)) {
        //!!IMPORTANT!! unload are being cancelled for everything except powerviews
        //unload events are calling purgeEditFormData()
        //this is being called directly here and
        //BEFORE closing a dialog
%>
      if(getTopWindow().purgeEditFormData){
        getTopWindow().purgeEditFormData("<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>");
      }
        //KIE1 ZUD TSK447636 
      getTopWindow().closeWindow();
<%
    } else {
// Make sure the progress indicator is off.
// The following is to undo what is done in
// emxUIFormUtil.js:saveChanges().
%>
    turnOffProgress();
    parent.formEditDisplay.document.body.style.cursor = "default";
    parent.document.body.style.cursor = "default";
    //formFooterFrame.document.body.style.cursor = "default";
<%
    }
%>
</script>
</html>

