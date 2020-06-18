<%--
  MyDeskCreateVariantPostProcess.jsp
  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

 --%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>

<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>

<%
  try
  {       
      %>
          <script language="javascript" type="text/javaScript">
              var contentFrameObj = findFrame(window.parent.getTopWindow().getTopWindow(),"content");
              contentFrameObj.editableTable.loadData();
              contentFrameObj.rebuildView();
          </script>
      <% 
  }
  catch(Exception e)
  {
	  String strErrorMessage = e.getMessage();
	  if(strErrorMessage.contains("1500789")){
		  strErrorMessage = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Common.NotUniqueMsg", new Locale(request.getHeader("Accept-Language")));
	  }
	  session.putValue("error.message", strErrorMessage);
  }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
