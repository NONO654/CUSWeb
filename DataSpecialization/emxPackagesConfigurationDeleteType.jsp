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
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuCustoDictionary"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
boolean mbDisableDeleteOnceDeployed = System.getenv("TXO_DisableDeleteOnceDeployed"+context.getTenant()) != null;
String selTypesId[] = emxGetParameterValues(request, "emxTableRowId");
int nbTypes = (null != selTypesId) ? selTypesId.length : -1;
int k = 0;
System.out.println(nbTypes + " Type(s) to delete");
if ((null != selTypesId) )
{
    int nbDeletedTypes = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			for (k = 0; k<nbTypes; k++)
			{				String typeId = selTypesId[k];
				// YI3 - Ids :  |38016.53567.5632.5790|38016.53567.5632.5790|0,1				
				if (typeId.startsWith("|") == true ) {
					typeId = typeId.substring(1);
				}
				int idxPipes = typeId.indexOf("|");
				if (idxPipes > 0 ) {								
					typeId = typeId.substring(0,idxPipes);
				}
				DAuData data = manager.getTypeOrExtensionFromId(context, typeId);
				if (null != data)
				{
					IDAuType type = data.IDAUTYPE;
					if (type == null)
						type = data.IDAUINSTANCE;
					if (null != type){
						String pubStatus = type.getPublishStatus(context);
						if(pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_NO)){
							type.delete(context);
							nbDeletedTypes++;
						}

						else if (pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_YES) || pubStatus.equals(DAuCustoDictionary.COMPARATOR_STATUS_PARTIAL)){
							if(mbDisableDeleteOnceDeployed){
								if(type.isAnInstance(context)){
									throw new Exception(DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.DeleteInst",type.getName(context)));
								}
								else{
									throw new Exception(DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.ErrMsg.DeleteType",type.getName(context)));
								}				
							}
							type.deleteOnceDeployed(context);
							nbDeletedTypes++;
						}
						
					}else{
						System.out.println("ERROR : Type " + typeId + " not found");
					}

				}
			}
			System.out.println("Delete OK : " + nbDeletedTypes + " deleted on " + nbTypes );
			emxNavErrorObject.addMessage(nbDeletedTypes + " Type(s) (with sub-Types) deleted on " + nbTypes + ",\n");			
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
