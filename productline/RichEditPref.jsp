<%--  
	RichEditPref.jsp
   	Copyright (c) 1992-2018 Dassault Systemes.
--%>



<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.enovia.webapps.richeditor.util.RichEditUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%><html>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
    

  <head>
    <title></title>
    <meta http-equiv="imagetoolbar" content="no">
    <meta http-equiv="pragma" content="no-cache">
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIConstants.js"
        type="text/javascript">
    </SCRIPT>
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIPopups.js"
          type="text/javascript">
    </SCRIPT>
    <script type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");
    </script>
  </head>
<%
	
	String preferred = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Preferences.RichEdit.PreferredEditor");
	String htmlEditor = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Preferences.RichEdit.HTMLEditor");
	String word = EnoviaResourceBundle.getProperty(context, "emxProductLineStringResource", context.getLocale(), "emxProduct.Preferences.RichEdit.Word");
	
	String pref = RichEditUtil.getPreferredEditor(context);
	
%>
  <body onload="turnOffProgress()">
    <form method="post" action="RichEditPrefProcess.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
      <table border="0" cellpadding="5" cellspacing="2"
             width="100%">
       
        <tr>
                <td width="150" class="label">
                      	<%=XSSUtil.encodeForHTML(context, preferred) %>
                </td>
                <td class="inputField">
			            <!-- //XSSOK -->
                        <input type="radio" name="richeditor" id="richeditor" value="HTML" <%=("HTML".equals(pref)) ? "checked" : "" %> /> <%=XSSUtil.encodeForHTML(context, htmlEditor) %>
                        <!-- //XSSOK -->
                        <br/><input type="radio" name="richeditor" id="richeditor" value="Word" <%=("Word".equals(pref)) ? "checked" : "" %> /> <%=XSSUtil.encodeForHTML(context, word) %>
                </td>
        </tr>
      </table>
    </form>
  </body>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</html>

