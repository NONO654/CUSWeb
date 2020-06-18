<%-- ProductConfigurationCreateNextProcess.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/configuration/ProductConfigurationUtil.jsp 1.70.2.7.1.2.1.1 Wed Dec 17 12:39:33 2008 GMT ds-dpathak Experimental$: ProductConfigurationUtil.jsp";
--%>
<%-- Common Includes --%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>

<%@ page import="com.matrixone.apps.domain.*" %>
<%@ page import="com.matrixone.apps.productline.*" %>
<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>
<%@page import = "matrix.util.StringList"%>
<%@page import="com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="javax.json.*" %>

<script language="javascript" type="text/javascript"
    src="../components/emxComponentsJSFunctions.js"></script>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>    
<SCRIPT language="javascript" src="../common/scripts/emxUIJson.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICalendar.js"></SCRIPT>

<HTML>
    	    <BODY class="white" onload=loadUtil()>
    	    <FORM name="ProductConfigurationOptions" method="post" >    	    
    	      <INPUT type="hidden" name="forNetscape" >
    	      <input type="hidden" name="txtParentFrameUrl" id="txtParentFrameUrl" value="" />
    	      <input type="hidden" name="txtProductConfigurationDescription" id="txtProductConfigurationDescription" value="" />
    	        &nbsp;
    	    </FORM>
    	    </BODY>
    	     </HTML>
    	     
