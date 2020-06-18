<%--
  ConfigurationFeatureAddExistingPostProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.configuration.Model"%>
<%@page import="matrix.util.StringList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.Hashtable"%>
<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<%
  try
  {  
     String strObjId = emxGetParameter(request, "objectId");
     String parentOID = emxGetParameter(request, "parentOID");
     String isModel = emxGetParameter(request,"isModel");
     String strLanguage = context.getSession().getLanguage();
     String parentForIRule = emxGetParameter(request, "parentForIRule");
     String strKeyInTypeCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.KeyInTypeCheck", strLanguage);
     String strContextNotSupportedForConfigurationFeature = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForConfigurationFeature",strLanguage);
     String strContextNotSupportedForConfigurationOption = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Feature.Create.ContextNotSupportedForConfigurationOption",strLanguage);
     String strFullSearchSelection = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FullSearch.Selection",strLanguage);
     String callbackFunctionName = "addToSelected"; 
     String frameName = emxGetParameter(request, "frameName");
     String strArrSelectedTableRowId[] = emxGetParameterValues(request, "emxTableRowId");
     
    //If the selection are not made in Search results page  
     if(strArrSelectedTableRowId==null){
	     %>    
	       <script language="javascript" type="text/javaScript">
	           alert("<%=XSSUtil.encodeForJavaScript(context,strFullSearchSelection)%>");
	       </script>
	     <%
	 }        
     else{
    	     // Set RPE variable to skip the Cyclic condition Check
    	     PropertyUtil.setGlobalRPEValue(context,"CyclicCheckRequired","False");
	         Map mpSelectedFeatures = new LinkedHashMap();	         
	         String strSelectedObject = "";
	         String xml = "";
	         String strFeatureType = "";
	         String relType = "";
	         boolean isValidationFailed = false;
	         	         
	         DomainObject parentObj = new DomainObject(strObjId); 
	         
	         StringList objectSelectList = new StringList();
	         objectSelectList.addElement(ConfigurationConstants.SELECT_TYPE);
	         objectSelectList.addElement(ConfigurationConstants.SELECT_ATTRIBUTE_KEYIN_TYPE);
	         Hashtable parentInfoTable = (Hashtable) parentObj.getInfo(context, objectSelectList);
	         
	         String strParentType = (String)parentInfoTable.get(ConfigurationConstants.SELECT_TYPE);
	         String strParentKeyInType = (String)parentInfoTable.get((ConfigurationConstants.SELECT_ATTRIBUTE_KEYIN_TYPE));
         
	         StringList strObjectIdList = new StringList();
	         ConfigurationUtil util = new ConfigurationUtil();
	         
	         StringList cfSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_CONFIGURATION_FEATURE);
	         StringList plSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_PRODUCT_LINE);
	         StringList modSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_MODEL);
	         StringList prdSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_PRODUCTS);
	         StringList coSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_CONFIGURATION_OPTION);
	          
	         for(int i=0;i<strArrSelectedTableRowId.length;i++)
	         {   //TODO- Use emxFramework split() [A69]
	             StringTokenizer strTokenizer = new StringTokenizer(strArrSelectedTableRowId[i] ,"|");
	             
	             //Extracting the Object Id from the String.
	             for(int j=0;j<strTokenizer.countTokens();j++)
	             {
	            	 strSelectedObject = strTokenizer.nextElement().toString();	            
	            	 strObjectIdList.addElement(strSelectedObject);
	                  break;
	             }
	         }
	         StringList strNewObjectIdList = new StringList(strObjectIdList);
	         strNewObjectIdList.addElement(strObjId);
	             String[] StrArr = new String[]{};
	             StrArr = (String[])strNewObjectIdList.toArray(StrArr);
	             
	             String SELECT_REVISIONS_ID = "revisions.id";
	             StringList objectSelects = new StringList();
                 objectSelects.add(DomainConstants.SELECT_TYPE);
                 objectSelects.add(ConfigurationConstants.SELECT_ID);
                 objectSelects.add(SELECT_REVISIONS_ID);
                 objectSelects.add("attribute["+ConfigurationConstants.ATTRIBUTE_KEY_IN_TYPE+"]");
                 objectSelects.add("attribute["+ConfigurationConstants.ATTRIBUTE_CONFIGURATION_SELECTION_TYPE+"]");
	             MapList objectDetails = DomainObject.getInfo(context, StrArr, objectSelects);
	             Map mpFeatureType = new HashMap();

	             for(int k=0;k<objectDetails.size();k++){
						Map mpTypeVal = (Map) objectDetails.get(k);
						String strID = (String) mpTypeVal.get(ConfigurationConstants.SELECT_ID);
						String strFeatureType1 = (String) mpTypeVal.get(DomainConstants.SELECT_TYPE);
						mpFeatureType.put(strID, strFeatureType1);
					}

	             Map mpRevisionId = new HashMap();
	             for(int l=0;l<objectDetails.size();l++){
						Map mpRevIdVal = (Map) objectDetails.get(l);
						String strID = (String) mpRevIdVal.get(ConfigurationConstants.SELECT_ID);
						List strKeySet = Arrays.asList(mpRevIdVal.keySet().toArray());
			             StringList strRevisionsIDs = new StringList();
						 for(int m=0;m<strKeySet.size();m++){
							 String strKey = (String) strKeySet.get(m);
							 if(ProductLineCommon.isNotNull(strKey) && !strKey.equalsIgnoreCase("id") && !strKey.equalsIgnoreCase("type") &&
									 !strKey.equalsIgnoreCase("attribute[Key-In Type]") && !strKey.equalsIgnoreCase("attribute[Configuration Selection Type]")){
								 String strRevID = (String) mpRevIdVal.get(strKey);
								 strRevisionsIDs.add(strRevID);
							 }
						 }
						mpRevisionId.put(strID, strRevisionsIDs);
					}
	             
	             Map mpAttributeVal = new HashMap();
	             for(int y=0;y<objectDetails.size();y++){
	            	    MapList mLAttrValues = new MapList();
						Map mpAttrVal = (Map) objectDetails.get(y);
						String strID = (String) mpAttrVal.get(ConfigurationConstants.SELECT_ID);
						Map mpAttr = new HashMap();
						mpAttr.put("AttributekeyInType",mpAttrVal.get("attribute["+ConfigurationConstants.ATTRIBUTE_KEY_IN_TYPE+"]"));
						mpAttr.put("AttributeAllowedFeatureSelections",mpAttrVal.get("attribute["+ConfigurationConstants.ATTRIBUTE_CONFIGURATION_SELECTION_TYPE+"]"));
						mLAttrValues.add(mpAttr);
						mpAttributeVal.put(strID, mLAttrValues);
					}
	             
             for(int x=0;x<strArrSelectedTableRowId.length;x++){
            	 StringTokenizer strTokenizer = new StringTokenizer(strArrSelectedTableRowId[x] ,"|");
	             for(int j=0;j<strTokenizer.countTokens();j++)
	             {
	            	 strSelectedObject = strTokenizer.nextElement().toString();	            
	                  break;
	             }
	             
	             strFeatureType = (String) mpFeatureType.get(strSelectedObject);
	             
	             if( !cfSubTypes.contains(strParentType) &&  !plSubTypes.contains(strParentType) && !prdSubTypes.contains(strParentType)&& !modSubTypes.contains(strParentType))
	             {
	            	 %>
	                 <script language="javascript" type="text/javaScript">
	                       alert("<%=XSSUtil.encodeForJavaScript(context,strContextNotSupportedForConfigurationFeature)%>");
	                 </script>
		            <%
		            isValidationFailed = true;
		            break;
	             }
	             //If the context Configuration Feature is defined to have Key-In type other than Blank, then the Subfeature defined under it can only be of type Configuration Option
	             else if(strParentKeyInType != null && !"".equals(strParentKeyInType) && !strParentKeyInType.equalsIgnoreCase("Blank") && !coSubTypes.contains(strFeatureType))
	             {
	                 %>
	                 <script language="javascript" type="text/javaScript">
	                       alert("<%=XSSUtil.encodeForJavaScript(context,strKeyInTypeCheck)%>");
	                 </script>
	                <%
	                isValidationFailed = true;
	                break;
	             }
	             else if(coSubTypes.contains(strFeatureType) && !cfSubTypes.contains(strParentType) )
	             {
	                 %>
	                 <script language="javascript" type="text/javaScript">
	                       alert("<%=XSSUtil.encodeForJavaScript(context,strContextNotSupportedForConfigurationOption)%>");
	                 </script>
	                <%
	                isValidationFailed = true;
	                break;
	             }
	             else{	            	 
	            	 relType = cfSubTypes.contains(strFeatureType)?"relationship_ConfigurationFeatures": "relationship_ConfigurationOptions";
	            	 mpSelectedFeatures.put(strSelectedObject, relType);
	             }
	          }
	                      
	         if(!isValidationFailed){
	        	// checking for different RDO alert
	             Set keySet = mpSelectedFeatures.keySet();
	             String[] selectedFetureIDList = new String[keySet.size()]; 
	             selectedFetureIDList = (String[])keySet.toArray(selectedFetureIDList);	             
	             String strContext = "true".equals(isModel)? parentOID: strObjId;

	             if("true".equals(isModel)){	             
                     // Call Modeler connectCandidateVariantsAndVariabilityGroup() API to connect Variant/VariabilityGroup Object.
					    com.dassault_systemes.enovia.configuration.modeler.Model model = new com.dassault_systemes.enovia.configuration.modeler.Model(parentOID);
					    model.connectCandidateVariantsAndVariabilityGroup(context, selectedFetureIDList);
                 %>
                 <script language="javascript" type="text/javaScript">
                         //TODO change below refresh page type to "find frame" [A69]
                         //alert(window.parent.getTopWindow().opener.parent.name); --coming as FTRModelCandidateConfigurationFeatures
                         var parentWindowToRefresh=window.parent.getTopWindow().getWindowOpener().parent;
                 if(parentWindowToRefresh!=null){
                	 parentWindowToRefresh.editableTable.loadData();
                	 parentWindowToRefresh.rebuildView();
                 }
                 getTopWindow().closeWindow();
                 </script>
                 <%
                 }else{
	             
	             // no need to check for Cyclic Condition. As CF under CF is not possible now.IR-536586-3DEXPERIENCER2018x
	             boolean isRDOMismatch = ConfigurationUtil.isRDODifferent(context, selectedFetureIDList, strContext);	
	             boolean isUserAgree = true;
	             
	             if(isRDOMismatch){
	            	 %>
	                 <script>
	                  var alertMsg = "<%=i18nNow.getI18nString("emxConfiguration.Alert.DifferentRDO",bundle,acceptLanguage)%>"
	                  var msg = confirm(alertMsg);                  
	                  if(!msg){
	                	  getTopWindow().window.location.href = "../common/emxCloseWindow.jsp"; 
	                	  <%   
                          isUserAgree = false;
                          %>
	                  }                  
	                  else{
	                     <%   
	                        isUserAgree = true;
	                     %>
	                 }                   
	                  </script>
	                  <%
	             }
	             
	             if(isUserAgree){
                             HashMap paramMap = new HashMap();
                             paramMap.put("objectId", strObjId);
                             paramMap.put("SelectionCriteria",ConfigurationConstants.RANGE_VALUE_MUST);
                             paramMap.put("objectCreation","Existing");
                             try {
                             xml = ConfigurationFeature.getXMLForSBCreateForMultipleFeatures(context, paramMap, mpSelectedFeatures, mpAttributeVal,strObjectIdList);
                           //xml = FrameworkUtil.findAndReplace(xml,"'","\\'");
                             } catch (Exception ex) {
                               if (ex.toString() != null && (ex.toString().trim()).length() > 0)
                               emxNavErrorObject.addMessage(ex.toString().trim()); 
                             }  
                            
                             %>             
                             <script language="javascript" type="text/javaScript">
                             var callback = null;
                             // eval(getTopWindow().getWindowOpener().parent.emxEditableTable.<%=callbackFunctionName%>);
                             if(typeof getTopWindow().SnN != 'undefined' && getTopWindow().SnN.FROM_SNN || !(getTopWindow().getWindowOpener())){
                            	var contentFrame = findFrame(getTopWindow(),"detailsDisplay");
                             	callback  = eval(contentFrame.emxEditableTable.<%=callbackFunctionName%>);
                             }
                             else{
                            	var contentFrameObj = findFrame(window.parent.getTopWindow().getWindowOpener().parent.getTopWindow(),"detailsDisplay");
                             	callback = eval(contentFrameObj.emxEditableTable.<%=callbackFunctionName%>);
                             }
                             var oxmlstatus = callback('<xss:encodeForJavaScript><%=xml%></xss:encodeForJavaScript>');
                             if(getTopWindow().getWindowOpener())
                           	 {
                           	 	getTopWindow().closeWindow();
                           	 }
                             else{
                            	getTopWindow().closeWindowShadeDialog();
                     		getTopWindow().closeWindow();
                             }
                             </script>
                            <%
	                   }
	         }	  
	       }   
         }
  }catch(Exception e)
  {
        session.putValue("error.message", e.getMessage());
  }
  %>
  
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
