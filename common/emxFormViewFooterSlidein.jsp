<%-- emxFormViewFooterSlidein.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormEditFooter.jsp.rca 1.11 Wed Oct 22 15:48:50 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%> 
<%
    String suiteKey        = Request.getParameter(request, "suiteKey");
    String sRegDir         = Request.getParameter(request, "RegisteredDirectory");
    String registeredSuite = "";

        if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
        registeredSuite = suiteKey.substring(13);

   String stringResFileId = UINavigatorUtil.getStringResourceFileId(context, registeredSuite);
   if(stringResFileId == null || stringResFileId.length()==0)
      stringResFileId="emxFrameworkStringResource";

    String strLanguage = request.getHeader("Accept-Language");
    String helpDone= EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), "emxFramework.FormComponent.Done");
    String helpCancel= EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), "emxFramework.FormComponent.Cancel");

    String form = Request.getParameter(request, "form");
    String targetLocation = emxGetParameter(request, "targetLocation");
    String title_prefix = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.WindowTitle.Footer", new Locale(strLanguage));
    String title = title_prefix + form;
%>
<table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
<tr>
<td align="right">
<table border="0" cellspacing="0">
<tr>
<!--  <td><div id="cancelImage"><a href="javascript:getTopWindow().closeSlideInDialog();"><img src="images/buttonDialogCancel.gif" border="0" alt="<%=helpCancel%>" /></a></div></td>-->
<td><div id="cancelText"><a class="button" onclick="closeSlideinWindow(getTopWindow())"
href="javascript:void(0)"><button class="btn-default" type="button"> <%=helpCancel%></button></a></div></td>
</tr>
</table>
</td>
</tr>
</table>
