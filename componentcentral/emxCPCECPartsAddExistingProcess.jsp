<%--  emxCPCECPartsAddExistingProcess.jsp  -
	(c) Dassault Systemes, 1993-2016.  All rights reserved.
--%>

<%@ include file  ="../emxUIFramesetUtil.inc"%>
<%@include file  ="emxCPCInclude.inc"%>
<%
		String objectId = emxGetParameter(request, "objectId");
		String policy=new DomainObject(objectId).getInfo(context,DomainConstants.SELECT_POLICY);
		CPCPart part=new CPCPart(objectId);
		String[] selPartIds = emxGetParameterValues(request, "emxTableRowId");
		DebugUtil.debug("Inside the CPC:selPartIds" +selPartIds);
		boolean processFailed = false;
	try
	{
		if(selPartIds != null)
			{
	          String relIdList[] = new String[selPartIds.length];
	          for(int i=0;i<selPartIds.length;i++){
					StringTokenizer st = new StringTokenizer(selPartIds[i], "|");
					String sRelId = st.nextToken();
					DebugUtil.debug("The relIdList: "+sRelId);
					BusinessObject FromObject = null;
					relIdList[i] = sRelId;
					DebugUtil.debug("The relIdList: "+relIdList[i]);
            }

				part.addECParttoSEP(context, relIdList,policy);
			}//End of if loop
		else{
				processFailed = true;
	%>
	<script language="Javascript">
	alert("<emxUtil:i18n localize="i18nId">emxComponentCentral.Common.PleaseMakeASelection</emxUtil:i18n>");
	</Script>
	<%
		}//End of else loop
	}//End of try block
    catch(Exception ex)
    {
      processFailed = true;
      session.putValue("error.message", ex.toString());
    }//End of catch loop
%>

<script language="Javascript">
	var processFailed = <%=processFailed%>;
	if(!processFailed){
		// Following refresh logic (2 lines) has been introduced during Flat table to Structure Browser conversion
        getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
        getTopWindow().closeWindow();
		}//End of if loop
</script>
