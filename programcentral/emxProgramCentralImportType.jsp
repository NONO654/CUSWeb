<%--
  emxProgramCentralImportType.jsp

  Creates a type by importing from a csv file.

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program.

  static const char RCSID[] = "$Id: emxProgramCentralImportType.jsp.rca 1.16 Wed Oct 22 15:49:23 2008 przemek Experimental przemek $";
--%>

<%@include file="emxProgramGlobals2.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>

<%
  String objectId   = (String) emxGetParameter(request, "objectId");
  String importType = (String)session.getAttribute("importType");
  String header     = (String) emxGetParameter(request, "header");
  String printerFriendly = emxGetParameter(request,"PrinterFriendly");
  if(printerFriendly == null)
  {
    printerFriendly = "false";
  }
%>

<html>
  <body class="white">
    <form name="TypeImport" action="emxProgramCentralImportSummary.jsp" method="post" enctype="multipart/form-data" onsubmit="validateForm ();return false">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="importType" value="<xss:encodeForHTMLAttribute><%=importType%></xss:encodeForHTMLAttribute>" />

      <table border="0" width="100%">
        <tr>
          <td>
            <table border="0" width="100%">
              <tr>
                <td class="labelRequired" width="20%" align="right" nowrap="nowrap">
                  <framework:i18n localize="i18nId">emxProgramCentral.Common.ImportFromFile</framework:i18n>
                </td>
   <%-- XSSOK--%>    
                    <framework:ifExpr expr='<%=!printerFriendly.equals("true")%>'>
                   <td class="field" width="80%"><input type="file" name="FilePath" size="18" /></td>
                </framework:ifExpr>
              </tr>

            </table>
          </td>
        </tr>
      </table>
      
      <!--
	  Unnecessary button image displayed on UI while Risk Import hence commented below line : 
      <input type="image" name="inputImage" height="1" width="1" src="../common/images/utilSpacer.gif" hidefocus="hidefocus" style="-moz-user-focus: none" /> 
      -->
    </form>
  </body>

  <script language="javascript" type="text/javaScript">//<![CDATA[
  <!-- hide JavaScript from non-JavaScript browsers
 if(<%=!printerFriendly.equals("true")%>)   <%-- XSSOK--%> 
  {
    f = document.TypeImport;

    turnOffProgress();

    function backUp() {
      parent.getTopWindow().refreshTablePage();//modified to make Refresh work in Netscape & IE
      parent.window.closeWindow();
    }

    function cancel() {
      //parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
      parent.window.closeWindow();
    }

    function validateForm () {
      var iValidForm = 0;
      var filePath = f.FilePath.value;

      if (f.FilePath.value == "" ) {
      alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Project.ChooseFile</emxUtil:i18nScript>");
      f.FilePath.focus();
      iValidForm++;
      } else {
       var fileExtensionMarker = filePath.lastIndexOf(".");
       var fileExtension = filePath.substring(fileExtensionMarker+1, filePath.length);
       if (fileExtension != "csv") {
         alert("<emxUtil:i18nScript localize="i18nId">emxProgramCentral.Import.WrongFileExtension</emxUtil:i18nScript>");
         iValidForm++;
       }
      }
      if (iValidForm > 0 ) {
      return ;
      }
      startProgressBar(false);
      f.submit();
    }
  }
  //Stop hiding here -->//]]>
  </script>
</html>
