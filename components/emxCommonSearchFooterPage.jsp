<%--  emxUIGenericSearchFooterPage.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonSearchFooterPage.jsp.rca 1.12 Wed Oct 22 16:18:51 2008 przemek Experimental przemek $
--%>


<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "emxSearchInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.*" %>



<html>
  <head>
    <link rel="stylesheet" href="../common/styles/emxUIDefault.css" type="text/css" />
    <link rel="stylesheet" href="../common/styles/emxUIList.css" type="text/css" />
    <link rel="stylesheet" href="../common/styles/emxUIDialog.css" type="text/css" />
  </head>

<%
  try
  {
  String I18NResourceBundle = "emxComponentsStringResource";
%>
<script language="javascript">
  function validateLimit() {
   var strQueryLimit = document.bottomCommonForm.QueryLimit.value;

    if (strQueryLimit != "")
    {
      if (isNaN(strQueryLimit) == true)
      {
<%
        String strNaNErrorMsg = i18nNow.getI18nString("emxComponents.Search.LimitMustBeNumeric",I18NResourceBundle,acceptLanguage);
%>
        alert("<%=XSSUtil.encodeForJavaScript(context, strNaNErrorMsg)%>");
        document.bottomCommonForm.QueryLimit.value = 100;
        document.bottomCommonForm.QueryLimit.focus();
      }
      else if (strQueryLimit > 32767)
      {
<%
        String strLimitSizeErrorMsg = i18nNow.getI18nString("emxComponents.Search.LimitMustBeLessThan",I18NResourceBundle,acceptLanguage);
%>
        alert("<%=XSSUtil.encodeForJavaScript(context, strLimitSizeErrorMsg)%>");
        document.bottomCommonForm.QueryLimit.value = 100;
        document.bottomCommonForm.QueryLimit.focus();
      }

      else if (strQueryLimit == 0)
            {
      <%
              String strLimitSizeErrorMsgZero = i18nNow.getI18nString("emxComponents.Search.Alert.Zero",I18NResourceBundle,acceptLanguage);
      %>
              alert("<%=XSSUtil.encodeForJavaScript(context, strLimitSizeErrorMsgZero)%>");
              document.bottomCommonForm.QueryLimit.value = 100;
              document.bottomCommonForm.QueryLimit.focus();
      }

      else if (strQueryLimit < 0)
                  {
            <%
                    String strLimitSizeErrorMsgNegative = i18nNow.getI18nString("emxComponents.Search.Alert.Negative",I18NResourceBundle,acceptLanguage);
            %>
                    alert("<%=XSSUtil.encodeForJavaScript(context, strLimitSizeErrorMsgNegative)%>");
                    document.bottomCommonForm.QueryLimit.value = 100;
                    document.bottomCommonForm.QueryLimit.focus();
            }

       else
            {
           document.bottomCommonForm.QueryLimit.value = strQueryLimit*1;
              var decIndex = strQueryLimit.indexOf(".");
              if(decIndex == -1) {
                  if(parent.searchPane.validateForm) {
                    if(parent.searchPane.validateForm()) {
                      getTopWindow().doSearch();
                    }
                  } else {
                  getTopWindow().doSearch();
                }
              }
              if(decIndex != -1)
                {
                  <%
                    String strLimitSizeErrorMsgDecimal = i18nNow.getI18nString("emxComponents.Search.Alert.Decimal",I18NResourceBundle,acceptLanguage);
                  %>
                  alert("<%=XSSUtil.encodeForJavaScript(context, strLimitSizeErrorMsgDecimal)%>");
                  document.bottomCommonForm.QueryLimit.value = 100;
                  document.bottomCommonForm.QueryLimit.focus();
                }
            }
    }
    else
       {
          if(strQueryLimit == "" || strQueryLimit.length == 0)
          {
            <%
                String strErrorMsg = i18nNow.getI18nString("emxComponents.Search.LimitMustBeNumeric",I18NResourceBundle,acceptLanguage);
            %>
            alert("<%=XSSUtil.encodeForJavaScript(context, strErrorMsg)%>");
            document.bottomCommonForm.QueryLimit.focus();
          }
          else
          {
              var decIndex = strQueryLimit.indexOf(".");
              if(decIndex == -1) {
                  if(parent.searchPane.validateForm) {
                    if(parent.searchPane.validateForm()) {
                      getTopWindow().doSearch();
                    }
                  } else {
                  getTopWindow().doSearch();
                }
               }
              if(decIndex != -1)
               {
                 <%
                  String strLimitSizeErrorMsgDecimal2 = i18nNow.getI18nString("emxComponents.Search.Alert.Decimal",I18NResourceBundle,acceptLanguage);
                  %>
                  alert("<%=XSSUtil.encodeForJavaScript(context, strLimitSizeErrorMsgDecimal2)%>");
                  document.bottomCommonForm.QueryLimit.value = 100;
                  document.bottomCommonForm.QueryLimit.focus();
               }
          }
       }

       return;
     }

  </script>
  <body>
    <form name="bottomCommonForm" method="post">
      <table width="100%" border="0" align="center" cellspacing="0" cellpadding="0">
        <tr>
          <td colspan="2">
          <img src="../common/images/utilSpacer.gif" width="1" height="9" />
          </td>
        </tr>
        <tr>
          <td>
            <table border="0">

<%
  String strQueryTo = i18nNow.getI18nString("emxComponents.PowerSearch.LimitTo",I18NResourceBundle,acceptLanguage);
  String strResults = i18nNow.getI18nString("emxComponents.PowerSearch.Results",I18NResourceBundle,acceptLanguage);
  String strPaginateResults = i18nNow.getI18nString("emxComponents.Search.PaginateResults",I18NResourceBundle,acceptLanguage);
  String strQueryLimit=request.getParameter("QueryLimit");

  String strFind   = i18nNow.getI18nString("emxComponents.Button.Find",I18NResourceBundle,acceptLanguage);
  String strCancel = i18nNow.getI18nString("emxComponents.Button.Cancel",I18NResourceBundle,acceptLanguage);
  if(strQueryLimit == null || strQueryLimit.equals("null") || strQueryLimit.equals("")){
%>
            <tr>
              <td colspan="4">
                &nbsp;<input type="hidden" name="QueryLimit" value="" />
              </td>
            </tr>
          </table>
        </td>
<%
  }else {
    Integer integerLimit = new Integer(strQueryLimit);
    int intLimit = integerLimit.intValue();
    if(intLimit>0){
%>
        <tr>
          <td>
            <%=XSSUtil.encodeForHTML(context, strQueryTo)%>
          </td>
          <td>
            &nbsp;<input type="text" size="5" name="QueryLimit" value="<%=XSSUtil.encodeForHTMLAttribute(context, strQueryLimit)%>" />
          </td>
          <td>
            <%=XSSUtil.encodeForHTML(context, strResults)%>
          </td>

        </tr>
      </table>
    </td>
<% }
else{
%>  <tr>
      <td colspan="4">&nbsp;<input type="hidden" name="QueryLimit" value="" /></td>
    </tr>
  </table>
</td>
<%}
 }
%>
    <td align="right">
    <table border="0" cellspacing="0" cellpadding="0" align="right">
      <tr>
       <td align="right">&nbsp;&nbsp;</td>
       <td align="right" ><a href="javascript:validateLimit()"  ><img src="../common/images/buttonDialogNext.gif" border="0" /></a>&nbsp</td>
       <td align="right" ><a href="javascript:validateLimit()"  ><%=XSSUtil.encodeForHTML(context, strFind)%></a>&nbsp&nbsp;</td>
       <td align="right" ><a href="javascript:getTopWindow().closeWindow()"  ><img src="../common/images/buttonDialogCancel.gif" border="0" /></a>&nbsp</td>
       <td align="right" ><a href="javascript:getTopWindow().closeWindow()"  ><%=XSSUtil.encodeForHTML(context, strCancel)%></a>&nbsp&nbsp;</td>
      </tr>
        </table>
        </td>
        </tr>
      </table>
    </form>
  </body>
</html>

<%
} // End of try
catch(Exception ex) {
   session.putValue("error.message", ex.getMessage());
 } // End of catch
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
