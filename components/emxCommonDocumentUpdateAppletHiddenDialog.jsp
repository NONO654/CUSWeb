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
<html>
<body>
<form name="hiddenForm" action="emxCommonDocumentUpdateAppletHiddenProcess.jsp" method="post">
<input type="hidden" name="noOfFiles" />
<input type="hidden" name="store" />


<%
    Map emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");
    String objectAction        = (String) emxCommonDocumentCheckinData.get("objectAction");
    
    if (objectAction == null || objectAction.equals("") )
    {
        objectAction = "update";
    }
    
    String fcsChunkThreshold = null;
    String fcsChunkSize      = null;
    try
    {
       fcsChunkThreshold = EnoviaResourceBundle.getProperty(context,"emxFramework.Applet.fcsChunkThreshold");
       fcsChunkSize      = EnoviaResourceBundle.getProperty(context,"emxFramework.Applet.fcsChunkSize");
    }
    catch (Throwable TEx)
    {}
    if ((null == fcsChunkThreshold) || (0 >= fcsChunkThreshold.length())) fcsChunkThreshold = "";
    if ((null == fcsChunkSize) || (0 >= fcsChunkSize.length()))  fcsChunkSize = "";
    
    emxCommonDocumentCheckinData.put("fcsChunkThreshold", fcsChunkThreshold);
    emxCommonDocumentCheckinData.put("fcsChunkSize", fcsChunkSize);
    emxCommonDocumentCheckinData.put("objectAction", objectAction);
    
    
    String maxNoOfFilesStr = EnoviaResourceBundle.getProperty(context,"emxFramework.Applet.MaximumNoFilesLimit");
    int maxNoOfFiles = (new Integer(maxNoOfFilesStr)).intValue();
    //int maxNoOfFiles = 0;
    for (int i=0; i<=maxNoOfFiles; i++)
    {
%>
        <input type="hidden" name="fileName<%=i%>" />
        <input type="hidden" name="comments<%=i%>" />
        <input type="hidden" name="oldFileName<%=i%>" />
        <input type="hidden" name="format<%=i%>" />
<%
    }

%> 

</form>
</body>
</html>   
