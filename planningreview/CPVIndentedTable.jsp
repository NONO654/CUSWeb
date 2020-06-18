<%-- 
 ** history:
 *  @fullreview  fl3 gh4 2016/09/19: Creation (3DEXP R2017x)
 *  @quickreview gh4 qwm 2017/03/13: IR-508481: Fixed issue of displaying unwanted warning message "Object Find Limit (1) reached"
 *  @quickreview gh4 gh4 2017/06/15: FUN070920: Not much changes, just code realignment
 *	@quickreview jmm1 gh4 2017/07/04: IR-533290: PPV_FUN070920_VNLS issues with PPV app
 *  @quickreview spl7 gh4 2017/07/26: IR-533599 : Fixed issue of XSS encoding feature 
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@ page import = "com.dassault_systemes.vplm.DELJConstants"%>
<%@ page import = "com.dassault_systemes.vplm.DELJTypeNAttServices"%>
<%@ page import = "com.dassault_systemes.vplm.DELJNavigationServices"%>

<html>
	
	<head>
		<title></title>
		
	</head>
	
	<body>
	<%	
		
		String sExpandViewMode= "";
		String sInstanceView  = DELJConstants.EXP_MODE_INSTANCE;
		String sQuantityView  = DELJConstants.EXP_MODE_QUANTITY;
		String sInstGroupView = DELJConstants.EXP_MODE_INSTANCE_GROUP;
		
		Locale locale = new Locale((String)request.getHeader("Accept-Language"));
		
		String sInstanceViewHeader = EnoviaResourceBundle.getProperty(context,"emxVPLMProcessEditorStringResource", locale,"emxVPLMProcessEditor.CommandLabel.InstanceView");
		String sQuantityViewHeader = EnoviaResourceBundle.getProperty(context,"emxVPLMProcessEditorStringResource", locale,"emxVPLMProcessEditor.CommandLabel.QuantityView");
		String sInstGroupViewHeader= EnoviaResourceBundle.getProperty(context,"emxVPLMProcessEditorStringResource", locale,"emxVPLMProcessEditor.CommandLabel.InstanceGroupView");
		
		String sPreferenceTableView     = EnoviaResourceBundle.getProperty(context,"emxVPLMProcessEditorStringResource", new Locale("en"),"emxVPLMProcessEditor.CommandParameter.PreferenceView");
	
		String sViewLabelSubHeader = "";
		String sErrorMessage = "";
		String sObjectIdOld  = "";
		String sObjectIdNew  = "";
		String sPPRObjType   = "";
		String sRootObjId    = "";
		
		try
		{
			String sViewType 	= emxGetParameter(request, "TableView");
			sPPRObjType = emxGetParameter(request,"PPRObjectType");
			HashMap argsMap = new HashMap();
			HashMap paramMap = new HashMap();
			paramMap.put("languageStr", (String)request.getHeader("Accept-Language"));			
			argsMap.put("paramMap", paramMap);
			argsMap.put("type", sPPRObjType);
			
			if (sPreferenceTableView.equals(sViewType)) {	
				sViewLabelSubHeader = (String) JPO.invoke(context, "DELJMyDeskUtil", null, "getSubHeaderForUI", JPO.packArgs(argsMap), String.class);
			} else {
			
				if(!DELJConstants.PPR_OBJECT_SYSTEM.equalsIgnoreCase(sPPRObjType)){
					sExpandViewMode = PropertyUtil.getAdminProperty(context, "Person", context.getUser(), "preference_DefaultView");
					if( UIUtil.isNullOrEmpty(sExpandViewMode))
						sExpandViewMode = FrameworkProperties.getProperty(context, "emxVPLMProcessEditor.preference_DefaultView");
					
					if (sExpandViewMode == sQuantityView)
						sViewLabelSubHeader = sQuantityViewHeader;
					else if (sExpandViewMode == sInstanceView)
						sViewLabelSubHeader = sInstanceViewHeader;
					else
						sViewLabelSubHeader = sInstGroupViewHeader;
				}
				
				sRootObjId   = emxGetParameter(request, "PPRRootObjId");
				sObjectIdOld = emxGetParameter(request, "objectId");
				
				if (DELJConstants.PPR_OBJECT_PRODUCT.equalsIgnoreCase(sPPRObjType)) {
					// We get objId of Process, we've to get ProductScopeID from it
					sObjectIdNew = DELJNavigationServices.getPIDOfProductScopedWithManItem(context, sObjectIdOld);
					// IR-508481: Clear client tasks so that cached warning messages are removed off
					context.clearClientTasks();
				} 
				else {
					// We've to get PhysicalID of the Process, as in PPV we depend on PhysicalID everywhere (not objID)
					sObjectIdNew = DELJTypeNAttServices.getPhysicalId(context, sObjectIdOld);
				}
				
				if (sRootObjId==null || sRootObjId.isEmpty())
					sRootObjId = sObjectIdNew;
			}
		}
		catch(Exception e)
		{
			sErrorMessage = e.getMessage();
		}
		
		if ("".equals(sErrorMessage.trim()))
		{
			String objIdReplaceFrom = "objectId=" + sObjectIdOld;
			String objIdReplaceTo = "objectId=" + sObjectIdNew;
			%>
			
			<script language="javascript">
				var url = window.location.href;
				var replaceFrom = "planningreview/CPVIndentedTable.jsp";
				var replaceTo = "common/emxIndentedTable.jsp";
				url = url.replace(replaceFrom, replaceTo);
				
				replaceFrom = "<%=XSSUtil.encodeForJavaScript(context, objIdReplaceFrom)%>";
				replaceTo = "<%=XSSUtil.encodeForJavaScript(context, objIdReplaceTo)%>";
				url = url.replace(replaceFrom, replaceTo);
				
				url += "&expandMode=<%=XSSUtil.encodeForURL(context,sExpandViewMode)%>";
				url += "&subHeader=<%=XSSUtil.encodeForURL(context,sViewLabelSubHeader)%>";
				url += "&PPRRootObjId=<%=XSSUtil.encodeForURL(context,sRootObjId)%>";
		        window.location.href = url;
				
			</script>
			<%
		}
		else {
			%>
			<link rel="stylesheet" href="../emxUITemp.css" type="text/css">
			&nbsp;
		      <table width="90%" border=0  cellspacing=0 cellpadding=3  class="formBG" align="center" >
		        <tr align="center">
		          <td class="sErrorMessage" align="center"><xss:encodeForHTML><%=sErrorMessage%></xss:encodeForHTML></td>
		        </tr>
		      </table>
			<%
		}
		%>
	</body>
	
	<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
		
</html>
