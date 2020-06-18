<%--  emxServiceKeyDeleteProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOServiceManagement/CNext/webroot/servicemanagement/emxServiceKeyDeleteProcess.jsp 1.1 Fri Nov 14 15:40:25 2008 GMT ds-hchang Experimental$
--%>

<html>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<head>
</head>

<%
	boolean statusFlag = true;
	String[] checkBoxId = request.getParameterValues("emxTableRowId");
    
	if(checkBoxId != null )
	{
	    try
	    {  
			for(int i=0;i<checkBoxId.length;i++)
			{
			    String sObjId = checkBoxId[i];
        		DomainObject bo = DomainObject.newInstance(context, sObjId);
        		String strTypeServiceFolder = PropertyUtil.getSchemaProperty(context, "type_ServiceKey");
        		// only delete Service Keys
        		if (bo.getType(context).equals(strTypeServiceFolder))
        		{
		    		bo.deleteObject(context);
        		}
		    }
    	}
	    catch(Exception Ex){
         	session.putValue("error.message", Ex.toString());
    	}
	}
%>

<script language="JavaScript">
<%
if (statusFlag)
{
%>
	getTopWindow().refreshTablePage();
<%
} else {
%>
<body class="content" onload="turnOffProgress();">
<body>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
<%
}
%>
</script>

</html>
