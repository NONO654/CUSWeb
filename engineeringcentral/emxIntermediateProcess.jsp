<%--  emxIntermediateProcess.jsp -  This is an intermediate jsp to invoke webform
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@page import="com.matrixone.apps.common.EngineeringChange,com.matrixone.apps.domain.util.i18nNow,java.util.Iterator,matrix.util.StringList,com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants,com.matrixone.apps.domain.util.MapList,java.util.HashMap,com.matrixone.apps.engineering.EngineeringConstants"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>


<%!
public String[] getSelectedObjectId(String[] objectIds) {
	int size = objectIds == null ? 0 : objectIds.length;
	StringList sList;
	String objectId;
	String[] arrObjectIdReturn = new String[size];
	
	for (int i = 0; i < size; i++) {
		sList = FrameworkUtil.split(objectIds[i], "|");    
	    
	    if (sList.size() == 3) {
	    	objectId = (String) sList.get(0);
	    } else { 
	    	objectId = (String) sList.get(1);
	    }
	    
	    arrObjectIdReturn[i] = objectId; 
	}
	
	return arrObjectIdReturn;
}
%>

<%
    String languageStr = request.getHeader("Accept-Language");
    i18nNow i18nnow = new i18nNow();
    
  	//Multitenant
    /* String strECRalertmessage = i18nNow.getI18nString("emxEngineeringCentral.BOMPowerView.ECRalertmessage","emxEngineeringCentralStringResource",context.getSession().getLanguage());
    String strProductionPartalertmessage = i18nNow.getI18nString("emxEngineeringCentral.AddTo.alertmessage","emxEngineeringCentralStringResource",context.getSession().getLanguage());
    String strObsoletePartalertmessage = i18nNow.getI18nString("emxEngineeringCentral.BOMPowerView.ObsoletePartalertmessage","emxEngineeringCentralStringResource",context.getSession().getLanguage());
    String strECOalertmessage = i18nNow.getI18nString("emxEngineeringCentral.BOMPowerView.ECOalertmessage","emxEngineeringCentralStringResource",context.getSession().getLanguage());
    String strDiffRDOMessage = i18nNow.getI18nString("emxEngineeringCentral.AffectedItem.AffectedItemHavingSameRDOs", "emxEngineeringCentralStringResource", context.getSession().getLanguage()); */
    
    String strECRalertmessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BOMPowerView.ECRalertmessage");
    String strProductionPartalertmessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.AddTo.alertmessage");
    String strObsoletePartalertmessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BOMPowerView.ObsoletePartalertmessage");
    String strECOalertmessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.BOMPowerView.ECOalertmessage");
    String strDiffRDOMessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.AffectedItem.AffectedItemHavingSameRDOs");
    String strCRalertmessage = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", context.getLocale(),"emxEngineeringCentral.AffectedItems.MoveToCRalertmessage");    
    
    String[] emxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    String fullSearch = emxGetParameter(request, "isFullSearch");
    String strDevPartPolicy = PropertyUtil.getSchemaProperty(context,"policy_DevelopmentPart");
    String strPolicyName = PropertyUtil.getSchemaProperty(context,"policy_ECPart"); //policy_ECPart
    String strStandPartPolicy = PropertyUtil.getSchemaProperty(context,"policy_StandardPart");
    String strCurrentName = PropertyUtil.getSchemaProperty(context,"policy",strPolicyName,"state_Release");
    String strCurrentObsolete = PropertyUtil.getSchemaProperty(context,"policy",strPolicyName,"state_Obsolete");
    String strCurrentName1ForECO = PropertyUtil.getSchemaProperty(context,"policy",strPolicyName,"state_Preliminary");
    String strCurrentName2ForECO = PropertyUtil.getSchemaProperty(context,"policy",strPolicyName,"state_Release");
    String contentURL = "";

    String strContentLabel = "";
    boolean isNotRelease = false;
    boolean isNotProductionPart = false;
    boolean isObsolete = false;
    boolean isNotInPreliminaryOrRelease = false;

    String strMode = emxGetParameter(request, "CreateMode");    
        
    String strObjectId = emxGetParameter(request, "objectId");
    
    String disableRDOField = "false";
    String strPartId = "";
    
    if ("null".equals(strObjectId) || "".equals(strObjectId)) {
        strObjectId = null;
    }
    long timeinMilli = System.currentTimeMillis();
     
    DomainObject doContextObj = new DomainObject(strObjectId);  
    
    DomainObject doObj = DomainObject.newInstance(context);
    EngineeringChange ECBean = (EngineeringChange)DomainObject.newInstance(context,DomainConstants.TYPE_ENGINEERING_CHANGE);
    Map relIdMap = ECBean.getObjectIdsRelIds(emxTableRowIds);
    String[] strObjectIds = (String[]) relIdMap.get("ObjId");
     //Added for IR-086764V6R2012 starts
    if(null!=strMode && (strMode.equalsIgnoreCase("MoveToECO")||strMode.equalsIgnoreCase("MoveToECOExisting")))
    {
    String[] relids = (String[]) relIdMap.get("RelId");
    
    for(int i=0;i<strObjectIds.length;i++)
    {
        strObjectIds[i]=strObjectIds[i]+"|"+relids[i];
    }
    }
     //Modified for IR-086764V6R2012 ends
    String strIds = "";
    
    //  363480
    String partsWithRevision = "";
    String[] filteredParts = null;
    String msgLatestRev = "";
    String msgSelectValidParts = "";
    boolean noFilteredPartExist = false;
    boolean partsWithRevisionExist = false;
    // Added for IR-108282V6R2012x
    String dynamicUrlFS = "";
    String dynamicUrlCreate = "";
    String rdoId = "";
    String rdoName = "";
    String rdoData = "";
    if (!("AddToECR".equals(strMode) || "AddToECRExisting".equals(strMode) || "MoveToCRExisting".equals(strMode))) {
    	//Modified for RDO Convergence Start
        //rdoData = (String) JPO.invoke (context, "emxPart", null, "getRDOId", getSelectedObjectId(emxTableRowIds), String.class);
    	rdoData = (String) JPO.invoke (context, "emxPart", null, "getPartorg", getSelectedObjectId(emxTableRowIds), String.class);
	}
	if (rdoData != null && !"".equals(rdoData)) {
		//rdoId = (String) FrameworkUtil.split(rdoData, "|").get(0);
		//rdoName = (String) FrameworkUtil.split(rdoData, "|").get(1);
		String whrClause = "name == '"+rdoData +"'";
		String result = MqlUtil.mqlCommand(context, "temp query bus $1 $2 $3 where $4 select $5 dump $6",DomainConstants.TYPE_ORGANIZATION,"*","*",whrClause,"id","|"); 		
		rdoId = result.substring(result.lastIndexOf("|")+1);
		rdoName = rdoData;
		
		//dynamicUrlFS = ":AFFECTEDITEMS_RDO=Unassigned|" + rdoId;		
		//dynamicUrlFS = ":ALTOWNER1=Unassigned|" + rdoData;	//Modified for IR-232344	
		dynamicUrlFS = ":ORGANIZATION=" + rdoData;	
		//Modified for RDO Convergence End
		
		dynamicUrlCreate = "&setRDOValue=Yes&DesignRespOID=" + rdoId;		
		disableRDOField = "true";
	}
	// Added for IR-108282V6R2012x
	if(strObjectIds != null) {		
		Map partMap = (Map)JPO.invoke(context,"emxENCFullSearch",null, "filterPartsWithNextReleasedRevision",strObjectIds,Map.class);
		partsWithRevision = (String)partMap.get("partsWithRevision");
		filteredParts = (String[])partMap.get("filteredParts");
		
		//Multitenant
		//msgLatestRev = i18nNow.getI18nString("emxEngineeringCentral.Alert.LatestRevisionExists","emxEngineeringCentralStringResource",context.getSession().getLanguage())+partsWithRevision;
		msgLatestRev = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", new Locale(context.getSession().getLanguage()),"emxEngineeringCentral.Alert.LatestRevisionExists")+partsWithRevision; 
	}
	
	strObjectIds = filteredParts;	
    if((filteredParts==null)||(filteredParts.length == 0)) {
        noFilteredPartExist = true;  
    }  
    if(!partsWithRevision.equals("")) {
        partsWithRevisionExist = true;
    }
	//363480
	StringTokenizer strTokTemp = null;
	String strTempId = null;
	if (strObjectIds != null) {
		int intNumIds = strObjectIds.length;

		for (int k = 0 ; k < intNumIds; k++) {
			if (k == 0) {
				strIds = strObjectIds[k];
			} else {
				strTokTemp = new StringTokenizer(strObjectIds[k], "|");
	            strTempId = strTokTemp.nextToken().trim(); 
	            if(strIds.indexOf(strTempId) == -1){
	                strIds = strIds + "~" + strObjectIds[k];
	            }
			}
		}
	}

	StringList memberIds = new StringList();
    String excludeOidProgramTxt = "";
    String sRelId = "";
    String prevRevisionState = null;
    //Added for IR-078274V6R2012 starts
    StringList slUniqueObjectIds=new StringList();
    String [] strUniqueObjectIds=null;
    //Added for IR-078274V6R2012 ends
    if(strMode!=null) {
        if(strMode.equalsIgnoreCase("AssignToECO") || strMode.equalsIgnoreCase("MoveToECO") 
                || strMode.equalsIgnoreCase("AssignToECOExisting") || strMode.equalsIgnoreCase("MoveToECOExisting")   
                || strMode.equalsIgnoreCase("AddToECO") || strMode.equalsIgnoreCase("AddToECOExisting")  
                || strMode.equalsIgnoreCase("AddToECR") || strMode.equalsIgnoreCase("AddToECRExisting")
                || strMode.equalsIgnoreCase("MoveToCRNew") || strMode.equalsIgnoreCase("MoveToCRExisting")) {
            for(int i=0; i < strObjectIds.length; i++) {            
            	//Added for ENG Convergence Start
            	String strAffectedItem = strObjectIds[i];	
            	if(UIUtil.isNotNullAndNotEmpty(strPartId)) {
            		strPartId += "," + strAffectedItem.substring(0, strAffectedItem.indexOf("|"));
            	} else {
            		strPartId = strAffectedItem.substring(0, strAffectedItem.indexOf("|"));
            	}				
            	
            	//Added for ENG Convergence End
                StringTokenizer st = new StringTokenizer(strObjectIds[i], "|");
                sRelId = st.nextToken();
                if(memberIds.contains(sRelId)) continue;
                //Added for IR-078274V6R2012
                //If the objectId is not a duplicate add to the list
                else
                {
                    slUniqueObjectIds.add(strObjectIds[i]);                 
                        
                }
                
                memberIds.addElement(sRelId);
                DomainObject domObject = new DomainObject(sRelId);
                String strPolicy = domObject.getInfo(context,DomainObject.SELECT_POLICY);
                String strCurrent = domObject.getInfo(context,DomainObject.SELECT_CURRENT);             

				if(domObject.isKindOf(context, EngineeringConstants.TYPE_MANUFACTURING_PART)) {
					isNotProductionPart = true;
					break;
				}
                
                if (domObject.isKindOf(context, DomainConstants.TYPE_PART)) {
                    String strPolicyClassification = EngineeringUtil.getPolicyClassification(context, strPolicy);
                    
                    if (!"Production".equalsIgnoreCase(strPolicyClassification)) {
                    	isNotProductionPart = true;
                        break;
                    }                                  
                }
                
                if(strCurrent.trim().equals(strCurrentObsolete)) {
                    isObsolete = true;
                    break;
                }
        
                if(!(strCurrent.trim().equals(strCurrentName))) {
                    isNotRelease = true;
                }
                
                if(!(strCurrent.trim().equals(strCurrentName1ForECO)) && !(strCurrent.trim().equals(strCurrentName2ForECO))) {
                    isNotInPreliminaryOrRelease = true;
                }
            }
        }
        //Added for IR-078274V6R2012
                 strUniqueObjectIds=      (String[])slUniqueObjectIds.toArray(new String[slUniqueObjectIds.size()]);
        
        if(strMode.equalsIgnoreCase("AssignToECOExisting") || strMode.equalsIgnoreCase("MoveToECOExisting")  
                    || strMode.equalsIgnoreCase("AddToECOExisting") || strMode.equalsIgnoreCase("MoveToCRExisting")
                    || strMode.equalsIgnoreCase("MoveToCRNew")) {
            //Modified for IR-078274V6R2012
            session.setAttribute("programMapforPart",strUniqueObjectIds);
            session.setAttribute("strMode",strMode);
            if(strMode.equalsIgnoreCase("MoveToCRExisting")) {
            	session.setAttribute("strSelectedItemIds",strPartId);
            }
		}

        if(strMode.equalsIgnoreCase("AddToECRExisting")) {
            session.setAttribute("strMode",strMode);
            //Modified for IR-078274V6R2012
            session.setAttribute("selectedParts",strUniqueObjectIds);
        }
		
        String smbPolicyFilterForECO = ":Policy!=policy_DECO,policy_TeamECO";
        
        if(strMode.equalsIgnoreCase("AssignToECOExisting")) {
            contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_ECO" +smbPolicyFilterForECO+ ":CURRENT=policy_ECO.state_Create,policy_ECO.state_DefineComponents,policy_ECO.state_DesignWork" + dynamicUrlFS + "&table=ENCAddExistingGeneralSearchResults&showInitialResults=false&selection=single&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrAssociateAffectedItemECOConnectECO.jsp&HelpMarker=emxhelpfullsearch&excludeOIDprogram=emxECR:getRelatedECOOIDs&objectId=" + strObjectId +"&strMode=" + strMode;
        } else if(strMode.equalsIgnoreCase("MoveToECOExisting")) {
            contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_ECO" +smbPolicyFilterForECO+ ":CURRENT=policy_ECO.state_Create,policy_ECO.state_DefineComponents,policy_ECO.state_DesignWork" + dynamicUrlFS + "&table=ENCAddExistingGeneralSearchResults&showInitialResults=false&selection=single&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrAssociateAffectedItemECOConnectECO.jsp&HelpMarker=emxhelpfullsearch&excludeOID=" + strObjectId + "&objectId=" + strObjectId + "&strMode=" + strMode;
        } else if(strMode.equalsIgnoreCase("AddToECOExisting")) {
            contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_ECO" +smbPolicyFilterForECO+ ":CURRENT=policy_ECO.state_Create,policy_ECO.state_DefineComponents,policy_ECO.state_DesignWork" + dynamicUrlFS + "&table=ENCAddExistingGeneralSearchResults&showInitialResults=false&selection=single&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxEngrAssociateAffectedItemECOConnectECO.jsp&HelpMarker=emxhelpfullsearch&objectId=" + strObjectId + "&strMode=" + strMode;
        } else if(strMode.equalsIgnoreCase("AddToECRExisting")) {
            contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_ECR:Type!=type_DCR:CURRENT=policy_ECR.state_Create,policy_ECR.state_Submit,policy_ECR.state_Evaluate" + dynamicUrlFS + "&table=ENCAddExistingGeneralSearchResults&showInitialResults=false&selection=single&submitAction=refreshCaller&hideHeader=true&submitURL=../engineeringcentral/emxAffectedItemCreateRaiseECR.jsp&HelpMarker=emxhelpfullsearch&objectId=" + strObjectId + "&strMode=" + strMode;
        } else if(strMode.equalsIgnoreCase("MoveToCRExisting")) {
            contentURL = "../common/emxFullSearch.jsp?field=TYPES=type_ChangeRequest:CURRENT=policy_ChangeRequest.state_Create,policy_ChangeRequest.state_Evaluate&table=ENCAddExistingGeneralSearchResults&showInitialResults=false&selection=single&submitAction=treeContent&hideHeader=true&submitURL=../engineeringcentral/emxEngrAssociateAffectedItemECOConnectECO.jsp&HelpMarker=emxhelpfullsearch&excludeOID=" + strObjectId + "&objectId=" + strObjectId + "&strMode=" + strMode;
        }
    }
 %>
