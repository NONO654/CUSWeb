 <%-- emxMultiColumnSortDialogBody.jsp
   Copyright (c) 1993-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file="emxNavigatorInclude.inc"%>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxUIConstantsInclude.inc"%>
<%@include file="../emxJSValidation.inc"%>
<jsp:useBean id="indentedTableBean"	class="com.matrixone.apps.framework.ui.UITableIndented" scope="session" />
<jsp:useBean id="tableBean"	class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%@ page import="java.util.List,java.util.ArrayList,java.util.HashMap,java.util.StringTokenizer,com.matrixone.apps.domain.util.MapList,com.matrixone.jsystem.util.MxMatcher,com.matrixone.jsystem.util.MxPattern"%>
<html>
<head>

<script language="javaScript">
addStyleSheet("emxUIDefault");
addStyleSheet("emxUIForm");
<%
String strNoneLabel = UINavigatorUtil.getI18nString("emxFramework.UITable.SortColumn.Default","emxFrameworkStringResource",request.getHeader("Accept-Language"));
String strNone = "None";
%>
	var strColNames=new Array();
	//XSSOK
	strColNames.push("<%=strNone%>");
	var strColLabel=new Array();
	//XSSOK
	strColLabel.push("<%=strNoneLabel%>");
	var sNames=new Array();
	var sortDirectionArray=new Array();

<%           
	String columnName;
    String sLabel;
	String sColumnName="";
	String sortColumnName="";
	String sColumnDirection="";
	String sDirection="";
	MapList tableColumns=new MapList();
	HashMap columnSettings = null;
	List sColumnNames = new ArrayList();
	List sNames = new ArrayList();
	List sortDirectionArray = new ArrayList();
	String timeStamp = emxGetParameter(request, "timeStamp");
	String uiType = emxGetParameter(request,"uiType");
	
	
	//Added For Custom table
	HashMap hmpTableData = null;
	HashMap hmpTableControlMap = null;
	HashMap hmpRequest = null;
	String strTableName = "";
	
	if("structureBrowser".equals(uiType)){
	    hmpTableData = indentedTableBean.getTableData(timeStamp);
	    hmpRequest = indentedTableBean.getRequestMap(hmpTableData);
	    boolean isUserTable = ((Boolean)hmpRequest.get("userTable")).booleanValue();
	    hmpTableControlMap = indentedTableBean.getControlMap(hmpTableData);
		sortColumnName = (String) hmpTableControlMap.get("SortColumnName");
		sDirection = (String) hmpTableControlMap.get("SortDirection");
		tableColumns = indentedTableBean.getColumns(timeStamp);
		strTableName = (String)hmpRequest.get("selectedTable");
		if(isUserTable)
		{
		    sortColumnName = (String) hmpRequest.get("customSortColumns");
			sDirection = (String) hmpRequest.get("customSortDirections");
			
		}
		
	}else{
		hmpTableData = tableBean.getTableData(timeStamp);
		hmpTableControlMap = tableBean.getControlMap(hmpTableData);
		hmpRequest = tableBean.getRequestMap(hmpTableData);
		boolean isUserTable = ((Boolean)hmpRequest.get("userTable")).booleanValue();
		sortColumnName = (String) hmpTableControlMap.get("SortColumnName");
		sDirection = (String) hmpTableControlMap.get("SortDirection");
		tableColumns = tableBean.getColumns(timeStamp);
		strTableName= (String)hmpRequest.get("table");
		if(isUserTable)
		{
		    sortColumnName = (String) hmpRequest.get("customSortColumns");
			sDirection = (String) hmpRequest.get("customSortDirections");
			
		}
	}
	
	for(int i=0;i<tableColumns.size();i++){
		columnSettings = (HashMap)tableColumns.get(i);
		HashMap settings=(HashMap)columnSettings.get("settings");
		String Sortable = (String)settings.get("Sortable");
		String sColumnType=(String)settings.get("Column Type");
		String sSortType=(String)settings.get("Sort Type");
		if(("true".equalsIgnoreCase(Sortable) ||
		        "null".equalsIgnoreCase(Sortable)) && 
		        (!sColumnType.equalsIgnoreCase("icon") &&
		                !sColumnType.equalsIgnoreCase("File") &&
		                !sColumnType.equalsIgnoreCase("Image") &&
		                !sColumnType.equalsIgnoreCase("Separator")) )
		                //&& !"other".equals(sSortType))
		        {
			columnName = (String)columnSettings.get("name");
			sLabel=(String)columnSettings.get("label");
			String sAlt = (String)columnSettings.get("alt");
			if(sAlt != null && sAlt != ""){
				sLabel = sAlt;
			}
			MxPattern p1 = MxPattern.compile("<img.* src=.*>.*</img>");
			MxPattern p2 = MxPattern.compile("<img.* src=.*/>");			
			MxPattern p3 = MxPattern.compile("<img.* src=.*>");
			MxMatcher m1 = p1.matcher(sLabel);
			MxMatcher m2 = p2.matcher(sLabel);			
			MxMatcher m3 = p3.matcher(sLabel);
			if (m1.matches() || m2.matches() || m3.matches()) {
				sLabel = columnName;
			}
			sColumnNames.add(columnName);
%>
			// JS colNames
			strColNames.push("<%=columnName%>"); //XSSOK
			strColLabel.push("<%=sLabel%>"); //XSSOK

<%
		}
	}
	
	
	if(!"".equalsIgnoreCase(sortColumnName)){
		StringTokenizer sNameTokenizer = new StringTokenizer(sortColumnName,",");
		while (sNameTokenizer.hasMoreTokens()) {
			sColumnName = sNameTokenizer.nextToken();
			if(sColumnNames.contains(sColumnName)){
%>
			// JS sNames       
			sNames.push("<xss:encodeForJavaScript><%=sColumnName%></xss:encodeForJavaScript>");    

<%
			}
        }
	}
	
	StringTokenizer sDirectionTokenizer = new StringTokenizer(sDirection, ",");
	while (sDirectionTokenizer.hasMoreTokens()) {
		sColumnDirection = sDirectionTokenizer.nextToken();
		sortDirectionArray.add(sColumnDirection);
%>
		// JS sNames       
		sortDirectionArray.push("<xss:encodeForJavaScript><%=sColumnDirection%></xss:encodeForJavaScript>");    

<%
	}
