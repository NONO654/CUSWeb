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
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuCustoDictionary"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
//HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
String selPacksIds[] = emxGetParameterValues(request, "emxTableRowId");
//Enumeration eNumParameters = emxGetParameterNames(request);
//  String parmValue = "";
//String tableRowIds[] = null;
//    while( eNumParameters.hasMoreElements() ) {
//      String parmName  = (String)eNumParameters.nextElement();
//System.out.println("param  : " + parmName);
//     }
int nbPacks = (null != selPacksIds) ? selPacksIds.length : -1;
if (nbPacks < 1)
{
	// cas de la commande placee dans le package, l'objet a publier est donc le package courant
	String packId = emxGetParameter(request, "objectId");
	if ((null != packId) && !packId.isEmpty())
	{
		selPacksIds = new String[1];
		selPacksIds[0] = packId;
		nbPacks = 1;
	}
	else
	{
		// In the deployment package page, there no mean to get the id.
		System.out.println("Publication of the deployement package ?");
		IDAuManager manager = DAuManagerAccess.getDAuManager();
		ArrayList<IDAuPackage> deploymentPackages = manager.getDeploymentPackages(context);
		if ((null != deploymentPackages) && (1 == deploymentPackages.size()))
		{
			IDAuPackage deploymentPackage = deploymentPackages.get(0);
			if (null != deploymentPackage)
			{
				selPacksIds = new String[1];
				selPacksIds[0] = deploymentPackage.getID(context);
				nbPacks = 1;					
			}
		}
	}
}
int k = 0;
System.out.println(nbPacks + " package(s) to delete");
if ((null != selPacksIds) )
{
    int nbDeletedPacks = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			for (k = 0; k<nbPacks; k++)
			{				String packId = selPacksIds[k];
				// JPI le 07 octobre 11 curieusement la forme des Ids a changé :  |38016.53567.5632.5790||0,1				
				if (packId.startsWith("|") == true ) {
					packId = packId.substring(1);
				}
				int idxPipes = packId.indexOf("||");
				if (idxPipes > 0 ) {								
					packId = packId.substring(0,idxPipes);
				}
				IDAuPackage pack = manager.getPackageFromId(context,packId);
				if (null != pack){
					boolean canDelete = false;
					canDelete = pack.canBeDeleted(context);
					if (canDelete) {
						//String pubStatus = pack.getPublishStatus(context);
						//if(pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_NO)){
							pack.delete(context);
							nbDeletedPacks++;
						/* }
						else if (pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_YES) || pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_PARTIAL)){
							pack.deleteOnceDeployed(context);
							nbDeletedPacks++;
						} */
						
					}
					else {
						System.out.println("Delete : " + pack.getName(context) + " cannot be deleted.");
						emxNavErrorObject.addMessage("Delete : " + pack.getName(context) + " cannot be deleted,\n");			
						%>
						<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
						<%
					}
				}
				else
					System.out.println("ERROR : Package " + packId + " not found");
			}
			System.out.println("Delete OK : " + nbDeletedPacks + " deleted on " + nbPacks );
			emxNavErrorObject.addMessage(nbDeletedPacks + " package(s) deleted on " + nbPacks + ",\n");			
			//emxNavErrorObject.addMessage("Delete package(s) not yet implemented.");			
			%>
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
			<%
		}
		catch (Exception e)
		{
			System.out.println("Delete KO" + e.getMessage());
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
window.parent.location.href = window.parent.location.href ;	
</script>
