<%--  emxpartCreateSubstitutePartProcess.jsp  - To edit attributes
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>

<%@include file = "emxEngrStartUpdateTransaction.inc"%>
<%
  Part part = (Part)DomainObject.newInstance(context,
                  DomainConstants.TYPE_PART,DomainConstants.ENGINEERING);
  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");

  String objectId = emxGetParameter(request,"objectId");
  String bomId = emxGetParameter(request,"bomId");
  String checkBoxId[] = emxGetParameterValues(request,"selectedPart");

  String url = "";

  try {
     String sDuplicateMessage ="";
     String sMessage = "Create Successful";

     // Create attribute list to be set on Component substitution relationship
     String sRelId = emxGetParameter(request,"bomRelId");
     part.setId(objectId);
     String sAssemblyName = part.getName(context);
     String sAssemblyRev = part.getRevision(context);
     String sAssType = part.getType(context);

     if(checkBoxId != null )
     {
        for(int i=0;i<checkBoxId.length;i++)
        {
           part.createSubstitutePart(context, bomId, sRelId, checkBoxId[i]);
      }
     }
  }
  catch(Exception e)
  {
   String backURL = "emxpartCreateSubstitutePartDialog1FS.jsp?objectId="+objectId+"&bomInfo="+bomId;
    session.putValue("error.message",e.getMessage());
 %>
    <%@include file = "emxEngrAbortTransaction.inc"%>
    <!--XSSOK-->
    <jsp:forward page="<%=XSSUtil.encodeForJavaScript(context,backURL)%>" />
<%
  }
  finally
  {
     url = "emxpartReviewSubstitutePartSummary.jsp" + "?objectId=" + objectId + "&jsTreeID=" + jsTreeID + "&suiteKey=" + suiteKey;
  }
%>
<%@include file = "emxEngrCommitTransaction.inc"%>
<%@include file = "emxDesignBottomInclude.inc"%>
<script language="Javascript">
  parent.window.getWindowOpener().parent.location.href =parent.window.getWindowOpener().parent.location.href;
  parent.closeWindow();
</script>