<%
String fromcontext = "";
try
{
String strMode           = emxGetParameter(request, "mode");


if(strMode.equals("checkForDuplicatePCName"))
{
	MapList lstPCList = null;
	String strName = emxGetParameter(request, "name");
	if(strName != null && !strName.trim().isEmpty())
	{
	StringBuffer whereCondition = new StringBuffer();
    whereCondition.append("name");
    whereCondition.append("==\""+strName+"\"");
    
    StringList objectList= new StringList(DomainConstants.SELECT_ID);
    
    
	    lstPCList =(MapList) DomainObject.findObjects(
            context,
            ProductLineConstants.TYPE_PRODUCT_CONFIGURATION,
            DomainConstants.QUERY_WILDCARD,
            whereCondition.toString(),
            objectList);
    
	}
  //JSONObject dupInfo = new JSONObject();
  JsonObjectBuilder dupJsonObjBuild = Json.createObjectBuilder();
  
  if(lstPCList==null || lstPCList.size()>0)
       //dupInfo.put("duplicate", true);
	  dupJsonObjBuild.add("duplicate", true);
  else
      //dupInfo.put("duplicate", false);
	  dupJsonObjBuild.add("duplicate", false);
  JsonObject dupInfo = dupJsonObjBuild.build();  
  out.clear();
  out.write(dupInfo.toString());
  out.flush();
}

else if(strMode.equals("toplevelPartRel"))
{
	
	String toplevelPart = emxGetParameter(request, "toplevelpartid");
	String topLevelRel = ConfigurationConstants.EMPTY_STRING;
	
	if(toplevelPart != null && !toplevelPart.trim().isEmpty())
	{
		DomainObject domPart = new DomainObject(toplevelPart);
		 topLevelRel  = domPart.getInfo(context,"to["+ ConfigurationConstants.RELATIONSHIP_TOP_LEVEL_PART+"]");
    
	}
  //JSONObject jsonTopLevel = new JSONObject();
  JsonObjectBuilder topLevelJsonObjBuild = Json.createObjectBuilder();
  
  if(topLevelRel.equalsIgnoreCase("true"))
	  //jsonTopLevel.put("toplevel", true);
	  topLevelJsonObjBuild.add("toplevel", true);
  else
	  //jsonTopLevel.put("toplevel", false);
	  topLevelJsonObjBuild.add("toplevel", false);
  JsonObject jsonTopLevel = topLevelJsonObjBuild.build();	  
  out.clear();
  out.write(jsonTopLevel.toString());
  out.flush();
}
else if(strMode.equals("getModelID"))
{
	String strModelId ="";
	String txtBasedONID = emxGetParameter(request, "txtBasedONID");
	if(txtBasedONID != null && !txtBasedONID.trim().isEmpty())
	{
		StringList strModelSelect = new StringList();
		strModelSelect.addElement("to["+ConfigurationConstants.RELATIONSHIP_MAIN_PRODUCT+"].from.id");
    	strModelSelect.addElement("to["+ConfigurationConstants.RELATIONSHIP_PRODUCTS+"].from.id");
    	strModelSelect.addElement(ConfigurationConstants.SELECT_TYPE);
    	
    	Map modelDetails = (Map)(new DomainObject(txtBasedONID)).getInfo(context,strModelSelect);
    	String strType = (String)modelDetails.get(DomainObject.SELECT_TYPE);
    	
		if(mxType.isOfParentType(context,strType,ConfigurationConstants.TYPE_PRODUCTS)){
        	strModelId = (String)modelDetails.get("to["+ConfigurationConstants.RELATIONSHIP_MAIN_PRODUCT+"].from.id");
        	if(strModelId==null || strModelId.equals("")){
        		strModelId = (String)modelDetails.get("to["+ConfigurationConstants.RELATIONSHIP_PRODUCTS+"].from.id");
        	}
		}
	}
  //JSONObject modelIDJSON = new JSONObject();
  JsonObjectBuilder modelIDJSONObjBuild = Json.createObjectBuilder();
  modelIDJSONObjBuild.add("strModelId", strModelId);
  JsonObject modelIDJSON = modelIDJSONObjBuild.build();
  //modelIDJSON.put("strModelId", strModelId);
  out.clear();
  out.write(modelIDJSON.toString());
  out.flush();
}
else
{
	ENOCsrfGuard.validateRequest(context, session, request, response);
	String strName           = emxGetParameter(request, "txtProductConfigurationName");
	String strMarketingName  = emxGetParameter(request, "txtProductConfigurationMarketingName");
	String strMarketingText  = emxGetParameter(request, "txtProductConfigurationMarketingText");
	fromcontext  = emxGetParameter(request, "fromcontext");
	//strName = hiddenPCName;
	String strRevision       = emxGetParameter(request, "hidDefaultRevision");
	String strDescription    = emxGetParameter(request, "txtProductConfigurationDescription");
	String strDerivedFromId  = emxGetParameter(request, "derivedFromId");
	String strPolicy         = emxGetParameter(request, "txtProductConfigurationPolicy");
	String strVault          = emxGetParameter(request, "txtProductConfigurationVault");
	String strOwner          = emxGetParameter(request, "txtProductConfigurationOwner");
	String strSalesIntent    = emxGetParameter(request, "radProductConfigurationSalesIntentValue");
	String strPurpose        = emxGetParameter(request, "radProductConfigurationPurposeValue");
	String strStartEffectivityDate    = emxGetParameter(request, "txtStartEffectivity");
	
	String strStartEffectivityDateValue    = emxGetParameter(request, "txtStartEffectivity_msvalue");
	String strEndEffectivityDateValue        = emxGetParameter(request, "txtEndEffectivity_msvalue");
	
	
	String strMilestoneId      = emxGetParameter(request, "strMilestoneId");	

	String topLevelPart      = emxGetParameter(request, "topLevelPart");
	String strParentProductId      = emxGetParameter(request, "strProductContextId");
	String contextId               = emxGetParameter(request, "hidProductId");
	String refineSelMode  = 	(String)EnoviaResourceBundle.getProperty(context,"emxConfiguration.Configurator.RefineSelectionMode");
	DomainObject domObject = new DomainObject(contextId);
	String strObjType = domObject.getInfo(context,DomainConstants.SELECT_TYPE);
	//if(mxType.isOfParentType(context,strObjType,com.matrixone.apps.configuration.ConfigurationConstants.TYPE_PRODUCTS)){
	//	strParentProductId="";	
	//}
    	
		    String pcCreateMode =  EnoviaResourceBundle.getProperty(context,"emxConfiguration.ProductConfiguration.UIMode");
	       
			String applyURL = "ProductConfigurationCreateProcess.jsp?mode=Apply";
	
    	   ProductConfiguration pConf = (ProductConfiguration)session.getAttribute("productconfiguration");
    	   if(pConf != null)
    		   {
          String prevDervdFrmId = pConf.getDerivedFromId();
          String prevStartEffectivity = pConf.getStartEffectivity();
          String prevEndEffectivity = pConf.getEndEffectivity();
          
   		  pConf.setContextId(contextId);
          pConf.setParentProductId(strParentProductId);
               pConf.setName(strName);
               pConf.setMarketingName(strMarketingName);
               pConf.setMarketingText(strMarketingText);
               pConf.setRevision(strRevision);
               pConf.setDescription(strDescription);
               pConf.setDerivedFromId(strDerivedFromId);
               pConf.setTopLevelPart(topLevelPart);
               pConf.setPolicy(strPolicy);
               pConf.setParentProductId(strParentProductId);
               pConf.setVault(strVault);
               pConf.setOwner(strOwner);
               pConf.setSalesIntent(strSalesIntent);
               pConf.setPurpose(strPurpose);
               pConf.setStartEffectivity(context,strStartEffectivityDate,ProductConfiguration.ACTION_PC_CREATE);
               pConf.set_MILESTONE(strMilestoneId);
               
               String newStartEffectivity = pConf.getStartEffectivity();
               
			   if (pcCreateMode != null && !"Solver".equals(pcCreateMode)) {
               if( ! strDerivedFromId.equals(prevDervdFrmId) || 
	            		   ! newStartEffectivity.equals(prevStartEffectivity))
               {
    		   if(pConf.getContextId() == null || !pConf.getParentProductId().equalsIgnoreCase(strParentProductId)
    				   || fromcontext.equalsIgnoreCase("fromProductConfiguration") || strStartEffectivityDate != null)
    		   {
    			   pConf.clearStructure();
    			   pConf.loadContextStructure(context, contextId, strParentProductId);
    		   }
    		   pConf.loadSelectedOptions(context);
               }    		   
			   		}
    		   }
    		   
    	   %>
    	   

    	  <SCRIPT language="javascript" type="text/javaScript">

    	    function loadUtil() {
    	    	<% if(pcCreateMode == null || !"Solver".equals(pcCreateMode))
                 {
    	    	%>

            	var formName = document.ProductConfigurationOptions;
    	        formName.target= "_self";
                formName.action="ProductConfigurationFS.jsp?FSmode=featureSelect&PRCFSParam2=createNew&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&functionality=ProductConfigurationCreateFlatViewContentFSInstance&relId=&suiteKey=Configuration&startEffDate=<%=XSSUtil.encodeForURL(context,strStartEffectivityDateValue)%>&fromcontext=<%=XSSUtil.encodeForURL(context,fromcontext)%>&applyURL=<%=XSSUtil.encodeForURL(context,applyURL)%>";
    	        formName.submit();
    	        
    	    	<%
                 }
    	    	 else
    	    	 {
    	    		 String Directory = (String)EnoviaResourceBundle.getProperty(context,"eServiceSuiteConfiguration.Directory");
    	    		 String strHelpMarker = "emxhelpproductconfigurationcreate";
    	    	%>
    	    	
                    //storing description in local storage as it could be very large data. 
                    var desc = "<%= XSSUtil.encodeForURL(context, strDescription) %>";
                    localStorage.setItem("desc", desc);
    	    		document.ProductConfigurationOptions.txtParentFrameUrl.value = "<%=emxGetParameter(request, "txtParentFrameUrl")%>";
    	    		
               var appendParams = "contextId=" + '<%= XSSUtil.encodeForURL(context, contextId) %>' + "&strAction=create&txtProductConfigurationName="+ '<%= XSSUtil.encodeForURL(context, strName ) %>' + "&txtProductConfigurationMarketingName=" + '<%= XSSUtil.encodeForURL(context, strMarketingName) %>' +
	    		 "&txtProductConfigurationMarketingText=" +  '<%= XSSUtil.encodeForURL(context, strMarketingText) %>' + "&fromcontext=" + '<%= XSSUtil.encodeForURL(context, fromcontext)%>'  +
	    		 "&hidDefaultRevision=" + '<%= XSSUtil.encodeForURL(context, strRevision) %>' +
	    		 "&derivedFromId="+'<%= XSSUtil.encodeForURL(context, strDerivedFromId) %>'  + "&txtProductConfigurationPolicy=" + '<%=  XSSUtil.encodeForURL(context, strPolicy) %>' + "&txtProductConfigurationVault="+ '<%= XSSUtil.encodeForURL(context, strVault) %>' +"&txtProductConfigurationOwner="+ '<%=  XSSUtil.encodeForURL(context, strOwner) %>'+ 
	    		"&radProductConfigurationSalesIntentValue="+ '<%= XSSUtil.encodeForURL(context, strSalesIntent) %>' +"&radProductConfigurationPurposeValue="+ '<%= XSSUtil.encodeForURL(context, strPurpose) %>' +"&txtStartEffectivity="+ '<%= XSSUtil.encodeForURL(context, strStartEffectivityDate) %>' + "&txtStartEffectivity_msvalue="+ '<%= XSSUtil.encodeForURL(context,  strStartEffectivityDateValue) %>'  + "&strMilestoneId="+ '<%= XSSUtil.encodeForURL(context,  strMilestoneId) %>' + "&topLevelPart="+ '<%= XSSUtil.encodeForURL(context, topLevelPart) %>' +"&strProductContextId="+ '<%= XSSUtil.encodeForURL(context, strParentProductId) %>' +"&refineSelMode="+ '<%= XSSUtil.encodeForURL(context, refineSelMode) %>' +"&SuiteDirectory="+ '<%= Directory %>' +"&HelpMarker="+ '<%= strHelpMarker %>';
    	    	 
    	    	 
	            	var formName = document.ProductConfigurationOptions;
	    	        formName.target= "_self";
	                formName.action="ProductConfiguratorFS.jsp?"+appendParams;
	    	        formName.submit();
    	    	<%
    	    	}
    	    	%>
    	    }
    	    </SCRIPT>
<%}
}
catch(Exception ex)
{%>
	<script language="javascript" type="text/javaScript">
    alert("<%=XSSUtil.encodeForJavaScript(context,ex.getMessage())%>");    
    var formName = getTopWindow().document.forms['ProductConfigurationOptions'];
    formName.target= "_self"; 
    //Modified the parameters for 	IR-182729V6R2014
    formName.action="../components/emxCommonFS.jsp?StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=product&functionality=ProductConfigurationCreateFlatViewFSInstance&relId=&suiteKey=Configuration&PRCFSParam1=ProductConfiguration&PRCFSParam3=getfromsession&fromcontext=<%=XSSUtil.encodeForURL(context,fromcontext)%>";
	//End of 	IR-182729V6R2014
 	formName.submit();
    

</script>
<%ex.printStackTrace();}
%>

