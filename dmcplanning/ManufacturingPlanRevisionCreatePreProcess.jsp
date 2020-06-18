<%--
  ManufacturingPlanRevisionCreatePreProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "DMCPlanningCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.Hashtable"%>
<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanUtil"%>


<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.dmcplanning.Product"%>


<%@page import="com.matrixone.apps.productline.DerivationUtil"%>


<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

                   
<%
boolean bIsError = false;
String action = "";
String msg = "";

try
{   
    String strLanguage = context.getSession().getLanguage();      
    String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
    String arrTableRowIdActual[] = emxGetParameterValues(request, "emxTableRowIdActual");
     
    String arrObjIds[] = null;
     
    String strObjectID = null;
    strObjectID  = emxGetParameter(request, "objectId"); 
    String parentId = null;
     
    String DerivationType = "Revision";
    String heading = "DMCPlanning.Form.Heading.newRevision";
    String formType = "CFPCreateNewManufacturingPlanForm";
    String helpMarker = "emxhelpMPderivationcreatenew";
    
    ManufacturingPlan mPlan = new ManufacturingPlan();
    boolean isMPMExist = mPlan.isMPMExist(context,strObjectID);
     
    // Context can be model/Product
    DomainObject objContext=new DomainObject(strObjectID);
    boolean isFromProductContext=false;
    int levelOfSelected = 0;
    isFromProductContext = objContext.isKindOf(context,ManufacturingPlanConstants.TYPE_PRODUCTS);
    
    String strMPBreakdownSelected = EnoviaResourceBundle.getProperty(context,
    		"DMCPlanning","DMCPlanning.Error.MPBreakdownSelected", strLanguage);
    String strRowSelectSingle =EnoviaResourceBundle.getProperty(context,
    		"DMCPlanning","DMCPlanning.RowSelect.Single", strLanguage);
    String strCannotCreateRevision = EnoviaResourceBundle.getProperty(context,
    		"DMCPlanning","DMCPlanning.Derivation.Create.CannotCreateRevision", strLanguage);
    String strNoMPsAvailableForRevision = EnoviaResourceBundle.getProperty(context,
    		"DMCPlanning","DMCPlanning.Error.NoMPsAvailableForRevision", strLanguage);
    String strLatestMPNotInBackwardChain = EnoviaResourceBundle.getProperty(context,
			"DMCPlanning","DMCPlanning.Error.LatestMPNotInBackwardChain", strLanguage);
    String strDefaultSymType = EnoviaResourceBundle.getProperty(context,
    		"DMCPlanning.ManufacturingPlanDerivation.DefaultType");
    boolean isRootSelected=false;


    if (isMPMExist) { 
       if (arrTableRowIds != null && arrTableRowIds.length > 1) {
%>
            <script language="javascript" type="text/javaScript">
                alert("<%=XSSUtil.encodeForJavaScript(context,strRowSelectSingle)%>");
            </script> 
<%
        } else {
        	String strSymbolicName = "";
            String strSelObjectID = "";
            boolean isNodeSelected = false;
            boolean hasRevision = false;
            String strLevel = "";
            boolean hasAvailableRevision = true;
            DomainObject domSelObj = null;
            boolean isAutoRevision = false;
            boolean hasLatestMPInBackwardChain = true;
            
            if (arrTableRowIds == null || arrTableRowIds.length == 0) {
                strSelObjectID = mPlan.getLatestManufacturingPlanId(context, strObjectID);
                strLevel = "0,0";
                isRootSelected=true;
                isAutoRevision = true;
                
                if(isFromProductContext)
                {
                	hasLatestMPInBackwardChain = new Product(strObjectID).hasLatestMPInBackwardChain(context, strSelObjectID);
                }
            } else {
                isNodeSelected = true;
                StringList sl = FrameworkUtil.split(arrTableRowIds[0] , "|");
                strLevel = sl.get(sl.size()-1).toString();
                StringList sl2 = FrameworkUtil.split(strLevel , ",");
                levelOfSelected = sl2.size();
                if (sl2.size() == 2) {
                    isRootSelected=true;
                }
                arrObjIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("ObjId");
                StringTokenizer st = new StringTokenizer(arrObjIds[0],"|");
                strSelObjectID = st.nextToken();
            }
            domSelObj = new DomainObject(strSelObjectID);
            String strSelType = domSelObj.getInfo(context,DomainObject.SELECT_TYPE);
            strSymbolicName = FrameworkUtil.getAliasForAdmin(context,DomainConstants.SELECT_TYPE, strSelType, true);
                
            // Find out of the strSelObjectID already has a child Revision
            if (!DerivationUtil.isLastNodeInRevisionChain(context, strSelObjectID)) {
             	hasRevision = true;
            }

%>
            <body>   
            <form name="MPDerivationCreate" method="post">
                <script language="Javascript">
                    var isFromProductContext=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isFromProductContext))%>;
                    //XSSOK
                    var levelOfSelected=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(levelOfSelected))%>;
                    var isNodeSelected=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isNodeSelected))%>;
                    var hasRevision=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(hasRevision))%>;
                    var hasAvailableRevision=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(hasAvailableRevision))%>;
                    //XSSOK
                    var hasLatestMPInBackwardChain=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(hasLatestMPInBackwardChain))%>;
                    var submitURL="";
                    if (isFromProductContext && isNodeSelected && levelOfSelected > 2) {
                        alert("<%=XSSUtil.encodeForJavaScript(context,strMPBreakdownSelected)%>");
                    } else if (hasRevision) {
                        alert("<%=XSSUtil.encodeForJavaScript(context,strCannotCreateRevision)%>");
                    } else if (!hasAvailableRevision) {
                        alert("<%=XSSUtil.encodeForJavaScript(context,strNoMPsAvailableForRevision)%>");
                    }else if( ! hasLatestMPInBackwardChain ){
                  	  alert("<%=XSSUtil.encodeForJavaScript(context,strLatestMPNotInBackwardChain)%>");
                    } else {
                        if (isFromProductContext) {
                            submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strSymbolicName)%>&typeChooser=false&autoNameChecked=false&nameField=both&vaultChooser=false&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&suiteKey=DMCPlanning&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&parentOID=<%=XSSUtil.encodeForURL(context,strObjectID)%>&objectID=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&derivedToLevel=<%=XSSUtil.encodeForURL(context,strLevel)%>&isRootMP=false&isAutoRevision=<%=XSSUtil.encodeForURL(context,String.valueOf(isAutoRevision))%>&createJPO=ManufacturingPlan:createManufacturingPlanJPO&postProcessJPO=ManufacturingPlan:createManufacturingPlan&submitAction=doNothing&preProcessJavaScript=populatefieldOnLoad&isFromProductContext=<%=XSSUtil.encodeForURL(context,String.valueOf(isFromProductContext))%>&postProcessURL=../dmcplanning/ManufacturingPlanRevisionCreatePostProcess.jsp&HelpMarker=<%=XSSUtil.encodeForURL(context,helpMarker)%>";
                        } else {
                            submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strSymbolicName)%>&typeChooser=false&autoNameChecked=false&nameField=both&vaultChooser=false&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&suiteKey=DMCPlanning&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&parentOID=<%=XSSUtil.encodeForURL(context,strObjectID)%>&objectID=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&derivedToLevel=<%=XSSUtil.encodeForURL(context,String.valueOf(strLevel))%>&isRootMP=false&isAutoRevision=<%=XSSUtil.encodeForURL(context,String.valueOf(isAutoRevision))%>&isRootSelected=<%=XSSUtil.encodeForURL(context,String.valueOf(isRootSelected))%>&createJPO=ManufacturingPlan:createManufacturingPlanJPO&postProcessJPO=ManufacturingPlan:createManufacturingPlan&submitAction=xmlMessage&preProcessJavaScript=populatefieldOnLoad&isFromProductContext=<%=XSSUtil.encodeForURL(context,String.valueOf(isFromProductContext))%>&postProcessURL=../dmcplanning/ManufacturingPlanRevisionCreatePostProcess.jsp&HelpMarker=<%=XSSUtil.encodeForURL(context,helpMarker)%>";
                        }
                        getTopWindow().showSlideInDialog(submitURL, "true");
                    }
                </script>
            </form>
            </body>
<%
        } 
    } else {
        // Create the Root Manufacturing Plan 
%> 
        <body>   
            <form name="MPDerivationCreate" method="post">
                <script language="Javascript">
                    var submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strDefaultSymType)%>&typeChooser=false&autoNameChecked=true&nameField=both&vaultChooser=false&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&suiteKey=DMCPlanning&StringResourceFileId=dmcplanningStringResource&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&SuiteDirectory=dmcplanning&parentOID=<%=XSSUtil.encodeForURL(context,strObjectID)%>&objectID=null&isRootMP=true&isAutoRevision=false&createJPO=ManufacturingPlan:createManufacturingPlanJPO&postProcessJPO=ManufacturingPlan:createManufacturingPlan&submitAction=refreshCaller&HelpMarker=<%=XSSUtil.encodeForURL(context,helpMarker)%>";
                    getTopWindow().showSlideInDialog(submitURL, "true");
                </script>
            </form>
        </body>
<%

    }
} catch (Exception e) {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
