<%-- EffectivityDefinitionDialog.jsp

   Copyright (c) 1999-2015 Dassault Systemes.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>
<%@page import = "com.matrixone.apps.domain.util.PersonUtil"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainRelationship"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "matrix.db.Context"%>
<%@page import = "java.util.List"%>
<%@page import = "matrix.db.JPO"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import = "matrix.util.StringList"%>
<%@page import = "java.util.HashMap"%>
<%@page import = "java.util.Vector"%>
<%@page import = "java.util.Map"%> 
   
<%@page import = "java.util.ArrayList"%>
<%@page import = "java.util.Locale"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkProperties"%>
<%@page import = "com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import = " com.matrixone.apps.factory.ConfigFilterablesFactory"%>
<%@page import = " com.matrixone.apps.interfaces.IConfigFilterablesFactory"%>

<%@page import = " matrix.db.RelationshipWithSelect,com.dassault_systemes.platform.model.itf.nav.INavBusConnection,
com.dassault_systemes.platform.model.itf.nav.INavBusProvider,
com.dassault_systemes.platform.model.services.NavigationServicesProvider,
com.dassault_systemes.plm.config.expression.itf.EnumTypeExpr,
com.dassault_systemes.plm.config.expression.itf.EnumTypeExpr,
 com.dassault_systemes.plm.config.expression.itf.IFilterableExpression,
 com.dassault_systemes.vplm.config.appservices.interfaces.IConfigExpressionServices.CfgDomain,
 com.dassault_systemes.vplm.config.appservices.interfaces.IConfigExpressionServices.CfgExpressionDomain,
 com.dassault_systemes.vplm.config.appservices.interfaces.IConfigExpressionServices.CfgExpressionView,
com.matrixone.apps.modeler_integration.IConfigNavFilterable,
com.matrixone.jdom.Element,com.matrixone.jdom.Document, com.matrixone.jdom.input.SAXBuilder,com.matrixone.jdom.output.XMLOutputter,com.matrixone.util.MxXMLUtils, 
com.dassault_systemes.vplm.config.appservices.interfaces.ConfigServicesToolbox, com.dassault_systemes.vplm.config.appservices.interfaces.IConfigDecouplingActivation"%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "../effectivity/EffectivityConstantsInclude.inc"%>
    
<%
String sPostProcessURL = emxGetParameter(request, "postProcessCFFURL");
String strmode                      = emxGetParameter(request,"modetype");
String strFieldNameEffTypes         = emxGetParameter(request,"fieldNameEffTypes");
String strFieldNameEffExprActual    = emxGetParameter(request,"fieldNameEffExprActual");
String strFieldNameEffExprDisplay   = emxGetParameter(request,"fieldNameEffExprDisplay");
String strFieldNameEffExprList   = emxGetParameter(request,"fieldNameEffExprActualList");
String strFieldNameDisplay              = emxGetParameter(request,"fieldNameDisplay");
String strFieldNameActual              = emxGetParameter(request,"fieldNameActual");
String strFieldNameEffExprListAc   = emxGetParameter(request,"fieldNameEffExprActualListAc");
String strFieldNameEffExprOID   = emxGetParameter(request,"fieldNameEffExprOID");
String strFormName                  = emxGetParameter(request,"formName");
String strExpandProgram                  = emxGetParameter(request,"expandProgram");
String strRelationship                 = emxGetParameter(request,"relationship");
String strRootId                 = emxGetParameter(request,"rootObjectId");
strRootId = (strRootId==null || "null".equals(strRootId))?"":strRootId;
String strEffRelationship = emxGetParameter(request,"effectivityRelationship");
String strRelName = emxGetParameter(request,"relName");
String CFFExpressionListAc = emxGetParameter(request,"CFFExpressionList");
String CFFExpressionListDisp = emxGetParameter(request,"CFFExpressionListDisp");
String includeContextProgram = emxGetParameter(request,"includeContextProgram"); //moved from cmd's setting to url's param
String effColumnType= emxGetParameter(request,"effColumnType");

boolean bDecouplingEnabled = false;
try {
	IConfigDecouplingActivation iCfgParam = ConfigServicesToolbox.getDecouplingParam();
	bDecouplingEnabled = iCfgParam.isDecouplingActivated( context );
} catch (Exception e) {
	bDecouplingEnabled = false;
}



String filterMode = emxGetParameter(request,"effectivityFilterMode");
String Directory = emxGetParameter(request,"dir");
if( Directory == null || "".equals(Directory) || "null".equals(Directory) )
{
    Directory = emxGetParameter(request,"Directory");
}

String lStr = i18nStringNowUtil("emxFramework.HelpDirectory","emxFrameworkStringResource", acceptLanguage);
String langOnlineStr = i18nStringNowUtil("emxFramework.OnlineXML.HelpDirectory", "emxFrameworkStringResource", lStr);

String strInvockedFrom = emxGetParameter(request, "invockedFrom");
if (strInvockedFrom == null || strInvockedFrom.equals("null") || strInvockedFrom.equals(""))
{
    strInvockedFrom = "fromForm";
}

String strSaveEffectivityParam = emxGetParameter(request, "saveEffectivity");
if( strSaveEffectivityParam == null || "".equals(strSaveEffectivityParam) || "null".equals(strSaveEffectivityParam) )
{
    strSaveEffectivityParam = "false";
}

String strContextObjectId = "" ;
String strRootType  = "";
String strObjectId  = "" ;
int noEffTypes = 0;
String effDiscipline = "";
String i18EffDiscipline = "";

String strParentObjectId = emxGetParameter(request,"parentOID");
if(strmode!=null && strmode.equalsIgnoreCase("create")){
    strParentObjectId  = emxGetParameter(request,"parentOID");
}
else if(strInvockedFrom.equalsIgnoreCase("fromTable")){
    //strRootId is the object Id of the root node in the navigation tree
    DomainObject rootDom = new DomainObject(strRootId);
    strRootType = rootDom.getInfo(context, DomainConstants.SELECT_TYPE);
} else{
    strParentObjectId  = emxGetParameter(request,"objectId");
}

boolean bShowSingleOperator = true;
boolean bShowSearchIcon = false;
String sShowSingleOperator = "";
String sShowSearchIcon = "";

try {
    sShowSingleOperator = EnoviaResourceBundle.getProperty(context, "emxEffectivity.Dialog.AllowSingleOperator");
    sShowSearchIcon = EnoviaResourceBundle.getProperty(context, "emxEffectivity.Dialog.ShowSearchIcon");
    
} catch (Exception ex) {
    sShowSingleOperator = "true"; //default value
    sShowSearchIcon = "true"; //default value
}

bShowSingleOperator = (sShowSingleOperator!=null && "true".equalsIgnoreCase(sShowSingleOperator))?true:false;
bShowSearchIcon = (sShowSearchIcon != null && "false".equalsIgnoreCase(sShowSearchIcon))?false:true;

