<%--  emxComponentsUserAuthenticationDialog.jsp  -

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxComponentsUserAuthenticationDialog.jsp.rca 1.11 Wed Oct 22 16:18:46 2008 przemek Experimental przemek $"
--%>

<%@  include file = "../emxUICommonAppInclude.inc"%>
<%@  include file = "emxComponentsUtil.inc" %>
<%@  include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%
String strLanguage = request.getHeader("Accept-Language");
String i18NAlertMessage = com.matrixone.apps.framework.ui.UINavigatorUtil.getI18nString("emxFramework.UserAuthentication.CheckboxAlertMessage", "emxFrameworkStringResource", strLanguage);
String i18NReadAndUnderstand = com.matrixone.apps.framework.ui.UINavigatorUtil.getI18nString("emxFramework.UserAuthentication.ReadAndUnderstand", "emxFrameworkStringResource", strLanguage);
// Added for 359515
String comments = emxGetParameter(request,"Comments");
if(comments != null && !"".equals(comments))
{    
	String strCharSet = Framework.getCharacterEncoding(request);
	comments = FrameworkUtil.encodeURL(comments,strCharSet);
}
// Ended
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String fromPage = emxGetParameter(request,"fromPage");
   String keyValue=emxGetParameter(request,"keyValue");
  if(fromPage == null)
          fromPage="";
%>

<script language="JavaScript">

 function submitFn()
  {
	 var readUnderstoodField = document.getElementById('calc_ReadAndUnderstand');
	 var child = readUnderstoodField.children[0].children[0].checked;
	 if(child == false)
  	  {
		var alertMsg = "<%=i18NAlertMessage%>";
    	alert(alertMsg);
    	return;
  	}
    document.verifyForm.submit();
  }

  function windowClose(){
    getTopWindow().closeWindow();
  }
</script>

<%@ include file = "../emxUICommonHeaderEndInclude.inc" %>
<%
	//Read the property file to hide/display the username
  String showUserName = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.ShowUserNameForFDA");  
%>

  <form name="verifyForm" method="post" action="emxComponentsValidateUserProcess.jsp">
  <input type="hidden" name="taskId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"taskId")%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"routeId")%></xss:encodeForHTMLAttribute> "/>
  <input type="hidden" name="approvalStatus" value="<xss:encodeForHTMLAttribute><%=emxGetParameter(request,"approvalStatus")%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="Comments" value="<xss:encodeForHTMLAttribute><%=comments%></xss:encodeForHTMLAttribute>" />  
  <input type="hidden" name="showUserName" value="<xss:encodeForHTMLAttribute><%=showUserName%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="fromPage" value="<xss:encodeForHTMLAttribute><%=fromPage%></xss:encodeForHTMLAttribute>" />
  <input type="hidden" name="keyValue" value="<xss:encodeForHTMLAttribute><%=keyValue%></xss:encodeForHTMLAttribute>" />


  <table width="100%" border="0" cellpadding="3" cellspacing="2">
  <!-- Table Column Headers -->
<%
  if("true".equalsIgnoreCase(showUserName))
  {
%>
    <tr class='odd'>
      <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.Login.Username</emxUtil:i18n></td>
      <td class="field"><input type="text" name="userName" /></td>
    </tr>
<%
  }
%>
    <tr class='even'>
      <td class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.Login.Password</emxUtil:i18n></td>
      <td class="field"><input type="password" name="passWord" /></td>
    </tr>
    
   	<tr class='odd' id="calc_ReadAndUnderstand" >
	  <td class="field" colspan="2"><input id="readAndUnderstood" type="checkbox" name="readAndUnderstood" />&nbsp;&nbsp;<%=i18NReadAndUnderstand%></td>
    </tr>  
  </table>
  </form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
