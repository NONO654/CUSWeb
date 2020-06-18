<%--  emxComponentsViewMyCompanyDetailsFS.jsp -- This page displays the details of a company.

  Copyright (c) 1992-2018 Dassault Systemes. All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxComponentsViewMyCompanyDetailsFS.jsp.rca 1.6 Wed Oct 22 16:18:52 2008 przemek Experimental przemek $;
--%>

<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxComponentsFramesetUtil.inc"%>

<%
  String jsTreeID  = emxGetParameter(request,"jsTreeID");
  String suiteKey  = emxGetParameter(request,"suiteKey");
  String companyId = null; 

  // Get the Organization id of the logged-in Person
  try {
    companyId = Person.getPerson(context).getCompanyId(context);
  } catch (Exception exception) {
    if (companyId == null ) {
%>
      <HTML>
      <table border="0" cellspacing="0" cellpadding="0" width="100%">
       <tr><td>&nbsp;</td></tr>
       <tr>
         <td class="errorMessage">
           <%=context.getUser()%>&nbsp;<emxUtil:i18n localize="i18nId">emxProfileManager.Common.Header</emxUtil:i18n>
         </td>
       </tr>
       <tr><td>&nbsp;</td></tr>
      </table>
      <jsp:include page = "eServiceEnd.jsp" flush="true" />
<%
      return;
    } else  {
%>
      <table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tr><td>&nbsp;</td></tr>
        <tr>
          <td class="errorMessage"><%=exception.getMessage()%></td>
        </tr>
        <tr><td>&nbsp;</td></tr>
      </table>
      <jsp:include page = "eServiceEnd.jsp" flush="true" />
<%
      return;
    }
  }

  String href = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, companyId)  +"&mode=insert&jsTreeID=" + XSSUtil.encodeForURL(context, jsTreeID) + "&suiteKey=" + XSSUtil.encodeForURL(context, suiteKey) ;
%>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script>
//XSSOK
getTopWindow().showModalDialog("<%=href%>","812","700",true ,"","Medium");
</script>
<BODY>
</BODY>
</HTML>
