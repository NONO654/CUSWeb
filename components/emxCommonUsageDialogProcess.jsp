<%-- emxCommonUsageDailogProcess.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonUsageDialogProcess.jsp.rca 1.4.7.5 Wed Oct 22 16:17:56 2008 przemek Experimental przemek $ 
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@ page import = "com.matrixone.apps.common.Download"%>

<%
	String strRelId = emxGetParameter(request, "relId");

	if(strRelId == null || "".equals(strRelId) || "null".equals(strRelId))
	{
		String strDocumentId = emxGetParameter(request, "documentId");
		String strPartId = emxGetParameter(request, "trackUsagePartId");

		int iSuccess = Download.createUsage(context, strDocumentId, strPartId, getUsageAttributeMap(request));
		if(iSuccess != 0)
		{
			throw new Exception(com.matrixone.apps.common.util.ComponentsUtil.i18nStringNow("emxComponents.Download.UsageException",  request.getHeader("Accept-Language")));
		}
	}else
	{
		DomainRelationship.setAttributeValues(context, strRelId, getUsageAttributeMap(request));
	}
	
	String strDownloadForwardURL = emxGetParameter(request,"downloadForwardURL");
	String strDocIds = emxGetParameter(request,"docIds");
	
	if(strDocIds != null && strDocIds.indexOf("|") != -1)
	{
		strDownloadForwardURL = "../components/emxCommonUsageDialogFS.jsp?downloadForwardURL="+strDownloadForwardURL+"&documentId="+strDocIds+"&trackUsagePartId="+ emxGetParameter(request,"trackUsagePartId");
		strDownloadForwardURL += "&docIds="+emxGetParameter(request,"docIds");
		strDownloadForwardURL += "&refreshContent="+emxGetParameter(request,"refreshContent");
	}

	if(strDownloadForwardURL == null)
	{

		%>
		<script>
		<%
		if(!"false".equals(emxGetParameter(request,"refreshContent")))
		{
			%>
			getTopWindow().getWindowOpener().parent.location.reload();
			<%
		}
		%>
			window.closeWindow();
		</script>

		<%
	}else
	{
		%>
 <form name="commonUsageDialogProcess" method="post" action="<%=XSSUtil.encodeForHTMLAttribute(context,strDownloadForwardURL)%>">
  <table>
    <input type="hidden" name="trackUsagePartId" value="<%=XSSUtil.encodeForHTMLAttribute(context, emxGetParameter(request,"trackUsagePartId"))%>" />
    <input type="hidden" name="docIds" value="<%=XSSUtil.encodeForHTMLAttribute(context, emxGetParameter(request,"docIds"))%>" />
    <input type="hidden" name="refreshContent" value="true" />
  </table>
</form>
<script type="text/javascript" language="JavaScript">
		    document.forms['commonUsageDialogProcess'].submit();
		    window.closeWindow();
			//getTopWindow().window.resizeTo(730, 520);	
			//document.location.href="<%=strDownloadForwardURL%>&trackUsagePartId=<%=emxGetParameter(request,"trackUsagePartId")%>&docIds=<%=emxGetParameter(request,"docIds")%>&refreshContent=true";
		</script>
		<%
	}

%>
<%!
	public static String trim(String str)
	{
		return str ==  null ? "": str.trim();
	}

	public static Map getUsageAttributeMap(HttpServletRequest request)
	{
		Map mapAttr = new HashMap(2);
		mapAttr.put(Download.ATTRIBUTE_DOWNLOAD_PURPOSE, trim(request.getParameter("txtPurpose")));
		mapAttr.put(Download.ATTRIBUTE_STATE_OF_USAGE, trim(request.getParameter("selStateOfUsage")));
		return mapAttr;
	}
%>
