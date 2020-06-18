<%--
  RichTextEditorVariables.jsp

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program
  
    @quickreview HAT1 ZUD 16:02:03  HL -  To enable Content column for Test Cases. 
    @quickreview QYG      16:05:03  javascript refactoring
    @quickreview ZUD HAT1 16:06:01 : IR-441351-3DEXPERIENCER2017x: The error message that appears on the HTML content view is not been translated into Japanes.
 --%><%
	response.setHeader("Cache-Control", "no-cache");
%>
<%@page contentType="text/javascript; charset=UTF-8"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.servlet.Framework"%>
<%@page import="com.matrixone.apps.domain.util.Request"%>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.dassault_systemes.enovia.webapps.richeditor.util.RichEditUtil"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%
	// Create context variable for use in pages
	matrix.db.Context context = Framework.getFrameContext(session);

    /* RTE EDITOR VARIABLES */
    String scebundle = "emxProductLineStringResource";
    //ZUD HAT1 :IR-441351-3DEXPERIENCER2017x fix
    String language=request.getHeader("Accept-Language");
    String cookie = "";

    for (Cookie c: request.getCookies()) {
        cookie += c.getName() + "=" + c.getValue() + ";";
    }    

%>   
	if(localStorage['debug.AMD']) {
		var _RTEVariable_js = _RTEVariable_js || 0;
		_RTEVariable_js++;
		console.info("RichTextEditorVariables.jsp loaded " + _RTEVariable_js + " times."); //, windows is " + window.location.href);
	}

    var TIMEOUT_VALUE = 50;
	var preferredEditor = "<%=RichEditUtil.getPreferredEditor(context)%>";

    <%--
       CKEDITOR
    --%>   
    
    var editButtonCK = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, scebundle, context.getLocale(), "emxProductLine.Button.SBEdit")%></xss:encodeForJavaScript>";
    var cancelButtonCK = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, scebundle, context.getLocale(), "emxProductLine.Button.Cancel")%></xss:encodeForJavaScript>";
    var applyButtonCK = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, scebundle, context.getLocale(), "emxProductLine.Button.Apply")%></xss:encodeForJavaScript>";
    
    var strAlertSaveCK = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, scebundle, context.getLocale(), "emxProductLine.RichTextEditor.Alert.Save")%></xss:encodeForJavaScript>";
    var strAlertPreventCK = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, scebundle, context.getLocale(), "emxProductLine.RichTextEditor.Alert.PreventAlert")%></xss:encodeForJavaScript>";
    var strAlertTitleCK = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, scebundle, context.getLocale(), "emxProductLine.RichTextEditor.Alert.Title")%></xss:encodeForJavaScript>";
    var alertMaxSizeCK = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, scebundle, context.getLocale(), "emxProductLine.RichTextEditor.Alert.MaxSizeForm")%></xss:encodeForJavaScript>";
    
    var csrfParams = "";
    //ZUD HAT1 :IR-441351-3DEXPERIENCER2017x fix
    var language = "<xss:encodeForJavaScript><%=language%></xss:encodeForJavaScript>";
    var cookie = "<xss:encodeForJavaScript><%=cookie%></xss:encodeForJavaScript>";
    
 <%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
	Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
	String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
%>
	var csrfTokenName = "<%=csrfTokenName%>";
	var csrfTokenValue = "<%=csrfTokenMap.get(csrfTokenName)%>";
    var csrfName = "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>";
    csrfParams = csrfName + "=" + csrfTokenName + "&" + csrfTokenName + "=" + csrfTokenValue;
<%} %>

//for debugging, do not remove
//# sourceURL=RichTextEditorVariables.jsp
