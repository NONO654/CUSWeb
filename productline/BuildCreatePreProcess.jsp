 <%-- BuildCreatePreProcess.jsp

   (c) Dassault Systemes, 1993-2018.  All rights reserved.

--%>

<%@page import="com.matrixone.apps.productline.ProductLineConstants"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUISlideIn.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<%	
try{
    
    StringBuffer contentBuffer = new StringBuffer();
	String actionMode = (String)emxGetParameter(request,"mode");
	String suiteKey = XSSUtil.encodeForJavaScript(context, (String)emxGetParameter(request,"suiteKey"));
	String StringResourceFileId = XSSUtil.encodeForJavaScript(context, (String)emxGetParameter(request,"StringResourceFileId"));
	String SuiteDirectory = XSSUtil.encodeForJavaScript(context, (String)emxGetParameter(request,"SuiteDirectory"));
	String timeStamp = (String)emxGetParameter(request,"timeStamp");
	String uiType = (String)emxGetParameter(request,"uiType");
	String objectId = (String)emxGetParameter(request,"objectId");
	String parentOID = (String)emxGetParameter(request,"parentOID");
	
	String contentURL="";
	boolean proceed = true;
	DomainObject parentObj = new DomainObject(parentOID);
	if(parentObj.isKindOf(context, ProductLineConstants.TYPE_PRODUCT_CONFIGURATION)){
		String productId = parentObj.getInfo(context, "to[" + ProductLineConstants.RELATIONSHIP_PRODUCT_CONFIGURATION +"].from.id");
		String alertMessage = EnoviaResourceBundle.getProperty(context , "emxProductLineStringResource", context.getLocale(),"emxProduct.Alert.BuildCannotBeAssigned");
		if(productId == null || "".equals(productId)){
			proceed = false;
%>
	<script language="javascript">
			alert("<%=alertMessage%>");
	</script>
<%		}
	}
	if(proceed){
		if(actionMode.equalsIgnoreCase("CreateNew")) {
			contentBuffer.append("../common/emxCreate.jsp?type=type_HardwareBuild,type_Builds&autoNameChecked=true&typeChooser=true&nameField=both&vaultChooser=true&form=PLCCreateBuildFormProductProductConfigurationContext&header=emxProduct.Heading.BuildCreate&HelpMarker=emxhelpbuildcreate&createContext=SummaryPage&targetLocation=slidein&multiBuildCreation=true&relationship=null&postProcessURL=../productline/BuildCreatePostProcess.jsp&fromContext=UnitContext");
			contentBuffer.append("&suiteKey=");
			contentBuffer.append(suiteKey);
			contentBuffer.append("&StringResourceFileId=");
			contentBuffer.append(StringResourceFileId);
			contentBuffer.append("&SuiteDirectory=");
			contentBuffer.append(SuiteDirectory);
			contentBuffer.append("&timeStamp=");
			contentBuffer.append(timeStamp);
			contentBuffer.append("&uiType=");
			contentBuffer.append(uiType);
			contentBuffer.append("&parentOID=");
			contentBuffer.append(parentOID);
			contentBuffer.append("&objectId=");
			contentBuffer.append(objectId);
 %>
     	<script language="javascript">
	   		getTopWindow().showSlideInDialog("<%=XSSUtil.encodeForJavaScript(context, contentBuffer.toString())%>", true);
	 	</script>
<%		} else if(actionMode.equalsIgnoreCase("AddExisting")) {
			contentBuffer.append("../common/emxFullSearch.jsp?field=TYPES=type_Builds&excludeOIDprogram=emxPLCCommon:filterRelatedBuilds&table=PLCSearchBuildConfigurationTable&selection=multiple&hideHeader=true&HelpMarker=emxhelpfullsearch&submitAction=refreshCaller&submitURL=../productline/SearchUtil.jsp?mode=AddExisting&relName=relationship_ProductConfigurationBuild&from=false&isUNTOper=true");
			contentBuffer.append("&uiType=");
			contentBuffer.append(uiType);
			contentBuffer.append("&parentOID=");
			contentBuffer.append(parentOID);
			contentBuffer.append("&objectId=");
			contentBuffer.append(objectId);
%>
		<script language = "javascript">
			//showSearch("<%=XSSUtil.encodeForJavaScript(context,contentBuffer.toString())%>");
			showModalDialog("<%=XSSUtil.encodeForJavaScript(context,contentBuffer.toString())%>", 700, 500,true,'Medium');
	    	this.window.closeWindow();
	    </script>
<%		}
	}
}catch(Exception ex) {
    String strExceptionMsg = ex.getMessage();
    %>
    <script language="javascript">
    alert("<%=XSSUtil.encodeForJavaScript(context, strExceptionMsg)%>");
    this.window.closeWindow();
    </script>
    <%    
}
%>
