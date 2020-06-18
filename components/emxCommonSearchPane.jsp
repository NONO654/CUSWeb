<%--  emxCommonSearchPane.jsp  -

   This is a intermediate page used to create hidden field for the search pages.

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonSearchPane.jsp.rca 1.7 Wed Oct 22 16:18:44 2008 przemek Experimental przemek $
--%>


<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file  ="../emxContentTypeInclude.inc" %>
<html>
  <body>
    <form name="searchPane" method="post" action="">
<%

      String strHREF = (String)session.getValue("searchHREF");
      if(strHREF!= null && !"".equals(strHREF)&&!"null".equals(strHREF)) {
        int indexOfQuery    = strHREF.indexOf("?");
        String sURL         = strHREF.substring(0, indexOfQuery);
        String sParam       = strHREF.substring(indexOfQuery+1);
        if(sParam!= null && !"".equals(sParam)&&!"null".equals(sParam)) {
          StringTokenizer paramToken = new StringTokenizer(sParam,"&");
          int index=0;
          while(paramToken.hasMoreTokens()) {
            String sParameters = (String)paramToken.nextToken();
            index = sParameters.indexOf("=");
            if(index>0) {
%>
              <input type="hidden" name="<%=sParameters.substring(0,index)%>" value="<xss:encodeForHTMLAttribute><%=sParameters.substring(index+1)%></xss:encodeForHTMLAttribute>"/>
<%
            }
          }
        }
%>
        <script language = "javascript">
          document.searchPane.action="<%=XSSUtil.encodeForJavaScript(context, sURL)%>";
          document.searchPane.submit();
        </script>
<%
      }
      session.removeAttribute("searchHREF");
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

    </form>
  </body>
</html>
