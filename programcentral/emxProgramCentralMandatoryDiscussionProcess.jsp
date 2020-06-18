<%-- emxProgramCentralMandatoryDiscussionProcess.jsp

  Performs the action to remove a mandatory task

  Copyright (c) 1992-2018 Dassault Systemes.

  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxProgramCentralMandatoryDiscussionProcess.jsp.rca 1.16 Wed Oct 22 15:49:32 2008 przemek Experimental przemek $";
--%>

<%@ include file="emxProgramGlobals2.inc" %>
<%@ include file="../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@ page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>

<script language="javascript" type="text/javascript" src="emxUICore.js" />

<%
	com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject.newInstance(context, DomainConstants.TYPE_TASK,"PROGRAM");

	String description = (String) emxGetParameter(request, "Comment");
  	String mode = (String) emxGetParameter(request, "mode");  
  	
  	String objectIds = (String) emxGetParameter(request, "selectedObjectIds");
  	if(ProgramCentralUtil.isNullString(objectIds)) {
		objectIds = (String) emxGetParameter(request, "objectId");
	}
  	StringList slobjectId =  FrameworkUtil.split(objectIds, ",");
  	
	boolean blStructureBrowser = false;
  	String fromPage  = (String) emxGetParameter(request, "fromPage");
  	if(fromPage!=null && "StructureBrowser".equalsIgnoreCase(fromPage)){
		blStructureBrowser = true;
  	}

  	String selectedIds="";
  	StringList selectedIdList=null;
  	StringList rowIdList=null;
  	StringBuffer xmlMessage = null;
  	try {
		if("UndoMarkDeleted".equalsIgnoreCase(mode)) {
			String rowIds = (String) emxGetParameter(request, "rowIds");
		   	rowIdList = FrameworkUtil.split(rowIds, "|");
		   	selectedIds  = emxGetParameter(request, "objectIds");
		   	if (selectedIds.endsWith("|")) {
				selectedIds = selectedIds.substring(0, selectedIds.length()-1); //trim trailing pipe
		   	}
		   	StringList idList = FrameworkUtil.split(selectedIds, ",");
		   	selectedIdList = new StringList();
		   	for(int nIndex =0;nIndex<idList.size();nIndex++)
		   	{
				String strId= (String)idList.get(nIndex);
		       	selectedIdList.add(strId.trim());
		   	}
		    
			if(slobjectId!=null && !slobjectId.isEmpty())
			{    
				String rowId =ProgramCentralConstants.EMPTY_STRING;
				xmlMessage = new StringBuffer("<mxRoot>");
		        xmlMessage.append("<action refresh=\"true\" fromRMB=\"\"><![CDATA[remove]]></action>");
			    for(int i=0;i<slobjectId.size();i++)
			    {
					String strId = ((String)slobjectId.get(i)).trim();
			        int index= selectedIdList.indexOf(strId);
			        if(index!=-1){
			            rowId = (String)rowIdList.get(index);
			        }
			        xmlMessage.append("<item id=\"").append(rowId).append("\" />");
			    }
			    xmlMessage.append("<message><![CDATA[]]></message>");
		        xmlMessage.append("</mxRoot>");
			}
			
			task.undoMarkAsDelete(context, slobjectId);
	  	}
	  	else {
			task.markForDelete(context, slobjectId, description);
	 	}
  	}
  	catch (Exception e) {
		ContextUtil.abortTransaction(context);
      	throw e;
  	}
%>

  <script language="javascript" type="text/javaScript">
    if(<%=blStructureBrowser%> == true) //XSSOK
	{
	    parent.window.closeWindow();
	} 
	else 
	{		
<%
		if(!"UndoMarkDeleted".equalsIgnoreCase(mode))
		{
%>
			var topFrame = findFrame(getTopWindow(), "detailsDisplay"); 
			topFrame.location.href = topFrame.location.href;
<%
		}
%>
	    parent.window.closeWindow();
	}
  </script>

<%
	if("UndoMarkDeleted".equalsIgnoreCase(mode))
	{
%>
		<script type="text/javascript" language="JavaScript">
        	window.parent.removedeletedRows('<%=xmlMessage %>'); //XSSOK
        </script>
<%
	}
%>


