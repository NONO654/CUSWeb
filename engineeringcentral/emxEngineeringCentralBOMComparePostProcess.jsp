<%--  emxEngineeringCentralBOMComparePostProcess.jsp   -    Post Process JSP for structure compare webform, directs based on user selection to tabular report or visual report jsp.
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file = "../emxTagLibInclude.inc"%>
<%@ page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@ page import="com.matrixone.apps.engineering.EngineeringConstants"%>
<%@ page import="com.matrixone.apps.domain.*" %>

<%@ page import="java.lang.reflect.*" %>
<%@ page import="com.matrixone.apps.domain.util.*,com.matrixone.apps.framework.ui.*"%>

<jsp:useBean id="SCTableBean" class="com.matrixone.apps.framework.ui.UITableIndented" scope="session"/>
<jsp:useBean id="structureCompareBean" class="com.matrixone.apps.framework.ui.UIStructureCompare" scope="session"/>

<%
	String language = request.getHeader("Accept-Language");

//Multitenant
/* String sEBOMLabel = UINavigatorUtil.getI18nString("emxEngineeringCentral.Part.EBOM","emxEngineeringCentralStringResource", language);
String sMBOMLabel = UINavigatorUtil.getI18nString("emxMBOM.ComparisionReport.MBOM","emxMBOMStringResource", language);
String sROLabel = UINavigatorUtil.getI18nString("emxComponents.Common.Rev","emxEngineeringCentralStringResource", language);
String sReportFormatLabel = UINavigatorUtil.getI18nString("emxEngineeringCentral.ECBOMCompare.ReportFormat","emxEngineeringCentralStringResource", language); */
String sEBOMLabel = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.EBOM");
String sMBOMLabel = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.ComparisionReport.MBOM");
String sROLabel = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxComponents.Common.Rev");
String sReportFormatLabel = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.ECBOMCompare.ReportFormat");
	String sRevOptLabel1 = "";
	String sRevOptLabel2 = "";
	String sEftyExprLabel1 = "";
	String sEftyExprLabel2 = "";
	String sPlantLabel1 = "";
	String sPlantLabel2 = "";
	String sMFGAsOnLabel1 = "";
	String sMFGAsOnLabel2 = "";
	String sDeviation1 = "";
	String sDeviation2 = "";
	String sMatBasedOn = "";
	String sReportDeffBy = "";
	String sReportFormat = "";
	String sPlantName1 = "";
	String sPlantName2 = "";
	boolean eccReport = false;
	boolean mfgReport = false;

	Map mfgCriteria = new com.matrixone.jsystem.util.MxLinkedHashMap();
	Map eccCriteria = new com.matrixone.jsystem.util.MxLinkedHashMap();
	
	Map exportSubHeader = new com.matrixone.jsystem.util.MxLinkedHashMap();
	
	String languageStr = request.getHeader("Accept-Language");
	String sTimeStamp 		= emxGetParameter(request, "SCTimeStamp");
	
	try {
		SCTableBean = (com.matrixone.apps.framework.ui.UIStructureCompare)structureCompareBean;
		HashMap sessionValueMap = (HashMap)((com.matrixone.apps.framework.ui.UIStructureCompare)SCTableBean).getSCCriteria(sTimeStamp);
		sessionValueMap.put("CriteriaHeader", exportSubHeader);
		((com.matrixone.apps.framework.ui.UIStructureCompare)SCTableBean).setStructureCompareCriteria(sTimeStamp, sessionValueMap);
	} catch (Exception e) {
		e.printStackTrace();
	}
	
	
	String sType1 			= emxGetParameter(request, "Type1");
	String sName1			= emxGetParameter(request, "BOM1NameDispOID");
	String sRevision1		= emxGetParameter(request, "BOM1Rev");
    String sRevisionOption1 = emxGetParameter(request, "RevisionOption1");
    String sRevisionOption2 = emxGetParameter(request,"RevisionOption2");
    String str3dPlayEnabled =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.Toggle.3DViewer");
    
    String sModRevOpt = sRevisionOption1.replaceAll("_", "");
    sModRevOpt = sModRevOpt.replaceAll(" ", "");
    
    if(sModRevOpt.equals("AsStored") || sModRevOpt.equals("Latest")) {    	
    	//Multitenant
    	//sRevOptLabel1 = UINavigatorUtil.getI18nString("emxEngineeringCentral.BOMCompareForm.RevisionOptions."+sModRevOpt,"emxEngineeringCentralStringResource", language);
    	sRevOptLabel1 = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BOMCompareForm.RevisionOptions."+sModRevOpt);
    } else if(sRevisionOption1.equals("Pending") || sRevisionOption1.equals("Current") || sRevisionOption1.equals("History")) {
    	//Multitenant
    	//sRevOptLabel1 = UINavigatorUtil.getI18nString("emxMBOM.RevisionOptions."+sModRevOpt,"emxMBOMStringResource", language);
    	sRevOptLabel1 = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.RevisionOptions."+sModRevOpt);
    }
    
    sModRevOpt = sRevisionOption2.replaceAll("_", "");
    sModRevOpt = sModRevOpt.replaceAll(" ", "");
    
    if(sModRevOpt.equals("AsStored") || sModRevOpt.equals("Latest")) {    	
    	//Multitenant
    	//sRevOptLabel2 = UINavigatorUtil.getI18nString("emxEngineeringCentral.BOMCompareForm.RevisionOptions."+sModRevOpt,"emxEngineeringCentralStringResource", language);
    	sRevOptLabel2 = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BOMCompareForm.RevisionOptions."+sModRevOpt);
    } else if(sRevisionOption2.equals("Pending") || sRevisionOption2.equals("Current") || sRevisionOption2.equals("History")) {
    	//Multitenant
    	//sRevOptLabel2 = UINavigatorUtil.getI18nString("emxMBOM.RevisionOptions."+sModRevOpt,"emxMBOMStringResource", language);
    	sRevOptLabel2 = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.RevisionOptions."+sModRevOpt);
    }
    
    String sObjectId1 		= emxGetParameter(request, "BOM1Name");
    
    
    //R212 TypeAhead changes
    if(sObjectId1==null||sObjectId1.equals(""))
    	sObjectId1 = emxGetParameter(request,"BOM1NameOID");
    boolean isPartFromVPLMSyncobj1 = new com.matrixone.apps.engineering.Part(sObjectId1).isPartFromVPLMSync(context);

   /* Added for ECC Report functionality ...sn*/

    boolean isECCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionEngineeringConfigurationCentral",false,null,null);    

    String sTargetPageEffURL = "";
    
	String sEffectivityExpressionActual1 = "";
	String sEffectivityExpressionActual2 = "";
	String pcFilterActual1 = "";
	String pcFilterActual2 = "";
	if (isECCInstalled ) 
	{
		try
		{
			sEffectivityExpressionActual1 = emxGetParameter(request, "EffectivityExpressionActual");
			sEffectivityExpressionActual2 = emxGetParameter(request, "EffectivityExpressionActual1");
			pcFilterActual1 = emxGetParameter(request, "PCFilterId1");
			pcFilterActual2 = emxGetParameter(request, "PCFilterId2");
			sEftyExprLabel1 =   emxGetParameter(request,"EffectivityExpression");
			sEftyExprLabel2 =   emxGetParameter(request,"EffectivityExpression1");
			
			if((UIUtil.isNotNullAndNotEmpty(sEftyExprLabel1) && UIUtil.isNotNullAndNotEmpty(pcFilterActual1)) || (UIUtil.isNotNullAndNotEmpty(sEftyExprLabel2) && UIUtil.isNotNullAndNotEmpty(pcFilterActual2))){
				%>
				<script>alert("<%=EnoviaResourceBundle.getProperty(context ,"emxUnresolvedEBOMStringResource",context.getLocale(),"emxUnresolvedEBOM.Alert.MultipleFilterSelected")%>");</script>
				
				<%
				
			}
			/*String sEffectivityExpression1=   emxGetParameter(request,"EffectivityExpression");
			String sEffectivityExpression2=   emxGetParameter(request,"EffectivityExpression1");
			String EffectivityExpressionOID1=   emxGetParameter(request,"EffectivityExpressionOID");
			String EffectivityExpressionOID2=   emxGetParameter(request,"EffectivityExpressionOID1");
			String EffectivityExpressionOIDList1=   emxGetParameter(request,"EffectivityExpressionOIDList");
			String EffectivityExpressionOIDList2=   emxGetParameter(request,"EffectivityExpressionOIDList1");
			String strEffExprOIDListAc1= emxGetParameter(request,"EffectivityExpressionOIDListAc");
			String strEffExprOIDListAc2= emxGetParameter(request,"EffectivityExpressionOIDListAc1");

			sEftyExprLabel1 = sEffectivityExpression1;
			sEftyExprLabel2 = sEffectivityExpression2;
		    
		    Map cBinary1 =null;
		    Map cBinary2= null;
		    
			Class cl = Class.forName("com.matrixone.apps.effectivity.EffectivityFramework");
			Object EFF1 =cl.newInstance();
	
			// parameters depending on the bean method
			Class[] inputType = new Class[3];
			inputType[0] = Context.class;
			inputType[1] = String.class;
			inputType[2] = String.class;
	
		    Method method = cl.getMethod("getFilterCompiledBinary", inputType);
		
    		if ( null != sEffectivityExpression1 && sEffectivityExpression1.length() > 0 ) 
    		{
    			
    			Field fd1 = cl.getDeclaredField("QUERY_MODE_150");
    			String queryMode = fd1.toString();
    	    	 Object[] actualParams = {context, sEffectivityExpressionActual1, queryMode};

    	 		//Object[] actualParams = {context,strEffExprOIDListAc1};
		 		cBinary1 = (Map)method.invoke(EFF1, actualParams);
	     		//com_bin1 = (String)cBinary1.get(com.matrixone.apps.effectivity.EffectivityFramework.COMPILED_BINARY_EXPR);
	     
			     Field fd = cl.getDeclaredField("COMPILED_BINARY_EXPR");
			     
		         com_bin1 =(String)cBinary1.get(fd.get(EFF1));
		    }

    		if (null != sEffectivityExpression2 && sEffectivityExpression2.length() > 0 ) 
    		{
    			
    			Field fd1 = cl.getDeclaredField("QUERY_MODE_150");
			String queryMode = fd1.toString();

    			//Object[] actualParams = {context,strEffExprOIDListAc2};
	   	    	 Object[] actualParams = {context, sEffectivityExpressionActual2, queryMode};

    			cBinary2 = (Map)method.invoke(EFF1, actualParams);
    			//com_bin2 = (String)cBinary2.get(com.matrixone.apps.effectivity.EffectivityFramework.COMPILED_BINARY_EXPR);
        		Field fd = cl.getDeclaredField("COMPILED_BINARY_EXPR");
        		com_bin2 =(String)cBinary2.get(fd.get(EFF1));
    		}*/
    	} 
		catch (Exception e ) 
    	{
		   System.out.println("Excpetion in the Effectivity invoke expressions : "+e.getMessage());
		}
	}

	
	/* Added for ECC Report functionality ...en*/

    /////////////////Added for MBOM starts
    String strPlant1 = "";
    String sMBOM1PlantId = "";
    String strAsOn1 = "";
    String strDeviation1 = "";	
    String IsStructureCompare = "";	
    String strPlant2 		= "";
    String sMBOM2PlantId 	= "";
    String strAsOn2 		= "";
    String strDeviation2 	= "";
    String sObjSelect 		= "";
    String sMake_Buy		= null;
    String sS_Type 		= null;
    String strEBOM 		= "";
    String strMBOM = "";
    String sMBOM1PlantId1 = "";
    String sMBOM2PlantId2 = "";
	com.matrixone.apps.engineering.IPartMaster pmObj = null;
    
	if(com.matrixone.apps.engineering.EngineeringUtil.isMBOMInstalled(context))
	{
        strPlant1 		= emxGetParameter(request,"Plant1"); 
        sMBOM1PlantId1 	= emxGetParameter(request,"Plant1OID"); 
        if(sMBOM1PlantId1!=null && !sMBOM1PlantId1.equals("") && !sMBOM1PlantId1.equals("null"))
        {
        	DomainObject dObj = new DomainObject(sMBOM1PlantId1);
        	sMBOM1PlantId = dObj.getAttributeValue(context, EngineeringConstants.ATTRIBUTE_PLANT_ID);
        	
        	sPlantName1 = dObj.getInfo(context, EngineeringConstants.SELECT_NAME);
        }
        
        strAsOn1 		= emxGetParameter(request,"AsOn1_msvalue");
        
        strDeviation1 	= emxGetParameter(request,"Deviation1");
        IsStructureCompare 	= emxGetParameter(request,"IsStructureCompare");
        strPlant2 		= emxGetParameter(request,"Plant2");
        sMBOM2PlantId2 	= emxGetParameter(request,"Plant2OID");
        if(sMBOM2PlantId2!=null && !sMBOM2PlantId2.equals("") && !sMBOM2PlantId2.equals("null"))
        {
	        DomainObject dObj1 = new DomainObject(sMBOM2PlantId2);
	        sMBOM2PlantId = dObj1.getAttributeValue(context, EngineeringConstants.ATTRIBUTE_PLANT_ID);
	        sPlantName2 = dObj1.getInfo(context, EngineeringConstants.SELECT_NAME);
        }
        
        strAsOn2 		= emxGetParameter(request,"AsOn2_msvalue");
        strDeviation2 	= emxGetParameter(request,"Deviation2");
        sObjSelect 		= "to["+EngineeringConstants.RELATIONSHIP_PART_REVISION+"].from.id";
        sMake_Buy		= emxGetParameter(request,"Make_Buy");
        sS_Type 		= emxGetParameter(request,"S_Type");
	    //Multitenant
        //strMBOM 		= i18nNow.getI18nString("emxMBOM.ComparisionReport.MBOM","emxMBOMStringResource","en");
        strMBOM 		= EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", new Locale("en"),"emxMBOM.ComparisionReport.MBOM");
		java.lang.Class clazz = java.lang.Class.forName("com.matrixone.apps.mbom.PartMaster");
		pmObj =(com.matrixone.apps.engineering.IPartMaster) clazz.newInstance();
    }
        
	//Multitenant
	//strEBOM 		= i18nNow.getI18nString("emxEngineeringCentral.Part.EBOM","emxEngineeringCentralStringResource","en");
	strEBOM 		=EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", new Locale("en"),"emxEngineeringCentral.Part.EBOM");
	/////////////////Added for MBOM ends
    String sType2 		= emxGetParameter(request,"Type2");
    
    String sSCTimeStamp 		= emxGetParameter(request,"SCTimeStamp");
	String sName2		= emxGetParameter(request,"BOM2NameDispOID");
	String sObjectId2 	= emxGetParameter(request,"BOM2Name");
     
    
    //R212 TypeAhead changes
    if(sObjectId2==null||sObjectId2.length()==0)
    	sObjectId2 = emxGetParameter(request,"BOM2NameOID");
    boolean isPartFromVPLMSyncobj2 = new com.matrixone.apps.engineering.Part(sObjectId2).isPartFromVPLMSync(context);
   
    //end R212 changes
	String sRevision2			= emxGetParameter(request,"BOM2Rev");
    ////////////////////Added for MBOM starts
    
    //////////////////Added for MBOM ends
      String sExpandLevel = emxGetParameter(request,"ExpandLevel");
    String sFormat = emxGetParameter(request,"Format");
    String sParent				= emxGetParameter(request,"parent");
    String strIsConsolidated= emxGetParameter(request,"isConsolidatedReport");
    String sMatchBasedOnLabel = emxGetParameter(request,"MatchBasedOn");
  //Multitenant
    //String sMatchBasedOn = UINavigatorUtil.getI18nString(sMatchBasedOnLabel,"emxEngineeringCentralStringResource", "en");
    String sMatchBasedOn =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", new Locale("en"),sMatchBasedOnLabel); 
  
    String sVal= sMatchBasedOn.replace(' ','_');
    sVal=StringUtils.replace(sVal,"_+_","_");
    sMatchBasedOn = sVal;

    // Report Output - Section values
	
	if(strIsConsolidated.equals("Yes")) {
		//Multitenant
		//sReportFormat = UINavigatorUtil.getI18nString("emxEngineeringCentral.Part.BOMConsolidatedReport","emxEngineeringCentralStringResource", language);
		sReportFormat = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.BOMConsolidatedReport");
	} else {
		//Multitenant
		//sReportFormat = UINavigatorUtil.getI18nString("emxEngineeringCentral.CompareBOM.StructuredReport","emxEngineeringCentralStringResource", language);
		sReportFormat = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.CompareBOM.StructuredReport");
	}

	// Added for Part Master
	//180113V6R2013x
    //String sPMObjectId1 = "";
   // String sPMObjectId2 = "";
    //String sObjSelect = "to["+MBOMConstants.RELATIONSHIP_PART_REVISION+"].from.id";
	  
    // Report Differences By values
    String sPart = emxGetParameter(request,"Part_Name");
    
    String sRev = emxGetParameter(request,"Revision");
    
    String sType = emxGetParameter(request,"Type");//Added to fix IR-037412V6R2011x
    
    String sFind_Number = emxGetParameter(request,"Find_Number");
    
    String sReference_Designator= emxGetParameter(request,"Reference_Designator");
    
    String sQuantity = emxGetParameter(request,"Qty");
    String sUsage  = emxGetParameter(request,"Usage");
    
    String sComponent_Location  = emxGetParameter(request,"Component_Location");
    
    String sUOM = emxGetParameter(request,"UOM");
    
    String sSubstitute_Part = emxGetParameter(request,"Substitute_For");
    
	/////////////////////////////////Added for MBOM starts
   
	/////////////////////////////////Added for MBOM ends  
    String sTargetPageURL    = null;
	//Multitenant
    //String pageHeading  = i18nNow.getI18nString("emxEngineeringCentral.Common.Details", "emxEngineeringCentralStringResource", languageStr);
    String pageHeading  = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Details"); 

    // Assign the values if null
	String strClassCode = "false";
    if (sObjectId1 == null || sObjectId1.length() <= 0 || sObjectId1.equals("null"))	{
		sObjectId1 = emxGetParameter(request,"objectId");
	}
	if (sName1 == null || sName1.length() <= 0 || sName1.equals("null"))	{
		sName1 = emxGetParameter(request,"BOM1Name");
	}
	if (sName2 == null || sName2.length() <= 0 || sName2.equals("null"))	{
		sName2 = emxGetParameter(request,"BOM2Name");
	}
	String objectId = sObjectId1+","+sObjectId2;
	String sReportType = emxGetParameter(request, "reportType");
	
	String sColumnName1 = "Find Number";
	String sColumnName2 = "None";
	String sColumnName3 = "None";
		
	if ("Find_Number".equals(sMatchBasedOn))
	{
		sColumnName1 = "Find Number";
		sColumnName2 = "None";
	}
	else if ("Reference_Designator".equals(sMatchBasedOn))
	{
		sColumnName1 = "Reference Designator";
		sColumnName2 = "None";
	}
	else if ("Part_Name_Reference_Designator".equals(sMatchBasedOn))
	{
		sColumnName1 = "Name";
		sColumnName2 = "Reference Designator";
	}
	else if ("Part_Name".equals(sMatchBasedOn))
	{
		sColumnName1 = "Name";
		sColumnName2 = "None";
	}
	else if ("Part_Name_Reference_Designator_Class_Code".equals(sMatchBasedOn))
	{
		sColumnName1 = "Class Code";
		sColumnName2 = "Name";
		sColumnName3 = "Reference Designator";
		strClassCode = "true";
	}
	String strMatchBasedOn = sColumnName1;

	if (!"None".equals(sColumnName2))
	{
		strMatchBasedOn = strMatchBasedOn + "," + sColumnName2;
	}
	if (!"None".equals(sColumnName3))
	{
		strMatchBasedOn = strMatchBasedOn + "," + sColumnName3;
	}
	String sCheckBox = "";
	String sRepDffBylabel = "";	
	if (sPart != null)
	{
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.Common.PartName","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.PartName");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Name,";
	}
	if (sRev != null)
	{
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.Common.Revision","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Revision");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Revision,";
	}
	if (sType != null)
    {
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.Common.Type","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Type");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
    	sCheckBox = sCheckBox + "Type,";
    }
	
	if (sFind_Number != null)
	{
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.BuildEBOM.FindNumber","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BuildEBOM.FindNumber");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Find Number,";
	}
	if (sReference_Designator != null)
	{
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.Markup.ReferenceDesignator","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.ReferenceDesignator");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Reference Designator,";
	}
	if (sQuantity != null)
	{
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.Common.Qty","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.Qty");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Quantity,";
	}
	if (sUsage != null)
	{
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.Part.Usage","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.Usage");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Usage,";
	}
	if (sComponent_Location != null)
	{
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.Markup.ComponentLocation","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.ComponentLocation");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Component Location,";
	}
	if (sUOM != null)
	{  // IR 64797
	  //sCheckBox = sCheckBox + "Unit of Measure,";
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.Part.UnitOfMeasure","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Part.UnitOfMeasure");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "UOM,";
	}
	if (sSubstitute_Part != null)
	{
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.Common.SubstituteFor","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Common.SubstituteFor");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Substitute For,";
	}
    // Start :Added for MBOM	
    if (sMake_Buy != null)
	{
    	//Multitenant
    	//String sLangValue = UINavigatorUtil.getI18nString("emxMBOM.MBOMCompare.MakeBuy","emxMBOMStringResource", language);
    	String sLangValue = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.MBOMCompare.MakeBuy");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "MakeBuy,";
	}
	if (sS_Type != null)
	{
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxMBOM.label.SType","emxMBOMStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.label.SType");
		sRepDffBylabel = sRepDffBylabel+sLangValue+"|";
		sCheckBox = sCheckBox + "Stype,";
	}
	if(UIUtil.isNotNullAndNotEmpty(sRepDffBylabel)) {
	sRepDffBylabel = sRepDffBylabel.substring(0, sRepDffBylabel.length()-1);
	}
    //End : Added for MBOM
	if ("".equals(sCheckBox))
	{
		//Multitenant
		//String sLangValue = UINavigatorUtil.getI18nString("emxEngineeringCentral.BuildEBOM.FindNumber","emxEngineeringCentralStringResource", language);
		String sLangValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BuildEBOM.FindNumber");
		sRepDffBylabel = sRepDffBylabel+sLangValue;
		sCheckBox = "Find Number,";
	}
	String scompareBy = sCheckBox.substring(0,sCheckBox.length() -1);
	
	String sRevOpt1 = "As Stored";
		
	if ("Latest".equals(sRevisionOption1))
	{
		sRevOpt1 = "Latest";
	}
	else
	{
		sRevOpt1 = "As Stored";

	}
	String sRevOpt2 = "As Stored";
	if ("Latest".equals(sRevisionOption2))
	{
		sRevOpt2 = "Latest";
	}
	else
	{
		sRevOpt2 = "As Stored";
    }
	
	String reportFrame = ("Difference_Only_Report".equals(sReportType)) ? "AEFSCDifferenceOnlyReport" : ("Common_Report".equals(sReportType)) ? "AEFSCCompareCommonComponents" : ("Unique_toLeft_Report".equals(sReportType)) ? "AEFSCBOM1UniqueComponentsReport" : ("Unique_toRight_Report".equals(sReportType)) ? "AEFSCBOM2UniqueComponentsReport" : "AEFSCCompleteSummaryResults";
	
	
	DomainObject doObj1 = new DomainObject(sObjectId1);
	DomainObject doObj2 = new DomainObject(sObjectId2);
	String sObj1Name = doObj1.getInfo(context, DomainConstants.SELECT_NAME);
	String sObj2Name = doObj2.getInfo(context, DomainConstants.SELECT_NAME);
	%>
	
	
