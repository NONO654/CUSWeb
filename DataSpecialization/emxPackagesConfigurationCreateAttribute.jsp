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
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuAttrInfosData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuType"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttrInfos"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttribute"%>
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


<%!
String dateFromMs(String ms_date,Context context){
  String dateValue="";
  Locale locale = i18nNow.getLocale(context.getSession().getLanguage());
  long millis = Long.parseLong(ms_date);  
  Calendar cal = Calendar.getInstance(locale);			  
				  cal.setTimeInMillis(millis);
				  //cal.set(Calendar.HOUR, 0);
				  //cal.set(Calendar.MINUTE, 0);
				  //cal.set(Calendar.SECOND, 0);
				  //cal.set(Calendar.AM_PM, Calendar.AM);
				  
   DateFormat formatter = matrix.util.DateFormatUtil.getGenericDateFormat();
   dateValue = formatter.format(cal.getTime());			  
  return dateValue;
}

String manageRealValues(String value){
	String returnVal="";
	try{		
		returnVal=DAuUtilities.shortenRealValues(value);
	}
	catch (Exception e)
	{
		//session.putValue("error.message", e.getMessage());
		System.out.println(" manageRealValues - error : "+e.getMessage());
	}
	return returnVal;
}

%>

<%

//System.out.println("GMX - CreateAttribute - hashMap");
Enumeration eNumParameters = emxGetParameterNames(request);
 // String parmValue = "";
