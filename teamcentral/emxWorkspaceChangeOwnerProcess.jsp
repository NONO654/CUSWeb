<%--  emxWorkflowAction.jsp  --  
  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxWorkflowChangeOwner.jsp.rca 1.2.2.1.7.5 Wed Oct 22 16:18:29 2008 przemek Experimental przemek $
 --%>
 
<%@page import="com.matrixone.apps.common.Person"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ page import = "com.matrixone.apps.domain.*,
                   com.matrixone.apps.domain.util.*,
                   com.matrixone.apps.common.util.*,
                   com.matrixone.apps.framework.ui.*,
                   com.matrixone.apps.framework.taglib.*" %>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
 <% 
	String ids = emxGetParameter(request, "emxTableRowId");
	StringList idList = FrameworkUtil.split(ids, "|");
	String personId = (String)idList.get(0);
	String objectId = emxGetParameter(request, "objectId");
	if(UIUtil.isNotNullAndNotEmpty(personId) && UIUtil.isNotNullAndNotEmpty(objectId)) { 
	   	 DomainObject workspaceObj = new DomainObject(objectId);
	   	 String oldOwner = workspaceObj.getInfo(context, DomainConstants.SELECT_OWNER);
	     String oldOwnerId = com.matrixone.apps.domain.util.PersonUtil.getPersonObjectID(context, oldOwner);

		if(!personId.equals(oldOwnerId)) {		 
			 DomainObject personObj = DomainObject.newInstance(context);
			 personObj.setId(personId);   
			 
			 try {
				 workspaceObj.setOwner(context, personObj.getName(context));
			 } catch(Exception e){
				 System.out.println("Error:"+e.toString());
				 throw new FrameworkException(e);
			 }
		}
	}
 %>
<script language="javascript">
	getTopWindow().refreshTablePage();
	getTopWindow().closeWindow();
</script>



