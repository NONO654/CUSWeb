<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%@page import="com.matrixone.apps.engineering.ExportToExcelUtil"%>


<%
String includePolicy = emxGetParameter(request,"includePolicy");
String excludePolicy = emxGetParameter(request,"excludePolicy");
String includeState = emxGetParameter(request,"initialState");
String checkOriginator = emxGetParameter(request,"checkOriginator");
String checkModified = emxGetParameter(request,"checkUserPreferences");
String sFormName = emxGetParameter(request,"customFormName");

StringBuffer sWhereExpr = new StringBuffer();
if(UIUtil.isNotNullAndNotEmpty(includePolicy)){
	if(includePolicy.indexOf(",") == -1)
		sWhereExpr.append("(policy == \\\""+includePolicy+"\\\")");
	else {
		StringList slPolicyList = FrameworkUtil.split(includePolicy,",");
		for(int i = 0; i <slPolicyList.size(); i++){
			if(sWhereExpr.length() == 0)
				sWhereExpr.append("(policy == \\\""+slPolicyList.get(i)+"\\\"");
			else
				sWhereExpr.append("|| policy == \\\""+slPolicyList.get(i)+"\\\")");
		}
	}
}
if(UIUtil.isNotNullAndNotEmpty(excludePolicy)){
	if(sWhereExpr.length()>0)
		sWhereExpr.append("&& (");
	else 
		sWhereExpr.append("(");
	if(excludePolicy.indexOf(",") == -1)
		sWhereExpr.append("policy != \\\""+excludePolicy+"\\\")");
	else {
		StringList slPolicyList = FrameworkUtil.split(excludePolicy,",");
		for(int i = 0; i <slPolicyList.size(); i++){
			if(sWhereExpr.length() == 0)
				sWhereExpr.append("policy != \\\""+slPolicyList.get(i)+"\\\"");
			else
				sWhereExpr.append("&& policy != \\\""+slPolicyList.get(i)+"\\\")");
		}
	}
}	
if(UIUtil.isNotNullAndNotEmpty(includeState)){
	if(sWhereExpr.length()>0)
		sWhereExpr.append("&& (");
	else 
		sWhereExpr.append("(");
	if(includeState.indexOf(",") == -1)
		sWhereExpr.append("current == \\\""+includeState+"\\\")");
	else {
		StringList slStateList = FrameworkUtil.split(includeState,",");
		for(int i = 0; i <slStateList.size(); i++){
			if(sWhereExpr.length() == 0)
				sWhereExpr.append("current == \\\""+slStateList.get(i)+"\\\"");
			else
				sWhereExpr.append("|| current != \\\""+slStateList.get(i)+"\\\")");
		}
	}
}
if("true".equals(checkOriginator)){
	 if(sWhereExpr.length()>0)
		sWhereExpr.append("&& (");
	else 
		sWhereExpr.append("("); 
	sWhereExpr.append("owner == \\\""+context.getUser()+"\\\"");
	sWhereExpr.append("|| attribute["+DomainConstants.ATTRIBUTE_ORIGINATOR+"] == \\\""+context.getUser()+"\\\")");
}


if("true".equals(checkModified)){
	String prefdays = PropertyUtil.getAdminProperty(context, DomainConstants.TYPE_PERSON, context.getUser(), "preference_MyViewPreference");
	if(UIUtil.isNotNullAndNotEmpty(prefdays)){
		int days=Integer.parseInt(prefdays);
		String dateNumofDaysBack=ExportToExcelUtil.getDateAfter(days);
		
		sWhereExpr.append("&& (modified >= \\\""+dateNumofDaysBack+"\\\")");
	}
}

//TODO: change to Policy.
if("EngSpecificationFilter".equals(sFormName)){
	sWhereExpr.append("&& (attribute["+DomainConstants.ATTRIBUTE_IS_VERSION_OBJECT+"]==False)");
}

//String sObjectCount = MqlUtil.mqlCommand(context,"eval expr 'count true' on temp que bus Part * * where '"+sWhereExpr.toString()+"'");
String sInitialQueryLimit = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.InitialLoad.QueryLimit");
Enumeration en1 = request.getParameterNames();
StringBuffer sbAppendURL = new StringBuffer();
while(en1.hasMoreElements()) {
	String reqParam = (String)en1.nextElement();
	String value = (String)request.getParameter(reqParam);
	sbAppendURL.append(reqParam).append("=").append(value).append("&");
}
String sPortalCommandName = emxGetParameter(request,"portalCmdName");
//sInitialQueryLimit = "10";
boolean sInitialEntryMore = false;
if(Integer.parseInt(sInitialQueryLimit)>32000){
	sInitialQueryLimit = "32000";
	sInitialEntryMore = true;
}
	
sbAppendURL.append("initialQueryLimit=").append(sInitialQueryLimit);
String sAppendURL = XSSUtil.encodeURLForServer(context,sbAppendURL.toString());
%>
	

<script language="Javascript">
//TODO: Create an object
sessionStorage.removeItem("sName");
sessionStorage.removeItem("sQueryLimit");
sessionStorage.removeItem("sDesc");
sessionStorage.removeItem("sType");
sessionStorage.removeItem("MEPName");
sessionStorage.removeItem("MEPType");
sessionStorage.removeItem("MEPState");
sessionStorage.removeItem("MEPDescription");
sessionStorage.removeItem("MEPStatus");
sessionStorage.removeItem("MEPManufacturer");
sessionStorage.removeItem("MEPPreference");

//My ENG View changes
sessionStorage.removeItem("searchPolicy");
sessionStorage.removeItem("searchState");
sessionStorage.removeItem("searchPhase");
sessionStorage.removeItem("searchOwner");
sessionStorage.removeItem("searchTitle");
sessionStorage.removeItem("formName");

var appendURL = "<%=XSSUtil.encodeForJavaScript(context, sAppendURL)%>";
// For ZAP Issue IR-532050-3DEXPERIENCER2018x encoding the form name.
<%-- var formName = "<%=sFormName%>"; --%>
var formName = "<%=XSSUtil.encodeForJavaScript(context,sFormName)%>";


<%--var totalCount = <%=sObjectCount%>;--%>
var initialQueryLimit = <%=sInitialQueryLimit%>;
var initialEntryMore="<%=sInitialEntryMore%>";
//if(totalCount >initialQueryLimit)
	//getTopWindow().showSlideInDialog("../common/emxForm.jsp?form="+formName+"&submitAction=doNothing&formHeader=emxEngineeringCentral.EngineeringCriteria.Header&mode=edit&HelpMarker=emxhelppartbomadd&suiteKey=EngineeringCentral&initialLoad=true&&sInitialEntryMore="+initialEntryMore+"&postProcessURL=../engineeringcentral/emxENGSubmitFilterPostProcess.jsp", false);

var portalCommandName = "<%=XSSUtil.encodeForJavaScript(context, sPortalCommandName)%>";
var contentFrame = getTopWindow().findFrame(getTopWindow(), "BOMDashboard");
if(contentFrame == null || contentFrame == "" || contentFrame == "null"){
	if(portalCommandName != null && portalCommandName != "" && portalCommandName != "null")
		contentFrame = getTopWindow().findFrame(getTopWindow(), portalCommandName);
	else
		contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
}
/* if("EngineeringDashboardFilter" == formName || "EngSpecificationFilter" == formName){
	contentFrame = getTopWindow().findFrame(getTopWindow(), "BOMDashboard");
} */

contentFrame.location.href = "../common/emxIndentedTable.jsp?"+appendURL;

</script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



