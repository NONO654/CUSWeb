<%--  emxEngrBOMGoToProductionPostProcess.jsp - For the BOM go to production command
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
    String objectId = emxGetParameter(request, "partObjectId");
    String changeId = emxGetParameter(request, "COToReleaseOID");
    String strECOPtions = emxGetParameter(request, "ecoOptions");
    String strForRevise = emxGetParameter(request, "For Revise");
    String sNextRevExists = ReleasePhaseManager.checkIfNextRevisionExistsForChild(context, objectId, strForRevise);
	String strNextRevisionAssociatedWithChildPartErrorMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource", 
	    		context.getLocale(),"ENCBOMGoToProduction.Confirm.NextRevisionAssociatedWithChildPart");
    boolean exception = false;
        
    if ("AddExisting".equals(strECOPtions)) {
        
    	try {
        	
            HashMap requestMap = new HashMap();
            requestMap.put("ChangeToReleaseOID", changeId);
            requestMap.put("partId", objectId);
            requestMap.put("strForRevise", strForRevise);
            
            
            HashMap programMap = new HashMap();
            programMap.put("requestMap", requestMap);
            
            if("NextRevExists".equalsIgnoreCase(sNextRevExists)){
%>
            <script language="Javascript">
            	alert("<%=strNextRevisionAssociatedWithChildPartErrorMsg%>");
                closeWindow();
            </script>
<%            
            return;
            }
            JPO.invoke(context, "enoBGTPManager", null, "addChange", JPO.packArgs (programMap), String.class);
            
        } 
        catch (Exception ex) {            
            exception = true;
%>  
                <script language="Javascript">
                    alert("<emxUtil:i18nScript localize="i18nId">emxEngineeringCentral.Alert.BOMGoToProductionFailed</emxUtil:i18nScript>");
                    closeWindow();
                </script>
<%
        }
        
        if(!exception) {
%>
            <script language="Javascript">         
                if (getTopWindow()) {
		//Added to fix bug # 419381 start
                	var contentFrame   = findFrame(getTopWindow().getWindowOpener(),"detailsDisplay");
            		if(!contentFrame){
            			contentFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "detailsDisplay");		
            		}
            		
            		if(contentFrame){
            			contentFrame.location.href = contentFrame.location.href;
            		}
            		else{
            			getTopWindow().getWindowOpener().parent.location.href = getTopWindow().getWindowOpener().parent.location.href;
            		}
            		
            		if (isMoz) {
        				getTopWindow().close();
        			}
        			else{
        				getTopWindow().closeWindow();
        			}
			//Added to fix bug # 419381 end
            		//getTopWindow().closeWindow();
                }                
            </script>    
<%
        }
    }
    else if("createNewCO".equals(strECOPtions)){
        //String actionURL = "../common/emxCreate.jsp?type=type_ECO&policy=policy_ECO&form=type_CreateECO&preProcessJavaScript=preProcessInCreateECO&nameField=autoname&typeChooser=false&ExclusionList=type_DECO&submitAction=treeContent&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&CreateMode=CreateECO&suiteKey=EngineeringCentral&selectedPartId=" + objectId + "&objectId="+ objectId + "&helpMarker=emxhelpecocreate&targetLocation=popup";
        //Added to fix bug # 419381 start
		//String actionURL = "../common/emxCreate.jsp?type=type_ChangeOrder&policy=policy_FormalChange&form=type_CreateChangeOrderSlidein&targetLocation=popup&postProcessJPO=enoBGTPManager:addChange&preProcessJavaScript=preProcessInCreateCO&nameField=autoname&createJPO=enoECMChangeOrder:createChange&typeChooser=false&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=enterprisechangemgt&CreateMode=CreateCO&suiteKey=EnterpriseChangeMgt&submitAction=doNothing&partId="+ objectId + "&strForRevise="+strForRevise+"&helpMarker=emxhelpchangeordercreate&targetLocation=popup&appendURL=ChangeEffectivity|EnterpriseChangeMgt&mode=create";
    	if("NextRevExists".equalsIgnoreCase(sNextRevExists)){
    		%>
    		            <script language="Javascript">
    		            	alert("<%=strNextRevisionAssociatedWithChildPartErrorMsg%>");
    		                closeWindow();
    		            </script>
    		<%            
    		            return;
    	}
		String actionURL = "../common/emxCreate.jsp?type=type_ChangeOrder&policy=policy_FormalChange&form=type_CreateChangeOrderSlidein&targetLocation=popup&postProcessJPO=enoBGTPManager:addChange&preProcessJavaScript=preProcessInCreateCO&nameField=autoname&createJPO=enoECMChangeOrder:createChange&typeChooser=false&suiteKey=EnterpriseChangeMgt&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=enterprisechangemgt&CreateMode=CreateCO&suiteKey=EnterpriseChangeMgt&submitAction=doNothing&partId="+ objectId + "&strForRevise="+strForRevise+"&helpMarker=emxhelpchangeordercreate&targetLocation=popup&mode=create&postProcessURL=../engineeringcentral/emxEngCommonRefresh.jsp&action=refreshParent";
		//Added to fix bug # 419381 end
%>
    <script language="Javascript">      
         getTopWindow().location.href = "<%= XSSUtil.encodeForJavaScript(context,actionURL)%>";
   	</script>
<%  
    }
else if("createNewCR".equals(strECOPtions)){   
	//Added to fix bug # 419381 start
		//String actionURL = "../common/emxCreate.jsp?type=type_ChangeRequest&policy=policy_ChangeRequest&form=type_CreateChangeRequest&postProcessJPO=enoBGTPManager:addChange&preProcessJavaScript=setRO&nameField=autoname&createJPO=enoECMChangeRequest:createChangeRequest&typeChooser=false&submitAction=doNothing&suiteKey=EnterpriseChangeMgt&SuiteDirectory=enterprisechangemgt&partId="+ objectId + "&strForRevise="+strForRevise+"&helpMarker=emxhelpchangerequestcreate&targetLocation=popup";
	if("NextRevExists".equalsIgnoreCase(sNextRevExists)){
		%>
		            <script language="Javascript">
		            	alert("<%=strNextRevisionAssociatedWithChildPartErrorMsg%>");
		                closeWindow();
		            </script>
		<%            
		            return;
		            }	
		String actionURL = "../common/emxCreate.jsp?type=type_ChangeRequest&policy=policy_ChangeRequest&form=type_CreateChangeRequest&postProcessJPO=enoBGTPManager:addChange&preProcessJavaScript=setRO&nameField=autoname&createJPO=enoECMChangeRequest:createChangeRequest&typeChooser=false&submitAction=doNothing&suiteKey=EnterpriseChangeMgt&SuiteDirectory=enterprisechangemgt&partId="+ objectId + "&strForRevise="+strForRevise+"&helpMarker=emxhelpchangerequestcreate&targetLocation=popup&postProcessURL=../engineeringcentral/emxEngCommonRefresh.jsp&action=refreshParent";
		//Added to fix bug # 419381 end
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
