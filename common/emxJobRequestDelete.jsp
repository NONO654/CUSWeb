<%-- emxJobRequestDelete.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxJobRequestDelete.jsp.rca 1.1.5.4 Wed Oct 22 15:48:42 2008 przemek Experimental przemek $
--%>

<%@page import  = "com.matrixone.apps.domain.Job"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxNavigatorInclude.inc"%>

<%
    String checkBoxId[] = emxGetParameterValues(request,"emxTableRowId");
    if(checkBoxId != null )
    {
        try
        {        
            Job.delete(context, checkBoxId);
        }
        catch (Exception e)
        {  
            if (e.toString()!=null && e.toString().length()>0) {emxNavErrorObject.addMessage(e.toString());}              
        }
    }
        
%>


<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

<script language="Javascript">
  parent.location.href = parent.location.href;
</script>
