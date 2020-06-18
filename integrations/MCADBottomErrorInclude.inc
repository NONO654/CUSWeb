<%--  MCADBottomErrorInclude.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%-- MCADBottomErrorInclude.inc -- Bottom error ipage in emx Navigator

   static const char RCSID[] = "$Id: /ENODesignerCentral/CNext/webroot/integrations/MCADBottomErrorInclude.inc 1.3 Sat Apr 26 10:22:24 2008 GMT ds-mbalakrishnan Experimental$";
--%>

<script language="JavaScript">
    var DisplayErrorMsg = "";
<%
    // Get the session error messages and display them
    if (session.getAttribute("error.message") != null)
    {
        String emxSessionErrorMsg = (String)session.getAttribute("error.message");
        session.removeAttribute("error.message");

        if ( (emxSessionErrorMsg != null) && (emxSessionErrorMsg.trim().length() > 0 ) )
        {
            emxSessionErrorMsg = emxSessionErrorMsg.replace('\'', '\"');
            // System.out.println("emxSessionErrorMsg : " + emxSessionErrorMsg);

            // Parse the string for "\n" so that the string can be displayed properly in Javascript
            StringTokenizer token = new StringTokenizer(emxSessionErrorMsg, "\n");
            while (token.hasMoreTokens())
            {
                String strMsg =token.nextToken().trim();
                // System.out.println("strMsg : " + strMsg);
%>
                //XSSOK
                DisplayErrorMsg += "<%=strMsg%>" + '\n';
<%
            }
%>
            alert(DisplayErrorMsg);
<%
        }
    }

    // get the error object within this request scope
    // Object "emxNavErrorObject" and the display the message.
    if (emxNavErrorObject != null)
    {
        String emxNavigatorErrorMsg = emxNavErrorObject.toString();
        // System.out.println("emxNavigatorErrorMsgList size : " + emxNavigatorErrorMsgList.size());

        if ( (emxNavigatorErrorMsg != null) && (emxNavigatorErrorMsg.trim().length() > 0 ) )
        {
            emxNavigatorErrorMsg = emxNavigatorErrorMsg.replace('\'', '\"');
            // System.out.println("emxNavigatorErrorMsg : " + emxNavigatorErrorMsg);

            // Parse the string for "\n" so that the string can be displayed properly in Javascript
            StringTokenizer token = new StringTokenizer(emxNavigatorErrorMsg, "\n");
            while (token.hasMoreTokens())
            {
                String strMsg =token.nextToken().trim();
                // System.out.println("strMsg : " + strMsg);
%>
                //XSSOK
                DisplayErrorMsg += "<%=strMsg%>" + '\n';
<%
            }
%>
            alert(DisplayErrorMsg);
<%
        }
    }
%>
</script>
