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
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttribute"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
String selPacksIds[] = emxGetParameterValues(request, "emxTableRowId");
int nbPacks = (null != selPacksIds) ? selPacksIds.length : -1;

int k = 0;
String selectedFrame = "";
System.out.println(nbPacks + " package(s) to Set Read-Only");
if ((null != selPacksIds) )
{
    int nbSelectedPacks = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			for (k = 0; k<nbPacks; k++)
			{	
				String packId = selPacksIds[k];
				// JPI le 07 octobre 11 curieusement la forme des Ids a chang :  |38016.53567.5632.5790||0,1				
				if (packId.startsWith("|") == true ) {
					packId = packId.substring(1);
				}
				int idxPipes = packId.indexOf("|");
				if (idxPipes > 0 ) {								
					packId = packId.substring(0,idxPipes);
				}
				IDAuPackage pack = manager.getPackageFromId(context,packId);
				if (null != pack){
					try{
						pack.setModify(context,false);
						nbSelectedPacks++;
					}
					catch (Exception e)
					{
						System.out.println("Read-Only KO" + e.getMessage());
						String ReadOnlyFailure = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ReadOnlyFailure");
						emxNavErrorObject.addMessage(ReadOnlyFailure + e.getMessage());
						//System.out.println( pack.getName(context) + " cannot be Set Read-Only.");
						//emxNavErrorObject.addMessage(pack.getName(context) + " cannot be Set Read-Only,\n");
					}
				}
				else
					System.out.println("ERROR : package " + packId + " not found");
			}
			System.out.println("Read-Only OK : " + nbSelectedPacks + " Set Read-Only on " + nbPacks );
			ArrayList<String> numberOfPack = new ArrayList<String>();
			numberOfPack.add(Integer.toString(nbSelectedPacks));
			numberOfPack.add(Integer.toString(nbPacks));
			String ReadOnlyOK = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.SetReadOnlyOK",numberOfPack);
			emxNavErrorObject.addMessage(ReadOnlyOK);	
			%>
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
			<%
		}
		catch (Exception e)
		{
			String ReadOnlyFailure = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ReadOnlyFailure");
			System.out.println("Read-Only KO" + e.getMessage());
			emxNavErrorObject.addMessage(ReadOnlyFailure + e.getMessage());									
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
