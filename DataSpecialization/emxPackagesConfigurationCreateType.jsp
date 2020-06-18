<%--  emxPackagesConfigurationCreateType.jsp  --  Creating Package object
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreateType.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuType"%>
<%@page import = "com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>

<%
String objectId = emxGetParameter(request, "objectId");
String typeName = emxGetParameter(request, "custoTypeName");
String parentTypeName = emxGetParameter(request, "parent");
String parentfieldValueOID = emxGetParameter(request, "parentfieldValueOID");
String TypeComment = emxGetParameter(request, "userComment");
String instName = emxGetParameter(request, "instanceName");
String iconName = emxGetParameter(request, "IconName");
String sIsAbstract = emxGetParameter(request, "abstractOption");

String nlsTrue = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanTrue");
String nlsFalse = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanFalse");

boolean isAbstract = false; 
if(sIsAbstract!=null && !sIsAbstract.isEmpty())
  isAbstract = nlsTrue.equals(sIsAbstract) ? true : false;

if ((null != objectId) && !objectId.isEmpty() && (null != typeName) && !typeName.isEmpty() && (null != parentTypeName) && !parentTypeName.isEmpty() && (null != parentfieldValueOID) && !parentfieldValueOID.isEmpty())
{
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			IDAuPackage custoPackage = manager.getPackageFromId(context, parentfieldValueOID);
			if (null != custoPackage)
			{
				DAuData data = manager.getTypeOrExtensionFromId(context, objectId);
				if (null != data)
				{
					IDAuType type = data.IDAUTYPE;
					if (null != type)
					{		
						IDAuType newType = custoPackage.createSpecializationType(context, typeName, type.getName(),TypeComment,isAbstract);
						if (null != newType)
						{
							String newTypeId = newType.getID(context);
							if(null != instName && !instName.isEmpty()){
								newType.setInstanceName(context,instName,false);
							}
							if(null != iconName && !iconName.isEmpty()){
								newType.setIconName(context,iconName,false);
							}
							%>
							<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
							<%
						}
						else
						{							
							%>
							<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
							<%
						}
					}else 
					{
						IDAuType instance = data.IDAUINSTANCE;
						IDAuType newInstance = custoPackage.createSpecializationInstance(context, typeName, instance.getName(),TypeComment);
						if (null != newInstance)
						{
							String newInstanceName = newInstance.getName(context);							
							%>
							<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
							<%
						}
						else
						{							
							%>
							<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
							<%
						}
					
					}
				}
			}
		}
		catch (Exception e)
		{
			session.putValue("error.message", e.getMessage());
			%>
			<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
			<%
		}
	}
}
%>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript">
var sbWindow = findFrame(top, "PackageConfigTypesCmd");

if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.refreshStructureWithOutSort){
   sbWindow.emxEditableTable.refreshStructureWithOutSort();
   sbWindow.refreshRows();
   sbWindow.expandAll(); 
   
}
</script> 
