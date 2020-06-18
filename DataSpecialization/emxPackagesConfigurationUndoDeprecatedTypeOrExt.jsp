<%--  emxPackagesConfigurationPublish.jsp  --  Publish the selected packages
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreatePackage.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>
<%@page import="com.dassault_systemes.DictionaryAuthor_itfs.DAuCustoDictionary"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuType"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
  String selTypesId[] = emxGetParameterValues(request, "emxTableRowId");
int nbSelectedTypeExt = (null != selTypesId) ? selTypesId.length : -1;
int k = 0;
System.out.println(nbSelectedTypeExt + " Type(s) or Extension(s) to deprecated");
if ((null != selTypesId) )
{
    int nbUndoDeprecatedTypeExt = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
    if (null != manager) {
      try {
        for (k = 0; k < nbSelectedTypeExt; k++) {
          String typeId = selTypesId[k];
          // YI3 - Ids :  |38016.53567.5632.5790|38016.53567.5632.5790|0,1				
          if (typeId.startsWith("|") == true) {
            typeId = typeId.substring(1);
          }
          int idxPipes = typeId.indexOf("|");
          if (idxPipes > 0) {
            typeId = typeId.substring(0, idxPipes);
          }
          DAuData data = manager.getTypeOrExtensionFromId(context, typeId);
          if (null != data) {
            IDAuType type = data.IDAUTYPE;
            if (type == null)
              type = data.IDAUINSTANCE;
            if (null != type) {
                String typePublishStatus = "";
                typePublishStatus = type.getPublishStatus(context);
                if (type.canBeModified(context) && type.isDeprecated(context)
                    && !typePublishStatus
                        .equals(DAuCustoDictionary.COMPARATOR_STATUS_NO)) {
                  type.setDeprecated(context, false, true);
                  nbUndoDeprecatedTypeExt++;
                }

            } else {
              IDAuExtension ext = data.IDAUEXTENSION;
              if (null != ext) {
                  String extPublishStatus = "";
                  extPublishStatus = ext.getPublishStatus(context);
                  if (ext.canBeModified(context) && ext.isDeprecated(context)
                      && !extPublishStatus
                          .equals(DAuCustoDictionary.COMPARATOR_STATUS_NO)) {
                    ext.setDeprecated(context, false, true);
                    nbUndoDeprecatedTypeExt++;
                  }
              }

            }

          }
        }
        System.out.println("Deprecated OK : " + nbUndoDeprecatedTypeExt
            + " deprecated on " + nbSelectedTypeExt);
        ArrayList<String> numberOfPack = new ArrayList<String>();
		numberOfPack.add(Integer.toString(nbUndoDeprecatedTypeExt));
		numberOfPack.add(Integer.toString(nbSelectedTypeExt));
		String undoDeprecatedTypeExtOK = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.UndoDeprecatedTypeExtOK",numberOfPack);
		emxNavErrorObject.addMessage(undoDeprecatedTypeExtOK);
%>
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
			<%
			
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
for(index = 0; index < channelBas.length; index++){
	sbWindowBas = findFrame(top, channelBas[index]);
	if(sbWindowBas){
		sbWindowBas.location.href = sbWindowBas.location.href;
		break;
	}
}

</script>

