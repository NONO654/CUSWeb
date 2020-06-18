
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%@ page import="com.matrixone.servlet.Framework" %>
<%@ include file ="MCADTopInclude.inc" %>

<%

	String jsMethodName	=Request.getParameter(request,"jsMethodName");
	Context context = Framework.getFrameContext(session);
	ENOCsrfGuard.validateRequest(context, session, request, response);	

%>

<script language="JavaScript" src="scripts/IEFUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/IEFUIModal.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<SCRIPT LANGUAGE="JavaScript">
function isFunction(object) {
	   return !!(object && object.constructor && object.call && object.apply);
	  }

	function ifFnExistsInvokeIt(refFrame, fnName)
	{
	   var fn = refFrame[fnName];
	   	var fnExists = isFunction(fn);
	   if(fnExists)
	      fn();
	}

	var integFrame = getIntegrationFrame(this);		
	ifFnExistsInvokeIt(integFrame,"<%=XSSUtil.encodeForJavaScript(context, jsMethodName)%>");
	
</SCRIPT>

