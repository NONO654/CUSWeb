<%--  emxEngrBOMGoToProduction.jsp - For the BOM go to production command
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>

<%@include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil" %>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
    String objectId = emxGetParameter(request, "objectId");
    //String changeId = emxGetParameter(request, "ECOToReleaseOID");
    String changeId = emxGetParameter(request, "COToReleaseOID");
    String rdoId    = emxGetParameter(request, "DesignResponsiblityOID");
    String strECOPtions = emxGetParameter(request, "ecoOptions");
    boolean exception = false;
    
    if ("AddExisting".equals(strECOPtions)) {
        try {
            HashMap requestMap = new HashMap();
            requestMap.put("changeId", changeId);
            //requestMap.put("selectedPartId", new String[] {objectId});
            requestMap.put("selectedPartId", objectId);
            requestMap.put("RDOId", new String[]{rdoId});
            
     // Commented for TBE 2013, since TBE goto production has been replaced by ENG goto production 
     //       if (EngineeringUtil.isENGSMBInstalled(context)) {
     //           JPO.invoke(context, "emxTeamECO", null, "bomGotoProduction", JPO.packArgs (requestMap), String.class);
     //       } else {
                JPO.invoke(context, "emxECO", null, "bomGotoProduction", JPO.packArgs (requestMap), String.class);                
     //       }
        } catch (Exception ex) {            
            exception = true;
            ex.printStackTrace();
            if(ex.getMessage().contains("license")){
            	 session.setAttribute("error.message", ex.getMessage());
%>  
                 <script language="Javascript">
                     //alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.BOMGoToProductionFailed</emxUtil:i18nScript>");
                     closeWindow();
                 </script>
<%
            }
            else {
%>  
                <script language="Javascript">
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.BOMGoToProductionFailed</emxUtil:i18nScript>");
                    closeWindow();
                </script>
<%
            }

        }
        
        if(!exception) {
%>
            <script language="Javascript">
            
                alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.BOMGoToProductionSuccessful</emxUtil:i18nScript>");
                //XSSOK
                url =  "../common/emxTree.jsp?mode=insert&objectId=<%=XSSUtil.encodeForJavaScript(context,changeId)%>";                                
                var parentContentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "content");                
                parentContentFrame.location.href = url;
                
                if (getTopWindow()) {
                    getTopWindow().closeWindow();
                }                
                
            </script>    
<%
        }
    }
    
    else if("createNewCO".equals(strECOPtions)){
        //String actionURL = "../common/emxCreate.jsp?type=type_ECO&policy=policy_ECO&form=type_CreateECO&preProcessJavaScript=preProcessInCreateECO&nameField=autoname&typeChooser=false&ExclusionList=type_DECO&submitAction=treeContent&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&CreateMode=CreateECO&suiteKey=EngineeringCentral&selectedPartId=" + objectId + "&objectId="+ objectId + "&helpMarker=emxhelpecocreate&targetLocation=popup";
		String actionURL = "../common/emxCreate.jsp?type=type_ChangeOrder&policy=policy_FormalChange&form=type_CreateChangeOrderSlidein&postProcessJPO=emxECO:bomGotoProduction&preProcessJavaScript=preProcessInCreateCO&nameField=autoname&createJPO=enoECMChangeOrder:createChange&typeChooser=false&submitAction=treeContent&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=enterprisechangemgt&CreateMode=CreateCO&suiteKey=EnterpriseChangeMgt&selectedPartId=" + objectId + "&objectId="+ objectId + "&helpMarker=emxhelpchangeordercreate&targetLocation=popup&appendURL=ChangeEffectivity|EnterpriseChangeMgt&mode=create";
		
        
// Commented for TBE 2013, since TBE goto production has been replaced by ENG goto production 
//        if (EngineeringUtil.isENGSMBInstalled(context)) {
//            actionURL = "../common/emxCreate.jsp?type=type_ECO&policy=policy_TeamECO&form=type_CreateTeamECO&nameField=autoname&typeChooser=false&submitAction=treeContent&suiteKey=TeamBOMEditor&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&CreateMode=CreateECO&selectedPartId=" + objectId + "&helpMarker=emxhelpteamecocreate&preProcessJavaScript=preProcessInCreateTeamECO&targetLocation=popup";
//        }
%>
    <script language="Javascript">      
    //XSSOK
        getTopWindow().location.href = "<%= XSSUtil.encodeForJavaScript(context,actionURL)%>";
		</script>
<%  
    }
else if("createNewCR".equals(strECOPtions)){       	
		String actionURL = "../common/emxCreate.jsp?type=type_ChangeRequest&policy=policy_ChangeRequest&form=type_CreateChangeRequest&postProcessJPO=emxECO:bomGotoProduction&preProcessJavaScript=setCreateFormROField&nameField=autoname&typeChooser=false&submitAction=treeContent&suiteKey=EnterpriseChangeMgt&selectedPartId=" + objectId + "&objectId="+ objectId + "&helpMarker=emxhelpchangerequestcreate&targetLocation=popup";        
%>
    <script language="Javascript">      
    //XSSOK
        getTopWindow().location.href = "<%= XSSUtil.encodeForJavaScript(context,actionURL)%>";
    </script>
<%  
    }
%>

<%@include file = "emxDesignBottomInclude.inc"%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