<html>
<head>
</head>
<body>
<form name="form" method="post">

<% 
java.util.Map contextObjDtlMap = new HashMap(); 
if(strMode!=null) {
	if(strMode.equalsIgnoreCase("AssignToECO") 
	        || strMode.equalsIgnoreCase("MoveToECO")  
	        || strMode.equalsIgnoreCase("AddToECO") 
	        ||strMode.equalsIgnoreCase("AddToECR")) {
%>
				<input type="hidden" name="memberid" value="<xss:encodeForHTMLAttribute><%=memberIds%></xss:encodeForHTMLAttribute>" />
				<input type="hidden" name="affectedItems" value="<xss:encodeForHTMLAttribute><%=strIds%></xss:encodeForHTMLAttribute>" />
    
<%
		//To Reload the values when operation is AssignToECO, MoveTo/AddTo ECO/ECR		
		if(strObjectId != null && (doContextObj.isKindOf(context, DomainConstants.TYPE_ECR)
		        || doContextObj.isKindOf(context, DomainConstants.TYPE_ECO))) {			
		    contextObjDtlMap = com.matrixone.apps.engineering.EngineeringUtil.getContextObjectDetailsOnECOCreate(context, strObjectId);		    
		}		
	}
}	

%>
    <script language="javascript">
    //XSSOK
	var rdoName = encodeURIComponent("<%=rdoName%>");
	</script>
	
	<input type="hidden" name="ReportedAgainstChangeOID" value="<xss:encodeForHTMLAttribute><%=(String)contextObjDtlMap.get("ReportedAgainstChangeOID")%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="ReportedAgainstChangeName" value="<xss:encodeForHTMLAttribute><%=(String)contextObjDtlMap.get("ReportedAgainstChangeName")%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="AprListOID" value="<xss:encodeForHTMLAttribute><%=(String)contextObjDtlMap.get("ApprovalListOID")%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="AprListValue" value="<xss:encodeForHTMLAttribute><%=(String)contextObjDtlMap.get("ApprovalListName")%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="DistListOID" value="<xss:encodeForHTMLAttribute><%=(String)contextObjDtlMap.get("DistributionListOID")%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="DistListName" value="<xss:encodeForHTMLAttribute><%=(String)contextObjDtlMap.get("DistributionListName")%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="RevListOID" value="<xss:encodeForHTMLAttribute><%=(String)contextObjDtlMap.get("ReviewerListOID")%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="RevListName" value="<xss:encodeForHTMLAttribute><%=(String)contextObjDtlMap.get("ReviewerListName")%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="DesignRespOID" value="<xss:encodeForHTMLAttribute><%=(String)contextObjDtlMap.get("DesignRespOID")%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="DesignRespName" value="" />
	
	<input type="hidden" name="RDE" value="<xss:encodeForHTMLAttribute><%=(String)contextObjDtlMap.get("RDE")%></xss:encodeForHTMLAttribute>" />
			
	<input type="hidden" name="OBJId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="CreateMode" value="<xss:encodeForHTMLAttribute><%=strMode%></xss:encodeForHTMLAttribute>" />
	<input type="hidden" name="strMode" value="<xss:encodeForHTMLAttribute><%=strMode%></xss:encodeForHTMLAttribute>" />

