<%--  emxCPCECPartsAddExistingProcess.jsp  -
	(c) Dassault Systemes, 1993-2016.  All rights reserved.

--%>

<%@ include file  ="../emxUIFramesetUtil.inc"%>
<%@include file  ="emxCPCInclude.inc"%>
<%
		//DebugUtil.setDebug(true);
		String ecPartId = emxGetParameter(request, "objectId");
		DebugUtil.debug("Inside the CPC:ecPartId" +ecPartId);
		CPCPart part=new CPCPart();
		String[] selSEPPartIds = emxGetParameterValues(request, "emxTableRowId");
		DebugUtil.debug("Inside the CPC:selPartIds" +selSEPPartIds);
		boolean processFailed = false;
	try
	{
		if(selSEPPartIds != null)
			{
	          String relIdList[] = new String[selSEPPartIds.length];
	          for(int i=0;i<selSEPPartIds.length;i++){
					StringTokenizer st = new StringTokenizer(selSEPPartIds[i], "|");
					String sRelId = st.nextToken();
					DebugUtil.debug("The relIdList: "+sRelId);
					BusinessObject FromObject = null;
					relIdList[i] = sRelId;
					DebugUtil.debug("The relIdList: "+relIdList[i]);
            }

				part.addSEPPartstoEC(context, relIdList,ecPartId);
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
