<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%

Enumeration en1 = request.getParameterNames();
while(en1.hasMoreElements()) {
	String reqParam = (String)en1.nextElement();
	String value = (String)request.getParameter(reqParam);
	
}

String sOpenFrame = (String)request.getParameter("openerFrame");
String portalCommand = (String)request.getParameter("portalCmdName");
//My ENG View Change
String formName = (String)request.getParameter("formName");
String searchType = (String)request.getParameter("searchType");
String searchView = (String)request.getParameter("searchView");
%>	

<script language="Javascript">
var formName = "";
var portalCommandName = "";
var vFrame = "null" != "<xss:encodeForJavaScript><%=portalCommand%></xss:encodeForJavaScript>" ? "<xss:encodeForJavaScript><%=portalCommand%></xss:encodeForJavaScript>" :  "BOMDashboard";


var  frameName = findFrame(getTopWindow(), vFrame);
if(frameName==null){
	 frameName = parent;
}

var documentReqMap = emxUICore.selectNodes(frameName.oXML.documentElement, "/mxRoot/requestMap/setting[@name = 'RequestValuesMap']");
var items = emxUICore.selectNodes(documentReqMap[0], "items/item");
 for ( var n = 0; n < items.length; n++) {
	var name1 = items[n].getAttribute("name");
	if(items[n].getAttribute("name") == "customFormName")
		formName = isIE ? items[n].text : items[n].textContent; 

} 
 var form = "<%=formName%>";
 var type = "<%=searchType%>";
 var searchView = "<%=searchView%>";
if(form == "EngineeringDashboardFilter" || form == "EngSpecificationFilter" || form == "EngRefDocFilter"){
getTopWindow().showSlideInDialog("../common/emxForm.jsp?form="+form+"&submitAction=doNothing&formHeader=emxEngineeringCentral.EngineeringCriteria.Header&mode=edit&HelpMarker=emxhelppartbomadd&suiteKey=EngineeringCentral&initialLoad=false&preProcessJavaScript=loadFilteredValue&postProcessURL=../engineeringcentral/emxENGSearchCriteriaPostProcess.jsp&filterResult=true&searchType="+type+"&searchView="+searchView, false);
}else{
	getTopWindow().showSlideInDialog("../common/emxForm.jsp?form="+formName+"&submitAction=doNothing&formHeader=emxEngineeringCentral.EngineeringCriteria.Header&mode=edit&HelpMarker=emxhelppartbomadd&suiteKey=EngineeringCentral&initialLoad=false&preProcessJavaScript=loadFilteredValue&postProcessURL=../engineeringcentral/emxENGSubmitFilterPostProcess.jsp&filterResult=false", false);
}

</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



