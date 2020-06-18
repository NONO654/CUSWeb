<%--  MCADVersionsSummary.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
 <%--  common revisions summary page  

--%>
<%@ page import="com.matrixone.apps.domain.util.*,com.matrixone.apps.framework.ui.*" %>

<%@ include file ="MCADTopInclude.inc"%>
<%@include file = "MCADTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<jsp:useBean id="bo" class="com.matrixone.apps.domain.DomainObject" scope="page" />
<%@include file = "../emxTagLibInclude.inc"%>


<%!
	//Framework uses 'emxUIFrameworkStringResource'
	// Call this method to internationalize variables in java.
	public String i18nStringNowUtil(String text,String Bundle, String languageStr) 
	{
		com.matrixone.apps.domain.util.i18nNow loc = new com.matrixone.apps.domain.util.i18nNow();

		return (String)loc.GetString(Bundle, languageStr, text);
	}

	// Get object details page to show object details page based on the application being used.
	public String getObjectDetailsPageName(HttpServletRequest request, String appName2)
	{
		String objectDetailsPageName = appName2 + "/common/emxTree.jsp";

		String sSuiteDirectory = (String) emxGetParameter(request, "emxSuiteDirectory" );
		if(sSuiteDirectory != null)
		{
			if(sSuiteDirectory.indexOf("infocentral") > -1)
				objectDetailsPageName = appName2 + "/infocentral/emxInfoManagedMenuEmxTree.jsp";
			else if(sSuiteDirectory.indexOf("iefdesigncenter") > -1)
				objectDetailsPageName = appName2 + "/common/emxTree.jsp";
		}

		return objectDetailsPageName;
	}
%>

<script language="JavaScript">
    function openWindow(strURL)
    {
        window.open(strURL);
    }
