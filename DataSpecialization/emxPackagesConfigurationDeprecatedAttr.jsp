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
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttrInfos"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuCustoDictionary"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
System.out.println("  ***** delete attribute(s) ***** ");
String selAttrsIds[] = emxGetParameterValues(request, "emxTableRowId");
int nbSelectedAttr = (null != selAttrsIds) ? selAttrsIds.length : -1;

int k = 0;
String selectedFrame = "";
System.out.println(nbSelectedAttr + " attribute(s) to deprecated");
if ((null != selAttrsIds) )
{
    int nbDeprecateAttr = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			for (k = 0; k<nbSelectedAttr; k++)
			{
				String attrId = selAttrsIds[k];
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
				  String attrPublishStatus = attr.getPublishStatus(context);
					 if(attr.canBeModified(context) && !attr.isDeprecated(context) && !attrPublishStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_NO))
					{
							attr.setDeprecated(context,true,true);
							nbDeprecateAttr++;
					} 
					
				}
				else{
					System.out.println("ERROR : attribute " + attrId + " not found");
				}
			}
			//System.out.println("Delete OK : " + nbDeletedAttrs + " deleted on " + nbAttrs );
			ArrayList<String> nbAttr = new ArrayList<String>();
			nbAttr.add(Integer.toString(nbDeprecateAttr));
			nbAttr.add(Integer.toString(nbSelectedAttr));
			String setDeprecatedAttrOK = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.DeprecatedAttrOK",nbAttr);
			emxNavErrorObject.addMessage(setDeprecatedAttrOK);
			%>
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
			<%
		}
		catch (Exception e)
		{
			String deprecatedFailure = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.DeprecatedFailure");
			System.out.println("Deprecated KO : " + e.getMessage());
			emxNavErrorObject.addMessage(deprecatedFailure + e.getMessage());									
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
var sbWindow = null;
var sbWindowsBas = null;
var index;
var channel= ["PackageConfigTypesCmd","PackageConfigExtsCmd","DeploymentExtensionsCmd"];
for (index = 0; index < channel.length; index++) {
	sbWindow = findFrame(top,channel[index]);
	if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.refreshStructureWithOutSort){
		   sbWindow.emxEditableTable.refreshStructureWithOutSort();  
		   break;
	}
}
var channelBas = ["PackageConfigAttributesCmd","DeploymentAttributesCmd"];
for (index = 0; index < channelBas.length; index++) {
	sbWindowsBas = findFrame(top,channelBas[index]);
	if(sbWindowsBas && typeof sbWindowsBas.emxEditableTable != 'undefined' && sbWindowsBas.emxEditableTable.refreshStructureWithOutSort){
		sbWindowsBas.emxEditableTable.refreshStructureWithOutSort();  
		   break;
	}
}
</script>
