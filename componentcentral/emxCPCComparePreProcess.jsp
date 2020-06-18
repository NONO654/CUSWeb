<%--  emxCPCPreProcess.jsp

  (c) Dassault Systemes, 1993-2016.  All rights reserved.

--%>
<%@include file="../emxUIFramesetUtil.inc"%>

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ page import="java.util.Set"%>
<%@ page import="com.matrixone.apps.domain.*"%>
<%@ page import="com.matrixone.apps.componentcentral.CPCCompare"%>
<jsp:useBean id="indentedTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="compareBean" class="com.matrixone.apps.componentcentral.CPCCompare" scope="session"/>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<%
	// Get suiteKey of the product - done as part of fix for IR-098236V6R2012
	String suiteKey = emxGetParameter(request, "suiteKey");
	suiteKey=XSSUtil.encodeForJavaScript(context,suiteKey);

String isError = "";
String strErrorMsg   = "";
//String acceptLanguage=request.getHeader("Accept-Language");
String displayExtendedAttributes = emxGetParameter(request, "disExtAttr");

String showExt = emxGetParameter(request, "showExt");
String selectedItems = "";
String baseObjectId="";
String calledMethod = emxGetParameter(request, "calledMethod");
int length = 0;
String[] extendedAttributes = new String[1];
String[] baseAttributes = new String[1];
String[] libAttributes=new String[1];

