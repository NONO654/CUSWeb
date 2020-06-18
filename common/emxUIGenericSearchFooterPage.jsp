<%--  emxUIGenericSearchFooterPage.jsp   -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxUIGenericSearchFooterPage.jsp.rca 1.38 Wed Oct 22 16:09:57 2008 przemek Experimental przemek $
--%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%
  String I18NResourceBundle = "emxFrameworkStringResource";
String pagination = PersonUtil.getPaginationPreference(context);
String I18NResourceBundle1 = "emxSystem";
String acceptLanguage = request.getHeader("Accept-Language");
%>
<form name="bottomCommonForm" onsubmit="validateLimit(); return false">
<!-- //XSSOK -->
<input type="hidden" name="pagination" id="pagination" value="<%=("true".equals(pagination))?"1":"0" %>" />
<table>
<tr>
<td class="functions">
<table>

<%
  String strQueryTo = UINavigatorUtil.getI18nString("emxFramework.PowerSearch.LimitTo",I18NResourceBundle,acceptLanguage);
  String strResults = UINavigatorUtil.getI18nString("emxFramework.PowerSearch.Results",I18NResourceBundle,acceptLanguage);
  String sQueryLimit= emxGetParameter(request,"qlim");
  if( sQueryLimit == null || "".equals(sQueryLimit) || "null".equals(sQueryLimit) )
  {
      sQueryLimit = emxGetParameter(request,"QueryLimit");
  }
  
  //to avoid unbounded query
  if( sQueryLimit == null || "".equals(sQueryLimit) || "null".equals(sQueryLimit) || "0".equals(sQueryLimit))
  {
      sQueryLimit="100";
  }  

  String strFind   = UINavigatorUtil.getI18nString("emxFramework.Button.Find",I18NResourceBundle,acceptLanguage);
  String strCancel = UINavigatorUtil.getI18nString("emxFramework.Button.Cancel",I18NResourceBundle,acceptLanguage);
  if(sQueryLimit == null || sQueryLimit.equals("null") || sQueryLimit.equals("")){%>
    <tr><td><input type="hidden" name="QueryLimit" value="" />  </td></tr>
<%
  }else {
    int intLimit;
    try{
        Integer integerLimit = new Integer(sQueryLimit);
        intLimit = integerLimit.intValue();
    }catch(Exception ex){
      intLimit=100;
    }

    if(intLimit>0){ %>
      <tr><td><xss:encodeForHTML><%=strQueryTo%></xss:encodeForHTML></td><td>&nbsp;<input type="text" size="5" name="QueryLimit" value="<xss:encodeForHTMLAttribute><%=sQueryLimit%></xss:encodeForHTMLAttribute>"/></td>
      <td><%=strResults%></td><td>&nbsp;&nbsp;</td></tr>
 <% }else{%>
      <tr><td>&nbsp;<input type="hidden" name="QueryLimit" value="" />  </td></tr>
<%}
 }
 %>
</table>
</td>
<td class="buttons">
<table>
 <tr>
     <!-- //XSSOK -->
     <td><a class="footericon" href="javascript:window.validateLimit();"><img src="../common/images/buttonDialogNext.gif" border="0" /></a></td>
     <!-- //XSSOK -->
     <td><a onclick="javascript:window.validateLimit();"><button class="btn-primary" type="button"><%=strFind%></button></a></td>
     <!-- //XSSOK -->
     <td><a class="footericon" href="javascript:getTopWindow().closeWindow();"  ><img src="../common/images/buttonDialogCancel.gif" border="0" /></a></td>
     <!-- //XSSOK -->
     <td><a onclick="javascript:getTopWindow().closeWindow();"><button class="btn-default" type="button"><%=strCancel%></button></a></td>
  </tr>
 </table>
 </td>
  </tr>
 </table>
</form>
