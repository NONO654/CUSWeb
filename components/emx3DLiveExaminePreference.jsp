<%--  
	emx3DLiveExaminePreference.jsp
   	Copyright (c) 1992-2018 Dassault Systemes.
--%>



<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%><html>
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
      function doLoad() {
          if (document.forms[0].elements.length > 0) {
            var objElement = document.forms[0].elements[0];
                                                                  
            if (objElement.focus) objElement.focus();
            if (objElement.select) objElement.select();
          }
        }
    </script>
  </head>
<%
	
	String accLanguage  = request.getHeader("Accept-Language");
	String showPref = i18nNow.getI18nString("emxComponents.3DLiveExamine.ShowPreference", "emxComponentsStringResource",accLanguage);
	String hidePref = i18nNow.getI18nString("emxComponents.3DLiveExamine.HidePreference", "emxComponentsStringResource",accLanguage);
	String channel3D = i18nNow.getI18nString("emxComponents.3DLiveExamine.3DLiveExamineChannel", "emxComponentsStringResource",accLanguage);
	
	String pref3DLive = PropertyUtil.getAdminProperty(context, "Person", context.getUser(), "preference_3DLiveExamineToggle");
	
%>
  <body onload="doLoad() ,turnOffProgress()">
    <form method="post" action="emx3DLiveExaminePreferenceProcess.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
      <table border="0" cellpadding="5" cellspacing="2"
             width="100%">
       
        <tr>
                <td width="150" class="label">
                      	<%=XSSUtil.encodeForHTML(context, channel3D) %>
                </td>
                <td class="inputField">
			            <!-- //XSSOK -->
                        <input type="radio" name="3DLiveExamineChannel" id="3DLiveExamineChannel" value="Show" <%=("Show".equals(pref3DLive)) ? "checked" : "" %> /> <%=XSSUtil.encodeForHTML(context, showPref) %>
                        <!-- //XSSOK -->
                        <br/><input type="radio" name="3DLiveExamineChannel" id="3DLiveExamineChannel" value="Hide" <%=("Hide".equals(pref3DLive)) ? "checked" : "" %> /> <%=XSSUtil.encodeForHTML(context, hidePref) %>
                </td>
        </tr>
      </table>
    </form>
  </body>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</html>