try{
if ("true".equals(showExt)) {
	int j=0;
	baseObjectId = compareBean.getBaseObjectID();
	if("true".equals(displayExtendedAttributes)) {
		String libraryID = (String)session.getAttribute("compareLibId");
		HashMap extLibAttrMap = compareBean.getExtendedAndLibAttr(context, libraryID, baseObjectId);
		Set libSet = (HashSet)extLibAttrMap.get("Library");
		StringList extAttrList = (StringList)extLibAttrMap.get("Extended");
		extendedAttributes = new String[extAttrList.size()];
		Iterator keySetIterator = extAttrList.iterator();
		while(keySetIterator.hasNext()) {
			extendedAttributes[j++]=(String)keySetIterator.next();
		}
		j=0;
		if(libSet.size() > 0 ) {
			libAttributes = new String[libSet.size()];

			keySetIterator = libSet.iterator();
			while(keySetIterator.hasNext()) {
				libAttributes[j++]=(String)keySetIterator.next();
			}
		}
	}
}
else {
	    session.removeAttribute("compareLibId");
	    session.removeAttribute("cpcTableMap");
		String[] selectedItemsList = emxGetParameterValues(request, "emxTableRowId");
		length= selectedItemsList.length;
		if (selectedItemsList != null) {
				for (int i = 0; i < selectedItemsList.length; i++){
					   StringList slList = FrameworkUtil.split(selectedItemsList[i], "|");
					   if(selectedItems.equals("")) {
							selectedItems = (String)slList.get(0);
							baseObjectId = (String)slList.get(0);
					   }
					   else {
							selectedItems = selectedItems +","+ (String)slList.get(0);
					   }
				}
		}
		String[] selectedObjectIds = selectedItems.split(",");
		compareBean.setObjectIDS(selectedObjectIds);
		String timeStamp = emxGetParameter(request, "timeStamp");
		HashMap tableDataMap = (HashMap) indentedTableBean.getTableData(timeStamp);
		session.setAttribute("cpcTableMap", tableDataMap);
		HashMap requestMap = (HashMap)tableDataMap.get("RequestMap");
		calledMethod = (String)requestMap.get("calledMethod");
		session.setAttribute("cpcTableMap", tableDataMap);
		requestMap.put("fromCompare", "true");
		//Start
		String filters = (String)requestMap.get("filters");
		
		if(filters!=null || filters=="")
		{
		String[] filter = filters.split(",");
		String libId = "";
		for(int i=0;i <filter.length; i++) {
			String fil = filter[i];

			if(fil.contains("LIBRARIES")) {
				StringList libIdList= FrameworkUtil.split(fil,"|");
				libId = (String)libIdList.get(1);
				//libId = libId.substring(0, (libId.length()-3));
				libId = libId.substring(0, (libId.indexOf("\"")));
				break;
			}
		}

		//End

		session.setAttribute("compareLibId", libId);
		}
		MapList columns = indentedTableBean.getColumns(tableDataMap);
		Iterator columnIterator = columns.iterator();
		StringList columnList = new StringList();
		String columnName = "";
		String columnType="";
		HashMap settingsMap = new HashMap();
		LinkedHashMap columnSettingsMap = new LinkedHashMap();
		String busExpression="";
		compareBean.pivot=false;
		compareBean.displayExtAttr=false;
		String labelName="";
		String programName="";
		String functionName="";
		String regSuite= "";
		HashMap setMap;
		while(columnIterator.hasNext()) {

			HashMap columnMap = (HashMap)columnIterator.next();
			busExpression =(String)columnMap.get("expression_businessobject");
			settingsMap =(HashMap)columnMap.get("settings");
			columnType = (String)settingsMap.get("Column Type");
			if(columnType.equals("businessobject")) {
				regSuite = (String)columnMap.get("Registered Suite");
				labelName=(String)columnMap.get("label");
				columnName = (String)columnMap.get("name");
				if(regSuite!= null && !regSuite.contains("Framework")) {
					columnName = i18nStringNowUtil("emxFrameworkStringResource","emxFramework.ObjectCompare."+busExpression, acceptLanguage);
					columnList.add(columnName+":"+busExpression);
				}
				else {
					columnList.add(labelName+":"+busExpression);
				}
			}
			else if(columnType.equals("programHTMLOutput")) {
				labelName = (String)columnMap.get("label");
				programName =(String)settingsMap.get("program");
				functionName =(String)settingsMap.get("function");
				columnList.add(labelName + "|" + programName + "|" + functionName+ "|ProgramHTML");
			}
			else {
				continue;
			}

		}
		baseAttributes = new String[columnList.size()];
		int j=0;
		Iterator columnListItr = columnList.iterator();
		while(columnListItr.hasNext()) {
			baseAttributes[j++]=(String)columnListItr.next();
		}
		compareBean.setBasicAttr(baseAttributes);
}

if(showExt == null && length < 2) {
	String languageStr  = request.getHeader("Accept-Language");
		strErrorMsg   = i18nStringNowUtil("emxComponentCentral.ObjectCompare.SelectionForCompare", "emxComponentCentralStringResource",languageStr);
		isError = "true";
		%>
		<script>
			//alert("<%=strErrorMsg%>");
		</script>
	<%
}
else
{
	compareBean.setBaseObjectID(context, baseObjectId);

	compareBean.setselectedAttributes(context, extendedAttributes, libAttributes);
	//compareBean.getCompareReport(context,(String)session.getAttribute("timeZone"), acceptLanguage);
}
}catch(Exception e){e.printStackTrace();}
%>
<script>
if("<%=isError%>" == "true") {
	alert("<%=strErrorMsg%>");
}
else {

 var url = "../componentcentral/emxCPCCompareFS.jsp?disExtAttr=<%=XSSUtil.encodeForURL(context,displayExtendedAttributes)%>&suiteKey=<%=suiteKey%>";
  var cMethod = "<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>";
 if(cMethod== "addExisting") {
 	url = url+"&calledMethod=<%=XSSUtil.encodeForJavaScript(context,calledMethod)%>";

 }
}
 if(<%=XSSUtil.encodeForJavaScript(context, showExt)%>== "true" || <%=XSSUtil.encodeForJavaScript(context, showExt)%> == "false") {
	 window.parent.location.href=url;
	 //top.close();
	
 }else {
window.open(url,'','resizable=1,width=1100,height=750,top=400,left=500,screenX=400,screenY=500',"_blank",true);
}

</script>
