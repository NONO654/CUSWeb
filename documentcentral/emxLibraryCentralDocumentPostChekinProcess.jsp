<%-- emxLibraryCentralDocumentPostChekinProcess.jsp

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@include file ="../emxUICommonAppInclude.inc"%>

<%
     String appDirectory =  (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteLibraryCentral.Directory");
%>

<html>
    <body>
        <script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
        <script language="JavaScript" src="../components/emxComponentsTreeUtil.js" type="text/javascript"></script>
        <script language="javascript" src="../documentcentral/emxLibraryCentralUtilities.js"></script>
        <script>
            try {
				// Changes added start(IR-685083-3DEXPERIENCER2019x)
                //updateCountAndRefreshTreeLBC("<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>", getTopWindow().getWindowOpener().getTopWindow());
                updateCountAndRefreshTreeLBC("%3Cxss:encodeForJavaScript%3E<%=appDirectory%>%3C/xss:encodeForJavaScript%3E", getTopWindow().getWindowOpener().getTopWindow());
				// Changes added end
				getTopWindow().closeWindow();
            }catch (ex) {
            	getTopWindow().closeWindow();
            }
        </script>
    </body>
</html>