String oId = emxGetParameter(request, "objectId");
String parentOID = emxGetParameter(request, "parentOID");

// dam - added this line to get structure browser edits working???
strContextObjectId = strParentObjectId;

String strContextPage = emxGetParameter(request, "contextPage");
String strRelId = emxGetParameter(request, "relId");
strRelId = (strRelId==null || "null".equals(strRelId))?"":strRelId;
String strParentOID = emxGetParameter(request, "parentOID");
String strProductID1 = emxGetParameter(request,"productID");
String strRuleExp = DomainConstants.EMPTY_STRING;

String strFromWhere = emxGetParameter(request, "fromWhere"); 
MapList mlEffectivityExpr = null;
EffectivityFramework EFF = new EffectivityFramework();
StringBuffer sbListValue = new StringBuffer();
boolean bGlobalContext = false;
String sGlobalContextPhyId = "Global";
String globalContextIcon = "";

String currActualExpression = "";//to hold current actual expression 
String includeContextsStr= "";//to store a list of contexts' id from current expression, include context program or configuration context
String dialogTitle = "";

try{
	if(effColumnType.equalsIgnoreCase("variant") && (strInvockedFrom.equalsIgnoreCase("fromTable"))){
		dialogTitle = "Effectivity.Label.EditVariantEffectivityDefinitionHeading";	
	}
	else if(effColumnType.equalsIgnoreCase("evolution") && (strInvockedFrom.equalsIgnoreCase("fromTable"))){
		dialogTitle = "Effectivity.Label.EditEvolutionEffectivityDefinitionHeading";
	}
	else{
		dialogTitle = "Effectivity.Label.EditEffectivityDefinitionHeading";
	}	
}
catch (Exception e) {
		e.printStackTrace();
}

