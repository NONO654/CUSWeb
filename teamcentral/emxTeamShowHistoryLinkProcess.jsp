<%-- emxTeamShowHistoryLinkProcess.jsp -- Displays list of Route Objects.
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamShowHistoryLinkProcess.jsp.rca 1.4 Wed Oct 22 16:06:37 2008 przemek Experimental przemek $
--%>

<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "emxTeamCommonUtilAppInclude.inc"%>
<%@ include file = "emxTeamUtil.inc"%>
<%@ include file= "emxTeamProfileUtil.inc" %>

<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../emxUIPageUtility.js"></script>
<%
    String objectId = emxGetParameter(request, "objectId");
    String commonDir=UINavigatorUtil.getCommonDirectory(context);
 %>

<script language="Javascript" >
//XSSOK
emxShowModalDialog("<%=commonDir%>/emxHistory.jsp?HistoryMode=AllRevisions&Header=emxFramework.Common.History&subHeader=Version&objectId=<%=XSSUtil.encodeForURL(context, objectId)%>", 775, 525);

</script>



