<%@ page import="java.io.*"%>
<%@ include file="../common/emxNavigatorInclude.inc"%>
<%@ page import="matrix.db.*,matrix.util.*,com.matrixone.apps.domain.util.*,com.matrixone.apps.framework.ui.*,com.matrixone.servlet.*,com.matrixone.apps.common.Person,java.util.HashMap,ds.enovia.apps.msf.sharepointRegister.*"%>

<html>

<%@include file="../common/emxUIConstantsInclude.inc"%>

<script language="JavaScript" type="text/JavaScript">
	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIToolbar");
	addStyleSheet("emxUIDOMLayout");
	addStyleSheet("emxUIAdminTools");
</script>

<%
	
	Boolean RC = false;
	String result = "";

	String appName = emxGetParameter(request, "appName");
	if (appName == null) {
		appName = "";
	}

	String spSiteUrl = emxGetParameter(request, "spURL");
	if (spSiteUrl == null) {
		spSiteUrl = "";
	}

	String clientSecret = emxGetParameter(request, "clientSecret");
	if (clientSecret == null) {
		clientSecret = "";
	}

	String clientID = emxGetParameter(request, "clientID");
	if (clientID == null) {
		clientID = "";
	}

	String deleteURL = emxGetParameter(request, "deleteUrl");
	if (deleteURL == null) {
		deleteURL = "";
	}
	
	//label translation 
	String pageHeader = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.Heading");
	String strAppName = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.SharePointAppName");
	String sharePointURL = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.SharePointURL");
	String strClientID = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.ClientID");
	String strClientSecret = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.ClientSecret");
	String registerButton = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.RegisterButton");
	String strEnabled = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.Enabled");
	String strName = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.Basic.Name");
	String strVerified = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.Verified");
	String strDefault = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.Common.Default");
	String strAdminRegistered = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.AdminRegistered");
	String strRemove = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.Button.Remove");
	String strURL = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.URL");
	
	// Check deletion
	if (!deleteURL.equals("")) {
		
		SharePointRegister.DeleteSPRegisteredAppSite(context, new String[] {"en-US", deleteURL});
		
		deleteURL = "";
	
	// Check registration
	} else if (!appName.equals("") && !spSiteUrl.equals("") && !clientSecret.equals("")
			&& !clientID.equals("")) {

		String accessUsers = "role_AdministrationManager,role_VPLMAdmin";
		boolean isAdminUser = PersonUtil.hasAnyAssignment(context,
				accessUsers);

		SPAppRegistrationEnum regEnum = SharePointRegister
				.RegisterSharePointApp(context, spSiteUrl, clientID,
						clientSecret, isAdminUser, appName);

		if (regEnum.equals(SPAppRegistrationEnum.Registered)) {

			RC = true;
			result = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.SucessResult");

		} else if (regEnum.equals(SPAppRegistrationEnum.AppSiteAlreadyRegistered)) {

			result = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.AlreadyRegisteredResult");

		} else {

			result = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.RegisterSite.ErrorResult");
		}
	}

	ArrayList<HashMap<String, String>> dataMap = SharePointRegister.GetSPRegisteredAppSitesWithTokenMap(context);

	String tableRows = "";

	for (HashMap<String, String> entry : dataMap) {

		boolean enabled = true;
		boolean verified = "true".equals("" + entry.get("isTokenDateValid"));
		boolean defaultSite = false;
		boolean adminRegistered = "true".equals("" + entry.get("isRegByAdmin"));

		tableRows += "<tr style=\"height: 24px;\">";

		tableRows += "<td style=\"padding-left: 10px;\"><input type=\"checkbox\" disabled=\"true\" " + (enabled ? "checked" : "") + " ></td>";
		tableRows += "<td style=\"white-space: nowrap;\" >" + entry.get("appName") + "</td>";	
		tableRows += "<td><input type=\"checkbox\" disabled=\"true\" " + (verified ? "checked" : "") + "></td>";
		tableRows += "<td><input type=\"checkbox\" " + (defaultSite ? "checked" : "") + "></td>";
		tableRows += "<td><input type=\"checkbox\" disabled=\"true\" " + (adminRegistered ? "checked" : "") + "></td>";
		tableRows += "<td style=\"padding-left: 10px; color: red; cursor: pointer;\" onclick=\"deleteEntry(this);\">X</td>";
		tableRows += "<td class=\"urlId\" >" + entry.get("name") + "</td>";	

		tableRows += "</tr>";
	}

