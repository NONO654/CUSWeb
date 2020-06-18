<%--  emxParameterDeleteParameters.jsp  --  Delete the selected parameters
  Copyright (c) 1992-2012 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxParameterStartTransaction.inc"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>

<%
    String parameters[] = emxGetParameterValues(request, "emxTableRowId");
    int size = null != parameters ? parameters.length : -1;
    if (size > 0)
    {
        try {
			String [] paramId = new String[size];
            
			for (int i=0; i<size; i++)
            {
                String param_i = parameters[i];
				
                if ((null != param_i) && !param_i.isEmpty())
                {
                    if (param_i.startsWith("|"))
                        param_i = param_i.substring(1);
                    int pipesIdx = param_i.indexOf("||");
                    if (pipesIdx > 0)
                        param_i= param_i.substring(0, pipesIdx);
                 
                }
				
				paramId[i] = param_i;
            }
		
			String retVal = null;
			Map argsHash = new HashMap();
			argsHash.put("paramId", paramId);
			
			String[] args = JPO.packArgs(argsHash);
			
			retVal =(String) JPO.invoke(context, "emxParameter", null, "deleteParameters", args, String.class);
			
				if(retVal == null) {
			%>
						<script>
						   top.refreshTablePage();
						</script>
<%
			}	 else{
			%>
					<script>
						  alert("<%= retVal %>");
					</script>
		<%
					}
			
			
            %>
            <%@ include file = "emxParameterCommitTransaction.inc" %>
            <%
        } catch (Exception e) {
            System.out.println("Delete parameter failed : " + e.getMessage());
            emxNavErrorObject.addMessage("Delete parameter failed : " + e.getMessage());
            %>
            <%@ include file = "emxParameterAbortTransaction.inc" %>
            <%
        }
    }
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>

<%-- Reload the page --%>
<script language="Javascript" >
    // To avoid a loop in CATIA
    if(window.parent.location.href != this.document.location.href)
    {
        window.parent.location.href = window.parent.location.href;
    }
</script>
