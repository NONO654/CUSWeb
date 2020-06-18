<%--  emxStructureCompareIntermediate.jsp   -    Post Process JSP for structure compare webform, directs based on user selection to tabular report or visual report jsp.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>
<%@ page import="com.matrixone.apps.framework.ui.UIStructureCompare"%>
<html>


<jsp:useBean id="SCTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>

<body>

<form name="AEFSCIntermediateForm" method="post">


<%

SCTableBean = (UIStructureCompare)structureCompareBean;
//String strResetMode = emxGetParameter(request, "isResetMode");
String sTimeStamp = emxGetParameter(request, "SCTimeStamp");

/*
if(!UIUtil.isNullOrEmpty(strResetMode) && "true".equals(strResetMode) && !UIUtil.isNullOrEmpty(sTimeStamp))
{
	((com.matrixone.apps.framework.ui.UIStructureCompare)SCTableBean).removeSCCriteriaMap(sTimeStamp);	
}
*/

HashMap hmCompareSelectionMap = new HashMap();

String strSubmitURL  = emxGetParameter(request, "submitURL");
String strReportType = emxGetParameter(request, "fromPage");


boolean isApplied = UIUtil.isNullOrEmpty(strReportType) ? true : false; 

Enumeration en = emxGetParameterNames(request); 

String sReportType = "";

String strLanguage = request.getHeader("Accept-Language");
String strEmptyReportMsg = UINavigatorUtil.getI18nString(
		"emxFramework.Common.EmptyReportResults",
		"emxFrameworkStringResource", strLanguage);

boolean isBlank = true;
boolean isBPSReport = UIUtil.isNullOrEmpty(strSubmitURL) ? true : false;



HashMap sessionValueMap = null; 
	
StringBuffer paramValues = new StringBuffer();

if(!UIUtil.isNullOrEmpty(sTimeStamp) && !isApplied)
{
	sessionValueMap = (HashMap)((UIStructureCompare)SCTableBean).getSCCriteria(sTimeStamp);
}

try
{
	Map requestMapToSubmit = new HashMap();
	
	if(null != sessionValueMap)
	{
		requestMapToSubmit = (HashMap)sessionValueMap.get("requestMap");	
	}
	
	if(requestMapToSubmit == null || requestMapToSubmit.size() < 1) {
		requestMapToSubmit = UINavigatorUtil.getRequestParameterMap(request);
	}
	java.util.Set ketSet = requestMapToSubmit.keySet();
	Iterator itrKey = ketSet.iterator();
	
	while(itrKey.hasNext()) {
		String sKey = (String)itrKey.next();
		String sVal = "";
		try {
			sVal = (String)requestMapToSubmit.get(sKey);
		} catch (Exception e) {
			//Do nothing
		} if(!sVal.equals("")) {
			%>
				<input type="hidden" name="<xss:encodeForHTMLAttribute><%=sKey%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=sVal%></xss:encodeForHTMLAttribute>" />
			<%
		}
	}
	
	hmCompareSelectionMap.put("requestMap", requestMapToSubmit);

//If - BPS Report: Build the URL for first time, else - Fetch the submit URL already prepared, change the Report type.
	if(isBPSReport)
	{
		if(UIUtil.isNullOrEmpty(strReportType))
		{
			isBlank = false;
	
			String strQueryString = java.net.URLDecoder.decode(request.getQueryString(),"UTF-8");
			String IsStructureCompare = emxGetParameter(request, "IsStructureCompare"); 
			String strCompareBy = emxGetParameter(request, "compareBy"); 
			String sMatchBasedOn = emxGetParameter(request, "matchBasedOn"); 
			String sCustomLevel = emxGetParameter(request, "compareLevel"); 
			String objectId = emxGetParameter(request, "objectId");
			String customize = emxGetParameter(request, "customize");

			strSubmitURL ="../common/emxIndentedTable.jsp?SCTimeStamp="+XSSUtil.encodeForURL(context, sTimeStamp)+"&subHeader=testing&objectId="+XSSUtil.encodeForURL(context, objectId)+"&IsStructureCompare="+XSSUtil.encodeForURL(context, IsStructureCompare)+"&matchBasedOn="+XSSUtil.encodeForURL(context, sMatchBasedOn)+"&compareLevel="+XSSUtil.encodeForURL(context, sCustomLevel)+"&compareBy="+XSSUtil.encodeForURL(context, strCompareBy)+"&"+XSSUtil.encodeURLwithParsing(context, strQueryString)+"&hideHeader=true&customize="+XSSUtil.encodeForURL(context, customize);
		}
		else if(null != sessionValueMap)
		{
			isBlank = false;
			strSubmitURL = (String)sessionValueMap.get("SubmitURL");	
		}

	}
	else
	{
		//App specific report
		strSubmitURL += "?SCTimestamp="+XSSUtil.encodeForURL(context, sTimeStamp);

		if(UIUtil.isNullOrEmpty(strReportType))
	    {
	   		isBlank = false;
			
	   		hmCompareSelectionMap.put("SubmitURL",strSubmitURL);
	    }
	   	else if(null != sessionValueMap)
	   	{
	   		isBlank = false;
	   		strSubmitURL = (String)sessionValueMap.get("SubmitURL");
	   	}
	}

	if(!UIUtil.isNullOrEmpty(strSubmitURL))
	{
		hmCompareSelectionMap.put("SubmitURL",strSubmitURL);
	}
}
catch(Exception ex)
{
	ex.printStackTrace();
}

