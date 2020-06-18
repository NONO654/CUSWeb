<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%

Enumeration en1 = request.getParameterNames();
StringBuffer sbAppendURL = new StringBuffer();
while(en1.hasMoreElements()) {
	String reqParam = (String)en1.nextElement();
	String value = (String)request.getParameter(reqParam);
	if(!("suiteKey".equals(reqParam)) && !("prevURL".equals(reqParam))){

		if("mode".equals(reqParam))
			value="view";

		sbAppendURL.append(reqParam).append("=").append(value).append("&");
	
	}

}


String sName = (String)request.getParameter("Name");
String sQueryLimit = (String)request.getParameter("QueryLimit");
String sDesc = (String)request.getParameter("Description");
String sType = (String)request.getParameter("Type");
//For MEP Filter
String MEPName        = emxGetParameter(request, "MEPName");
String MEPType        = emxGetParameter(request, "MEPType");
String MEPDescription        = emxGetParameter(request, "MEPDescription");
String MEPStatus        = emxGetParameter(request, "MEPStatus");
String MEPState        = emxGetParameter(request, "MEPState");
String MEPManufacturer        = emxGetParameter(request, "MEPManufacturer");
String MEPPreference        = emxGetParameter(request, "MEPPreference");

String sAppendURL = sbAppendURL.toString();
String sReqParam = sAppendURL;
String sFormName = (String)request.getParameter("form");
%>

<script language="javascript" type="text/javaScript">
//XSSOK
var appendURL = "<%=sAppendURL%>";
var formName = "<xss:encodeForJavaScript><%=sFormName%></xss:encodeForJavaScript>";
var portalCommandName = "";
var frameName = findFrame(getTopWindow(), "portalDisplay") == null ? findFrame(getTopWindow(), "content") : findFrame(getTopWindow(), "portalDisplay").frames[0];
if(formName == "EngSpecificationFilter")
	frameName = findFrame(getTopWindow(), "portalDisplay").frames[1];

var documentReqMap = emxUICore.selectNodes(frameName.oXML.documentElement, "/mxRoot/requestMap/setting[@name = 'RequestValuesMap']");
var items = emxUICore.selectNodes(documentReqMap[0], "items/item");
 for ( var n = 0; n < items.length; n++) {
	var name1 = items[n].getAttribute("name");
	/* if(items[n].getAttribute("name") == "customFormName")
		formName = items[n].textContent; */
	if(items[n].getAttribute("name") == "portalCmdName")
		portalCommandName = isIE ? items[n].text : items[n].textContent; 
	appendURL = isIE? appendURL + name1+"="+items[n].text+"&":appendURL + name1+"="+items[n].textContent+"&";
} 
apentURL = appendURL+"sFromCommonComponentFilter=True";
 var contentFrame;
 if(portalCommandName != null && portalCommandName != "")
 	contentFrame = getTopWindow().findFrame(getTopWindow(), portalCommandName);
 if (contentFrame == null || contentFrame == undefined || contentFrame == "") {
 	contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
 }
 //XSSOK
 sessionStorage.setItem('sRequestParam',"<%=sReqParam%>");
 sessionStorage.setItem('sName',"<xss:encodeForJavaScript><%=sName%></xss:encodeForJavaScript>");
 sessionStorage.setItem('sQueryLimit',"<xss:encodeForJavaScript><%=sQueryLimit%></xss:encodeForJavaScript>");
 sessionStorage.setItem('sDesc',"<xss:encodeForJavaScript><%=sDesc%></xss:encodeForJavaScript>");
 sessionStorage.setItem('sType',"<xss:encodeForJavaScript><%=sType%></xss:encodeForJavaScript>");
 sessionStorage.setItem('MEPName',"<xss:encodeForJavaScript><%=MEPName%></xss:encodeForJavaScript>");
 sessionStorage.setItem('MEPType',"<xss:encodeForJavaScript><%=MEPType%></xss:encodeForJavaScript>");
 sessionStorage.setItem('MEPState',"<xss:encodeForJavaScript><%=MEPState%></xss:encodeForJavaScript>");
 sessionStorage.setItem('MEPDescription',"<xss:encodeForJavaScript><%=MEPDescription%></xss:encodeForJavaScript>");
 sessionStorage.setItem('MEPStatus',"<xss:encodeForJavaScript><%=MEPStatus%></xss:encodeForJavaScript>");
 sessionStorage.setItem('MEPManufacturer',"<xss:encodeForJavaScript><%=MEPManufacturer%></xss:encodeForJavaScript>");
 sessionStorage.setItem('MEPPreference',"<xss:encodeForJavaScript><%=MEPPreference%></xss:encodeForJavaScript>");

	contentFrame.location.href = "../common/emxIndentedTable.jsp?"+appendURL;
  </script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



