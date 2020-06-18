<%--  emxPackagesConfigurationCreateAttribute.jsp - Creating Attribute object
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreateAttribute.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.*"%>
<%@page import = "com.dassault_systemes.ontology_itfs.OntoException"%>
<%@page import = "com.matrixone.apps.domain.util.eMatrixDateFormat"%>
<%@page import = "com.dassault_systemes.knowledge_itfs.IKweUnit"%>
<%@page import = "com.dassault_systemes.knowledge_itfs.KweInterfacesServices"%>
<%@page import = "com.dassault_systemes.knowledge_itfs.IKweDictionary"%>
<%@page import = "java.util.*"%>
<%@page import = "java.util.List"%>
<%@page import = "java.text.*"%>
<%@page import = "matrix.db.*"%>
<%@page import = "matrix.util.*"%>


<%
String currentTypeId = emxGetParameter(request, "objectId");
String attrName = emxGetParameter(request, "attrName");
String attrType = emxGetParameter(request, "attrType");
String plmType = emxGetParameter(request, "txtPLMType");
String attrUnit = emxGetParameter(request, "attrUnit");
String multiVal = emxGetParameter(request, "multiVal");
if(null==multiVal || "".equals(multiVal) || "null".equals(multiVal))
	multiVal="false";
String attrProtection = emxGetParameter(request, "attrProtection");

if (attrType.equals("Magnitude"))
{
	String magnitude = emxGetParameter(request, "txtMagnitude");
	String strChooseMagnitude = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AttributChooseMagnitude");

	if ((null != magnitude) && !magnitude.isEmpty() && !magnitude.equals(strChooseMagnitude)) 
	{
		attrType = magnitude;
	}
	else
	{
		emxNavErrorObject.addMessage("Must enter valid value for magnitude.");									
		%>
		<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
		<%
		return;
	}
}

String selectedFrame = "";
if ("".equals(attrType))
	attrType = null;
if ("".equals(attrProtection))
	attrProtection = null;
/**
 * MFL - Try to recover here values recongnized by M1 and not those that are NLS
 */
/*JPI 05/08/27 IR-393694-3DEXPERIENCER2016x 
if (attrType != null) {
	String nlsString = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeString");
	String nlsInteger = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeInteger");
	String nlsBoolean = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeBoolean");
	String nlsDate = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeDate");
	String nlsReal = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeReal");
	String nlsList = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeList");
	if (attrType.equals(nlsString)) 
		attrType = "String";
	else if (attrType.equals(nlsInteger))
		attrType = "Integer";
	else if (attrType.equals(nlsBoolean)) 
		attrType = "Boolean";
	else if (attrType.equals(nlsDate)) 
		attrType = "Date";
	else if (attrType.equals(nlsReal)) 
		attrType = "Real";
	else if (attrType.equals(nlsList)) 
		attrType = "List";
}*/
String strChoosePLMType = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AttributeChoosePLMType");
if(plmType!=null && !plmType.isEmpty() && !plmType.equals(strChoosePLMType)){
	attrType = plmType;
}
String nlsTrue = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanTrue");
String nlsFalse = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanFalse");

if (attrProtection != null) {
	String nlsReadWrite = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AttributeUserAccessReadWrite");
	String nlsReadOnly = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AttributeUserAccessReadOnly");
	String nlsNone = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AttributeUserAccessNone");
	if (attrProtection.equals(nlsReadWrite)) 
		attrProtection = "ReadWrite";
	else if (attrProtection.equals(nlsReadOnly)) 
		attrProtection = "ReadOnly";
	else if (attrProtection.equals(nlsNone)) 
		attrProtection = "None";
}

boolean attrMultiVal = false;
if(nlsTrue.equals(multiVal.trim()) || "true".equals(multiVal.trim()))
  attrMultiVal = true;
else if(nlsFalse.equals(multiVal.trim()) || "false".equals(multiVal.trim()))
  attrMultiVal = false;

/**
 * MFL - Try now to create attribute
 */
