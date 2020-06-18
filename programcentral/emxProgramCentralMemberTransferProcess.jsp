<%--  emxProgramCentralMemberTransferProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information
  of MatrixOne, Inc.  Copyright notice is precautionary only and
  does not evidence any actual or intended publication of such program
--%>

<%--
Change History:
Date       Change By  Release   Bug/Functionality        Details
-----------------------------------------------------------------------------------------------------------------------------
6-Apr-09   wqy        V6R2010   370793                   Removed "if loop" block of alert if there is any error while executing mql statements.

--%>
<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>

<%
  com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK, DomainConstants.PROGRAM);
  String jsTreeID = emxGetParameter(request, "jsTreeID");
  String timeStamp  = emxGetParameter(request, "timeStamp");

    StringList slErrors = null;
	String[] selectedIds = null;

	//This session removes the session object "emxProgramCentralMemberTransferDialogFSParams" set for back button functionality
	//Bug No. 357558
	session.removeAttribute("emxProgramCentralMemberTransferDialogFSParams");
	
  try {
    //ContextUtil.startTransaction( context, true );

    String txtPersonFrom = (String) emxGetParameter( request, "txtPersonFrom" );
    String txtPersonTo   = (String) emxGetParameter( request, "txtPersonTo" );
    selectedIds = (String[]) emxGetParameterValues( request, "emxTableRowId" );
    String objectId      = (String) emxGetParameter( request, "objectId" );

    HashMap hashmap = new HashMap();
    hashmap.put("txtPersonFrom", txtPersonFrom);
    hashmap.put("txtPersonTo", txtPersonTo);
    hashmap.put("selectedIds", selectedIds);
    hashmap.put("objectId", objectId);
	
if(selectedIds != null){
    String as[] = JPO.packArgs(hashmap);
    String initArgs[] = new String[] { objectId };
	slErrors = (StringList) JPO.invoke(context, "emxProjectSpace", initArgs, "transferTaskAssignments", as, StringList.class);

}
    //ContextUtil.commitTransaction( context );

  } catch (Exception e) {
    //ContextUtil.abortTransaction( context );
    throw e;
  }
%>

<html>
    <%
	if(selectedIds == null){
	%>
		<script language="javascript" type="text/javaScript">//<![CDATA[
        <!-- hide JavaScript from non-JavaScript browsers
            alert("<framework:i18nScript localize="i18nId">emxProgramCentral.Project.NoTaskAvailabletoSubmit</framework:i18nScript>");
        //Stop hiding here -->//]]>
        </script>
	<%
	}
    %>

  <script language="javascript" type="text/javaScript">//<![CDATA[
  <!-- hide JavaScript from non-JavaScript browsers
    //Added:4-Oct-2010:vf2:R2012
    //parent.window.getWindowOpener().parent.document.location.href = parent.window.getWindowOpener().parent.document.location.href;
    getTopWindow().parent.getWindowOpener().location.href = getTopWindow().parent.getWindowOpener().location.href;
    //End:4-Oct-2010:vf2:R2012
	parent.window.closeWindow();

  //Stop hiding here -->//]]>
  </script>
</html>
