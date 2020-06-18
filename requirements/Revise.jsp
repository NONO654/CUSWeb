<%--  Revise.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENORequirementsManagementBase/CNext/webroot/requirements/Revise.jsp 1.2.2.1.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$
--%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 DJH 19 Jun 2013  IR IR-235014V6R2014x "Added language support to a kernel thrown exception when we revise an unrevisable object."
     @quickreview T25 DJH 18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
--%>
<%@page import = "com.matrixone.apps.requirements.RequirementsCommon" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../components/emxComponentsUtil.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  String objectId = emxGetParameter(request, "objectId");

  if( objectId != null)
  {
    try
    {
      RequirementsCommon.revise(context, objectId, true);
    } catch (Exception ex)
    {
    	//Start:T25 DJH:13:06:19
	//Not messing up with the logic to check revisability, we just translate kernel thrown exception.
    	String message=null;
    	if((ex.toString().trim()).equals("Business object is not revisionable"))
    	{
        	message = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Alert.ReviseCheck");
    	}
    	else
    	{
    		message=ex.toString();
    	}
    	//End:T25 DJH:13:06:19
        session.setAttribute("error.message" , message);
    }
  }
%>

<html>
<body>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUIUtility.js" type="text/javascript"></script>
<script src="../webapps/AmdLoader/AmdLoader.js"></script>
<script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>
<script src="../webapps/WebappsUtils/WebappsUtils.js"></script>
<script language="Javascript" > 
  var frameContent = findFrame(getTopWindow(),"detailsDisplay");
  var contentFrame = findFrame(getTopWindow(), "content");
  var contTree = contentFrame.objDetailsTree;
  if(contTree == null) {
    //frameContent.document.location.href = frameContent.document.location.href;
		if(frameContent.editableTable !=null&&frameContent.emxEditableTable!=null){
			//there is no portal displayed
			frameContent.editableTable.loadData();
			frameContent.emxEditableTable.refreshStructureWithOutSort();
		}else{
			require(['DS/ENORMTCusto/ENORMTCusto'], function(){
				//the table is in a portal
				var channel = findCurrentChannel();
				if(channel!=null){
					//the channel is found 
					channel.editableTable.loadData();
					channel.emxEditableTable.refreshStructureWithOutSort();
				}else{
					//default behavior;
	  			refreshTablePage();
	  			}
			});
		}
  } else {
    var node = contTree.getSelectedNode().parent;
    //var contentFrame = findFrame(getTopWindow(), "content");
    if ( contentFrame != null && node != null && this.name != "listHidden")
    {
        if (getTopWindow().addContextTreeNode)
        {
          getTopWindow().addContextTreeNode('<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>', node.nodeID, '<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>');
        } else {
          contentFrame.addContextTreeNode('<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>', node.nodeID, '<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>');
        }
    } else {
        frameContent.document.location.href = frameContent.document.location.href;
    }
  }
</script>
</body>
</html>