<body>
	<form name="BOMComparePL" method="post" id="BOMComparePL">
				  
	  <input type="hidden" name="table" value="ENCBOMCompareVisualTable" />
	  <input type="hidden" name="toolbar" value="AEFStructureCompareToolbar" />				  
	  <input type="hidden" name="compareLevel" value="<xss:encodeForHTMLAttribute><%=sExpandLevel%></xss:encodeForHTMLAttribute>" />
		<input type="hidden" name="connectionProgram" value="emxPart:validateStateForApplyForBOMCompare" />
  
	  <input type="hidden" name="compareBy" value="<xss:encodeForHTMLAttribute><%=scompareBy%></xss:encodeForHTMLAttribute>" />
	  <input type="hidden" name="matchBasedOn" value="<xss:encodeForHTMLAttribute><%=strMatchBasedOn%></xss:encodeForHTMLAttribute>" />
	  
	  <input type="hidden" name="SCTimeStamp" value="<xss:encodeForHTMLAttribute><%=sSCTimeStamp%></xss:encodeForHTMLAttribute>" />
	  <input type="hidden" name="IsStructureCompare" value="TRUE" />
      <input type="hidden" name="portalMode" value="true" />
      <input type="hidden" name="hideHeader" value="true" />
      <input type="hidden" name="autoFilter" value="false" /> 
      <input type="hidden" name="rowGrouping" value="false" />
      <input type="hidden" name="emxExpandFilter" value="<xss:encodeForHTMLAttribute><%=sExpandLevel%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="strExpandLevel" value="<xss:encodeForHTMLAttribute><%=sExpandLevel%></xss:encodeForHTMLAttribute>" />
      		          
      <input type="hidden" name="compare" value="compareBy" />
      <input type="hidden" name="selTypeDisp1" value="<xss:encodeForHTMLAttribute><%=sName1%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="selTypeDisp" value="<xss:encodeForHTMLAttribute><%=sName2%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="matchColumns" value="[Name, Revision, Type, Find Number, Reference Designator, Component Location, Description, State, Quantity, UOM, Usage]" />
      <input type="hidden" name="objectCompare" value="false" />           
      <input type="hidden" name="CompareBy" value="Revision" />
      <input type="hidden" name="objectIds" value="<xss:encodeForHTMLAttribute><%=sObjectId1%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="parentOID" value="<xss:encodeForHTMLAttribute><%=sObjectId1%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="ParentobjectId" value="<xss:encodeForHTMLAttribute><%=sObjectId1%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="cbox_Value" value="<xss:encodeForHTMLAttribute><%=sCheckBox%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="uiType" value="StructureBrowser" />
      <input type="hidden" name="firstColumn" value="<xss:encodeForHTMLAttribute><%=sColumnName1%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="suiteKey" value="EngineeringCentral" />
      <input type="hidden" name="HelpMarker" value="emxhelp_structurecomparereport" /> 
      <input type="hidden" name="showClipboard" value="false" /> 
      <input type="hidden" name="reportType" value="<xss:encodeForHTMLAttribute><%=sReportType%></xss:encodeForHTMLAttribute>" />		          
      <input type="hidden" name="secondColumn" value="<xss:encodeForHTMLAttribute><%=sColumnName2%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="reportType" value="<xss:encodeForHTMLAttribute><%=sReportType%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="customize" value="false" />
      
      <input type="hidden" name="LeftRevOption" value="<xss:encodeForHTMLAttribute><%=sRevOpt1%></xss:encodeForHTMLAttribute>" /> 
      <input type="hidden" name="RightRevOption" value="<xss:encodeForHTMLAttribute><%=sRevOpt2%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="LeftstrRevisionOption" value="<xss:encodeForHTMLAttribute><%=sRevisionOption1%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="RightstrRevisionOption" value="<xss:encodeForHTMLAttribute><%=sRevisionOption2%></xss:encodeForHTMLAttribute>" />

      <input type="hidden" name="thirdColumn" value="<xss:encodeForHTMLAttribute><%=sColumnName3%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="ClassCode" value="<xss:encodeForHTMLAttribute><%=strClassCode%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="isConsolidatedReport" value="<xss:encodeForHTMLAttribute><%=strIsConsolidated%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="expandLevel" value="<xss:encodeForHTMLAttribute><%=sExpandLevel%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="relation" value="EBOM" />
      
      <input type="hidden" name="languageStr" value="en-us" />
      <input type="hidden" name="charSet" value="UTF8" />
      <input type="hidden" name="SuiteDirectory" value="common" />
      <input type="hidden" name="StringResourceFileId" value="emxEngineeringCentralStringResource" />
     <% 
     if("true".equalsIgnoreCase(str3dPlayEnabled) && isPartFromVPLMSyncobj1 && isPartFromVPLMSyncobj2 ){
    	%>
    	 <input type="hidden" name="selectHandler" value="highlightCompareItem3dPlay"/>
    	<%  
     } else if("false".equalsIgnoreCase(str3dPlayEnabled)){
    	 %>
     	 <input type="hidden" name="selectHandler" value="highlightCompareItem"/>
     	 <% 
  	}
     	 %>
 
      <input type="hidden" name="LeftstrType" value="<xss:encodeForHTMLAttribute><%=sType1%></xss:encodeForHTMLAttribute>" />
      <input type="hidden" name="RightstrType" value="<xss:encodeForHTMLAttribute><%=sType2%></xss:encodeForHTMLAttribute>" />
	  <%
	  	
	    if(sType1.equals(strEBOM) && sType2.equals(strEBOM))
	    {
	    	exportSubHeader.put(sEBOMLabel+" 1", sObj1Name);
	    	exportSubHeader.put(sEBOMLabel+" 2", sObj2Name);
	    	
			    %>
			    	  <input type="hidden" name="toolbar" value="AEFStructureCompareToolbar" />
			          <input type="hidden" name="strObjectId1" value="<xss:encodeForHTMLAttribute><%=sObjectId1%></xss:encodeForHTMLAttribute>" />
			          <input type="hidden" name="strObjectId2" value="<xss:encodeForHTMLAttribute><%=sObjectId2%></xss:encodeForHTMLAttribute>" />
			          <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=sObjectId1%></xss:encodeForHTMLAttribute>,<xss:encodeForHTMLAttribute><%=sObjectId2%></xss:encodeForHTMLAttribute>" />
	          <%
	    	
			if (UIUtil.isNotNullAndNotEmpty(sEffectivityExpressionActual1) || UIUtil.isNotNullAndNotEmpty(sEffectivityExpressionActual2)|| UIUtil.isNotNullAndNotEmpty(pcFilterActual1) || UIUtil.isNotNullAndNotEmpty(pcFilterActual2))
			{	
				eccReport = true;
				//Multitenant
				//String sEffectivityLabel = UINavigatorUtil.getI18nString("emxUnresolvedEBOM.Common.Effectivity","emxUnresolvedEBOMStringResource", language);
				String sEffectivityLabel = EnoviaResourceBundle.getProperty(context, "emxUnresolvedEBOMStringResource", context.getLocale(),"emxUnresolvedEBOM.Common.Effectivity");
				eccCriteria.put(sEffectivityLabel+" 1", sEftyExprLabel1); 
				eccCriteria.put(sEffectivityLabel+" 2", sEftyExprLabel2);
			    %>
			          <input type="hidden" name="expandProgram" value="emxPart:getStoredEffectivityEBOM" />
					  <input type="hidden" name="BOMCompare" value="true" />
					  <input type="hidden" name="sEffectivityExpressionActual1" value="<xss:encodeForHTMLAttribute><%=sEffectivityExpressionActual1%></xss:encodeForHTMLAttribute>" />
					  <input type="hidden" name="sEffectivityExpressionActual2" value="<xss:encodeForHTMLAttribute><%=sEffectivityExpressionActual2%></xss:encodeForHTMLAttribute>" />
					  <input type="hidden" name="pcObjectId1" value="<xss:encodeForHTMLAttribute><%=pcFilterActual1%></xss:encodeForHTMLAttribute>" />
					  <input type="hidden" name="pcObjectId2" value="<xss:encodeForHTMLAttribute><%=pcFilterActual2%></xss:encodeForHTMLAttribute>" />
				<%				
			} else {	
				%>
					  <input type="hidden" name="expandProgram" value="emxPart:getStoredEBOM" />
				<%
			}
		
		} else {
			mfgReport = true;
			//Multitenant
			//String sDeviationLabel = UINavigatorUtil.getI18nString("emxMBOM.label.Deviation","emxMBOMStringResource", language);
			String sDeviationLabel =EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.label.Deviation");
			
			//Multitenant
			//String sAsOnLabel = UINavigatorUtil.getI18nString("emxMBOM.ComparisionReport.AsOn","emxMBOMStringResource", language);
			String sAsOnLabel = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.ComparisionReport.AsOn");
			//Multitenant
			//String sPlantLabel = UINavigatorUtil.getI18nString("emxMBOM.MBOM.PlantName","emxMBOMStringResource", language);
				String sPlantLabel = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.MBOM.PlantName");
			
			//Multitenant
			//String sTrue = UINavigatorUtil.getI18nString("emxMBOM.Deviation.FilterOptions.True","emxMBOMStringResource", language);
			String sTrue = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Deviation.FilterOptions.True");
			//Multitenant
			//String sFalse = UINavigatorUtil.getI18nString("emxMBOM.Deviation.FilterOptions.False","emxMBOMStringResource", language);
			String sFalse = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Deviation.FilterOptions.False");
			
			String strAsOnLabel1 = "";
			String strAsOnLabel2 = "";
			
			String sDeviationLabel1 = "";
			String sDeviationLabel2 = "";
			
			String sPlantNameLabel1 = "";
			String sPlantNameLabel2 = "";
			
			if(sType1.equals(strMBOM)) {
				exportSubHeader.put(sMBOMLabel+" 1", sObj1Name);
				//sObjectId1 = (String)pmObj.getPartMaster(context,sObjectId1);    //180113V6R2013x		
				
				strAsOnLabel1 		= emxGetParameter(request,"AsOn1");
				if(strDeviation1.equalsIgnoreCase("true")) {
					sDeviationLabel1 = sTrue;
				}
				sPlantNameLabel1 = sPlantName1;
	    	} else {
	    		
	    		exportSubHeader.put(sEBOMLabel+" 1", sObj1Name);
	    	}
	    		
	    		
	    	if (sType2.equals(strMBOM)) {    		
	    		exportSubHeader.put(sMBOMLabel+" 2", sObj2Name);
	    		//sPMObjectId2 = (String)pmObj.getPartMaster(context,sObjectId2);//180113V6R2013x
	    		// sObjectId2 = (String)pmObj.getPartMaster(context,sObjectId2);//180113V6R2013x
	    		
	    		strAsOnLabel2 		= emxGetParameter(request,"AsOn2");
	    		if(strDeviation2.equalsIgnoreCase("true")) {
					sDeviationLabel2 = sTrue;
				}
	    		sPlantNameLabel1 = sPlantName2;
	    	} else {
	    		exportSubHeader.put(sEBOMLabel+" 2", sObj2Name);
	    	}
			
			objectId = sObjectId1+","+sObjectId2;
		     
			%>
			    <input type="hidden" name="expandProgram" value="emxPartMaster:getCompareBOMs" />
			    
			    <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=sObjectId1%></xss:encodeForHTMLAttribute>,<xss:encodeForHTMLAttribute><%=sObjectId2%></xss:encodeForHTMLAttribute>" />
			    
			    <input type="hidden" name="strObjectId1" value="<xss:encodeForHTMLAttribute><%=sObjectId1%></xss:encodeForHTMLAttribute>" />	
			    <input type="hidden" name="strObjectId2" value="<xss:encodeForHTMLAttribute><%=sObjectId2%></xss:encodeForHTMLAttribute>" />
			    
			    <input type="hidden" name="LeftstrDeviation" value="<xss:encodeForHTMLAttribute><%=strDeviation1%></xss:encodeForHTMLAttribute>" />
			    <input type="hidden" name="LeftstrAsOn" value="<xss:encodeForHTMLAttribute><%=strAsOn1%></xss:encodeForHTMLAttribute>" />
			    <input type="hidden" name="LeftstrPlantId" value="<xss:encodeForHTMLAttribute><%=sMBOM1PlantId%></xss:encodeForHTMLAttribute>" />
			    
			    <input type="hidden" name="RightstrDeviation" value="<xss:encodeForHTMLAttribute><%=strDeviation2%></xss:encodeForHTMLAttribute>" />
			    <input type="hidden" name="RightstrAsOn" value="<xss:encodeForHTMLAttribute><%=strAsOn2%></xss:encodeForHTMLAttribute>" />
			    <input type="hidden" name="RightstrPlantId" value="<xss:encodeForHTMLAttribute><%=sMBOM2PlantId%></xss:encodeForHTMLAttribute>" />
			    		    
			<%
			
			
			mfgCriteria.put("<BR/>"+sPlantLabel+" 1", sPlantNameLabel1);
			mfgCriteria.put(sPlantLabel+" 2", sPlantNameLabel2);
			
			mfgCriteria.put(sAsOnLabel+" 1", strAsOnLabel1);
			mfgCriteria.put(sAsOnLabel+" 2", strAsOnLabel2);
			
			mfgCriteria.put(sDeviationLabel+" 1", sDeviationLabel1);
			mfgCriteria.put(sDeviationLabel+" 2", sDeviationLabel2);
		}
	  exportSubHeader.put(sROLabel+" 1", sRevOptLabel1);
	  exportSubHeader.put(sROLabel+" 2", sRevOptLabel2);
	  if(eccReport) {
		  exportSubHeader.putAll(eccCriteria);
	  }
	  if(mfgReport) {
		  exportSubHeader.putAll(mfgCriteria);
		}
	  exportSubHeader.put(sReportFormatLabel, sReportFormat);
	  
	//Multitenant
		//String sMatchBasedOnLabel1 = UINavigatorUtil.getI18nString(sMatchBasedOnLabel,"emxEngineeringCentralStringResource", language);
		String sMatchBasedOnLabel1 =EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),sMatchBasedOnLabel); 
		//Multitenant
		//exportSubHeader.put(UINavigatorUtil.getI18nString("emxEngineeringCentral.label.MatchBasedOn","emxEngineeringCentralStringResource", language), sMatchBasedOnLabel1);
		exportSubHeader.put(EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.label.MatchBasedOn"), sMatchBasedOnLabel1);
		  if(UIUtil.isNotNullAndNotEmpty(sRepDffBylabel)) {
			//Multitenant
			//exportSubHeader.put(UINavigatorUtil.getI18nString("emxEngineeringCentral.label.ReportDifferencesBy","emxEngineeringCentralStringResource", language), sRepDffBylabel);
			  exportSubHeader.put(EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.label.ReportDifferencesBy"), sRepDffBylabel);
	  }
	 %>

	</form>
</body>  
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script>
	var resultTargetFrame = getTopWindow().findFrame(getTopWindow(),"<xss:encodeForJavaScript><%=reportFrame%></xss:encodeForJavaScript>");
	
	this.document.forms["BOMComparePL"].target = resultTargetFrame.name;
	this.document.forms["BOMComparePL"].method = "post";
    this.document.forms["BOMComparePL"].action = "../common/emxIndentedTable.jsp?IsStructureCompare=TRUE&displayView=details,thumbnail&hideLifecycleCommand=true&hideLaunchButton=true";
    this.document.forms["BOMComparePL"].submit();

</script>
