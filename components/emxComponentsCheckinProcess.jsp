<%--  emxComponentsCheckinProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxComponentsCheckinProcess.jsp.rca 1.15 Wed Oct 22 16:18:40 2008 przemek Experimental przemek $"
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "emxComponentsSetCompanyKeyInRPE.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<jsp:useBean id="requestBean" scope="page" class="com.matrixone.apps.domain.util.Request"/>

<%

  StringList strFileList = new StringList(1);
  String appProcessPage = "";
  String appDir =   "";
  String objectId = "";

  try
  {
      boolean multiPart = false;
      if (request.getContentType() != null &&
          request.getContentType().indexOf("multipart/form-data") == 0)
      {
          multiPart = true;
      }
      String store = "";
      Map requestMap = new HashMap();
      String jpoName = "emxCommonFile";
      String fileName = "";
      Enumeration enumParam;
      if (multiPart)
      {

          com.matrixone.servlet.FileUploadMultipartRequest multi = requestBean.uploadFile(context,request);
          enumParam = multi.getParameterNames();
          objectId = multi.getParameter("objectId");
          jpoName = multi.getParameter("JPOName");
          requestMap.put("fcsEnabled", "false");
          appDir = multi.getParameter("appDir");
          fileName = multi.getParameter("fileName");
          appProcessPage = multi.getParameter("appProcessPage");
          store = multi.getParameter("store");

          while (enumParam.hasMoreElements())
          {
              String name = (String) enumParam.nextElement();
              requestMap.put(name, multi.getParameter(name));
          }
      }
      else
      {

          enumParam = request.getParameterNames();
          objectId = request.getParameter("objectId");
          jpoName  = request.getParameter("JPOName");
          appDir   = request.getParameter("appDir");
          appProcessPage = request.getParameter("appProcessPage");
          fileName = request.getParameter("fileName");
          requestMap.put("fcsEnabled", "true");
          store = request.getParameter("store");
          while (enumParam.hasMoreElements())
          {
              String name = (String) enumParam.nextElement();
              requestMap.put(name, request.getParameter(name));
          }
      }

      request.setAttribute("requestMap", requestMap);
      strFileList.addElement(fileName);
      String[] args = JPO.packArgs(requestMap);
      if ( "".equals(objectId) || "null".equals(objectId) )
      {
          objectId = null;
      }
      if ( jpoName == null || "".equals(jpoName) || "null".equals(jpoName) )
      {
          jpoName = "emxCommonFile";
      }
      if ( jpoName != null )
      {
		  FrameworkUtil.validateMethodBeforeInvoke(context, jpoName, "checkin", "Program");
          objectId = (String)JPO.invoke(context, jpoName, null, "checkin", args, String.class);
      }
      if (objectId == null )
      {
            String alreadyExistsErr = fileName + " " + i18nNow.getI18nString("emxComponents.Common.DocumentAlreadyExists","emxComponentsStringResource",request.getHeader("Accept-Language"));
            throw (new Exception(alreadyExistsErr));
      }

  } catch (Exception ex) {

      String errMessage = ex.getMessage();
      ex.printStackTrace();
      session.putValue("error.message", errMessage);
  }
  finally
  {
      Document.workspaceCleanUp(context,strFileList);
      int interval = session.getMaxInactiveInterval();
      int maxInterval = Integer.parseInt((String)EnoviaResourceBundle.getProperty(context,"emxFramework.ServerTimeOutInSec"));
      if( interval == maxInterval )
      {
        interval = ((Integer)session.getAttribute("InactiveInterval")).intValue();
        session.setMaxInactiveInterval(interval);
      }
  }

  if ( appProcessPage != null && !"".equals(appProcessPage) && !"null".equals(appProcessPage) )
  {
      appProcessPage = "../" + appDir + "/" + appProcessPage;
                context.shutdown();
%>
      <jsp:forward page="<%=XSSUtil.encodeForHTML(context, appProcessPage)%>" >
        <jsp:param name ="objectId" value  ="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
      </jsp:forward>
<%
  }
  else
  {
%>
	  <script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
      <script language="Javascript">
        function findFrame(objWindow, strName)  {
		    if (strName == "_top") {
        		return getTopWindow();
		    } else if (strName == "_self") {
        		return self;
	        } else if (strName == "_parent") {
		        return parent;
      		} else {
		        var objFrame = null;
		        for (var i = 0; i < objWindow.frames.length && !objFrame; i++) {
		          if (objWindow.frames[i].name == strName) {
        			  objFrame = objWindow.frames[i];
          		  }
        		}
		        if (!objFrame) {
			    	for (var i=0; i < objWindow.frames.length && !objFrame; i++) {
           		 		objFrame = findFrame(objWindow.frames[i], strName);
          			}
        		}
		        return objFrame;
      		}
    	}
      
        var contentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");
        contentFrame = contentFrame == null ? findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content") : contentFrame;
        if(contentFrame) {
	        contentFrame.document.location.href = contentFrame.document.location.href;
	    } else {
	    	getTopWindow().getWindowOpener().getTopWindow().document.location.href = getTopWindow().getWindowOpener().getTopWindow().document.location.href;
	    }
	    getTopWindow().closeWindow();
      </script>
<%
  }
%>
