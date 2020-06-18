<%-- MoveProductConfigurationPreProcess.jsp --%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import = "com.dassault_systemes.enovia.configuration.modeler.Product"%>
<%@page import = "com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ProductConfigurationFactory"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>


<html>

<body>
<%
String strLanguage=new String();
try {
	String contextOID = emxGetParameter(request,"objectId");
	String strModelPhyId = new String();
	com.dassault_systemes.enovia.configuration.modeler.Product ModelerPrd = new com.dassault_systemes.enovia.configuration.modeler.Product(contextOID);
	Map mpModel=ModelerPrd.getModelDetails(context, null);				   		
    if(mpModel!=null && mpModel.containsKey(ConfigurationConstants.SELECT_PHYSICAL_ID)){
    	strModelPhyId=(String)mpModel.get(ConfigurationConstants.SELECT_PHYSICAL_ID);
	}
	strLanguage=context.getSession().getLanguage();
	ProductConfiguration pConf = ProductConfigurationFactory.newInstance(context);
	boolean hasCFAssociated = false;
	String strErrorMessage = new String();
	
	//check if context product is having configuration feature associated with it or not.	
	 if(ProductLineCommon.isNotNull(contextOID)){
		 try{
			 hasCFAssociated = pConf.hasConfigurationFeatures(context, contextOID);
		 }
		 catch (Exception e) {
			 strErrorMessage = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.NoConfigurationFeaturesAssociated",strLanguage);
			 throw new FrameworkException(strErrorMessage);
		 }
	 }
	if(hasCFAssociated){
		 %>
		 <script language="javascript" type="text/javaScript">
		 var submitURL="../common/emxFullSearch.jsp?objectId=<%=XSSUtil.encodeForURL(context,contextOID)%>&field=TYPES=type_ProductConfiguration:CURRENT=policy_ProductConfiguration.state_Preliminary:BASED_ON_ID!=<%=XSSUtil.encodeForURL(context,contextOID)%>:IS_TOP_LEVEL_PART_CONNECTED=false:BASED_ON_MODEL_PID=<%=XSSUtil.encodeForURL(context,strModelPhyId)%>:BASED_ON_MATURITY!=Obsolete&table=FTRSearchProductConfigurationsTable&selection=multiple&HelpMarker=emxhelpfullsearch&suiteKey=Configuration&showInitialResults=false&submitURL=../configuration/MoveProductConfigurationPostProcess.jsp?suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration";
		 showModalDialog(submitURL,575,575,"true","Large");
		 </script>
	     <%		
	} 
} 
catch (Exception ex) {
	String strException = ex.getMessage();
	    %>
	    <script language="javascript" type="text/javaScript">
	         alert("<%=XSSUtil.encodeForJavaScript(context,strException)%>");
	    </script>
	    <%
}
%>
</body>
</html>