//section: get actual expression and a list of contexts from that expression and from includeContextProgram or "Configuration Context" rel 
try {
    /*
    String sCommand = "print bus $1 $2 $3 select $4 dump;";
    sGlobalContextPhyId = MqlUtil.mqlCommand(context, sCommand, true, "Model", "Global", "", "physicalid");
    if(sGlobalContextPhyId == null){
        sGlobalContextPhyId = "";
        bGlobalContext = false;
        System.out.println("ERROR: Unable to retrieve Global Context");
    } else {
        globalContextIcon = UINavigatorUtil.getTypeIconProperty(context, "Model");
    }
    */
    
    //if there's any effectvity milestone property defined, get its i18 value
    if(strEffRelationship != null && !"null".equalsIgnoreCase(strEffRelationship) && strEffRelationship.length() > 0){
        effDiscipline = PropertyUtil.getSchemaProperty(context, "relationship", PropertyUtil.getSchemaProperty(context,strEffRelationship), "ENO_EffectivityDiscipline");
        if(effDiscipline != null && effDiscipline.length() > 0){
            String[] disciplinesArr = effDiscipline.split(",");
            for(int j=0; j < disciplinesArr.length; j++){
                String i18Discipline = ""; 
                try {
                    i18Discipline = i18nStringNowUtil("emxFramework.Range.Milestone."+disciplinesArr[j], "emxFrameworkStringResource",acceptLanguage);
                } catch(Exception e){
                    i18Discipline = disciplinesArr[j]; 
                }
                
                i18EffDiscipline = (i18EffDiscipline.length() < 1)?i18Discipline:","+i18Discipline;
            }           
        }
    }    
    
    if (strmode!=null && (strmode.equals("structureEdit") || strmode.equals("edit") ||  strInvockedFrom.equalsIgnoreCase("fromTable")))
    {
        if (strRelId != null && !"null".equalsIgnoreCase(strRelId) && !"".equals(strRelId)){
       	try{
    		StringList selects = ConfigFilterablesFactory.getNecessarySelectsForRelationshipToConfigure();
        	RelationshipWithSelect rel1 = (Relationship.getSelectRelationshipData( context, new String[] {strRelId}, selects )).getElement(0); 
    	    INavBusProvider navBusProvider = NavigationServicesProvider.getNavBusProvider();                                   
    	    INavBusConnection navBusConnection = navBusProvider.createNavBusConnection( context, rel1 );
    	    IConfigFilterablesFactory factory = ConfigFilterablesFactory.getConfigFilterablesFactory( context );
    	    IConfigNavFilterable instanceToConfigure = factory.createFilterable( context, navBusConnection );  
		    IFilterableExpression filterableExpression = instanceToConfigure.getEffectivity( context );
		    if(instanceToConfigure.hasEffectivity(context)){
			    String XMLExpression = null;        	
	        	String strDisplayExpression = null;
	        	
	        	//Checks whether Decoupling is Enabled or not, and will work as per value of bDecouplingEnabled 
	        	if(!bDecouplingEnabled){
	        		//mlEffectivityExpr = EFF.getRelExpression(context, strRelId, clientTZOffset, true);
		       		XMLExpression = filterableExpression.getExpression( context, CfgDomain.CFG_DOMAIN_CONFIG_CHANGE, EnumTypeExpr.TypeXML, CfgExpressionView.CFG_EXPRVIEW_CURRENT, true, false );        	
		           	strDisplayExpression = filterableExpression.getExpression( context, CfgDomain.CFG_DOMAIN_CONFIG_CHANGE, EnumTypeExpr.TypeXSLTransformed, CfgExpressionView.CFG_EXPRVIEW_CURRENT, true, false );
	        	} 
	        	else{
	   	        	if(effColumnType.equalsIgnoreCase("variant")){
	   		       		XMLExpression = filterableExpression.getExpression( context, CfgDomain.CFG_DOMAIN_CONFIG_CHANGE_VARIANT, EnumTypeExpr.TypeXML, CfgExpressionView.CFG_EXPRVIEW_CURRENT, true, false );        	
	   		           	strDisplayExpression = filterableExpression.getExpression( context, CfgDomain.CFG_DOMAIN_CONFIG_CHANGE_VARIANT, EnumTypeExpr.TypeXSLTransformed, CfgExpressionView.CFG_EXPRVIEW_CURRENT, true, false );
	   	        	}  else if(effColumnType.equalsIgnoreCase("configchange")){
	   		       		XMLExpression = filterableExpression.getExpression( context, CfgDomain.CFG_DOMAIN_CONFIG_CHANGE, EnumTypeExpr.TypeXML, CfgExpressionView.CFG_EXPRVIEW_CURRENT, true, false );        	
	   		           	strDisplayExpression = filterableExpression.getExpression( context, CfgDomain.CFG_DOMAIN_CONFIG_CHANGE, EnumTypeExpr.TypeXSLTransformed, CfgExpressionView.CFG_EXPRVIEW_CURRENT, true, false );
	   	        	} else if(effColumnType.equalsIgnoreCase("evolution")){
	   		       		XMLExpression = filterableExpression.getExpression( context, CfgDomain.CFG_DOMAIN_CONFIG_CHANGE_EVOLUTION, EnumTypeExpr.TypeXML, CfgExpressionView.CFG_EXPRVIEW_CURRENT, true, false );        	
	   		           	strDisplayExpression = filterableExpression.getExpression( context, CfgDomain.CFG_DOMAIN_CONFIG_CHANGE_EVOLUTION, EnumTypeExpr.TypeXSLTransformed, CfgExpressionView.CFG_EXPRVIEW_CURRENT, true, false );
	   	        	} 	
	            }
	        	EffectivityFramework EFF1 = new EffectivityFramework();
      			SAXBuilder saxb = new SAXBuilder();
	           	Document document = document = saxb.build(new StringReader(XMLExpression));
	           	Element root = document.getRootElement();
	         	Element expression = root.getChild("Expression", null);
	     		         
	         	Element elemMultiContext = expression.getChild("MultiContextView", null);
	         	if(elemMultiContext!=null){
   		            List listContext = (List) elemMultiContext.getChildren();
   		           	for (int k = 0; k < listContext.size(); k++) {
						 Element elemContext = (Element) listContext.get(k);
						 try{
							 Element elemBoolean = elemContext.getChild("Boolean", null);
						 if(elemBoolean!=null){
							 elemContext.detach();	
							 k--;
						 }
						 }
						 catch(Exception e){
							 e.printStackTrace();
						 }
   		           	}
   		        	XMLOutputter outputter = MxXMLUtils.getOutputter(true);
   		    		XMLExpression = outputter.outputString(document);   	   		           	
	         	}

	        	String expression_xml1 = EFF1.convertXMLtoActualExpression(context,XMLExpression);
	        	
	        	Map tempMap = new HashMap();
	        	tempMap.put("displayValue", strDisplayExpression);
	        	tempMap.put("actualValue", expression_xml1);
	        			
	        	mlEffectivityExpr = new MapList();
	        	mlEffectivityExpr.add(tempMap);		    	
		    }
      	} catch (Exception e) {
   				e.printStackTrace();
		} 

     	
        }
        else if (strObjectId != null && strObjectId.length() > 0){
            mlEffectivityExpr = EFF.getObjectExpression(context, strObjectId, clientTZOffset, true);
        }
        
        if(mlEffectivityExpr != null && mlEffectivityExpr.size() > 0){
            Map mapExpression = (Map)mlEffectivityExpr.get(0);
            //need only actual expression to later find other information
            currActualExpression = (String)mapExpression.get("actualValue");
        }       
    }
    
    //from CFFToolbar or Filter, objectId is the root id
    if(strContextObjectId != null && ("fromEffToolbar".equalsIgnoreCase(strInvockedFrom) || "filter".equalsIgnoreCase(strmode))){
            strRootId = strContextObjectId;
    }

    //get contexts from includeContextProgram or "Configuration Context" relationship, if any   
    MapList includeContextMapList = null;    
    if(strRootId != null && !"null".equals(strRootId) && strRootId.length() > 0){
        //only add needed info for context program to execute successfully.
        //if want to use values from pageContext and request, make sure values are not modified in this page
        HashMap requestMap = new HashMap(); //UINavigatorUtil.getRequestParameterMap(pageContext);
        HashMap requestValuesMap = new HashMap();//UINavigatorUtil.getRequestParameterValuesMap(request);
        String[] rootIdArr = new String[]{strRootId};
        requestValuesMap.put("rootID", rootIdArr);
        requestMap.put("RequestValuesMap", requestValuesMap);
        
        if(strParentObjectId != null && strParentObjectId.length() > 0){
            requestMap.put("parentID", strParentObjectId);  
        }
        if(oId != null && oId.length() > 0){
            requestMap.put("objectId", oId);    
        }
        if(strRelId != null && strRelId.length() > 0){
            requestMap.put("relId", strRelId);
        }
        
        String[] arrJPOArgs = (String[])JPO.packArgs(requestMap);
        
        //gets from include program        
        if(includeContextProgram != null && !"".equals(includeContextProgram) && !"null".equals(includeContextProgram)){
            String[] programMethod = (String[])includeContextProgram.split(":");        
            if(programMethod != null && programMethod.length == 2){            
                includeContextMapList = (MapList) JPO.invoke(context,programMethod[0],null, programMethod[1],arrJPOArgs,MapList.class);
            }   
        } else{ //gets from Configuration Context Relationship 
            StringList includeContextStrList = (StringList) JPO.invoke(context,"emxEffectivityFramework",null, "getConfigurationContexts",arrJPOArgs,StringList.class);
            if(includeContextStrList != null && includeContextStrList.size() > 0){
                includeContextMapList = new MapList(includeContextStrList.size());
                for(int n=0; n < includeContextStrList.size(); n++){
                    Map contextMap = new HashMap();
                    contextMap.put(DomainObject.SELECT_ID, (String)includeContextStrList.get(n));
                    includeContextMapList.add(contextMap);
                }
            }       
        }

        if(includeContextMapList != null && includeContextMapList.size() > 0){
            for(int x=0; x < includeContextMapList.size(); x++){
                Map idMap = (Map)includeContextMapList.get(x);
                String cxtId = (String)idMap.get(DomainObject.SELECT_ID);
                includeContextsStr += (includeContextsStr.length() > 0)?"|"+cxtId:cxtId;                
            }
        }        
    }
        
    //extract contextids from actual expression to be filtered against the list from includeContextProgram or Configuration Context
    if(currActualExpression.length() > 0){      
       Map currContextsMap = EFF.getEffectivityByContext(context, currActualExpression);
       for(Iterator cxtItr = currContextsMap.keySet().iterator();cxtItr.hasNext();){
           String cxtPhysicalId = (String)cxtItr.next();
           //if there's global context, save it here to be included in the context panel later
           if(cxtPhysicalId != null && !"null".equalsIgnoreCase(cxtPhysicalId) && cxtPhysicalId.length() > 0){
               includeContextsStr += (includeContextsStr.length() > 0)?"|"+cxtPhysicalId:cxtPhysicalId;        
           } else if(cxtPhysicalId == null || "null".equalsIgnoreCase(cxtPhysicalId)){//global context map
               bGlobalContext = true;
           }
       }
    }    
    
}catch(Exception e){
    e.printStackTrace();
    throw new Exception(e.toString());
}

String strCtxType = "";
String strCtxName = "";
String strCtxRev = "";


