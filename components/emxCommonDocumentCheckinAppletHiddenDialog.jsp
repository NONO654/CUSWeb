<%-- emxCommonDocumentCheckinAppletHiddenDialog.jsp - used for Checkin of file into Document Object
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckinAppletHiddenDialog.jsp.rca 1.8 Wed Oct 22 16:18:33 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxContentTypeInclude.inc"%>
<%@include file = "emxComponentsCheckin.inc"%>
<form name="hiddenForm" action="emxCommonDocumentCheckinAppletHiddenProcess.jsp" method="post">
<input type="hidden" name="noOfFiles" />
<input type="hidden" name="store" />
<input type="hidden" name="objectId" />
<%
    Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");
    String objectAction        = (String) emxCommonDocumentCheckinData.get("objectAction");


    if (objectAction == null || objectAction.equals("") )
    {
        objectAction = "create";
    }

    String showTitle        = (String) emxCommonDocumentCheckinData.get("showTitle");
    String maxNoOfFilesStr = EnoviaResourceBundle.getProperty(context,"emxFramework.Applet.MaximumNoFilesLimit");
    int maxNoOfFiles = (new Integer(maxNoOfFilesStr)).intValue();
    for (int i=0; i<=maxNoOfFiles; i++)
    {
%>
        <input type="hidden" name="fileName<%=i%>" />
          <input type="hidden" name="comments<%=i%>" />
          <input type="hidden" name="description<%=i%>" />
<%
        if ( "true".equalsIgnoreCase(showTitle) || "required".equalsIgnoreCase(showTitle))
        {
%>
          <input type="hidden" name="title<%=i%>" />
<%
        }
%>
          <input type="hidden" name="format<%=i%>" />
<%

    }
%>
</form>
</body>
</html>
