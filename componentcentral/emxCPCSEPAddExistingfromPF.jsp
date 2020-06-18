<%--  emxCPCSEPAddExistingfromPF.jsp  -
	(c) Dassault Systemes, 1993-2016.  All rights reserved.
--%>

<%@ include file  ="../emxUIFramesetUtil.inc"%>
<%@include file  ="emxCPCInclude.inc"%>
<%
		//DebugUtil.setDebug(true);
		String partFamilyId = emxGetParameter(request, "objectId");
		CPCPart part=new CPCPart();
		String[] selSEPPartIds = emxGetParameterValues(request, "emxTableRowId");
		boolean processFailed = false;
	try
	{
		if(selSEPPartIds != null)
			{
	          String relIdList[] = new String[selSEPPartIds.length];
	          for(int i=0;i<selSEPPartIds.length;i++){
					StringTokenizer st = new StringTokenizer(selSEPPartIds[i], "|");
					String sRelId = st.nextToken();
					BusinessObject FromObject = null;
					relIdList[i] = sRelId;
            }

				part.addSEPPartstoPF(context, relIdList,partFamilyId);
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
		getTopWindow().closeWindow();
		getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
		}//End of if loop
</script>
