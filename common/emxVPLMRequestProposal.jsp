<%--  emxVPLMRequestProposal.jsp   -   
   Copyright (c) 2010 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxVPLMRequestProposal.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $

   Wk 34 2011 : RCI - RI 120185 - Check Replace Twice on same source
--%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%@include file = "../components/emxComponentsUtil.inc"%> 
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%

   HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);

     String action = emxGetParameter(request, "action");
  
try
{
      String rowIds[] = emxGetParameterValues(request, "emxTableRowId");
      String role = (String) requestMap.get("role");
      String objectId = (String) requestMap.get("objectId");
      String user = (String) requestMap.get("user");

      Map programMap = new HashMap();
	programMap.put("emxTableRowId", rowIds);
      programMap.put("objectId", objectId);
      programMap.put("action", action);
  

	
	String[] methodargs =JPO.packArgs(programMap);
	if (action.equals("edit"))
	{
     	 JPO.invoke(context, "emxVPLMPropose", null,"updateValue", methodargs);	
	}
       	else	
	{
     	 JPO.invoke(context, "emxVPLMPropose", null,"requestProposal", methodargs);	
        }


  }
catch (Exception ex)
{
	    
  if  ((  ex.toString()  !=  null)  &&  (ex.toString().trim().length()>0))   
	    {
	    	String msgError = (String)(ex.toString());
	    	if ( (msgError.indexOf("Delete")) > 0 )
	    	{
			String msgTitle = UINavigatorUtil.getI18nString("emxVPMSRMPropCmds.Command.Request.Delete",  "emxVPLMSRMServicesStringResource",  request.getHeader("Accept-Language"));
			emxNavErrorObject.addMessage(msgTitle); 
         	}
	else if ( ((msgError.indexOf("Valid")) > 0 ) && ((msgError.indexOf("proposal")) > 0 ))
	    	{
			String msgTitle = UINavigatorUtil.getI18nString("emxVPMSRMPropCmds.Command.Request.Valid",  "emxVPLMSRMServicesStringResource",  request.getHeader("Accept-Language"));
			emxNavErrorObject.addMessage(msgTitle); 
            }
	else if ( ((msgError.indexOf("Valid")) > 0 ) && ((msgError.indexOf("replace")) > 0 ))
	    	{
			String msgTitle = UINavigatorUtil.getI18nString("emxVPMSRMPropCmds.Command.Request.Twice",  "emxVPLMSRMServicesStringResource",  request.getHeader("Accept-Language"));
            emxNavErrorObject.addMessage(msgTitle); 
	    	}		

	    	else
	    	 ex.printStackTrace();
	    }

	    
}

%>
 <%@include file = "emxNavigatorBottomErrorInclude.inc"%>

<html>
<body>

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="Javascript" >

// remise à jour de la page

    top.refreshTablePage();	
</script>


</body>
</html>

 


