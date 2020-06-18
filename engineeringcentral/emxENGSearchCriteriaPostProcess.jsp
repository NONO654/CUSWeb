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
	if("State".equals(reqParam)){
		String[] stateValue = request.getParameterValues("State");
		value="";
		for(String state : stateValue){
			value += state + ",";
		}
		value = value.substring(0, value.length()-1);
		sbAppendURL.append(reqParam).append("=").append(value).append("&");
	}
	if(!("suiteKey".equals(reqParam)) && !("prevURL".equals(reqParam)) && !("State".equals(reqParam))){

		if("mode".equals(reqParam))
			value="view";

		sbAppendURL.append(reqParam).append("=").append(value).append("&");
	
	}
	

}


String sName = (String)request.getParameter("Name");
String sQueryLimit = (String)request.getParameter("QueryLimit");
String sDesc = (String)request.getParameter("Description");
String sType = (String)request.getParameter("Type");
if(UIUtil.isNullOrEmpty(sType)){sType = (String)request.getParameter("TypeDisplay");}
//My ENG View Changes
String searchPolicy = (String)request.getParameter("Policy");
String[] searchState = request.getParameterValues("State");
String searchStateDisplay = (String)request.getParameter("StateDisplayValue");
String searchPhase = (String)request.getParameter("ReleasePhase");
String searchOwner = (String)request.getParameter("Owner");
String ownerDisplay = (String)request.getParameter("OwnerDisplay");
String searchTitle = (String)request.getParameter("Title");
String sAppendURL = XSSUtil.encodeURLForServer(context, sbAppendURL.toString());
String sReqParam = sAppendURL;
String sFormName = (String)request.getParameter("form");