<%
if (strObjectId != null) {
    if (doContextObj.isKindOf(context, DomainConstants.TYPE_ECR)) {
%>
        <input type="hidden" name="sourceECRId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
<%
    } else if (doContextObj.isKindOf(context, DomainConstants.TYPE_ECO)) {
%>
        <input type="hidden" name="sourceECOId" value="<xss:encodeForHTMLAttribute><%=strObjectId%></xss:encodeForHTMLAttribute>" />
<%
    }
}

%>

<script language="javascript">
//XSSOK
var modetype = "<xss:encodeForJavaScript><%=strMode%></xss:encodeForJavaScript>";
//XSSOK
var isNotRelease = "<%=isNotRelease%>";
//XSSOK
var ECRalertmessage = "<%=strECRalertmessage%>";
//XSSOK
var isNotProductionPart = "<%=isNotProductionPart%>";
//XSSOK
var isObsolete = "<%=isObsolete%>";
//XSSOK
var isNotInPreliminaryOrRelease = "<%=isNotInPreliminaryOrRelease%>";
//XSSOK
var ConfgPartalertmessage = "<%=strProductionPartalertmessage%>";
//XSSOK
var ObsoletePartalertmessage = "<%=strObsoletePartalertmessage%>";
//XSSOK
var ECOalertmessage = "<%=strECOalertmessage%>";
//XSSOK
var blPartsRevisionExist = "<%=partsWithRevisionExist%>";
//XSSOK
var blNoFilteredPartExist = "<%=noFilteredPartExist%>";
//XSSOK
var revisionMessege = "<%=msgLatestRev%>";
//XSSOK
var boolShowSlidin = true;
//XSSOK
document.form.DesignRespName.value = encodeURIComponent("<%=rdoName%>");
//XSSOK
var rdoId = "<%= rdoData%>";
//XSSOK
var fullSearch = "<xss:encodeForJavaScript><%=fullSearch%></xss:encodeForJavaScript>";
//XSSOK
var ECOalertmessage = "<%=strCRalertmessage%>";

