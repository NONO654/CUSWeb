<%--  emxStructureCompareCleanUpSession.jsp   -  page to clear the session attributeMap .
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@include file="emxNavigatorInclude.inc"%>

<jsp:useBean id="SCTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>

<%
String scTimeStamp 			  = request.getParameter("scTimeStamp");
SCTableBean = (com.matrixone.apps.framework.ui.UIStructureCompare)structureCompareBean;

((com.matrixone.apps.framework.ui.UIStructureCompare)SCTableBean).removeSCCriteriaMap(scTimeStamp);	

%>
<script>
this.parent.location.href = this.parent.location.href;
</script>
