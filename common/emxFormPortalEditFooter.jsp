<%-- emxFormEditFooter.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxFormPortalEditFooter.jsp.rca 1.6 Wed Oct 22 15:48:10 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxFormConstantsInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>

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
    String helpDone=EnoviaResourceBundle.getProperty(context, stringResFileId, "emxFramework.FormComponent.Done", new Locale(strLanguage));
    String helpCancel=EnoviaResourceBundle.getProperty(context, stringResFileId, "emxFramework.FormComponent.Cancel", new Locale(strLanguage));

    String form = Request.getParameter(request, "form");
    String title_prefix = EnoviaResourceBundle.getProperty(context, stringResFileId, "emxFramework.WindowTitle.Footer", new Locale(strLanguage));
    String title = title_prefix + form;
%>
<html>
<head>
<STYLE TYPE="text/css" MEDIA=screen>
<!--
a {
        color: #000000; text-decoration: none;
}

a:hover {color: #FFFFFF;text-decoration: none;}
-->
</STYLE>
<!-- //XSSOK -->
<title><xss:encodeForHTML><%=title%></xss:encodeForHTML></title>
<script language="JavaScript" src="scripts/emxUICoreMenu.js"></script>
<script language="JavaScript" src="scripts/emxUIActionbar.js"></script>
<script language="JavaScript" src="scripts/emxUIModal.js"></script>
<script language="JavaScript" src="scripts/emxUIPopups.js"></script>
<script language="javascript" src="scripts/emxUIFormUtil.js"></script>
<script type="text/javascript">
        addStyleSheet("emxUIDefault");
        addStyleSheet("emxUIDialog");
        addStyleSheet("emxUIChannelDefault");
        addStyleSheet("emxUIChannelActionbar");
</script></head>

<body>
<div style="border-top: 1px solid #666666; border-bottom:1px solid #666666; background-image: url(images/utilChActionbarBG.gif); height: 25px; text-align: right ">
  <table border="0" cellspacing="0" cellpadding="3">
    <tr>
      <td id="abc" style=" border-left: 1px solid #666666; border-top: 1px solid #FFFFFF">
      <a class="leftNavLink" href="javascript:;" onClick="saveChanges()" onMouseOver="abc.style.backgroundColor='#9a9a9a'" onMouseOut="abc.style.backgroundColor=''">
      <img src="images/utilWorkflowApproved.gif" width="16" height="16" border="0" align="absmiddle" />
          <img src="images/utilSpacer.gif" width="5" height="5" border="0" align="absmiddle" /><%=helpDone%>
          <img src="images/utilSpacer.gif" width="15" height="5" border="0" align="absmiddle" />
      </a></td>
    </tr>
  </table>
</div>
</body>
</html>