%>

<style>

th {
	color: #808080;
	font-weight: bold;
	border-bottom: thin solid rgb(180, 182, 186);
	border-top: thin solid rgb(180, 182, 186);
	height: 24px;
	background-clip: border-box;
	background-image: linear-gradient(rgb(245, 246, 247) 0%, rgb(226, 228, 227) 100%);
	margin-bottom: 10px;
		}

</style>

<body onload="turnOffProgress();" class="no-footer">

	<form name="SPRegistration" method="post"
		action="emxSharePointRegistration.jsp"
		onsubmit="validate(); return false">
		<div id="pageHeadDiv">
			<%
				String progressImage = "images/utilProgressBlue.gif";
				String languageStr = request.getHeader("Accept-Language");
				String processingText = UINavigatorUtil.getProcessingText(context,
						languageStr);
			%>
			<table>
				<tr>
					<td class="page-title">
						<h2><%=XSSUtil.encodeForHTML(context,pageHeader)%></h2>
					</td>
					<td class="functions">
						<table>
							<tr>
								<td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
							</tr>
						</table>
					</td>
				</tr>
			</table>

		</div>
		<div id="divPageBody" style="margin-left: 4px;" >
			<table width="100%" cellspacing="2" cellpadding="5">
				<tr>
					<td nowrap="nowrap" class="cellLabel"><br /><%=XSSUtil.encodeForHTML(context,strAppName)%></td>
				</tr>
				<tr>
				<td nowrap="nowrap" class="inputField"><input name="appName"
						value='<xss:encodeForHTMLAttribute><%=appName%></xss:encodeForHTMLAttribute>'
						type="text" style="width: 98.4%;"
						onkeypress="javascript:submitFunction(event)" size="48" /></td>
				</tr>
				<tr>
					<td nowrap="nowrap" class="cellLabel"><br /><%=XSSUtil.encodeForHTML(context,sharePointURL)%></td>
				</tr>
				<tr>
					<td nowrap="nowrap" class="inputField"><input name="spURL"
						value='<xss:encodeForHTMLAttribute><%=spSiteUrl%></xss:encodeForHTMLAttribute>'
						type="text" style="width: 98.4%;"
						onkeypress="javascript:submitFunction(event)" size="48" /></td>
				</tr>
				<tr>
					<td nowrap="nowrap" class="cellLabel"><br /><%=XSSUtil.encodeForHTML(context,strClientID)%></td>
				</tr>
				<tr>
					<td nowrap="nowrap" class="inputField"><input name="clientID"
						value='<xss:encodeForHTMLAttribute><%=clientID%></xss:encodeForHTMLAttribute>'
						type="text" style="width: 98.4%;"
						onkeypress="javascript:submitFunction(event)" size="48" /></td>
				</tr>
				<tr>
					<td nowrap="nowrap" class="cellLabel"><br /><%=XSSUtil.encodeForHTML(context,strClientSecret)%></td>
				</tr>
				<tr>
					<td nowrap="nowrap" class="inputField"><input
						name="clientSecret"
						value='<xss:encodeForHTMLAttribute><%=clientSecret%></xss:encodeForHTMLAttribute>'
						type="text" style="width: 98.4%;"
						onkeypress="javascript:submitFunction(event)" size="48" /></td>
				</tr>
				<tr>
					<td width="75" align="left"><br />
					<button type="button" onclick="registerSite();"><%=XSSUtil.encodeForHTML(context,registerButton)%></button>
				</tr>

			</table>


			<table id="urlTable" style="width: 99.8%; margin-top: 20px;">
				<tbody>
					<tr> 
						<th style="padding-right: 30px; padding-left: 10px;"><%=XSSUtil.encodeForHTML(context,strEnabled)%></th>
						<th style="padding-right: 30px;"><%=XSSUtil.encodeForHTML(context,strName)%></th>
						<th style="padding-right: 30px;"><%=XSSUtil.encodeForHTML(context,strVerified)%></th>
						<th style="padding-right: 30px;"><%=XSSUtil.encodeForHTML(context,strDefault)%></th>
						<th style="padding-right: 30px; white-space: nowrap;"><%=XSSUtil.encodeForHTML(context,strAdminRegistered)%></th>
						<th style="padding-right: 10px;"><%=XSSUtil.encodeForHTML(context,strRemove)%></th>
						<th><%=XSSUtil.encodeForHTML(context,strURL)%></th>
					</tr>
					<%= tableRows %>
				</tbody>
			</table>
			<input 
				name="deleteUrl" 
				id="deleteUrlId" 
				value='<xss:encodeForHTMLAttribute><%=deleteURL%></xss:encodeForHTMLAttribute>'
				type="text"
				style="display:none;"
			/>

		</div>
		
	</form>

	<script language="JavaScript">
	
		var clicked = false;
	
		checkCompleted();
		
		function registerSite() {
		
			document.SPRegistration.appName.value = trim(document.SPRegistration.appName.value);
			document.SPRegistration.spURL.value = trim(document.SPRegistration.spURL.value);
			document.SPRegistration.clientSecret.value = trim(document.SPRegistration.clientSecret.value);
			document.SPRegistration.clientID.value = trim(document.SPRegistration.clientID.value);

			if (document.SPRegistration.appName.value == "") {

				alert('Enter value for App name');

			} else if (document.SPRegistration.spURL.value == "") {

				alert('Enter valid URL for Site');

			} else if (document.SPRegistration.clientSecret.value == "") {

				alert('Enter value for Client Secret');

			} else if (document.SPRegistration.clientID.value == "") {

				alert('Enter value for Client ID');
			
			} else {
			
				document.SPRegistration.submit();
			
			}
	
		}

		// Check completion and notify
		function checkCompleted() {
			
			var Msg = '<%=result%>';
			if ("" != Msg) {
				
				alert(Msg);
				
				if (<%=RC%>) {
					
					var win = window.open(document.SPRegistration.spURL.value, '_blank');
				    win.focus();
				    
				}
				
			}
			
		}
	
		// This Function Checks For The Length Of The Data That Has
		// Been Entered And Trims the Extra Spaces In The Front And Back.
		function trim(varTextBox) {
			while (varTextBox.charAt(varTextBox.length - 1) == ' '
					|| varTextBox.charAt(varTextBox.length - 1) == "\r"
					|| varTextBox.charAt(varTextBox.length - 1) == "\n")
				varTextBox = varTextBox.substring(0, varTextBox.length - 1);
			while (varTextBox.charAt(0) == ' ' || varTextBox.charAt(0) == "\r"
					|| varTextBox.charAt(0) == "\n")
				varTextBox = varTextBox.substring(1, varTextBox.length);
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
			if (!clicked) {
				clicked = true;
				return true;
			} else {
				return false;
			}
		}
	
		//Trims the filter criteria and submits the form
		function validate() {
	
			parent.window.focus();
			document.SPRegistration.clientSecret.focus();
			if (jsClickCheck()) {
				registerSite()
			}
		}
		
		function deleteEntry(item) {
			
			var url = $(item).parent().children(".urlId").html();
			
			if (confirm("Confirm deletion of:\n" + url)) {
				
				$("#deleteUrlId").attr("value", url);
				
				document.SPRegistration.submit();
				
			}
			
		}
		
	
	</script>

</body>

</html>