if(fullSearch == "null" || fullSearch == "undefined" || fullSearch == null){
		fullSearch = false;
	}
var boolrdoIdExists = (rdoId == null || rdoId == "null") ? false : true;

if(isObsolete=='true') {
	alert(ObsoletePartalertmessage);
	parent.closeWindow();
	boolShowSlidin = false;
} else if(isNotProductionPart=='true') {
    alert(ConfgPartalertmessage);
    parent.closeWindow();
    boolShowSlidin = false;
} else {
	if(modetype!='AddToECR' && modetype!='AddToECRExisting' && isNotInPreliminaryOrRelease=='true') {
		alert(ECOalertmessage);
		parent.closeWindow();
		boolShowSlidin = false;
	} else if((modetype=='MoveToCRNew' || modetype=='MoveToCRExisting') && isNotInPreliminaryOrRelease=='true') {
		alert(ECOalertmessage);
		parent.closeWindow();
		boolShowSlidin = false;
	}  else {
		if(modetype=='AssignToECOExisting' || modetype=='MoveToECOExisting'  || modetype=='AddToECOExisting' || modetype=='MoveToCRExisting') {
			//XSSOK
                  document.form.action="<%=XSSUtil.encodeForJavaScript(context,contentURL)%>";
		}
		
		if(modetype=='AssignToECO' || modetype=='MoveToECO'  || modetype=='AddToECO') {	
			//XSSOK
			document.form.action = "../common/emxCreate.jsp?form=type_CreateECO&type=type_ECO&policy=ECO&typeChooser=true&ExclusionList=type_DECO&nameField=autoname&header=emxFramework.Shortcut.CreateECO&submitAction=refreshCaller&CreateMode="+modetype+"&suiteKey=EngineeringCentral&createJPO=emxECO:createECO&preProcessJavaScript=setCreateFormFields"+"<%=XSSUtil.encodeForJavaScript(context,dynamicUrlCreate)%>";			
		} 
		
		else if(modetype=='MoveToCRNew') {
			document.form.action="../common/emxCreate.jsp?form=type_CreateChangeRequest&header=EnterpriseChangeMgt.Command.CreateChangeRequest&type=type_ChangeRequest&nameField=autoname&createJPO=enoECMChangeOrder:createChange&preProcessJavaScript=preProcessInCreateCO&suiteKey=EnterpriseChangeMgt&postProcessJPO=emxPart:addAffectedItemstoCR&strSelectedAffectedItem="+"<%=XSSUtil.encodeForJavaScript(context,strPartId)%>"+"&strMode="+modetype+"&typeChooser=true&submitAction=treeContent&DefaultCategory=ECMCOAffectedItemsTreeCategory";			
		}
	}
	
	if(isNotRelease == "true" && (modetype=='AddToECR' || modetype=='AddToECRExisting') ) {
		alert(ECRalertmessage);
		parent.closeWindow();
		boolShowSlidin = false;
	} else {
		if(modetype=='AddToECR') {
			document.form.action="../common/emxCreate.jsp?form=type_CreateECR&type=type_ECR&policy=ECR&typeChooser=true&nameField=autoname&header=emxFramework.Shortcut.CreateECR&submitAction=refreshCaller&CreateMode="+modetype+"&suiteKey=EngineeringCentral&preProcessJavaScript=preProcessInCreateECR";
		} else if(modetype=='MoveToCRNew') {			
			document.form.action="../common/emxCreate.jsp?form=type_CreateChangeRequest&header=EnterpriseChangeMgt.Command.CreateChangeRequest&type=type_ChangeRequest&nameField=autoname&createJPO=enoECMChangeOrder:createChange&preProcessJavaScript=preProcessInCreateCO&suiteKey=EnterpriseChangeMgt&postProcessJPO=emxPart:addAffectedItemstoCR&strSelectedAffectedItem="+"<%=XSSUtil.encodeForJavaScript(context,strPartId)%>"+"&strMode="+modetype+"&typeChooser=true&submitAction=treeContent&DefaultCategory=ECMCOAffectedItemsTreeCategory";
		}

		if(modetype=='AddToECRExisting') {
			//XSSOK
                  document.form.action="<%=XSSUtil.encodeForJavaScript(context,contentURL)%>";
		}
	}
}
//363480
if (blPartsRevisionExist == 'true') {
	alert(revisionMessege);
	parent.closeWindow();
	boolShowSlidin = false;
}