//Display values for search criteria subheader
String sNameText = XSSUtil.encodeForURL(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxComponents.Common.Name"));
String sTitleText = XSSUtil.encodeForURL(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Specifications.Title"));
String sTypeText = XSSUtil.encodeForURL(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Common.Type"));		
String sPhaseText = XSSUtil.encodeForURL(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Attribute.Release_Phase"));
String sOwnerText = XSSUtil.encodeForURL(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Basic.Owner"));
String sPolicyText = XSSUtil.encodeForURL(context, EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.Basic.Policy"));
String sStateText = XSSUtil.encodeForURL(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Common.State"));
String sQueryLimitText = XSSUtil.encodeForURL(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.FieldName.QueryLimit"));
String sSearchCriteriaText = XSSUtil.encodeForURL(context, EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(), "emxEngineeringCentral.Subheader.SearchCriteria"));
String subheaderSeparator = "|";
String subHeaderEqual = "=";

//Convert String searchStateDisplay to String array 

searchStateDisplay = searchStateDisplay.substring(1, searchStateDisplay.length()-1);
String[] keyValuePairs = searchStateDisplay.split(",");
Map<String,String> map = new HashMap();               

for(String pair : keyValuePairs)                        //iterate over the pairs
{
    String[] entry = pair.split("=");                   //split the pairs to get key and value 
    map.put(entry[0].trim(), entry[1].trim());          //add them to the hashmap and trim whitespaces
}
String[] ar = new String[map.size()];
//ArrayList<String> ar = new ArrayList<String>();
if(searchState != null){
ar = new String[searchState.length];
for(int k=0;k<searchState.length;k++){
	ar[k]= map.get(searchState[k]);
} 
}


%>

<script language="javascript" type="text/javaScript">
var appendURL = "<%=sAppendURL%>";
var formName = "<%=sFormName%>";
var portalCommandName = "";
var subHeader = "";
var frameName = findFrame(getTopWindow(), "BOMDashboard");
if(formName == "EngineeringDashboardFilter"){
var documentReqMap = emxUICore.selectNodes(frameName.oXML.documentElement, "/mxRoot/requestMap/setting[@name = 'RequestValuesMap']");
var items = emxUICore.selectNodes(documentReqMap[0], "items/item");
 for ( var n = 0; n < items.length; n++) {
	var name1 = items[n].getAttribute("name");
	/* if(items[n].getAttribute("name") == "customFormName")
		formName = items[n].textContent; */
	if(items[n].getAttribute("name") == "portalCmdName")
		portalCommandName = isIE ? items[n].text : items[n].textContent; 
	
	if(items[n].getAttribute("name") == "subHeader"){
		subHeader = isIE ? items[n].text : items[n].textContent;
		if(subHeader != "emxEngineeringCentral.EngView.MyViewSubHeader"){
			appendURL = appendURL + name1+"=emxEngineeringCentral.EngView.MyViewSubHeader&";
			continue;
		}
	}
	appendURL = isIE? appendURL + name1+"="+items[n].text+"&":appendURL + name1+"="+items[n].textContent+"&";
} 
 }
 else if(formName == "EngSpecificationFilter"){
	 appendURL = appendURL+ "table=ENCEngineeringView&program=enoENGView:findMyViewObjects&toolbar=ENCPartSpecificationSearchToolbar&type=type_CADModel,type_CADDrawing,type_DrawingPrint,type_PartSpecification&mode=view&header=emxEngineeringCentral.Common.Specifications&selection=multiple&freezePane=Name&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&subHeader=emxEngineeringCentral.EngView.MyViewSubHeader&";
 }
 else if(formName == "EngRefDocFilter"){
	 appendURL = appendURL+ "&table=ENCEngineeringView&program=enoENGView:findMyViewObjects&toolbar=ENCFullSearchToolbar&type=type_DOCUMENTS&mode=view&header=emxEngineeringCentral.ECOSummary.ReferenceDocuments&selection=multiple&freezePane=Name&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&subHeader=emxEngineeringCentral.EngView.MyViewSubHeader&";
 }
 appendURL = appendURL+"sFromCommonComponentFilter=True";
 var contentFrameDashboard = findFrame(getTopWindow(), "BOMDashboard");
 var contentFrameDetails = findFrame(getTopWindow(), "frameDetails");
 var contentFrame;
 if((contentFrameDashboard != null || contentFrameDashboard != undefined)&&(contentFrameDetails != null || contentFrameDetails != undefined)){
	 contentFrame = contentFrameDetails;
 }else{
	 contentFrame = contentFrameDashboard;
 }
 if (contentFrame == null || contentFrame == undefined || contentFrame == "") {
 	//contentFrame = getTopWindow().findFrame(getTopWindow(), "content");
	 contentFrame = findFrame(getTopWindow(), "BOMDashboard");
 }
 //sessionStorage.setItem('sRequestParam',"<%=sReqParam%>");
 sessionStorage.setItem('sName',"<%=sName%>");
 sessionStorage.setItem('sQueryLimit',"<%=sQueryLimit%>");
 sessionStorage.setItem('sDesc',"<%=sDesc%>");
 sessionStorage.setItem('sType',"<%=sType%>");
 
 //My ENG View changes
 sessionStorage.setItem('searchPolicy',"<%=searchPolicy%>");
 //sessionStorage.setItem('searchState',"<%=searchState%>");
 sessionStorage.setItem('searchPhase',"<%=searchPhase%>");
 sessionStorage.setItem('searchOwner',"<%=searchOwner%>");
 sessionStorage.setItem('ownerDisplay',"<%=ownerDisplay%>");
 sessionStorage.setItem('searchTitle',"<%=searchTitle%>");
 sessionStorage.setItem('searchForm',"<%=sFormName%>");
 var appendSubheader = "";
if(formName == "EngineeringDashboardFilter" || formName == "EngSpecificationFilter" || formName == "EngRefDocFilter"){
	
	if('<%=sName%>' != null && '<%=sName%>' != "" && '<%=sName%>'!= undefined && '<%=sName%>' != "*"){
		appendSubheader = "<%=sNameText%>=".concat("<xss:encodeForURL><%=sName%></xss:encodeForURL>").concat(" | ");
	}
	if('<%=searchTitle%>' != null && '<%=searchTitle%>' != "" && '<%=searchTitle%>'!= undefined && '<%=searchTitle%>' != "*"){
		appendSubheader += "<%=sTitleText%>=".concat("<xss:encodeForURL><%=searchTitle%></xss:encodeForURL>").concat(" | ");
	}
	if('<%=sType%>' != null && '<%=sType%>' != "" && '<%=sType%>' != undefined && '<%=sType%>' != "*" && '<%=sType%>' != " "){
		appendSubheader += "<%=sTypeText%>=".concat("<xss:encodeForURL><%=sType%></xss:encodeForURL>").concat(" | ");
	}
	if('<%=searchPolicy%>' != null && '<%=searchPolicy%>' != "" && '<%=searchPolicy%>' != undefined && '<%=searchPolicy%>' != "*"){
		appendSubheader += "<%=sPolicyText%>=".concat("<xss:encodeForURL><%=searchPolicy%></xss:encodeForURL>").concat(" | ");
	}
	if(formName == "EngineeringDashboardFilter"){
	if('<%=searchPhase%>' != null && '<%=searchPhase%>' != "" && '<%=searchPhase%>' != undefined && '<%=searchPhase%>' != "*" && '<%=searchPhase%>' != " "){
		appendSubheader += "<%=sPhaseText%>=".concat("<xss:encodeForURL><%=searchPhase%></xss:encodeForURL>").concat(" | ");
	}
	}
	if('<%=searchOwner%>' != null && '<%=searchOwner%>' != "" && '<%=searchOwner%>' != undefined && '<%=searchOwner%>' != "*" && '<%=searchOwner%>' != " "){
		appendSubheader += "<%=sOwnerText%>=".concat("<xss:encodeForURL><%=ownerDisplay%></xss:encodeForURL>").concat(" | ");
	}
	var searchState = new Array();
	var stateSubHeader = new Array();
	//var searchStateDisplay = JSON.parse('<%=searchStateDisplay%>');
	//searchState = "<%=searchState%>";
	

<%		
if(searchState != null){	
for(int i=0;i<searchState.length;i++){%>
	searchState[<%= i %>] = "<%= searchState[i] %>"; 
	//stateSubHeader[<%= i %>] = searchStateDisplay[searchState[<%= i %>]];
	<%}%>
	<%
	
	for(int i=0;i<ar.length;i++){%>
	//searchState[<%= i %>] = "<%= searchState[i] %>"; 
	stateSubHeader[<%= i %>] = "<xss:encodeForURL><%= ar[i] %></xss:encodeForURL>";
	<%}
	}%>
	sessionStorage.setItem("searchState", JSON.stringify(searchState));
	if(searchState != null && searchState != "" && searchState != undefined && searchState != "*" && searchState != " "){
		
		var searchStateStr = stateSubHeader.join(", ");
		//var searchStateStr = searchStateDisplay.toArray();
			appendSubheader += "<%=sStateText%>=" + searchStateStr + " | ";
		}
	if('<%=sQueryLimit%>' != null && '<%=sQueryLimit%>' != "" && '<%=sQueryLimit%>' != undefined && '<%=sQueryLimit%>' != "*" && '<%=sQueryLimit%>' != " "){
		appendSubheader += "<%=sQueryLimitText%>=".concat("<xss:encodeForURL><%=sQueryLimit%></xss:encodeForURL>").concat(" | ");
	}
		if(appendSubheader != undefined || appendSubheader != null){
			appendSubheader = appendSubheader.substring(0,appendSubheader.length-2); 
			appendSubheader = "<%=sSearchCriteriaText%>: " + appendSubheader;
			appendURL = appendURL.replace("emxEngineeringCentral.EngView.MyViewSubHeader", appendSubheader);
		}else{
			appendSubheader ="";
		}
		
	}
 
	contentFrame.location.href = "../common/emxIndentedTable.jsp?"+appendURL;
  </script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>



