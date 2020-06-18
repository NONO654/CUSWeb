<%-- emxFormEditFooter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormEditFooter.jsp.rca 1.11 Wed Oct 22 15:48:50 2008 przemek Experimental przemek $
--%>

<%-- @quickreview T25 OEP 21 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags and tag Lib are included--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>  
<%
    String suiteKey        = Request.getParameter(request, "suiteKey");
    String sRegDir         = Request.getParameter(request, "RegisteredDirectory");
    String registeredSuite = "";

        if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
        registeredSuite = suiteKey.substring(13);

   String stringResFileId = UINavigatorUtil.getStringResourceFileId(context,registeredSuite);
   if(stringResFileId == null || stringResFileId.length()==0)
      stringResFileId="emxFrameworkStringResource";

    String strLanguage = request.getHeader("Accept-Language");
    String helpDone=EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(), "emxFramework.FormComponent.Done");
    String helpCancel=EnoviaResourceBundle.getProperty(context, stringResFileId, context.getLocale(), "emxFramework.FormComponent.Cancel");

    String form = Request.getParameter(request, "form");
	String title = "footer_" + form;
%>
<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
<tr>
<td align="right">
<table border="0" cellspacing="0">
<tr>
<td><a href="javascript:;" onClick="submitPage()" class="button"><button class="btn-primary" type="button"><xss:encodeForHTML><%=helpDone%></xss:encodeForHTML></button></a></td>
<td>&nbsp;&nbsp;</td>
<td><div id="cancelText"><a href="javascript:doCancel()" class="button"><button class="btn-default" type="button"><xss:encodeForHTML><%=helpCancel%></xss:encodeForHTML></button></a></div></td>
</tr>
</table>
</td>
</tr>
</table>
