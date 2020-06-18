<%--  emxBlank.jsp   - Component Frame for "Build ECO"

   Copyright (c) 1992-2000 MatrixOne, Inc.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: slmMore.jsp,v 1.1 2007/06/08 19:22:15 dperkins Exp $
--%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%
String type = emxGetParameter(request,"type");
String lowerType = "";

if ( type != null && type.length() > 0 )
{
    type = SimulationUtil.getSchemaProperty(type);
    lowerType = type.toLowerCase();
}

response.addHeader("Cache-Control", "max-age=604800"); 
long now = System.currentTimeMillis(); 
response.setDateHeader("Expires", now + 604800*1000);
%>
<html>
<head>
<title>More Commands</title>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script language="javascript">
  addStyleSheet('emxUICalendar');
</script>

<script language="javascript" src="scripts/emxUIObjMgr.js"></script>
<script language="javascript" src="scripts/emxUIModal.js"></script>
<script language="javascript" src="scripts/emxUIFormUtil.js"></script>
<script language="JavaScript" src="scripts/emxUITableUtil.js" type="text/javascript"></script>
<script language="JavaScript" src="scripts/emxUIPopups.js" type="text/javascript"></script>
<script type="text/javascript">

    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIProperties");
    addStyleSheet("emxUIList");

</script>
</head>
<body>

<table border="0" width="99%" cellpadding="5" cellspacing="2">
    <caption class="groupheader">Expand <b>More</b> to display the following information about the current <%= type %>:
</caption>

    <tr>
        <td class="label" >Access</td>
        <td class="field" colspan="1">A list of the access rights to the <%= lowerType %> for individual users, roles, and groups. <b>Access</b> also allows you to modify the access rights.</td>
    </tr>

    <tr>
        <td class="label" >History</td>
        <td class="field" colspan="1">A list of all the actions that have been performed on the <%= lowerType %>, including the date of the action and by whom it was performed.</td>
    </tr>

    <tr>
        <td class="label" >Images</td>
        <td class="field" colspan="1">A list of the graphic images associated with this <%= lowerType %>. <b>Images</b> also allows you to add or delete images.</td>
    </tr>

    <tr>
        <td class="label" >Impact Graph</td>
        <td class="field" colspan="1">A graphic representation of the relationship between the simulation and its activities and documents. <B>Impact Graph</b> also allows you to update objects that are shown as out-of-date. </td>
    </tr>

    <tr>
        <td class="label" >Issues</td>
        <td class="field" colspan="1">A list of the issues associated with the <%= lowerType %>. <b>Issues</b> also allows you to add or delete issues.</td>
    </tr>

    <tr>
        <td class="label" >Lifecycle</td>
        <td class="field" colspan="1">A graphic representation of all the lifecycle states, including the current state. <b>Lifecycle</b> also allows you to change the state, if applicable.</td>
    </tr>

    <tr>
        <td class="label" >Revisions</td>
        <td class="field" colspan="1">A list of the revisions that have been made to the <%= lowerType %>. <b>Revisions</b> also allows you to create a new revision.</td>
    </tr>

</table>

</body>
</html>
