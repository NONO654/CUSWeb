<%--  emxEngrMarkupView.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@ page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeConstants" %>

<%

ContextUtil.pushContext(context);

String language  = request.getHeader("Accept-Language");

//Multitenant
/* String strMultipleParts = i18nNow.getI18nString("emxEngineeringCentral.Markup.SelectMarkupsUnderOneAffectedItem","emxEngineeringCentralStringResource", language);
String strMultipleMarkups = i18nNow.getI18nString("emxEngineeringCentral.Markup.SelectSameTypeOfMarkups","emxEngineeringCentralStringResource", language);
String strOneAppliedMarkup = i18nNow.getI18nString("emxEngineeringCentral.Markup.SelectOnlyOneAppliedMarkup","emxEngineeringCentralStringResource", language);
String strSamePlantBOMsMsg = i18nNow.getI18nString("emxMBOM.Markup.SelectPlantBOMMarkupsOfSamePlant","emxMBOMStringResource", language); */

String strMultipleParts = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.SelectMarkupsUnderOneAffectedItem");
String strMultipleMarkups = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.SelectSameTypeOfMarkups");
String strOneAppliedMarkup = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.SelectOnlyOneAppliedMarkup");
String strSamePlantBOMsMsg = EnoviaResourceBundle.getProperty(context, "emxMBOMStringResource", context.getLocale(),"emxMBOM.Markup.SelectPlantBOMMarkupsOfSamePlant");

//ENG Convergence Start
String strMultipleItemMarkupMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.CannotSelectMultipleItemMarkup");
String strMarkupsWithDiffCAMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.Markup.CannotSaveMarkupsWithDiffCR");
//ENG Convergence ENd

String ECRObjectId = emxGetParameter(request,"objectId");

String strMarkupRelId = "";
String strMarkupId = "";

String strMarkUpIds = "";
String strPartId = "";
String strTempPartId = null;
String strType = null;
String strTempType = null;
String strMarkupState = null;
//Added for not allowing to open PBMK of different Plants
String strPrevPlant = null;
String strCurrPlant = null;
String strAttrPlantID = PropertyUtil.getSchemaProperty(context,"attribute_PlantID");
String strRelApplPartMarkup = PropertyUtil.getSchemaProperty(context,"relationship_AppliedPartMarkup");

//Added for ENG Convergence start
String strCOId = null;
String strPrevCOId = null;
String RELATIONSHIP_APPLIED_MARKUP = PropertyUtil.getSchemaProperty(context,"relationship_AppliedMarkup");
String RELATIONSHIP_PROPOSED_MARKUP = PropertyUtil.getSchemaProperty(context,"relationship_ProposedMarkup");
String RELATIONSHIP_CHANGE_ACTION = PropertyUtil.getSchemaProperty(context,"relationship_ChangeAction");

DomainObject dObj = new DomainObject(ECRObjectId);
String strPolicy = dObj.getInfo(context, DomainConstants.SELECT_POLICY);
String strReleasePhaseVal = dObj.getInfo(context, EngineeringConstants.ATTRIBUTE_RELEASE_PHASE_VALUE);
String strPolicyClassification = EngineeringUtil.getPolicyClassification(context, strPolicy);
boolean blnMulitpleItemMarkups = false;
boolean blnDiffCA = false;
//Added for ENG Convergence End


DomainObject doMarkup = null;
boolean blnMulitpleTypes = false;
boolean blnMulitplePlantBOMTypes = true;
boolean blnMulitpleParts = false;
boolean blnIsDevelopmentMarkup = false;
boolean blnMultiplePlants = false;
boolean blnMultipleStateMarkups = false;
boolean blnIsAppliedMarkup = false;

String suiteKey = emxGetParameter(request,"suiteKey");
String strObjectId = emxGetParameter(request,"objectId");
String contentURL = "";
String tableRowIdList[] = emxGetParameterValues(request,"emxTableRowId");
String[] emxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
String Location = emxGetParameter(request,"Location");

