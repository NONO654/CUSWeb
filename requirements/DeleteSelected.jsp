<%--
  DeleteSelected.jsp

  Performs the action that creates an incident.

  Copyright (c) 1999-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,
  Inc.  Copyright notice is precautionary only
  and does not evidence any actual or intended publication of such program

  static const char RCSID[] = ;
  
multiple selection,
from Spec SB, Spec SCE, Spec List view
     Chapter SB
     Req SB, Req SCE, Req List view
	 Decision category list view
 --%>
 
<%-- @quickreview T25 DJH 13:10:18  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
     @quickreview T25 DJH 2014:03:03 HL Single Shot Deletion of Requirement Specification.
 --%>
<!-- 
Release Developer Reviewer  MM:DD:YYYY  Comment
2014    LX6       QYG       11:29:2010  IR-191273V6R2014 Synchronize seq Order and refresh table on Delete Object Command   
-->
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.db.BusinessObject"%>
<%@page import = "java.util.List"%>
<%@page import = "com.matrixone.apps.requirements.DeleteUtil"%>
<%@page import = "com.matrixone.apps.requirements.SpecificationStructure"%>
<%@page import="com.matrixone.apps.requirements.RequirementsUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>  
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>  
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
		String modevalue = emxGetParameter(request, "mode");
		boolean detachIfCantDelete = false;
		if(modevalue!=null && modevalue.equals("deleteAll"))
            detachIfCantDelete = true;
		String RootId = emxGetParameter(request, "objectId");
	  String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId"); //indented tree: format: relId | objId | parentId | rowId; search list: objectId
		String timeStamp = emxGetParameter(request, "timeStamp");      
		if(tableRowIds != null){ 
			boolean isFromStructureBrowser = DeleteUtil.isFromStructureBrowse(tableRowIds[0]);
			String prg = emxGetParameter(request, "program");
			boolean isMultiRoot = false;
			if(prg!= null && prg.length() != 0) isMultiRoot = true;
			
			if(DeleteUtil.hasStructureBrowserRoot(tableRowIds) && !isMultiRoot){
				String suiteKey = emxGetParameter(request, "suiteKey");
	  			String strStringResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);
	  			String ErrMsg = EnoviaResourceBundle.getProperty(context, strStringResourceFile, context.getLocale(), "emxRequirements.Delete.Error.SBRoot"); 
				throw new Exception (ErrMsg);
			}
			
			Map objectMap = DeleteUtil.getObjectIdsRelIds(tableRowIds); 
			String[] oids = (String[]) objectMap.get("ObjId");
			String[] relIds = (String[]) objectMap.get("RelId");
			String[] parentIds = (String[]) objectMap.get("ParentId");
			boolean ignoreRoot = DeleteUtil.isStructureBrowserRoot(tableRowIds[0]);
			Map deleteResult = null;
			if(modevalue!=null && modevalue.equals("deleteAll"))
			{
				String relPattern ="relationship_SpecificationStructure,"+"relationship_DerivedRequirement,"+"relationship_RequirementBreakdown"; //(String)JPO.invoke(context, "emxSpecificationStructure", null, "getSpecChildRelationshipsToDelete", null, String.class);
				deleteResult = DeleteUtil.deleteChildObjects(context, oids, relIds, parentIds, relPattern, ignoreRoot, detachIfCantDelete);
			}
			else
			{
			   deleteResult = DeleteUtil.deleteObjects(context, oids, relIds, parentIds, true, null);
			}
			
			List reservedObjects = (List)deleteResult.get("reserveCheck");
			List frozenObjects = (List)deleteResult.get("stateCheck");
			List readonlyObjects = (List)deleteResult.get("accessCheck");
			List parentCheckObjects = (List)deleteResult.get("parentCheck");
			List childCheckObjects = (List)deleteResult.get("childCheck");
			List exceptionObjects = (List)deleteResult.get("exceptionCheck");
			boolean isFromSearchDialog = "true".equalsIgnoreCase(emxGetParameter(request, "fromSearch"));
			boolean checkFailed = "true".equalsIgnoreCase((String)deleteResult.get("checkFailed"));
			
			if(checkFailed){
				long number = new Random(System.currentTimeMillis()).nextLong();
				String key = "deleteResult" + System.currentTimeMillis() + "_" + number;
				session.setAttribute(key, deleteResult);
				//present the popup
%>
    <script language="javascript" type="text/javaScript">
	    parent.showModalDialog("DeleteReportFS.jsp?suiteKey=<%=XSSUtil.encodeForJavaScript(context, emxGetParameter(request, "suiteKey"))%>&key=<%=key%>&fromSearch=<%=isFromSearchDialog%>&timeStamp=<%=XSSUtil.encodeForJavaScript(context, timeStamp)%>&isFromStructureBrowser=<%=isFromStructureBrowser%>&mode=<%=XSSUtil.encodeForJavaScript(context, modevalue)%>", "500", "600", true); <%--XSSOK--%>
    </script>
<%

				
			}
			else
			{
				//START LX6 IR-191273V6R2014 Synchronize seq Order and refresh table on Delete Object Command
				//Sychronize Sequence Order Attribute
				//get Parent object of all selected items
				//String[] ParentsId;*
				Map ParentsMap = new HashMap();
				for(int i=0;i<tableRowIds.length;i++)
				{
					//put all parents Id in a Map
					String ParentId = tableRowIds[i].split("[|]")[2];
					String RelId = tableRowIds[i].split("[|]")[2];
					BusinessObject Test = new BusinessObject(ParentId);
					if((Test.exists(context))&&(!ParentsMap.containsKey(ParentId)))
					{
					//Do a 1 level synchronization
					DomainObject ParentObject = DomainObject.newInstance(context, ParentId);
					String relTypes = ReqSchemaUtil.getSpecStructureRelationship(context) + "," +
             ReqSchemaUtil.getSubRequirementRelationship(context) + "," +
             ReqSchemaUtil.getDerivedRequirementRelationship(context);
					SpecificationStructure.normalizeSequenceOrderMultiRelationship(context, ParentObject, relTypes);
					ParentsMap.put(ParentId,"value");
					}
				}		
        //END LX6 IR-191273V6R2014 Synchronize seq Order and refresh table on Delete Object Command
				if(isFromSearchDialog && timeStamp != null){ 
				    
%>
    <jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/> 
    <form name="frm">
<%				    
				        Map requestMap = (Map)tableBean.getRequestMap(timeStamp);
				        if (requestMap != null)
				        {
				            java.util.Set keys = requestMap.keySet();
				            Iterator itr = keys.iterator();
				            String paramName = null;
				            String paramValue = null;
				            while(itr.hasNext()) 
				             {
				                paramName = (String)itr.next();
				                try 
				                 {
				                   paramValue = (String)requestMap.get(paramName);
				                 }catch(Exception ClassCastException) 
				                 {
				                    //Ignore the exception
				                 }
				        %>
				            <input type="hidden" name="<%=paramName%>" value="<xss:encodeForHTMLAttribute><%=paramValue%></xss:encodeForHTMLAttribute>" />
				        <% 
				             } 
				        }
%>
    </form>
<%				        
				    
				}
			}
				//refresh the parent
