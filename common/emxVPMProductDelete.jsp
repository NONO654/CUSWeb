<%--  emxTest.jsp   -   FS page for Create CAD Drawing dialog
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTestDelete.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $
--%>

<SCRIPT language="Javascript">
<!--

function logon(id) {
	var valUsr = parent.frames[1].document.forms['form1'].elements['usr'].value;
	var valPwd = parent.frames[1].document.forms['form1'].elements['pwd'].value;
	var valRole = parent.frames[1].document.forms['form1'].elements['role'].value;
	document.location.href="emxTestDelete.jsp?objectId=" + id + "&usr=" + valUsr + "&pwd=" + valPwd + "&role=" + valRole;
}

// -->
</SCRIPT>

<%@ page import = "java.util.Set" %>
<%@ page import = "java.net.URLEncoder" %>
<%@include file="../emxUIFramesetUtil.inc"%>

<%
  framesetObject fs = new framesetObject();

  String initSource = emxGetParameter(request,"initSource");
  if (initSource == null){
    initSource = "";
  }

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String objectId = emxGetParameter(request,"objectId");


  String sNewRev = emxGetParameter(request,"RevMode");

  String sType = PropertyUtil.getSchemaProperty(context,"type_CADDrawing");
  // Specify URL to come in middle of frameset
  String contentURL = "emxTest2.jsp";

  // add these parameters to each content URL, and any others the App needs
  String args = "?suiteKey=" + suiteKey + "&initSource=" + initSource + "&jsTreeID=" + jsTreeID +"&CreateType=" + sType + "&ShortCut=Create";
  args += "&RevMode=" + sNewRev + "&objectId=" + objectId;
  contentURL += args;

  //contentURL = Framework.encodeURL(response, contentURL);

  // Marker to pass into Help Pages
  // icon launches new window with help frameset inside
  String HelpMarker = "";

  StringBuffer validateURL = new StringBuffer();
  
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	String usr = (String) requestMap.get("usr");
	String pwd = (String) requestMap.get("pwd");
	String role = (String) requestMap.get("role");
	String del = (String) requestMap.get("delete");
	if (del != null)
		contentURL += "&usr=" + usr + "&pwd=" + pwd + "&role=" + role + "&delete=" + del;
	else if (usr != null && pwd != null && role != null) {
		contentURL += "&usr=" + usr + "&pwd=" + pwd + "&role=" + role;
	}
	
	validateURL.append("emxTestDelete.jsp").append(args).append("&usr=" + usr + "&pwd=" + pwd + "&role=" + role + "&delete=yes");
	
  fs.setPageTitle("ENOVIA - Web Core Modeler UI");

  fs.setStringResourceFile("emxEngineeringCentralStringResource");

  fs.initFrameset("Log on VPLM",	//pageHeading
                  HelpMarker,				//helpMarker
                  contentURL.toString(),	//contentURL
                  false,					//UsePrinterFriendly
                  true,						//IsDialogPage
                  false,					//ShowPagination
                  false);					//ShowConversion

	String encodedURL = URLEncoder.encode(validateURL.toString());

if (usr == null || pwd == null || role == null) {

  fs.createFooterLink("emxEngineeringCentral.Button.Next",
                      "parent.logon('" + objectId + "')",
                      "role_GlobalUser",
                      false,
                      true,
                      "emxUIButtonNext.gif",
                      0);

  fs.createFooterLink("emxFramework.Command.Cancel",
                      "parent.window.close()",
                      "role_GlobalUser",
                      false,
                      true,
                      "emxUIButtonCancel.gif",
                      0);

} else if (del == null) {

  fs.createFooterLink("emxFramework.Command.Delete",
                      encodedURL,
                      "role_GlobalUser",
                      false,
                      false,
                      "emxUIButtonNext.gif",
                      0);

  fs.createFooterLink("emxFramework.Command.Cancel",
                      "parent.window.close()",
                      "role_GlobalUser",
                      false,
                      true,
                      "emxUIButtonCancel.gif",
                      0);
                      
} else {

  fs.createFooterLink("emxFramework.Command.Done",
                      "parent.window.close()",
                      "role_GlobalUser",
                      false,
                      true,
                      "emxUIButtonDone.gif",
                      0);

}

  // ----------------- Do Not Edit Below ------------------------------

  fs.writePage(out);
  
%>