if (boolrdoIdExists) { // Added for IR-108282V6R2012x
    if (blNoFilteredPartExist == 'true') {
        parent.closeWindow();
    } else {
        if (modetype == 'AssignToECO' || modetype == 'MoveToECO' || modetype == 'AddToECO' || modetype == 'AddToECR' || modetype == 'MoveToCRNew') {
            if (boolShowSlidin) {
                if (getTopWindow().getWindowOpener() != null && "emxNavigator.jsp".indexOf(getTopWindow().getWindowOpener().location)) {
                	if(modetype == 'MoveToECO'){
                		//XSSOK
                	parent.open('about:blank', 'newWin' + "<%=timeinMilli%>", 'height=550,width=850,resizable=yes');
                	}
                	else{
                		//XSSOK
                	window.open('about:blank', 'newWin' + "<%=timeinMilli%>", 'height=550,width=850,resizable=yes');	
                	}
                		//XSSOK
                    document.form.target = "newWin" + "<%=timeinMilli%>";               
                    document.form.submit();             
                } else {
                	
                	if(!fullSearch){
                	//XSSOK
                    getTopWindow().showSlideInDialog("../common/emxAEFSubmitSlideInAction.jsp?portalFrame=listHidden&url=" + encodeURIComponent(document.form.action + "&targetLocation=slidein&disableRDO=<%=disableRDOField%>"), "true");
                	
                	}
                	else
                		{
                		//XSSOK
                		showModalDialog("../common/emxAEFSubmitPopupAction.jsp?frameName=listHidden&url=" + encodeURIComponent(document.form.action + "&targetLocation=popup&disableRDO=<%=disableRDOField%>"), "600", "500");
                		
                		}
                }           
            }       
        } else {
            document.form.submit();
        }
    }
} else { // Added for IR-108282V6R2012x - Start
	//XSSOK
	alert ("<%= strDiffRDOMessage%>");
	parent.closeWindow();	
}
//Added for IR-108282V6R2012x - End
//363480
 </script>
 </form>
 </body>
</html>