if ((null != currentTypeId) && !currentTypeId.isEmpty())
{
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			DAuData data = manager.getTypeOrExtensionFromId(context, currentTypeId);
			if (null != data)
			{
				IDAuType type = data.IDAUTYPE;
				IDAuExtension extension = data.IDAUEXTENSION;
				IDAuType instance = data.IDAUINSTANCE;
				DAuAttrInfosData attrInfosData 	  = new DAuAttrInfosData();
				attrInfosData.S_Type              = attrType;
				attrInfosData.S_UserAccess        = attrProtection;
				attrInfosData.B_IsVolatile		  = true;
				attrInfosData.B_MultiValuated     = attrMultiVal;
				attrInfosData.S_PreferredUnit     = attrUnit;
				String volExtName = "";
				IDAuPackage pack = null;
				String mPackagePrefix= "";
				boolean bIRPCCusto = false;
				String packName = "";
				String typeExtName = "";
				String iTargetedEntities= ""; 
				if (null != type)
				{
					selectedFrame="type";
					pack = type.getPackage(context);
					mPackagePrefix= pack.getPrefix(context);
					bIRPCCusto = pack.isIRPCCusto(context);
					packName = pack.getName(context);
					typeExtName = type.getName(context);
					IDAuAttrInfos attrInfos = type.createAttrInfos(context, attrInfosData);
					if (null != attrInfos)
					{
						IDAuAttribute attribute = type.addAttribute(context, attrName, attrInfos);
						if (null != attribute)
						{
							attribute.setVolatile(context, true);
							if (mPackagePrefix != null && !mPackagePrefix.isEmpty()) {
								typeExtName = mPackagePrefix + typeExtName;
							}

							if (packName.contains(" ")) {
								packName = "\"" + packName + "\"";
								typeExtName = "\"" + typeExtName + "\"";
							}
							volExtName = packName+"."+typeExtName+"_VolatileItf";
							if (bIRPCCusto) {
								typeExtName = DAuCustoDictionary.IRPC_TYP + typeExtName;
							}
							iTargetedEntities = "Type."+typeExtName;
						}
					}
				}
				else if(null != extension)
				{
					selectedFrame="extension";
					pack = extension.getPackage(context);
					mPackagePrefix= pack.getPrefix(context);
					bIRPCCusto = pack.isIRPCCusto(context);
					packName = pack.getName(context);
					typeExtName = extension.getName(context);
					IDAuAttrInfos attrInfos = extension.createAttrInfos(context,attrInfosData);
					if (null != attrInfos)
					{
						IDAuAttribute attribute = extension.addAttribute(context, attrName, attrInfos);
						if (null != attribute)
						{
							attribute.setVolatile(context, true);
							if (mPackagePrefix != null && !mPackagePrefix.isEmpty()) {
								typeExtName = mPackagePrefix + typeExtName;
							}

							if (packName.contains(" ")) {
								packName = "\"" + packName + "\"";
								typeExtName = "\"" + typeExtName + "\"";
							}
							volExtName = packName+"."+typeExtName+"_VolatileItf";
							if (bIRPCCusto) {
								typeExtName = DAuCustoDictionary.IRPC_ITF + typeExtName;
							}
							iTargetedEntities = "Interface."+typeExtName;
						}
					}
				} else{
					// instance
					selectedFrame="type";
					pack = instance.getPackage(context);
					mPackagePrefix= pack.getPrefix(context);
					bIRPCCusto = pack.isIRPCCusto(context);
					packName = pack.getName(context);
					typeExtName = instance.getName(context);
					IDAuAttrInfos attrInfos = instance.createAttrInfos(context,attrInfosData);
					if (null != attrInfos)
					{
						IDAuAttribute attribute = instance.addAttribute(context, attrName, attrInfos);
						if (null != attribute)
						{
							attribute.setVolatile(context, true);
							if (mPackagePrefix != null && !mPackagePrefix.isEmpty()) {
								typeExtName = mPackagePrefix + typeExtName;
							}
							if (packName.contains(" ")) {
								packName = "\"" + packName + "\"";
								typeExtName = "\"" + typeExtName + "\"";
							}
							volExtName = packName+"."+typeExtName+"_VolatileItf";
							if (bIRPCCusto) {
								typeExtName = DAuCustoDictionary.IRPC_REL + typeExtName;
							}
							iTargetedEntities = "Relation."+typeExtName;
						}
					}
				
				}
				if(pack !=null){
					//IDAuExtension volatileExt = pack.createExtensionForVolatiles(context, volExtName, iTargetedEntities,false);
					//if(volatileExt !=null){
						%>
						<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
						<%
					//}
				
				}
			}
		}
		catch (OntoException e)
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
var selectFrame = "<%=selectedFrame%>";
var sbWindow;
if(selectFrame == "type")
	sbWindow = findFrame(top, "PackageConfigTypesCmd");
else
	sbWindow = findFrame(top, "PackageConfigExtsCmd");
if(!sbWindow){
	sbWindow = findFrame(top, "DeploymentExtensionsCmd");
}
if(sbWindow && typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.refreshStructureWithOutSort){
   sbWindow.emxEditableTable.refreshStructureWithOutSort();
   //sbWindow.refreshRows();
   //sbWindow.expandAll();    
}
var sbChannelAttr = findFrame(top, "PackageConfigAttributesCmd");
if(sbChannelAttr){
	sbChannelAttr.location.href = sbChannelAttr.location.href;
}
var sbChannelDeplAttr = findFrame(top, "DeploymentAttributesCmd");
if(sbChannelDeplAttr){
	sbChannelDeplAttr.location.href = sbChannelDeplAttr.location.href;
}

</script> 
