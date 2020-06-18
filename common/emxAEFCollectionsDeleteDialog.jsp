<%--  emxCollectionDeleteDialog.jsp   -  This page displays options for deleting Collections.
   Copyright (c) 199x-2003 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

      static const char RCSID[] = $Id: emxAEFCollectionsDeleteDialog.jsp.rca 1.5 Wed Oct 22 15:48:52 2008 przemek Experimental przemek $
--%>


<%
  // ----------------- Include Static Pages Here ------------------------------
%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxCompCommonUtilAppInclude.inc"%>
<script language="JavaScript" src="scripts/emxUICollections.js" type="text/javascript"></script>

<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>

<%
  // ----------------- Variable Declarations Here ------------------------------
%>

<%
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String objectId = emxGetParameter(request,"objectId");
  String initSource = emxGetParameter(request,"initSource");
  String suiteKey = emxGetParameter(request,"suiteKey");

  //hardcoded for now: known issue
  if(suiteKey == null || suiteKey.equals("") || suiteKey.equals("null"))
     suiteKey = "eServiceSuiteEngineeringCentral";


  //Declare display variables
  String sCollectionNames  = emxGetParameter(request, "selectedCollections");
  
  boolean isCPFUser = FrameworkLicenseUtil.isCPFUser(context);

  // ------ Include any Javascript functions needed in page here ----------
  // ------ If common Javascript functions, use include for a .js file --------
%>

<script language="Javascript">

  function submit() {
    document.formConfirmDelete.submit();
  }

</script>

<%
  // ----------------------- Header End Include Here -----------------------
%>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  // ------------------------ Page content below here  ---------------------
%>

<form name="formConfirmDelete" method="post" onsubmit="submit(); return false" action="emxAEFCollectionsDeleteProcess.jsp">
  <table width="100%" border="0" cellpadding="3" cellspacing="2">
    <input type="hidden" name="Collections" value="<xss:encodeForHTMLAttribute><%=sCollectionNames%></xss:encodeForHTMLAttribute>" />
     <tr>
       <td class="label">
         <table border="0" cellpadding="3" cellspacing="2">
           <tr>
             <td nowrap class="label"><emxUtil:i18n localize="i18nId">emxFramework.Collections.ScopeOfDeletion</emxUtil:i18n></td>
           </tr>
         </table>
       </td>
       <td class="inputField">
       <table border="0" cellpadding="2" cellspacing="1">
         <tr>
            <td> <input name="deleteRadio" type="radio" value="false" checked />
            </td>
            <td><emxUtil:i18n localize="i18nId">emxFramework.Collections.OnlyCollection</emxUtil:i18n>
            </td>
         </tr>
         <tr>
            <td>&nbsp;</td>
            <td><emxUtil:i18n localize="i18nId">emxFramework.Collections.OnlyCollectionInfo</emxUtil:i18n>
            </td>
          </tr>
<%
    if (isCPFUser)
    {
%>
          <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr>
             <td> <input name="deleteRadio" type="radio" value="true" />
             </td>
             <td><emxUtil:i18n localize="i18nId">emxFramework.Collections.CollectionItems</emxUtil:i18n>
             </td>
          </tr>
          <tr>
             <td>&nbsp;</td>
             <td><emxUtil:i18n localize="i18nId">emxFramework.Collections.CollectionItemsInfo</emxUtil:i18n>
             </td>
          </tr>
<%
    }
%>
       </table>
       &nbsp;</td>
       </tr>
</table>
</form>

<%
  // ------------------------ Page content above here  ---------------------
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
