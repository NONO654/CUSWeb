<%--
  UpdateRevision.jsp

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
<%-- @quickreview T25 OEP 12:12:10  :  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under respective scriplet--%>
<%-- @quickreview T25 DJH 12:12:12  :  No change --%>
<%-- @quickreview T25 OEP 12:12:18  :  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included --%>
<%-- @quickreview T25 DJH 13:10:18  :  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included. --%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../emxTagLibInclude.inc"%>
<%@page import = "java.util.List"%>
<%@page import = "java.util.Set"%>
<%@page import = "com.matrixone.apps.requirements.DeleteUtil"%>
<%@page import = "com.matrixone.apps.requirements.SpecificationStructure"%>
<html>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
    <script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
    <script language="javascript" src="../common/scripts/emxUIUtility.js"></script>
<script type="text/javascript" language="JavaScript">


</script>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
	try
	{
		
	  	String[] tableRowIds = emxGetParameterValues(request, "emxTableRowId"); //indented tree: format: relId | objId | parentId | rowId; search list: objectId
		if(tableRowIds != null){ 
			boolean isFromStructureBrowser = DeleteUtil.isFromStructureBrowse(tableRowIds[0]);
		
			if(DeleteUtil.hasStructureBrowserRoot(tableRowIds)){
				String suiteKey = emxGetParameter(request, "suiteKey");
	  			String strStringResourceFile = UINavigatorUtil.getStringResourceFileId(context,suiteKey);
	  			String ErrMsg = EnoviaResourceBundle.getProperty(context, strStringResourceFile, context.getLocale(), "emxRequirements.UpdateRevision.Error.SBRoot");
				throw new Exception (ErrMsg);
			}
			
			//SpecificationStructure.sortSelectedObjects(tableRowIds); //comment out due to IR-058906V6R2011x
			
			Map objectMap = DeleteUtil.getObjectIdsRelIds(tableRowIds); 
			String[] oids = (String[]) objectMap.get("ObjId");
			String[] relIds = (String[]) objectMap.get("RelId");
			String[] parentIds = (String[]) objectMap.get("ParentId");
			String[] rowIds = (String[])objectMap.get("RowId");
			
			Map updateResult = SpecificationStructure.updateRevisions(context, oids, relIds, parentIds);  
			
			Map objectMapping = (Map)updateResult.get("ObjectMapping");
			Set failedRels = (Set)updateResult.get("failedRels");
			
			String timeStamp = emxGetParameter(request, "timeStamp");      
			boolean checkFailed = "true".equalsIgnoreCase((String)updateResult.get("checkFailed"));
			boolean refresh = ((Integer)updateResult.get("successObjects")).intValue() > 0;
			
			if(checkFailed){
				long number = new Random(System.currentTimeMillis()).nextLong();
				String key = "updateRevisionResult" + System.currentTimeMillis() + "_" + number;
				session.setAttribute(key, updateResult);
				//present the popup
%>
    <script language="javascript" type="text/javaScript">
		getTopWindow().showModalDialog("UpdateRevisionReportFS.jsp?suiteKey=<xss:encodeForJavaScript><%=emxGetParameter(request, "suiteKey")%></xss:encodeForJavaScript>&key=<xss:encodeForJavaScript><%=key%></xss:encodeForJavaScript>&timeStamp=<xss:encodeForJavaScript><%=timeStamp%></xss:encodeForJavaScript>&isFromStructureBrowser=<xss:encodeForJavaScript><%=isFromStructureBrowser%></xss:encodeForJavaScript>", "500", "600", true); 
    </script>
<%

				
			}
			
			if(refresh){
//need to refresh the parent pages
//structure browser, rich text editor	
%>
    <script language="javascript" type="text/javaScript">
		function refreshWindow(topwin)
		{
			if(<xss:encodeForJavaScript><%=isFromStructureBrowser%></xss:encodeForJavaScript>){
				if(topwin.emxEditableTable && topwin.emxEditableTable.isRichTextEditor){//rich text editor
					topwin.refreshSCE();
					//only update the object if it succeeds
<%				
					for(int i = 0; i < oids.length; i++){
					}
%>				
				} 
				else{//structure browser popup
<%				
					for(int i = 0; i < oids.length; i++){
						String newId = (String)objectMapping.get(oids[i]);
						if(newId != null && !failedRels.contains(relIds[i])){
%>				
							var xmlmsg = "<mxRoot><action>add</action><data status=\"committed\"" + 
			    			(<xss:encodeForJavaScript><%="true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB"))%></xss:encodeForJavaScript> ? " fromRMB=\"true\"" : "")  + 
			    			" pasteBelowOrAbove=\"true\"" + ">"  + 
			    			"<item oid=\"" + "<xss:encodeForJavaScript><%=newId%></xss:encodeForJavaScript>" + "\" relId=\"" + "<xss:encodeForJavaScript><%=relIds[i]%></xss:encodeForJavaScript>" +  "\" pid=\"" + "<xss:encodeForJavaScript><%=parentIds[i]%></xss:encodeForJavaScript>" + 
 								"\" direction=\"\" pasteAboveToRow=\"" + "<xss:encodeForJavaScript><%=rowIds[i]%></xss:encodeForJavaScript>" + "\"/>" + "</data></mxRoot>";
 								
							parent.emxEditableTable.addToSelected(xmlmsg);
							parent.emxEditableTable.removeRowsSelected(new Array("<xss:encodeForJavaScript><%=tableRowIds[i]%></xss:encodeForJavaScript>"));
<%						}
					}
%>				
				}
			} 			
		}
		
		refreshWindow(parent);
    </script>
<%
			}
			
		}else{
			//no selection, shouldn't happen
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
