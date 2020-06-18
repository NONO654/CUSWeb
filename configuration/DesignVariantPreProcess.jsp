<%--
  DesignVariantPreProcess.jsp
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

<%@page import="com.matrixone.apps.domain.DomainConstants, com.matrixone.apps.domain.util.mxType"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.configuration.ConfigurationConstants, 
                  com.matrixone.apps.configuration.LogicalFeature,
                  com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import = "com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import = "java.util.StringTokenizer"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<%
  try
  {   
      String strMode = emxGetParameter(request,"mode");
      String strObjId = emxGetParameter(request, "objectId");
      String strLanguage = context.getSession().getLanguage();
      
      if(strMode.equalsIgnoreCase("viewDesignVariant"))
      {
           ProductLineUtil utilBean = new ProductLineUtil();
           // selected Table Row Ids
           String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
           // variable to store rel and obj ids
           String strObjIds[] = null;
           // Seperate the Obj and Rel Ids
           if ( strTableRowIds[0].indexOf("|")!=-1 )
           {
                 Map mapIds = (Map)utilBean.getObjectIdsRelIds(strTableRowIds);
                 strObjIds = (String[])mapIds.get("ObjId");
                 StringTokenizer st = new StringTokenizer(strObjIds[0],"|");
                 String strObject = st.nextToken();
                 DomainObject domObj = new DomainObject(strObject);
                 String strType = domObj.getInfo(context,DomainConstants.SELECT_TYPE);
                 if(mxType.isOfParentType(context, strType,ConfigurationConstants.TYPE_LOGICAL_STRUCTURES))
                 {
            %>
                  <script language="javascript" type="text/javaScript">
                    showNonModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObject)%>,<%=XSSUtil.encodeForURL(context,strObjId)%>&portal=FTRConfigurationDesignVariantPortal&contextIndependent=no&mode=portal&header=emxProduct.DesignVariantPortal.ViewDesignVariantHeader&subHeader=emxProduct.DesignVariantPortal.ViewDesignVariantSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview","","",true,true,"Large");
                  </script>
            <%
                 }else{
                	   String strAlertMessage = i18nNow.getI18nString("emxProduct.Alert.SelectFeature",bundle,acceptLanguage);
               %>
                     <Script>
                     alert("<%=XSSUtil.encodeForJavaScript(context,strAlertMessage)%>");
                     </Script>
             <%
                 }
           }
       }
      else if(strMode.equalsIgnoreCase("viewAllLFDesignVariants"))
      {
    	  String strPortalName = "";
    	 
          strPortalName = "FTRConfigurationDesignVariantPortal";
    	  
          ProductLineUtil utilBean = new ProductLineUtil();
          // selected Table Row Ids
          String[] strTableRowIds = emxGetParameterValues(request, "emxTableRowId");
          // variable to store rel and obj ids
          String strObjIds[] = null;
          // Seperate the Obj and Rel Ids
          if(null != strTableRowIds){
          if ( strTableRowIds[0].indexOf("|")!=-1 )
          {
                Map mapIds = (Map)utilBean.getObjectIdsRelIds(strTableRowIds);
                strObjIds = (String[])mapIds.get("ObjId");
                StringTokenizer st = new StringTokenizer(strObjIds[0],"|");
                String strObject = st.nextToken();
              
           %>
                 <script language="javascript" type="text/javaScript">
                 //showNonModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObject)%>,<%=XSSUtil.encodeForURL(context,strObjId)%>&ProductID=<%=XSSUtil.encodeForURL(context,strObjId)%>&portal=<%=XSSUtil.encodeForURL(context,strPortalName)%>&contextIndependent=no&mode=portal&header=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariants&subHeader=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariantsSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview","","",true,true,"Large");
                 showModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObject)%>,<%=XSSUtil.encodeForURL(context,strObjId)%>&ProductID=<%=XSSUtil.encodeForURL(context,strObjId)%>&portal=<%=XSSUtil.encodeForURL(context,strPortalName)%>&contextIndependent=no&mode=portal&header=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariants&subHeader=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariantsSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview","","",true,"Large");
                 </script>
           <%
          }
          }else{
          %>
          <script language="javascript" type="text/javaScript">
             //showNonModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjId)%>,<%=XSSUtil.encodeForURL(context,strObjId)%>&ProductID=<%=XSSUtil.encodeForURL(context,strObjId)%>&portal=<%=XSSUtil.encodeForURL(context,strPortalName)%>&contextIndependent=no&mode=portal&header=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariants&subHeader=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariantsSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview","","",true,true,"Large");
             showModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjId)%>,<%=XSSUtil.encodeForURL(context,strObjId)%>&ProductID=<%=XSSUtil.encodeForURL(context,strObjId)%>&portal=<%=XSSUtil.encodeForURL(context,strPortalName)%>&contextIndependent=no&mode=portal&header=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariants&subHeader=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariantsSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview","","",true,"Large");
           </script>
           <%
          }
       }
	   else if (strMode.equalsIgnoreCase("searchDesignVariant")) {
	          String strObjID = emxGetParameter(request, "objectId");
	          String strdvMode = emxGetParameter(request, "dvMode");
	          String strSearchHeader = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Heading.Search.DesignVariants", strLanguage);
	          
	          boolean isSlideInDV=false;
	          if("slideindv".equalsIgnoreCase(strdvMode)){
	        	  isSlideInDV=true;
	          }	          
	          
	          String strFeatureId="";
	          String strContextObjId="";
	          strFeatureId=strObjID.substring(strObjID.indexOf(",")+1,strObjID.length());
              if(strObjID.indexOf(",")==-1){
            	  strFeatureId = emxGetParameter(request, "prodId");
            	  strContextObjId = strObjID;
              }else{
            	  strContextObjId = strObjID.substring(0,strObjID.indexOf(","));
              }
          	if(ConfigurationUtil.isFrozenState(context,strContextObjId)){
                %>
                <script language = "javascript">
                    alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.DVActionsDisabledReleasedorBeyond</emxUtil:i18n>");
                </script>
                <%				
    	    }else{                  
	          // check for Multiple Part Families
              LogicalFeature compFtr = new LogicalFeature(strContextObjId);
	          String relWhere = DomainObject.EMPTY_STRING;
	          String objWhere = DomainObject.EMPTY_STRING;
	          // Obj and Rel pattern
	          StringBuffer typePattern = new StringBuffer();
	          typePattern.append(ConfigurationConstants.TYPE_PART_FAMILY);
	          StringBuffer relPattern = new StringBuffer();
	
	          int iLevel = 1;

	          MapList objectList = compFtr.getGBOMStructure(context,typePattern.toString() ,
	                  relPattern.toString(), null, null, false, true, iLevel, 0,
	                  objWhere, relWhere, DomainObject.FILTER_ITEM, DomainObject.EMPTY_STRING);
	          if(objectList.size()<=1){
	        	  if(null ==strFeatureId ){
	        		  String ProductID = emxGetParameter(request, "ProductID");
	        		  strFeatureId = ProductID;
	        	  }
		          %>
				  <script language="javascript" type="text/javaScript">
				    
				     //alert(vardvMode);
				    //if(vardvMode == 'true'){
	                //    var urlStr= "../common/emxIndentedTable.jsp?program=LogicalFeature:getValidCFsForDesignVariants&selection=multiple&freezePane=DisplayName,PrimaryImage&toolbar=FTRCFAddAsDVMenu"+
                	//	  "&objectId=<%=XSSUtil.encodeForJavaScript(context,strObjID)%>&HelpMarker=emxhelpfullsearch&AutoFilter=false&editLink=false&table=FTRDVSearchResultsTable&sortColumnName=DisplayName&editLink=true&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&emxSuiteDirectory=configuration&massPromoteDemote=false&objectCompare=false&subHeader=&mode=view&showClipboard=false&displayView=detail&showPageURLIcon=false&rowGrouping=false&export=false&multiColumnSort=false&PrinterFriendly=false&cellwrap=false&header=emxProduct.Table.Label.SelectDesignVariants&hideHeader=false&cancelLabel=emxProduct.Button.Cancel&triggerValidation=false&mode=view";
                	//	  showModalDialog(urlStr,"","",true,"Large");
				    //}else{
                     //,PARENT_PRODUCT,PARENT_PRODUCTLINE need to add to inclusion list
				    	 showModalDialog("../common/emxFullSearch.jsp?filters={\'txtTextSearch\':[\'Equals|*\']}&field=TYPES=type_Variant,type_VariabilityGroup,type_ConfigurationFeature:CURRENT!=policy_ConfigurationFeature.state_Obsolete,policy_PerpetualResource.state_Obsolete:HAS_CONFIG_CHILDREN=TRUE&excludeOIDprogram=LogicalFeature:excludeDesignVariant&table=FTRConfigurationFeaturesSearchResultsTable&showInitialResults=false&selection=multiple&submitAction=refreshCaller&header=<%=XSSUtil.encodeForURL(context,strSearchHeader)%>&hideHeader=true&formInclusionList=DISPLAY_NAME,PARENT_PRODUCT,PARENT_PRODUCTLINE&HelpMarker=emxhelpfullsearch&submitURL=../configuration/DesignVariantAddPostProcess.jsp&objectId=<%=XSSUtil.encodeForURL(context,strContextObjId)%>&prodId=<%=XSSUtil.encodeForURL(context,strFeatureId)%><% if(isSlideInDV==true) { %>&dvMode=slideindv<% } %>","","",true,"Medium");
	                //}
				 </script>
		   <%} else{
			       String strAlertMessage = i18nNow.getI18nString("emxConfiguration.Error.MultiplePartFamilies",bundle,acceptLanguage);
                   %>
                  <Script>
                  alert("<%=XSSUtil.encodeForJavaScript(context,strAlertMessage)%>");
                  </Script>
                  <%
		        }
    	    }
      }
	   else if(strMode.equalsIgnoreCase("RMBviewDesignVariant"))
      {
	       String objId = (String)emxGetParameter(request, "objectId");
	       String prodId = (String)emxGetParameter(request, "productID");
          String strPortalName = "FTRConfigurationDesignVariantPortal";
          
            %>
                  <script language="javascript" type="text/javaScript">
                 //showNonModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,objId)%>,<%=XSSUtil.encodeForURL(context,prodId)%>&ProductID=<%=XSSUtil.encodeForURL(context,prodId)%>&portal=<%=XSSUtil.encodeForURL(context,strPortalName)%>&contextIndependent=no&mode=portal&header=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariants&subHeader=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariantsSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview","","",true,true,"Large");
                   showModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,objId)%>,<%=XSSUtil.encodeForURL(context,prodId)%>&ProductID=<%=XSSUtil.encodeForURL(context,prodId)%>&portal=<%=XSSUtil.encodeForURL(context,strPortalName)%>&contextIndependent=no&mode=portal&header=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariants&subHeader=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariantsSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview","","",true,"Large");
                 </script>
            <%
           
       }
   // Added for IR-190361V6R2014
      
	   else if(strMode.equalsIgnoreCase("hyperlinkViewDesignVariant"))
	   {
		       String objId = (String)emxGetParameter(request, "objectId");
		       String prodId = (String)emxGetParameter(request, "productID");
	           String strPortalName = "FTRConfigurationDesignVariantPortal";
	           %>
	                 <script language="javascript" type="text/javaScript">
	                 //showNonModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,objId)%>,<%=XSSUtil.encodeForURL(context,prodId)%>&ProductID=<%=XSSUtil.encodeForURL(context,prodId)%>&portal=<%=XSSUtil.encodeForURL(context,strPortalName)%>&contextIndependent=no&mode=portal&header=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariants&subHeader=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariantsSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview","","",true,true,"Large");
	                   showModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,objId)%>,<%=XSSUtil.encodeForURL(context,prodId)%>&ProductID=<%=XSSUtil.encodeForURL(context,prodId)%>&portal=<%=XSSUtil.encodeForURL(context,strPortalName)%>&contextIndependent=no&mode=portal&header=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariants&subHeader=emxConfiguration.DesignVariantPortal.LogicalFeatureDesignVariantsSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview","","",true,"Large");       
	                 </script>
	           <%
	   }
	   else if(strMode.equalsIgnoreCase("hyperlinkViewDesignVariantSlideIn"))
	   {
		       String objId = (String)emxGetParameter(request, "objectId");
		       String prodId = (String)emxGetParameter(request, "productID");
		       String strLevel = emxGetParameter(request, "strLevel");
	           %>
	                 <script language="javascript" type="text/javaScript">
	                  var varLevel='<%=XSSUtil.encodeForJavaScript(context,strLevel)%>';
	                  //alert(varLevel);
                      var urlStr= "../common/emxIndentedTable.jsp?program=LogicalFeature:getActiveInactiveDesignVariants&selection=multiple&freezePane=DisplayName,PrimaryImage&toolbar=FTRDesignVariantToolbarActions"+
                    		  "&objectId=<%=XSSUtil.encodeForJavaScript(context,objId)%>&strLevel=<%=XSSUtil.encodeForJavaScript(context,strLevel)%>&AutoFilter=false&editLink=false&table=FTRAllDVsTable&sortColumnName=DisplayName&editLink=true&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&emxSuiteDirectory=configuration&massPromoteDemote=false&objectCompare=false&mode=view&showClipboard=false&displayView=detail&showPageURLIcon=false&rowGrouping=false&export=false&multiColumnSort=false&PrinterFriendly=false&autofilter=false&cellwrap=false&HelpMarker=emxhelpdesignvariantslideinview&autoFilter=false&header=emxProduct.DesignVariantPortal.ViewDesignVariantHeader&hideHeader=false&dvMode=slideindv&submitLabel=emxProduct.Button.Close&submitURL=../configuration/DesignVariantSlideInProcess.jsp&objectId=<%=XSSUtil.encodeForJavaScript(context,objId)%>";
                      getTopWindow().showSlideInDialog(urlStr, "false","","","600");
	                 </script>
	           <%
	   }
      
      
   // End of IR-190361V6R2014
   
	   else if(strMode.equalsIgnoreCase("viewConfigurationFeatures")){
    	   String objId = (String)emxGetParameter(request, "objectId");
	       String  contextProductOID =  "";
	       
	       if(null != objId){
	       StringTokenizer objIDs = new StringTokenizer(objId, ",");
			if(objIDs.countTokens()>1){
				// Context Feature ID
				objId = objIDs.nextToken().trim();
				// Context Product ID
				contextProductOID = objIDs.nextToken().trim();
			}else{
	      		 contextProductOID = (String)emxGetParameter(request, "contextProductOID");
			}
	       }else{
	    	  
	      		contextProductOID = (String)emxGetParameter(request, "contextProductOID");
	      		objId = contextProductOID;
			}
			 String url= "../common/emxRefreshChannel.jsp?portal=FTRConfigurationDesignVariantPortal&channel=FTRDVConfigurationFeatureChannel&isIndentedTable=true&contextIndependent=no&mode=insert&objectId=" + objId +"," +contextProductOID;
			 String url1= "../common/emxRefreshChannel.jsp?portal=FTRConfigurationDesignVariantPortal&channel=FTRDVConfigurationOptionChannel&isIndentedTable=true&contextIndependent=no&mode=insert&objectId=" + objId +"," +contextProductOID;
           %>
           <script language="javascript" type="text/javaScript">
    	   var oidnew='<%=XSSUtil.encodeForJavaScript(context,objId)%>';
    	   var contextProductOID='<%=XSSUtil.encodeForJavaScript(context,contextProductOID)%>';
    	   
           var CFCHANNEL;
           CFCHANNEL = getTopWindow().findFrame(getTopWindow(),"FTRDVConfigurationFeatureCommand");	
    	   var prevCFCHANNELURL=CFCHANNEL.location.href;
    	   if(prevCFCHANNELURL.indexOf("&reload=reload") == -1){
    	    prevCFCHANNELURL=prevCFCHANNELURL+"&reload=reload";
    	   }
    	   var oidold=prevCFCHANNELURL.substring(prevCFCHANNELURL.indexOf("objectId=")+9, prevCFCHANNELURL.indexOf("&", prevCFCHANNELURL.indexOf("objectId=")));
    	   var res = prevCFCHANNELURL.replace("objectId="+oidold, "objectId="+oidnew+","+contextProductOID);
    	   var newCFCHANNELURL = res.replace("parentOID="+oidold, "parentOID="+oidnew+","+contextProductOID);
    	   CFCHANNEL.location.href=newCFCHANNELURL;
    	   
    	   var COCHANNEL;
    	   COCHANNEL = getTopWindow().findFrame(getTopWindow(),"FTRDVConfigurationOptionCommand");	
    	   var prevCOCHANNELURL=COCHANNEL.location.href;
    	   if(prevCOCHANNELURL.indexOf("&reload=reload") == -1){
    	    prevCOCHANNELURL=prevCOCHANNELURL+"&reload=reload";
    	   }
    	   var oidold=prevCOCHANNELURL.substring(prevCOCHANNELURL.indexOf("objectId=")+9, prevCOCHANNELURL.indexOf("&", prevCOCHANNELURL.indexOf("objectId=")));
    	   var res = prevCOCHANNELURL.replace("objectId="+oidold, "objectId="+oidnew+","+contextProductOID);
    	   var newCOCHANNELURL = res.replace("parentOID="+oidold, "parentOID="+oidnew+","+contextProductOID);
    	   COCHANNEL.location.href=newCOCHANNELURL;
    	   
    	   </script>
       <% 
       }
	   else{
           String strobjectId = emxGetParameter(request,"objectId");
           StringTokenizer st = new StringTokenizer(strobjectId,",");
           String strObject = st.nextToken();
           String strParent = st.nextToken();
           String strObjID = strObject;
           if(strParent!=null && !strParent.equals("null")){
        	   strObjID = strObjID + ","+ strParent;
           }
                 
                 DomainObject domObj = new DomainObject(strObject);
                 String strType = domObj.getInfo(context,DomainConstants.SELECT_TYPE);
                 if(mxType.isOfParentType(context, strType,ConfigurationConstants.TYPE_LOGICAL_STRUCTURES))
                 {
                	 if(strParent!=null && !strParent.equals("null") && !strMode.equalsIgnoreCase("viewDesignVariantinLF") )
                	 {
                		 %>
                         <script language="javascript" type="text/javaScript">
                         showNonModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjID)%>&portal=FTRConfigurationDesignVariantPortal&mode=portal&contextIndependent=no&header=emxProduct.DesignVariantPortal.ViewDesignVariantHeader&subHeader=emxProduct.DesignVariantPortal.ViewDesignVariantSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview",860,600, true,true,"Large");
                         </script>
                         <%
                		 
                	 }
                	 else{
                		 %>
                         <script language="javascript" type="text/javaScript">
                          showNonModalDialog("../common/emxPortal.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjID)%>&portal=FTRConfigurationContextDesignVariantPortal&mode=portal&contextIndependent=yes&header=emxProduct.DesignVariantPortal.ViewDesignVariantHeader&subHeader=emxProduct.DesignVariantPortal.ViewDesignVariantSubHeader&suiteKey=Configuration&HelpMarker=emxhelpdesignvariantview",860,600, true,true,"Large");
                         </script>
                   <%
                		 
                	 }
            
                 }
           }
    }catch(Exception e)
     {
            session.putValue("error.message", e.getMessage());
     }
     %>
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
