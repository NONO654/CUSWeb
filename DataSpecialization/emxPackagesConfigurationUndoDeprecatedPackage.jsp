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
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.*"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import = "com.dassault_systemes.ontology_itfs.OntoException"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%


String selPacksIds[] = emxGetParameterValues(request, "emxTableRowId");

int nbSelectedPack = (null != selPacksIds) ? selPacksIds.length : -1;

int k = 0;
System.out.println(nbSelectedPack + " package(s) to Deprecated");
if ((null != selPacksIds) )
{
    int nbUndoDeprecatedPacks = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			IDAuPackage pack = null;
			for (k = 0; k<nbSelectedPack; k++)
			{
				String packId = selPacksIds[k];		
				if (packId.startsWith("|") == true ) {
					packId = packId.substring(1);
				}
				int idxPipes = packId.indexOf("||");
				if (idxPipes > 0 ) {								
					packId = packId.substring(0,idxPipes);
				}
				System.out.println("Deprecation of :" + packId);
				pack = manager.getPackageFromId(context,packId);
				if (null != pack){
					
				  if(pack.canBeModified(context)){
						pack.setContentDeprecated(context, false, true);
						nbUndoDeprecatedPacks++;
					  }
				  
				}
				else
					System.out.println("ERROR : Package " + packId + " not found");
			}
			System.out.println("Undo Deprecation OK. " + nbUndoDeprecatedPacks + " undo deprecated on " + nbSelectedPack );
			%>
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>		
			<%
			
			ArrayList<String> nbPack = new ArrayList<String>();
			nbPack.add(Integer.toString(nbUndoDeprecatedPacks));
			nbPack.add(Integer.toString(nbSelectedPack));
			String setDeprecatedOK = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.UndoDeprecatedPackOK",nbPack);
			emxNavErrorObject.addMessage(setDeprecatedOK);

		}
		catch (Exception e)
		{
			String undoDeprecatedFailure = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.UndoDeprecatedFailure");
			System.out.println("Undo Deprecated KO : " + e.getMessage());
			emxNavErrorObject.addMessage(undoDeprecatedFailure + e.getMessage());									
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
	var temp=false;
	var channel = ["PackagesConfigurationCmd","PackagesConfigurationDeploymentCmd"];
	var index;
	for(index=0;index<channel.length;index++){
		sbWindow = findFrame(top, channel[index]);
		if (sbWindow && typeof sbWindow.emxEditableTable != 'undefined'
				&& sbWindow.emxEditableTable.refreshStructureWithOutSort) {
			sbWindow.emxEditableTable.refreshStructureWithOutSort();
			temp=true;
		}
	}
	 if(temp==false) {
		var win = findFrame(top, "content");
		if (win && typeof win.emxEditableTable != 'undefined'
				&& win.emxEditableTable.refreshStructureWithOutSort) {
			win.emxEditableTable.refreshStructureWithOutSort();
		} else {
			window.parent.location.href = window.parent.location.href;
		}
	}
</script>
