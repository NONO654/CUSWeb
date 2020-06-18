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
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuCustoDictionary"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
boolean mbDisableDeleteOnceDeployed = System.getenv("TXO_DisableDeleteOnceDeployed"+context.getTenant()) != null;
String selExtsIds[] = emxGetParameterValues(request, "emxTableRowId");
int nblExts = (null != selExtsIds) ? selExtsIds.length : -1;
int k = 0;
System.out.println(nblExts + " Extension(s) to delete");
if ((null != selExtsIds) )
{
    int nbDeletedPacks = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			for (k = 0; k<nblExts; k++)
			{				String extId = selExtsIds[k];
				// JPI le 07 octobre 11 curieusement la forme des Ids a changé :  |38016.53567.5632.5790||0,1				
				if (extId.startsWith("|") == true ) {
					extId = extId.substring(1);
				}
				int idxPipes = extId.indexOf("|");
				if (idxPipes > 0 ) {								
					extId = extId.substring(0,idxPipes);
				}
				DAuData data = manager.getTypeOrExtensionFromId(context, extId);
				if (null != data)
				{
					IDAuExtension extension = data.IDAUEXTENSION;
					if (null != extension){		
						String pubStatus = extension.getPublishStatus(context);
						if(pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_NO)){
							extension.delete(context);
							nbDeletedPacks++;
						}
						else if(pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_YES) || pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_PARTIAL)){
							if(mbDisableDeleteOnceDeployed)
								throw new Exception(DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.DeleteExtension",extension.getName(context)));
							extension.deleteOnceDeployed(context);
							nbDeletedPacks++;
						}
					}else{
						System.out.println("ERROR : Extension " + extId + " not found");
					}

				}
			System.out.println("Delete OK : " + nbDeletedPacks + " deleted on " + nblExts );
			emxNavErrorObject.addMessage(nbDeletedPacks + " Extension(s) (with sub-Extensions) deleted on " + nblExts + ",\n");	
			%>
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
			<%
			}
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
