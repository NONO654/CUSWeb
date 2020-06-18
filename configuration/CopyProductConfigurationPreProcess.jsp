<%-- CopyProductConfigurationPreProcess.jsp --%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import = "com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ProductConfigurationFactory"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>

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
		 var submitURL="../common/emxFullSearch.jsp?objectId=<%=XSSUtil.encodeForURL(context,contextOID)%>&field=TYPES=type_ProductConfiguration&table=FTRSearchProductConfigurationsTable&selection=multiple&HelpMarker=emxhelpfullsearch&suiteKey=Configuration&showInitialResults=false&submitURL=../configuration/CopyProductConfigurationPostProcess.jsp?suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration";
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

