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
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuUniquenessKey"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuCustoDictionary"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
boolean mbDisableDeleteOnceDeployed = System.getenv("TXO_DisableDeleteOnceDeployed"+context.getTenant()) != null;
String selUkeysIds[] = emxGetParameterValues(request, "emxTableRowId");
int nbUKs = (null != selUkeysIds) ? selUkeysIds.length : -1;
int k = 0;
System.out.println(nbUKs + " Unique key(s) to delete");
if ((null != selUkeysIds) )
{
    int nbDeletedUks = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			for (k = 0; k<nbUKs; k++)
			{				String ukeyId = selUkeysIds[k];
				// JPI le 07 octobre 11 curieusement la forme des Ids a changé :  |38016.53567.5632.5790||0,1				
				if (ukeyId.startsWith("|") == true ) {
					ukeyId = ukeyId.substring(1);
				}
				int idxPipes = ukeyId.indexOf("|");
				if (idxPipes > 0 ) {								
					ukeyId = ukeyId.substring(0,idxPipes);
				}
				System.out.println("YI3 - ukeyId " + ukeyId  );
				IDAuUniquenessKey ukey = manager.getUniquenessKeyFromId(context,ukeyId);
				if (null != ukey){				
					//try{
						String pubStatus = ukey.getPublishStatus(context);
						if(pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_NO)){
							ukey.deleteUniquenessKey(context);
							nbDeletedUks++;
						}
						else if (pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_YES) || pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_PARTIAL)){
							if(mbDisableDeleteOnceDeployed)
								throw new Exception(DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.DeleteUK",ukey.getName(context)));
							ukey.deleteOnceDeployed(context);
							nbDeletedUks++;
						}
		/*			}
		 			catch (Exception e)
					{
						System.out.println("Delete : " + ukey.getUniquenessKeyName(context) + " cannot be deleted.");
						emxNavErrorObject.addMessage("Delete : " + ukey.getUniquenessKeyName(context) + " cannot be deleted,\n");							
					} */
				}
				else
					System.out.println("ERROR : Uniqueness key " + ukeyId + " not found");
			}
			System.out.println("Delete OK : " + nbDeletedUks + " deleted on " + nbUKs );
			emxNavErrorObject.addMessage(nbDeletedUks + " Uniqueness Key(s) deleted on " + nbUKs + ",\n");			
			//emxNavErrorObject.addMessage("Delete Uniqueness Key(s) not yet implemented.");			
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
