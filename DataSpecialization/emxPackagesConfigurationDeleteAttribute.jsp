<%--  emxPackagesConfigurationPublish.jsp  --  Publish the selected packages
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreatePackage.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuType"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttribute"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuCustoDictionary"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
boolean mbDisableDeleteOnceDeployed = System.getenv("TXO_DisableDeleteOnceDeployed"+context.getTenant()) != null;
System.out.println("  ***** delete attribute(s) ***** ");
String selAttrsIds[] = emxGetParameterValues(request, "emxTableRowId");
int nbAttrs = (null != selAttrsIds) ? selAttrsIds.length : -1;

int k = 0;
String selectedFrame = "";
System.out.println(nbAttrs + " attribute(s) to delete");
if ((null != selAttrsIds) )
{
    int nbDeletedAttrs = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			for (k = 0; k<nbAttrs; k++)
			{				String attrId = selAttrsIds[k];
				// JPI le 07 octobre 11 curieusement la forme des Ids a changé :  |38016.53567.5632.5790||0,1				
				if (attrId.startsWith("|") == true ) {
					attrId = attrId.substring(1);
				}
				int idxPipes = attrId.indexOf("|");
				if (idxPipes > 0 ) {								
					attrId = attrId.substring(0,idxPipes);
				}
				//System.out.println(" YI3 - attribute Id :"+attrId);
				IDAuAttribute attr = manager.getAttributeFromId(context,attrId);
				if (null != attr){
					DAuData data = attr.getData(context);
					//System.out.println(" YI3 - attribute not null");
					if(data.IDAUTYPE != null){
						selectedFrame="type";
					}else if(data.IDAUEXTENSION != null){
						IDAuExtension extension = data.IDAUEXTENSION;
						int nature = extension.getNatureInfos(context);
						// Deployment Extension 
						if ((nature & DAuCustoDictionary.USAGE_EXTENSION_DEPLOYMENT) == DAuCustoDictionary.USAGE_EXTENSION_DEPLOYMENT)
							selectedFrame="deploymentExt";
					}
					String pubStatus =attr.getPublishStatus(context);
					if(pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_NO)){
						attr.delete(context);
						nbDeletedAttrs++;
					}
					else if(pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_YES) || pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_PARTIAL)){
						if(mbDisableDeleteOnceDeployed)
							throw new Exception(DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.DeleteAttribute",attr.getName(context)));
						attr.deleteOnceDeployed(context);
						nbDeletedAttrs++;
					}
					
				}
				else{
					System.out.println("ERROR : attribute " + attrId + " not found");
				}
			}
			//System.out.println("Delete OK : " + nbDeletedAttrs + " deleted on " + nbAttrs );
			emxNavErrorObject.addMessage(nbDeletedAttrs + " attribute(s) deleted on " + nbAttrs + ",\n");	
			%>
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
			<%
		}
		catch (Exception e)
		{
			//System.out.println("Delete KO" + e.getMessage());
			emxNavErrorObject.addMessage("Delete KO : " + e.getMessage());									
			%>
			<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
			<%
		}		
	}
}
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%-- Reload the page --%>
<script language="Javascript" >
var selectFrame = "<%=selectedFrame%>";
var sbWindow = null;
if(selectFrame == "type"){
	sbWindow = findFrame(top, "PackageConfigTypesCmd");
}else if(selectFrame == "deploymentExt"){
	sbWindow = findFrame(top, "DeploymentExtensionsCmd");
}
else{
	sbWindow = findFrame(top, "PackageConfigExtsCmd");
}
	
if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.refreshStructureWithOutSort){
   sbWindow.emxEditableTable.refreshStructureWithOutSort();
   //sbWindow.refreshRows();
   //sbWindow.expandAll();    
}
var sbChannelAttr = findFrame(top, "PackageConfigAttributesCmd");
if(sbChannelAttr==null)
	sbChannelAttr = findFrame(top, "DeploymentAttributesCmd");
sbChannelAttr.location.href = sbChannelAttr.location.href;

</script>
