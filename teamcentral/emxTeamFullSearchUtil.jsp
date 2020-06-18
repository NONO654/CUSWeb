<%--
  emxTeamFullSearchUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import="matrix.db.Context"%> 
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<%
	boolean bIsError = false;
	try
	{
		String strMode = emxGetParameter(request,"mode");
		String strObjId = emxGetParameter(request, "objectId");
		String frameName = emxGetParameter(request, "frameName");
		String typeAhead = emxGetParameter(request, "typeAhead");
		String populateDescription = emxGetParameter(request, "populateDescription");	
		
		String strRelName = emxGetParameter(request,"relName");
		String strDirection = emxGetParameter(request,"direction");
		String strRowId[] = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));

		// Convert any internal relationship name to its display format:
		if (strRelName != null)
		{
			strRelName = PropertyUtil.getSchemaProperty(context, strRelName);
		}

		if (strRowId == null)
		{   
			%>
				<script language="javascript" type="text/javaScript">
					alert("<emxUtil:i18n localize='i18nId'>emxFramework.IconMail.FindResults.AlertMsg1</emxUtil:i18n>");
				</script>
			<%
		}
		else
		{
			if (strMode.equalsIgnoreCase("Connect"))
			{
				boolean preserve = false;  // to update the modified date on the root obj
				for (int i = 0; i < strRowId.length; i++)
				{
					String selObjId = strRowId[i];

					if ("to".equalsIgnoreCase(strDirection))
					{
						// Create the named relationship to the selected obj from the root obj:
						DomainRelationship.connect(context, selObjId, strRelName, strObjId, preserve);
					}
					else
					{
						// Create the named relationship to the root obj from the selected obj:
						DomainRelationship.connect(context, strObjId, strRelName, selObjId, preserve);
					}
				}
				%>

					<script language="javascript" type="text/javaScript">
						window.parent.getTopWindow().getWindowOpener().parent.location.href = window.parent.getTopWindow().getWindowOpener().parent.location.href;
						window.getTopWindow().closeWindow();
					</script>
				<%
			}
			
			// Start:OEP:V6R2010:BUG 372490
			// Handled the Chooser condition for RangeHref passing from WebForm for Owner Field.
			if (strMode.equalsIgnoreCase("Chooser"))
         {
            String strSearchMode = emxGetParameter(request, "chooserType");
            String fieldNameActual = emxGetParameter(request, "fieldNameActual");
            String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");

            // For most webform choosers, default to the object id/name...
            String selObjId = strRowId[0];
            DomainObject selObject = new DomainObject(selObjId);
            String selObjName = selObject.getInfo(context, DomainConstants.SELECT_NAME);
            String description = "";
            if("true".equalsIgnoreCase(populateDescription))
            {
            	selObject.open(context);
            	description = selObject.getDescription(context);
            	selObject.close(context);
            }

            // When choosing a person, use the name/fullname instead...
            if (strSearchMode.equals("PersonChooser"))
            {
               selObjId = selObjName;
               selObjName = PersonUtil.getFullName(context, selObjName);
            }
%>
<script language="javascript" type="text/javaScript">
   var typeAhead = "<%=XSSUtil.encodeForJavaScript(context, typeAhead)%>";
   var tmpFieldNameOID = "<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>" + "OID";	
   var targetWindow = getTopWindow().getWindowOpener();
   if(!targetWindow || typeof getTopWindow().FullSearch == "undefined" && (typeof getTopWindow().SnN == "undefined" || getTopWindow().SnN.POPUP_SNN == false)){
	   targetWindow = parent;
   }
   var vfieldNameActual = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context, fieldNameActual)%>");
   var vfieldNameDisplay = targetWindow.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context, fieldNameDisplay)%>");
   var vfieldNameOID = targetWindow.document.getElementsByName(tmpFieldNameOID);
   var populateDescription =  "<%=XSSUtil.encodeForJavaScript(context, populateDescription)%>";
   
   if(populateDescription){
	   var description = targetWindow.document.getElementsByName("Description")[0];
	  description = description == null ? targetWindow.document.forms["createDialog"].txtdescription : description;
   description.value =  "<%=XSSUtil.encodeForJavaScript(context,description)%>" ;
   }
   vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context, selObjId)%>" ;
   vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,selObjName)%>" ;
   vfieldNameOID[0].value ="<%=XSSUtil.encodeForJavaScript(context, selObjId)%>" ;
   
   if(typeAhead != "true")
   getTopWindow().closeWindow();   
</script>
<%
         }
		// END:OEP:V6R2010:BUG 372490
		}
	}
	catch (Exception e)
	{
		bIsError = true;
		session.putValue("error.message", "" + e);
		//emxNavErrorObject.addMessage(e.toString().trim());
	}// End of main Try-catck block
%>

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
