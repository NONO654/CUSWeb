<%-- emxProgramCentralNavigatorBottomErrorInclude.jsp -- Bottom error ipage in emx Navigator

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxProgramCentralNavigatorBottomErrorInclude.inc.rca 1.9 Wed Oct 22 15:48:33 2008 przemek Experimental przemek $";
--%>

<%@include file = "../emxMQLNotice.inc"%>
<%   if(request.getAttribute("useScriptTags") == null){ %>
<script language="JavaScript">
<% } %>
    var DisplayErrorMsg = "";
<% 
    // Get the session error messages and display them
    if (session.getAttribute("error.message") != null)
    {
        String emxSessionErrorMsg = (String)session.getAttribute("error.message");
        session.removeAttribute("error.message");

        if ( (emxSessionErrorMsg != null) && (emxSessionErrorMsg.trim().length() > 0 ) )
        {
	        //Modified for Bug 372874
            //emxSessionErrorMsg = emxSessionErrorMsg.replace('\'', '\"');
	        emxSessionErrorMsg = emxSessionErrorMsg.replace("\"", "\\\"");
            // System.out.println("emxSessionErrorMsg : " + emxSessionErrorMsg);

            // Parse the string for "\n" so that the string can be displayed properly in Javascript
            StringTokenizer token = new StringTokenizer(emxSessionErrorMsg, "\n");
            while (token.hasMoreTokens())
            {
                String strMsg =token.nextToken().trim();
                // System.out.println("strMsg : " + strMsg);
%>
                DisplayErrorMsg += "<%=strMsg%>" + "\n";   <%-- XSSOK --%>
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
	   		//Modified for Bug 372874
            //emxNavigatorErrorMsg = emxNavigatorErrorMsg.replace('\'', '\"');
	  		emxNavigatorErrorMsg = emxNavigatorErrorMsg.replace("\"", "\\\"");
            // System.out.println("emxNavigatorErrorMsg : " + emxNavigatorErrorMsg);

            // Parse the string for "\n" so that the string can be displayed properly in Javascript
            StringTokenizer token = new StringTokenizer(emxNavigatorErrorMsg, "\n");
            while (token.hasMoreTokens())
            {
                String strMsg =token.nextToken().trim();
                // System.out.println("strMsg : " + strMsg);
%>
                DisplayErrorMsg += "<%=strMsg%>" + "\n";  <%-- XSSOK --%>
<%
            }
%>
            alert(DisplayErrorMsg);
<%
        }
    }
      if(request.getAttribute("useScriptTags") == null){
%>
</script>
<% } %>
