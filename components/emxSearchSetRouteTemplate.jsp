<%-- emxSearchSetRouteTemplate.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxSearchSetRouteTemplate.jsp.rca 1.8 Wed Oct 22 16:18:03 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

<%
//added for 320802
  String parentForm       = emxGetParameter(request,"form");
  String parentField      = emxGetParameter(request,"field");
  String parentFieldDisp  = emxGetParameter(request,"fieldDisp");
  String parentFieldObjId  = emxGetParameter(request,"fieldDispObjId");
//320802

  
  String selectedId = request.getParameter("emxTableRowId");
  String objectId = "";
  String templateName = "";
//Added for fixing the bug 308990
  String description = "";
  //Added on 28/Mar/2006 for fixing the bug 308872
  String routeBasePurpose = "";
  if(selectedId!=null)
  {
        objectId = selectedId;
	if(!objectId.equals(null) || !"".equals(objectId))
	{
		  //Added on 28/Mar/2006 for fixing the bug 308872
		  String sAttrRouteBasePurpose = PropertyUtil.getSchemaProperty(context, "attribute_RouteBasePurpose" );
		  String SELECT_ROUTE_BASE_PURPOSE = DomainObject.getAttributeSelect(sAttrRouteBasePurpose);
		  
		  SelectList selectStmts = new SelectList(3);
		  selectStmts.addElement(DomainObject.SELECT_NAME);
		  selectStmts.addElement(SELECT_ROUTE_BASE_PURPOSE);
//		Added for fixing the bug 308990
		  selectStmts.addElement(DomainObject.SELECT_DESCRIPTION);

		DomainObject routeTemplateObj = new DomainObject(objectId);
		//Added/Modified on 28/Mar/2006 for fixing the bug 308872
		Map resultMap = routeTemplateObj.getInfo(context, selectStmts);
		templateName = (String) resultMap.get(routeTemplateObj.SELECT_NAME);
		routeBasePurpose = (String) resultMap.get(SELECT_ROUTE_BASE_PURPOSE);
//		Added for fixing the bug 308990
		description = (String)resultMap.get(DomainObject.SELECT_DESCRIPTION);
		
		// The description might contains new line characters, such description will give JavaScript error
		// when it is assigned to description field
		description = FrameworkUtil.findAndReplace(description, "\n", "\\n");
	}
  }
  %>
<script src="scripts/emxUIConstants.js" type="text/javascript"></script>
<script src="scripts/emxUICore.js" type="text/javascript"></script>  
 <script language="javascript">
 var objIds = "<%=XSSUtil.encodeForJavaScript(context, selectedId)%>";
 var parentForm = "<%=XSSUtil.encodeForJavaScript(context, parentForm)%>";  // Use the form provided
 var parentField ="<%=XSSUtil.encodeForJavaScript(context, parentField)%>";
 var parentFieldDisp ="<%=XSSUtil.encodeForJavaScript(context, parentFieldDisp)%>";
 var parentFieldObjId ="<%=XSSUtil.encodeForJavaScript(context, parentFieldObjId)%>";
 var OBJECTID="<%=XSSUtil.encodeForJavaScript(context, objectId)%>";
 var templateName ="<%=XSSUtil.encodeForJavaScript(context, templateName)%>";


 if(objIds!="null")
 {
    if((parentField != "null"))
    {
        var parentFieldVal = null;
        var parentFieldDispVal = null;
        var parentFieldObjIdVal = null;

        // If form name is supplied then use that to form the references to the fields, else use the first form in the parent document
        if (parentForm != "null") {
            parentFieldVal = eval("getTopWindow().getWindowOpener().document." + parentForm + "." + parentField);
            parentFieldDispVal = eval("getTopWindow().getWindowOpener().document." + parentForm + "." + parentFieldDisp);
            parentFieldObjIdVal = eval("getTopWindow().getWindowOpener().document." + parentForm + "." + parentFieldObjId);
        }
        else {
            parentFieldVal=eval("getTopWindow().getWindowOpener().document.forms[0]." + parentField);
            parentFieldDispVal= eval("getTopWindow().getWindowOpener().document.forms[0]." + parentFieldDisp);
            parentFieldObjIdVal =eval("getTopWindow().getWindowOpener().document.forms[0]." + parentFieldObjId);
        }

        // Assign fields only if their references are available
        if (parentFieldDispVal) {
            parentFieldDispVal.value= "<%=XSSUtil.encodeForJavaScript(context, templateName)%>";
        }
        if (parentFieldVal) {
            parentFieldVal.value ="<%=XSSUtil.encodeForJavaScript(context, templateName)%>";
        }
        if (parentFieldObjIdVal) {
            parentFieldObjIdVal.value="<%=XSSUtil.encodeForJavaScript(context, objectId)%>";
        }
     }
    else
    {
        var form = getTopWindow().getWindowOpener().document.forms[0];
        if (form) {
            if (form.templateName) {
                form.templateName.value="<%=XSSUtil.encodeForJavaScript(context, templateName)%>";
            }
            if (form.template) {
                form.template.value="<%=XSSUtil.encodeForJavaScript(context, templateName)%>";
            }
            if (form.templateId) {
                form.templateId.value="<%=XSSUtil.encodeForJavaScript(context, objectId)%>";
            }
            if (form.routeBasePurpose) {
                //Added on 28/Mar/2006 for fixing the bug 308872
                form.routeBasePurpose.value="<%=XSSUtil.encodeForJavaScript(context, routeBasePurpose)%>";
            }
            if (form.txtdescription) {
                form.txtdescription.value="<%=XSSUtil.encodeForJavaScript(context, description)%>";
            }
        }
    }

    getTopWindow().closeWindow();
 }
 else
 {
    alert("<emxUtil:i18nScript localize='i18nId'>emxComponents.SearchTemplate.SelectOne</emxUtil:i18nScript>");
 }
 </script>
