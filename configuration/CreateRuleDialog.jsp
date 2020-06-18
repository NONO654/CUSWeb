<%@page import = "matrix.util.StringList"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainConstants"%>
<%@page import = "com.matrixone.apps.domain.util.MapList"%>
<%@page import = "java.util.Map"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import = "com.matrixone.apps.productline.ProductLineCommon"%>

<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxValidationInclude.inc"%>
<%@include file = "RuleDialogCommonInclude.inc"%>

<% 
    String strmode = emxGetParameter(request,"modetype");
	String strCommandName = emxGetParameter(request,"commandName");
	String strRuleType = emxGetParameter(request,"ruleType");
	String strObjectId = emxGetParameter(request,"objectId");
	String strParentOID = emxGetParameter(request,"parentOID");
    String immdParentOID = emxGetParameter(request, "parentFeatureId");
	String relId=emxGetParameter(request,"relId");
	String hyperLinkCheck=emxGetParameter(request,"hyperLinkCheck");
	String strLanguage = context.getSession().getLanguage();
	String strAlertIRMarkUp = EnoviaResourceBundle.getProperty(context,"Configuration","emxFeature.Alert.IRMarkUp", strLanguage);
	if(("yes".equalsIgnoreCase(hyperLinkCheck))){
	if("".equals(relId) || ("null".equals(relId))|| relId == null){
		/* StringList RelationshipSelect = new StringList(ConfigurationConstants.SELECT_RELATIONSHIP_ID); 
        StringList sLRelationshipWhere = new StringList();
        sLRelationshipWhere.addElement("to.id" + "==" + strObjectId);
        sLRelationshipWhere.addElement("&&");
        sLRelationshipWhere.addElement("from.id" + "==" + immdParentOID);
        
        //Use Query connection
        StringBuffer sb= new StringBuffer();
        sb.append(ConfigurationConstants.RELATIONSHIP_CONFIGURATION_STRUCTURES);
        sb.append(",");
        sb.append(ConfigurationConstants.RELATIONSHIP_LOGICAL_STRUCTURES);
        sb.append(",");
        sb.append(ConfigurationConstants.RELATIONSHIP_MANUFACTURING_STRUCTURES);

        ProductLineCommon PL = new ProductLineCommon();
        MapList mLRelId = PL.queryConnection(context,
        		    sb.toString(),
                    RelationshipSelect,
                    sLRelationshipWhere.toString());  */
                    
        MapList mLRelId = new MapList(); 
        StringList strSelect = new StringList();
        strSelect.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].id");
        strSelect.add("from["+ ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES +"].id");
        strSelect.add("from["+ ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA +"].id");
        strSelect.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].to.id");
        strSelect.add("from["+ ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES +"].to.id");
        strSelect.add("from["+ ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA +"].to.id");
        
        DomainObject.MULTI_VALUE_LIST.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].id");
        DomainObject.MULTI_VALUE_LIST.add("from["+ ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES +"].id");
        DomainObject.MULTI_VALUE_LIST.add("from["+ ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA +"].id");
        DomainObject.MULTI_VALUE_LIST.add("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].to.id");
        DomainObject.MULTI_VALUE_LIST.add("from["+ ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES +"].to.id");
        DomainObject.MULTI_VALUE_LIST.add("from["+ ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA +"].to.id");
        
        DomainObject ProductORCFObject = new DomainObject(immdParentOID);
        Map mapOfRelIds                = ProductORCFObject.getInfo(context, strSelect);
        
        DomainObject.MULTI_VALUE_LIST.remove("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].id");
        DomainObject.MULTI_VALUE_LIST.remove("from["+ ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES +"].id");
        DomainObject.MULTI_VALUE_LIST.remove("from["+ ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA +"].id");
        DomainObject.MULTI_VALUE_LIST.remove("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].to.id");
        DomainObject.MULTI_VALUE_LIST.remove("from["+ ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES +"].to.id");
        DomainObject.MULTI_VALUE_LIST.remove("from["+ ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA +"].to.id");
        
        StringList listOfConfFeatRelIds = (StringList) mapOfRelIds.get("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].id");
        StringList listOfVarValsRelIds  = (StringList) mapOfRelIds.get("from["+ ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES +"].id");
        StringList listOfGrpVBCriteriaRelIds  = (StringList) mapOfRelIds.get("from["+ ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA +"].id");
        StringList listOfConfFeatIds    = (StringList) mapOfRelIds.get("from["+ ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES +"].to.id");
        StringList listOfVarValsIds     = (StringList) mapOfRelIds.get("from["+ ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES +"].to.id");
        StringList listOfGrpVBCriteriaIds     = (StringList) mapOfRelIds.get("from["+ ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA +"].to.id");
        
        if(listOfConfFeatRelIds != null)
        {
	        for(int j = 0; j < listOfConfFeatRelIds.size(); j++)
	        {
	        	if(strObjectId.equals(listOfConfFeatIds.get(j)))
	        	{
	        		Map mapOfObject = new HashMap();
	        		mapOfObject.put("RelInfo", ConfigurationConstants.RELATIONSHIP_CONFIGURATION_FEATURES);
	        		mapOfObject.put("id[connection]", listOfConfFeatRelIds.get(j));
	        		
	        		mLRelId.add(mapOfObject);
	        	}
	        }
        }
        else if(listOfVarValsRelIds != null)
        {
	        for(int j = 0; j < listOfVarValsRelIds.size(); j++)
	        {
	        	if(strObjectId.equals(listOfVarValsIds.get(j)))
	        	{
	        		Map mapOfObject = new HashMap();
	        		mapOfObject.put("RelInfo", ConfigurationConstants.RELATIONSHIP_VARIANT_VALUES);
	        		mapOfObject.put("id[connection]", listOfVarValsRelIds.get(j));
	        		
	        		mLRelId.add(mapOfObject);
	        	}
	        }
        } 
        else if(listOfGrpVBCriteriaRelIds != null)
        {
	        for(int j = 0; j < listOfGrpVBCriteriaRelIds.size(); j++)
	        {
	        	if(strObjectId.equals(listOfGrpVBCriteriaIds.get(j)))
	        	{
	        		Map mapOfObject = new HashMap();
	        		mapOfObject.put("RelInfo", ConfigurationConstants.RELATIONSHIP_GROUPED_VARIABILITY_CRITERIA);
	        		mapOfObject.put("id[connection]", listOfGrpVBCriteriaRelIds.get(j));
	        		
	        		mLRelId.add(mapOfObject);
	        	}
	        }
        } 
        
        if(mLRelId.size()==0){%>
<script language="javascript" type="text/javaScript">
        	  alert("<%=XSSUtil.encodeForJavaScript(context,strAlertIRMarkUp)%>");      	     
     	      window.closeWindow();  	           
     	     </script>
<%
        }
	}
	}
%>
