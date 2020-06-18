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
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Map"%>
<%@page import = "java.util.Set"%>
<%@page import = "java.util.Iterator"%>
<%@page import = "java.util.Collections"%>
<%@page import = "java.util.List"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%


String selPacksIds[] = emxGetParameterValues(request, "emxTableRowId");


int nbSelectedPack = (null != selPacksIds) ? selPacksIds.length : -1;
int result = 0;
Map<String,Integer> Packages = new HashMap<String,Integer>();
int k = 0;
System.out.println(nbSelectedPack + " package(s) to Deprecated");
if ((null != selPacksIds) )
{
    int nbDeprecatedPacks = 0;
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
					result = pack.setContentDeprecated(context, true, true);
					if(result!=0)
					{
						nbDeprecatedPacks++;
					}
					Packages.put(pack.getName(context),result);
				  }
				}
				else
					System.out.println("ERROR : Package " + packId + " not found");
			}
			System.out.println("Deprecation OK. " + nbDeprecatedPacks + " deprecated on " + nbSelectedPack );
			%>
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>		
			<%
			
			ArrayList<String> nbPack = new ArrayList<String>();
			nbPack.add(Integer.toString(nbDeprecatedPacks));
			nbPack.add(Integer.toString(nbSelectedPack));
			String setDeprecatedOK = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.DeprecatedPackOK",nbPack);
			Set<String> keys = Packages.keySet();
			List<String> list = new ArrayList<String>(keys);
			Collections.sort(list);
// 			Iterator itKey = keys.iterator();
// 			while(itKey.hasNext())
			for(String sVal:list)
			{
				String packName = sVal;// (String)itKey.next();
				int elements = Packages.get(packName);
				ArrayList<String> nbElements = new ArrayList<String>();
				nbElements.add(packName);
				nbElements.add(Integer.toString(elements));
				String ElementsByPackage = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ElementsByPackage",nbElements);
				setDeprecatedOK = setDeprecatedOK + "\n" + ElementsByPackage;
			}
			String infoDeprecatedOK = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.InfoDeprecatedPackOK");
			setDeprecatedOK = setDeprecatedOK + "\n \n" + infoDeprecatedOK;
			emxNavErrorObject.addMessage(setDeprecatedOK);

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
