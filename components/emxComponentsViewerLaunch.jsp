<%--
  emxComponentsViewerLaunch.jsp

  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsViewerLaunch.jsp.rca 1.8 Wed Oct 22 16:18:29 2008 przemek Experimental przemek $
--%>
<%@include file = "emxComponentsNoCache.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>

<%!

  // ----------------------------------------------
  // BEGIN Integration Modification (DDELUCA: 11/28/02)
  // J2EE or non-J2EE servlet URL
  // J2EEOrNonJ2EE is a "local" utility class to deduce
  // if we are within a J2EE or non-J2EE environment.
  // It uses similar logic as FrameworkServlet.getRealURL(string)
  // ---------------------------------------------------------------------
  static final class J2EEOrNonJ2EE
  {
     private String PROXY_SERVER_LOOKUP = "ematrix.proxy.server";
     private String WEB_APP_LOOKUP = "ematrix.web.app";
     private String WEB_APP_NAME = "ematrix.page.path";

     public String getRealURL(String url)
     {
  StringBuffer buf = new StringBuffer();
  if (Framework.getPropertyBoolean(WEB_APP_LOOKUP, false))
        {
          String proxy = Framework.getPropertyValue(PROXY_SERVER_LOOKUP);
          if (proxy != null) {
             buf.append(proxy);
          }

          String webAppName = Framework.getPropertyValue(WEB_APP_NAME);
          if (webAppName != null) {
             buf.append(webAppName);
          }
  }

        if (url != null) {
           buf.append(url);
        }

        return buf.toString();
     }
  }
%>

<%
  DomainObject domainObj = DomainObject.newInstance(context);

  String objectId   = emxGetParameter(request,"objectId");
  String languageStr = request.getHeader("Accept-Language");
  String strFileFormat = emxGetParameter(request,"format");
  String strFileName = emxGetParameter(request,"fileName");
  String viewerURL  = null;
  domainObj.setId(objectId);
  domainObj.open(context);

  if(strFileFormat == null || strFileName == null) {
    FormatItr formatItr  = new FormatItr(domainObj.getFormats(context));
    strFileFormat = domainObj.getDefaultFormat(context);

    while ( formatItr.next() ) {
        strFileFormat = formatItr.obj().getName();
        FileList fileList = domainObj.getFiles(context,strFileFormat);
        if ( fileList.size() > 0 ) {
          break;
        }
    }
    strFileName = domainObj.getAttributeValue(context,PropertyUtil.getSchemaProperty(context, "attribute_Title"));
  }

  domainObj.close(context);

  FormatUtil formatUtil = new FormatUtil();
  String symbolicFormatName = FrameworkUtil.getAliasForAdmin( context, "format", strFileFormat, true);

  try
  {
      if (objectId == null || strFileFormat == null || strFileName == null )
      {
          session.putValue("error.message", ComponentsUtil.i18nStringNow("emxComponents.ViewerLaunch.NullValues", languageStr));
          throw (new Exception("Null values in Request"));
      }

      formatUtil.setFormatName( symbolicFormatName );

      viewerURL = formatUtil.getViewer( context, application, context.getUser());

      boolean viewerExtflag      = false;
      String strViewerExtension  = EnoviaResourceBundle.getProperty(context,"emxFramework.ViewerExtensions");
      StringTokenizer sTokenViewExt = new StringTokenizer(strViewerExtension, ",");
      String sNextToken = null;
      String fileExt = strFileName.substring(strFileName.lastIndexOf(".")+1,strFileName.length()).toLowerCase();

      while (sTokenViewExt.hasMoreElements()) {
        sNextToken = sTokenViewExt.nextToken();

        if(fileExt.equalsIgnoreCase(sNextToken)){
          viewerExtflag = true;
          break;
        }
      }

      if( viewerURL == null || "".equals( viewerURL ) || !viewerExtflag)
      {
          throw (new Exception("No registred Viewer found or InValid Viewer Preference"));
      }


  viewerURL = new J2EEOrNonJ2EE().getRealURL("/servlet/" + viewerURL);
  // ----------------------------------------------
  // END Integration Modification (DDELUCA: 11/28/02)
  // ----------------------------------------------

  }
  catch(Exception Ex)
  {
        // for JT format, reload the page with a Error message
        if( symbolicFormatName.equals("format_JT") )
        {

        session.putValue("error.message", ComponentsUtil.i18nStringNow("emxComponents.ViewerLaunch.NoViewerFound", languageStr));
%>
        <script language="JavaScript">
            window.getWindowOpener().parent.location.reload();
            window.closeWindow();
        </script>
<%
          return;
        }

        BusinessObject busDoc = new BusinessObject(objectId);
        String errorPage = "/"+ appDirectory +"/emxComponentsError.jsp";
        Map checkoutMap = DocumentUtil.getFileViewURL(context,request,response,busDoc,strFileName,strFileFormat, errorPage, false);
        String actionURL = (String)checkoutMap.remove("action");
        String jobTicket = (String)checkoutMap.remove("jobTicket");
        String ticket = (String)checkoutMap.remove("ticket");
        Hashtable hash = new Hashtable(checkoutMap);

%>
        <form name="checkout1" method="post" action="<%=XSSUtil.encodeForHTML(context, actionURL)%>" target="">
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
    document.checkout1.submit();
  </script>
<%
      return;

  }
%>

<%
  // --------------------------------------------------
  // BEGIN Integration Modification (DDELUCA: 11/28/02)
  // Use NEW applet tag below for fileupload
  // --------------------------------------------------
%>
<form name="viewerForm" action="<%= XSSUtil.encodeForHTML(context, viewerURL) %>" method="post">
      <input type="hidden" name="id" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="format" value="<xss:encodeForHTMLAttribute><%=strFileFormat%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="file" value="<xss:encodeForHTMLAttribute><%=strFileName%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="mode" value="1"/>
      <input type="hidden" name="AcceptLanguage" value="<xss:encodeForHTMLAttribute><%=request.getHeader("Accept-Language")%></xss:encodeForHTMLAttribute>"/>
</form>
<%
  // ------------------------------------------------
  // END Integration Modification (DDELUCA: 11/28/02)
  // ------------------------------------------------
%>
<script language="JavaScript">
    document.viewerForm.submit();
</script>