</script>
<%
	String jsTreeID			= emxGetParameter(request,"jsTreeID");
	String objectId			= emxGetParameter(request,"objectId");
	String suiteDirectory	= emxGetParameter(request, "emxSuiteDirectory");

	String queryString	= request.getQueryString();
	MapList revisionsList = null;

	String appName = application.getInitParameter("ematrix.page.path");

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = Framework.getFrameContext(session);

	MCADMxUtil util = new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	
	SelectList busSelects = bo.getBusSelectList(7);
	busSelects.add(bo.SELECT_ID);
	busSelects.add(bo.SELECT_NAME);
	busSelects.add(bo.SELECT_REVISION);
	busSelects.add(bo.SELECT_TYPE);
	busSelects.add(bo.SELECT_CURRENT);
	busSelects.add(bo.SELECT_DESCRIPTION);
	String ATTR_MCAD_LABEL =  util.getActualNameForAEFData(context,"attribute_MCADLabel");
	String SELECT_ATTR_MCAD_LABEL = "attribute[" + ATTR_MCAD_LABEL + "]";
	busSelects.add(SELECT_ATTR_MCAD_LABEL);
	
	//Get any versioned object and pass its id
	
	String acceptLanguage = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);
	String errorMessage = "";

	if(integSessionData == null)
	{
		errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.UserDoesNotHavePrivilegesToUseIEF");
		//emxNavErrorObject.addMessage(errorMessage);
	}

	try
	{
	String integrationName							= util.getIntegrationName(context, objectId);
	MCADGlobalConfigObject  globalConfigObject		= integSessionData.getGlobalConfigObject(integrationName,context);
	MCADServerGeneralUtil serverGeneralUtil			= new MCADServerGeneralUtil(context, globalConfigObject, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

	BusinessObject busObj = new BusinessObject(objectId);
	busObj.open(context);
	BusinessObjectList list    = util.getMinorObjects(context,busObj);
	BusinessObjectItr boRevItr = new BusinessObjectItr(list);
	if(boRevItr.next())
	{
		BusinessObject thisBO = boRevItr.obj();
		thisBO.open(context);
		objectId = thisBO.getObjectId();		
		
		request.setAttribute("objectId", objectId);
		bo.setId(objectId);
		thisBO.close(context);

		revisionsList = bo.getRevisions(context, busSelects, false);
	}
	busObj.close(context);

	String objectDetailsPageName = getObjectDetailsPageName(request, appName);	
%>

<html>
<head>

<!--XSSOK-->
<link rel="stylesheet" href="<%=appName%>/common/styles/emxUIDefault.css" type="text/css">
<!--XSSOK-->
<link rel="stylesheet" href="<%=appName%>/common/styles/emxUIList.css" type="text/css">
<!--XSSOK-->
<link rel="stylesheet" href="<%=appName%>/common/styles/emxUIForm.css" type="text/css">
<!--XSSOK-->
<link rel="stylesheet" href="<%=appName%>/common/styles/emxUIProperties.css" type="text/css" >
<!--XSSOK-->
<link rel="stylesheet" href="<%=appName%>/emxUITemp.css" type="text/css">


<style type="text/css"> 
td.highlight {  font-weight: bold; color: red } 
</style>

<!--XSSOK-->
<script src="<%=appName%>/integrations/scripts/MCADUtilMethods.js" type="text/javascript"></script>
<!--XSSOK-->
<script src="<%=appName%>/common/scripts/emxUIConstants.js" type="text/javascript"></script>
<!--XSSOK-->
<script src="<%=appName%>/common/scripts/emxUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>

</head>
<body>
<form name = "tableForm" method="post" >

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
//System.out.println("CSRFINJECTION");
%>


      <table width="100%%" border="0" cellpadding="3" cellspacing="3">

      <tr>
		  <th nowrap="nowrap"><input type = "checkbox" name ="selectAllCheckbox" onClick = "parent.selectAllNodes()"> </th>
		  <!--XSSOK-->
          <th nowrap="nowrap"><%=integSessionData.getStringResource("mcadIntegration.Server.ColumnName.Name")%></th>
		  <!--XSSOK-->
          <th nowrap="nowrap"><%=integSessionData.getStringResource("mcadIntegration.Server.ColumnName.Version")%></th>
		  <!--XSSOK-->
          <th nowrap="nowrap"><%=integSessionData.getStringResource("mcadIntegration.Server.ColumnName.Type")%></th>
		  <!--XSSOK-->
          <th nowrap="nowrap"><%=integSessionData.getStringResource("mcadIntegration.Server.ColumnName.State")%></th>
		  <!--XSSOK-->
          <th nowrap="nowrap"><%=integSessionData.getStringResource("mcadIntegration.Server.ColumnName.Description")%></th>
		  <!--XSSOK-->
		  <th nowrap="nowrap"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Baseline")%></th>
          <th>&nbsp;</th>
      </tr>
<%     
    if (list.size() > 0)
    {  
%>
    <!--XSSOK-->
	<fw:mapListItr mapList="<%= revisionsList %>" mapName="revMap">
<%
		String sObjName = (String)revMap.get(bo.SELECT_NAME);
		String sObjId = (String)revMap.get(bo.SELECT_ID);

		String typeIcon = UINavigatorUtil.getTypeIconProperty(context, application, (String)revMap.get(bo.SELECT_TYPE));
		
		BusinessObject thisBO = new BusinessObject(sObjId);
		thisBO.open(context);
		boolean bFinalized = serverGeneralUtil.isBusObjectFinalized(context,thisBO);
		thisBO.close(context);

	    HashMap paramMap = new HashMap();
	    MapList objectList = new MapList();
	    HashMap objDetails = new HashMap();
	    //String checkoutObjectDetails[] = serverGeneralUtil.getValidObjctIdForCheckout(sObjId);
	  
	    //String validObjectId   = checkoutObjectDetails[1];
   
	    //objDetails.put("id", validObjectId);
		objDetails.put("id", sObjId);
	    objectList.add(objDetails);
	    paramMap.put("objectList", objectList);
	    Vector ret = (Vector)JPO.invoke(context, "DSCShowViewerLink", null, "getHtmlString", JPO.packArgs(paramMap), Vector.class);
		StringBuffer htmlForViewerLink = new StringBuffer(300);

		for (int i = 0; i < ret.size(); i++){
			  String html = (String)ret.elementAt(i);
			  htmlForViewerLink.append(html);
		}

		String makeBold = "";
		if(bFinalized) 
			makeBold = " style=\"font-weight:bold\"";
%>      
          <!--XSSOK-->
          <tr class='<fw:swap id="even"/>' <%=makeBold%>>
<%      
			String URLForInsert =  objectDetailsPageName + "?objectId=" + sObjId +"&mode=insert&jsTreeID=" + jsTreeID + "&emxSuiteDirectory=" + suiteDirectory;
			String URLForPopup	=  objectDetailsPageName + "?objectId=" + sObjId +"&mode=popup&jsTreeID=" + jsTreeID + "&emxSuiteDirectory=" + suiteDirectory;

            String target = " target=\"content\"";
%>      
            <td>
			<!--XSSOK-->
			<input type = checkbox name="list" value="<%= sObjId %>" onClick = "parent.changeNodeSelection()" ></td>
            <td>
			  <!--XSSOK-->
              <a href="<%=URLForInsert%>" <%=target%>><img src="<%=appName%>/common/images/<%=typeIcon%>" border="0" align="middle"></a>
			  <!--XSSOK-->
              <a href="<%=URLForInsert%>" <%=target%>><%=sObjName%></a>
            </td>
        
		    <!--XSSOK-->
            <td><%=revMap.get(bo.SELECT_REVISION)%>&nbsp;</td> 
			<!--XSSOK-->
            <td><%=revMap.get(bo.SELECT_TYPE)%>&nbsp;</td> 
			<!--XSSOK-->
            <td><%=revMap.get(bo.SELECT_CURRENT)%>&nbsp;</td>
			<!--XSSOK-->
            <td><%=revMap.get(bo.SELECT_DESCRIPTION)%>&nbsp;</td>
			<!--XSSOK-->
			<td><%=revMap.get(SELECT_ATTR_MCAD_LABEL)%>&nbsp;</td>
            <td>
			    <!--XSSOK-->
				<a href="../integrations/IEFMultipleCheckout.jsp?action=checkout&amp;Target Location=hiddenFrame&amp;integrationName=<%=integrationName%>&amp;emxTableRowId=<%=sObjId%>&amp;" target="listHidden" ><img src="../iefdesigncenter/images/iconActionCheckOut.gif" border="0" title="<%=integSessionData.getStringResource("mcadIntegration.Server.AltText.Checkout")%>"/></a>
				<!--XSSOK-->
				<a href="../integrations/IEFMultipleCheckout.jsp?action=checkout&amp;Target Location=hiddenFrame&amp;integrationName=<%=integrationName%>&amp;emxTableRowId=<%=sObjId%>&amp;LaunchCADTool=false" target="listHidden" ><img src="../iefdesigncenter/images/iconActionQuickCheckOut.gif" border="0" title="<%=integSessionData.getStringResource("mcadIntegration.Server.AltText.QuickCheckout")%>"/></a>
				<!--XSSOK-->
				<a href="javascript:showNonModalDialog('<%=URLForPopup%>',700,600)"><img src="<%=appName%>/common/images/iconActionNewWindow.gif" border="0"/></a>
				<!--XSSOK-->
				<%=htmlForViewerLink.toString()%>
			</td>
        <%			
			String strMcadLabelObjId	= revMap.get(SELECT_ATTR_MCAD_LABEL) + "-" + sObjId;
			String strMcadId			= "mcad" + "-" + sObjId;
		%>
            
			<input type="hidden" name ="mcadlabelStr" id = "<%=strMcadId%>" value="<%=strMcadLabelObjId%>">
          </tr>
	</fw:mapListItr>
<%
		}
	}
	catch (Exception e)
	{
		errorMessage = e.getMessage();
	}
%>
      </table>
<%@include file = "MCADBottomErrorInclude.inc"%>
<%
	if (!"".equals(errorMessage.trim()))
	{
%>
    <!--XSSOK-->
	<link rel="stylesheet" href="<%=appName%>/emxUITemp.css" type="text/css">
	&nbsp;
      <table width="90%" border=0  cellspacing=0 cellpadding=3  class="formBG" align="center" >
        <tr >
		  <!--XSSOK-->
          <td class="errorHeader"><%=serverResourceBundle.getString("mcadIntegration.Server.Heading.Error")%></td>
        </tr>
        <tr align="center">
		  <!--XSSOK-->
          <td class="errorMessage" align="center"><%=errorMessage%></td>
        </tr>
      </table>
<%
	}
%>
</form>
</body>
</html>

