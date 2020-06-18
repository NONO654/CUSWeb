<%--  CPVPersonSubmit.jsp 

   (c) Dassault Systemes, 1993-2015.  All rights reserved.

--%>

<%-- 
 ** history:
 *  @quickreview spl7 gh4 2017/07/26: IR-533599 : Fixed issue of XSS encoding feature
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@ page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "com.matrixone.apps.domain.DomainObject"%>
<%@ page import = "com.matrixone.apps.domain.util.PersonUtil"%>

<emxUtil:localize id="i18nId" bundle="emxVPLMProcessEditorStringResource" locale='<%= XSSUtil.encodeForHTML(context, request.getHeader("Accept-Language")) %>' />

<html>

	<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<head>
		<%
		try{
			
           	String fieldNameActual 	= emxGetParameter(request, "fieldNameActual");
           	String fieldNameDisplay = emxGetParameter(request, "fieldNameDisplay");
           	String[] emxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
			StringList emxTableRowIdList = FrameworkUtil.split(emxTableRowIds[0], "|");

           	String sObjId = (String)emxTableRowIdList.get(0);
           	DomainObject selObject = new DomainObject(sObjId);
           	String sObjName = selObject.getInfo(context, DomainConstants.SELECT_NAME);
           	String sDisplayName = PersonUtil.getFullName(context, sObjName);
		%>
		<script language="javascript" type="text/javascript">
					
			var frame, vfieldNameActual, vfieldNameDisplay;

			frame = emxUICore.findFrame(getTopWindow(), "slideInFrame");
				
			if(frame != null){					
				vfieldNameActual = frame.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>");
				vfieldNameDisplay = frame.document.getElementsByName("<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>");
				vfieldNameActual[0].value ="<%=XSSUtil.encodeForJavaScript(context,sObjName)%>" ;
				vfieldNameDisplay[0].value ="<%=XSSUtil.encodeForJavaScript(context,sDisplayName)%>" ;
			}
			else{
				// Close the popup window
				window.location.href = "../common/emxCloseWindow.jsp";
			}
		</script>	
		<%
		}
		catch(Exception ex){
		    if (ex.toString() != null && (ex.toString().trim()).length() > 0){
		        emxNavErrorObject.addMessage(ex.toString().trim());
		    %>
		    <%@ include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
		  <%}
		
		}%>
	</head>
</html> 
