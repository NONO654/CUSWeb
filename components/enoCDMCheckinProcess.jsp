<%--  emxComponentsCheckinProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckinProcess.jsp.rca 1.22 Wed Oct 22 16:18:50 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "emxComponentsSetCompanyKeyInRPE.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<jsp:useBean id="requestBean" scope="page" class="com.matrixone.apps.domain.util.Request"/>
<%
  Map requestMap = (Map) session.getAttribute("emxCommonDocumentCheckinData");
  //Commented this for the bug 335525
  //session.removeAttribute("emxCommonDocumentCheckinData");
  //End of comments for the bug 335525
  String objectAction = (String)requestMap.get("objectAction");
  String objectId       = "";
  String appProcessPage = (String)requestMap.get("appProcessPage");
  String appDir         = (String)requestMap.get("appDir");
  String jpoName = (String)requestMap.get("JPOName");
  String methodName = (String)requestMap.get("methodName");
  String deleteFromTree = (String)requestMap.get("deleteFromTree");
  String refreshTable = (String)requestMap.get("refreshTable");
  String deleteFilePostCheckin = (String)requestMap.get("deleteFileOnCheckin");
  boolean errorMSG=false;
  boolean refreshTableContent = "true".equalsIgnoreCase((String)requestMap.get("refreshTableContent"));
  Map objectMap = new HashMap();
  StringList strFileList = (StringList)requestMap.get("fileList");
  if (strFileList == null)
  {
      strFileList = new StringList(5);
  }
  String fcsEnabled = (String) requestMap.get("fcsEnabled");
  StringList deleteFromTreeList = (StringList)requestMap.get("deleteFromTreeList");
  boolean updateDeleteFromTreeList = false;
  if (deleteFromTreeList == null || deleteFromTreeList.size() == 0)
  {
      deleteFromTreeList = new StringList(5);
      if ( deleteFromTree != null && !"".equals(deleteFromTree) && !"null".equals(deleteFromTree) )
      {
          deleteFromTreeList.addElement(deleteFromTree);
          updateDeleteFromTreeList = true;
      }
  }
  String oid = "";
  try
  {
      boolean multiPart = false;
      if (request.getContentType() != null &&
        request.getContentType().indexOf("multipart/form-data") == 0)
      {
        multiPart = true;
      }

      //Map requestMap = new HashMap();
      Enumeration enumParam;
        if (multiPart)
        {
          com.matrixone.servlet.FileUploadMultipartRequest multi = requestBean.uploadFile(context,request,true,true);
          //requestBean.uploadFile(context,request);
          enumParam = multi.getParameterNames();
          objectId = multi.getParameter("objectId");
          //jpoName = multi.getParameter("JPOName");
          //appProcessPage = multi.getParameter("appProcessPage");
          //appDir = multi.getParameter("appDir");
          requestMap.put("fcsEnabled", "false");

          while (enumParam.hasMoreElements())
          {
            String name = (String) enumParam.nextElement();
            String value = (String) multi.getParameter(name);
            if ( name.indexOf("fileName") == 0 && (value != null && !"".equals(value) && !"null".equals(value) ) )
            {
              strFileList.addElement(value);
            }
            if ( updateDeleteFromTreeList && name.indexOf("oid") == 0 )
            {
                if ( value != null && !"".equals(value) && !"null".equals(value) )
                {
                    deleteFromTreeList.addElement(value);
                }
            }
            requestMap.put(name, value);
          }
        }
        else
        {
          enumParam = request.getParameterNames();
          objectId = (String)requestMap.get("objectId");
          //jpoName = request.getParameter("JPOName");
          //appProcessPage = request.getParameter("appProcessPage");
          //appDir   = request.getParameter("appDir");
          requestMap.put("fcsEnabled", "true");
          while (enumParam.hasMoreElements())
          {
              String name = (String) enumParam.nextElement();
              requestMap.put(name, request.getParameter(name));
              if (updateDeleteFromTreeList && name.indexOf("oid") == 0 )
              {
                oid = request.getParameter(name);
                if ( oid != null && !"".equals(oid) && !"null".equals(oid) )
                {
                    deleteFromTreeList.addElement(oid);
                }
              }
          }
        }
        if ( fcsEnabled != null && !"".equals(fcsEnabled) && !"null".equals(fcsEnabled) )
        {
            requestMap.put("fcsEnabled", fcsEnabled);
        }
        request.setAttribute("requestMap", requestMap);
        String[] args = JPO.packArgs(requestMap);

        if ( "".equals(objectId) || "null".equals(objectId) )
        {
          objectId = null;
        }
        if (jpoName == null || "".equals(jpoName) || "null".equals(jpoName) )
        {
          jpoName = "emxCommonDocument";
        }
        if (methodName == null || "".equals(methodName) || "null".equals(methodName) )
        {
          methodName = "commonDocumentCheckin";
        }
        FrameworkUtil.validateMethodBeforeInvoke(context, jpoName, methodName, "Program");
        objectMap = (Map)JPO.invoke(context, jpoName, null, methodName, args, Map.class);
        request.setAttribute("objectMap", objectMap);
        request.setAttribute("requestMap", requestMap);
        errorMSG = UIUtil.isNullOrEmpty((String)objectMap.get("errorMessage")) ? true : false;
        if(!errorMSG)
        {
        	String errorMsg = (String)objectMap.get("errorMessage");
        	if(errorMsg.contains("ORA-12899") || errorMsg.contains("ORA-01461")){
	    		String oraErrorMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Create.NameColumn", new Locale(request.getHeader("Accept-Language")));            		
	    		session.setAttribute("error.message", oraErrorMessage);	    	
        	}else{
          session.setAttribute("error.message", objectMap.get("errorMessage"));
        	}
          
        }
        if(objectId == null){
        	objectId = emxGetParameter(request, "objectId");
        }
%>
<html>
<header>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
</header>
<body>
<script>     
		parent.isCheckinRefreshFinished = true;
</script>
</body>

</html>
<%

        
        
  } catch (Exception ex) {

      try
      {
        if ( objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER)
                  || objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ)) {

          // Logic to delete the object when an exception comes.
          String []objectIds = new String[1];
          objectIds[0] = objectId;
          DomainObject.deleteObjects(context,objectIds);
        }
      } catch(Exception dex)
      {
        String deleteErrMessage = dex.getMessage();
        dex.printStackTrace();
        session.putValue("error.message", deleteErrMessage);
      }
      String errMessage = ex.getMessage();
      ex.printStackTrace();
      session.putValue("error.message", errMessage);
%>
	<html>
	<header>
	<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
	</header>
	<body>
	<script>     
			parent.isCheckinRefreshFinished = false;
	</script>
	</body>
	
	</html>
<%      
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
%>
