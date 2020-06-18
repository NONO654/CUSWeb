<%-- emxFormEditFooter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormEditFooter.jsp.rca 1.11 Wed Oct 22 15:48:50 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>
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
    String resetForm = emxGetParameter(request, "resetForm");
    String hideCancel = emxGetParameter(request, "hideCancel");
    String helpDone= EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), "emxFramework.FormComponent.Done");
    String helpCancel= EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage),"emxFramework.FormComponent.Cancel");
	String helpReset = EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), "emxFramework.FreezePane.Action.Reset");

    String isSelfTargeted="";
    String mode = Request.getParameter(request, "mode");
    if(mode != null && "edit".equalsIgnoreCase(mode)){
    	isSelfTargeted = XSSUtil.encodeForJavaScript(context,Request.getParameter(request, "isSelfTargeted"));
    }
    String form = Request.getParameter(request, "form");
    String targetLocation = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "targetLocation"));
    String title_prefix = EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), "emxFramework.WindowTitle.Footer");
	String title = title_prefix + form;
	String portalMode = XSSUtil.encodeForJavaScript(context,emxGetParameter(request, "portalMode"));
    String strDoneImageScr = "images/buttonDialogDone.gif";
    String strSubmitLabel = emxGetParameter(request, "submitLabel");
    
    //To modify the label for Done as Apply, in case where 'submitLabel' parameter is passed. 
    if(null != strSubmitLabel && "Apply".equals(strSubmitLabel))
    {
    	helpDone = EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), "emxFramework.FreezePane.Apply");
    	strDoneImageScr = "images/buttonDialogApply.gif";
    } else if (null != strSubmitLabel) {
    	helpDone = EnoviaResourceBundle.getProperty(context, stringResFileId, new Locale(strLanguage), strSubmitLabel);
    }
%>
<table>
<tr>
<td class="functions">
</td>
<td class="buttons">
	<table>
<tr>
<!-- //XSSOK -->
<td><a class="footericon" href="javascript:;" onClick="submitPage('<%=targetLocation%>')"><img src="<%=strDoneImageScr%>" border="0" alt="<%=helpDone%>" /></a></td>
<td><a href="javascript:;" onClick="submitPage('<%=targetLocation%>')" class="button"><button class="btn-primary" type="button"><%=helpDone%></button></a></td>
<%
if(null == hideCancel && !"true".equals(hideCancel))
{
%> 
<td><a class="footericon" onClick="doCancel('<%=targetLocation%>', '<%=isSelfTargeted %>', '<%=portalMode %>')"><img src="images/buttonDialogCancel.gif" border="0" alt="<%=helpCancel%>" /></a></td>
<td><a onClick="doCancel('<%=targetLocation%>', '<%=isSelfTargeted %>', '<%=portalMode %>')" class="button"><button class="btn-default" type="button"><%=helpCancel%></button></a></td>
<%
}
%>
<% 
if("true".equals(resetForm))
{
%>
<td><a class="footericon" href="javascript:doReset()"><img src="images/buttonDialogRefresh.gif" border="0" alt="<%=helpDone%>" /></a></td>
<td><a href="javascript:doReset()" class="button"><button class="btn-default" type="button"><%=helpReset%></button></a></td>
<% 
}
%> 
</tr>
</table>
</td>
</tr>
</table>
