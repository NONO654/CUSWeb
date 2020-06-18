<%--  emxObjectCompareHtmlExport.jsp  
      Copyright (c) 1992-2018 Dassault Systemes.
      All Rights Reserved. 
      This program contains proprietary and trade secret information of MatrixOne,Inc.
      Copyright notice is precautionary only   and does not evidence any actual or intended publication of such program  

      static const char RCSID[] = $Id: emxObjectCompareHtmlExport.jsp.rca 1.4 Wed Oct 22 15:48:01 2008 przemek Experimental przemek $
--%>
<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
      String acceptLanguage=request.getHeader("Accept-Language");
      String header=i18nNow.getI18nString("emxFramework.ObjectCompare.PrinterFriendlyHeading", "emxFrameworkStringResource", acceptLanguage);
      header=header.replace(' ','_');
      long startTime = System.currentTimeMillis();
      String fileName = header+ startTime;


      String fileEncodeType = UINavigatorUtil.getFileEncoding(context, request);

      response.setContentType("text/html; charset="+fileEncodeType);

      String fileCreateTimeStamp = Long.toString(System.currentTimeMillis());
      String filename = header + fileCreateTimeStamp;
      fileName = FrameworkUtil.encodeURL(fileName,"UTF8");
      fileName=fileName + ".html"; 
      response.setHeader ("Content-Disposition","inline; filename=\"" + fileName +"\"");
      response.setLocale(request.getLocale());
      String reportFormat = emxGetParameter(request, "reportFormat");
%>
     <jsp:include page = "emxObjectCompareReportBody.jsp" flush="true">
        <jsp:param name="reportFormat" value="<%=XSSUtil.encodeForURL(context, reportFormat)%>"/>
     </jsp:include>
</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc" %>
</html>
