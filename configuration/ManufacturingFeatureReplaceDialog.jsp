<%--
  ManufacturingFeatureReplaceDialog.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxProductCommonInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<html>
<%@include file="emxValidationInclude.inc"%>
<%@page import="java.util.*"%>
<%@page import="com.matrixone.apps.domain.*"%>
<%@page import="java.util.List"%>
<%@page import = "matrix.db.BusinessObject"%>
<%@page import="com.matrixone.apps.domain.util.*"%>
<%@page import="com.matrixone.apps.framework.ui.*"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants" %>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.configuration.InclusionRule"%>
<%@include file="../emxUICommonHeaderEndInclude.inc"%>
<body>
<%
String strTableRowId = emxGetParameter (request,"emxTableRowId") ;
String suiteKey = emxGetParameter (request, "suiteKey") ;
String functionality = emxGetParameter (request,"functionality") ;
String strObjectId    = emxGetParameter(request, "objectId");
String strParentOId = emxGetParameter(request, "ParentOId");

%>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>
<script type="text/javascript">
var action = "<%= XSSUtil.encodeForJavaScript(context,functionality)%>";
</script>
<%
HashMap paramMap = new HashMap();                   
String strName =  "";
String strRevision ="";
DomainObject domObject = new DomainObject(strObjectId);
strName = domObject.getInfo(context, DomainConstants.SELECT_NAME);
strRevision = domObject.getInfo(context, DomainConstants.SELECT_REVISION);
String strFullName = strName +" " + strRevision;
String type = EnoviaResourceBundle.getProperty(context,"Configuration.ManufacturingFeatureReplace.type_ManufacturingFeature");
String strReplaceFeatureTypes = EnoviaResourceBundle.getProperty(context,"eServiceSuiteConfiguration" + "." + functionality
                    + "AllowedSourceTypesForDestination."  + type);

com.matrixone.apps.common.util.FormBean formBean = new com.matrixone.apps.common.util.FormBean () ;
formBean.processForm (session, request) ;
String strObjId = null ;
    
String strProductId = emxGetParameter(request, "strProdId");
String strRelId = emxGetParameter(request, "RelId");
String strFeatureId = emxGetParameter(request, "objectId");
String strParentId = emxGetParameter(request, "parentOID");

boolean stateFrozen = false;
InclusionRule incRule = new InclusionRule();
if(strRelId!=null)
	stateFrozen = incRule.isFeatureinFrozenState(context,strRelId);
	if(stateFrozen){
	    %>
	    <script language="javascript" type="text/javaScript">
	          alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.AllProdReleased</emxUtil:i18n>");  
	          parent.closeWindow();
	    </script>
	 <%
	    
	}

DomainObject domObjForType =  new DomainObject(strFeatureId);
//String txtType = null;
//txtType = domObjForType.getInfo(context,DomainConstants.SELECT_TYPE);
BusinessObject bus = domObjForType.getLastRevision(context);
DomainObject higherRevDom = new DomainObject(bus);
StringList slSelectable = new StringList(ConfigurationConstants.SELECT_NAME);
                        slSelectable.add(ConfigurationConstants.SELECT_REVISION);
                        slSelectable.add(ConfigurationConstants.SELECT_ID);
Map higherRevInfo = higherRevDom.getInfo(context, slSelectable);
String strHigherRevName = (String)higherRevInfo.get(ConfigurationConstants.SELECT_NAME);
String strHigherRevRevision = (String)higherRevInfo.get(ConfigurationConstants.SELECT_REVISION);
String strHigherRevID = (String)higherRevInfo.get(ConfigurationConstants.SELECT_ID);
if(strHigherRevID!=null && strHigherRevID.equals(strFeatureId)){
    strHigherRevName = "";
    strHigherRevID = "";
}
else{
    strHigherRevName = strHigherRevName + " Rev. " + strHigherRevRevision;
}
%>
<script type="text/javascript">
   var objID = "<%= XSSUtil.encodeForJavaScript(context,strObjId)%>";
