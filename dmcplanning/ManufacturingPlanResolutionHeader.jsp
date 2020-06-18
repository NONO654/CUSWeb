<%-- ManufacturingPlanResolutionHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program   
--%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%
//Define request Parameters for toolbar
String toolbar = emxGetParameter(request, "toolbar");
String strFunctionality = emxGetParameter(request, "functionality");
String HelpMarker = emxGetParameter(request, "HelpMarker");
//Modified for  IR-079555V6R2012
boolean bPrinterFriendly = false;
%>
        <script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUICoreMenu.js"></script>
        <script language="JavaScript" src="../common/scripts/emxUIToolbar.js"></script>         
        <script type="text/javascript">     
            addStyleSheet("emxUIToolbar");
            addStyleSheet("emxUIDialog"); 
        </script>       
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="mx_filterselect_hidden_form" method=post>
<input type="hidden" name="pheader" value=""/>
  <table border="0" cellspacing="2" cellpadding="0" width="100%">
    <tr>
      <td width="99%">
        <table border="0" width="100%" cellspacing="0" cellpadding="0">
          <tr>           
            <%
            String pageHeader = "DMCPlanning.Heading.ManufacturingPlanResolution";
            
            %>
            <td width="1%" nowrap><span class="pageHeader">   
            <emxUtil:i18n localize="i18nId">
            <%=XSSUtil.encodeForHTML(context,pageHeader)%>
            </emxUtil:i18n>

            </span></td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;<img src="../common/images/utilSpacer.gif" width="34" height="28" name="progress"></td>
            <td width="1%"><img src="../common/images/utilSpacer.gif" width="1" height="28" border="0" alt="" vspace="6"></td>
            <td align="right" class="filter">&nbsp;</td>
          </tr>
        </table>
        <table border="0" cellspacing="0" cellpadding="0" width="100%">
          <tr>
            <td class="pageBorder" height="1" ><img src="images/utilSpacer.gif" width="1" height="1" alt=""></td>
          </tr>
        </table>

        <jsp:include page = "../common/emxToolbar.jsp" flush="true">
            <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context,toolbar)%>"/>
            <jsp:param name="suiteKey" value="DMCPlanning"/>
            <jsp:param name="export" value="false"/>
            <jsp:param name="PrinterFriendly" value="<%=XSSUtil.encodeForURL(context, String.valueOf(bPrinterFriendly))%>"/>
            <jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context,HelpMarker)%>"/>  
        </jsp:include>

      </td>
      <td><img src="../common/images/utilSpacer.gif" alt="" width="4"></td>
    </tr>
  </table>
</form>       
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
