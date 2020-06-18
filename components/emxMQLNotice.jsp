<%-- emxMQLNotice.jsp - included code to construct a JavaScript alert for MQL trigger Notices

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   code to promote given object set in request within main page

   static const char RCSID[] = "$Id: emxMQLNotice.jsp.rca 1.6 Wed Oct 22 16:17:48 2008 przemek Experimental przemek $"
--%>

<%@ page import = "matrix.db.*, matrix.util.* ,com.matrixone.servlet.* , java.util.* " %>
<%@ include file  ="../emxContentTypeInclude.inc" %>

<script language="Javascript" >
<%
  matrix.db.Context context = Framework.getFrameContext(session);

  //
  // Declare the message variables and message vector
  //
  Vector msgVector = new Vector();
  Vector reasonVector = new Vector();

  msgVector.clear();
  reasonVector.clear();
  ClientTaskList listNotices = null ;

  for (int i=0; i < 2 ; i++)
  {
    listNotices = context.getClientTasks();
  }

  ClientTaskItr itrNotices = new ClientTaskItr(listNotices);

  String sTaskData = "";
  int iReason = -1;
  while (itrNotices.next()) {
    ClientTask clientTaskMessage =  itrNotices.obj();
    sTaskData = (String) clientTaskMessage.getTaskData();
    if(sTaskData.contains("Warning #1501905")){
    	continue;
    }
    iReason = clientTaskMessage.getReason();
    if(sTaskData != null && sTaskData.length()>0) {
      msgVector.addElement(sTaskData);
      reasonVector.addElement(new Integer(iReason));
    }
  }

  context.clearClientTasks();

  //
  // Get the messages from the vector and prepare them to be displayed in JavaScript alert
  //
  for (int m = 0; m < msgVector.size(); m++) {
    String sMessage = (String) msgVector.elementAt(m);
    Integer IntReason2 = (Integer) reasonVector.elementAt(m);
    iReason = IntReason2.intValue();
    Vector vStringBuffers = new Vector();

    if (sMessage != null && sMessage.length() > 0) {
      StringBuffer sbMsg = new StringBuffer();

      for (int i = 0; i < sMessage.length(); i++) {
        char ch = sMessage.charAt(i);
        int unicode = Character.getNumericValue(ch);
        Character CH = new Character(ch);
        int hashCode = CH.hashCode();

        if (hashCode != 10 && i < sMessage.length()-1) {  // hashcode: 10 -check for carriage return
          sbMsg  = sbMsg.append(ch);
        } else {
          vStringBuffers.addElement(sbMsg);
          sbMsg = new StringBuffer("");
        }
      }
    }

    //
    // Display the message before going to the next message element.
    // Display the heading based on the reason. And set the heading text message based on the Reason.
    //

    String sExternalTask = "External Program";            // ExternalTask = 0
    String sMQLTCLTask = "MQL Tcl";                       // MQLTCLTask = 1
    String sApplTask = "Application Script";              // ApplTask = 2
    String sNoticeTask = "Notice";                        // NoticeTask = 3
    String sWarningTask = "Warning";                      // WarningTask = 4
    String sErrorTask = "Error";                          // ErrorTask = 5
    String sOpenViewTask = "Open View";                   // OpenViewTask = 6
    String sOpenEditTask = "Open Edit";                   // OpenEditTask = 7
    String sCheckinTask = "Checkin";                      // CheckinTask = 8
    String sCheckoutTask = "Checkout";                    // CheckoutTask = 9
    String sUpdateClientTask = "Update Client";           // UpdateClientTask = 10
    String sPopContextTask = "Pop Context";               // PopContextTask = 11
    String sPushContextTask = "Push Context";             // PushContextTask = 12
    String sNoTask = null;                                // NoTask = 13

    String sHeaderText = null;
    switch (iReason) {
      case 0 : sHeaderText = sExternalTask; break;
      case 1 : sHeaderText = sMQLTCLTask; break;
      case 2 : sHeaderText = sApplTask; break;
      case 3 : sHeaderText = sNoticeTask; break;
      case 4 : sHeaderText = sWarningTask; break;
      case 5 : sHeaderText = sErrorTask; break;
      case 6 : sHeaderText = sOpenViewTask; break;
      case 7 : sHeaderText = sOpenEditTask; break;
      case 8 : sHeaderText = sCheckinTask; break;
      case 9 : sHeaderText = sCheckoutTask; break;
      case 10 : sHeaderText = sUpdateClientTask; break;
      case 11 : sHeaderText = sPopContextTask; break;
      case 12 : sHeaderText = sPushContextTask; break;
      case 13 : sHeaderText = sNoTask; break;
      default : sHeaderText = null;
    }

    // Display only if the reason is Notice, Warning or Error
    if (iReason == 3 || iReason == 4 || iReason == 5) {
%>
      var msg = '';
<%
      if (sHeaderText != null && sHeaderText.length() > 0 && vStringBuffers.size() > 0) {
%>
		//XSSOK
        msg += '<%=sHeaderText%>' + ':\n\n';
<%
      }
      String sMsg = null;
      for (int i=0; i < vStringBuffers.size(); i++) {
        StringBuffer sbAlertMsg = (StringBuffer) vStringBuffers.elementAt(i);
        sMsg = sbAlertMsg.toString();
        sMsg = sMsg.replace('\'','\"');  // replace the ' chr with " only.
%>
        //XSSOK
        msg += '<%=sMsg%>' + '\n';
<%
      }
%>
      alert(msg);
<%
    }
  }
%>
</script>
