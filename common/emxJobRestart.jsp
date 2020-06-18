 <%-- emxJobRestart.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxJobRestart.jsp.rca 1.3.3.2 Wed Oct 22 15:47:46 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxNavigatorInclude.inc"%>

<%
    String objectId=emxGetParameter(request,"objectId");
	Job jobObj = (Job)DomainObject.newInstance(context, objectId);
	jobObj.synchronizeFromDB(context);
    jobObj.reStart(context);
%>

<script language="Javascript">
getTopWindow().location.href = getTopWindow().location.href;
</script>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>
