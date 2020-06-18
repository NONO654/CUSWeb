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
<%@page import = "com.dassault_systemes.ontology_itfs.OntoException"%>
<%@page import = "com.dassault_systemes.iPLMDictionaryPublicItf.*"%>
<%@page import = "com.dassault_systemes.ontology_itfs.OntologyDictionary"%>

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
String deploymentKO = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.DeploymentKO");
//String deploymentOK = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.DeploymentOK");


int nbPacks = (null != selPacksIds) ? selPacksIds.length : -1;
if (nbPacks < 1)
{
	String packId = emxGetParameter(request, "objectId");
	if ((null != packId) && !packId.isEmpty())
	{
		selPacksIds = new String[1];
		selPacksIds[0] = packId;
		nbPacks = 1;
	}
	else
	{
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
System.out.println(nbPacks + " package(s) to deploy");
if ((null != selPacksIds) )
{
    int nbPublishedPacks = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			IDAuPackage pack = null;
			int iIPLMFrom = IPLMDictionaryPublicItf.IPLMFromUnknown;
			for (k = 0; k<nbPacks; k++)
			{				String packId = selPacksIds[k];		
				if (packId.startsWith("|") == true ) {
					packId = packId.substring(1);
				}
				int idxPipes = packId.indexOf("||");
				if (idxPipes > 0 ) {								
					packId = packId.substring(0,idxPipes);
				}
				System.out.println("Deployment of :" + packId);
				pack = manager.getPackageFromId(context,packId);
				if (null != pack){
					//MFL_190412
					if (k == 0) {
						int packType = Integer.valueOf(pack.getNature(context));
						switch(packType) {
							case OntologyDictionary.DeploymentUsage:
								iIPLMFrom = IPLMDictionaryPublicItf.IPLMFromDMA;
								break;
							case OntologyDictionary.SpecializationUsage:
								iIPLMFrom = IPLMDictionaryPublicItf.IPLMFromKWD;
								break;
							default:
								iIPLMFrom = IPLMDictionaryPublicItf.IPLMFromUnknown;
						}
					}
					//MFL_190412_End				
					//YI3_03-sept-2014: check if all parent of this package are deployed 
					ArrayList parents = pack.getDirectParents(context);
					parents.addAll(pack.getReferencedPackages(context));
					String checkMsg = "";
					//manager.removeDuplicatedPackages(context,parents);
					if (parents != null) {
						IDAuPackage parent = null;
						String name = null;
						for(int i = 0; i < parents.size(); i++) {
							parent = (IDAuPackage)parents.get(i);
							if (parent != null) {
								name = parent.getName(context);
								if(!parent.isDSModeler(context) && !DAuCustoDictionary.COMPARATOR_STATUS_YES.equals(parent.getPublishStatus(context))){
									checkMsg = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.CheckRelatedPackageStatus",name);
									throw new OntoException(checkMsg);
								}
							}
						}
					}
					
					
					pack.publish(context,iIPLMFrom);
					nbPublishedPacks++;
				}
				else
					System.out.println("ERROR : Package " + packId + " not found");
			}
			System.out.println("Deployment OK. " + nbPublishedPacks + " deployed on " + nbPacks );
			%>
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>		
			<%
			//Update search index : 
			//if (null != pack){
			//	pack.UpdateIndexForPackage(context);
			//}
			/* MFL_141119: For dynamic Dico
			// Update the current user roles in session variable
			UICache.loadUserRoles(context, session);		        
			
    	    //clear the tenant properties cache
			UICache.clearTenantCache(context); 
			
			// reset the cache in the remote APP servers (incl. RMI gateway), if configured
			StringList errAppSeverList = CacheManager.resetRemoteAPPServerCache(context, pageContext);     
    
			// reset the cache in RMI servers specified in the emxReloadCacheServerInfo JPO
			CacheManager.resetRMIServerCache(context);    	
    
			StringBuffer sCacheResetMsg = new StringBuffer();
			if(errAppSeverList != null && errAppSeverList.size() > 0)    
			{

				String CacheRestFailMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxNavigator.UIMenu.ResetRemoteCacheFailedMessage");
				sCacheResetMsg.append(CacheRestFailMsg);
				
				for(int i=0; i < errAppSeverList.size(); i++)
				{
					if(i > 0)
					{
						sCacheResetMsg.append(",");   
					}
            
					sCacheResetMsg.append(" ");
					sCacheResetMsg.append(errAppSeverList.get(i));
				}              
        
			}
			else
			{

				String CacheRestMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxNavigator.UIMenu.ResetCacheMessage");
				sCacheResetMsg.append(CacheRestMsg); 
				
				HashMap lookup = null;
				//If the lookup table is not there, create and populate it.
				if (lookup == null) {
					try {
					MQLCommand getSchemaNames = new MQLCommand();
					getSchemaNames.executeCommand(
						context,
						"execute program 'eServiceListSchemaNames.tcl'");
					StringTokenizer parser =
						new StringTokenizer(getSchemaNames.getResult(), "|");
					lookup = new HashMap();
					boolean isValue = true;
					String key = null;
					String value = null;
					while (parser.hasMoreTokens()) {
						if (isValue) {
							value = parser.nextToken();
							isValue = false;
						} else {
							key = parser.nextToken();
							if (value != null && value.startsWith("type_")) {
								lookup.put(key, value);
							}
							isValue = true;
						}
					}
					application.setAttribute("TypeLookup", lookup);
				} catch (Exception e) {
					System.out.println("Exception caught " + e.toString());
					return;
					}
				}
			}
			emxNavErrorObject.addMessage(nbPublishedPacks +" "+ deploymentOK + nbPacks + ",\n"  + sCacheResetMsg);			
			MFL_141119: For dynamic Dico_End */
			ArrayList<String> numberOfPack = new ArrayList<String>();
			numberOfPack.add(Integer.toString(nbPublishedPacks));
			numberOfPack.add(Integer.toString(nbPacks));
			String deploymentOK = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.DeploymentOK",numberOfPack);
			emxNavErrorObject.addMessage(deploymentOK);

		}
		catch (Exception e)
		{
			System.out.println("Deployment KO" + e.getMessage());
			emxNavErrorObject.addMessage(deploymentKO + e.getMessage());									
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
