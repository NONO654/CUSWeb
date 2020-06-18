<%--  emxProgramCentralSearchAdvanceInclude.inc

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralSearchAdvanceInclude.inc.rca 1.11 Wed Oct 22 15:49:54 2008 przemek Experimental przemek $"
--%>

&nbsp;
<a href="javascript:goToFindLike()" >
  <img src="../common/images/utilSearchPlus.gif" border="0" align="absmiddle" />
  <emxUtil:i18n localize="i18nId">emxProgramCentral.Button.More</emxUtil:i18n>
</a>
&nbsp;


<script language="Javascript" >
  function goToFindLike()
  {
    document.location.href = "emxProgramCentralSearchAdvanceDialog.jsp?ComboType=<%= objectSymbolicName %>&selectMultiple=<%=selectMultiple%>&typeString=<%= objectI18NString %>&searchMode=<%= searchMode %>&hasTarget=<%= hasTarget %>";
  }
</script>