%>
</script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script type="text/javascript">
     function doSubmit(){
 	var consolidatedCols = "";
	var dir = "";
	//for IR-059878V6R2011x
    var colDir = "";
 	if(document.getElementById('firstColumn').value != 'None'){
 		consolidatedCols += document.getElementById('firstColumn').value;
 		colDir = document.multiColumnSortBody.firstColumnGroup[0].checked ? "ascending" : "descending";   
 		dir = colDir;
 		if(document.getElementById('secondColumn').value != 'None'){
     		consolidatedCols += "," + document.getElementById('secondColumn').value;
     		colDir = document.multiColumnSortBody.secondColumnGroup[0].checked ? ",ascending" : ",descending";
     		dir += colDir;
     		
	     	if(document.getElementById('thirdColumn').value != 'None'){
	     		consolidatedCols += ","+ document.getElementById('thirdColumn').value;
	            colDir = document.multiColumnSortBody.thirdColumnGroup[0].checked ? ",ascending" : ",descending";
	            dir += colDir;
	     	}
	    }
 		//for IR-059878V6R2011x
 	} else {
 		  consolidatedCols = "none";
 		  if(document.multiColumnSortBody.firstColumnGroup[0].checked){
 			 dir = "ascending";
 		  }else {
 			 dir = "descending";
 		  }
 	}
	
	//If the underlying table is a structure browser, call the methods of SB. Otherwise, reloadTable
	if("structureBrowser" == "<xss:encodeForJavaScript><%=uiType%></xss:encodeForJavaScript>"){
		//getTopWindow().getWindowOpener().setRequestMap(consolidatedCols,dir);
		getTopWindow().getWindowOpener().refreshRows(consolidatedCols,dir);
		this.closeWindow();
	}else{
		getTopWindow().getWindowOpener().reloadTable("<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>",consolidatedCols,dir);
	}
}
     
</script>
<script type="text/javascript" language="javascript" src="../common/scripts/emxUIMultiColumnSortUtils.js"></script>
</head>
<body style="margin:0; padding: 0 10px 0 10px;">
	<form name="multiColumnSortBody" method="post" action="javascript:doSubmit();">
	   <table class="grid">
			<tr class="no-background">
				<th scope="col"></th>
				<th scope="col"></th>
				<th scope="col"><img src="images/iconSortAscending.gif" /></th>
				<th scope="col"><img src="images/iconSortDescending.gif" /></th>
			</tr>
			<tr>
				<th scope="row"><emxUtil:i18n localize="i18nId">emxFramework.Common.Label.1st</emxUtil:i18n></th>
				<td class="merge-with-next">
					<select name="firstColumn" id="firstColumn" style="max-width: 270px;" onChange="javaScript:populateSecondOption();populateThirdOption();populate();conflict();"> </select>
			</td>
				<td class="merge-with-next"><input type="radio" id="firstGroup" name="firstColumnGroup" value="ascending" checked /></td>
				<td><input type="radio" id="firstGroup" name="firstColumnGroup" value="descending" /></td>
			</tr>
			<tr>
				<th scope="row"><emxUtil:i18n localize="i18nId">emxFramework.Common.Label.2nd</emxUtil:i18n></th>
				<td class="merge-with-next">
					<select name="secondColumn" id="secondColumn" style="max-width: 270px;" onChange="javaScript:populateThirdOption();populate();conflict();"> 
					</select>
				</td>
				<td class="merge-with-next"><input type="radio" id=secondGroup" name="secondColumnGroup" value="ascending" checked /></td>
				<td><input type="radio" id=secondGroup" name="secondColumnGroup" value="descending" /></td>
			</tr>
			<tr>
				<th scope="row"><emxUtil:i18n localize="i18nId">emxFramework.Common.Label.3rd</emxUtil:i18n></th>
				<td class="merge-with-next">
					<select name="thirdColumn" id="thirdColumn" style="max-width: 270px;" onChange="javaScript:populate();conflict();"> 
					</select>
				</td>
				<td class="merge-with-next"><input type="radio" id=thirdGroup" name="thirdColumnGroup" value="ascending" checked /></td>
				<td><input type="radio" id=thirdGroup" name="thirdColumnGroup" value="descending" /></td>
			</tr>
		</table>
		<script language="JavaScript">
		
		setSortColumnsArray(strColNames,strColLabel);
		loadData(sNames,sortDirectionArray,document.multiColumnSortBody.firstColumnGroup,document.multiColumnSortBody.secondColumnGroup,document.multiColumnSortBody.thirdColumnGroup);
		</script>
	</form>
</body>
</html>
