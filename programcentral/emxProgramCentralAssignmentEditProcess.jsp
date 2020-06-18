<%-- emxProgramCentralAssignmentEditProcess.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  Reviewed for Level III compliance by JDH 5/2/2002

  static const char RCSID[] = "$Id: emxProgramCentralAssignmentEditProcess.jsp.rca 1.17 Wed Oct 22 15:50:30 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>.
<%@page import = "com.matrixone.apps.program.Task" %>
<jsp:useBean id="formBean" scope="session" class="com.matrixone.apps.common.util.FormBean"/>

<%
  com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, "PROGRAM");

  String selectedDateStr = emxGetParameter(request, "selectedDate");
  String selectedId = emxGetParameter(request, "busId");

  formBean.processForm(session,request);
  Iterator elements            = formBean.getElementNames();
  String element               = null;
  String objectId              = null;
  String currentPrefix         = "currentMillisecondOffset";
  String oldPrefix             = "oldDate";
  String currentPercentPrefix  = "newPercent";
  String oldPercentPrefix      = "oldPercent";
  String oldPercentString      = null;
  String currentPercentString  = null;
  String oldMSOffsetString     = null;
  String index                 = null;
  String sErrorMsg = "";
  long currentMSOffset;
  long oldMSOffset;
  double currentPercentValue;
  double oldPercentValue;

  boolean closeWindow = "true".equalsIgnoreCase((String)formBean.getElementValue("closeEditWindow"));
  String editPageLocation = (String)formBean.getElementValue("thisPageLocation");

  String sPolicyName = PropertyUtil.getSchemaProperty(context,"policy_ProjectTask");
  String sCompleteStateName = PropertyUtil.getSchemaProperty(context,"policy",sPolicyName,"state_Complete");
  while(elements.hasNext())
  {
    element = (String)elements.next();
    if(element.startsWith(currentPrefix))
    {
      // get index
      index = element.substring(currentPrefix.length());
      // get objectId
      objectId = (String)formBean.getElementValue("ID_of_" + index);
      task.setId(objectId);
      oldPercentString     = (String)formBean.getElementValue(oldPercentPrefix + index);
      currentPercentString = (String)formBean.getElementValue(currentPercentPrefix + index);
      oldPercentString     = oldPercentString.substring(0,oldPercentString.length()-2);
      currentPercentString = currentPercentString.substring(0,currentPercentString.length()-2);

      if(oldPercentString != null && currentPercentString != null) {
        oldPercentValue     = Task.parseToDouble(oldPercentString);
        currentPercentValue = Task.parseToDouble(currentPercentString);
        if(oldPercentValue != currentPercentValue)  // if a change has been made
        {                                           // update the state
          // State Names
          String sActiveStateName = PropertyUtil.getSchemaProperty(context,"policy",sPolicyName,"state_Active");
          String sReviewStateName = PropertyUtil.getSchemaProperty(context,"policy",sPolicyName,"state_Review");
          // get the states for the object
          StringList busSelects = new StringList(3);
          busSelects.add(task.SELECT_STATES);
          busSelects.add(task.SELECT_CURRENT);
          busSelects.add(task.SELECT_PERCENT_COMPLETE);
          Map taskMap           = task.getInfo(context, busSelects);
          String oldPercent     = (String) taskMap.get(task.SELECT_PERCENT_COMPLETE);
          String currentState   = (String) taskMap.get(task.SELECT_CURRENT);
          StringList statesList = (StringList) taskMap.get(task.SELECT_STATES);

          try {
            try {
              if(oldPercentValue <= 0.0) {
                if(currentPercentValue > 0.0 && currentPercentValue < 100.0) {
                  // object is in create state; promote object to active state
                  task.setState(context, sActiveStateName);
                } else if(currentPercentValue >= 100.0) {
                  if(currentState.equals(sCompleteStateName)) {
                    task.setState(context, sReviewStateName);
                  }
                }
              } else if(oldPercentValue >= 100.0) {
                if(currentPercentValue >= 0.0 && currentPercentValue < 100.0) {
                  //set the state to active state
                  task.setState(context, sActiveStateName);
                }
              } else if(oldPercentValue > 0.0 && oldPercentValue < 100.0) {
                if(currentPercentValue <= 0.0) {
                  // unknown state; demote to create state regardless of current state
                  // task.setState(context, (String)statesList.get(0));
                } else if(currentPercentValue >= 100.0) {
                  // if currentPercentValue is 100 set the state to "Review"
                  task.setState(context, sReviewStateName);
                }
              }
              // set the percent complete to value given by user
              task.setAttributeValue(context, task.ATTRIBUTE_PERCENT_COMPLETE, currentPercentString);
            } catch ( Exception e ){
               sErrorMsg = e.getMessage();
            }
          } catch (NumberFormatException e) {
            try {
              //just switching names to clear code up because newPercent
              //is a state instead of a percent
              String newState = currentPercentString;
              //promote/demote to requested state;
              int direction = task.setState(context, newState);
            } catch ( Exception error ){
                sErrorMsg = error.getMessage();
            }
          }
        }
      }

      // get date values
      oldMSOffsetString     = (String)formBean.getElementValue(oldPrefix + index);
      if(oldMSOffsetString != null) {
        oldMSOffset = Long.parseLong(oldMSOffsetString);
        if (objectId.equals(selectedId)){
          double clientTZOffset = (new Double((String)session.getValue("timeZone"))).doubleValue();
          selectedDateStr = com.matrixone.apps.domain.util.eMatrixDateFormat.getFormattedInputDate(context,selectedDateStr, clientTZOffset,request.getLocale());
          currentMSOffset = Date.parse(selectedDateStr);
        } else {
          currentMSOffset = oldMSOffset;
        }
        if(currentMSOffset != oldMSOffset) // if a change has been made
        {                                  // update the finish date
          Date date = new Date(currentMSOffset);
          //java.text.SimpleDateFormat sdformat = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat());
          java.text.SimpleDateFormat sdformat = new java.text.SimpleDateFormat(eMatrixDateFormat.getEMatrixDateFormat(), Locale.US);
          String dateString = sdformat.format(date).trim();
          try {
            task.setAttributeValue(context, task.ATTRIBUTE_TASK_ACTUAL_FINISH_DATE, dateString);
            task.setState(context, sCompleteStateName);
          } catch (Exception e) {
            sErrorMsg = e.getMessage();
          }
        }
      }
      session.putValue("EditWBSErrorMessage", sErrorMsg);
    }
  }
%>

<html>
  <script language="javascript" type="text/javaScript">//<![CDATA[
    <!-- hide JavaScript from non-JavaScript browsers
<% if(closeWindow) { %>
     parent.window.getWindowOpener().parent.document.location.href =parent.window.getWindowOpener().parent.document.location.href;
     parent.window.closeWindow();
<% } else { %>
     parent.window.document.location = "<%=XSSUtil.encodeForJavaScript(context,editPageLocation)%>";
<% } %>
     // Stop hiding here -->//]]>
  </script>
</html>