String type_ConfigOption = PropertyUtil.getSchemaProperty(context,"type_ConfigurationOption");
List ConfigOptionTypes = new LinkedList();
ConfigOptionTypes.add(type_ConfigOption);
ConfigOptionTypes.addAll(EFF.getChildrenTypes(context, type_ConfigOption));
String ListConfigOptionTypes = ConfigOptionTypes.toString();

String type_Milestone = PropertyUtil.getSchemaProperty(context,"type_Milestone");
List MilestoneTypes = new LinkedList();
MilestoneTypes.add(type_Milestone);
MilestoneTypes.addAll(EFF.getChildrenTypes(context, type_Milestone));
String ListMilestoneTypes = MilestoneTypes.toString();

%>

<script Language="Javascript">
//below variables are used in .js
var contextExpressionArr = new Array();
var completedDisplayExpressionArr = new Array();
var iClientTimeOffset = "<%=XSSUtil.encodeForJavaScript(context,Double.toString(clientTZOffset))%>";
var bGlobalContext = <%=XSSUtil.encodeForJavaScript(context,Boolean.toString(bGlobalContext))%>;
var globalContextIcon = "<%=XSSUtil.encodeForJavaScript(context,globalContextIcon)%>";
var bShowSingleOperator = <%=XSSUtil.encodeForJavaScript(context,Boolean.toString(bShowSingleOperator))%>;
var bShowSearchIcon = <%=XSSUtil.encodeForJavaScript(context,Boolean.toString(bShowSearchIcon))%>;
var ConfigOptionSubtypes = "<%=XSSUtil.encodeForJavaScript(context,ListConfigOptionTypes)%>";
var MilestoneSubtypes = "<%=XSSUtil.encodeForJavaScript(context,ListMilestoneTypes)%>";

//XSSOK
var postProcessURL = (<%=XSSUtil.encodeForJavaScript(context,sPostProcessURL)!=null%>)?
                          "<%=XSSUtil.encodeForJavaScript(context,sPostProcessURL)%>":"";
var MODE = "<%=XSSUtil.encodeForJavaScript(context,strmode)%>";                       
var currentEffTypes;
var currentEffExprActual="";
var currentEffExprDisp="";
var currentEffExpr="";
var currentEffExprAc="";
var currentEffTypesModeArr = new Array();
var currentEffTypesModeArrActual = new Array();
var showValidMsg = true;
var cnt = 0;


var ProductID = "<%=XSSUtil.encodeForJavaScript(context, strProductID1)%>";
var RELID = "<%=XSSUtil.encodeForJavaScript(context, strRelId)%>";
var ROOTID = "<%=XSSUtil.encodeForJavaScript(context, strRootId)%>";
var objectId = "<%=XSSUtil.encodeForJavaScript(context,oId)%>";
var strContextObjectId = "<%=XSSUtil.encodeForJavaScript(context, strContextObjectId)%>";
var parentOID= "<%=XSSUtil.encodeForJavaScript(context,strParentOID)%>";
var globalContextPhyId = "<%=XSSUtil.encodeForJavaScript(context,sGlobalContextPhyId)%>";
var includeContextsStr = "<%=XSSUtil.encodeForJavaScript(context, includeContextsStr)%>";
var includeContextsInfo = null;
var FORM_NAME = "<%=XSSUtil.encodeForJavaScript(context,strFormName)%>";
//XSSOK
var fieldNameEffTypes = (<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffTypes)!=null%>)?
                        "<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffTypes)%>":"";
//XSSOK
var fieldNameEffExprActual = (<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprActual)!=null%>)?
                             "<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprActual)%>":"";
//XSSOK
var fieldNameEffExprDisplay = (<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprDisplay)!=null%>)?
                            "<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprDisplay)%>":"";
//XSSOK
var fieldNameEffExprList = (<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprList)!=null%>)?
                            "<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprList)%>":"";
//XSSOK
var fieldNameEffExprListAc = (<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprListAc)!=null%>)?
                             "<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprListAc)%>":"";
//XSSOK
var fieldNameActual = (<%=XSSUtil.encodeForJavaScript(context,strFieldNameActual)!=null%>)?
                            "<%=XSSUtil.encodeForJavaScript(context,strFieldNameActual)%>":"";
//XSSOK
var fieldNameDisplay = (<%=XSSUtil.encodeForJavaScript(context,strFieldNameDisplay)!=null%>)?
                        "<%=XSSUtil.encodeForJavaScript(context,strFieldNameDisplay)%>":"";
//XSSOK
var invokedFrom = (<%=XSSUtil.encodeForJavaScript(context,strInvockedFrom)!=null%>)?
                            "<%=XSSUtil.encodeForJavaScript(context,strInvockedFrom)%>":"";
var bDefaultAllowSingleDate = (strContextObjectId != null && (MODE == 'filter' || invokedFrom == FROMEFFTOOLBAR));
var bForFiltering = (MODE == 'filter' || invokedFrom == FROMEFFTOOLBAR);
var EFFECTIVITY_DISCIPLINE = "<%=XSSUtil.encodeForJavaScript(context, effDiscipline)%>";
var I18EFFECTIVITY_DISCIPLINE = "<%=XSSUtil.encodeForJavaScript(context, i18EffDiscipline)%>";

</script>

<%@include file = "../emxTagLibInclude.inc"%>
<%-- XSSOK --%>
<framework:localize id="i18nId" bundle="EffectivityStringResource"  locale="<%=acceptLanguage%>"/>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title><emxUtil:i18n localize="i18nId">Effectivity.Label.EditEffectivityDefinitionHeading</emxUtil:i18n></title>

<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css"/>
<link rel="stylesheet" type="text/css" href="../common/styles/emxUIMenu.css"/>
<link rel="stylesheet" type="text/css" media="screen" href="../common/styles/emxUIStructureBrowser.css" />
<link rel="stylesheet" type="text/css" media="screen" href="../effectivity/styles/emxUIRuleLayerDialog.css" />
<link rel="stylesheet" type="text/css" href="styles/emxUIEffectivityDialog.css"/>

<script language="JavaScript" type="text/javascript"
    src="../common/emxUIConstantsJavaScriptInclude.jsp"></script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/emxUIPageUtility.js"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" type="text/javascript" src="../common/scripts/emxUICalendar.js"></script>
<script src="../common/scripts/emxNavigatorHelp.js" type="text/javascript"></script>
<script type="text/javascript" src="../effectivity/scripts/jquery.min.js"></script>
<link rel="stylesheet" href="../effectivity/styles/autocomplete.css"/>
<script type="text/javascript" src="../effectivity/scripts/autocomplete.js"></script>
<script language="javascript" type="text/javascript" src="../effectivity/scripts/emxUIEffectivityFramework.js"></script>
<script Language="Javascript">
<%
StringList slEffTypes = new StringList();  
 
