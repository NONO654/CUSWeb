<%-- emxComponentsCheckout.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsCheckout.jsp.rca 1.18 Wed Oct 22 16:17:54 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file="emxComponentsNoCache.inc"%>
<%@ include file="emxComponentsUtil.inc"%>

<link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css"/>
<html>
<head>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
</head>
<body>

<%

  DomainObject domainObj = DomainObject.newInstance(context);

  String objectId = emxGetParameter(request, "objectId");
  String action = emxGetParameter(request,"action");
  String refreshStr = emxGetParameter(request,"refresh");
  String strFileFormat = emxGetParameter(request,"format");
  String strFileName = emxGetParameter(request,"fileName");
  String appName = emxGetParameter(request,"appName");
  String appDir = emxGetParameter(request,"appDir");
  String closeWindow = emxGetParameter(request, "closeWindow");
  String sLock = "false";

  if ( action == null )
  {
      action = "";
  }

  if ( closeWindow == null || "".equals(closeWindow) || "null".equals(closeWindow) )
  {
      closeWindow = "true";
  }

  boolean refresh = "true".equalsIgnoreCase(refreshStr);
  if ( refreshStr == null || "".equals(refreshStr) || "null".equals(refreshStr) )
  {
     refresh = true;
  }

  int interval = session.getMaxInactiveInterval();
  int maxInterval = Integer.parseInt((String)EnoviaResourceBundle.getProperty(context,"emxFramework.ServerTimeOutInSec"));
  if ( interval != maxInterval )
  {
    session.setMaxInactiveInterval(maxInterval);
    session.setAttribute("InactiveInterval", new Integer(interval));
  }

  domainObj.setId(objectId);
  //domainObj.open(context);
  StringList selectList = new StringList(2);
  selectList.add(domainObj.SELECT_FILE_NAME);
  selectList.add(domainObj.SELECT_FILE_FORMAT);
  selectList.add(domainObj.SELECT_TYPE);
  Map documentInfo = domainObj.getInfo(context, selectList);

//Modified for bug 316630
  StringList  fileNames = (StringList)documentInfo.get(domainObj.SELECT_FILE_NAME);
  StringList  formatNames = (StringList)documentInfo.get(domainObj.SELECT_FILE_FORMAT);
  if (formatNames != null && formatNames.size() > 0 && fileNames != null && fileNames.size() > 0 )
  {
    if ( strFileName == null || "".equals(strFileName) || "null".equals(strFileName) )
    {
        if ( strFileFormat == null || "".equals(strFileFormat) || "null".equals(strFileFormat) )
        {
            strFileFormat = (String)formatNames.get(0);
            strFileName = (String)fileNames.get(0);
        }
        else
        {
            int fileIndex = formatNames.indexOf(strFileFormat);
            if(fileIndex!=-1)
            {
                strFileName = (String)fileNames.get(fileIndex);
            }
        }
    }
    else if ( strFileFormat == null || "".equals(strFileFormat) || "null".equals(strFileFormat) )
    {
        int formatIndex = fileNames.indexOf(strFileName);
        if(formatIndex!=-1)
        {
            strFileFormat = (String)formatNames.get(formatIndex);
        }
    }
  }
//End of modification for bug 316630
  String objType = (String)documentInfo.get(domainObj.SELECT_TYPE);
  if("view".equals(action))
  {
%>
      <form name="viewer" action="emxComponentsViewerLaunch.jsp" >
        <table>
          <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="fileName" value="<xss:encodeForHTMLAttribute><%=strFileName%></xss:encodeForHTMLAttribute>" />
          <input type="hidden" name="format" value="<xss:encodeForHTMLAttribute><%=strFileFormat%></xss:encodeForHTMLAttribute>" />
        </table>
      </form>
      <script language="javascript">
        document.viewer.submit();
      </script>

<%
  }

  if("checkout".equals(action)) {
    domainObj.lock(context);
  }

  String errorPage = "/"+ appDirectory +"/emxComponentsError.jsp";
  Map checkoutMap = new HashMap();
  String target = "";
  if ( action.equals("download") ||  action.equals("checkout") ) {
    checkoutMap = DocumentUtil.getFileStreamURL(context,request,response,domainObj,strFileName,strFileFormat, errorPage, false);
    if ( "true".equals(closeWindow) )
    {
      //target = "hiddenFrame";
    }
  } else {
    checkoutMap = DocumentUtil.getFileViewURL(context,request,response,domainObj,strFileName,strFileFormat, errorPage, false);
  }

  String actionURL = (String)checkoutMap.remove("action");
  String jobTicket = (String)checkoutMap.remove("jobTicket");
  String ticket = (String)checkoutMap.remove("ticket");
  Hashtable hash = new Hashtable(checkoutMap);

%>
<form name="checkout" method="post" action="<%=XSSUtil.encodeForHTML(context, actionURL)%>" target="<%=XSSUtil.encodeForHTML(context, target)%>">
<%
    if ( jobTicket != null )
    {
%>
      <input type="hidden" name="<%=jobTicket%>" value="<xss:encodeForHTMLAttribute><%=ticket%></xss:encodeForHTMLAttribute>"/>

<%
    }
    Enumeration enumParam = hash.keys();
    while (enumParam.hasMoreElements() )
    {
        String name = (String)enumParam.nextElement();
        String value = (String)hash.get(name);
%>
      <input type="hidden" name="<%=name%>" value="<xss:encodeForHTMLAttribute><%=value%></xss:encodeForHTMLAttribute>"/>
<%
    }
%>
<img src="../common/images/utilSpacer.gif"  height="250" width="1" /><br/>
<table width="100%" border="0" cellpadding="5" cellspacing="0">
  <tr>
    <td align="right" nowrap >
      <img src="../common/images/utilSpacer.gif"  height="10" width="1" /><br/>
 <a href="javascript:getTopWindow().closeWindow()"> <img src="../common/images/buttonDialogDone.gif" border="0" align="absmiddle"/></a>&nbsp;<a href="javascript:getTopWindow().closeWindow()"><emxUtil:i18n localize="i18nId">emxComponents.Common.Done</emxUtil:i18n>
     </td>
   </tr>
</table>
</form>

<script language="javascript">
  document.checkout.submit();
  //XSSOK
  var refresh = "<%=refresh%>"
  var ischeckout = false;
<%
   if ("checkout".equals(action) )
   {
%>
      ischeckout = true;
<%
   }
%>
  strExecRefresh = "getTopWindow().getWindowOpener().parent.location.href=getTopWindow().getWindowOpener().parent.location.href;";
  if (ischeckout && refresh){
    eval(strExecRefresh);
  }
<%
  if ( "hiddenFrame".equals(target) )
  {
%>
    getTopWindow().closeWindow()
<%
  }

%>

</script>
<iframe id="testframe" width="1" height="1" ></iframe>
</body>
</html>
