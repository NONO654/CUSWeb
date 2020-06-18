<%--
  ManufacturingPlanDerivationCreatePreProcess.jsp
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

<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlan"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%@page import="com.matrixone.apps.dmcplanning.ManufacturingPlanConstants"%>
<%@page import="com.matrixone.apps.dmcplanning.Product"%>


<%@page import="com.matrixone.apps.productline.DerivationUtil"%>

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
     
    String parentId = null;
    String strObjectID = emxGetParameter(request, "objectId");
	 
	String DerivationType = "Derivation";
	String heading = "DMCPlanning.Form.Heading.newDerivation";
	String formType = "CFPCreateNewManufacturingPlanForm";
	 
	ManufacturingPlan mPlan = new ManufacturingPlan();
	boolean isMPMExist = mPlan.isMPMExist(context,strObjectID);
	 
	// Context can be model/Product
	DomainObject objContext=new DomainObject(strObjectID);
	boolean isFromProductContext=false;
    isFromProductContext = objContext.isKindOf(context,ManufacturingPlanConstants.TYPE_PRODUCTS);

    boolean isRootSelected=false;
	int levelOfSelected=0;
	
    String strCannotCreateRoot = EnoviaResourceBundle.getProperty(context,
    		"DMCPlanning", "DMCPlanning.Derivation.Create.CannotCreateRoot", strLanguage);
	String strMPBreakdownSelected = EnoviaResourceBundle.getProperty(context,
			"DMCPlanning","DMCPlanning.Error.MPBreakdownSelected", strLanguage);
	String strNonMPDNonLastNodeSelected = EnoviaResourceBundle.getProperty(context,
			"DMCPlanning","DMCPlanning.Error.NonMPDNonLastNodeSelected", strLanguage);
	String strRowSelectAtleast = EnoviaResourceBundle.getProperty(context,
			"DMCPlanning","DMCPlanning.RowSelect.atleastOne", strLanguage);
	String strRowSelectSingle = EnoviaResourceBundle.getProperty(context,
			"DMCPlanning","DMCPlanning.RowSelect.Single", strLanguage);
	String strRootMPOnForwardChain = EnoviaResourceBundle.getProperty(context,
			"DMCPlanning","DMCPlanning.Error.hasRootMPOnForwardChain", strLanguage);
	String strLatestMPOnForwardChain = EnoviaResourceBundle.getProperty(context,
			"DMCPlanning","DMCPlanning.Error.hasLatestMPOnForwardChain", strLanguage);
    String strNoMPsAvailableForDerivation = EnoviaResourceBundle.getProperty(context,
    		"DMCPlanning","DMCPlanning.Error.NoMPsAvailableForDerivation", strLanguage);
	String strDefaultSymType = EnoviaResourceBundle.getProperty(context,
			"DMCPlanning.ManufacturingPlanDerivation.DefaultType");

 	if (isMPMExist) { 
        // The Root Manufacturing Plan already exists.
        if ((arrTableRowIds == null || (arrTableRowIds.length == 0)) && !isFromProductContext) {
%>
		    <script language="javascript" type="text/javaScript">
		        alert("<%=XSSUtil.encodeForJavaScript(context,strRowSelectAtleast)%>");
		    </script>
<%       
		} else if (arrTableRowIds != null && arrTableRowIds.length > 1) {
%>
			<script language="javascript" type="text/javaScript">
		        alert("<%=XSSUtil.encodeForJavaScript(context,strRowSelectSingle)%>");
		    </script> 
<%
        } else {
		    String strSymbolicName="";
			String strSelObjectID="";
			boolean hasRootMPOnForwardChain=false;
			boolean isNodeSelected=false;
			boolean isMPDEnabledLastNode=false;
			boolean hasLatestMPOnFwdChain=false;
			boolean hasAvailableDerivation = true;
			
			if ((arrTableRowIds==null || (arrTableRowIds.length == 0)) && isFromProductContext) {
			    strSymbolicName=strDefaultSymType;
				strSelObjectID=null;
			    hasRootMPOnForwardChain=new Product(strObjectID).hasRootMPOnBackwardChain(context);
			    
                // If there is no selection in the SB and we are in the Product Context, then we need to check and
                // make sure there is a Manufacturing Plan available from which to derive the new Derivation.  In other 
                // words, make sure there is at least ONE existing Manufacturing Plan (Revision or Derivation) 

                Map programMap=new HashMap();
                programMap.put("contextObjectId", strObjectID);
                String[] methodargs = JPO.packArgs(programMap);
                StringList slAvailableMPs = (StringList)JPO.invoke 
                    (context, "ManufacturingPlanSearch", null, "getManufacturingPlansForDerivationCreate", methodargs, StringList.class);
                if (slAvailableMPs.size() <= 0) {
                	hasAvailableDerivation = false;                        
                }
			} else {
				DomainObject domSelObj=null;
				isNodeSelected=true;
				StringList sl=FrameworkUtil.split(arrTableRowIds[0] , "|");
				String strLevel=sl.get(sl.size()-1).toString();
				StringList sl2=FrameworkUtil.split(strLevel , ",");
				levelOfSelected=sl2.size();
				if (sl2.size()==2) {
				    isRootSelected=true;
				}
			    arrObjIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("ObjId");
				StringTokenizer st = new StringTokenizer(arrObjIds[0],"|");
				strSelObjectID = st.nextToken();
				domSelObj=new DomainObject(strSelObjectID);
			    String strSelType=domSelObj.getInfo(context,DomainObject.SELECT_TYPE);
			    strSymbolicName = FrameworkUtil.getAliasForAdmin(context,DomainConstants.SELECT_TYPE, strSelType, true);
			}

			%>
	        <body>   
	        <form name="MPDerivationCreate" method="post">
	            <script language="Javascript">
	                var isFromProductContext=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isFromProductContext))%>;
	                var levelOfSelected=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(levelOfSelected))%>;
	                var hasRootMPOnForwardChain=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(hasRootMPOnForwardChain))%>;
	                var isNodeSelected=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isNodeSelected))%>;
	                var isMPDEnabledLastNode=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isMPDEnabledLastNode))%>;
	                var hasLatestMPOnFwdChain=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(hasLatestMPOnFwdChain))%>;
                    var hasAvailableDerivation=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(hasAvailableDerivation))%>;
	                var submitURL="";
                    if (isFromProductContext && levelOfSelected>2) {
                	    alert("<%=XSSUtil.encodeForJavaScript(context,strMPBreakdownSelected)%>");
                    } else if (!isNodeSelected && !hasRootMPOnForwardChain) {
                 	    alert("<%=XSSUtil.encodeForJavaScript(context,strRootMPOnForwardChain)%>");
                    } else if (!hasAvailableDerivation) {
                        alert("<%=XSSUtil.encodeForJavaScript(context,strNoMPsAvailableForDerivation)%>");
             	    } else {
		                if (isFromProductContext) {
		                    submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strSymbolicName)%>&typeChooser=false&autoNameChecked=false&nameField=both&vaultChooser=false&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&suiteKey=DMCPlanning&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&parentOID=<%=XSSUtil.encodeForURL(context,strObjectID)%>&objectID=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&isRootMP=false&createJPO=ManufacturingPlan:createManufacturingPlanJPO&postProcessJPO=ManufacturingPlan:createManufacturingPlan&submitAction=doNothing&preProcessJavaScript=populatefieldOnLoad&isFromProductContext=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isFromProductContext))%>&postProcessURL=../dmcplanning/ManufacturingPlanDerivationCreatePostProcess.jsp";
		                } else {
		                    submitURL = "../common/emxCreate.jsp?type=<%=XSSUtil.encodeForURL(context,strSymbolicName)%>&typeChooser=false&autoNameChecked=false&nameField=both&vaultChooser=false&form=<%=XSSUtil.encodeForURL(context,formType)%>&header=<%=XSSUtil.encodeForURL(context,heading)%>&copyObjectId=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&DerivationType=<%=XSSUtil.encodeForURL(context,DerivationType)%>&suiteKey=DMCPlanning&StringResourceFileId=dmcplanningStringResource&SuiteDirectory=dmcplanning&parentOID=<%=XSSUtil.encodeForURL(context,strObjectID)%>&objectID=<%=XSSUtil.encodeForURL(context,strSelObjectID)%>&isRootMP=false&isRootSelected=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isRootSelected))%>&createJPO=ManufacturingPlan:createManufacturingPlanJPO&postProcessJPO=ManufacturingPlan:createManufacturingPlan&submitAction=xmlMessage&preProcessJavaScript=populatefieldOnLoad&isFromProductContext=<%=XSSUtil.encodeForJavaScript(context,String.valueOf(isFromProductContext))%>&postProcessURL=../dmcplanning/ManufacturingPlanDerivationCreatePostProcess.jsp";
		                }
                        getTopWindow().showSlideInDialog(submitURL, "true");
	                }
	            </script>
	        </form>
	        </body>
<%
        } 
    } else {
        // Do not allow to create the Main Manufacturing Plan
        %>
        <script language="javascript" type="text/javaScript">
            alert("<%=XSSUtil.encodeForJavaScript(context,strCannotCreateRoot)%>");                
        </script>
        <%
    }
} catch (Exception e) {
    bIsError=true;
    session.putValue("error.message", e.getMessage());
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
