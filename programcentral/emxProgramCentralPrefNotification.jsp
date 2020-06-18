<%--  emxProgramCentralPrefNotification.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<html>

<%@include file="emxProgramCentralNavigatorInclude.inc"%>
<%@include file = "emxProgramCentralNavigatorTopErrorInclude.inc"%>

  <head>
    <title></title>
    <meta http-equiv="imagetoolbar" content="no" />
    <meta http-equiv="pragma" content="no-cache" />
    <script language="JavaScript" src="emxUIConstants.js" type="text/javascript">
    </script>
    <script language="JavaScript" src="emxUIModal.js" type="text/javascript">
    </script>
    <script language="JavaScript" src="emxUIPopups.js" type="text/javascript">
    </script>
    <script type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");

      function doLoad() {
          if (document.forms[0].elements.length > 0) {
            var objElement = document.forms[0].elements[0];

            if (objElement.focus) objElement.focus();
            if (objElement.select) objElement.select();
          }
        }
    </script>
  </head>

<emxUtil:localize id="i18nId" bundle="emxProgramCentralStringResource" locale='<%= request.getHeader("Accept-Language") %>'/>
<%
      boolean AssignedTaskNotification=false;
      boolean LateTaskNotification=false;
      boolean RejectedTimesheetNotification=false;
      boolean SubmittedTimesheetNotification=false;
      
      String AssignedTaskNotificationYesSelected = "";
      String AssignedTaskNotificationNoSelected = "";
      String LateTaskNotificationYesSelected = "";
      String LateTaskNotificationNoSelected = "";
      String RejectedTimesheetNotificationYesSelected = "";
      String RejectedTimesheetNotificationNoSelected = "";
      String SubmittedTimesheetNotificationYesSelected = "";
      String SubmittedTimesheetNotificationNoSelected = "";
      String ChangeOwnerNotificationYesSelected = "";
      
      AssignedTaskNotification = PersonUtil.getAssignedTaskNotification(context);
      if( (AssignedTaskNotification == true))
      {
          AssignedTaskNotificationYesSelected="checked";
      }        
      else
      {
          AssignedTaskNotificationNoSelected="checked";
      }
      
      LateTaskNotification = PersonUtil.getLateTaskNotification(context);
      if( (LateTaskNotification == true))
      {
          LateTaskNotificationYesSelected="checked";
      }        
      else
      {
          LateTaskNotificationNoSelected="checked";
      }
      
      RejectedTimesheetNotification = PersonUtil.getRejectedTimesheetNotification(context);
      if( (RejectedTimesheetNotification == true))
      {
          RejectedTimesheetNotificationYesSelected="checked";
      }        
      else
      {
          RejectedTimesheetNotificationNoSelected="checked";
      }
      
      SubmittedTimesheetNotification = PersonUtil.getSubmittedTimesheetNotification(context);
      if( (SubmittedTimesheetNotification == true))
      {
          SubmittedTimesheetNotificationYesSelected="checked";
      }        
      else
      {
          SubmittedTimesheetNotificationNoSelected="checked";
      }
      
%>
<BODY onload="doLoad(), getTopWindow().turnOffProgress()">

  <form name="NotificationPrefForm" method="post" action="emxProgramCentralPrefNotificationProcess.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>  
    <table border="0" cellpadding="5" cellspacing="2" width="100%">

      <tr>
          <td width="350" class="label">
                        <emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.AssignedWBSTasks</emxUtil:i18n>
          </td>
        <td class="inputField">
                <table>
                        <tr>
          <%-- XSSOK--%>
                      <td><input type="radio" name="prefAssignedTaskNotification" id="prefAssignedTaskNotification" value="true" <%=AssignedTaskNotificationYesSelected%> /><emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.Yes</emxUtil:i18n></td>
                        </tr>
                        <tr>
          <%-- XSSOK--%> 
                      <td><input type="radio" name="prefAssignedTaskNotification" id="prefAssignedTaskNotification" value="false" <%=AssignedTaskNotificationNoSelected%> /><emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.No</emxUtil:i18n></td>
                        </tr>
                </table>
        </td>
      </tr>
      
            <tr>
          <td width="350" class="label">
                        <emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.LateWBSTasks</emxUtil:i18n>
          </td>
        <td class="inputField">
                <table>
                        <tr>
            <%-- XSSOK--%> 
                        <td><input type="radio" name="prefLateTaskNotification" id="prefLateTaskNotification" value="true" <%=LateTaskNotificationYesSelected%> /><emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.Yes</emxUtil:i18n></td>
                        </tr>
                        <tr>
             <%-- XSSOK--%> 
                       <td><input type="radio" name="prefLateTaskNotification" id="prefLateTaskNotification" value="false" <%=LateTaskNotificationNoSelected%> /><emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.No</emxUtil:i18n></td>
                        </tr>
                </table>
        </td>
      </tr>
      
                  <tr>
          <td width="350" class="label">
                        <emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.RejectedTimesheet</emxUtil:i18n>
          </td>
        <td class="inputField">
                <table>
                        <tr>
               <%-- XSSOK--%>
                       <td><input type="radio" name="prefRejectedTimesheetNotification" id="prefRejectedTimesheetNotification" value="true" <%=RejectedTimesheetNotificationYesSelected%> /><emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.Yes</emxUtil:i18n></td>
                        </tr>
                        <tr>
                <%-- XSSOK--%>
                       <td><input type="radio" name="prefRejectedTimesheetNotification" id="prefRejectedTimesheetNotification" value="false" <%=RejectedTimesheetNotificationNoSelected%> /><emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.No</emxUtil:i18n></td>
                        </tr>
                </table>
        </td>
      </tr>
      
                        <tr>
          <td width="350" class="label">
                        <emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.SubmittedTimesheet</emxUtil:i18n>
          </td>
        <td class="inputField">
                <table>
                        <tr>
               <%-- XSSOK--%> 
                        <td><input type="radio" name="prefSubmittedTimesheetNotification" id="prefSubmittedTimesheetNotification" value="true" <%=SubmittedTimesheetNotificationYesSelected%> /><emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.Yes</emxUtil:i18n></td>
                        </tr>
                        <tr>
              <%-- XSSOK--%>
                         <td><input type="radio" name="prefSubmittedTimesheetNotification" id="prefSubmittedTimesheetNotification" value="false" <%=SubmittedTimesheetNotificationNoSelected%> /><emxUtil:i18n localize="i18nId">emxProgramCentral.NotificationPreference.No</emxUtil:i18n></td>
                        </tr>
                </table>
        </td>
      </tr>
      
      
    </table>
    <input type="image" height="1" width="1" border="0" />
  </form>
 </BODY>

<%@include file = "emxProgramCentralNavigatorBottomErrorInclude.inc"%>
</html>
