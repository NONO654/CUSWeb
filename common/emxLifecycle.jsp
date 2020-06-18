<%-- emxLifecycle.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLifecycle.jsp.rca 1.16 Tue Oct 28 22:59:38 2008 przemek Experimental przemek $
--%>
<%@include file="emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorCheckReadAccess.inc"%>
<html>

<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<script language="Javascript" src="scripts/emxUIConstants.js"></script>
<%
	// Get the mode for the page, if no mode is passed then it is basic mode by default
	String strMode = emxGetParameter(request, "mode");
	String objectId = emxGetParameter(request, "objectId");
	String pageHeader= "emxFramework.Lifecycle.Lifecycle";
	pageHeader=UINavigatorUtil.getI18nString(pageHeader, "emxFrameworkStringResource", request.getHeader("Accept-Language"));
	pageHeader=UIUtil.getWindowTitleName(context,null,objectId,pageHeader);
	if (strMode == null || "".equals(strMode.trim()) || "null".equals(strMode.trim())) {
	    strMode = "basic";
	}
	String emxTableRowId = emxGetParameter(request, "emxTableRowId");
	String sObjectId = null;
	StringTokenizer st = null;
	matrix.util.StringList sList = null;
	if(emxTableRowId != null)
    {
	    if(emxTableRowId.indexOf("|") != -1){
	        st = new StringTokenizer(emxTableRowId, "|");
	        sList = com.matrixone.apps.domain.util.FrameworkUtil.split(emxTableRowId,"|");
	        if(sList.size() == 3){
	            sObjectId = (String)sList.get(0);
	        }else{
	            sObjectId = (String)sList.get(1);
	        }
	    }else{
	        sObjectId = emxTableRowId;
	    }
   }else{
       sObjectId = emxGetParameter(request, "objectId" );
   }
	
	if ("advanced".equalsIgnoreCase(strMode)) {
	    // Form the portal url to show the advanced lifecycle page
	    StringBuffer strPortalUrl = new StringBuffer("emxPortal.jsp?showPageHeader=true&portal=AEFLifecyclePowerView&header=emxFramework.ObjectPortal.LifecycleReviewPowerViewHeader&HelpMarker=emxhelplifecylepv");
	    
	    // Append all the parameters to the url, avoid the parameters - portal, header, HelpMarker, toolbar
	    Enumeration enumeration = emxGetParameterNames(request);
		while (enumeration.hasMoreElements()) {
			String strParamName = (String)enumeration.nextElement();
			String strParamValue = emxGetParameter(request, strParamName);
			if ("objectId".equals(strParamName) && sObjectId != null) {
			    strParamValue = sObjectId;
			}
            if("treeLabel".equals(strParamName)){
            	strParamValue = XSSUtil.encodeForURL(context, strParamValue);
            }
			strPortalUrl.append("&").append(XSSUtil.encodeForJavaScript(context, strParamName)).append("=").append(XSSUtil.encodeForJavaScript(context, strParamValue));
		}
		
		//Redirect to the portal page
%>
<script language="javascript">
		<!-- Hide from non javascript browsers--><!-- //XSSOK -->
			window.location.href = "<%=strPortalUrl.toString()%>";
		</script>
<%		
	}
	else if ("basic".equalsIgnoreCase(strMode)) {
	    //String appendParams = emxGetQueryString(request);  
	    
	    // Avoid sending the HelpMarker parameter ahead, 
	    // the lifecycle header page will form the specific helpmarker for each policy
	    StringBuffer sbufAppendParams = new StringBuffer(64);
	    Enumeration enumeration = emxGetParameterNames(request);
		while (enumeration.hasMoreElements()) {
			String strParamName = (String)enumeration.nextElement();
			if ("HelpMarker".equals(strParamName)) {
			    continue;
			}
			
			String strParamValue = emxGetParameter(request, strParamName);
			if ("objectId".equals(strParamName) && sObjectId != null) {
			    strParamValue = sObjectId;
			}
			if("treeLabel".equals(strParamName)){
                strParamValue = XSSUtil.encodeForURL(context, strParamValue);
            }
			if (sbufAppendParams.length() > 0) {
			    sbufAppendParams.append("&");
			}
			
			sbufAppendParams.append(XSSUtil.encodeForURL(context,strParamName)).append("=").append(XSSUtil.encodeForURL(context,strParamValue));
		}
		String appendParams = sbufAppendParams.toString();
			    
	    String objectLifecycleBodyURL = "emxLifecycleDialog.jsp?" + appendParams;  
	    
	    // check if "promote/demote" is going on in the background on this Object
	  //  String objectId = emxGetParameter(request, "objectId");
	    String inProgressFlag = objectId + "_inProgress";
	    String isBackgroundProcessInProgress = (String)session.getAttribute(inProgressFlag);

	    String toolbar = emxGetParameter(request, "toolbar");
	    String header = emxGetParameter(request, "header");
	    String suiteKey = emxGetParameter(request, "suiteKey");
	    String tipPage = emxGetParameter(request, "TipPage");
	    String printerFriendly = emxGetParameter(request, "PrinterFriendly");
	    String relId = emxGetParameter(request, "relId");
	    String timeStamp = emxGetParameter(request, "timeStamp");
	    String export = emxGetParameter(request, "export");
	    String sHelpMarker = "emxhelp";

	    String languageStr = request.getHeader("Accept-Language");

	    //Open the current BusinessObject
	    DomainObject boGeneric = DomainObject.newInstance(context, objectId);
	    SelectList objectSelects = boGeneric.getObjectSelectList(2);
	    objectSelects.addElement(boGeneric.SELECT_ID);
	    objectSelects.addElement(boGeneric.SELECT_POLICY);

	    Map map = boGeneric.getInfo(context, objectSelects);

	    // Use symbolic policy name to generate help marker for lifecycle (10.5 change)
	    // The help marker will be the prefix "emxhelp" plus the symbolic name
	    // of the policy converted to lower case (i.e. emxhelppolicy_ecpart)
	    // 
	    String sPolicy = (String)map.get(boGeneric.SELECT_POLICY);
	    String symbolicPolicy = FrameworkUtil.getAliasForAdmin(context, "policy", sPolicy, true);

	    if (symbolicPolicy != null) {
	    	sHelpMarker = sHelpMarker + symbolicPolicy.toLowerCase();
	    }

	    String registeredSuite = "";
	    String suiteDir = "";
	    String stringResFileId = "";

	    try
	    {
	        if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
	        {
	            registeredSuite = suiteKey.substring(13);
	        } else if( suiteKey != null) {
	            registeredSuite = suiteKey;
	        }

	        if ( (registeredSuite != null) && (registeredSuite.trim().length() > 0 ) )
	        {
	            suiteDir = UINavigatorUtil.getRegisteredDirectory(context,registeredSuite);
	            stringResFileId = UINavigatorUtil.getStringResourceFileId(context,registeredSuite);
	        }
            if (boGeneric.isKindOf(context,PropertyUtil.getSchemaProperty(context,"type_Classification" ))) {
                header = UINavigatorUtil.getI18nString("emxFramework.Lifecycle.LifeCyclePageHeadingNoRev", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
            } else if( header != null && header.trim().length() > 0 ) {
	            header = UINavigatorUtil.getI18nString(header, stringResFileId , request.getHeader("Accept-Language"));
	        } else {
	            header = UINavigatorUtil.getI18nString("emxFramework.Lifecycle.LifeCyclePageHeading", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
	        }

	        // Then if the label contain macros, parse them
	        if (header.indexOf("$") >= 0 )
	        {
	            if (objectId != null && objectId.length() > 0 )
	            {
	                header = UIExpression.substituteValues(context,pageContext, header, objectId);
	            }
	            else
	            {
	                header = UIExpression.substituteValues(context, header);
	            }
	        }
	    }
	    catch (Exception ex)
	    {
	         if( ( ex.toString()!=null )
	            && (ex.toString().trim()).length()>0)
	         {
	            emxNavErrorObject.addMessage(ex.toString().trim());
	         }
	    }
	   
	    if( "true".equals(isBackgroundProcessInProgress)){
%>
<META HTTP-EQUIV="REFRESH" CONTENT="4" />
<%
	    }
%>
<head>
<title><%=pageHeader %></title><!-- XSSOK -->
<%@include file = "emxUIConstantsInclude.inc"%>
<script language="JavaScript" type="text/javascript">
	addStyleSheet("emxUIDOMLayout");
	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIMenu");
</script>
<script language="JavaScript" type="text/javascript">
function adjustBody(){
	var phd = document.getElementById("pageHeadDiv");
	var dpb = document.getElementById("divPageBody");
	
	var ht = phd.offsetHeight;	
	if(ht <= 0){
		ht = phd.clientHeight;
	}
	dpb.style.top = ht + "px";
}
</script>
<script language="JavaScript" type="text/javascript" src="scripts/emxUIToolbar.js"></script>
<script language="JavaScript" type="text/javascript" src="scripts/emxUIModal.js"></script>
<script language="JavaScript" type="text/javascript" src="scripts/emxUIPopups.js"></script>
<script language="JavaScript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
<script language="JavaScript" type="text/javascript" src="scripts/emxUILifecycleUtils.js"></script>
<script language="JavaScript" type="text/javascript" src="../emxUIPageUtility.js"></script>
</head>
<body class="no-footer" onload="adjustBody();turnOffProgress();">
<div id="pageHeadDiv">
<form method="post">
   <table>
     <tr>
    <td class="page-title">
      <h2><xss:encodeForHTML><%=header%></xss:encodeForHTML></h2>
    </td>
    <%
       String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
    %>
        <td class="functions">
    	    <table>
              <tr>
                <!-- //XSSOK -->
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
	        </tr></table>
        </td>
        </tr>
        </table>
<!-- //XSSOK -->
<jsp:include page = "emxToolbar.jsp" flush="true">  <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>  <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>  <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/>  <jsp:param name="parentOID" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>  <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>  <jsp:param name="header" value="<%=XSSUtil.encodeForURL(context, header)%>"/>  <jsp:param name="PrinterFriendly" value="<%=XSSUtil.encodeForURL(context, printerFriendly)%>"/>  <jsp:param name="export" value="<%=XSSUtil.encodeForURL(context, export)%>"/>  <jsp:param name="HelpMarker" value="<%=sHelpMarker%>"/>  <jsp:param name="tipPage" value="<%=XSSUtil.encodeForURL(context, tipPage)%>"/>  <jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, suiteKey)%>"/>
</jsp:include> 
</form>
</div><!-- /#pageHeadDiv -->
        <div id="divPageBody">
          	<!-- //XSSOK -->
			<iframe name="pagecontent" src="<%=objectLifecycleBodyURL%>"  width="100%" height="100%"  frameborder="0" border="0"></iframe>      		
            <iframe class="hidden-frame" name="hiddenLifecycle"></iframe>
		</div>
</body>
<% 
	}
	else {
	    String ExMsg =UINavigatorUtil.getI18nString("emxFramework.Lifecycle.InvalidParameter", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
	    throw new Exception(ExMsg+" '" + strMode + "'");
	}
%>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%> 
</html>
