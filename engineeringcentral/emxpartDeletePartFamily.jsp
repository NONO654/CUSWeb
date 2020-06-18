<%--  emxpartDeletePartFamily.jsp   - The Part Family delete object processing page
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%

  DomainObject domObj = DomainObject.newInstance(context);
  boolean hasException = false;
  String[] sCheckBoxArray = emxGetParameterValues(request, "emxTableRowId");
  if(sCheckBoxArray != null)
  {
         try
         {
            for(int i=0; i < sCheckBoxArray.length; i++)
            {
		       String sBusId = sCheckBoxArray[i];
               if(sBusId == null || sBusId.equalsIgnoreCase("null"))
               {
%>
                  <emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.InvalidBusinessObject</emxUtil:i18n>
<%
                 return;
               }
               else
               {
            	   sBusId = (String) FrameworkUtil.split(sBusId, "|").get(0);
               }
	        domObj.setId(sBusId);
	        hasException = false;
	        domObj.deleteObject(context);
        }

        }//end of try
        catch(Exception Ex)
        {
                session.putValue("error.message",Ex.getMessage());
        }
}

%>
<%@include file = "emxDesignBottomInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript">

<%
  if(!hasException)
  {
%>
    var contentFrame = getTopWindow().findFrame(getTopWindow(),"listHidden");
    contentFrame.parent.document.location.href=contentFrame.parent.document.location.href;
<%
   }
%>
</script>
