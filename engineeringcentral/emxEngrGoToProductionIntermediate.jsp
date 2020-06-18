<%--  emxEngrGoToProductionIntermediate.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>

<%@include file="../common/emxNavigatorInclude.inc"%>
<%@page import="matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="com.matrixone.apps.domain.DomainConstants" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@page import="com.matrixone.apps.engineering.EngineeringUtil" %>

<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>

<%
	String objectId = emxGetParameter(request, "objectId");	
	String mode = emxGetParameter(request, "mode");
    
    String headerStr = "emxEngineeringCentral.Common.RevisePartToProduction";    
    String helpMarker = "emxhelppartgotoproduction";    
	
	if ("partGoToProduction".equals(mode)) {
	    String createJPO = "emxPart:partGoToProductionJPO";
	    String preProcessJS = "preProcessForGoToProduction";
	    String formName = "ENCPartGoToProduction";	    
	    String SELECT_RDO_REL_EXISTS = "to[" + DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY + "]";
	    String SELECT_RDO_REL_ID = "to[" + DomainConstants.RELATIONSHIP_DESIGN_RESPONSIBILITY + "].from.id";  //Added for RDO Convergence
	
	    Map partInfoMap = (Map) JPO.invoke(context, "emxPart", null, "getPartInfo", new String[] {objectId}, Map.class);
	    
	    String srcObjType = (String) partInfoMap.get(DomainConstants.SELECT_TYPE);
		String symbolicName = com.matrixone.apps.domain.util.FrameworkUtil.getAliasForAdmin(context,"type",srcObjType,true);
	    String sName = (String) partInfoMap.get(DomainConstants.SELECT_NAME);
	    String vault = (String) partInfoMap.get(DomainConstants.SELECT_VAULT);
	    String hasRDO = (String) partInfoMap.get(SELECT_RDO_REL_EXISTS);   
	    String sRDOOID = (String) partInfoMap.get(SELECT_RDO_REL_ID);  //Added for RDO Convergence
	    
	    %>
	    <script language="Javascript">
	        //var sURL = "../common/emxCreate.jsp?&Vault=<%=vault%>&copyObjectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&form=<%=formName%>&header=<%=headerStr%>&type=<%=symbolicName%>&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&partName=<%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(sName)%>&submitAction=treeContent&createJPO=<%=createJPO%>&preProcessJavaScript=<%=preProcessJS%>&HelpMarker=<%=helpMarker%>&hasRDO=<%=hasRDO%>&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral";
	        if(findFrame(getTopWindow(),"emxUIStructureTree")) {
		        var sURL = "../common/emxCreate.jsp?&Vault=<xss:encodeForURL><%=vault%></xss:encodeForURL>&copyObjectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&form=<xss:encodeForURL><%=formName%></xss:encodeForURL>&header=<xss:encodeForURL><%=headerStr%></xss:encodeForURL>&type=<xss:encodeForURL><%=symbolicName%></xss:encodeForURL>&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&partName=<xss:encodeForURL><%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(sName)%></xss:encodeForURL>&submitAction=refreshCaller&createJPO=<xss:encodeForURL><%=createJPO%></xss:encodeForURL>&preProcessJavaScript=<xss:encodeForURL><%=preProcessJS%></xss:encodeForURL>&HelpMarker=<xss:encodeForURL><%=helpMarker%></xss:encodeForURL>&hasRDO=<xss:encodeForURL><%=hasRDO%></xss:encodeForURL>&RDOOID=<xss:encodeForURL><%=sRDOOID%></xss:encodeForURL>&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral";
	        } else  {
	        var sURL = "../common/emxCreate.jsp?&Vault=<xss:encodeForURL><%=vault%></xss:encodeForURL>&copyObjectId=<%=XSSUtil.encodeForJavaScript(context,objectId)%>&form=<xss:encodeForURL><%=formName%></xss:encodeForURL>&header=<xss:encodeForURL><%=headerStr%></xss:encodeForURL>&type=<xss:encodeForURL><%=symbolicName%></xss:encodeForURL>&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&partName=<xss:encodeForURL><%=com.matrixone.apps.domain.util.XSSUtil.encodeForURL(sName)%></xss:encodeForURL>&submitAction=treeContent&createJPO=<xss:encodeForURL><%=createJPO%></xss:encodeForURL>&preProcessJavaScript=<xss:encodeForURL><%=preProcessJS%></xss:encodeForURL>&HelpMarker=<xss:encodeForURL><%=helpMarker%></xss:encodeForURL>&hasRDO=<xss:encodeForURL><%=hasRDO%></xss:encodeForURL>&RDOOID=<xss:encodeForURL><%=sRDOOID%></xss:encodeForURL>&suiteKey=EngineeringCentral&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral";
	        }
	        getTopWindow().showSlideInDialog(sURL, true);     
	    </script>
		 <%
		 
} else if ("bomGoToProduction".equals(mode)) {
	 //headerStr  = "emxEngineeringCentral.Common.SelectECO";
	 headerStr  = "emxEngineeringCentral.Common.SelectCO";
     helpMarker = "emxhelpbomgotoproduction";
     
     try{
         //Check for BOM Go To Production conditions
        String result = EngineeringUtil.checkForBOMGoToProductionPreReqs(context, objectId);
        if (!"".equals(result)) {
            throw new FrameworkException(result); 
        }
        
        
     // Commented for TBE 2013, since TBE goto production has been replaced by ENG goto production 
	// if (EngineeringUtil.isENGSMBInstalled(context)) {
	//	 headerStr = "emxEngineeringCentral.Select.TeamECO";
    //    helpMarker = "emxhelppartgotoproduction";
	// }
	       
	 //String actionURL = "../common/emxForm.jsp?form=BOMGoToProduction&mode=edit&formHeader=" + headerStr + "&preProcessJavaScript=disableFieldsInBOMGotoProduction&suiteKey=EngineeringCentral&HelpMarker=" + helpMarker + "&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&objectId=" + objectId + "&postProcessURL=../engineeringcentral/emxEngrBOMGoToProduction.jsp";
	 String actionURL = "../common/emxForm.jsp?form=ENCBOMGoToProduction&mode=edit&formHeader=" + headerStr + "&preProcessJavaScript=disableFieldsInENCBOMGotoProduction&suiteKey=EngineeringCentral&HelpMarker=" + helpMarker + "&StringResourceFileId=emxEngineeringCentralStringResource&SuiteDirectory=engineeringcentral&objectId=" + objectId + "&postProcessURL=../engineeringcentral/emxEngrBOMGoToProduction.jsp";
%>	    
	    <script language="javascript">
	    //XSSOK
            document.location.href = "<%= XSSUtil.encodeForJavaScript(context,actionURL)%>";
	    </script>
<%
     } catch (Exception e) {
	     String errorMessage = e.getMessage();
%>
	     <script language="javascript">	     
	     //XSSOK
		     alert("<%=errorMessage%>");
		    // getTopWindow().window.close();
	       </script>
<% 
	     }
     }
%>
