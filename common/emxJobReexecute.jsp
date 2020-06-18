 <%-- emxJobReexecute.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxJobReexecute.jsp.rca 1.3.3.2 Wed Oct 22 15:47:46 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>
<script language="javascript" src="../emxUIPageUtility.js"></script>
<%
    String objectId=emxGetParameter(request,"objectId");
    Job jobObj = (Job)DomainObject.newInstance(context, objectId);
    String rerunJobId = "";
    Boolean contFlag = true;
    try{
        rerunJobId = jobObj.reRun(context);
    }catch(Exception e){
    	String exepMsg = e.getMessage().toString();
    	if(exepMsg.indexOf("#1500185") > -1){
    		String errorMsg="emxFramework.JobReExecuteReviseError";
    		errorMsg = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, errorMsg, request.getLocale());
    		contFlag = false;
            %>
            <script language="Javascript">
            	alert("<%=errorMsg%>");
            </script>
    		<%
    	}
    }
if(contFlag){
    String jobUrl = "emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, rerunJobId);
%>
<html>
<head>
	<title></title>
        <script language="Javascript">
            function launchModalWin(){
                //XSSOK
                emxShowModalDialog('<%=jobUrl%>',600,600);
            }
        </script>
</head>

<body onload="launchModalWin()">

</body>
</html>
<%}%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
