<%-- emxTaskUpdateCommentsDialog.jsp -- Dialog Page to Update the Rejection Comments.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxTaskUpdateCommentsDialog.jsp.rca 1.9 Wed Oct 22 16:17:55 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxJSValidation.inc" %>

<%
  String strCommentsAttr = PropertyUtil.getSchemaProperty(context, "attribute_Comments" );
  String isFDAEnabled =  EnoviaResourceBundle.getProperty(context,"emxFramework.Routes.EnableFDA");
String objectId      = emxGetParameter(request,"objectId");
String routeId      = emxGetParameter(request,"routeId");
String approvalStatus      = emxGetParameter(request,"approvalStatus");
String Comments      = emxGetParameter(request,"Comments");
%>

<script language="Javascript" type="text/javascript">

  // function to submit the form
  function submitForm() {
  
    document.rejectComments.Comments.value = trimWhitespace(document.rejectComments.Comments.value);
    var commentsVal = document.rejectComments.Comments.value;

    if (commentsVal.length==0) {
    
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.RejectComments.Comments</emxUtil:i18nScript>");
      document.rejectComments.Comments.focus();
      return;
      
    } 
    
    //Bug 308433 
     var badChars = checkForBadChars(document.rejectComments.Comments);
    // end fix
    if (badChars != "") {
    
      alert("<emxUtil:i18nScript localize="i18nId">emxComponents.ErrorMsg.InvalidInputMsg</emxUtil:i18nScript>\n"+badChars);
      document.rejectComments.Comments.focus();
      return;
      
    } else {

      eval("var parentObj  = parent.window.getWindowOpener().document.frmTaskDetails;");
      eval("var commentObj = parent.window.getWindowOpener().document.frmTaskDetails['<%=XSSUtil.encodeForJavaScript(context, strCommentsAttr)%>'];");
      
      if(commentsVal != ' ' && commentsVal != "null") {
        commentObj.value = commentsVal +" "+commentObj.value;
      }
      <% 
      if(isFDAEnabled != null && "true".equalsIgnoreCase(isFDAEnabled))
      {
        %>
                document.rejectComments.target="_top";
                document.rejectComments.action="emxComponentsUserAuthenticationDialogFS.jsp?taskId=<%=XSSUtil.encodeForURL(context, objectId)%>&routeId=<%=XSSUtil.encodeForURL(context, routeId)%>&approvalStatus=<%=XSSUtil.encodeForURL(context, approvalStatus)%>&Comments="+commentObj.value;
                document.rejectComments.submit();
     <%
        }else{
       %>
                parentObj.submit();
                window.closeWindow();
        <%
                }
        %>
    }
  }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form name="rejectComments" onSubmit="javascript:submitForm(); return false" method="post" action="" >
  <table border="0" cellpadding="5" cellspacing="2" width="400">
    <tr>
      <td class="labelRequired"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.Common.Comments</emxUtil:i18n></label></td>
      <td class="field" ><textarea name="Comments" cols="30" rows="5" wrap></textarea></td>
    </tr>
  </table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>



