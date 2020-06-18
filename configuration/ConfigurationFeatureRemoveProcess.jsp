<%--
  ConfigurationFeatureRemoveProcess.jsp
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

<%@page import="com.matrixone.apps.configuration.Model"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationFeature"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.mxType"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<%

  try
  {	  
	  String strLanguage = context.getSession().getLanguage();     
	  String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.FeatureRemoveOptionNotAllowed", strLanguage);
	  
	  String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	  String strParentId = emxGetParameter(request, "objectId");
               
	  String strParentType = new DomainObject(strParentId).getType(context);
	        
      if(arrTableRowIds!=null && arrTableRowIds[0].endsWith("|0")){
	     %>
	        <script language="javascript" type="text/javaScript">
	              alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
	        </script>
	     <%
      }
      else{
   	   boolean unsavedData= false;
	   for(int i=0;i<arrTableRowIds.length;i++) {
		   StringList emxTableRowIds = FrameworkUtil.split(arrTableRowIds[i], "|");
		   if(emxTableRowIds.size()==3 && !((String)emxTableRowIds.get(1)).isEmpty()){
			   unsavedData=true;
			   break;
			   }
	   }
	   if(unsavedData == true){
		        %>
	            <script language="javascript" type="text/javaScript">
	  	            alert("<emxUtil:i18n localize='i18nId'>emxFeature.Alert.UnsavedMarkUp</emxUtil:i18n>");
	  	        </script>
	            <%
  	   }else{
    	  
    	  StringList strObjectIdList = new StringList();
          StringList strParentIdList = new StringList();
          StringTokenizer strTokenizer = null;
          MapList mLstParentChildDetails = new MapList();
          StringList strRelIdList = new StringList();
          
          for(int i=0;i<arrTableRowIds.length;i++)
          {
        	  Map parentChid = new HashMap();
              if(arrTableRowIds[i].indexOf("|") > 0){
                    strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");  
                    String strRelID = strTokenizer.nextToken();
                    String strObjId = strTokenizer.nextToken();
                    String strParentObjId = strTokenizer.nextToken();
                    strObjectIdList.add(strObjId);
                    strParentIdList.add(strParentObjId);
                    strRelIdList.add(strRelID);
                    parentChid.put("ParentOID",strParentObjId);
                    parentChid.put("ChildOID",strObjId);
                    parentChid.put("RelId",strRelID);
                }
                else{
                    strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                    String strObjId = strTokenizer.nextToken();
                    String strParentObjId = strTokenizer.nextToken();
                    strObjectIdList.add(strObjId);
                    strParentIdList.add(strParentObjId);
                    parentChid.put("ParentOID",strParentObjId);
                    parentChid.put("ChildOID",strObjId);
                }
              mLstParentChildDetails.add(parentChid);
              
          }
          
          boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strParentIdList);
          ConfigurationFeature.canRemoveDesignVariantFromProduct(context,mLstParentChildDetails);
          
          if(bInvalidState){
              %>
              <script language="javascript" type="text/javaScript">
                    alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidStateCheck)%>");
              </script>
             <%
          }
          else if(mxType.isOfParentType(context,strParentType,ConfigurationConstants.TYPE_MODEL)){              
        	  String [] reldsArray = new String[strRelIdList.size()];
              
              //Model confModel = new Model(strParentId);
              //confModel.removeCandidateConfigurationFeatures(context, strObjectIdList);
              
              // Call Modeler removeCandidateVariantsAndVariabilityGroup() API to remove Candidate Variants and Variability Groups from the model context
			  com.dassault_systemes.enovia.configuration.modeler.Model model = new com.dassault_systemes.enovia.configuration.modeler.Model(strParentId);
              model.removeCandidateVariantsAndVariabilityGroup(context, (String[])strRelIdList.toArray(reldsArray));
              %>
              <SCRIPT language="javascript" type="text/javaScript">              
                   parent.location.href = parent.location.href;                  
              </script>
              <%
          }
          else{
            %>
            <script language="javascript" type="text/javaScript">            
                parent.editableTable.cut();
            </script>
            <% 
          }
      }
     }
  }
  catch(Exception e){
  	    session.putValue("error.message", e.getMessage());
   }
   %>
   <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
