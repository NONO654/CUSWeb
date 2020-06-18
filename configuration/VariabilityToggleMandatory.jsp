<%--
  VariabilityToggleMandatory.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc" %>

<%@page import = "java.util.StringTokenizer"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import = "matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
    boolean isRootNodeSelected = false;
    boolean isSubFeatureSelected = false;

    String strLanguage = context.getSession().getLanguage();
    String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
    String strParentId = emxGetParameter(request, "parentOID");
    String strContextId = emxGetParameter(request, "objectId");
    String mode = emxGetParameter(request, "mode");
    String strParentOID = "";    
    String strObjectID = "";
    StringTokenizer strTokenizer = null;
    StringList strObjectIdList = new StringList();
    String strSuccessMsg = "";
    String level = "";
    StringList lstRelIds = new StringList();
    try
    {
    	for(int i=0;i<arrTableRowIds.length;i++)
        {      
            if(arrTableRowIds[i].indexOf("|") > 0){
                  strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                  lstRelIds.add((String) strTokenizer.nextToken());
                  strObjectID = strTokenizer.nextToken() ;  
                  strParentOID = strTokenizer.nextToken() ;
                  level = strTokenizer.nextToken();
                  String[] levelArray = level.split(",");
                  if(levelArray.length>2)
                  {
                	  isSubFeatureSelected = true;
                  }
                /*  if(!strParentId.equals(strParentOID)){
                	  isSubFeatureSelected = true;
                  }*/
                  strObjectIdList.add(strObjectID);
              }
              else{
            	  isRootNodeSelected = true;                         
              }
        }
    	
    	String strType = "";
    	if(ProductLineCommon.isNotNull(strParentOID)){
	    	DomainObject domObj = DomainObject.newInstance(context, strParentOID);
	    	strType = domObj.getInfo(context, DomainConstants.SELECT_TYPE);
    	}
    	String strOnlyCandidateMakeMandatory = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.OnlyCandidateMakeMandatory", strLanguage);
    	MapList mapList = DomainRelationship.getInfo(context, (String[])lstRelIds.toArray(new String[lstRelIds.size()]), new StringList(DomainConstants.SELECT_NAME));
  	    Boolean isCommittedOrMandatoryRel = false;		  
  	    if(mapList.size() > 0 && !ConfigurationConstants.TYPE_PRODUCT_LINE.equalsIgnoreCase(strType))
  	    {
  		  for(int i = 0; i < mapList.size(); i++)
  		  {
  			  Map map = (Map) mapList.get(i);
  			  String strRelName = (String) map.get(DomainConstants.SELECT_NAME);
  			  if(ConfigurationConstants.RELATIONSHIP_COMMITTED_CONFIGURATION_FEATURES.equalsIgnoreCase(strRelName) || ConfigurationConstants.RELATIONSHIP_MANDATORY_CONFIGURATION_FEATURES.equalsIgnoreCase(strRelName)){
  				  isCommittedOrMandatoryRel = true;
  				  break;
  			  }
  		  }
  	    }
  	    
  	    if(isCommittedOrMandatoryRel)
  	    {
  	    	%>
            <script language="javascript" type="text/javaScript">
            alert("<%=strOnlyCandidateMakeMandatory%>");
            </script>
            <%
  	    }
  	    else if(isRootNodeSelected == true){
    		 %>
             <script language="javascript" type="text/javaScript">
                   alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
             </script>
             <%
    	}
    	else if(isSubFeatureSelected == true){
    		 %>
             <script language="javascript" type="text/javaScript">
                   alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotSetMandatory</emxUtil:i18n>");
             </script>
             <%
    	}
    	else
    	{
            if(mode.equals("makeMandatory")){     
    			com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon confGovCommon = new com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon(strContextId);
    			confGovCommon.toggleMandatoryConfigurationFeature(context, strObjectIdList);
                //ConfigurationFeature.makeMandatoryConfigurationFeature(context, strContextId, strObjectIdList); 
                strSuccessMsg = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.MakeMandatorySuccess",strLanguage);
            }
            else if(mode.equals("removeMandatory")){
            	com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon confGovCommon = new com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon(strContextId);
            	confGovCommon.toggleMandatoryConfigurationFeature(context, strObjectIdList); // IR-369131-3DEXPERIENCER2016x- strParentId changes to strContextId for passing object ID not parentID 
                strSuccessMsg = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.RemoveMandatorySuccess",strLanguage);
            }
    		else if(mode.equals("toggleMandatory")){
                //ConfigurationFeature.toggleMandatoryConfigurationFeature(context, strContextId, strObjectIdList);
                com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon confGovCommon = new com.dassault_systemes.enovia.configuration.modeler.ConfigurationGovernanceCommon(strContextId);
                confGovCommon.toggleMandatoryConfigurationFeature(context, strObjectIdList);
                strSuccessMsg = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.ToggleMandatorySuccess",strLanguage);
            }
            %>
                <SCRIPT language="javascript" type="text/javaScript">
                    alert("<%=XSSUtil.encodeForJavaScript(context,strSuccessMsg)%>");
                    parent.location.href = parent.location.href;                  
                </script>
            <%	
    	}        
    }
    catch(Exception e)
    {	
    	String msg = e.toString();
		if(msg.contains("java.lang.Exception:")){
    		msg = msg.replace("java.lang.Exception:","");
    		session.putValue("error.message", msg);
		}
		else{	
			session.putValue("error.message", msg);
		}
    	
    }	
    %>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    