//need to refresh the parent pages
//list, indented table, category list, rich text editor	
%>
    <script language="javascript" type="text/javaScript">
	    function getTableRowIds(win, objectId){
	        var checkboxArray = new Array();
	        var aRowsSelected = emxUICore.selectNodes(win.oXML,"/mxRoot/rows//r[@o='" + objectId + "']");
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
			if(parent.emxEditableTable){
		        if(parent.emxEditableTable.isRichTextEditor){//rich text editor
		          //only delete the object if it succeeds
		<%        
		          for(int i = 0; i < oids.length; i++){
		%>        
		            parent.deleteObject("<%=oids[i]%>");
		<%          
		          }
		%>        
		        } 
		        if(parent.oXML){//structure browser
		            var cBoxArray = new Array();

		            if(<%="true".equals(emxGetParameter(request, "isFromRMB"))%>){<%--XSSOK--%>
		              cBoxArray = getTableRowIds(parent, "<%=oids[0]%>");
		            }
		            else
		            {
		              var checkboxes = parent.getCheckedCheckboxes();
		              for (var e in checkboxes){
		                      cBoxArray[cBoxArray.length] = e;
		              }
		            }
		          parent.emxEditableTable.removeRowsSelected(cBoxArray);
		          //parent.emxEditableTable.refreshStructureWithOutSort();
		        }
			//START LX6 IR-191273V6R2014 Synchronize seq Order and refresh table on Delete Object Command
		     //Refresh Table
		     if(parent.emxEditableTable)
		        {
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
		         else
		         {
		             parent.location.href = parent.location.href;
		         }
		    //END LX6 IR-191273V6R2014 Synchronize seq Order and refresh table on Delete Object Command
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
<%				
						for(int i = 0; i < oids.length; i++){
%>				
							contentFrame.deleteMultipleStructureNode("<%=oids[i]%>");
<%					
						}
%>				
					}catch(e){}
				}
			} else
			if(<%=isFromSearchDialog %>){
		       var contentFrame = findFrame(getTopWindow(),"searchView");       
		       if (contentFrame != null) {
		           document.frm.action = "../common/emxTable.jsp";
		           document.frm.target ="searchView";
		           document.frm.submit();
		        }
			}
		} 
		refreshWindow();
    </script>
<%
			
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
