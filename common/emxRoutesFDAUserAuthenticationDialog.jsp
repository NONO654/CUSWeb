<%--  
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
--%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@ page import = "java.util.Map" %>
<%@ page import = "java.util.List" %>
<%@ page import = "com.matrixone.apps.domain.util.PropertyUtil" %>
<%@ page import = "com.matrixone.apps.domain.util.FrameworkUtil" %>
<%@  include file = "../emxUICommonAppInclude.inc"%>
<%@  include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@  include file = "../emxTagLibInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<script language="JavaScript" src="./scripts/emxUICore.js"></script>
<%
  String pageAction = emxGetParameter(request,"pageAction");
  List<String> slPageAction = FrameworkUtil.split(pageAction, "?");
  List<String> slURLParameters = FrameworkUtil.split(slPageAction.get(1).toString(),"&");
  String strRouteTaskUser = "";
  for(String strParameter : slURLParameters)
  {
	  String sParam = FrameworkUtil.split(strParameter, "=").get(0).toString();
	  if(sParam.equals("routeTaskUser"))
	  {
		  strRouteTaskUser = FrameworkUtil.split(strParameter, "=").get(1).toString();
		  strRouteTaskUser = PropertyUtil.getSchemaProperty(context, strRouteTaskUser);
	  }
  }
  String showUserName = emxGetParameter(request, "showUserName");
  if(showUserName == null || showUserName.trim().equals("")) {
      showUserName = EnoviaResourceBundle.getProperty(context, "emxFramework.Routes.ShowUserNameForFDA");
  }
  
  
  String strLanguage = request.getHeader("Accept-Language");
  
  String i18NUserName=com.matrixone.apps.framework.ui.UINavigatorUtil.getI18nString("emxFramework.Login.Username", "emxFrameworkStringResource", strLanguage);
  String i18NPassword=com.matrixone.apps.framework.ui.UINavigatorUtil.getI18nString("emxFramework.Login.Password", "emxFrameworkStringResource", strLanguage);
  String i18NDone=com.matrixone.apps.framework.ui.UINavigatorUtil.getI18nString("emxFramework.FormComponent.Done", "emxFrameworkStringResource", strLanguage);
  String i18NCancel=com.matrixone.apps.framework.ui.UINavigatorUtil.getI18nString("emxFramework.FormComponent.Cancel", "emxFrameworkStringResource", strLanguage);
  String i18NHeader = com.matrixone.apps.framework.ui.UINavigatorUtil.getI18nString("emxFramework.UserAuthentication.VerifyUser", "emxFrameworkStringResource", strLanguage);
  String i18NReadAndUnderstand = com.matrixone.apps.framework.ui.UINavigatorUtil.getI18nString("emxFramework.UserAuthentication.ReadAndUnderstand", "emxFrameworkStringResource", strLanguage);
  String i18NAlertMessage = com.matrixone.apps.framework.ui.UINavigatorUtil.getI18nString("emxFramework.UserAuthentication.CheckboxAlertMessage", "emxFrameworkStringResource", strLanguage);
  String isResponsibleRoleEnabled = DomainConstants.EMPTY_STRING;
  try
  {
  isResponsibleRoleEnabled = EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.ResponsibleRoleForSignatureMeaning.Preserve");
  if(UIUtil.isNotNullAndNotEmpty(isResponsibleRoleEnabled) && isResponsibleRoleEnabled.equalsIgnoreCase("true") && UIUtil.isNotNullAndNotEmpty(strRouteTaskUser))
  {
	  i18NReadAndUnderstand = MessageUtil.getMessage(context, null, "emxFramework.UserAuthentication.ReadAndUnderstandRole", new String[] {
			  strRouteTaskUser}, null, context.getLocale(),
			  "emxFrameworkStringResource");
  }
  }
  catch(Exception e){
	  isResponsibleRoleEnabled = "false";
  }


  String processingText = com.matrixone.apps.framework.ui.UINavigatorUtil.getProcessingText(context, strLanguage);
  
  
%>

