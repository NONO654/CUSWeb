<%--
  DesignVariantTogglePostProcess.jsp
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

<%@page import="com.matrixone.apps.domain.DomainObject,com.matrixone.apps.domain.DomainRelationship" %>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants,com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>

<%
try
{   
      String strMode = emxGetParameter(request,"mode");
      String strObjId = emxGetParameter(request, "objectId"); 
      String strdvMode = emxGetParameter(request, "dvMode");
      boolean isSlideInDV=false;
      if("slideindv".equalsIgnoreCase(strdvMode)){
    	  isSlideInDV=true;
      }
      String strFeatureId = "";
      String strProductId = "";
      StringTokenizer stContext = new StringTokenizer(strObjId, ",");

      if (stContext.countTokens() > 1) {
          strFeatureId = stContext.nextToken().trim();
          strProductId = stContext.nextToken().trim();
      }else{
          strFeatureId = strObjId;
      }
      
    if(null != strMode && strMode.equalsIgnoreCase("quickAction")){
      	try{        

			if(ConfigurationUtil.isFrozenState(context,strObjId)){
				out.write("responseMsg=FROZEN#");		
			}else{
		        String strDVRELID = emxGetParameter(request, "DVRELID");  
		        String strDVOID = emxGetParameter(request, "DVOID");
		        DomainRelationship domDV = new DomainRelationship(strDVRELID);
		        Hashtable relData = domDV.getRelationshipData(context,new StringList(DomainRelationship.SELECT_NAME));
		        String strDVRelName= relData.get(DomainRelationship.SELECT_NAME).toString();
		        LogicalFeature logicalFTR= new LogicalFeature(strObjId);				
		        boolean bFlag = false;
		    	if(strDVRelName.contains(ConfigurationConstants.RELATIONSHIP_INACTIVE_VARIES_BY)){
			        bFlag=logicalFTR.makeDesignVariantsActive(context,new StringList(strDVOID),null);	 
	            }else{
			        bFlag = logicalFTR.makeDesignVariantsInactive(context,new StringList(strDVOID),null);    
	            }
	          out.write("responseMsg="+bFlag+"#");
	      }    
      	}catch(Exception e){
      		if (e.toString().contains("1500028")) {
            	out.write("responseMsg=NOMODIFY#");	
            }else{
            	out.write("responseMsg="+e.getMessage()+"#");
            }
	      }
	      out.println();
	      out.flush();
	}else if(ConfigurationUtil.isFrozenState(context,strObjId)){
        %>
        <script language = "javascript">
            alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.DVActionsDisabledReleasedorBeyond</emxUtil:i18n>");
        </script>
        <%				
	}else{
      String strContextObjectId[] = emxGetParameterValues(request,"emxTableRowId");
      StringList strActiveDVList = new StringList();
      StringList strInActiveDVList = new StringList();
      String strDVId = "";
      String strDVRelId = "";
      DomainRelationship domDV = null;
      String strDVRelName = "";
      // this MapList is for maintaining the Design Variant relId and the ObjectId
      MapList mLstDVObjAndRelId = new MapList();
      for(int i=0;i<strContextObjectId.length;i++)
      {
             StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");
             strDVRelId=strTokenizer.nextToken(); //Realationship ID
             strDVId=strTokenizer.nextToken(); //Selected DV to remove
             domDV = new DomainRelationship(strDVRelId);
             Map mapDevRelObjIDs = new HashMap();
             Hashtable relData = domDV.getRelationshipData(context,new StringList(DomainRelationship.SELECT_NAME));
             strDVRelName= relData.get(DomainRelationship.SELECT_NAME).toString();
             if(strDVRelName.contains(ConfigurationConstants.RELATIONSHIP_INACTIVE_VARIES_BY)){
            	 strInActiveDVList.add(strDVId);            	 
             }else{
            	 strActiveDVList.add(strDVId);
            	 // add the DV and the Rel ID for the making the DV Invalid / Valid
            	 mapDevRelObjIDs.put(DomainObject.SELECT_ID,strDVId);
            	 mapDevRelObjIDs.put(DomainRelationship.SELECT_ID,strDVRelId);
            	 mLstDVObjAndRelId.add(mapDevRelObjIDs);
             }
      }
      boolean bResult = true;
      if(strMode.equalsIgnoreCase("ActiveInactive")){
    	  if(strActiveDVList.size()>0){
    		  LogicalFeature lfBean = new LogicalFeature(strFeatureId);
    		  bResult = lfBean.makeDesignVariantsInactive(context,strActiveDVList,strProductId);  
    	  }
    	  if(bResult && strInActiveDVList.size()>0){
//    		  LogicalFeature lfBean = new LogicalFeature(strFeatureId);    		  
  //  		  bResult = lfBean.makeDesignVariantsActive(context,strInActiveDVList,strProductId);
    			  for(int i = 0; i < strInActiveDVList.size(); i++){
    			      	      LogicalFeature lfBean = new LogicalFeature(strFeatureId);
    			      		  StringList strList = new StringList();
    			      		  strList.addElement(strInActiveDVList.get(i));
    			      		  bResult = lfBean.makeDesignVariantsActive(context,strList,strProductId);
    			      		  }
    	  }
      }
	  else if (strMode.equalsIgnoreCase("ValidaInvalid")){
		  if(strInActiveDVList.size()>0){
			  String strAlertMessage = i18nNow.getI18nString("emxProduct.Alert.SelectActiveInvalid",bundle,acceptLanguage);
			  bResult = false;
		      %>
	             <Script>
	             alert("<%=XSSUtil.encodeForJavaScript(context,strAlertMessage)%>");
	             </Script>
	          <%
		  }else{
			   LogicalFeature lfBean = new LogicalFeature(strFeatureId);
	           bResult= lfBean.makeDesignVariantsValidOrInvalid(context,mLstDVObjAndRelId,strProductId);
		  }
	  }
      if (bResult) {
          %>
          <script language="javascript" type="text/javaScript">
          var isSlideInDV='<%=isSlideInDV%>';
          if(isSlideInDV  == 'true'){
         		var slideInFrame = findFrame(getTopWindow(),"slideInFrame");
         		slideInFrame.editableTable.loadData();
         		slideInFrame.emxEditableTable.refreshStructureWithOutSort(); 
         }else{
          parent.location.href = parent.location.href;
         }
          </script>
     <%}
	 }
    }catch(Exception e){
            session.putValue("error.message", e.getMessage());
    }
    %>
    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
