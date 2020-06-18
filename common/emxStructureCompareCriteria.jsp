<%--  emxStructureCompareCriteria.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxStructureCompareCriteria.jsp.rca 1.10.3.2 Wed Oct 22 15:48:12 2008 przemek Experimental przemek $
--%>
<%@include file="emxNavigatorInclude.inc"%>
<html>
<head>
<%@include file="emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxUIConstantsInclude.inc"%>
<%@include file="../emxJSValidation.inc"%>
<%@ page import = "com.matrixone.apps.domain.util.FrameworkProperties,com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.domain.util.PersonUtil"  %>
<emxUtil:localize id="i18nId" bundle="emxFrameworkStringResource" locale='<xss:encodeForHTMLAttribute><%= request.getHeader("Accept-Language") %></xss:encodeForHTMLAttribute>' />
<%@ page import="java.util.*,java.io.*,com.matrixone.jdom.*,com.matrixone.jdom.output.*"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>
 <jsp:useBean id="tableIndentedBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
  <%--Get the request parameter into local variables   --%>
<%
	  
	try{
	String strTimeStamp 		= 	emxGetParameter(request, "timeStamp");
	String strObjectIds			=	emxGetParameter(request, "objectIds");
	String strExpandProgram		=	emxGetParameter(request, "expandProgram");
	String strTable				=	emxGetParameter(request, "table");
	
	String strLevel				=	emxGetParameter(request, "level");
	String strToolbar			=	emxGetParameter(request, "toolbar");
	String sTimeStamp			=   emxGetParameter(request, "SCTimeStamp");
	
	// sIgnoredColumnType contains the StringNotCompare information
	//String sIgnoredColumnTypes = EnoviaResourceBundle.getProperty(context, "emxFramework.SBCompare.IgnoredColumnTypes");
	// The above setting is longer valid 2014x onwards. NA columns will be controlled by  getIgnoredColumnTypes method.
	String sIgnoredColumnTypes = UIStructureCompare.getIgnoredColumnTypes();
	// End

	String strQueryString = java.net.URLDecoder.decode(request.getQueryString(),"UTF-8");
	String strQuerySubString = strQueryString;
	if(strQueryString.indexOf("expandProgram")!=-1)
	{
		strQueryString = strQueryString.substring(0,strQueryString.indexOf("&expandProgram"));
		strQueryString+= strQuerySubString.substring(strQuerySubString.indexOf("&toolbar"));
	}
	String expandProgramMenu = "";
	String programName = ""; 
	if ( strExpandProgram == null || strExpandProgram.length() == 0 )
	{
	     Vector userRoleList = PersonUtil.getAssignments(context);
	     expandProgramMenu		=	emxGetParameter(request, "expandProgramMenu");
	     
	     if ( expandProgramMenu != null && expandProgramMenu.length() > 0 )
	     {
	         
	         if (UIMenu.getMenu(context, expandProgramMenu) != null) {

	             // get the Menu with commands 
	             MapList commandList = UIMenu.getMenu(context,
	                     expandProgramMenu, userRoleList);

	             // set programParam to first command
	             // add all commands to programFilter
	             int menuSize = commandList.size();
	             for (int i = 0; i < menuSize; i++) {
	                 HashMap commandItem = (HashMap) commandList.get(i);
	                 String label = UIMenu.getLabel(commandItem);
	                 
	                 
	                 String mxProgName = UIMenu.getSetting(commandItem,
	                         "program"); 
	                 String mxMethodName = UIMenu.getSetting(
	                         commandItem, "function");  

	                     // if this is the first command set tableName
	                     if (i == 0) {
	                         programName = mxProgName + ":"
	                                 + mxMethodName;
	                     } 
	                       
	                 }
	             }
	        } 
	        strQueryString += "&expandProgram="+programName;
	} 
	String strObject1 = null;
	String strObject2 = null; 
	String strObjName1= null;
	String strObjName2= null;
	String strObjType1= null;
	String strObjType2= null;
	String strObjActualType1= null;
	String strObjActualType2= null;
	 
	int level=1;
	strLevel = "1"; 
	MapList columnList = tableBean.getColumns(context, strTable, PersonUtil.getUserRoles(context));
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	columnList = tableBean.appendAdditionalColumns(context, columnList, requestMap, PersonUtil.getUserRoles(context));
	requestMap.put("objectId",(String)requestMap.get("ParentobjectId"));
	requestMap.put("userTable",Boolean.valueOf(false));
	MapList mpL = tableBean.processColumns(context, new HashMap(),columnList, requestMap);
	int iSize=mpL.size();
	StringList strColmJSLabelList=new StringList(iSize);
	StringList strColmLabelList = new StringList(iSize);
	StringList strColmList=new StringList(iSize);
	String noneLabel = UINavigatorUtil.getI18nString("emxFramework.FreezePane.SBCompare.MatchBasedRange.None","emxFrameworkStringResource", request.getHeader("Accept-Language"));
	noneLabel = FrameworkUtil.findAndReplace(noneLabel,"'","\\'");
	StringList strlNotCompare= FrameworkUtil.split(sIgnoredColumnTypes, ",");
	for(int i=0;i<iSize;i++)
	{
	    Map mtemp=(Map)mpL.get(i);
	    Map mSetting=(Map)mtemp.get("settings");
	    String strColumnType=(String)mSetting.get("Column Type");
	    String strComparable=(String)mSetting.get("Comparable");
		if(strColumnType!=null || "".equals(strColumnType)){
			if(!strlNotCompare.contains(strColumnType)){
				if( (strComparable==null) || "".equals(strComparable) || !"false".equals(strComparable)){
				    String colLabel = (String)mtemp.get("label");
				    strColmLabelList.addElement((String)mtemp.get("label"));
				    colLabel = FrameworkUtil.findAndReplace(colLabel,"'","\\'");
				    strColmJSLabelList.addElement(colLabel);
				    strColmList.addElement((String)mtemp.get("name"));
				}
			}
		}
		else{
		    String colLabel = (String)mtemp.get("label");
		    strColmLabelList.addElement((String)mtemp.get("label"));
		    colLabel = FrameworkUtil.findAndReplace(colLabel,"'","\\'");
		    strColmJSLabelList.addElement(colLabel);
    		    strColmList.addElement((String)mtemp.get("name"));
		}
	}  
	int iListSize = strColmList.size();  

	String url="&tableMenu=&expandProgramMenu=&massPromoteDemote=false&selection=multiple&showClipboard=false&objectCompare=false&HelpMarker=emxhelp_structurecomparereport";
	url += "&"+ XSSUtil.encodeURLwithParsing(context, strQueryString); 
	url += "&storeCriteria=true"; 
	
	String targetResultsPage="../common/emxStructureCompareIntermediate.jsp?SCTimeStamp"+XSSUtil.encodeForURL(context, sTimeStamp);
	targetResultsPage += url;
	
	StringTokenizer strTkObjects=new StringTokenizer(strObjectIds,",");
		
	int columnNamesCount=0;     
	if(!"".equals(strObjectIds)){         
	  columnNamesCount = strTkObjects.countTokens();         
	}         
	if(columnNamesCount==2){
		strObject1=	strTkObjects.nextToken().trim();
		strObject2=	strTkObjects.nextToken().trim();
	}else if(columnNamesCount==1)
	    strObject1=	strTkObjects.nextToken().trim(); 
	if(!strLevel.equals("")){
	    level=(int)(Integer.parseInt(strLevel));
	}
	if(strObject1!=null) 
	{
	DomainObject domObj1=new DomainObject(strObject1);
	
	strObjName1=domObj1.getName(context);
	strObjActualType1=domObj1.getType(context);
	strObjActualType1 = FrameworkUtil.findAndReplace(strObjActualType1," ","_");
	String strResKey = "emxFramework.Type."+strObjActualType1;
	strObjType1 = UINavigatorUtil.getI18nString(strResKey, "emxFrameworkStringResource", request.getHeader("Accept-Language"));
	}
	else
	    strObjName1 = "*";   
	if(strObject2!=null && !"null".equals(strObject2))
	{
	DomainObject domObj2=new DomainObject(strObject2);
	strObjName2=domObj2.getName(context);
	strObjActualType2=domObj2.getType(context);
	strObjActualType2 = FrameworkUtil.findAndReplace(strObjActualType2," ","_");
	String strResKey = "emxFramework.Type."+strObjActualType2;
	strObjType2 = UINavigatorUtil.getI18nString(strResKey, "emxFrameworkStringResource", request.getHeader("Accept-Language"));
	}
	else
	    strObjName2 = "*";	
	
%>


	<script type="text/javascript" language="javascript" src="scripts/emxUIModal.js"></script> 
	<script type="text/javascript" language="javascript" src="scripts/emxUIStructureCompareUtils.js"></script>
	<script type="text/javascript" language="javascript" src="scripts/emxUIFormUtil.js"></script>  
	<script type="text/javascript">
	        addStyleSheet("emxUIDefault");
			addStyleSheet("emxUIDialog");
			addStyleSheet("emxUIToolbar");
			addStyleSheet("emxUIMenu");
			addStyleSheet("emxUIForm");
			addStyleSheet("emxUIList");
	</script> 

	<script>		
		function showTypeSelector(strObject){
			
			if(strObject == "selTypeDisp"){
				var strURL = "../common/emxFullSearch.jsp?table=AEFGeneralSearchResults&submitURL=../common/emxStructureCompareProcess.jsp?callbackFunction=callbackNameobject1&selection=single";
			}
			if(strObject == "selTypeDisp1"){
				var strURL = "../common/emxFullSearch.jsp?table=AEFGeneralSearchResults&submitURL=../common/emxStructureCompareProcess.jsp?callbackFunction=callbackNameobject2&selection=single";
			}
			 
			showSearch(strURL);
		}
		 

		function callbackNameobject1(objectId)
		{
			var objId = objectId;
			var strObj1 = document.getElementById("selTypeDisp");
			var objHidden1 = document.getElementById("strObjectId1");
			var labelType1 = document.getElementById("labelType");			
			var strObj1Name = emxUICore.getData("emxGetNameFromId.jsp?action=objectname&objectId="+objId);
			var displayLabelType1 = emxUICore.getData("emxGetNameFromId.jsp?action=typename&objectId="+objId);
			objHidden1.setAttribute("value",objId);
			strObj1.setAttribute("value",strObj1Name);
			labelType1.innerHTML = displayLabelType1;
			return 0;
		}
		
		function callbackNameobject2(objectId)
		{
			var objId = objectId;
			var strObj2 = document.getElementById("selTypeDisp1");
			var objHidden2 = document.getElementById("strObjectId2");
			var labelType2 = document.getElementById("labelType1");
			var strObj2Name = emxUICore.getData("emxGetNameFromId.jsp?action=objectname&objectId="+objId);
			var displayLabelType2 = emxUICore.getData("emxGetNameFromId.jsp?action=typename&objectId="+objId);
			objHidden2.setAttribute("value",objId);
			strObj2.setAttribute("value",strObj2Name);
			labelType2.innerHTML=displayLabelType2+"2"; 
			return 0;
		}
	</script>
	
	<script>
		var isExpandProgOrMenuPassed = false;
		<% if(strExpandProgram != null || expandProgramMenu != null ) { %>
			isExpandProgOrMenuPassed = true;
		<% } %>
		var colNames = new Array();
		var colLabels = new Array();
		var firstOptionArray=new Array();
		var firstOptionLabelArray = new Array();
		colNames.push("None");
		//XSSOK
		colLabels.push('<%=noneLabel%>');
<%
		for(int i=0;i<iListSize;i++){
%>
			colNames.push('<%=XSSUtil.encodeForJavaScript(context,strColmList.get(i).toString())%>');
			colLabels.push('<%=XSSUtil.encodeForJavaScript(context,strColmJSLabelList.get(i).toString())%>');
			 firstOptionArray.push('<%=XSSUtil.encodeForJavaScript(context,strColmList.get(i).toString())%>');
			//XSSOK
			firstOptionLabelArray.push('<%=strColmJSLabelList.get(i)%>');
<%
		} 
%>
	</script>
</head>

<body onload=loadData()>
<form name="compareForm" method="post" action="<%=targetResultsPage%>" onsubmit="javascript:checkValue()">
	<input type="hidden" id="cbox_Value" name="cbox_Value" value=""/>
	<input type="hidden" id="matchColumns" name="matchColumns" value="<%= strColmList.toString()%>" />
	<input type="hidden" id="timeStamp" name="timeStamp" value="<xss:encodeForHTMLAttribute><%=strTimeStamp%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" id="table" name="table" value="<xss:encodeForHTMLAttribute><%=strTable%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" id="strObjectId1" name="strObjectId1" value="<xss:encodeForHTMLAttribute><%=strObject1 %></xss:encodeForHTMLAttribute>" />
	<input type="hidden" id="strObjectId2" name="strObjectId2" value="<xss:encodeForHTMLAttribute><%=strObject2 %></xss:encodeForHTMLAttribute>" />
	
	<input type="hidden" id="compareBy" name="compareBy" value="" />
	<input type="hidden" id="customize" name="customize" value="false" />
	<input type="hidden" name="IsStructureCompare" value="TRUE" />
	<input type="hidden" name="matchBasedOn" value="" />
    <input type="hidden" name="objectId" value="" />
    <input type="hidden" name="scApplied" value="false" />
    <input type="hidden" name="criteriaModified" value="false" />

	<table class="List">	
		<tr>
			<td class="labelRequired" id="labelType">
				<%
					if(strObjType1 == null || "".equals(strObjType1)){
		    	%>
			   		<emxUtil:i18n localize="i18nId">emxFramework.Common.PleaseSelectObjectToCompare</emxUtil:i18n>
		   		 <%
					}else{
		   		 %>
		    		<xss:encodeForHTML><%=strObjType1%></xss:encodeForHTML> 1
		   		 <%
					}
				%>
			</td>
		
			<td class="inputField" >
				<input type="text" id="selTypeDisp"  name="selTypeDisp" size="30" value="<xss:encodeForHTMLAttribute><%=strObjName1%></xss:encodeForHTMLAttribute>" readonly="readonly" />&nbsp;
				<input type="button" value="..." onClick=showTypeSelector("selTypeDisp") /> 
			</td>
			
			<td class="label" id="matchBased" size="25">
				<emxUtil:i18n localize="i18nId">emxFramework.Common.MatchBasedOn</emxUtil:i18n>
			</td>
			<td class="inputField" size="25">
				<select name="firstColumn" 
					id="firstColumn"   
					onChange="javaScript:populateSecondOption();populate();conflict();disableCheckBox();" 
					style="width:150px;"></select>
				<select name="secondColumn" 
					id="secondColumn" 
					onChange="javaScript:populateThirdOption();populate();disableCheckBox();conflict();" 
					style="width:150px;"> </select>
					<br>
				<select name="thirdColumn" 
					id="thirdColumn"  
					onChange="javaScript:populate();disableCheckBox();conflict();" 
					style="width:150px;"> </select>
			</td>
		</tr>

		<tr>
			<td class="labelRequired" id="labelType1">
				<%
					if(strObjType2 == null || "".equals(strObjType2)){
				    %>
			    	<emxUtil:i18n localize="i18nId">emxFramework.Common.PleaseSelectObjectToCompare</emxUtil:i18n>
			    	<%
					}else{
			    	%>
			    	<xss:encodeForHTML><%=strObjType2%></xss:encodeForHTML> 2	    
			    	<%
					}
				%>
			</td>
		
			<td class="inputField" >

  <input type="text" id="selTypeDisp1" name="selTypeDisp1" size="30" value="<xss:encodeForHTMLAttribute><%=strObjName2%></xss:encodeForHTMLAttribute>" readonly="readonly" />&nbsp;
			<input type="button" value="..." onClick=showTypeSelector("selTypeDisp1") />  
			</td>
			
			<td class="labelRequired" rowspan="3" id="compareByLabel">
				<emxUtil:i18n localize="i18nId">emxFramework.Common.CompareBy</emxUtil:i18n>
			</td> 
			
			<td class="inputField" rowspan="3" >	
			<table>
				<% 
						for(int i=0;i<iListSize;i++){
				%>					

						<td><input type="checkbox" 
		 						name="CompareBy" 
								id="CompareBy" 
								style="width:10px;"
								
								value="<%= strColmList.get(i) %>"/>&nbsp;<xss:encodeForHTML><%=strColmLabelList.get(i)%></xss:encodeForHTML></td>
						<%		
								if((i+1) % 3 == 0)
								{%>
									<tr></tr>
							  <%}
							} 
						%>			
						</table>	
			</td>
	 
		</tr>
  

		<tr>
			<td class="label" id="expandLevel">
				<emxUtil:i18n localize="i18nId">emxFramework.Common.ExpandLevel</emxUtil:i18n>
			</td>
			<td class="inputField">
				<select id="Match1" name="compareLevel" style="width:150px;" onchange="if(this.options[this.selectedIndex].value=='All') javascript:validateLevel(this);">
				<option value="1" selected><emxUtil:i18n localize="i18nId">emxFramework.FreezePane.1</emxUtil:i18n></option>
				<option value="2"><emxUtil:i18n localize="i18nId">emxFramework.FreezePane.2</emxUtil:i18n></option>
				<option value="3"><emxUtil:i18n localize="i18nId">emxFramework.FreezePane.3</emxUtil:i18n></option>
				<option value="4"><emxUtil:i18n localize="i18nId">emxFramework.FreezePane.4</emxUtil:i18n></option>
				<option value="5"><emxUtil:i18n localize="i18nId">emxFramework.FreezePane.5</emxUtil:i18n></option>
				<option value="All"><emxUtil:i18n localize="i18nId">emxFramework.FreezePane.All</emxUtil:i18n></option>
				</select>
			</td>
		</tr>
		
</table>

</form>
</body>
</html>
<%
		}catch(Exception exe)
		{
		    System.out.println(exe.getMessage());
		    throw exe; 
		}
%>
