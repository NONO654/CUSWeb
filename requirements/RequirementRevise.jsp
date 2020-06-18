<%--  RequirementRevise.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENORequirementsManagementBase/CNext/webroot/requirements/Revise.jsp 1.2.2.1.1.1 Wed Oct 29 22:20:01 2008 GMT przemek Experimental$
--%>
<%-- @quickreview T25  OEP 26 Sep 2012  IR-174854V6R2014   Revision command could not handle large number of objects ) --%>
<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
      respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 DJH 18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../components/emxComponentsUtil.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
  // Start:IR-174854V6R2014:T25
  // Review:OEP
  String strkeyRevision=emxGetParameter(request, "strkeyRevision");
  String objectId="";
  //END:IR-174854V6R2014:T25
  String strSuiteKey = emxGetParameter(request, "suiteKey");
  String strDescription = emxGetParameter(request, "txtDescription");
  String timeStamp = emxGetParameter(request, "timeStamp");
  String strParentObjectId = "";
 boolean error = false;
 Map errorMap = new HashMap();
 Vector exceptionObjects = new Vector();
 
 StringList strSuccess = new StringList();
 StringList strFailed =new StringList();

  try
  {
   // Start:IR-174854V6R2014:T25
   // Review:OEP
	  if(strkeyRevision != null){ 
		  objectId = (String)session.getAttribute(strkeyRevision);
		}
		else
		{
	 	 objectId = emxGetParameter(request, "objectId");
		}
	     if(strkeyRevision!= null){
			session.removeAttribute(strkeyRevision);
		}
   //END:IR-174854V6R2014:T25
	  Map updateResult = SpecificationStructure.modifyRevision(context, objectId, strDescription);
	  
	  Set failedRels = (Set)updateResult.get("failedRels");
	  boolean checkFailed = "true".equalsIgnoreCase((String)updateResult.get("checkFailed"));
	  boolean refresh = ((Integer)updateResult.get("successObjects")).intValue() > 0;
	  if(checkFailed){
          long number = new Random(System.currentTimeMillis()).nextLong();
          String key = "updateRevisionResult" + System.currentTimeMillis() + "_" + number;
          session.setAttribute(key, updateResult);
          %>
          <script language="javascript" type="text/javaScript">
          getTopWindow().showModalDialog("../requirements/ReviseReportFS.jsp?suiteKey=<xss:encodeForJavaScript><%=strSuiteKey%></xss:encodeForJavaScript>&key=<xss:encodeForJavaScript><%=key%></xss:encodeForJavaScript>&timeStamp=<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>", "500", "600", true);
          
          //getTopWindow().close();
          </script>
      <%
	  }
  } catch (Exception ex)
    {
    	
    }
  
%>


<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.db.BusinessObject"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Vector"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.requirements.SpecificationStructure"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Random"%><html>
<body>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIUtility.js"></script>

<script language="Javascript" >
var sbWindow = findFrame(getTopWindow(), "detailsDisplay");
if(!sbWindow) {
	sbWindow = findFrame(getTopWindow(), "content");
}
if (sbWindow && sbWindow.emxEditableTable && sbWindow.emxEditableTable.isRichTextEditor){
	sbWindow.refreshSCE();
}
else{
	refreshTablePage();
}

getTopWindow().closeSlideInDialog();
</script>
</body>
</html>

