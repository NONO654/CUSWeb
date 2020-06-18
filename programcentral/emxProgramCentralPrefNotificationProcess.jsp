<%--  emxProgramCentralPrefNotificationProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@include file = "emxProgramCentralNavigatorInclude.inc"%>
<%@include file = "emxProgramCentralNavigatorTopErrorInclude.inc"%>

<emxUtil:localize id="i18nId" bundle="emxProgramCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>

<%

String prefAssignedTaskNotification = emxGetParameter(request, "prefAssignedTaskNotification");
String prefLateTaskNotification = emxGetParameter(request, "prefLateTaskNotification");
String prefRejectedTimesheetNotification = emxGetParameter(request, "prefRejectedTimesheetNotification");
String prefSubmittedTimesheetNotification = emxGetParameter(request, "prefSubmittedTimesheetNotification");

if( (prefAssignedTaskNotification == null) || ("".equals(prefAssignedTaskNotification)) )
{
	prefAssignedTaskNotification="";
}
if( (prefLateTaskNotification == null) || ("".equals(prefLateTaskNotification)) )
{
	prefLateTaskNotification="";
}
if( (prefRejectedTimesheetNotification == null) || ("".equals(prefRejectedTimesheetNotification)) )
{
	prefRejectedTimesheetNotification="";
}
if( (prefSubmittedTimesheetNotification == null) || ("".equals(prefSubmittedTimesheetNotification)) )
{
	prefSubmittedTimesheetNotification="";
}

try
{
    ContextUtil.startTransaction(context, true);
    if(prefAssignedTaskNotification !=null)
        PersonUtil.setAssignedTaskNotificationPreference(context,prefAssignedTaskNotification.trim());
    if(prefLateTaskNotification !=null)
        PersonUtil.setLateTaskNotificationPreference(context,prefLateTaskNotification.trim());
    if(prefRejectedTimesheetNotification !=null)
        PersonUtil.setRejectedTimesheetNotificationPreference(context,prefRejectedTimesheetNotification.trim());
    if(prefSubmittedTimesheetNotification !=null)
        PersonUtil.setSubmittedTimesheetNotificationPreference(context,prefSubmittedTimesheetNotification.trim());
    
    ContextUtil.commitTransaction(context);
}
catch (Exception ex) {
    ContextUtil.abortTransaction(context);

    if(ex.toString()!=null && (ex.toString().trim()).length()>0)
    {
        emxNavErrorObject.addMessage("emxprefNotification:" + ex.toString().trim());
    }
}
finally
{
    
}

%>

<%@include file = "emxProgramCentralNavigatorBottomErrorInclude.inc"%>