<script language="JavaScript">
  //XSSOK
  var showUserName = <%="true".equalsIgnoreCase(showUserName)%>;	
 
 function validateUserCredentials() 
 {
	var readUnderstoodField = document.getElementById('calc_ReadAndUnderstand');
	var child = readUnderstoodField.children[0].children[0].checked;
	if(child == false)
	  {
		var alertMsg = "<%=i18NAlertMessage%>";
	   alert(alertMsg);
	   return;
	}
	var imgProgressDiv = document.getElementById("imgProgressDiv");
	imgProgressDiv.style.visibility = 'visible';
 	var userName = document.getElementById("userName");
 	var passWord = document.getElementById("passWord");
	var userNameVal = "";
     var passWordVal = btoa(encodeURIComponent(passWord.value).replace(/%([0-9A-F]{2})/g,
	function toSolidBytes(match, p1) {
  return String.fromCharCode('0x' + p1);}));
 	if(showUserName) {
                   userNameVal = btoa(encodeURIComponent(userName.value).replace(/%([0-9A-F]{2})/g,
function toSolidBytes(match, p1) {
  return String.fromCharCode('0x' + p1);
                   }));
 	}
	var url = "emxRoutesFDAValidateUserProcess.jsp";
	var postData = "userName=" + userNameVal + "&passWord=" + passWordVal + "&showUserName=" + showUserName;
	var xmlResult = emxUICore.getXMLDataPost(url, postData);

    try{
        var root = xmlResult.documentElement;
		var resultNodeVal = emxUICore.getText(emxUICore.selectSingleNode(root, "/mxFDAAuth/result"));
		var messageNodeVal = emxUICore.getText(emxUICore.selectSingleNode(root, "/mxFDAAuth/errorMsg"));
		if(resultNodeVal == "success") {
			var verifyForm = document.getElementById("verifyForm");
			var pageAction = encodeURI(document.getElementById("pageAction").value);
			verifyForm.action = pageAction;
			window.resizeTo(800, 600);
			verifyForm.submit();	        
		} else if(resultNodeVal == "fail") {
			imgProgressDiv.style.visibility = 'hidden';
			alert(messageNodeVal);
			if(showUserName) {
				userName.value="";
				userName.focus();
			} else {
				passWord.focus();
			}
			passWord.value="";
		} else if(resultNodeVal == "block") {
			imgProgressDiv.style.visibility = 'hidden';
			alert(messageNodeVal);
			getTopWindow().closeWindow();
		} else {
			imgProgressDiv.style.visibility = 'hidden';
			alert(emxUIConstants.STR_JS_InvalidResult);
			getTopWindow().closeWindow();
		}
    }catch(e){
    	alert(emxUIConstants.STR_JS_AnExceptionOccurred + " " + emxUIConstants.STR_JS_ErrorName + " " + e.name
				+ emxUIConstants.STR_JS_ErrorDescription + " " + e.description
				+ emxUIConstants.STR_JS_ErrorNumber + " " + e.number
				+ emxUIConstants.STR_JS_ErrorMessage + " " + e.message)           	
    }    
 }
</script>

<%@ include file = "../emxUICommonHeaderEndInclude.inc" %>

  <form name="verifyForm" id="verifyForm" method="post">
  <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
  <input type="hidden" id="pageAction" name="pageAction" value="<xss:encodeForHTMLAttribute><%=pageAction%></xss:encodeForHTMLAttribute>" />
  
  <div id="divPageHead" >
  	<table border="0" width="100%" cellspacing="0" cellpadding="0">  
		<tr>
			<td width="100%" wrap><span class="pageHeader">&nbsp;<%=i18NHeader%></span></td> 
			<td nowrap><div id="imgProgressDiv">&nbsp;<img src="images/utilProgressBlue.gif" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div></td>			
		</tr>	
  	</table>	
  </div>
  <br/>  <br/>
  <div id="divPageBody">	
	  <table width="100%" border="0" cellpadding="3" cellspacing="2">
<%
		  if("true".equalsIgnoreCase(showUserName))
		  {
%>
		    <tr class='odd'>
		      <!-- //XSSOK -->
		      <td class="labelRequired"><%=i18NUserName%></td>
		      <td class="field"><input id=userName type="text" name=userName /></td>
		    </tr>
<%
  		  }
%>
		  <tr class='even'>
		      <!-- //XSSOK -->
		      <td class="labelRequired"><%=i18NPassword%></td>
		      <td class="field"><input id="passWord" type="password" name="passWord" /></td>
		  </tr>
		  <tr class='odd' id="calc_ReadAndUnderstand" >
		      <!-- //XSSOK -->
		      <td class="field" colspan="2"><input id="readAndUnderstood" type="checkbox" name="readAndUnderstood" />&nbsp;&nbsp;<%=i18NReadAndUnderstand%></td>
		  </tr>
	  </table>
   </div>
   <br/>  <br/> <br/> <br/>
  <div id="divPageFoot">
  	<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
    	<tr>
        	<td align="right">
		    	<table border="0" cellspacing="0">
        			<tr>
                    	<!-- //XSSOK -->
                    	<td><a href="javascript:;" onclick="validateUserCredentials();return false"><img src="images/buttonDialogDone.gif" border="0" alt="<%=i18NDone%>" /></a></td>
                    	<!-- //XSSOK -->
                    	<td><a href="javascript:;" onclick="validateUserCredentials();return false" class="button"><%=i18NDone%></a></td>
			            <td>&nbsp;&nbsp;</td>
          				<!-- //XSSOK -->
          				<td><div id="cancelImage"><a href="javascript:getTopWindow().closeWindow()"><img src="images/buttonDialogCancel.gif" border="0" alt="<%=i18NCancel%>" /></a></div></td>
			            <!-- //XSSOK -->
						<td><div id="cancelText"><a onClick="javascript:getTopWindow().closeWindow()" class="button"><%=i18NCancel%></a></div></td>
          			 </tr>
		          </table>
        	  </td>
          </tr>
     </table>
    </div>
<script language="javascript">
var imgProgressDiv = document.getElementById("imgProgressDiv");
imgProgressDiv.style.visibility = 'hidden';
</script>   	  
  </form>
<%@include file = "../emxUICommonEndOfPageInclude.inc" %>