try {

	boolean isMobileMode = UINavigatorUtil.isMobile(context);
    if(isMobileMode)
    {
  	 %>
  	  var msg = "<%=i18nNow.getI18nString("Effectivity.Alert.EffectivityOnMobile",bundle,acceptLanguage)%>";
  	  alert(msg);
  	  getTopWindow().closeWindow();
  	 <%
    }
    
    //get the valid effectivity types for the context object and/or rel
    if (strmode!=null && (strmode.equals("structureEdit") ||  strInvockedFrom.equalsIgnoreCase("fromTable"))){ 
        MapList relEffTypes = null;
        String[] strRelArr = null;
        if(strExpandProgram != null && !("").equalsIgnoreCase(strExpandProgram)){
            if (strEffRelationship == null || "null".equalsIgnoreCase(strEffRelationship) ||
                "".equals(strEffRelationship) || "*".equals(strEffRelationship)){    // If effectivityRelationship parameter is not defined assume all Relationships on the given Type that have been configured for Effectivity
                relEffTypes = EFF.getEffectivityForAllRelTypes(context, strRootType);
            }else if(strEffRelationship.contains(","))
            {
                strRelArr=strEffRelationship.split(",");
                relEffTypes = EFF.getRelEffectivity(context,strRelArr[0]);
                for(int i = 1; i < strRelArr.length; i++)
                {
                    relEffTypes.addAll(EFF.getRelEffectivity(context,strRelArr[i]));
                }
            }
            else
            {
                    relEffTypes = EFF.getRelEffectivity(context,strEffRelationship);
            }
        } else{
            //uses effectivityRelationship passed in
            if (strEffRelationship != null && !"null".equalsIgnoreCase(strEffRelationship) && strEffRelationship.length() > 0){
                strRelationship = strEffRelationship;
            }

            if(strRelationship == null && strRelId != null && !"null".equalsIgnoreCase(strRelId) && !"".equalsIgnoreCase(strRelId)){
                DomainRelationship domRel = new DomainRelationship(strRelId);
                domRel.open(context);
                String relName = domRel.getTypeName();
                String relAlias = FrameworkUtil.getAliasForAdmin(context, "relationship", relName, true);        
                relEffTypes = EFF.getRelEffectivity(context, relAlias);     
            } else if ("*".equals(strRelationship)){//dam
                relEffTypes = EFF.getEffectivityForAllRelTypes(context, strRootType);                   
            }else if(strRelationship.contains(","))
            {
                strRelArr=strRelationship.split(",");
                relEffTypes = EFF.getRelEffectivity(context,strRelArr[0]);
                for(int i = 1; i < strRelArr.length; i++)
                {
                    relEffTypes.addAll(EFF.getRelEffectivity(context,strRelArr[i]));
                }
            }
            else
            {
                    relEffTypes = EFF.getRelEffectivity(context,strRelationship);
            }
        }

        Map effTypeMap = null;
        String effType = ""; 
        String effTypeActual = ""; 
        //Start R2020x_FUN079666: This is code is valid for R2020x only. Because MQL Expression MilestoneActivation will not available in R2019x.
        //So in case of R2019x, value of strExpr will always blank.
        String strListMQL  = "list expression $1";
		String strExpr     = MqlUtil.mqlCommand(context, strListMQL, "MilestoneActivation");
		String strExprValue = "";
		if(!"".equalsIgnoreCase(strExpr)){
			String strPrintMQL  = "print expression $1 select value dump";
			strExprValue = MqlUtil.mqlCommand(context, strPrintMQL, strExpr);
		}
		//End R2020x_FUN079666:
        for (int idx=0; idx < relEffTypes.size(); idx++){
            effTypeMap = (Map)relEffTypes.get(idx);
            effType = (String)effTypeMap.get("displayValue");
            effTypeActual = (String)effTypeMap.get("actualValue");
            if(!slEffTypes.contains(effTypeActual)){
            	
            	//Added if check for R2020x_FUN079666 function.
            	if("Milestone".equalsIgnoreCase(effType) && "Disabled".equalsIgnoreCase(strExprValue)){
            	}else{
                slEffTypes.add(effTypeActual);
    %>      
                currentEffTypesArr[cnt] = "<%=XSSUtil.encodeForJavaScript(context,effType)%>";
                currentEffTypesArrActual[cnt] = "<%=XSSUtil.encodeForJavaScript(context,effTypeActual)%>";
                cnt++;
    <%
            	}
            }
       }
        noEffTypes = relEffTypes.size();
    %>
        currentEffExprActual = "<%=XSSUtil.encodeForJavaScript(context,currActualExpression)%>";     

    <%    
    }
    else if (strContextObjectId != null && strContextObjectId.length() > 0){
        if(("fromEffToolbar").equalsIgnoreCase(strInvockedFrom) || strmode.equalsIgnoreCase("filter")){
            dialogTitle = "Effectivity.Label.FilterEffectivityDefinitionHeading";
            Map mapExpression = null;       
            DomainObject domObj     = DomainObject.newInstance(context,strContextObjectId);
            String strContextType   = domObj.getInfo(context,DomainConstants.SELECT_TYPE);

            MapList objEffTypes = EFF.getObjectEffectivityTypes(context,strContextObjectId);
            MapList relEffTypes = new MapList();
            String[] strRelArr = null;
            if(strExpandProgram != null && !("").equalsIgnoreCase(strExpandProgram)){
                if (strEffRelationship == null || "null".equalsIgnoreCase(strEffRelationship) || "".equals(strEffRelationship)){   // If effectivityRelationship parameter is not defined assume all Relationships on the given Type that have been configured for Effectivity
                    relEffTypes = EFF.getEffectivityForAllRelTypes(context, strContextType);
                } else if(strEffRelationship.contains(","))
                {
                    strRelArr=strEffRelationship.split(",");
                    relEffTypes = EFF.getRelEffectivity(context,strRelArr[0]);
                    for(int i = 1; i < strRelArr.length; i++)
                    {
                        relEffTypes.addAll(EFF.getRelEffectivity(context,strRelArr[i]));
                    }
                }
                else
                {
                        relEffTypes = EFF.getRelEffectivity(context,strEffRelationship);
                }
            } else{
                //uses effectivityRelationship passed in
                if (strEffRelationship != null && !"null".equalsIgnoreCase(strEffRelationship) && strEffRelationship.length() > 0){
                    strRelationship = strEffRelationship;
                }            
                if(strRelationship == null || strRelationship.equals("*")){
                    relEffTypes = EFF.getEffectivityForAllRelTypes(context, strContextType);
                } else if(strRelationship.contains(","))
                {
                    strRelArr=strRelationship.split(",");
                    relEffTypes = EFF.getRelEffectivity(context,strRelArr[0]);
                    for(int i = 1; i < strRelArr.length; i++)
                    {
                        relEffTypes.addAll(EFF.getRelEffectivity(context,strRelArr[i]));
                    }
                }
                else
                {
                        relEffTypes = EFF.getRelEffectivity(context,strRelationship);
                }
            }

            Map effTypeMap = null;
            Map effRelMap = null;
            String effType = "";
            String effTypeActual = "";

            for (int idx=0; idx < objEffTypes.size(); idx++){
                effTypeMap = (Map)objEffTypes.get(idx);
                effType = (String)effTypeMap.get("displayValue");
                effTypeActual = (String)effTypeMap.get("actualValue");
                if(!slEffTypes.contains(effTypeActual)){
                    slEffTypes.add(effTypeActual);
        %>     
                    currentEffTypesArr[cnt] = "<%=XSSUtil.encodeForJavaScript(context,effType)%>";
                    currentEffTypesArrActual[cnt] = "<%=XSSUtil.encodeForJavaScript(context,effTypeActual)%>";
                    cnt++;
        <%  
                }
            }

            for (int idx=0; idx < relEffTypes.size(); idx++){
                effRelMap = (Map)relEffTypes.get(idx);
                effType = (String)effRelMap.get("displayValue");
                effTypeActual = (String)effRelMap.get("actualValue");
                if(!slEffTypes.contains(effTypeActual)){
                    slEffTypes.add(effTypeActual);
            %>      
                    currentEffTypesArr[cnt] = "<%=XSSUtil.encodeForJavaScript(context,effType)%>";
                    currentEffTypesArrActual[cnt] = "<%=XSSUtil.encodeForJavaScript(context,effTypeActual)%>";
                    cnt++;
            <%  
                }
            }
            noEffTypes = objEffTypes.size() + relEffTypes.size();
        }
        %>
        //get current expression (actual) if any    
        //XSSOK    
        currentEffExprAc = (<%=XSSUtil.encodeForJavaScript(context,CFFExpressionListAc)!=null%>)?
                           "<%=XSSUtil.encodeForJavaScript(context,CFFExpressionListAc)%>":"";
        //only need actual expression to get all other information
        var actualExprField = eval("parent.window.getWindowOpener().document."+FORM_NAME+".CFFExpressionFilterInput_actualValue");
        currentEffExprActual =  (actualExprField)?actualExprField.value:currentEffExprAc;

    <%
    }
    %>

    if(invokedFrom != null && invokedFrom == "fromForm"){
        currentEffTypes = (fieldNameEffTypes != null && fieldNameEffTypes != "")?
                          eval("parent.window.getWindowOpener().document."+FORM_NAME+"."+fieldNameEffTypes):"";
        //need only actual expression                 
        currentEffExprActual = (fieldNameEffExprActual != null && fieldNameEffExprActual != "")?
                          eval("parent.window.getWindowOpener().document."+FORM_NAME+"."+fieldNameEffExprActual+".value"):"";  
    }
    
<%
}//end try
catch(Exception e)
{
%>
    alert("<%=e.getMessage()%>");   //XSSOK
<%
}// End of main Try-catck block
%> 
 
