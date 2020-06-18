<%--  emxRunMQL.jsp   -  This page handles MQL commands

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRunMQL.jsp.rca 1.10 Wed Oct 22 15:48:23 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@page import  ="com.matrixone.apps.domain.util.MqlUtil"%>
<html>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%
String accessUsers = "role_AdministrationManager,role_VPLMAdmin";
if( !PersonUtil.hasAnyAssignment(context, accessUsers) ) {
    return;
}


String sResource ="emxFrameworkStringResource";
String setContextMessage=UINavigatorUtil.getI18nString("emxFramework.MyDesk.ContextMsg", sResource , request.getHeader("Accept-Language"));
%>
<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>

  <script language="JavaScript" type="text/JavaScript">
addStyleSheet("emxUIDefault");
addStyleSheet("emxUIToolbar");
addStyleSheet("emxUIDOMLayout");
addStyleSheet("emxUIAdminTools");
</script>
<script language="javascript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>

<script language="JavaScript">
    var clicked = false;

  // This Function Checks For The Length Of The Data That Has
  // Been Entered And Trims the Extra Spaces In The Front And Back.
  function trim(varTextBox) {
    while (varTextBox.charAt(varTextBox.length-1) == ' ' || varTextBox.charAt(varTextBox.length-1) == "\r" || varTextBox.charAt(varTextBox.length-1) == "\n" )
        varTextBox = varTextBox.substring(0,varTextBox.length - 1);
    while (varTextBox.charAt(0) == ' ' || varTextBox.charAt(0) == "\r" || varTextBox.charAt(0) == "\n")
        varTextBox = varTextBox.substring(1,varTextBox.length);
    return varTextBox;
  }


  // check if EnterKey is pressed
  function submitFunction(e) {
    if (!isIE)
        Key = e.which;
    else
        Key = window.event.keyCode;

    if (Key == 13)
        validate();
    else
       return;
  }

function jsClickCheck() {
    if(!clicked) {
        clicked = true;
        return true;
    }
    else {
        return false;
    }
}

  //Trims the filter criteria and submits the form
  function validate() {
  var strCommand = document.MQLCommand.mqlCommand.value;
  var regExp = /set[\s]+cont/;
  if(strCommand==null) strCommand="";
     strCommand=strCommand.toLowerCase();
    if(regExp.test(strCommand)){
      document.MQLCommand.mqlCommand.value="";
      //XSSOK
      alert("<%=setContextMessage%>");
      return;
    }
      document.MQLCommand.mqlCommand.value = trim(document.MQLCommand.mqlCommand.value);
      document.MQLCommand.mqlResult.value = "";
      parent.window.focus();
      document.MQLCommand.mqlCommand.focus();
      if(jsClickCheck()){
          document.MQLCommand.submit();
      }
  }

</script>

<%
  String result = "";
  String command = emxGetParameter(request,"mqlCommand");
  if (command == null) {
      command = "";
  }

  if ( !command.equals("") ) {
      try {
    	  StringList cmdList = com.matrixone.apps.domain.util.StringUtil.split(command, ";");
		  boolean validCommand = true;
    	  for(int i=0; i< cmdList.size(); i++)
    	  {
    		  String singleCommand = (String)cmdList.get(i);
	          StringList cmdElementsList = com.matrixone.apps.domain.util.StringUtil.split(singleCommand, " ");
			  if( cmdElementsList.size() >= 2)
			  {
				  String firstToken = (String)cmdElementsList.get(0);
				  String secondToken = (String)cmdElementsList.get(1);
			      if(firstToken.startsWith("exe"))
			      {
				      validCommand = false;
			      }
			      if(firstToken.startsWith("pri") && secondToken.contains("prog"))
			      {
				      validCommand = false;
			      }	
			      if(firstToken.startsWith("lis") && secondToken.contains("prog"))
			      {
			  	      validCommand = false;
			      }
		      }
    	  }
		  if( validCommand )
		  {
          result = MqlUtil.mqlCommand(context,command,false);
      }
    	  

      }
      catch (FrameworkException e) {
          result = e.toString();
      }
  }

  boolean isPrinterFriendly = false;
  String printerFriendly = emxGetParameter(request, "PrinterFriendly");

  if (printerFriendly != null && "true".equals(printerFriendly)) {
        isPrinterFriendly = true;
   }

  String runCmd = UINavigatorUtil.getI18nString("emxFramework.AdminTool.Run",
                                        "emxFrameworkStringResource",
                                        request.getHeader("Accept-Language"));
  String sHelpMarker="emxhelpadminrunmql";
  String suiteDir="common";
%>
<body onload="turnOffProgress();" class="no-footer">
<form name="MQLCommand" method="post" action="emxRunMQL.jsp" onsubmit="validate(); return false">
<div id="pageHeadDiv" >
<%
String progressImage = "images/utilProgressBlue.gif";
String languageStr = request.getHeader("Accept-Language");
String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
%>
      <table>
       <tr>
      <td class="page-title">
        <h2><emxUtil:i18n localize="i18nId">emxFramework.AdminTool.MQLCommandPage</emxUtil:i18n></h2>
      </td>
	    <td class="functions">
	        <table>
	            <tr>
	                <!-- //XSSOK -->
	                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
				</tr>
			</table>
		</td>
	</tr>
	</table>
	<!-- //XSSOK -->
  <jsp:include page = "emxToolbar.jsp" flush="true"> <jsp:param name="export" value="false"/> <jsp:param name="helpMarker" value="<%=sHelpMarker%>"/> <jsp:param name="PrinterFriendly" value="false"/>
  </jsp:include>
</div>
<div id="divPageBody">
  <table width="100%" cellspacing="2" cellpadding="5">
<tr>
   <td nowrap="nowrap" class="cellLabel"> <emxUtil:i18n localize="i18nId">emxFramework.AdminTool.MQLCmd</emxUtil:i18n></td>
</tr>
<tr>
<%
if (!isPrinterFriendly) {
%>
<td nowrap="nowrap" class="inputField"><input name="mqlCommand" value='<xss:encodeForHTMLAttribute><%=command%></xss:encodeForHTMLAttribute>' type="text" class="RunMQLTextInput" onkeypress="javascript:submitFunction(event)" size="48"/></td>
<!-- //XSSOK -->
<td width="75" align="center"><input type="submit" name="Submit" value="<%=runCmd%>"/></td>
<%
}
else {
%>
      <td><xss:encodeForHTML><%=command%></xss:encodeForHTML></td>
<%
}
%>
</tr>
</table>
<br/>
<table width="100%" height="100%" border="0" cellpadding="5" cellspacing="2">
<tr>
   <td colspan="2" height="15" nowrap="nowrap" class="cellLabel"> <emxUtil:i18n localize="i18nId">emxFramework.AdminTool.MQLCommandResults</emxUtil:i18n></td>
</tr>
<tr>
<%
String Encode=UINavigatorUtil.htmlEncode(result);
  if (!isPrinterFriendly) {

%>
  <!-- //XSSOK -->
  <td colspan="2" valign="top" class="inputFieldFixedFont"><textarea name="mqlResult" cols="48" rows="23" wrap="OFF" class="RunMQLTextArea" id="results"><%=Encode%></textarea>
    </td>
<%
  }
  else
  {
%>
  <!-- //XSSOK -->
  <td colspan="2" valign="top"><textarea name=mqlResult cols="48" rows="23"><%=Encode%></textarea>
    </td>
<%
  }
%>

  </tr>
</table>
<script>
	<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
</script>
</div>
</form>
</body>
</html>
