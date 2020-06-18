<%--  emxEngrTableDisconnectProcess.jsp -  This page disconnects the selected objects.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

 
<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
	//String portalMode = emxGetParameter(request, "portalMode");
	
	String checkBoxId[] = emxGetParameterValues(request, "emxTableRowId");

	
	
	if(checkBoxId != null) {
		
		String objectIdList[] = new String[checkBoxId.length];
		
		try {
			
			String delId = "";
			
			for (int i = 0; i < checkBoxId.length; i++) {
				
				StringTokenizer st = new StringTokenizer(checkBoxId[i], "|");
				String sObjId = st.nextToken();
				objectIdList[i] = sObjId;
				
				while (st.hasMoreTokens()) {
					sObjId = st.nextToken();
				}
				
				delId = delId + sObjId + ";";

			}
			//code for disconnecting          
			DomainRelationship.disconnect(context, objectIdList);
		} 
		catch (Exception Ex) {
			session.putValue("error.message", Ex.toString());
		}
	}
%>

<script language="Javascript">

	  parent.document.location.href=parent.document.location.href 
  
</script>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