String reportFrame = null;

if(UIUtil.isNullOrEmpty(strReportType))
{
	strReportType = ((UIStructureCompare)SCTableBean).getActiveTabForStructureCompare(sTimeStamp);
}

if(isBPSReport)
{
	reportFrame = ((UIStructureCompare)SCTableBean).getFrameForActiveTab(strReportType); 
}

%>

<script>
//Start: Added to persist the BOM Compare criteria values 
if(!getTopWindow().window.info) {
	getTopWindow().window.info=[];
}

var JSONObjectStr = '{';
var temp = "";
var fieldName = "";
var fieldValue = "";
var alreadyCoveredCheckBoxes = new Array();
var alreadyCovered = false;
if(parent.document) {
	var editForm = parent.document.forms["editDataForm"];
	if(!editForm) {
		editForm = (findFrame(getTopWindow(),"formStructureCompare")) ? findFrame(getTopWindow(),"formStructureCompare").document.forms["compareForm"] : undefined;
	} 
	
	if(editForm) {
		for(var i=0; i < editForm.length; i++) {
		   temp = editForm.elements[i];
		   fieldName = temp.name;
		   fieldValue = ""; 
			
		   if(temp.type=="text" || temp.type=="hidden") {
			   fieldValue=temp.value;
			} else if(temp.type=="select-one") {
				fieldValue = temp.options[temp.selectedIndex].value;
			} else if(temp.type=="radio"){
				if(temp.checked) {
					fieldValue = temp.value;
				}
			} else if(temp.type=="checkbox") {
				//This logic is for multi check box wth same name
				alreadyCovered = false;
				for(var k= 0; k < alreadyCoveredCheckBoxes.length; k++){
					if(alreadyCoveredCheckBoxes[k] == fieldName) {
						alreadyCovered = true;
					}
				}
				if(alreadyCovered)
					continue;
				
				alreadyCoveredCheckBoxes.push(fieldName);
				var obj = eval("editForm." + fieldName);
				var count = obj.length;
				if(count) {
					fieldValue = "";
					for(var j=0; j < count; j++){
				   		if (obj[j].checked){
				   			fieldValue += obj[j].value + ",";
				      	}
				  	}
				} else {
					if (obj.checked)
						fieldValue = obj.value;
				}
			} else {
				fieldValue = temp.value;
			}
		
			if(fieldName && fieldValue) {
				JSONObjectStr += '"'+ fieldName +'" : "' + fieldValue + '",';
			}
		}
		
		JSONObjectStr += '}';
		var JSONObject = eval ('(' + JSONObjectStr + ')');
		getTopWindow().window.info["CompareCriteriaJSON"] = JSONObject;
	}
}


//End: Added to persist the BOM Compare criteria values 

var isBlank = '<%=isBlank%>';
var isBPSReport = '<%=isBPSReport%>';

if(isBlank == "false")
{
	//XSSOK
	var submitURL = "<%=strSubmitURL%>";
	var activeTab = "<xss:encodeForJavaScript><%=strReportType%></xss:encodeForJavaScript>";

	submitURL += "&reportType="+activeTab;		
	
	if(isBPSReport == "true")
	{
		var reportFrame = "<%=reportFrame%>";
	
		getTopWindow().findFrame(getTopWindow(),reportFrame).location.href = submitURL;
		
	}
	else
	{
		document.AEFSCIntermediateForm.action = submitURL;
		document.AEFSCIntermediateForm.method = "post";
		document.AEFSCIntermediateForm.submit();
	}
}


</script>   


<%
if(isBlank)
{
%>
<script type="text/javascript"> addStyleSheet("emxUIDialog"); </script>
<div class="divPageBody" align = "center"><%=strEmptyReportMsg%></div>

 
<%
}

if(!UIUtil.isNullOrEmpty(sTimeStamp) && isApplied)
{
	((UIStructureCompare)SCTableBean).setStructureCompareCriteria(sTimeStamp, hmCompareSelectionMap);
}
else
{
	((UIStructureCompare)SCTableBean).setActiveTabForStructureCompare(sTimeStamp, strReportType);
}

%> 
</form>
</body>
</html>
