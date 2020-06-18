<%-- emxMQLNotice.jsp - included code to construct a JavaScript alert for MQL trigger Notices

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
   code to promote given object set in request within main page

   static const char RCSID[] = $Id: emxMQLNotice.inc.rca 1.6 Wed Oct 22 16:18:27 2008 przemek Experimental przemek $
--%>

<script language="Javascript" type="text/javascript">
<%
            com.matrixone.apps.framework.ui.MqlNoticeUtil.writeMqlNotice(context,request,out,false);
%>
</script>
