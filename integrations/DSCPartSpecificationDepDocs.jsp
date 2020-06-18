<%--  DSCPartSpecificationDepDocs.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>


<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<html>
<head>
<%
MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData)session.getAttribute("MCADIntegrationSessionDataObject");
Context context								= integSessionData.getClonedContext(session);

%>


<%
	String objectID			 =Request.getParameter(request,"objectId");
	String sSuiteKey		 =Request.getParameter(request,"suiteKey");
	String errorMessage		 = "";
	
	StringList cadlist   =   null;

//	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute(MCADServerSettings.MCAD_INTEGRATION_SESSION_DATA_OBJECT);
	
	String acceptLanguage						  = request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle = new MCADServerResourceBundle(acceptLanguage);

	if(integSessionData == null)
	{
        errorMessage = serverResourceBundle.getString("mcadIntegration.Server.Message.ServerFailedToRespondSessionTimedOut");
	}
	else
	{
//		Context context	= integSessionData.getClonedContext(session);
		MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

		try
		{
			BusinessObject partObj  = new BusinessObject(objectID);
			partObj.open(context);

			String relDirection			= "from";
			String relnshipName			= util.getActualNameForAEFData(context, "relationship_PartSpecification");
			BusinessObjectList busList  = util.getRelatedBusinessObjects(context, partObj, relnshipName, relDirection);
			
			//IR-460641: Drawing derived outputs not visible under EC Part
			int cadsize = busList.size();
			Iterator itr1 =busList.iterator();
			cadlist = new StringList(cadsize);
			String cadobjectID;
			Boolean result=false;
			while(itr1.hasNext()){
				BusinessObject cadObj=(BusinessObject)itr1.next();
				cadobjectID	= cadObj.getObjectId(context);
				result= cadlist.add(cadobjectID);			
			}	

			if(busList != null && !busList.isEmpty())
			{
				BusinessObject cadObj	= (BusinessObject) busList.firstElement();
				objectID				= cadObj.getObjectId(context);
			}

			partObj.close(context);
		}
		catch(Exception e)
		{
			errorMessage = e.getMessage();
		}
	}
%>


</head>
<body>
<form name="derivedOutputForm" action="DSCDerivedOutput.jsp" method="post">

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

    <!--XSSOK-->
   <input type="hidden" name="objectId" value="<%= objectID %>">
   
   <!-- IR-460641: Drawing derived outputs not visible under EC Part -->
   <input type="hidden" name="cadlist" value="<%= cadlist %>">

<% if (null != sSuiteKey) { %>
    <!--XSSOK-->
    <input type="hidden" name="suiteKey" value="<%=sSuiteKey%>">
<% } %>
</form>


<%
	if ("".equals(errorMessage.trim()))
	{
%>
	<SCRIPT LANGUAGE="JavaScript">
		document.derivedOutputForm.submit();
	</SCRIPT>
<%
	} else {
%>
	<link rel="stylesheet" href="../emxUITemp.css" type="text/css">
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
</body>
</html>
