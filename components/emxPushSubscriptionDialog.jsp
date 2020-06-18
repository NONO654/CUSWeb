<%-- emxPushSubscriptionDialog.jsp
   Copyright (c) 2000-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPushSubscriptionDialog.jsp.rca 1.1.7.5 Wed Oct 22 16:18:53 2008 przemek Experimental przemek $
--%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<html>
<head>
<%
    StringBuffer sfb = new StringBuffer();
    boolean appendAmp = false;
    Enumeration enumParamNames = request.getParameterNames();
    while(enumParamNames.hasMoreElements()) {
        String paramName = (String) enumParamNames.nextElement();
        String paramValue = request.getParameter(paramName);

        if(paramValue != null && !"null".equals(paramValue) && !"".equals(paramValue)) {
            if(appendAmp)
                sfb.append("&");
            else
                appendAmp = true;

            sfb.append(paramName);
            sfb.append("=");
            sfb.append(paramValue);
        }
    }

    String objectId = emxGetParameter(request, "objectId");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String strHelpMarker = emxGetParameter(request,"HelpMarker");
    String strLanguage = request.getHeader("Accept-Language");
    String helpCancel= EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(), "emxComponents.Button.Close"); 
    String pageHeader = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(), "emxComponents.PushSubscription.PageHeader"); 
    pageHeader = UINavigatorUtil.parseHeader(context, pageContext, pageHeader, objectId, "Framework", strLanguage);
    if(pageHeader == null || pageHeader.trim().length() == 0)
    {
        pageHeader = "Push Subscription";
    }
%>

  <title><%=XSSUtil.encodeForHTML(context, pageHeader) %></title>

  <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
  <script language="javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
  <script language="JavaScript" type="text/JavaScript">
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIDOMLayout");
    addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIMenu");
    addStyleSheet("emxUIDialog");  
  </script>
  <%@include file = "../emxStyleDefaultInclude.inc"%>
  <%@include file = "../emxStyleDialogInclude.inc"%>

  <script language="javascript">
    function windowClose()
    {
        window.closeWindow();
    }

  </script>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</head>

<body class="dialog">
    <div id="pageHeadDiv">
        <table>
            <tr>
                <td class="page-title">
                    <h2><%=XSSUtil.encodeForHTML(context,pageHeader)%></h2>
                </td>
            </tr>
        </table>    
        <jsp:include page = "../common/emxToolbar.jsp" flush="true">
            <jsp:param name="toolbar" value=""/>
            <jsp:param name="objectId" value="<%=objectId%>"/>
            <jsp:param name="suiteKey" value="<%=suiteKey%>"/>
            <jsp:param name="PrinterFriendly" value="false"/>
            <jsp:param name="export" value="false"/>
            <jsp:param name="helpMarker" value="<%=strHelpMarker%>"/>
        </jsp:include>
    </div>

    <div id="divPageBody" style="top: 79px">
        <div style="height: 99%">
          <iframe name="pushsubscriptionframe" src="emxPushSubscriptionBody.jsp?<%=XSSUtil.encodeURLwithParsing(context, sfb.toString())%>" width="100%" height="100%"  frameborder="0" border="0"></iframe>
          <iframe class="hidden-frame" name="formEditHidden" src="emxBlank.jsp" HEIGHT="0" WIDTH="0"></iframe>
        </div>
    </div>

    <div id="divPageFoot">
        <div id="divDialogButtons">
          <table width="100%" border="0" align="center" cellspacing="2" cellpadding="3">
              <tr>
                  <td align="right">
                      <table border="0" cellspacing="0">
                          <tr>
                              <td><div id="cancelImage"><a onclick="javascript:getTopWindow().closeWindow()"><button class="btn-default"><%=XSSUtil.encodeForHTML(context, helpCancel)%></button></a></div></td>
                          </tr>
                      </table>
                  </td>
              </tr>
          </table>
        </div>
    </div>
</body>
</html>
