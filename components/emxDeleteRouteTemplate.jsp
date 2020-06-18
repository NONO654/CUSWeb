<%--  emxTeamDeleteRouteTemplate.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxDeleteRouteTemplate.jsp.rca 1.11 Wed Oct 22 16:18:52 2008 przemek Experimental przemek $
--%>

<%@include file  = "../emxUICommonAppInclude.inc"%>
<%@include file  = "emxRouteInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  String[] sTemplateIds = ComponentsUIUtil.getSplitTableRowIds(request.getParameterValues("emxTableRowId"));
  for(int i=0;i<sTemplateIds.length;i++) {
    try{
    String sTemplateId = sTemplateIds[i];
    
    BusinessObject boTemplate = new BusinessObject(sTemplateId);
    boTemplate.open(context);
    boTemplate.remove(context);
    %>
    <script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript">
	  getTopWindow().deleteObjectFromTrees("<%=XSSUtil.encodeForJavaScript(context, sTemplateId)%>", false);
	</script>

<%
    boTemplate.close(context);
    }
    catch(Exception e)
    {
          String errMsg = e.getMessage();
          //Remove the java.lang.Exception coming in the message
          if(errMsg.indexOf("No delete") > -1 )
          {
          	 String object = errMsg.substring(errMsg.indexOf("'")+1,errMsg.lastIndexOf("'"));
			 errMsg=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(),"emxComponents.Common.NoDeleteAccess")+":"+object;
          
          }else if(errMsg.indexOf("No fromdisconnect") > -1)
          {
          	 errMsg = errMsg.substring(29,86);
          }
		  

      session.putValue("error.message",errMsg);
    }
  }
%>

  <script language="Javascript">
    parent.window.location.href= parent.window.location.href;
  </script>
