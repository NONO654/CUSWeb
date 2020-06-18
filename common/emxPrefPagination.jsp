<%--  emxPrefPagination.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxPrefPagination.jsp.rca 1.7 Wed Oct 22 15:48:48 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>

<html>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

  <head>
    <title></title>
    <meta http-equiv="imagetoolbar" content="no" />
    <meta http-equiv="pragma" content="no-cache" />
    <script language="JavaScript" src="scripts/emxUIConstants.js" type="text/javascript">
    </script>
    <script language="JavaScript" src="scripts/emxUICore.js"></script>
    <script language="JavaScript" src="scripts/emxUIModal.js" type="text/javascript">
    </script>
    <script language="JavaScript" src="scripts/emxUIPopups.js" type="text/javascript">
    </script>
    <script type="text/javascript">
      addStyleSheet("emxUIDefault");
      addStyleSheet("emxUIForm");
    </script>
  </head>
  <%
        String pagination="";
        String paginationRange="";
        String paginationYesSelected="";
        String paginationNoSelected="";

        pagination = PersonUtil.getPagination(context);
        paginationRange=PersonUtil.getPaginationRange(context);

        if( (pagination == null) || (pagination.equals("null")) || (pagination.equals("")) || (pagination.equals("true") ))
        {
            paginationYesSelected="checked";
        }
        else
        {
            paginationNoSelected="checked";
        }

        if( (paginationRange == null) || (paginationRange.equals("null")) || (paginationRange.equals("")))
                paginationRange="10";



  %>
  <script language="JavaScript" type="text/javascript">
  function validationRoutine(){
    var theForm = document.forms[0];
    var theField = theForm["txtPageRange"];
    if(isNaN(theField.value)){
        alert("<emxUtil:i18nScript localize="i18nId">emxFramework.FormComponent.MustEnterAValidNumericValueFor</emxUtil:i18nScript> <emxUtil:i18n localize="i18nId">emxFramework.PaginationPreference.Items</emxUtil:i18n>");
        return false;
    }
    return true;
  }

  </script>
  <body onload="turnOffProgress()">
    <form method="post" action="emxPrefPaginationProcessing.jsp" onsubmit="findFrame(getTopWindow(),'preferencesFoot').submitAndClose()">
      <table border="0" cellpadding="5" cellspacing="2"
             width="100%">
        <tr>
          <td width="150" class="label">
            <emxUtil:i18n localize="i18nId">emxFramework.PaginationPreference.PaginateAllListPages</emxUtil:i18n>
          </td>
          <td class="inputField">
                <table>
                        <tr>
                                <td><input type="radio" name="prefPagination" id="prefPagination" value="true" <%=paginationYesSelected%> /><emxUtil:i18n localize="i18nId">emxFramework.PaginationPreference.Yes</emxUtil:i18n></td>
                        </tr>
                        <tr>
                        <td><input type="radio" name="prefPagination" id="prefPagination" value="false" <%=paginationNoSelected%> /><emxUtil:i18n localize="i18nId">emxFramework.PaginationPreference.No</emxUtil:i18n></td>
                        </tr>
                </table>
            </td>
        </tr>
        <tr>
                <td width="150" class="label">
                        <emxUtil:i18n localize="i18nId">emxFramework.PaginationPreference.Items</emxUtil:i18n>
                </td>
                <td class="inputField">
                        <input type="text" name="txtPageRange" id="txtPageRange" value="<%=paginationRange%>" />
                </td>
        </tr>
      </table>
    </form>
  </body>

<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</html>

