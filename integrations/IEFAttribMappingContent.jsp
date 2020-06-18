<%--  IEFAttribMappingContent.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@ page import="java.util.*"%>
<%@ page import="java.lang.Integer"%>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>


<link rel="stylesheet" href="./styles/emxIEFMiscUI.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css">
<link rel="stylesheet" href="../common/styles/emxUIListPF.css" type="text/css">
<link rel="stylesheet" href="emxTreeTable.css" type="text/css">
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">

<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script  language="JavaScript"  src="scripts/IEFUIConstants.js"  type="text/javascript"></script>
<script  language="JavaScript"  src="scripts/MCADUtilMethods.js"  type="text/javascript"></script>
<script  language="JavaScript"  src="scripts/IEFUIModal.js"  type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script  language="JavaScript">

function changeCheckboxSelection()
{
	var tableDisplayFrame = findFrame(top,'tableDisplay');
	var sCheckBoxDelete = tableDisplayFrame.document.forms['frmAttribMapping'].elements['AttributeMapList'];
	var sCheckBoxAllDelete = tableDisplayFrame.document.forms['frmAttribMapping'].elements['deleteAttributeMapList'];
	var sSelectedNodeID = top.frames['tableDisplay'].document.forms['frmAttribMapping'].AttributeMapList.id;
	
	    if(sCheckBoxDelete.length == undefined)
		{
			if(tableDisplayFrame.document.forms['frmAttribMapping'].AttributeMapList.checked == false)
				sCheckBoxAllDelete.checked = false;
			else
				sCheckBoxAllDelete.checked = true;
		}
		else
		{
			var count = 0;
			for (var i = 0;i< sCheckBoxDelete.length;i++)
			{
				
				if(sCheckBoxDelete[i].checked == false)
				{
					sCheckBoxAllDelete.checked = false;
				}
				else
				{
					count++;
					if(count == sCheckBoxDelete.length)
					{
						sCheckBoxAllDelete.checked = true;
					}
				}
			}
		}
}

function selectAllCheckbox()
{
		var tableDisplayFrame = findFrame(top,'tableDisplay');
		var sCheckBoxAllDelete = tableDisplayFrame.document.forms['frmAttribMapping'].elements['deleteAttributeMapList'].checked;
		var sCheckBoxDelete = tableDisplayFrame.document.forms['frmAttribMapping'].elements['AttributeMapList'];
		if(sCheckBoxAllDelete)
		{			
			if(sCheckBoxDelete.length == undefined)
			{
				tableDisplayFrame.document.forms['frmAttribMapping'].AttributeMapList.checked = true;
			}
			else
			{
				for (var i = 0;i< sCheckBoxDelete.length;i++)
				sCheckBoxDelete[i].checked = true;
			}
		}
		else
		{
			if(sCheckBoxDelete.length == undefined)
			{
				tableDisplayFrame.document.forms['frmAttribMapping'].AttributeMapList.checked = false;
			}
			else
			{
				for (var i = 0;i< sCheckBoxDelete.length;i++)
				sCheckBoxDelete[i].checked = false;
			}
		}
}
</script>
<%

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);
	String lang = integSessionData.getLanguageName();
	MCADMxUtil util = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	
	String sAction 			= Request.getParameter(request,"sAction");
	String sAttrib= request.getParameter("attri");
	
	if("reset".equals(sAction))
		session.removeAttribute("IEFAttrMapping");
	
	IEFAttrMappingBase objIEFAttrMappingBase = (IEFAttrMapping)session.getAttribute("IEFAttrMapping");
	String gcoName = objIEFAttrMappingBase.getsGCOName();
	String strMappingType = objIEFAttrMappingBase.getsMappingType();
	objIEFAttrMappingBase.executeAction(context,sAction,sAttrib,"");
	String[] listColumeName = objIEFAttrMappingBase.getTableColumnNameMap();

%>

<html>
<body>
<form method="POST" name="frmAttribMapping" action="IEFAttribMappingFS.jsp?gcoName=<%=XSSUtil.encodeForURL(context,gcoName)%>&MappingType=<%=XSSUtil.encodeForURL(context,strMappingType)%>" target="_parent">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION :: IEFAttributeMAppingCOntent");
%>


		<input TYPE="hidden" NAME="attri" value="">
		<input TYPE="hidden" NAME="sAction" value="">
  
		<table class="list" align="left">
			<tr>
			<tr><th><input type="checkbox" id="deleteAttributeMapList" name="deleteAttributeMapList" onclick=javascript:selectAllCheckbox()></th><th><%=listColumeName[0]%></th><th><%=listColumeName[1]%></th><th><%=listColumeName[2]%></th><th><%=listColumeName[3]%></th></tr>
