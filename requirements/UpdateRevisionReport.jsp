<%--
  DeleteReport.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = ;

 --%>
<%-- @quickreview T25 OEP 21 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags and tag Lib are included--%>
<%-- @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget. --%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@include file = "../emxTagLibInclude.inc"%>
<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%
	boolean isFromStructureBrowser = "true".equalsIgnoreCase(emxGetParameter(request, "isFromStructureBrowser"));
	String timeStamp = emxGetParameter(request, "timeStamp");      
 %>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
<script type="text/javascript" language="JavaScript">
        //addStyleSheet("emxUIDefault");
        //addStyleSheet("emxUIList");
        //addStyleSheet("emxUISearch");

function popupObjectDialog(oid)
{
	showNonModalDialog("../common/emxTree.jsp?emxSuiteDirectory=common&suiteKey=Framework&relId=&parentOID=null&jsTreeID=null&objectId=" + oid, 900, 600,true )

}        

<%
	try
	{
	  	String key = emxGetParameter(request, "key"); 
		if(key != null){ 
			Map updateResult = (Map)session.getAttribute(key);
			if(updateResult != null){
				int totalObjects = ((Integer)updateResult.get("totalObjects")).intValue();
				int failedObjects = ((Integer)updateResult.get("failedObjects")).intValue();

%>
</script>
<style type="text/css">
ul {
    /* list-style: none;  */
    margin-left: 0px; 
    padding-left: 0px;
}
li {
	margin-left: 40px;
	padding-left: 0px; 
}
</style>
</head>
 //KIE1 ZUD TSK447636 
<body onunload="getTopWindow().closeWindow()">
<%
				
				String suiteKey = emxGetParameter(request, "suiteKey");
	  			String strStringResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);
				String[] arrFormatMessageArgs = new String[2];
                arrFormatMessageArgs[0] = failedObjects + "";
                arrFormatMessageArgs[1] = totalObjects + "";
%>
<xss:encodeForHTML><%=MessageUtil.getMessage(context, null, "emxRequirements.UpdateRevision.Error.UpdateSelectedFail",arrFormatMessageArgs, null, context.getLocale(), strStringResourceFile)%></xss:encodeForHTML>
                            
<%
				List reservedObjects = (List)updateResult.get("reserveCheck");
				List exceptionObjects = (List)updateResult.get("exceptionCheck");
				List frozenObjects = (List)updateResult.get("stateCheck");
				
				if(frozenObjects.size() > 0){
%>
	<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.UpdateRevision.Error.State</emxUtil:i18nScript><br/>
<%
					for(int i = 0; i < frozenObjects.size(); i++){
						Map values = (Map)frozenObjects.get(i);
						Map parentValues = (Map)values.get("$parent");
						arrFormatMessageArgs = new String[3];
		                arrFormatMessageArgs[0] = "<a href=\"javascript:popupObjectDialog('" + (String)values.get(DomainConstants.SELECT_ID) + 
		                						"')\"> 	" + (String)values.get(DomainConstants.SELECT_NAME) + " " + 
		                						(String)values.get(DomainConstants.SELECT_REVISION) + "</a>";
		                arrFormatMessageArgs[1] = "<a href=\"javascript:popupObjectDialog('" + (String)parentValues.get(DomainConstants.SELECT_ID) + 
		                						"')\"> 	" + (String)parentValues.get(DomainConstants.SELECT_NAME) + " " + 
		                						(String)parentValues.get(DomainConstants.SELECT_REVISION) + "</a>";
		                arrFormatMessageArgs[2] = i18nNow.getStateI18NString("", (String)parentValues.get("current"), request.getLocale().toString());
%>
<li><xss:encodeForHTML><%=MessageUtil.getMessage(context, null, "emxRequirements.UpdateRevision.Error.CurrentState",arrFormatMessageArgs, null, context.getLocale(), strStringResourceFile)%></xss:encodeForHTML>
</li>
<%
					}
%>
	</ul>
<%					
				}

				if(reservedObjects.size() > 0){
%>
	<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.UpdateRevision.Error.Reserved</emxUtil:i18nScript><br/>
<%				
					for(int i = 0; i < reservedObjects.size(); i++){
						Map values = (Map)reservedObjects.get(i);
						Map parentValues = (Map)values.get("$parent");
						arrFormatMessageArgs = new String[3];
		                arrFormatMessageArgs[0] = "<a href=\"javascript:popupObjectDialog('" + (String)values.get(DomainConstants.SELECT_ID) + 
		                						"')\"> 	" + (String)values.get(DomainConstants.SELECT_NAME) + " " + 
		                						(String)values.get(DomainConstants.SELECT_REVISION) + "</a>";
		                arrFormatMessageArgs[1] = "<a href=\"javascript:popupObjectDialog('" + (String)parentValues.get(DomainConstants.SELECT_ID) + 
		                						"')\"> 	" + (String)parentValues.get(DomainConstants.SELECT_NAME) + " " + 
		                						(String)parentValues.get(DomainConstants.SELECT_REVISION) + "</a>";
		                arrFormatMessageArgs[2] = (String)parentValues.get("reservedby");
						
%>
<li><xss:encodeForHTML><%=MessageUtil.getMessage(context, null, "emxRequirements.UpdateRevision.Error.ReservedBy",arrFormatMessageArgs, null, context.getLocale(), strStringResourceFile)%></xss:encodeForHTML>
</li>
<%
					}
%>
	</ul>
<%					
				}
				
				if(exceptionObjects.size() > 0){
%>
	<p/><ul><emxUtil:i18nScript localize="i18nId">emxRequirements.UpdateRevision.Error.UpdateFail</emxUtil:i18nScript><br/>
<%
					for(int i = 0; i < exceptionObjects.size(); i++){
						Map values = (Map)exceptionObjects.get(i);
						arrFormatMessageArgs = new String[2];
		                arrFormatMessageArgs[0] = "<a href=\"javascript:popupObjectDialog('" + (String)values.get(DomainConstants.SELECT_ID) + 
		                						"')\"> 	" + (String)values.get(DomainConstants.SELECT_NAME) + " " + 
		                						(String)values.get(DomainConstants.SELECT_REVISION) + "</a>";
		                arrFormatMessageArgs[1] = (String)values.get("errorMsg");
%>
<li><xss:encodeForHTML><%=MessageUtil.getMessage(context, null, "emxRequirements.UpdateRevision.Error.Exception",arrFormatMessageArgs, null, context.getLocale(), strStringResourceFile)%></xss:encodeForHTML>
</li>
<%
					}
%>
	</ul>
<%					
				}
				session.removeAttribute(key);
			}
		}else{
		
		}
    }
    catch (Exception exp)
	{
		exp.printStackTrace(System.out);
		session.putValue("error.message", exp.getMessage());
		//throw exp;
	}
%>
</body>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
