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
System.out.println(nbPacks + " package(s) to Set Read/Write");
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
						pack.setModify(context,true);
						nbSelectedPacks++;
					}
					catch (Exception e)
					{
						String msg =DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.SetReadWritePackage", pack.getName(context));
						System.out.println("Read/Write KO : "+msg);
						String readWriteFailure = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ReadWriteFailure");
						emxNavErrorObject.addMessage(readWriteFailure + msg);
					}
				}
				else
					System.out.println("ERROR : package " + packId + " not found");
			}
			System.out.println("Read/Write OK : " + nbSelectedPacks + " Set Read/Write on " + nbPacks );
			ArrayList<String> numberOfPack = new ArrayList<String>();
			numberOfPack.add(Integer.toString(nbSelectedPacks));
			numberOfPack.add(Integer.toString(nbPacks));
			String readWriteOK = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.SetReadWriteOK",numberOfPack);
			emxNavErrorObject.addMessage(readWriteOK);	
			%>
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
			<%
		}
		catch (Exception e)
		{
			String readWriteFailure = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ReadWriteFailure");
			System.out.println("Read/Write KO : " + e.getMessage());
			emxNavErrorObject.addMessage(readWriteFailure + e.getMessage());									
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