/*
    while( eNumParameters.hasMoreElements() ) {
      String parmName  = (String)eNumParameters.nextElement();
System.out.println("param  : " + parmName + " - value : " + emxGetParameter(request, parmName));
     }
System.out.println("GMX - CreateAttribute - hashMap");
*/
String currentTypeId = emxGetParameter(request, "objectId");
String attrName = emxGetParameter(request, "attrName");
String attrType = emxGetParameter(request, "attrType");
String attrEmptyRange = emxGetParameter(request, "addEmptyRange");
boolean isMagnitude=false;
if (attrType.equals("Magnitude"))
{
	String magnitude = emxGetParameter(request, "txtMagnitude");
	String strChooseMagnitude = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AttributChooseMagnitude");

	if ((null != magnitude) && !magnitude.isEmpty() && !magnitude.equals(strChooseMagnitude)) 
	{
		attrType = magnitude;
		isMagnitude=true;
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
HashMap<Integer,String> rangeValuesTmp =new HashMap<Integer,String>();
HashMap<Integer,String> rangeValuesMsTmp =new HashMap<Integer,String>();
HashMap<Integer,String> rangeMagnitudesTmp =new HashMap<Integer,String>();
ArrayList<String> rangeValues = new ArrayList<String>();
ArrayList<String> rangeValuesMs = new ArrayList<String>();
ArrayList<String> rangeMagnitudes = new ArrayList<String>();
String attrUnit = emxGetParameter(request, "attrUnit");
String attrLength = emxGetParameter(request, "attrLength");
String attrDefaultValue = emxGetParameter(request, "defaultValue");
String resetCloning = emxGetParameter(request, "resetCloning");
String resetNew = emxGetParameter(request, "resetNew");
String attrProtection = emxGetParameter(request, "attrProtection");
String attrIndexation = emxGetParameter(request, "attrIndexation");
String attr3DXML = emxGetParameter(request, "attr3DXML");
String attr6w = emxGetParameter(request, "txtattr6w");
if(attr6w!=null && attr6w.contains("_")){
	//BMN2 14/05/2019 : IR-678718
	int indexOfSepr = attr6w.lastIndexOf('_');
	if(indexOfSepr>0 && indexOfSepr<attr6w.length())
	{
		attr6w=attr6w.substring(0,indexOfSepr);
	}
}
String attrXPDM = emxGetParameter(request, "attrXPDM");
//BMN2 FUN076582 08/02/2018
String attrResetOnFork = emxGetParameter(request, "attrResetOnFork");
String multiVal = emxGetParameter(request, "multiVal");
String attrMultiline = emxGetParameter(request,"attrMultiline");
if(null==multiVal || "".equals(multiVal) || "null".equals(multiVal))
	multiVal="false";

//System.out.println("GMX - Attribute - ID du type : " + currentTypeId);
//System.out.println("GMX - Attribute - name : " + attrName);
//System.out.println("GMX - Attribute - type : " + attrType);
//System.out.println("GMX - Attribute - unit : " + attrUnit);
//System.out.println("GMX - Attribute - length : " + attrLength);
//System.out.println("GMX - Attribute - default : " + attrDefaultValue);
// yi3 test date format
String defaultValue_msvalue = emxGetParameter(request, "defaultValue_msvalue");
String selectedFrame = "";
//System.out.println("GMX - Attribute - reset on cloning : " + resetCloning);
//System.out.println("GMX - Attribute - reset on new : " + resetNew);
//System.out.println("GMX - Attribute - protection : " + attrProtection);
if ("".equals(attrType))
	attrType = null;
if ("".equals(attrLength))
	attrLength = null;
if ("".equals(attrProtection))
	attrProtection = null;
/**
 * MFL - Try to revover here values recongnized by M1 and not those that are NLS
 */
/*JPI 05/08/27 IR-393694-3DEXPERIENCER2016x 
 if (attrType != null) {
	String nlsString = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeString");
	String nlsInteger = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeInteger");
	String nlsBoolean = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeBoolean");
	String nlsDate = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeDate");
	String nlsReal = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.AtributeTypeReal");
	if (attrType.contains(nlsString)) 
		attrType = "String";
	else if (attrType.contains(nlsInteger))
		attrType = "Integer";
	else if (attrType.contains(nlsBoolean)) 
		attrType = "Boolean";
	else if (attrType.contains(nlsDate)) 
		attrType = "Date";
	else if (attrType.contains(nlsReal)) 
		attrType = "Real";
}*/
String attrRange = emxGetParameter(request, "attrRange_0_rng");
String attrRangeMs = emxGetParameter(request, "attrRange_0_rng_msvalue");

//if((null!=attrRange && !"".equals(attrRange) && !"null".equals(attrRange)) || (null!=attrRangeMs && !"".equals(attrRangeMs) && !"null".equals(attrRangeMs)) )
//{
	//construire la liste des valeurs 
	while( eNumParameters.hasMoreElements() ) {
		String parmName  = (String)eNumParameters.nextElement();
		if(parmName.contains("_rng")){
		  int order=0;
		  String paramNameList[] = parmName.split("_");
		  if(paramNameList!=null && paramNameList.length>1){
		    order=Integer.parseInt(paramNameList[1]);
		  }
			String parmValue = emxGetParameter(request, parmName);
			//System.out.println("param  : " + parmName + " - value : " + parmValue);
			if(null!=parmValue && !"".equals(parmValue) && !"null".equals(parmValue) && !"#0".equals(parmValue)){
				if(parmName.contains("_msvalue") && "Date".equals(attrType)){
					rangeValuesMsTmp.put(order,parmValue);
					//System.out.println("**MS param  : " + parmName + " - value : " + parmValue);
				}else if(attrUnit!=null && !attrUnit.isEmpty()&& attrDefaultValue != null && !attrDefaultValue.isEmpty()){
					rangeMagnitudesTmp.put(order,parmValue);	
					//System.out.println("**Mag param  : " + parmName + " - value : " + parmValue);	
					// BMN2-IR-347926 03/02/15
				}else if("Real".equals(attrType) && attrDefaultValue != null && !attrDefaultValue.isEmpty()){
					rangeValuesTmp.put(order,manageRealValues(parmValue));
				}else{
					rangeValuesTmp.put(order,parmValue);
					//System.out.println("**Other param  : " + parmName + " - value : " + parmValue);
				}
			}
		}
	}
	 if(!rangeValuesTmp.isEmpty()){
         TreeMap<Integer,String> sorted = new TreeMap<Integer,String>(rangeValuesTmp);
         rangeValues = new ArrayList<String> (sorted.values());
       }
	 if(!rangeMagnitudesTmp.isEmpty()){
         TreeMap<Integer,String> sorted = new TreeMap<Integer,String>(rangeMagnitudesTmp);
         rangeMagnitudes = new ArrayList<String> (sorted.values());
       }
	 if(!rangeValuesMsTmp.isEmpty()){
         TreeMap<Integer,String> sorted = new TreeMap<Integer,String>(rangeValuesMsTmp);
         rangeValuesMs = new ArrayList<String> (sorted.values());
       }
//}

//YI3 - convert date to millisecondes 
// BMN2-IR-347926 03/02/15
if(attrType.equals("Date") && !"#0".equals(defaultValue_msvalue)){
	attrDefaultValue = dateFromMs(defaultValue_msvalue, context);
}
//if(null!=attrRangeMs && !"".equals(attrRangeMs) && !"null".equals(attrRangeMs)){ 
		for(String val : rangeValuesMs){
			rangeValues.add(dateFromMs(val, context));
		}
	//}


String nlsTrue = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanTrue");
String nlsFalse = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanFalse");

if(attrType.equals("Boolean") && attrDefaultValue != null && !attrDefaultValue.isEmpty()){
	if(nlsTrue.equalsIgnoreCase(attrDefaultValue.trim()) || "true".equalsIgnoreCase(attrDefaultValue.trim()))
	  attrDefaultValue = "true";
	else if(nlsFalse.equalsIgnoreCase(attrDefaultValue.trim()) || "false".equalsIgnoreCase(attrDefaultValue.trim()))
	  attrDefaultValue = "false";
}
if(attrUnit!=null && !attrUnit.isEmpty()&& attrDefaultValue != null && !attrDefaultValue.isEmpty()){
	IKweDictionary dico = KweInterfacesServices.getKweDictionary();
	if (dico != null) {
		IKweUnit unit = dico.findUnit(context, attrUnit);
		attrDefaultValue= String.valueOf(unit.convert(Double.valueOf(attrDefaultValue)));
		if(!rangeMagnitudes.isEmpty())
			attrDefaultValue= manageRealValues(attrDefaultValue);
		for(String sval : rangeMagnitudes){
			sval=String.valueOf(unit.convert(Double.valueOf(sval)));
			rangeValues.add(manageRealValues(sval));
		}
	}
}
if(attrType.equals("Integer") && attrDefaultValue != null && attrDefaultValue.isEmpty()){
	attrDefaultValue = "0";
}
if((attrType.equals("Real") || isMagnitude) && attrDefaultValue != null ){
	if(attrDefaultValue.isEmpty()){
		attrDefaultValue = "0.0";
	}else{
		if(!rangeValues.isEmpty())
			attrDefaultValue = manageRealValues(attrDefaultValue);
	}
}
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

boolean attrResetCloning = nlsTrue.equals(resetCloning) ? true : false;
boolean attrResetNew = nlsTrue.equals(resetNew) ? true : false;
//boolean attrMultiVal = nlsTrue.equals(multiVal) ? true : false;
boolean attrMultiVal = false;

if(nlsTrue.equals(multiVal.trim()) || "true".equals(multiVal.trim()))
  attrMultiVal = true;
else if(nlsFalse.equals(multiVal.trim()) || "false".equals(multiVal.trim()))
  attrMultiVal = false;
boolean attributeIndexation = nlsTrue.equals(attrIndexation) ? true : false;
boolean attribute3DXML = nlsTrue.equals(attr3DXML) ? true : false;
boolean attributeExportable = nlsTrue.equals(attrXPDM) ? true : false;
boolean attributeResetOnFork = false;
if(attrResetOnFork!=null && !attrResetOnFork.isEmpty()){
	attributeResetOnFork = nlsTrue.equals(attrResetOnFork) ? true : false;
}
boolean attributeMultiline = false;
if(attrMultiline!=null && !attrMultiline.isEmpty()){
	attributeMultiline = nlsTrue.equals(attrMultiline) ? true : false;
}
if(attrEmptyRange!=null && attrEmptyRange.equals("empty")){
  attrDefaultValue="";
  rangeValues.add(0, "");
}

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
				if (null != type)
				{
					selectedFrame="type";
					DAuAttrInfosData attrInfosData = new DAuAttrInfosData();
					attrInfosData.S_Type              = attrType;
					attrInfosData.S_PreferredUnit     = attrUnit;
					attrInfosData.S_Length            = attrLength;
					attrInfosData.S_DefaultValue      = attrDefaultValue;
					attrInfosData.B_ResetOnCloning    = attrResetCloning;
					attrInfosData.B_ResetOnNewVersion = attrResetNew;
					attrInfosData.S_UserAccess        = attrProtection;
					attrInfosData.B_MultiValuated     = attrMultiVal;
					attrInfosData.L_Range             = rangeValues;
					attrInfosData.S_SIXW		      = attr6w;
					attrInfosData.B_Indexation	      = attributeIndexation;
					if(attribute3DXML)
						attrInfosData.B_3DXMLExposed	  = attribute3DXML;
					if(attributeExportable)
						attrInfosData.B_V6Exportable	  = attributeExportable;
					if(attributeResetOnFork)
						attrInfosData.B_ResetOnFork = attributeResetOnFork;
					if(attributeMultiline)
						attrInfosData.B_Multiline = attributeMultiline;

					IDAuAttrInfos attrInfos = type.createAttrInfos(context, attrInfosData);
					//IDAuAttrInfos attrInfos = type.createAttrInfos(context, attrType, attrUnit, attrLength, attrDefaultValue, attrResetCloning, attrResetNew, attrProtection);
					if (null != attrInfos)
					{
						IDAuAttribute attribute = type.addAttribute(context, attrName, attrInfos);
						if (null != attribute)
						{
							%>
							<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
							<script language="javascript">
								function redirection(iFrame, iURL)
								{
									iFrame.document.location = iURL;
								}
								
								var contentFrame = openerFindFrame(top, "content");
								if (null != contentFrame)
								{
									
									//setTimeout('redirection(contentFrame, url)', 10);
									//var link = "javascript:link(\"1\",\"18720.4974.1920.40626\",\"\",\"18720.4974.51584.26442\",\"GMXDoc1\")";
									//setTimeout('eval(link)', 10000);
									//alert("Test");
								}
							</script>
							<%
						}
					}
				}
				else if(null != extension)
				{
				
					selectedFrame="extension";
					DAuAttrInfosData attrInfosData = new DAuAttrInfosData();
					attrInfosData.S_Type              = attrType;
					attrInfosData.S_PreferredUnit     = attrUnit;
					attrInfosData.S_Length            = attrLength;
					attrInfosData.S_DefaultValue      = attrDefaultValue;
					attrInfosData.B_ResetOnCloning    = attrResetCloning;
					attrInfosData.B_ResetOnNewVersion = attrResetNew;
					attrInfosData.S_UserAccess        = attrProtection;
					attrInfosData.B_MultiValuated     = attrMultiVal;
					attrInfosData.L_Range             = rangeValues;
					attrInfosData.S_SIXW		      = attr6w;
					attrInfosData.B_Indexation	      = attributeIndexation;
					if(attribute3DXML)
						attrInfosData.B_3DXMLExposed	  = attribute3DXML;
					if(attributeExportable)
						attrInfosData.B_V6Exportable	  = attributeExportable;
					if(attributeResetOnFork)
						attrInfosData.B_ResetOnFork = attributeResetOnFork;
					if(attributeMultiline)
						attrInfosData.B_Multiline = attributeMultiline;
					//IDAuAttrInfos attrInfos = extension.createAttrInfos(context, attrType, attrUnit, attrLength, attrDefaultValue, attrResetCloning, attrResetNew, attrProtection);
					IDAuAttrInfos attrInfos = extension.createAttrInfos(context,attrInfosData);

					if (null != attrInfos)
					{
						IDAuAttribute attribute = extension.addAttribute(context, attrName, attrInfos);
						if (null != attribute)
						{
							%>
							<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
							<%
						}
					}
					
				} else{
					// instance
					selectedFrame="type";
					DAuAttrInfosData attrInfosData = new DAuAttrInfosData();
					attrInfosData.S_Type              = attrType;
					attrInfosData.S_PreferredUnit     = attrUnit;
					attrInfosData.S_Length            = attrLength;
					attrInfosData.S_DefaultValue      = attrDefaultValue;
					attrInfosData.B_ResetOnCloning    = attrResetCloning;
					attrInfosData.B_ResetOnNewVersion = attrResetNew;
					attrInfosData.S_UserAccess        = attrProtection;
					attrInfosData.B_MultiValuated     = attrMultiVal;
					attrInfosData.L_Range             = rangeValues;
					attrInfosData.S_SIXW		      = attr6w;
					attrInfosData.B_Indexation	      = attributeIndexation;
					if(attribute3DXML)
						attrInfosData.B_3DXMLExposed	  = attribute3DXML;
					if(attributeExportable)
						attrInfosData.B_V6Exportable	  = attributeExportable;
					if(attributeResetOnFork)
						attrInfosData.B_ResetOnFork = attributeResetOnFork;
					if(attributeMultiline)
						attrInfosData.B_Multiline = attributeMultiline;
					//IDAuAttrInfos attrInfos = instance.createAttrInfos(context, attrType, attrUnit, attrLength, attrDefaultValue, attrResetCloning, attrResetNew, attrProtection);
					IDAuAttrInfos attrInfos = instance.createAttrInfos(context,attrInfosData);

					if (null != attrInfos)
					{
						IDAuAttribute attribute = instance.addAttribute(context, attrName, attrInfos);
						if (null != attribute)
						{
							%>
							<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
							<%
						}
					}
				
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
/*
if(sbChannelAttr && typeof sbChannelAttr.emxEditableTable != 'undefined' && sbChannelAttr.emxEditableTable.refreshStructureWithOutSort){
	alert("0");
   sbChannelAttr.emxEditableTable.refreshStructureWithOutSort();
   alert("1");
   sbChannelAttr.refreshRows();
   //sbChannelAttr.expandAll(); 
   
}*/
</script> 
