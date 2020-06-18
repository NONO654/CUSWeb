<%--  emxTeamBlankSubFolders.jsp   -  Displays the SubFolders of the given Folder
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamBlankSubFolders.jsp.rca 1.6 Wed Oct 22 16:06:18 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxTeamCommonUtilAppInclude.inc"%>

<HTML>
<body bgColor="#ffffff">
 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>
 <table class="list" id="UITable">

	<tr>
		<td align="center" colspan="13" class="error">
			<emxUtil:i18n localize="i18nId">emxTeamCentral.DocSummary.NoSubCategories</emxUtil:i18n></td>
	</tr>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>
</table>
</body>
</HTML>
