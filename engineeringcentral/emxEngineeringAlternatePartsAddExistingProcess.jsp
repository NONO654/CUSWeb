<%--  emxEngineeringAlternatePartsAddExistingProcess.jsp  - 
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
		Part part = (Part)DomainObject.newInstance(context,DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
		String objectId = emxGetParameter(request, "objectId");
		part.setId(objectId);
		String[] selPartIds = emxGetParameterValues(request, "emxTableRowId");
		String errorMesg = null;
		//boolean processFailed = false;
	try
	{
		if(selPartIds != null)
			{
			
			for (int i=0; i < selPartIds.length ;i++)
				{
				StringTokenizer strTokens = new StringTokenizer(selPartIds[i],"|");
					if (strTokens.hasMoreTokens())
					{
						String selectedId = strTokens.nextToken();
						try {
							part.createAlternatePart(context, selectedId);
						} catch (Exception e) {
							errorMesg = e.toString();			
						}
					}//End of if loop
				}//End of for loop
			}//End of if loop
		else{
				//processFailed = true;
	%>
	<script language="Javascript">
	alert("<emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.PleaseMakeASelection</emxUtil:i18n>");
	</Script>
	<%
		}//End of else loop
	}//End of try block
    catch(Exception ex)
    {
      //processFailed = true;
      session.putValue("error.message", ex.toString());
    }//End of catch loop
    
    if (errorMesg != null) {
    	session.putValue("error.message", errorMesg);
    }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="Javascript">
//modified for IR-155489V6R2013x 
		//top.parent.location.href = "../common/emxCloseWindow.jsp";
		//top.getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;

		getTopWindow().getWindowOpener().window.location.href = getTopWindow().getWindowOpener().window.location.href;
		getTopWindow().closeWindow();
</script>