</script>

</head>
    
<body onload="displayCFFDefinitionDialog();" onbeforeunload="cleanupCache();">
<div id = "keyInDiv" style="position:absolute;top:0px;left:0px;border:solid 1px black;z-index:10000;"></div>
<!-- check for mode and make this conditional add method getModeTypes()-->
<form action="" method="post" name="BCform">
<div id="pageHeadDiv">
    <table >
        <tr>
            <td class="page-title">
            <h2><emxUtil:i18n localize="i18nId"><%=XSSUtil.encodeForHTML(context,dialogTitle)%></emxUtil:i18n></h2>
            <%        
            if (strCtxName != null && strCtxName.length() > 0)
            {
            %>
                <h3><emxUtil:i18n localize="i18nId">Effectivity.Label.EffectivityExpressionSubHeading</emxUtil:i18n><%=XSSUtil.encodeForHTML(context,strCtxType) + " " + XSSUtil.encodeForHTML(context,strCtxName) + " " + XSSUtil.encodeForHTML(context,strCtxRev)%></h3>
            <%
            }
            %>
            </td>
            <td class="buttons">
              <table border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td><a href='javascript:openHelp("emxhelpeffectivityedit","effectivity","<%=XSSUtil.encodeForJavaScript(context,lStr)%>","<%=XSSUtil.encodeForJavaScript(context,langOnlineStr)%>")'><img src="../common/images/iconActionHelp.gif" width="16" height="16" border="0"  alt="<emxUtil:i18n localize="i18nId">Effectivity.Button.Help</emxUtil:i18n>" /></a></td>
                    <td><button class="btn-primary" type="button" name="validate" class="mx_btn-validate" onClick="fnValidate(false,true);" ><emxUtil:i18n localize='i18nId'>Effectivity.Button.Validate</emxUtil:i18n></button></td>
                    <td><button class="btn-primary" name="done" type="button" onclick="computedRule('','left');submitRule();return false"><emxUtil:i18n localize="i18nId">Effectivity.Common.Done</emxUtil:i18n></button></td>
                    <td><button class="btn-primary" type="button" name="cancel" class="mx_btn-cancel" onClick="JavaScript:getTopWindow().window.closeWindow();"> <emxUtil:i18n localize="i18nId">Effectivity.Button.Cancel</emxUtil:i18n></button></td>
                  </tr>
              </table>
            </td>
        </tr>
    </table>
