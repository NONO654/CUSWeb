<%--  emxEngineeringMyViewPreference.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>


<%@page import="java.util.regex.Pattern"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.PropertyUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<html>
  <head>
    <title></title>
    <meta http-equiv="imagetoolbar" content="no" />
    <meta http-equiv="pragma" content="no-cache" />
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIModal.js" type="text/javascript"></SCRIPT>
    <SCRIPT language="JavaScript" src="../common/scripts/emxUIPopups.js" type="text/javascript"> </SCRIPT>
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
                String colMappings = emxGetParameter(request, "ColumnMappings");
                                
                if(UIUtil.isNotNullAndNotEmpty(colMappings)) {
                        PropertyUtil.setAdminProperty(context, "Person", context.getUser(), "preference_BOMImportColumnMappings", colMappings.trim());
                }
                else 
                {
                        colMappings = PropertyUtil.getAdminProperty(context, "Person", context.getUser(), "preference_BOMImportColumnMappings");
                        if(UIUtil.isNullOrEmpty(colMappings)) {
                                colMappings = MqlUtil.mqlCommand(context, "print page $1 select $2 dump", "ENCImportBOMColumnMapping", "content");
                        }
                }
                
        String accLanguage  = request.getHeader("Accept-Language");
%>
  <script language="JavaScript" type="text/javascript">
  function validationRoutine(){
    var theForm = document.forms[0];
    return true;
  }

  </script>
  <body onload="doLoad() ,turnOffProgress()">
    <form method="post" action="ENCImportBOMColumnMapping.jsp?action=submit" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
      <table border="0" cellpadding="5" cellspacing="2"
             width="100%">
       
        <tr>
        <!-- XSSOK -->
                <td width="150" class="label">
                        <%=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ImportEBOM.EBOMImportColumnMappings") %>
                </td>
                <td class="textarea">
                                        <textarea name="ColumnMappings" id="ColumnMappings" cols="35" rows="3"><xss:encodeForHTMLAttribute><%=colMappings%></xss:encodeForHTMLAttribute></textarea>
                                </td>
        </tr>
      </table>
    </form>
  </body>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

</html>

