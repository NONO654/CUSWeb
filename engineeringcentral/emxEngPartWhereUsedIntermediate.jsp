 <!--  emxEngPartWhereUsedIntermediate.jsp -  This is an intermediate jsp to invoke webform
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
-->

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@ page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@ page import="com.matrixone.apps.engineering.EngineeringConstants"%>

<%

	String strRMBTableID = emxGetParameter(request, "emxTableRowId");
    String objectId = emxGetParameter(request, "objectId");
	String suiteKey = emxGetParameter(request, "suiteKey");	
	String sRMBPlanning = emxGetParameter(request, "Initial");
	//Added for IR-216449V6R2014 : Start
	DomainObject doPart = new DomainObject(objectId);
	StringList slInfoList = new StringList(2);
	slInfoList.addElement(DomainConstants.SELECT_POLICY);
	slInfoList.addElement(DomainConstants.SELECT_TYPE);
	Map mapPartInfo= doPart.getInfo(context, slInfoList);
	String sPartPolicy = (String)mapPartInfo.get(DomainConstants.SELECT_POLICY);
	//Added for IR-216449V6R2014 : End

    if (strRMBTableID != null && !"null".equals(strRMBTableID) && !"".equals(strRMBTableID)) {
		StringList sList = FrameworkUtil.split(strRMBTableID, "|");    
		
		if (sList.size() == 3) {
			objectId = (String) sList.get(0);		    
		} else if (sList.size() == 4) {
			objectId = (String) sList.get(1);		    
		} else if (sList.size() == 2) {
			objectId = (String) sList.get(1);
		} else {
			objectId = strRMBTableID;
		}
    }
//For Adding Default values from Properties file -- Start

    //Multitenant
	//String strSelectedRevisions = UINavigatorUtil.getI18nString("emxEngineeringCentral.RevisionFilterOption.Latest", "emxEngineeringCentralStringResource", "en");
	String strSelectedRevisions = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", new Locale("en"),"emxEngineeringCentral.RevisionFilterOption.Latest");
	//Multitenant
	//String strSelectedLevel = UINavigatorUtil.getI18nString("emxEngineeringCentral.Part.WhereUsedLevelUpTo", "emxEngineeringCentralStringResource", "en");
	String strSelectedLevel = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", new Locale("en"),"emxEngineeringCentral.Part.WhereUsedLevelUpTo");
    String strSelectedLevelValue = "1";
    
    try {
    	//Multitenant
    	//String propDefaultRev = FrameworkProperties.getProperty("emxEngineeringCentral.DefaultWhereUsedRevFilter");
    	String propDefaultRev = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentral.DefaultWhereUsedRevFilter");
	    if (propDefaultRev != null && !"".equals(propDefaultRev)) {
	    	//Multitenant
	    	//strSelectedRevisions = UINavigatorUtil.getI18nString(propDefaultRev, "emxEngineeringCentralStringResource", "en");
	    	strSelectedRevisions = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", new Locale("en"),propDefaultRev);
	    }
    } catch (Exception e) {}

    try {
	    String propDefaultLevel = FrameworkProperties.getProperty(context, "emxEngineeringCentral.DefaultEBOMLevelFilter");
	    if (propDefaultLevel != null && !"".equals(propDefaultLevel)) {
	    	//Multitenant
	    	//strSelectedLevel = UINavigatorUtil.getI18nString(propDefaultLevel, "emxEngineeringCentralStringResource", "en");
	    	strSelectedLevel = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", new Locale("en"),propDefaultLevel);
	    }
    } catch (Exception e) {}

    try {
	    String propDefaultLevelValue = FrameworkProperties.getProperty(context, "emxEngineeringCentral.DefaultEBOMLevel");
	    if (propDefaultLevelValue != null && !"".equals(propDefaultLevelValue)) {
	    	//Multitenant
	    	//strSelectedLevelValue = UINavigatorUtil.getI18nString(propDefaultLevelValue, "emxEngineeringCentralStringResource", "en");
	    	strSelectedLevelValue = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", new Locale("en"),propDefaultLevelValue);
	    }
    } catch (Exception e) {}

