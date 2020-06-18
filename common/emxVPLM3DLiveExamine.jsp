<%--  emxVPLM3DLiveExamine.jsp   -   page for Public attributes of VPLMEntities
   Copyright (c) 1992-2007 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxVPLMLogon.jsp.rca 1.12.1.1.1.2 Sun Oct 14 00:27:58 2007 przemek Experimental cmilliken przemek $

	RCI - Wk38 2011 - RI 130143 - % dans le iFrame
	RCI - Wk25 2012 - migration on 
	RCI - Wk22 2013 - RI 207033 - IE diplay
	RCI - Wk30 2013 - RI 207033 - reprise IE diplay ... IE9 needed
   
   --%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.HashMap"%>
<%@ page import = "java.util.Set" %>
<%@ page import = "matrix.db.*" %>
<%@ page import = "java.util.ArrayList" %>
<%@ page import = "java.util.List" %>
<%@ page import = "com.dassault_systemes.WebNavTools.util.VPLMDebugUtil" %>
<%@ page import = "com.dassault_systemes.vplm.interfaces.access.IPLMxCoreAccess" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.PLMCoreModelerSession" %>
<%@ page import = "com.dassault_systemes.vplm.data.PLMxJResultSet" %>
<%@ page import = "com.dassault_systemes.vplm.modeler.entity.PLMxReferenceEntity" %>
<%@ page import = "com.dassault_systemes.vplm.productNav.interfaces.IVPLMProductNav" %>
<%@ page import = "com.dassault_systemes.Tools.VPLMJLogStreamUnstream"%>
<%@ page import = "com.matrixone.apps.domain.util.XSSUtil"%>
<%@ page contentType="text/html; charset=UTF-8" language="java"%>

<!DOCTYPE html>
<html>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

		<script language="JavaScript" src="../common/scripts/emxUIConstants.js"></script>
		<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
		<script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
		<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>

		<script type="text/javascript" language="JavaScript">
			 addStyleSheet("emxUIDefault","../common/styles/");
    	    addStyleSheet("emxUIDOMLayout","../common/styles/");
    	    addStyleSheet("emxUIToolbar","../common/styles/");
    	    addStyleSheet("emxUIMenu","../common/styles/");
		</script>

	</head>
<script language="javascript" src="../components/ENOVIA3DLiveExamine.js"></script>
<script language="javascript" src="../components/ENOVIA3DLiveExamineExtension.js"></script>

<%
String strLanguage = request.getHeader("Accept-Language");
	HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
	//System.out.println("requestMap = " + requestMap);
	String categoryTreeName = emxGetParameter(request, "categoryTreeName");
	//System.out.println("categoryTreeName = " + categoryTreeName);
	String objectId = emxGetParameter(request,"objectId");
	String revision = MqlUtil.mqlCommand(context, "print bus "+objectId+" select revision dump");
	String header = "3DLive Examine";
	String toolbar = emxGetParameter(request, "toolbar");
	String suiteKey = emxGetParameter(request, "suiteKey");
	String PrinterFriendly = emxGetParameter(request, "PrinterFriendly");
	String export = emxGetParameter(request, "Export");
 //VPLMDebugUtil.dumpObject(requestMap); 
 
 
   StringBuffer  parametersBuffer  =  new  StringBuffer();  
   Map  parameters  =  request.getParameterMap();  
   java.util.Set  keys  =  parameters.keySet();  
   Iterator  keysItr  =  keys.iterator();  
   while(keysItr.hasNext()){  
      String  key  =  (String)  keysItr.next();  
      String  value[]  =  (String[])parameters.get(key);  
      if(parametersBuffer!=null  &&  !parametersBuffer.toString().isEmpty()){  
            parametersBuffer.append("&");  
        } 
      String encodedValue = XSSUtil.encodeForURL(context, value[0]); //L48 : HTTP400 Error
      parametersBuffer.append(key  +  "="  +  encodedValue);  
    }	  
	
	
	
	String browser = request.getHeader("USER-AGENT");
    boolean isIE = browser.indexOf("MSIE") > 0;

	header = "";
%>
<body onload="turnOffProgress();">
<script language="javascript">
 var offsetHeight = document.getElementById('pageHeadDiv').offsetHeight;
 </script>
		<div id="pageHeadDiv" >
			<table>
				<tr>
					<td class="page-title"><h2 id="ph">版本:<%=revision%></h2></td>
					<td class="functions">
						<table>
							<tr>
								<td class="progress-indicator"><div id="imgProgressDiv"></div></td>
							</tr>
						</table>
					</td>
				</tr>

			</table>
	<jsp:include page = "../common/emxToolbar.jsp" flush="true">
			    <jsp:param name="toolbar" value="<%=toolbar%>"/>
			    <jsp:param name="suiteKey" value="<%=suiteKey%>"/>
			    <jsp:param name="PrinterFriendly" value="<%=PrinterFriendly%>"/>
			    <jsp:param name="export" value="<%=export%>"/>
			    <jsp:param name="helpMarker" value="emxhelpprocesses"/>
			    <jsp:param name="categoryTreeName" value="<%=categoryTreeName%>"/>
			</jsp:include>
		</div>
			
		<div id="divPageBody" style="top: (100-offsetHeight)%;">
			<iframe id="frameViewer" name="frameViewer" src="../common/emxVPLM3DLiveExamineViewer.jsp?<%=parametersBuffer.toString()%>"  width="100%" height="100%"  frameborder="0" border="0"></iframe>
		</div>
        
		<div id="divPageFoot">

		</div>
</body>
	
</body>

</html>


