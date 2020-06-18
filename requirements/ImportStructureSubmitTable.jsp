<%--  SpecificationCreateFS.jsp
   FrameSet page for Create Requirement Specification dialog

   Copyright (c) 2008-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under 
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
     @quickreview T25 DJH 18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
     @quickreview HAT1 ZUD 20 Jul 2017  IR-512136-3DEXPERIENCER2018x: R419-FUN055837: In "Import from Existing" prefix field should not be mandatory.
     @quickreview HAT1 ZUD 31 Oct 2017 IR-559728-3DEXPERIENCER2018x: R419-STP: For Partial Structure duplication  "Duplication string" is not getting apply to duplicated Req objects.
--%>
<%@page import="com.dassault_systemes.requirements.ReqConstants"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxProductVariables.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%!
	String getCopyWithLinkParameter(String[] tokens)
	{
		String CopyWithLink  = "false";
		for(int i = 0; i < tokens.length; i++)
		{
			if(tokens[i].contains(ReqConstants.COPY_WITH_LINK))
			{
				String Values[] = tokens[i].split(":");
				CopyWithLink = Values[1];
			}
		}
		return CopyWithLink;
	}

String getFromWebAppParameter(String[] tokens)
{
  String isFromWebApp  = "false";
  for(int i = 0; i < tokens.length; i++)
  {
    if(tokens[i].contains(ReqConstants.FROM_WEB_APP))
    {
      String Values[] = tokens[i].split(":");
      isFromWebApp = Values[1];
    }
  }
  return isFromWebApp;
}

	String getCopyAndRefOptions(String[] tokens)
	{
		String splittedOption;
		String RefCopyObjects = "";
		for(int i = 0;i<tokens.length;i++)
		{
			if(tokens[i].contains("Reference")||tokens[i].contains("Copy"))
			{
				RefCopyObjects += tokens[i].split(":")[0] + ",";
			}
		}
		return RefCopyObjects;
	}
%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
	String objectId = emxGetParameter(request,"emxTableRowId");
 %>
<html>
<head>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" type="text/javaScript">
	
	var url = "ImportStructureTriStateFS.jsp?"
	url += "options=" + "<xss:encodeForJavaScript><%=emxGetParameter(request,"options")%></xss:encodeForJavaScript>";
	<%
//START : LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
	String isCopyReqSpec = (emxGetParameter(request,"copyReqSpec")==null)?"false":emxGetParameter(request,"copyReqSpec");
//END : LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
	String[] tokens = emxGetParameter(request,"options").split("[;]");
	PropertyUtil.setGlobalRPEValue(context, ReqConstants.COPY_WITH_LINK, getCopyWithLinkParameter(tokens));
	PropertyUtil.setGlobalRPEValue(context, ReqConstants.FROM_WEB_APP, getFromWebAppParameter(tokens));
	PropertyUtil.setAdminProperty(context, PersonUtil.personAdminType, context.getUser(), "RefCopyObjects", getCopyAndRefOptions(tokens));
	%>
	url += "&emxTableRowId=" + "<xss:encodeForJavaScript><%=emxGetParameter(request,"emxTableRowId")%></xss:encodeForJavaScript>";
	<%
		// ++ HAT1 ZUD: IR-512136-3DEXPERIENCER2018x fix ++
		String perfixValue = "";
		if(emxGetParameter(request,"prefix") == null || "null".equalsIgnoreCase(emxGetParameter(request,"prefix")))
		{
			perfixValue = "";
		}
		else
		{
			perfixValue = (String)emxGetParameter(request,"prefix");
		}
 		// -- HAT1 ZUD: IR-512136-3DEXPERIENCER2018x fix --
	%>	
	url += "&prefix=" + "<xss:encodeForJavaScript><%=perfixValue%></xss:encodeForJavaScript>";
//START : LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
	url += "&copyReqSpec=" + "<%=isCopyReqSpec%>";
//END : LX6 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications

	//getTopWindow().document.location.href = url; //this causes firefox to hang.
function loadPage()
{
	getTopWindow().location.href = encodeURI(url);
}	
	  	
</script>
</head>
<body onload="loadPage()">
</body>
</html>
