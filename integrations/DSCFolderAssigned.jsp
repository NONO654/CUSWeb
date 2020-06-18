<%--  DSCFolderAssigned.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>

<html>
<head>
<script language="JavaScript">

<%@include file = "IEFTreeTableInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

</script>
<%
	String nodeId		= emxGetParameter(request,"nodeId");
	String encodedTNR	= emxGetParameter(request, "tnr");
	String type			= "";
	String name			= "";
	String revision		= "";
	String design				= "";
	String nameDisplayed		= "";
	String revisionDisplayed	= "";
	
	
	String integrationName					= "";
	String headerString						= "";
	String actualObjectIDToWork				= "";
	String headerCurrentFolderAssigned		= "";
	String headerFolderType					= "";

	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String acceptLanguage = request.getHeader("Accept-Language");

	if(integSessionData == null)
	{
	     MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

         String errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	     emxNavErrorObject.addMessage(errorMessage);
	}
	else
	{
		 design				= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Design");
		 nameDisplayed		= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.ColumnName.Name");
		 revisionDisplayed	= integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.FieldName.Revision");
		
         MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);
	     MCADMxUtil util	= new MCADMxUtil(integSessionData.getClonedContext(session), integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	    
	     headerCurrentFolderAssigned = serverResourceBundle.getString("mcadIntegration.Server.Title.CurrentFolderAssigned");
	     headerFolderType = serverResourceBundle.getString("mcadIntegration.Server.Title.FolderType");
	}
      
      
      String[] init = new String[] {};
      String jpoName = "DSCFolderUtil";
      String jpoMethod = "getObjectAssignedFolders";
      HashMap paramMap = new HashMap();
      //System.out.println("+++ object ID = " + objectID); 
      	
      Context context = null;
      MapList assignedFoldersList = null;
      try
      {
          context =  Framework.getFrameContext(session); 
          String tnr = encodedTNR;
          StringTokenizer tokenizer = new StringTokenizer(tnr, "|");
         
          if (tokenizer.hasMoreTokens())
             type = tokenizer.nextToken();
          if (tokenizer.hasMoreTokens())
             name = MCADUrlUtil.hexDecode(tokenizer.nextToken());
          if (tokenizer.hasMoreTokens())
             revision = tokenizer.nextToken();
          if (false == revision.equals("--"))
          {
               BusinessObject bus = new BusinessObject(type, name, revision, "");
          
               bus.open(context);
               bus.close(context);
               paramMap.put(DomainObject.SELECT_ID, bus.getObjectId());
               paramMap.put("LocaleLanguage", acceptLanguage);
               assignedFoldersList = (MapList)JPO.invoke(context, 
                                                        jpoName, 
                                                        init, jpoMethod, 
                                                        JPO.packArgs(paramMap),
                                                        MapList.class);
          }
      }
      catch (Exception e)
      {
          System.out.println("DSCFolderAssigned: " + e.toString());
      }
      
%>
<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>


<body>
<form name="folderAssignedForm" action="../common/emxTable.jsp">

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


    <input type="hidden" name="program" value="DSCFolderUtil:getObjectAssignedFolders">
	<input type="hidden" name="table" value="DSCAssignedFolders">
	<input type="hidden" name="pagination" value="10">
	<input type="hidden" name="headerRepeat" value="10">
	<input type="hidden" name="sortColumnName" value="">
	<input type="hidden" name="Sortdirection" value="descending">
	<input type="hidden" name="targetLocation" value="content">
	<input type="hidden" name="selection" value="multiple">
	<input type="hidden" name="topActionbar" value="">
<table border="0" width="100%">
      <tr>
         <td width="30%">
	     <!--XSSOK-->
             <b><%=design%></b>
         </td>
         <td width="70%">
             <xss:encodeForHTML><%=type%></xss:encodeForHTML>
         </td>
      </tr>
      <tr>
         <td width="30%">
	     <!--XSSOK-->
             <b><%=nameDisplayed%></b>
         </td>
         <td width="70%">
             <xss:encodeForHTML><%=name%></xss:encodeForHTML>
         </td>
      </tr>
      <tr>
         <td width="30%">
             <!--XSSOK-->
             <b><%=revisionDisplayed%></b>
         </td>
         <td width="70%">
            <xss:encodeForHTML><%=revision%></xss:encodeForHTML> 
         </td>
      </tr>
      <tr>
         <td>&nbsp</td>
      </tr>
</table>
<table border="0" width="100%" cellpadding="0" cellspacing="0">
      <tr>
         <th>
             <!--XSSOK-->
             <%=headerCurrentFolderAssigned%>
         </th>
         <th>
             <!--XSSOK-->
             <%=headerFolderType%>
         </th>
      </tr>
      <tr>
         <td class="listCell" valign="top">&nbsp;</td>
         <td class="listCell" valign="top">&nbsp;</td>
      </tr>
<% if (null != assignedFoldersList && assignedFoldersList.size() > 0) { 
      String path = "";
      //System.out.println("+++ assigned folder size = " + assignedFoldersList.size());
      for (int i = 0; i < assignedFoldersList.size(); i++)
      {
         
          HashMap objectDetails = (HashMap)assignedFoldersList.get(i);
          String folderType = (String)objectDetails.get(DomainObject.SELECT_TYPE);
          path = (String)objectDetails.get(DomainObject.SELECT_NAME);
          //System.out.println("+++ path = " + path);
          if (null == path || 0 == path.length()) continue;
%>
          
          <tr>
	     <!--XSSOK-->
             <td class="listCell" valign="top"><%= path %></td>
             <!--XSSOK-->
             <td class="listCell" valign="top"><%= folderType %></td>
          </tr>
<%
      }
    } %>	
</table>
</form>

<%@include file = "MCADBottomErrorInclude.inc"%>

<%
	if ((emxNavErrorObject.toString()).trim().length() == 0)
	{
%>
	<SCRIPT LANGUAGE="JavaScript">
           // document.folderAssignedForm.submit();
	</SCRIPT>
<%
	}
%>

</body>
</html>
