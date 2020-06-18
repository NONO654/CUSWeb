<%--  emxTeamUtil.jsp   - utility functions for TeamCentral apps
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxTeamUtil.inc.rca 1.57 Wed Oct 22 16:06:01 2008 przemek Experimental przemek $
--%>
<%@ page import="matrix.db.*, matrix.util.*, com.matrixone.servlet.*, java.util.* , com.matrixone.apps.domain.util.*, com.matrixone.apps.framework.taglib.*, com.matrixone.apps.domain.*, com.matrixone.apps.common.*"  %>

<script language="javascript">

  function trim (textBox) {
      return textBox.replace(/\s/gi, "");
  }

</script>

<%!
  public static String getProjectId ( HttpSession session ) {
    return ( ((String)session.getAttribute("activeProjectId")));
  }
%>

