<%--  emxFolderServiceSearchProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOServiceManagement/CNext/webroot/servicemanagement/emxFolderServiceSearchProcess.jsp 1.1 Fri Nov 14 15:40:25 2008 GMT ds-hchang Experimental$
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
  HashMap hMap=(HashMap)session.getAttribute("hmapRequestParams");
  String objectId			= (String)hMap.get("objectId");
  String searchType			= (String)hMap.get("searchType");
  String commandType		= (String)hMap.get("commandType");
  String selectedItems[]	= emxGetParameterValues(request,"emxTableRowId"); 
  String relServiceCategory = PropertyUtil.getSchemaProperty(context,"relationship_ServiceCategory");
  String relServiceAccess 	= PropertyUtil.getSchemaProperty(context,"relationship_ServiceAccess");
  String HelpMarker			= emxGetParameter(request,"HelpMarker");

  String sURL = "emxFolderServiceSearchDialogFS.jsp?objectId="+XSSUtil.encodeForURL(context,objectId)+"&searchType="+XSSUtil.encodeForURL(context,searchType)+"&commandForm="+XSSUtil.encodeForURL(context,commandType)+"&HelpMarker="+XSSUtil.encodeForURL(context,HelpMarker);
  if (commandType.equals("AddServiceAccessText")) {
    String formName			= (String)hMap.get("formName");
    String parentField		= (String)hMap.get("fieldNameDisplay");
    String parentidField	= (String)hMap.get("fieldNameActual");
    sURL += "&formName="+XSSUtil.encodeForURL(context, formName)+"&fieldNameDisplay="+XSSUtil.encodeForURL(context,parentField)+"&fieldNameActual="+XSSUtil.encodeForURL(context,parentidField);
  } else if (commandType.equals("AddServiceCategoryRel")) {
   // Add necessary statemenents for AddServiceCategoryRel case if needed.
  } else if (commandType.equals("AddServiceAccessRel")) {
   // Add necessary statemenents for AddServiceAccessRel case if needed.
  }
  try {
	if (selectedItems != null) {
	    if (commandType.equals("AddServiceAccessText")) {
		    String formName		= (String)hMap.get("formName");
		    if (formName == null || formName.length() == 0) {
		        formName = "0";
		    } else {
		        formName = "\"" + formName + "\"";
		    }
		    String parentField		= (String)hMap.get("fieldNameDisplay");
		    String parentidField	= (String)hMap.get("fieldNameActual");
		    String accessList 		= "";
		    for(int i=0; i<selectedItems.length; i++)
		    {
				accessList = accessList + selectedItems[i] + "|";
		    }
%>
        <script language="javascript">
        var fieldName 	= "<%=XSSUtil.encodeForJavaScript(context,parentField)%>";
        var fieldId 	= "<%=XSSUtil.encodeForJavaScript(context,parentidField)%>";
        var nameField 	= getTopWindow().getWindowOpener().document.forms[0].elements[fieldName];
        var idField		= getTopWindow().getWindowOpener().document.forms[0].elements[fieldId];
		 if(nameField != null && nameField != '' && nameField != 'undefined'){
		    nameField.value="<%=XSSUtil.encodeForJavaScript(context, accessList)%>";
		 }
		 if(idField != null && idField != '' && idField != 'undefined'){
		    idField.value="<%=XSSUtil.encodeForJavaScript(context, accessList)%>";
		 }
		</script>
<%		 
	    } else if (commandType.equals("AddServiceCategoryRel")) {
	        DomainObject domServiceFolder = new DomainObject(objectId);
	        for(int i=0;i<selectedItems.length;i++)
			{
				DomainObject domService = new DomainObject(selectedItems[i]);
				try {
					DomainRelationship.connect(context,domServiceFolder,relServiceCategory,domService);
				} catch (Exception e) {
				    session.putValue("error.message",e.getMessage());
				}
			} 
	    } else if (commandType.equals("AddServiceAccessRel")) {
	        DomainObject domServiceKey = new DomainObject(objectId);
	        for(int i=0;i<selectedItems.length;i++)
			{
				DomainObject domService = new DomainObject(selectedItems[i]);
				try {
					DomainRelationship.connect(context,domServiceKey,relServiceAccess,domService);
				} catch (Exception e) {
				    session.putValue("error.message",e.getMessage());
				}
			} 
	    }
        session.removeAttribute("hmapRequestParams");
%>

<html>
<body>
<form name="newForm" target="_parent">
</form>
<script language="javascript"> 
  if(getTopWindow().getWindowOpener().getTopWindow().modalDialog)
  {
    getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
  }
  //XSSOK
  if ("<%=commandType%>" == "AddServiceAccessText") {
    // Add necessary statemenents for AddServiceAccessText case if needed. 
    //XSSOK
  } else if ("<%=commandType%>" == "AddServiceCategoryRel" || "<%=commandType%>" == "AddServiceAccessRel") {
  	getTopWindow().getWindowOpener().parent.document.location.href=getTopWindow().getWindowOpener().parent.document.location.href;
  }
  getTopWindow().window.close();
</script>
</body>
</html>

<%
}else{
%>
        <script language="javascript">
          alert("<emxUtil:i18nScript localize="i18nId">emxWSManagement.AddContent.SelectOneObj</emxUtil:i18nScript>");
          //parent.document.location.reload();
          //XSSOK
          parent.document.location.href="<%=sURL%>";
        </script>
<%
              }
  } catch (Exception ex ) {
    session.putValue("error.message",ex.getMessage());
%>
        <script language="javascript">
                //parent.document.location.reload();
                //XSSOK
                parent.document.location.href="<%=sURL%>";
        </script>
<%
  }
%>
