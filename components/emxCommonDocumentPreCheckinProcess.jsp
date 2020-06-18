<%-- emxCommonDocumentPreCheckinProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentPreCheckinProcess.jsp.rca 1.10 Wed Oct 22 16:18:27 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "emxComponentsSetCompanyKeyInRPE.inc"%>

<jsp:useBean id="requestBean" scope="page" class="com.matrixone.apps.domain.util.Request"/>

<html>
    <head>
<%
  Map requestMap = (Map) session.getAttribute("emxCommonDocumentCheckinData");
  String objectAction = (String)requestMap.get("objectAction");
  String objectId       = "";
  String appProcessPage = (String)requestMap.get("appProcessPage");
  String appDir         = (String)requestMap.get("appDir");
  String jpoName = (String)requestMap.get("JPOName");
  String deleteFromTree = (String)requestMap.get("deleteFromTree");
  String refreshTable = (String)requestMap.get("refreshTable");
  Map objectMap = new HashMap();
  StringList strFileList = new StringList(5);
  StringList deleteFromTreeList = new StringList();
  if ( deleteFromTree != null && !"".equals(deleteFromTree) && !"null".equals(deleteFromTree) )
  {
      deleteFromTreeList.addElement(deleteFromTree);
  }
  String oid = "";
  try
  {
      com.matrixone.servlet.FileUploadMultipartRequest multi = requestBean.uploadFile(context,request,true,true);
      Enumeration enumParam = multi.getParameterNames();
      objectId = multi.getParameter("objectId");
      requestMap.put("fcsEnabled", "false");

      while (enumParam.hasMoreElements())
      {
        String name = (String) enumParam.nextElement();
        String value = (String) multi.getParameter(name);
        if ( name.indexOf("fileName") == 0 && (value != null && !"".equals(value) && !"null".equals(value) ) )
        {
          strFileList.addElement(value);
        }
        if ( name.indexOf("oid") == 0 )
        {
            if ( value != null && !"".equals(value) && !"null".equals(value) )
            {
                deleteFromTreeList.addElement(value);
            }
        }
        requestMap.put(name, value);
      }
      requestMap.put("deleteFromTreeList", deleteFromTreeList);
      requestMap.put("fileList", strFileList);
  } catch (Exception ex) {
      String errMessage = ex.getMessage();
      ex.printStackTrace();
      session.putValue("error.message", errMessage);
  }
%>
   </head>
<body>
   <form name="checkinProcessForm" action="emxCommonDocumentCheckinProcess.jsp" method="post">
      <input type="hidden" name="xyz" value="xyz" />
</form>
<script>
      document.checkinProcessForm.submit();
</script>

</body>
</html>
