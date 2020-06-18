<%--  emxCompDeleteMail.jsp   -  This page deletes mail(s) of a matrix user.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
  static const char RCSID[] = $Id: emxCompDeleteMail.jsp.rca 1.12 Wed Oct 22 15:48:36 2008 przemek Experimental przemek $
--%>

<%@page import     ="java.util.*" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file ="emxCompCommonUtilAppInclude.inc" %>

<!-- content begins here -->
<%
  //Get all the icon mail numbers to be deleted
  StringBuffer sMailIdPattern = new StringBuffer(100);
  boolean bMailDetail=false;
  String sArrayMailId[] = emxGetParameterValues(request, "chkbxMailId");
  String sMailstatus        = emxGetParameter(request,"mx.page.filter");
  String sPageNumber        = emxGetParameter(request,"pageNum");
  String showPaginationMinimized =emxGetParameter(request,"showPaginationMinimized");
  if(sArrayMailId!=null) {
    for (int iIndex = 0; iIndex < sArrayMailId.length ; iIndex++) {
        sMailIdPattern.append(sArrayMailId[iIndex]);
        sMailIdPattern.append(",");
    }

  } else {
    sMailIdPattern.append(emxGetParameter(request, "mailId"));
    bMailDetail=true;

  }

  //Create a pattern of the mail numbers received to delete
  if(sMailIdPattern.toString() != null) {
    Pattern patternMailId = new Pattern(sMailIdPattern.toString());
    IconMailItr iconMailItrGeneric = new IconMailItr(IconMail.getMail(context));

    //Iterate through all the mails of the current user,
    //Match each icon mail number with the created pattern,
    //if matches then remove the corresponding icon mail.
    while (iconMailItrGeneric.next()) {
      IconMail iconMailObj = iconMailItrGeneric.obj();
      if (patternMailId.matchList(String.valueOf(iconMailObj.getNumber()))) {
        try {
          iconMailObj.open(context, new Visuals());
          iconMailObj.remove(context);
          iconMailObj.close(context);
        } catch (MatrixException exception) {
          session.setAttribute("error.message", exception.getMessage());
          break;
        }
      }
    }
  }

if(!bMailDetail) {
%>

<form name="newForm" target="_parent">
  </form>
<script language="javascript">
  parent.document.location.href="emxCompInboxDialogFS.jsp?mx.page.filter=<%=XSSUtil.encodeForURL(context, sMailstatus)%>";
</script>

<%
} else {

%>
<html>
<body>
<script language="javascript">
 getTopWindow().window.getWindowOpener().parent.document.location.href="emxCompInboxDialogFS.jsp";
 getTopWindow().closeWindow();
</script>
</body>
</html>
<%
}
%>