// For Adding Default values from Properties file -- Start
	String strPolicyClassification = (String)(DomainObject.newInstance(context,objectId).getInfo(context,"policy.property[PolicyClassification].value"));
	boolean isECCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionEngineeringConfigurationCentral",false,null,null);
	if (isECCInstalled) {
		if (objectId != null && !"null".equals(objectId) && !"".equals(objectId)) {
			  suiteKey	= strPolicyClassification.equalsIgnoreCase("Unresolved")?"UnresolvedEBOM":suiteKey;
		}
	}
	
    // String actionURL = "../common/emxIndentedTable.jsp?portalMode=true&partWhereUsed=true&header=emxEngineeringCentral.Common.WhereUsed&suiteKey="+suiteKey+"&table=PartWhereUsedTable&program=emxPart:getPartWhereUsed&toolbar=ENCpartReviewWhereUsedSummaryToolBar,ENCPartWhereUsedFiltersToolbar1,ENCPartWhereUsedFiltersToolbar2&HelpMarker=emxhelppartwhereused&selection=multiple&expandLevelFilter=false&PrinterFriendly=true&objectId=" + objectId + "&ENCPartWhereUsedLevel=" + strSelectedLevel + "&ENCPartWhereUsedLevelTextBox=" + strSelectedLevelValue + "&ENCPartWhereUsedRevisions=" + strSelectedRevisions;

%>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript">

   var currValue ="";
   //XSSOK
   if('false' == "<%=sRMBPlanning%>" || 'true' == "<%=sRMBPlanning%>")
   	currValue = "planning";
   
   //XSSOK
   if(currValue =="" && "Manufacturing Part" == "<%=sPartPolicy%>"){
		currValue = "plantspecific";	   
   }

   	if ("planning" == currValue) {
   		URL = "../common/emxIndentedTable.jsp?program=emxPlanningMBOM:getPartWhereUsed&partWhereUsed=true&table=MFGPlanningMBOMWhereUsedSummary&header=emxPlanningMBOM.Part.WhereUsedInMBOMHeader&sortColumnName=FindNumber&sortDirection=ascending&HelpMarker=emxhelppartwhereusedinplbom&PrinterFriendly=true&location=&toolbar=MFGPlanningWhereUsedToolbar,MFGPlanningWhereUsedCustomFilterMenu&expandLevelFilter=false&suiteKey=MBOM&Export=true&MFGPlanningWhereUsedFilter=plmbom&objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>";
   	} else if ("plantspecific" == currValue) {
   		URL = "../common/emxIndentedTable.jsp?header=emxMBOM.Part.WhereUsedInMBOMHeader&partWhereUsed=true&expandProgram=emxPartMaster:getWhereUsed&table=MBOMWhereUsedMBOMSummary&sortColumnName=FindNumber&sortDirection=ascending&HelpMarker=emxhelppartwhereusedinmbom&PrinterFriendly=true&location=&toolbar=MBOMWhereUsedToolBar,MBOMWhereUsedCustomFilterMenu&expandLevelFilter=false&Export=true&MFGPlanningWhereUsedFilter=mbom&suiteKey=MBOM&objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>";
   	}else{
   //XSSOK
   		URL = "../common/emxIndentedTable.jsp?header=emxEngineeringCentral.Common.WhereUsed&sortColumnName=none&partWhereUsed=true&showMassUpdate=false&suiteKey=<%=XSSUtil.encodeForJavaScript(context,suiteKey)%>&table=PartWhereUsedTable&program=emxPart:getPartWhereUsed&expandProgram=emxPart:getPartWhereUsed&showApply=false&toolbar=ENCpartReviewWhereUsedSummaryToolBar,ENCPartWhereUsedFiltersToolbar1,ENCPartWhereUsedFiltersToolbar2&HelpMarker=emxhelppartwhereused&selection=multiple&expandLevelFilter=false&expandByDefault=true&PrinterFriendly=true&objectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&ENCPartWhereUsedLevel=<%=strSelectedLevel%>&ENCPartWhereUsedLevelTextBox=<%=strSelectedLevelValue%>&ENCPartWhereUsedRevisions=<%=XSSUtil.encodeForJavaScript(context,strSelectedRevisions)%>";   		
   	}
   	//XSSOK
   	if(("Production" == "<%=strPolicyClassification%>" || "Development" ==  "<%=strPolicyClassification%>") && !(<%=doPart.isKindOf(context,EngineeringConstants.TYPE_MANUFACTURING_PART)%>)){   		
   		URL = URL +"&onReset=resetWhereUsedMassChange&editLink=true";
   	}
   	URL = URL + "&showFilter=true";
   //XSSOK
   var isRMBMenu = "<%= XSSUtil.encodeForJavaScript(context,strRMBTableID)%>";
   if(isRMBMenu != null && isRMBMenu != "null" && isRMBMenu != ""){
   //XSSOK
	  URL = URL + "&openShowModalDialog=true";
	   getTopWindow().showModalDialog(URL, "Max", "Max",true);
   }
   else {
   //XSSOK
   		URL = URL + "&portalMode=true";
	   window.location.href = URL;
   }           
   </script>         
        
