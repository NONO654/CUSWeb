<%--  emxActivatInactivateProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOServiceManagement/CNext/webroot/servicemanagement/emxActivateInactivateProcess.jsp 1.1 Fri Nov 14 15:40:25 2008 GMT ds-hchang Experimental$
--%>

<html>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<head>
</head>

<%
    String sCommand = (String) emxGetParameter(request, "cmd");
	String sCurrentState = (String) emxGetParameter(request, "cstate");
    String[] tableRowIds = request.getParameterValues("emxTableRowId");
    String wsId = tableRowIds[0];
    boolean statusFlag = true;
    String sErrorMsg = "";
    try
    {
        DomainObject bo = DomainObject.newInstance(context, wsId);
        State curState = bo.getCurrentState(context);

        // This is for validation only. Check if the current state the user is viewing is actually the same as in database.
        String sActualCurrentStateName = curState.getName();

        //if command is promote
        if (sCommand.equals("promote"))
        {
            if (!sActualCurrentStateName.equals(sCurrentState)) {
        		String errMsgKey = "emxWSManagement.LifeCycle." + sCurrentState + ".Wrongstate.ErrorMessage";
        		String stringPromotionMsg=UINavigatorUtil.getI18nString(errMsgKey, "emxWSManagementStringResource", request.getHeader("Accept-Language"));
                sErrorMsg = stringPromotionMsg;
                statusFlag = false;                
                if( ( sErrorMsg.toString()!=null ) && (sErrorMsg.toString().trim()).length()>0 )
                {
                    emxNavErrorObject.addMessage(sErrorMsg.toString().trim());
                }
            } else {
            	try
            	{  
                	bo.promote(context);
           		}
            	catch (MatrixException me)
            	{
                	String stringPromotionMsg=UINavigatorUtil.getI18nString("emxFramework.LifeCycle.PromotionFailed.ErrorMessage", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
                	sErrorMsg = stringPromotionMsg;
                	statusFlag = false;                
                	if( ( sErrorMsg.toString()!=null ) && (sErrorMsg.toString().trim()).length()>0 )
                	{
                    	emxNavErrorObject.addMessage(sErrorMsg.toString().trim());
                	}
            	}
            }
        }

	  //if command is demote
        if (sCommand.equals("demote"))
        {
            if (!sActualCurrentStateName.equals(sCurrentState)) {
				String errMsgKey = "emxWSManagement.LifeCycle." + sCurrentState + ".Wrongstate.ErrorMessage";
				String stringPromotionMsg=UINavigatorUtil.getI18nString(errMsgKey, "emxWSManagementStringResource", request.getHeader("Accept-Language"));
        		sErrorMsg = stringPromotionMsg;
        		statusFlag = false;                
        		if( ( sErrorMsg.toString()!=null ) && (sErrorMsg.toString().trim()).length()>0 )
        		{
            		emxNavErrorObject.addMessage(sErrorMsg.toString().trim());
        		}
    		} else {
            	try
            	{
                	bo.demote(context);
            	}
            	catch (MatrixException me)
            	{
                	String stringDemotionMsg=UINavigatorUtil.getI18nString("emxFramework.LifeCycle.DemotionFailed.ErrorMessage", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
                 	sErrorMsg = stringDemotionMsg;
                 	statusFlag = false;
                 	if( ( sErrorMsg.toString()!=null ) && (sErrorMsg.toString().trim()).length()>0)
                 	{
                    	emxNavErrorObject.addMessage(sErrorMsg.toString().trim());
                 	}
            	}
            }
        }
    }
    catch(Exception ex)
    {
        statusFlag = false;
        if( ( ex.toString()!=null ) && (ex.toString().trim()).length()>0 )
            emxNavErrorObject.addMessage(ex.toString().trim());
    }
%>

<script language="JavaScript">
<%
if (statusFlag)
{
%>
	getTopWindow().refreshTablePage();
<%
} else {
%>
<body class="content" onload="turnOffProgress();">
<body>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
<%
}
%>
</script>

</html>
