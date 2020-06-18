<%--
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil,com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%
 	String strusepg = emxGetParameter(request,"usepg");
 	if(strusepg != null && strusepg.equalsIgnoreCase("true")) {
%><script language="JavaScript" type="text/javascript" src="../common/scripts/emxUITableUtil.js"></script><%
 	}
%>
</head>
<body>
<%
  Calendar currServerCal = Calendar.getInstance();
  Date currentDateObj = currServerCal.getTime();

  // Date Format initialization
  int iDateFormat = PersonUtil.getPreferenceDateFormatValue(context);
  String iPrefTimeDisp = PersonUtil.getPreferenceDisplayTime(context);

  java.text.DateFormat outDateFrmt=null;
  if (iPrefTimeDisp != null && iPrefTimeDisp.equalsIgnoreCase("true"))
  {
      outDateFrmt = java.text.DateFormat.getDateTimeInstance(iDateFormat, iDateFormat, request.getLocale());
  } else {
      outDateFrmt = java.text.DateFormat.getDateInstance(iDateFormat, request.getLocale());
  }

  currentDateObj = outDateFrmt.parse(outDateFrmt.format(currentDateObj));
  String currentTime = outDateFrmt.format(currentDateObj);
  String pfheading = emxGetParameter(request,"pfheading");
  String strfile = emxGetParameter(request,"strfile");
String emxUICommonHeaderEndInclude_ObjId = emxGetParameter(request,"objectId");
  
 if(!UIUtil.isNullOrEmpty (strfile) && !UIUtil.isNullOrEmpty (pfheading)) {
	pfheading = EnoviaResourceBundle.getProperty(context, strfile,context.getLocale(),pfheading);
  }
  if(!UIUtil.isNullOrEmpty (pfheading) &&
     !UIUtil.isNullOrEmpty (emxUICommonHeaderEndInclude_ObjId)) {
      pfheading = UINavigatorUtil.parseStringMacro(context, session, pfheading, emxUICommonHeaderEndInclude_ObjId);
      pfheading = UIExpression.substituteValues(context, pageContext, pfheading, emxUICommonHeaderEndInclude_ObjId);
  }
  
  if ("true".equals(showPFPage)){
   %>
	<table width="100%">
	  <tr>
	      <td class="pageHeader" width="80%"><%=XSSUtil.encodeForHTML(context, pfheading)%></td>
	      <td width="1%">
			<img width="1" height="28" alt="" src="images/utilSpacer.gif"/>
		  </td>
		  <td width="39%" align="right"/>
	      <td nowrap>
	          <table>
	          <tr><td nowrap=""><%=context.getUser()%></td></tr>
	          <!-- //XSSOK -->
	          <tr><td nowrap=""><%=currentTime%></td></tr>
	          </table>
	      </td>
	  </tr>
	</table>
<%
  }
%>
<%
  String ShowWarningString    = emxGetParameter(request,"warn");
  boolean showWarning = true;
  if ("false".equalsIgnoreCase(ShowWarningString)){
    showWarning = false;
  }

  if (("true".equalsIgnoreCase(isDialogPage)) && (showWarning)){
    String requiredText = EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.Commom.RequiredText",new Locale(request.getHeader("Accept-Language")));
%>
  <table border="0" cellpadding="0" cellspacing="0"  width="1%" align="center">
    <tr><td class="requiredNotice"><%=requiredText%></td></tr>
  </table>
<%
    }
%>
<%-- BEGIN SHOW ERRORS  --%>
<%
  String error = (String)session.getAttribute("error.message");
 if (error != null && !"".equals(error) && !"".equals(error.trim())) {
%>
      &nbsp;
      <table width="90%" border="0"  cellspacing="0" cellpadding="3"  class="formBG" align="center" >
        <tr >
          <td class="errorHeader"><%=EnoviaResourceBundle.getFrameworkStringResourceProperty(context,"emxFramework.Error.Header",new Locale(request.getHeader("Accept-Language")))%></td>
        </tr>
        <tr align="center">
          <!-- //XSSOK -->
          <td class="errorMessage" align="center"><%=error%></td>
        </tr>
      </table>
<%
    session.removeAttribute("error.message");
  }
%>
<%-- END SHOW ERRORS  --%>
