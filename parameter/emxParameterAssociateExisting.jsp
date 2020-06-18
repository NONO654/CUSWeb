<%-- emxConnectExistingParameter.jsp --
  Copyright (c) 1992-2008 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc" %>

 
<%
  	String parameterId   = emxGetParameter(request,"objectId");
		
	String connectObjectId   = emxGetParameter(request,"connectFromId");
	String relationship   = emxGetParameter(request,"connectRelationship");
	
	if (parameterId == null) {
		parameterId = "";
	}
	
	if (relationship == null) {
		relationship = "";
	}
	
	if (connectObjectId == null) {
		connectObjectId = "";
	}
	
	String[] objectsToConnectId = emxGetParameterValues(request, "emxTableRowId");

	try
	{
		if(objectsToConnectId != null) {
	
			
			String selectedId = "";
		
			for (int i=0; i < objectsToConnectId.length ;i++) {
				StringTokenizer strTokens = new StringTokenizer(objectsToConnectId[i],"|");
			
				if (strTokens.hasMoreTokens()) {
					selectedId = strTokens.nextToken();
				}
			
				objectsToConnectId[i] = selectedId;
						
			}
			
			Map argsHash = new HashMap();
			String retVal = null;
			
			if(connectObjectId.length() != 0){
	
				argsHash.put("objectId", connectObjectId);
				argsHash.put("parametersId", objectsToConnectId);
				argsHash.put("relationship", relationship);
		
				// Pack arguments into string array.
				String[] args = JPO.packArgs(argsHash);
			
				retVal =(String) JPO.invoke(context, "emxParameterConnect", null, "associateParameters", args, String.class);
				
				
			}else{
					
					argsHash.put("parameterId", parameterId);
					argsHash.put("objectsId", objectsToConnectId);
					argsHash.put("relationship", relationship);
		
				// Pack arguments into string array.
					String[] args = JPO.packArgs(argsHash);
			
					retVal =(String) JPO.invoke(context, "emxParameterConnect", null, "connectToObjects", args, String.class);
				}
					
					if(retVal == null) {			
%>
					<script>
					  top.opener.top.refreshTablePage();
					  top.close();
					
					//  top.opener.refreshTablePage();
					 // window.close();
					</script>
<%		
				}
				else {				
					// Message processing for eliminating exceptions of the type : java.lang.Exception: Message:No toconnect access to business object 'PlmParameter PlmParameter-0000101 A' Severity:2 ErrorCode:1500028
					
					String errorMsg = retVal;
					
					if(errorMsg.contains("java.lang.Exception:")){
						errorMsg = errorMsg.replaceAll("java.lang.Exception:","");
					}
					
					if(errorMsg.contains("Message:")){
						errorMsg = errorMsg.replaceAll("Message:","");
					}
					
					if(errorMsg.contains("Severity")){
						int i = errorMsg.indexOf("Severity");
						errorMsg = errorMsg.substring(0,i-1);
					}
									
%>			
					<script>
						alert(" <%= errorMsg %>");
					</script>
<%			
				}
		}
		else {
%>
			<script language="Javascript">
				alert("<emxUtil:i18n localize="i18nId">emxParameter.FindObjects.NoItems</emxUtil:i18n>");
			</script>
<%
	}
}
catch(Exception ex) {
%>					
	<script>
	  top.opener.top.refreshTablePage();
	  top.close();
	</script>
<%
	if (ex.toString()!=null && ex.toString().length()>0)
	{
		emxNavErrorObject.addMessage(ex.toString());
	}
	System.out.println("error.message" + ex.toString());
}
  
%>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc" %>