<%
		Hashtable attributeDetailsTable = objIEFAttrMappingBase.getAttributeDetailsHTable();
		if(attributeDetailsTable != null)
		{
			String strAttrFrom				= "";
			String strAttrFromValue			= "";
			String strAttrTo				= "";
			String strAttrToValue			= "";
			String strENOVIAAttributeType	= "";
			
			Iterator keys =  attributeDetailsTable.keySet().iterator();
			Hashtable attrMapShowDetails = new Hashtable();
		        String sFrameworkResourceValidation = "";
			while(keys.hasNext())
			{
				String key = (String)keys.next();
				String attrInfo = (String)attributeDetailsTable.get(key);
				objIEFAttrMappingBase.parseAttributeMappingString(attrInfo,attrMapShowDetails);
				
				if(strMappingType.equals(objIEFAttrMappingBase.MAPPINGTYPE_CADTOENOVIA))
				{
					strAttrFrom				= (String)attrMapShowDetails.get("CADTYPE");
					strAttrFrom =   util.getNLSName(context, "Range", strAttrFrom, "Attribute", "CAD Type", lang);
					strAttrFromValue		= (String)attrMapShowDetails.get("CADATTRIBUTE");
					strAttrTo				= (String)attrMapShowDetails.get("ENOVIATYPE");
					strAttrTo =   util.getNLSName(context, "Type",strAttrTo , "", "", lang);
					strAttrToValue			= (String)attrMapShowDetails.get("ENOVIAATTRIBUTE");
					strENOVIAAttributeType  = (String)attrMapShowDetails.get("ENOVIAATTRIBUTETYPE");
					sFrameworkResourceValidation = util.getStringResourceFromFrameworkBundle(strAttrToValue,strENOVIAAttributeType, context);
				
					if(null != sFrameworkResourceValidation && !"".equals(sFrameworkResourceValidation) && !strAttrToValue.equals(sFrameworkResourceValidation))
						strAttrToValue = sFrameworkResourceValidation;
				}
				else if(strMappingType.equals(objIEFAttrMappingBase.MAPPINGTYPE_ENOVIATOCAD))
				{
					strAttrFrom				= (String)attrMapShowDetails.get("ENOVIATYPE");
					strAttrFrom = util.getNLSName(context, "Type",strAttrFrom , "", "", lang);
					strAttrFromValue		= (String)attrMapShowDetails.get("ENOVIAATTRIBUTE");
					strAttrTo				= (String)attrMapShowDetails.get("CADTYPE");
					strAttrTo = util.getNLSName(context, "Range", strAttrTo, "Attribute", "CAD Type", lang);
					strAttrToValue			= (String)attrMapShowDetails.get("CADATTRIBUTE");
					strENOVIAAttributeType  = (String)attrMapShowDetails.get("ENOVIAATTRIBUTETYPE");
				sFrameworkResourceValidation = util.getStringResourceFromFrameworkBundle(strAttrFromValue,strENOVIAAttributeType, context);
				
					if(null != sFrameworkResourceValidation && !"".equals(sFrameworkResourceValidation) && !strAttrFromValue.equals(sFrameworkResourceValidation))
						strAttrFromValue = sFrameworkResourceValidation;
				}
			
%>					
						<tr bgcolor=#DADADA color=black height=24px>
						<!--XSSOK-->
						<td ><input type="checkbox" id="<%=key%>" onclick=changeCheckboxSelection() name="AttributeMapList" ></td><td><%= strAttrFrom %></td><td><%= strAttrFromValue %></td> <td><%= strAttrTo %></td><td><%= strAttrToValue %></td>
						</tr>			
<%						
				attrMapShowDetails.clear();			
			}
		}
		if(objIEFAttrMappingBase.ACTION_DEPLOY.equals(sAction))
		{
			%>
			<script>
				top.close();
			</script>
			<%
		}
%>
</tr>
</table>
</form>
</body>
</html>
