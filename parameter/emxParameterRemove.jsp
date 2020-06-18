<%-- emxConnectExistingParameter.jsp --
  Copyright (c) 1992-2008 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

--%>

<%@include file="../emxUICommonAppInclude.inc" %>
<%-- important for importing packages as java.lang.*,matrix.db.*, matrix.util.* ,com.matrixone.servlet.*,java.util.*,com.matrixone.apps.domain.util.* --%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc" %>


<%
	String objectId = emxGetParameter(request, "objectId");
	String[] rowsId = emxGetParameterValues(request, "emxTableRowId");
	String[] connectionsId = new String[rowsId.length];

	try {
		if(rowsId != null) {
		
			String connection = "";
				
			for (int i=0; i < rowsId.length; i++) {
				StringTokenizer strTokens = new StringTokenizer(rowsId[i],"|");
				if (strTokens.hasMoreTokens()) {
					connection = strTokens.nextToken();			
				}

				connectionsId[i] = connection;	
			}
		
			String retVal = null;
			Map argsHash = new HashMap();
			argsHash.put("connectionsId", connectionsId);
			argsHash.put("objectId", objectId);
			
			String[] args = JPO.packArgs(argsHash);
			
			retVal =(String) JPO.invoke(context, "emxParameterConnect", null, "removeConnections", args, String.class);
		
			if(retVal == null) {
			%>
						<script>
						   //top.refreshTablePage();
						   if (parent.editableTable)
						   {
							   parent.editableTable.loadData();
							   parent.emxEditableTable.refreshStructureWithOutSort();
						   }
						   else
						   {
							   windows.refreshTablePage();
						   }
						   refreshStructureTree();
						</script>
<%
			}	 else{
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
						  alert("<%= errorMsg %>");
					</script>
		<%
					}
		}
	else
	{
%>
		<script language="Javascript">
			alert("<emxUtil:i18n localize="i18nId">emxParameter.Associate.RemoveAlert</emxUtil:i18n>");
		</Script>
<%
	}
}
catch(Exception ex)
{
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

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc" %>