<!-- end #mx_divPageHead -->
</div>
<div id="divPageBody">
    <div id="mx_divContent" class="open">
        <div id="mx_divFilter">
           <div class="panel-head">
               <div class="button-toggle" id="mx_contextToggle" title="<emxUtil:i18n localize="i18nId">Effectivity.Dialog.ClickToClose</emxUtil:i18n>" onclick="togglePanel('mx_divContent','open','closed','mx_contextToggle')"><a href="#"></a></div>
               <div class="title"><emxUtil:i18n localize="i18nId">Effectivity.Label.Context</emxUtil:i18n></div>              
               <div class="toolbar">
                    <div class="functions">
                        <ul>                         
                            <li><a href="#" onclick="javascript:searchContext()" title="<emxUtil:i18n localize="i18nId">Effectivity.Dialog.SearchContext</emxUtil:i18n>"><img src="../common/images/iconActionSearch.gif" id="searchIcon"/></a></li>                        
                        </ul>
                    </div>
                    <div class="actions">
                    </div>                    
               </div>
           </div>
           <div class="panel-body">
                <div class="panel-content" id="mx_contextPanel">
                    <ul id="cachedContextList" selectedContext=""></ul>             
                </div>
           </div>
        </div><!-- /#mx_divFilter -->

        <div id="mx_divSourceList">
        </div><!-- /#mx_divSourceList -->
        <div id="mx_divExpression">
           <div class="panel-head">
            <div class="function" id="mx_builderToggle" value="openStatus"><a href="#" onclick="toggleBuilderPanel()" id="builderTagId"   title="<emxUtil:i18n localize="i18nId">Effectivity.Dialog.ClickToExpand</emxUtil:i18n>"><img src="../common/images/iconActionClosePanel.gif" id="builderCollId" /></a></div>
               <div class="title" style='left:17px'><emxUtil:i18n localize="i18nId">Effectivity.Form.Label.EffectivityExpression</emxUtil:i18n></div>
               <div class="toolbar">
                    <div class="functions">
                        <ul>
                            <li>
                                <div id="rangeCheckbox"><input type="checkbox" id="insertAsRange"/><label><emxUtil:i18n localize="i18nId">Effectivity.Label.Range</emxUtil:i18n></label></div>
                            </li>
                            <li></li>
                        </ul>
                    </div>
                    <div class="actions">
                        <ul id="operatorsTable" class="mx_operators">
                           <li id="li-l-paren"><input type="button" id="l-paren" name="l-paren" value="(" onclick='operatorInsert("(","left"),computedRule("(","left")' /></li>
                         <li id="li-or"><input type="button" id="or" name="or" value="OR" class="off" onclick='togglestyle(this)' /></li>
                          <li id="li-r-paren"><input type="button" id="r-paren" name="r-paren" value=")" onclick='operatorInsert(")","left"),computedRule(")","left")' /></li>
                         <li id="li-infinity"><input type="button" id="infinity" name="infinity" value=<%=XSSUtil.encodeForHTMLAttribute(context,infinitySymbolDisp)%> onclick='insertInfinity(),computedRule(")","left")' /></li>                        </ul>
                    </div>
               </div>
           </div><!-- /.panel-head -->

           <div class="panel-body">
                <ul id="mx_divObjectManipulation">
                    <li class="mx_button"><a id="insertButtinId" href="#" onclick="insertFeatureOptions(getActiveEffectivityType()),computedRule('','left'),clearAllCheckedNodes(getActiveEffectivityType())" class="mx_button-insert" title="<emxUtil:i18n localize="i18nId">Effectivity.Button.Insert</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></li>
                    <li class="mx_button"><a href="#" onclick="moveUp('left'),computedRule('','left')" class="mx_button-move-up" title="<emxUtil:i18n localize="i18nId">Effectivity.Button.MoveUp</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></li>
                    <li class="mx_button"><a href="#" onclick="moveDown('left'),computedRule('','left')" class="mx_button-move-down" title="<emxUtil:i18n localize="i18nId">Effectivity.Button.MoveDown</emxUtil:i18n>"><img src="../common/images/utilSpacer.gif" border="0" /></a></li>
                    <li class="mx_button"><input type="button" value="<emxUtil:i18n localize="i18nId">Effectivity.Button.Clear</emxUtil:i18n>"  onClick="clearExpression();" class="mx_button-clear" title="<emxUtil:i18n localize="i18nId">Effectivity.Button.ClearExpression</emxUtil:i18n>" style="height:25px;margin-left:2px; text-overflow: ellipsis; overflow: hidden; width:50px;" /></li>
                </ul>
                <div id="divSelect" oncontextmenu="return false" onscroll="OnDivScroll();">
                    <select name="LeftExpression" size="10" id="IncExp" multiple oncontextmenu="return false" onfocus="OnSelectFocus();" onchange="resetKeyInDiv();" onkeydown="resetReadMode();" ondblclick="toggleOperator();"> </select>
                    <div id="helper" style="position:absolute;width:50px;height:120px;top:0px;left:0px;"></div>                                         
                </div>
           </div>
        </div><!-- /#mx_divExpression -->
        <div id="mx_divCompletedRule">
           <div class="panel-head">               
               <div class="title"><emxUtil:i18n localize="i18nId">Effectivity.Label.CompletedExpression</emxUtil:i18n></div>
           </div>
           <div class="panel-body">
               <div id="mx_divRuleText"></div>
           </div>
        </div><!-- /#mx_divCompletedRule -->
    </div><!-- /#mx_divContent -->
</div><!-- /#divPageBody -->

<input type="hidden" name="txtObjectId" value="<xss:encodeForHTMLAttribute><%=strObjectId %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="txtParentObjectId" value="<xss:encodeForHTMLAttribute><%=strParentOID %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="txtProductObjectId" value="<xss:encodeForHTMLAttribute><%=strProductID1 %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="txtContextPage" value="<xss:encodeForHTMLAttribute><%=strContextPage %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="txtFeatureOId" value="<xss:encodeForHTMLAttribute><%=strObjectId %></xss:encodeForHTMLAttribute>" />
 <input type="hidden" name="txtRootType" id="txtRootType" value="<xss:encodeForHTMLAttribute><%=strRootType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="invockedfromfield" value="<xss:encodeForHTMLAttribute><%=strInvockedFrom %></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="effColumnType" value="<xss:encodeForHTMLAttribute><%=effColumnType%></xss:encodeForHTMLAttribute>" />

<!-- Mode Field on Effectivity Definition Dialog  -->
<%

  if((strmode.compareTo("create")==0)){%>
    <input type="hidden" name="txtObjectId" value="<xss:encodeForHTMLAttribute><%=strContextObjectId %></xss:encodeForHTMLAttribute>" />
<%} 
  if((strmode.compareTo("edit")==0))  {%>
    <input type="hidden" name="txtObjectId" value="<xss:encodeForHTMLAttribute><%=strObjectId %></xss:encodeForHTMLAttribute>" />
<%} %>

</form>


<script type="text/javascript" Language="Javascript">
/*
 * submits created expression
 */