</script>

<form name="ReplaceManufacturingFeature" method="post" action=javascript:moveNext()><input type="hidden" name="sourceObjectId" value="<xss:encodeForHTML><%=strObjectId %></xss:encodeForHTML>" />
<%@include file = "../common/enoviaCSRFTokenInjection.inc" %>
<table border="0" cellpadding="5" cellspacing="2" width="100%" >
    <%-- Display the input fields. --%>
    <tr>
        <td width="150" nowrap="nowrap" class="label"><emxUtil:i18nScript localize="i18nId">emxProduct.Form.Label.SelectedItem</emxUtil:i18nScript></td>
        <td nowrap="nowrap" class="field"><%=strFullName%><input type="hidden" name="sourceFeature" value="<xss:encodeForHTML><%=strFullName %></xss:encodeForHTML>"/></td>
    </tr>    
    
    <tr>
        <td width="150" nowrap="nowrap" class="labelRequired"><emxUtil:i18n
            localize='i18nId'>emxConfiguration.Replace.Destination</emxUtil:i18n>
        </td>       

        <td nowrap="nowrap" class="field">
			<input type="text" id="txtSourceObject" name="txtSourceObject" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strHigherRevName %></xss:encodeForHTMLAttribute>"/> 
			<input type="hidden" id="txtToFeatureId" name="txtToFeatureId" value="<xss:encodeForHTML><%=strHigherRevID %></xss:encodeForHTML>"/> 
        <input class="button" type="button" name="btnProduct" size="200" value="..." alt="" onClick="javascript:showProductChooser()"/></td>
    </tr>
</table>
</form>
<script language="javascript" type="text/javaScript">
  //<![CDATA[
    var  formName = document.ReplaceManufacturingFeature;

 function showProductChooser()
 {
        showModalDialog('../common/emxFullSearch.jsp?field=TYPES=<%=XSSUtil.encodeForURL(context,strReplaceFeatureTypes.toString())%>:CURRENT!=policy_ManufacturingFeature.state_Obsolete&excludeOID=<%=XSSUtil.encodeForURL(context,strProductId)%>,<%=XSSUtil.encodeForURL(context,strFeatureId)%>&table=FTRLogicalFeatureSearchResultsTable&showInitialResults=false&Registered Suite=Configuration&selection=single&formInclusionList=DISPLAY_NAME&showSavedQuery=true&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../configuration/SearchUtil.jsp?mode=Chooser&chooserType=CustomChooser&excludeOIDprogram=ManufacturingFeature:excludeManufacturingFeature&fieldNameActual=txtToFeatureId&fieldNameDisplay=txtSourceObject&excludeOID=<%=XSSUtil.encodeForURL(context,strObjectId)%>&strProductId=<%=XSSUtil.encodeForURL(context,strProductId)%>',850,630); 
 }

    //when 'Cancel' button is pressed in Dialog Page
 function closeWindow()
 {
    parent.window.closeWindow();
 }
    
   function submitForm()
   {
       submit();
   }

   
    function submit()
    {
    	var strObjectID = "<%= XSSUtil.encodeForJavaScript(context,strObjectId )%>";
    	var strProductID = "<%=XSSUtil.encodeForJavaScript(context,strProductId )%>";
    	var strRelID = "<%= XSSUtil.encodeForJavaScript(context,strRelId)%>";
    	var strFeatureID = "<%= XSSUtil.encodeForJavaScript(context,strFeatureId )%>";
    	var strParentID = "<%= XSSUtil.encodeForJavaScript(context,strParentId )%>";    	
    	var strId = formName.txtToFeatureId.value;
    	formName.action="../configuration/ManufacturingFeatureReplacePostProcess.jsp?objectId="+strObjectID+"&objectIdTobeconnected="+strId+"&strProdId="+strProductID+"&RelId="+strRelID+"&strParentId="+strParentID;
        
    	formName.submit();
        
    }
  //]]>
  </script>
  </body>
  </html>
