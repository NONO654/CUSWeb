<html>

<!--
//@fullReview  ZUR 2013/05/20 HL XP 
-->

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>


<%@  include file = "../emxJSValidation.inc"%>

<%@ page import="java.util.*"%>
<%@ page import ="com.matrixone.vplm.parameterizationUtilities.NLSUtilities.ParameterizationNLSCatalog"%>


<head>
	<link rel=stylesheet type="text/css" href="styles/emxUIDOMLayout.css">
	<link rel=stylesheet type="text/css" href="styles/emxUIDefault.css">
	<link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css">
	<link rel=stylesheet type="text/css" href="styles/emxUIParamOnline.css">

	<script type="text/javascript" src="scripts/expand.js"></script>
	<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
	<script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>
			
	<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
	<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIConstants.js"></script>


	<script language="JavaScript" src="../common/scripts/emxNavigatorHelp.js"></script>
	<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
 
	<script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>
	<script language="JavaScript" src="../common/scripts/emxUIActionbar.js" type="text/javascript"></script>

</head>

<body>

<div id="pageHeadDiv">
<script language="javascript">
addStyleSheet("emxUIDefault");
addStyleSheet("emxUIToolbar");
addStyleSheet("emxUIMenu");
addStyleSheet("emxUIDialog");
</script>
 
<%



Locale currentLocale = request.getLocale();
ParameterizationNLSCatalog myNLS = new ParameterizationNLSCatalog(context, currentLocale, "emxVPLMAdministrationStringResource");
//String pgHead	= myNLS.getMessage("emxPlmOnline.label.Lifecycle");

String timeStamp = Long.toString(System.currentTimeMillis());
String contentURL = "emxPLMOnlineAdminXPLifecycleSummary.jsp";
String objectId = emxGetParameter(request,"objectId");
%>

<jsp:include page = "../common/emxToolbar.jsp" flush="false">
<jsp:param name="toolbar" value="APPXPLifecycleMenu"/>
<jsp:param name="helpMarker" value="emxhelplineitemsplits"/>
<jsp:param name="PrinterFriendly" value="false"/>
<jsp:param name="timeStamp" value="<xss:encodeForHTMLAttribute><%=timeStamp%></xss:encodeForHTMLAttribute>"/>
<jsp:param name="portalMode" value="false"/>
<jsp:param name="export" value="false"/>
<jsp:param name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
<jsp:param name="uiType" value=""/>
<jsp:param name="showPageURLIcon" value="false"/>
<jsp:param name="objectCompare" value="false"/>
</jsp:include>
</div>
<div id='divPageBodyXP' style="position:absolute;width:100%;height:95.5%" >
<iframe name="pagecontent" id='pagecontent' src="<xss:encodeForHTMLAttribute><%=contentURL%></xss:encodeForHTMLAttribute>" style="position:absolute;width:100%;height:100%" border="0" frameborder="0"></iframe>
</div>

</body>
</html>