function finalSubmit()
{
    closePostProcessURLPopup();
    var vInvockedFrom = document.BCform.invockedfromfield.value;
    //get all values for compelte expression 
    var completeExp = getCompleteExpression(contextExpressionArr);

    var actualExpression = completeExp.completedRuleActual;
    var relationshipId = "<xss:encodeForJavaScript><%=strRelId %></xss:encodeForJavaScript>";
    var vSaveEffectivityParam ="<xss:encodeForJavaScript><%=strSaveEffectivityParam %></xss:encodeForJavaScript>";

    if(vSaveEffectivityParam == "true")
    {
        var url="../effectivity/EffectivityUtil.jsp?mode=saveEffectivity&relId="+relationshipId;
        var vRes = emxUICore.getDataPost(url, "actualExp=" + actualExpression);

        if(vRes.indexOf("ERROR:")>=0)
        {
            alert(vRes.subString(vRes.indexOf("ERROR:")+6).trim());        
        }
        else
        {
            if(getTopWindow().getWindowOpener())
            {
                parent.window.closeWindow();
            }
            else
            {
                window.location.href="../common/emxLogin.jsp";
            }
        }        
    }
    else
    { 
        if(vInvockedFrom == "fromEffToolbar")
        {            
            var targetElement = getTopWindow().getWindowOpener().getTopWindow().document.getElementById("CFFExpressionFilterInput");            
            var targetDocument;
			
			if(targetElement){				
				targetDocument = getTopWindow().getWindowOpener().getTopWindow().document;
			}
			else{				
				targetDocument = getTopWindow().getWindowOpener().document;
			}
			
            var elemCFFExpressionFilterInput = targetDocument.getElementById("CFFExpressionFilterInput");
            
            if(elemCFFExpressionFilterInput != null){               
                elemCFFExpressionFilterInput.value = completeExp.completedRuleText;
                elemCFFExpressionFilterInput.setAttribute("title", completeExp.completedRuleText);
            }

            var elemCFFExpressionFilterInput_actualValue = targetDocument.getElementById("CFFExpressionFilterInput_actualValue");
            if(elemCFFExpressionFilterInput_actualValue != null){
                elemCFFExpressionFilterInput_actualValue.value = completeExp.completedRuleActual;
            }               

            var urlParams = "mode=getBinary&effExpr="+completeExp.completedRuleActual+"&filterMode="+<%=XSSUtil.encodeForJavaScript(context,filterMode)%>;
            var vRes = emxUICore.getDataPost("../effectivity/EffectivityUtil.jsp", urlParams);
            
            var elemCFFExpressionFilterInput_OID = targetDocument.getElementById("CFFExpressionFilterInput_OID");
            if(elemCFFExpressionFilterInput_OID != null){
                elemCFFExpressionFilterInput_OID.value = vRes;
            }

            //1. Store the delimited actual expression
            currentEffExprAc = completeExp.completedRuleActualList;
            
            var CFFExpressionListAc = targetDocument.getElementById("CFFExpressionList");
            if(CFFExpressionListAc == undefined || CFFExpressionListAc == null)
            {
                CFFExpressionListAc = targetDocument.createElement('input');//parent.window.getWindowOpener().document.createElement('input');
                CFFExpressionListAc.setAttribute('type', 'hidden');
                CFFExpressionListAc.setAttribute('name', 'CFFExpressionList');
                CFFExpressionListAc.setAttribute('id', 'CFFExpressionList');       
            }

            CFFExpressionListAc.setAttribute('value', currentEffExprAc);

            //2. Store the delimited display expression           
            var CFFExpressionListDisp = targetDocument.getElementById("CFFExpressionListDisp");
            if(CFFExpressionListDisp == undefined || CFFExpressionListDisp == null)
            {
                CFFExpressionListDisp = targetDocument.createElement('input');//parent.window.getWindowOpener().document.createElement('input');
                CFFExpressionListDisp.setAttribute('type', 'hidden');
                CFFExpressionListDisp.setAttribute('name', 'CFFExpressionListDisp');
                CFFExpressionListDisp.setAttribute('id', 'CFFExpressionListDisp');                           
            }

            CFFExpressionListDisp.setAttribute('value', completeExp.completedRuleTextList);
            getTopWindow().closeWindow();            
        }
        else if(vInvockedFrom == "fromForm")
        {
            <%if(strFieldNameEffExprDisplay != null && strFieldNameEffExprActual != null && strFieldNameEffExprList != null && strFieldNameEffExprListAc!= null){%>
            parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>.<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprDisplay)%>.setAttribute("title", completeExp.completedRuleText);
            parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>.<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprDisplay)%>.value = completeExp.completedRuleText;
            parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>.<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprActual)%>.value = completeExp.completedRuleActual;
            parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>.<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprList)%>.value = completeExp.completedRuleTextList;
            parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>.<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprListAc)%>.value = completeExp.completedRuleActualList;
            <%}%>
            //store the compiled binary if this is filter mode
            <%if(strmode != null && strmode.equalsIgnoreCase("filter")){%>
                var urlParams = "mode=getBinary&effExpr="+completeExp.completedRuleActual+"&filterMode="+<%=XSSUtil.encodeForJavaScript(context,filterMode)%>;
                var vRes = trim(emxUICore.getDataPost("../effectivity/EffectivityUtil.jsp", urlParams));
                parent.window.getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,strFormName)%>.<%=XSSUtil.encodeForJavaScript(context,strFieldNameEffExprOID)%>.value = vRes;
            <%}%>            
            currentEffExprActual = completeExp.completedRuleActual;
            currentEffExprDisp = completeExp.completedRuleText;
            currentEffExpr = completeExp.completedRuleTextList;
            currentEffExprAc = completeExp.completedRuleActualList;
        }
        else
        {    
            // code to handle the expression to be set in the structure browser columns
            var displayVal = ' ';
            var actualVal = ' ';       
            var targetWindow = getTopWindow().getWindowOpener();
            var tmpFieldNameActual = fieldNameActual;
            var tmpFieldNameDisplay = fieldNameDisplay;
            var vfieldNameActual = targetWindow.document.getElementById(tmpFieldNameActual);
            var vfieldNameDisplay = targetWindow.document.getElementById(tmpFieldNameDisplay);
            if (vfieldNameActual==null && vfieldNameDisplay==null) {
                vfieldNameActual=targetWindow.document.forms[0][tmpFieldNameActual];
                vfieldNameDisplay=targetWindow.document.forms[0][tmpFieldNameDisplay];
            }

            if (vfieldNameActual==null && vfieldNameDisplay==null) {
                vfieldNameActual=targetWindow.document.getElementsByName(tmpFieldNameActual)[0];
                vfieldNameDisplay=targetWindow.document.getElementsByName(tmpFieldNameDisplay)[0];
            }

            if (vfieldNameActual==null && vfieldNameDisplay==null) {
                var elem = targetWindow.document.getElementsByTagName("input");
                var att;
                var iarr;
                for(i = 0,iarr = 0; i < elem.length; i++) {
                   att = elem[i].getAttribute("name");
                   if(tmpFieldNameDisplay == att) {
                       vfieldNameDisplay = elem[i];
                       iarr++;
                   }
                   if(tmpFieldNameActual == att) {
                       vfieldNameActual = elem[i];
                       iarr++;
                   }
                   if(iarr == 2) {
                       break;
                   }
               }
           }

            if(fieldNameDisplay != null && fieldNameDisplay != ""){
                displayVal = completeExp.completedRuleText;

                if (displayVal == '')
                {
                    displayVal = ' ';
                }                 
                vfieldNameDisplay.value = displayVal;  
            }

            if(fieldNameActual != null && fieldNameActual != ""){
                actualVal = completeExp.completedRuleActual;
                if (actualVal == '')
                {
                    actualVal = ' ';
                }

                vfieldNameActual.value = actualVal;
          }
       }
       parent.window.closeWindow();
   }
    
}

</script>
</body>
</html>
