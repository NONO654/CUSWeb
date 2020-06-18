<%--
  FullSearchUtil.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.program.ProgramCentralUtil"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../common/emxCompCommonUtilAppInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import="matrix.db.Context"%> 

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<%
   boolean bIsError = false;
   try
   {
      String strMode = emxGetParameter(request,"mode");
      String strObjId = emxGetParameter(request, "objectId");  
      String strRowId[] = emxGetParameterValues(request,"emxTableRowId");


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
 
         if (strMode.equalsIgnoreCase("Chooser"))
         {
            String strSearchMode = emxGetParameter(request, "chooserType");
            String fieldNameActual = emxGetParameter(request, "fieldNameActual");
            String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");

            strRowId = ProgramCentralUtil.parseTableRowId(context, strRowId);
            
            // For most webform choosers, default to the object id/name...
            String selObjId = strRowId[0];
            DomainObject selObject = new DomainObject(selObjId);
            String selObjName = selObject.getInfo(context, DomainConstants.SELECT_NAME);

%>
<script language="javascript" type="text/javaScript">
//XSSOK
	var frame = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(), "slideInFrame");
	if(frame == null){
		frame = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(), "slideInFrame");
		if(frame == null){
			frame = emxUICore.findFrame(getTopWindow(), "PMCTaskManagementProperties");
		}
	}
	var vfieldNameActual;
	var vfieldNameDisplay;
	if(frame != null){
		 vfieldNameActual = frame.document.getElementsByName("<%=fieldNameActual%>");
		 vfieldNameDisplay = frame.document.getElementsByName("<%=fieldNameDisplay%>"); //XSSOK
   } else {
	 //XSSOK
	    vfieldNameActual = getTopWindow().getWindowOpener().document.getElementsByName("<%=fieldNameActual%>");
	    vfieldNameDisplay = getTopWindow().getWindowOpener().document.getElementsByName("<%=fieldNameDisplay%>"); //XSSOK
   }
   //XSSOK
   vfieldNameActual[0].value ="<%=selObjId%>" ;
   vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,selObjName)%>" ;
 </script>
<%
         }

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
<script language="javascript" type="text/javaScript">
				<%
	if(!ProgramCentralUtil.is3DSearchEnabled(context)){
	%>
		window.getTopWindow().closeWindow();
		<%}%>
</script>

