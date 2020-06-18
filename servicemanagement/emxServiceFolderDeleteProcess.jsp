<%--  emxServiceFolderDeleteProcess.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: /ENOServiceManagement/CNext/webroot/servicemanagement/emxServiceFolderDeleteProcess.jsp 1.1 Fri Nov 14 15:40:25 2008 GMT ds-hchang Experimental$
--%>

<%@include file = "../components/emxComponentsDesignTopInclude.inc"%>
<%@include file = "../components/emxComponentsVisiblePageInclude.inc"%>

<!-- content begins here -->

<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
	boolean statusFlag = true;
	String[] checkBoxId = emxGetParameterValues(request,"serviceFolderId");

	if(checkBoxId != null )
	{
	    try
	    {  
			String sObjId = "";
			for(int i=0;i<checkBoxId.length;i++)
			{
			    sObjId = checkBoxId[i];
        		DomainObject bo = DomainObject.newInstance(context, sObjId);
		    	bo.deleteObject(context);
		    }
    	}
	    catch(Exception Ex){
         	session.putValue("error.message", Ex.toString());
    	}
	}
%>

<script language="javascript">
    if(getTopWindow().getWindowOpener().getTopWindow().modalDialog)
    {
      getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
    }
    getTopWindow().getWindowOpener().document.location.href = getTopWindow().getWindowOpener().document.location.href;
    <%--
	getTopWindow().getWindowOpener().parent.refreshTablePage();
	--%>
	getTopWindow().window.close();
</script>
<!-- content ends here -->

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