String TYPE_PART_SPECIFICATION=PropertyUtil.getSchemaProperty(context,"type_PartSpecification");
	 String TYPE_DOCUMENTS=PropertyUtil.getSchemaProperty(context,"type_DOCUMENTS");

	 boolean isSelPart=false;
		
	for(int i=0;i<tableRowIdList.length;i++)
	{
		String rowtemp=tableRowIdList[i];
		StringList strmarkupId = FrameworkUtil.split(tableRowIdList[i],"|");
		String strSelId = (String)strmarkupId.elementAt(1);
		
		DomainObject dosel=new DomainObject(strSelId);
		String sselType=dosel.getInfo(context,DomainConstants.SELECT_TYPE);

        boolean bpart=mxType.isOfParentType(context,sselType,DomainConstants.TYPE_PART);
		boolean bSpec=mxType.isOfParentType(context,sselType,TYPE_DOCUMENTS);
		if(bpart || bSpec)
		{
			isSelPart=true;
%>
			<script language="javascript">
			alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Markup.MarkupAlertonSelectionofDifferentAffectedItems</emxUtil:i18nScript>");
				parent.closeWindow();
			</script>
<%	
			break;	
}
	}

if(!isSelPart)
{
		if (tableRowIdList!= null) 
		{
    for (int i=0; i< tableRowIdList.length; i++) {
       //process - relId|objectId|parentId - using the tableRowId
       String tableRowId = tableRowIdList[i];

       String firstIndex = tableRowIdList[i].substring(0,tableRowIdList[i].indexOf("|"));
        if(!"".equals(firstIndex)) {
          StringTokenizer strTok = new StringTokenizer(tableRowId,"|");
          strMarkupRelId = strTok.nextToken();
          strMarkupId = strTok.nextToken();
          doMarkup = new DomainObject(strMarkupId);
          doMarkup.open(context);
          strTempType = doMarkup.getTypeName();
          
          if ("Production".equalsIgnoreCase(strPolicyClassification)) {        	       	  
        	  //strCOId = doMarkup.getInfo(context,"to["+RELATIONSHIP_APPLIED_MARKUP+"].from.to["+RELATIONSHIP_CHANGE_ACTION+"].from.id");
        	  strCOId = doMarkup.getInfo(context,"to["+RELATIONSHIP_APPLIED_MARKUP+"].from.id");        	  
        	            	  
        	  if(UIUtil.isNullOrEmpty(strCOId)) {
        		  if("TRUE".equalsIgnoreCase(doMarkup.getInfo(context,"to["+RELATIONSHIP_PROPOSED_MARKUP+"]")))
        		  	strCOId = doMarkup.getInfo(context,"to["+RELATIONSHIP_PROPOSED_MARKUP+"].from.id");        		       		 
        	  }  
        	  ECRObjectId = strCOId;
                	  
        	 if(UIUtil.isNotNullAndNotEmpty(strPrevCOId) && UIUtil.isNotNullAndNotEmpty(strCOId) && !strPrevCOId.equals(strCOId)) {        
        		//  blnDiffCA = true;
        	  } else {          		  
          		  	strPrevCOId = strCOId;
        	  }
			}
          
         if(strReleasePhaseVal.equals(EngineeringConstants.DEVELOPMENT))
      	{
      		blnIsDevelopmentMarkup = true;
      	}
          
          if (strTempType.equals(PropertyUtil.getSchemaProperty(context,"type_EBOMMarkup")))
          {
			  strTempType = PropertyUtil.getSchemaProperty(context,"type_BOMMarkup");
		  }
		  //Added for not allowing to open PBMK of different Plants
					if(strTempType.equals(PropertyUtil.getSchemaProperty(context,"type_PlantBOMMarkup"))) 
					{
			  strCurrPlant = doMarkup.getInfo(context,"attribute["+strAttrPlantID+"]");
						if (strPrevPlant!=null && !strCurrPlant.equals(strPrevPlant)) 
						{
				blnMultiplePlants = true;
				break;
			  }
	  		 strPrevPlant = strCurrPlant;
		  }
          doMarkup.close(context);

          if (!strTempType.equals(strType) && i > 0)
          {
						// Added To Handle To Different Types Of Markup START
						//modified for 375031
						if(strTempType.equals(PropertyUtil.getSchemaProperty(context,"type_PlantItemMarkup")) || strTempType.equals(PropertyUtil.getSchemaProperty(context,"type_ItemMarkup")) || strTempType.equals(PropertyUtil.getSchemaProperty(context,"type_BOMMarkup"))|| strTempType.equals(PropertyUtil.getSchemaProperty(context,"type_PlantBOMMarkup")))
						{
							blnMulitplePlantBOMTypes = false;
						}
						// Added To Handle To Different Types Of Markup END
			blnMulitpleTypes = true;
		  }
		  else
		  {
			  strType = strTempType;
		  }
          
          if (UIUtil.isNotNullAndNotEmpty(strTempType) && UIUtil.isNotNullAndNotEmpty(strType) && i > 0
        		  && strTempType.equals(strType) && strTempType.equals(PropertyUtil.getSchemaProperty(context,"type_ItemMarkup"))) {
        	  blnMulitpleItemMarkups = true;
          }
          
		  if (strTok.hasMoreTokens())
		  {
          strTempPartId = strTok.nextToken();
          
          //Added for CA Affected Items Start
          DomainObject doTempObj = new DomainObject(strTempPartId);          
          if(doTempObj.isKindOf(context, ChangeConstants.TYPE_CHANGE_ACTION)) {
        	  strTempPartId = doMarkup.getInfo(context,"to["+DomainConstants.RELATIONSHIP_EBOM_MARKUP+"].from.id");            	  
          }
          //Added for CA Affected Items End
        
          if (!strTempPartId.equals(strPartId) && i > 0)
          {
			blnMulitpleParts = true;
			break;
		  }
		  else
		  {
			  strPartId = strTempPartId;
		  }
		  }
		  else
		  {
			  strPartId = ECRObjectId;
			  blnIsDevelopmentMarkup = true;
		  }
          strMarkupState = doMarkup.getInfo(context, DomainConstants.SELECT_CURRENT);
          if ("Applied".equals(strMarkupState))
          {
			  blnIsAppliedMarkup = true;
			  if (tableRowIdList.length > 1)
			  {
				  blnMultipleStateMarkups = true;
				  break;
			  }
		  }
          if (i == 0)
          {
			  strMarkUpIds = strMarkupId;
		  }
		  else
		  {
			  strMarkUpIds = strMarkUpIds + "," + strMarkupId;
		  }
       }
    }
  }
		
if (!blnMultiplePlants && !blnMultipleStateMarkups && !blnMulitpleParts && !blnMulitpleTypes)
{

if ((PropertyUtil.getSchemaProperty(context,"type_BOMMarkup")).equals(strType) || (PropertyUtil.getSchemaProperty(context,"type_EBOMMarkup")).equals(strType))
{
    if (blnIsDevelopmentMarkup)
    {
        if (blnIsAppliedMarkup)
        {        	
           // contentURL = "../engineeringcentral/emxEngrOpenAppliedMarkupsFS.jsp?emxSuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&objectId="+strPartId + "&markupIds=" + strMarkUpIds;
            contentURL =   contentURL = "../common/emxTable.jsp?program=emxPartMarkup:getAplliedMarkupXMLContent&table=ENCOpenAppliedMarkup&header=emxEngineeringCentral.Markup.OpenMarkup&suiteKey=EngineeringCentral&Export=false&disableSorting=true&mode=view&markupIds="+strMarkUpIds+"&objectId="+strPartId+"&TransactionType=update&HelpMarker=emxhelpopenmarkup&CancelButton=true&CancelLabel=emxEngineeringCentral.Button.Close";            
        }
        else if("Production".equalsIgnoreCase(strPolicyClassification)) {
        	contentURL = "emxEngrMarkupPreProcess.jsp?objectId="+strPartId+"&suiteKey="+suiteKey+"&markupIds=" + strMarkUpIds +"&sChangeOID="+strCOId + "&Location=" + Location;
        } else {
            contentURL = "emxEngrMarkupPreProcess.jsp?objectId="+strPartId+"&suiteKey="+suiteKey+"&markupIds=" + strMarkUpIds + "&Location=" + Location;
            //contentURL = "../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&table=ENCEBOMIndentedSummary&header=emxFramework.Command.BOM&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelpaffecteditemsmarkupopen&PrinterFriendly=true&toolbar=ENCOpenBOMMarkupToolBar&objectId="+strPartId+"&suiteKey="+suiteKey+"&mode=edit&showApply=FALSE&preProcessURL=../engineeringcentral/emxEngrMarkupPreProcess.jsp&markupIds=" + strMarkUpIds +"&preProcessJPO=emxPart:sendXML&selection=multiple&freezePane=Name";
        }
    } else {
        DomainObject changeObj = new DomainObject(ECRObjectId);
        if (blnIsAppliedMarkup )
        {
          /*  DomainObject doPart = new DomainObject(strPartId);
            DomainObject doMarkupObj = new DomainObject(strMarkUpIds);
            String strAppliedRev = doMarkupObj.getInfo(context, "to[" + strRelApplPartMarkup + "].from.id");
            doPart = new DomainObject(strAppliedRev);
            String strPrevRev = doPart.getInfo(context, "previous");
            if (strPrevRev != null && strPrevRev.length() > 0 && !(strPartId.equals(strAppliedRev)))
            {
                contentURL = "emxEngrMarkupPreProcess.jsp?objectId="+strPartId+"&suiteKey="+suiteKey+"&markupIds=" + strMarkUpIds +"&sChangeOID="+ECRObjectId;
                //contentURL = "../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&table=ENCEBOMIndentedSummary"+"&header=emxFramework.Command.BOM&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelpaffecteditemsmarkupopen&PrinterFriendly=true&objectId="+strPartId+"&suiteKey="+suiteKey+"&mode=edit&showApply=FALSE&preProcessURL=../engineeringcentral/emxEngrMarkupPreProcess.jsp&markupIds=" + strMarkUpIds +"&preProcessJPO=emxPart:sendXML&selection=multiple&freezePane=Name&sChangeOID="+ECRObjectId;
            }
            else
            {*/            	
                //contentURL = "../engineeringcentral/emxEngrOpenAppliedMarkupsFS.jsp?emxSuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&objectId="+strPartId + "&markupIds=" + strMarkUpIds;
                contentURL =   contentURL = "../common/emxTable.jsp?program=emxPartMarkup:getAplliedMarkupXMLContent&table=ENCOpenAppliedMarkup&header=emxEngineeringCentral.Markup.OpenMarkup&suiteKey=EngineeringCentral&Export=false&disableSorting=true&mode=view&markupIds="+strMarkUpIds+"&objectId="+strPartId+"&TransactionType=update&HelpMarker=emxhelpopenmarkup&CancelButton=true&CancelLabel=emxEngineeringCentral.Button.Close";                
            //}
        } else {
            String[] inputArgs = new String[2];
            inputArgs[0]= strPartId;
            inputArgs[1]=ECRObjectId;
            
            String strNewPartId = strPartId;
            if(UIUtil.isNotNullAndNotEmpty(ECRObjectId)){
            	strNewPartId = (String) JPO.invoke(context, "enoEngChange", null, "getIndirectAffectedItems", inputArgs,String.class);
            }
            if (strNewPartId != null) {
                contentURL = "emxEngrMarkupPreProcess.jsp?objectId="+strNewPartId+"&suiteKey="+suiteKey+"&markupIds=" + strMarkUpIds +"&sChangeOID="+ECRObjectId;
                //contentURL = "../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&table=ENCEBOMIndentedSummary&header=emxFramework.Command.BOM&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelpaffecteditemsmarkupopen&PrinterFriendly=true&toolbar=ENCOpenBOMMarkupToolBar&objectId="+strNewPartId+"&suiteKey="+suiteKey+"&mode=edit&showApply=FALSE&preProcessURL=../engineeringcentral/emxEngrMarkupPreProcess.jsp&markupIds=" + strMarkUpIds +"&preProcessJPO=emxPart:sendXML&selection=multiple&freezePane=Name&sChangeOID="+ECRObjectId;
            } else {
                contentURL = "emxEngrMarkupPreProcess.jsp?objectId="+strPartId+"&suiteKey="+suiteKey+"&markupIds=" + strMarkUpIds +"&sChangeOID="+ECRObjectId;
                //contentURL = "../common/emxIndentedTable.jsp?expandProgram=emxPart:getStoredEBOM&table=ENCEBOMIndentedSummary&header=emxFramework.Command.BOM&reportType=BOM&sortColumnName=Find Number&sortDirection=ascending&HelpMarker=emxhelpaffecteditemsmarkupopen&PrinterFriendly=true&toolbar=ENCOpenBOMMarkupToolBar&objectId="+strPartId+"&suiteKey="+suiteKey+"&mode=edit&showApply=FALSE&preProcessURL=../engineeringcentral/emxEngrMarkupPreProcess.jsp&markupIds=" + strMarkUpIds +"&preProcessJPO=emxPart:sendXML&selection=multiple&freezePane=Name&sChangeOID="+ECRObjectId;
            }
        }
    }
} else if ((PropertyUtil.getSchemaProperty(context,"type_ItemMarkup")).equals(strType)) {
	String sToolBar = PropertyUtil.getSchemaProperty(context, "menu_ENCEditPartItemMarkupToolbar");
		if (blnIsAppliedMarkup)
		{
			DomainObject doPart = new DomainObject(strPartId);
			DomainObject doMarkupObj = new DomainObject(strMarkUpIds);
			String strAppliedRev = doMarkupObj.getInfo(context, "to[" + strRelApplPartMarkup + "].from.id");
			doPart = new DomainObject(strAppliedRev);
			String strPrevRev = doPart.getInfo(context, "previous");

			if (strPrevRev != null && strPrevRev.length() > 0 && !(strPartId.equals(strAppliedRev)))
			{
				strPartId = strPrevRev;
			}
		}
		else
		{
			String[] inputArgs = new String[2];
			inputArgs[0]= strPartId;
			inputArgs[1]=ECRObjectId;

			String strNewPartId = (String) JPO.invoke(context, "enoEngChange", null, "getIndirectAffectedItems", inputArgs,String.class);

			if (strNewPartId != null)
			{
				strPartId = strNewPartId;
			}
		}
	contentURL = "../common/emxForm.jsp?objectId="+strMarkupId+"&form=type_ItemMarkup&Export=false&mode=view&activity=view&parentOID="+strPartId+"&sChangeOID="+ECRObjectId+"&toolbar="+sToolBar;
}
else if((PropertyUtil.getSchemaProperty(context,"type_PlantBOMMarkup")).equals(strType))
{
        if (blnIsAppliedMarkup)
        {
          /*  DomainObject doPart = new DomainObject(strPartId);
            DomainObject doMarkupObj = new DomainObject(strMarkUpIds);
            String strAppliedRev = doMarkupObj.getInfo(context, "to[" + strRelApplPartMarkup + "].from.id");
            doPart = new DomainObject(strAppliedRev);

            String strPrevRev = doPart.getInfo(context, "previous");

            if (strPrevRev != null && strPrevRev.length() > 0 && !(strPartId.equals(strAppliedRev)))
            {
                contentURL = "../common/emxIndentedTable.jsp?expandProgram=emxPartMaster:getCommonViewBOM&table=MBOMCommonMBOMSummary&sortColumnName=Find Number&sortDirection=ascending&header=emxMBOM.Command.BOMHeader&HelpMarker=emxhelpaffecteditemsmarkupopen&PrinterFriendly=true&selection=multiple&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&suiteKey=MBOM&ENCBillOfMaterialsViewCustomFilter=common&ENCBOMRevisionCustomFilter=As Stored&MBOMDeviationCustomFilter=false&connectionProgram=emxPartMarkup:visualQuesForAlternateAndSubstitute";
                contentURL+="&mode=edit&showApply=FALSE&preProcessURL=../manufacturingchange/emxPlantBOMMarkupViewPreProcess.jsp&markupIds=" + strMarkUpIds +"&preProcessJPO=emxMBOMPart:sendPlantBOMMarkupXML&selection=multiple&freezePane=Name&objectId="+strPartId+"&sChangeOID="+ECRObjectId+"&MBOMPlantCustomFilter="+strPrevPlant;
            }
            else
            {*/
               // contentURL = "../engineeringcentral/emxEngrOpenAppliedMarkupsFS.jsp?emxSuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&objectId="+strPartId + "&markupIds=" + strMarkUpIds;
                contentURL =   contentURL = "../common/emxTable.jsp?program=emxPartMarkup:getAplliedMarkupXMLContent&table=ENCOpenAppliedMarkup&header=emxEngineeringCentral.Markup.OpenMarkup&suiteKey=EngineeringCentral&Export=false&disableSorting=true&mode=view&markupIds="+strMarkUpIds+"&objectId="+strPartId+"&TransactionType=update&HelpMarker=emxmfgmecomarkupopen&CancelButton=true&CancelLabel=emxEngineeringCentral.Button.Close";

            //}
                } 
                else 
                {
            String[] inputArgs = new String[2];
            inputArgs[0]= strPartId;
            inputArgs[1]=ECRObjectId;
            String strNewPartId = (String) JPO.invoke(context, "enoEngChange", null, "getIndirectAffectedItems", inputArgs,String.class);
            if (strNewPartId != null)
            {
                contentURL = "../common/emxIndentedTable.jsp?expandProgram=emxPartMaster:getCommonViewBOM&table=MBOMCommonMBOMSummary&toolbar=MBOMOpenMarkupMenuToolBar&sortColumnName=Find Number&sortDirection=ascending&header=emxMBOM.Command.BOMHeader&HelpMarker=emxhelpaffecteditemsmarkupopen&PrinterFriendly=true&selection=multiple&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&suiteKey=MBOM&ENCBillOfMaterialsViewCustomFilter=common&ENCBOMRevisionCustomFilter=As Stored&MBOMDeviationCustomFilter=false&connectionProgram=emxPartMarkup:visualQuesForAlternateAndSubstitute";
                contentURL+="&mode=edit&showApply=FALSE&preProcessURL=../manufacturingchange/emxPlantBOMMarkupViewPreProcess.jsp&markupIds=" + strMarkUpIds +"&preProcessJPO=emxMBOMPart:sendPlantBOMMarkupXML&selection=multiple&freezePane=Name&objectId="+strNewPartId+"&sChangeOID="+ECRObjectId+"&MBOMPlantCustomFilter="+strPrevPlant;
            }
            else
            {
    contentURL = "../common/emxIndentedTable.jsp?expandProgram=emxPartMaster:getCommonViewBOM&table=MBOMCommonMBOMSummary&toolbar=MBOMOpenMarkupMenuToolBar&sortColumnName=Find Number&sortDirection=ascending&header=emxMBOM.Command.BOMHeader&HelpMarker=emxhelpaffecteditemsmarkupopen&PrinterFriendly=true&selection=multiple&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&suiteKey=MBOM&ENCBillOfMaterialsViewCustomFilter=common&ENCBOMRevisionCustomFilter=As Stored&MBOMDeviationCustomFilter=false&connectionProgram=emxPartMarkup:visualQuesForAlternateAndSubstitute";
    contentURL+="&mode=edit&showApply=FALSE&preProcessURL=../manufacturingchange/emxPlantBOMMarkupViewPreProcess.jsp&markupIds=" + strMarkUpIds +"&preProcessJPO=emxMBOMPart:sendPlantBOMMarkupXML&selection=multiple&freezePane=Name&objectId="+strPartId+"&sChangeOID="+ECRObjectId+"&MBOMPlantCustomFilter="+strPrevPlant;
}
	   }
	}
			else if((PropertyUtil.getSchemaProperty(context,"type_PlantItemMarkup")).equals(strType))
			{
				if(blnIsAppliedMarkup) 
				{
		            //contentURL = "../manufacturingchange/emxMBOMOpenAppliedItemMarkupFS.jsp?emxSuiteDirectory=engineeringcentral&suiteKey=MBOM&objectId="+strPartId + "&markupIds=" + strMarkUpIds;
				    contentURL = "../common/emxIndentedTable.jsp?program=emxPartMaster:getPIMKMarkupXMLContent&table=MBOMPIMKOpenMarkup&header=emxMBOM.Markup.OpenMarkup&suiteKey=MBOM&mode=view&markupIds="+strMarkUpIds+"&objectId="+strPartId+"&TransactionType=update&HelpMarker=emxhelpopenmarkup&Export=false&disableSorting=true&CancelButton=true&CancelLabel=emxMBOM.Button.Close";
				} 
				else 
				{
	String sWhereObjects	= "";
	String sXMLFormat		= PropertyUtil.getSchemaProperty(context, "format_XML");
	//	Send MarkUpXML Code here Goes
	//Below code is sample xml which is similar to  markup xml which
	//need to be sent from this jsp to the called JS method
	DomainObject domMarkup	= new DomainObject(strMarkupId);
	String sMarkupName		= domMarkup.getInfo(context, "name");
	String sTransPath		= context.createWorkspace();
	java.io.File fEmatrixWebRoot = new java.io.File(sTransPath);

	domMarkup.checkoutFile(context, false, sXMLFormat, sMarkupName+ ".xml", fEmatrixWebRoot.toString());
	java.io.File srcXMLFile = new java.io.File(fEmatrixWebRoot, sMarkupName+ ".xml");
	com.matrixone.jdom.input.SAXBuilder builder	= new com.matrixone.jdom.input.SAXBuilder();
	builder.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
	builder.setFeature("http://xml.org/sax/features/external-general-entities", false);
	builder.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
	com.matrixone.jdom.Document docXML			= builder.build(srcXMLFile);
	com.matrixone.jdom.Element rootElement		= docXML.getRootElement();

	java.util.List lElement = rootElement.getChildren();
	java.util.Iterator itr	= lElement.iterator();
					while(itr.hasNext())
					{
		com.matrixone.jdom.Element childElement = (com.matrixone.jdom.Element)itr.next();
						if(!sWhereObjects.equals(""))
						{
			sWhereObjects += "|";
		}
		sWhereObjects += childElement.getAttributeValue("id");
	}
	session.setAttribute("rootElement", rootElement);
	session.setAttribute("parentOID", ECRObjectId);

	contentURL = "../common/emxIndentedTable.jsp?table=MBOMManufacturingResponsibility&toolbar=MBOMMarkupEditToolBar&expandProgram=emxPartMarkup:getAllManuSites&suiteKey=MBOM&header=emxMBOM.ManufacturingResponsibility.Heading&sortColumnName=Plant Id&sortDirection=ascending&location=&expandLevelFilter=false&activity=view&mode=edit&selection=multiple&showApply=false&objectId="+strPartId+"&preProcessURL=../manufacturingchange/emxMBOMPIMPreProcess.jsp&preProcessJPO=emxPartMarkup:sendPIMXML&markupId=" + strMarkUpIds+"&filterObjects="+sWhereObjects;
}
}
}
        // Added To Handle To Different Types Of Markup START
        else if (!blnMultiplePlants && !blnMultipleStateMarkups && !blnMulitpleParts && blnMulitpleTypes) 
        {
            if ((PropertyUtil.getSchemaProperty(context,"type_BOMMarkup")).equals(strType) || (PropertyUtil.getSchemaProperty(context,"type_EBOMMarkup")).equals(strType) || (PropertyUtil.getSchemaProperty(context,"type_PlantBOMMarkup")).equals(strType))
            {
                if (blnIsAppliedMarkup) 
                {
                  /*  DomainObject doPart = new DomainObject(strPartId);
                    DomainObject doMarkupObj = new DomainObject(strMarkUpIds);
                    String strAppliedRev = doMarkupObj.getInfo(context, "to[" + strRelApplPartMarkup + "].from.id");
            
                    doPart = new DomainObject(strAppliedRev);
        
                    String strPrevRev = doPart.getInfo(context, "previous");
        
                    if (strPrevRev != null && strPrevRev.length() > 0 && !(strPartId.equals(strAppliedRev))) 
                    {
                        contentURL = "../common/emxIndentedTable.jsp?expandProgram=emxPartMaster:getCommonViewBOM&table=MBOMCommonMBOMSummary&sortColumnName=Find Number&sortDirection=ascending&header=emxMBOM.Command.BOMHeader&HelpMarker=emxhelppartbom&PrinterFriendly=true&selection=multiple&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&suiteKey=MBOM&ENCBillOfMaterialsViewCustomFilter=common&ENCBOMRevisionCustomFilter=As Stored&MBOMDeviationCustomFilter=false&connectionProgram=emxPartMarkup:visualQuesForAlternateAndSubstitute";
                        contentURL+="&mode=edit&showApply=FALSE&preProcessURL=../manufacturingchange/emxPlantBOMMarkupViewPreProcess.jsp&markupIds=" + strMarkUpIds +"&preProcessJPO=emxMBOMPart:sendPlantBOMMarkupXML&selection=multiple&freezePane=Name&objectId="+strPartId+"&sChangeOID="+ECRObjectId+"&MBOMPlantCustomFilter="+strPrevPlant;
                    } 
                    else 
                    { */
                      //  contentURL = "../engineeringcentral/emxEngrOpenAppliedMarkupsFS.jsp?emxSuiteDirectory=engineeringcentral&suiteKey=EngineeringCentral&objectId="+strPartId + "&markupIds=" + strMarkUpIds;
                    	contentURL =   contentURL = "../common/emxTable.jsp?program=emxPartMarkup:getAplliedMarkupXMLContent&table=ENCOpenAppliedMarkup&header=emxEngineeringCentral.Markup.OpenMarkup&suiteKey=EngineeringCentral&Export=false&disableSorting=true&mode=view&markupIds="+strMarkUpIds+"&objectId="+strPartId+"&TransactionType=update&HelpMarker=emxhelpopenmarkup&CancelButton=true&CancelLabel=emxEngineeringCentral.Button.Close";

                   // }
                } 
                else 
                {
                    String[] inputArgs = new String[2];
                    inputArgs[0]= strPartId;
                    inputArgs[1]=ECRObjectId;
            
                    String strNewPartId  = strPartId;
                    if(UIUtil.isNotNullAndNotEmpty(ECRObjectId)){
                    	strNewPartId = (String) JPO.invoke(context, "enoEngChange", null, "getIndirectAffectedItems", inputArgs,String.class);
                    }
                    if (strNewPartId != null) 
                    {
                        contentURL = "../common/emxIndentedTable.jsp?expandProgram=emxPartMaster:getCommonViewBOM&table=MBOMCommonMBOMSummary&toolbar=MBOMOpenMarkupMenuToolBar&sortColumnName=Find Number&sortDirection=ascending&header=emxMBOM.Command.BOMHeader&HelpMarker=emxhelppartbom&PrinterFriendly=true&selection=multiple&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&suiteKey=MBOM&ENCBillOfMaterialsViewCustomFilter=common&ENCBOMRevisionCustomFilter=As Stored&MBOMDeviationCustomFilter=false&connectionProgram=emxPartMarkup:visualQuesForAlternateAndSubstitute";
                        contentURL+="&mode=edit&showApply=FALSE&preProcessURL=../manufacturingchange/emxPlantBOMMarkupViewPreProcess.jsp&markupIds=" + strMarkUpIds +"&preProcessJPO=emxMBOMPart:sendPlantBOMMarkupXML&selection=multiple&freezePane=Name&objectId="+strNewPartId+"&sChangeOID="+ECRObjectId+"&MBOMPlantCustomFilter="+strPrevPlant;
                    } 
                    else 
                    {
                        contentURL = "../common/emxIndentedTable.jsp?expandProgram=emxPartMaster:getCommonViewBOM&table=MBOMCommonMBOMSummary&toolbar=MBOMOpenMarkupMenuToolBar&sortColumnName=Find Number&sortDirection=ascending&header=emxMBOM.Command.BOMHeader&HelpMarker=emxhelppartbom&PrinterFriendly=true&selection=multiple&expandLevelFilter=true&objectCompare=false&expandLevelFilterMenu=MBOMFreezePaneExpandLevelFilter&suiteKey=MBOM&ENCBillOfMaterialsViewCustomFilter=common&ENCBOMRevisionCustomFilter=As Stored&MBOMDeviationCustomFilter=false&connectionProgram=emxPartMarkup:visualQuesForAlternateAndSubstitute";
                        contentURL+="&mode=edit&showApply=FALSE&preProcessURL=../manufacturingchange/emxPlantBOMMarkupViewPreProcess.jsp&markupIds=" + strMarkUpIds +"&preProcessJPO=emxMBOMPart:sendPlantBOMMarkupXML&selection=multiple&freezePane=Name&objectId="+strPartId+"&sChangeOID="+ECRObjectId+"&MBOMPlantCustomFilter="+strPrevPlant;
                    }
            } // End Of if (blnIsAppliedMarkup) IF/ELSE
            } // End Of Markup Type Check
        }
    // Added To Handle To Different Types Of Markup END


%>
<html>
<head>
</head>

<body scrollbar="no" border="0">
<script language="JavaScript" type="text/javascript">
<%
if(blnMulitpleTypes && !blnMulitplePlantBOMTypes)
{
%>
//XSSOK
alert("<%=strMultipleMarkups%>");
parent.closeWindow();
<% } 
//ENG Convergence Start
else if(blnMulitpleItemMarkups) {		
	%> 
	//XSSOK
	alert("<%=strMultipleItemMarkupMsg%>");
	parent.closeWindow();
<%
} else if(blnDiffCA) {
	%> 
	//XSSOK
	alert("<%=strMarkupsWithDiffCAMsg%>");
	parent.closeWindow();
<%
}

//ENG Convergence End
else if (blnMulitpleParts)
{
%>
//XSSOK
alert("<%=strMultipleParts%>");
parent.closeWindow();
<%
				} 
				else if(blnMultiplePlants)
{
%>
//XSSOK
alert("<%=strSamePlantBOMsMsg%>");
parent.closeWindow();
<%
}
else if (blnMultipleStateMarkups)
{
%>
//XSSOK
alert("<%=strOneAppliedMarkup%>");
parent.closeWindow();
<%
}
else
{
%>
//XSSOK
document.location.href='<%=XSSUtil.encodeForJavaScript(context,contentURL)%>';
<%
}
%>
</script>
</body>
</html>
<%
}
ContextUtil.popContext(context);
%>
