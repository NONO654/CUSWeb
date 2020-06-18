<%--
  DeleteChildren.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = ;

single selection,
from Spec SB, Spec SCE,
     Req SB, Req SCE

 --%>
<!-- 
Release Developer Reviewer  MM:DD:YYYY  Comment
2014    LX6       QYG       11:29:2010  IR-191273V6R2014 Synchronize seq Order and refresh table on Delete Children Command   
-->

<%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags 
      are added under respective scriplet
     @quickreview T25 OEP 18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
     @quickreview T25 DJH 13:10:18  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
--%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>

<%@page import = "com.matrixone.apps.requirements.DeleteUtil"%>
<%@page import = "com.matrixone.apps.requirements.SpecificationStructure"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.dassault_systemes.requirements.ReqSchemaUtil"%>

<html>
    <script language="javascript" src="../common/scripts/emxUICore.js"></script>
    <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
<script type="text/javascript" language="JavaScript">

</script>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
	try
	{
		//root can not be deleted!!!
	  	String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId"); //indented tree: format: relId | objId | parentId | rowId; search list: objectId
	  	String relPattern = emxGetParameter(request, "relPattern");
		String timeStamp = emxGetParameter(request, "timeStamp");
		String relPatternJPO = emxGetParameter(request, "relPatternJPO");
		if(relPatternJPO != null)
		{
			relPatternJPO = relPatternJPO.trim();
			String[] jpocall = relPatternJPO.split("[:]");
			relPattern = (String)JPO.invoke(context, jpocall[0], null, jpocall[1], null, String.class);
		}
		if(tableRowIds != null){ 
			boolean isFromStructureBrowser = DeleteUtil.isFromStructureBrowse(tableRowIds[0]);
			
			Map objectMap = DeleteUtil.getObjectIdsRelIds(tableRowIds);
			String[] oids = (String[]) objectMap.get("ObjId");
			String[] relIds = (String[]) objectMap.get("RelId");
			String[] parentIds = (String[]) objectMap.get("ParentId");
			if(oids.length == 1 && relIds.length == 1){
				//if(DeleteUtil.isStructureBrowserRoot(tableRowIds[0])){
				//	throw new Exception ("Root object can not be deleted.");
				//}
				String suiteKey = emxGetParameter(request, "suiteKey");
	  			String strStringResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);
	  			
				boolean ignoreRoot = DeleteUtil.isStructureBrowserRoot(tableRowIds[0]);
				String oid = oids[0];
				String relId = relIds[0];
				ContextUtil.startTransaction(context, true);
				Map result = DeleteUtil.deleteChildObjects(context, oid, relId, "", relPattern, ignoreRoot); 
				if("true".equalsIgnoreCase((String)result.get("checkFailed"))){
					ContextUtil.abortTransaction(context);
					
					result.put("childrenDelete", "true");
					long number = new Random(System.currentTimeMillis()).nextLong();
					String key = "deleteResult" + System.currentTimeMillis() + "_" + number;
					session.setAttribute(key, result);
%>
    <script language="javascript" type="text/javaScript">
		parent.showModalDialog("DeleteReportFS.jsp?suiteKey=<xss:encodeForJavaScript><%=emxGetParameter(request, "suiteKey")%></xss:encodeForJavaScript>&key=<xss:encodeForJavaScript><%=key%></xss:encodeForJavaScript>&isFromStructureBrowser=<xss:encodeForJavaScript><%=isFromStructureBrowser%></xss:encodeForJavaScript>", "500", "600", true); 
    </script>
<%
				}else{
					//START LX6 IR-191273V6R2014 Synchronize seq Order and refresh table on Delete Children Command  
					//Synchronize Sequence Order attribute
					String[] tokens = tableRowIds[0].split("[|]");
				  String ParentId = tokens[2];
					DomainObject ParentObject = DomainObject.newInstance(context, ParentId);
					String relTypes = ReqSchemaUtil.getSpecStructureRelationship(context) + "," +
				     ReqSchemaUtil.getSubRequirementRelationship(context) + "," +
				     ReqSchemaUtil.getDerivedRequirementRelationship(context);
			    SpecificationStructure.normalizeSequenceOrderMultiRelationship(context, ParentObject, relTypes);
			    //END LX6 IR-191273V6R2014 Synchronize seq Order and refresh table on Delete Children Command
					ContextUtil.commitTransaction(context);
%>
    <script language="javascript" type="text/javaScript">
	    function getTableRowIds(win, objectId){
	        var aRowsSelected = emxUICore.selectNodes(win.oXML,"/mxRoot/rows//r[@o='" + objectId + "']");
	        return getCheckboxArray(aRowsSelected);
	    }

		function getRootChildren(win, rootObjectId)
		{
	        var aRowsSelected = emxUICore.selectNodes(win.oXML,"/mxRoot/rows//r[@p='" + rootObjectId + "']");
	        return getCheckboxArray(aRowsSelected);
		}

		function getCheckboxArray(aRowsSelected)
		{
	        var checkboxArray = new Array();
	        var chkLen = aRowsSelected.length;
	        for(var j = 0; j < chkLen; j++){
	           var id = aRowsSelected[j].getAttribute("id");
	           var oid = aRowsSelected[j].getAttribute("o");
	           var relid = aRowsSelected[j].getAttribute("r");
	           if (relid == null || relid == "null") {
	              relid = "";
	           }
	           var parentId = aRowsSelected[j].getAttribute("p");
	           if (parentId == null || parentId == "null") {
	              parentId = "";
	           }
	           var totalRowInfo = relid + "|" + oid + "|" + parentId + "|" + id;
	           checkboxArray[checkboxArray.length] = totalRowInfo;
	        }
	        return checkboxArray;
		}
	    
		function refreshWindow()
		{
			//START LX6 IR-191273V6R2014 Synchronize seq Order and refresh table on Delete Children Command
			if(parent.emxEditableTable){
				if(parent.emxEditableTable.isRichTextEditor)
            {
                parent.refreshSCE();//structure content editor SCE
            }
            else
            {
            	parent.editableTable.loadData(); 
              parent.emxEditableTable.refreshStructureWithOutSort();   // Structure Browser
            }
				}
			//END LX6 IR-191273V6R2014 Synchronize seq Order and refresh table on Delete Children Command
				var contentFrame;
			    if(getTopWindow().deleteStructureNode) 
			    {
			    	contentFrame = getTopWindow(); 
			    }
			    else{
			    	contentFrame = findFrame(getTopWindow(), "content");
			    }
				if(contentFrame && contentFrame.deleteMultipleStructureNode)
				{
					try{
						contentFrame.deleteMultipleStructureNode("<%=oids[0]%>");
					}catch(e){}
				}
		}
		if(<xss:encodeForJavaScript><%=ignoreRoot%></xss:encodeForJavaScript>){
			alert("<emxUtil:i18nScript localize="i18nId">emxRequirements.Delete.Error.SBRoot</emxUtil:i18nScript>");
		}
		refreshWindow();
		
		//Refresh Table
 		
    </script>
<%
				}
			}

			boolean bIsFromRichTextEditor = "true".equalsIgnoreCase(emxGetParameter(request,"isRTE")) ? true: false;		
			if(bIsFromRichTextEditor)
			{
%>				<jsp:useBean id="richtextTableBean" class="com.matrixone.apps.requirements.ui.UITableRichText" scope="session" />
<%				richtextTableBean.expireObjectList(timeStamp); //clear object list for filtering
			}
		}else{
		
		}
    }
    catch (Exception exp)
	{
		
		exp.printStackTrace(System.out);
		session.putValue("error.message", exp.getMessage());
		//throw exp;
	}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</html>
