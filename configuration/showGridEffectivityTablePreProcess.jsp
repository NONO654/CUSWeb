<%--
  showGBOMPartTablePreProcess.jsp
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

<%@page import="java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.productline.ProductLineCommon"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
                 
<%
  try
  {      
      String strObjIdContext = "";      
      String strContext = emxGetParameter(request, "context");
      boolean isMobileMode = UINavigatorUtil.isMobile(context);  
      boolean isFTRUser = ConfigurationUtil.isFTRUser(context);
	  boolean isCMMUser = ConfigurationUtil.isCMMUser(context);
      String editLink="true";
      String mode="edit";
      if(isMobileMode||(!isFTRUser&&!isCMMUser)){
          editLink="false";
          mode="view";
      }
      if(ProductLineCommon.isNotNull(strContext) && strContext.equalsIgnoreCase("LogicalFeature")){//Product LF->Reports->Logical Structure Effectivity
          
          String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
          String arrObjectIds[] = null;
          arrObjectIds = (String[])(ProductLineUtil.getObjectIdsRelIds(arrTableRowIds)).get("ObjId");
          StringTokenizer st = new StringTokenizer(arrObjectIds[0],"|");
          //Logical Feature Id
          strObjIdContext = st.nextToken();
          %>
          <script language="javascript" type="text/javaScript">          
                var url= "../common/emxIndentedTable.jsp?objectId=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&program=LogicalFeature:getFirstLevelLogicalFeature&type=type_LogicalFeature&mode=<%=XSSUtil.encodeForJavaScript(context,mode)%>&postProcessJPO=LogicalFeature:EffectivityGridApplyProcess&massUpdate=true&table=FTRLogicalFeatureEffectivityTable&editLink=<%=XSSUtil.encodeForJavaScript(context,editLink)%>&header=emxConfiguration.Table.LogicalFeatureEffectivity&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&selection=multiple&sortColumnName=Name&effectivityRelationship=relationship_LogicalFeatures&targetLocation=popup&toolbar=CFFEffectivityFrameworkToolbar&effectivityFilterMode=150&HelpMarker=emxhelplogicaleffectivity";
                //showNonModalDialog(url,860,600,true, '', 'MediumTall');
                  showModalDialog(url,860,600,true,'MediumTall');                
            </script>
          <%       
      }
      else if(ProductLineCommon.isNotNull(strContext) && strContext.equalsIgnoreCase("GBOM")){//LF->GBOM-> Effectivity- to show grid or effectivity column

          strObjIdContext = XSSUtil.encodeForURL(context,emxGetParameter(request, "objectId"));
          String strProdId = XSSUtil.encodeForURL(context,emxGetParameter(request, "prodId"));
          String strAppendURL= "";
    	  //strAppendURL= "StructureEffectivityForExpand|Effectivity"; //Before Decoupling
    	  strAppendURL= "VariantEffectivity|Effectivity"; //After Decoupling
    	  
          // Added code for Logical Feature >> GBOM Category
          String strTableName = "FTRViewGBOMTable";
          if(strProdId == null){
        	  strTableName = "FTRLFGBOMCategoryTable";
          }
          // Added code for Logical Feature >> GBOM Category
          boolean isEffectivityGridActive = ConfigurationUtil.isEffectivityGridActive(context);
          
          if(isEffectivityGridActive && strObjIdContext!=null){//if Grid is on- check if context LF has DV
              LogicalFeature lfBean = new LogicalFeature(strObjIdContext);
              StringList relSelects = new StringList();
              StringList objSelects = new StringList();
              objSelects = new StringList();
              relSelects = new StringList();
              MapList activeDVs = lfBean.getActiveDesignVariants(context,
	  					"", "",
	  					objSelects, relSelects, false, true, 1, 0,
	  					"", DomainObject.EMPTY_STRING,
	  					DomainObject.FILTER_ITEM, "");
              StringList ctxModelList = lfBean.getAllContextModels(context, false);
              
        	  if(ctxModelList==null ||ctxModelList.isEmpty()||activeDVs == null || activeDVs.isEmpty()){
        		  isEffectivityGridActive=false;
        	  }
          }//isFTRUser check missing?          
    	  if(isEffectivityGridActive){//Grid Effectivity Setting ON + LF has DV + LF is not Stand alone- show GRID UX
              %>
              <script language="javascript" type="text/javaScript">          
                    var url= "../common/emxIndentedTable.jsp?objectId=<%=strObjIdContext%>&parentOID=<%=strObjIdContext%>&prodId=<%=strProdId%>&sortColumnName=Name&freezePane=ActionIcons,Name&mode=<%=XSSUtil.encodeForJavaScript(context,mode)%>&isGBOMGrid=true&table=<%=strTableName%>&program=emxFTRPart:getActiveGBOMStructure&selection=multiple&header=emxProduct.GBOMStructureBrowser.ViewGBOMPartTableHeader&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&toolbar=FTRContextGBOMStructureToolbarActions,FTRGBOMCustomFilterToolbar,CFFEffectivityFrameworkToolbar&massUpdate=true&editLink=<%=XSSUtil.encodeForJavaScript(context,editLink)%>&type=type_Part&HelpMarker=emxhelpgbomparttableview&effectivityFilterMode=150&effectivityRelationship=relationship_GBOM&postProcessJPO=LogicalFeature:EffectivityGridApplyProcess";
                    //showNonModalDialog(url,860,600,true, '', 'MediumTall');

                    self.location.href = url;
                </script>
             <%          
          }
          else{ //effectivity columns
              %>
              <script language="javascript" type="text/javaScript">          
                    var url= "../common/emxIndentedTable.jsp?objectId=<%=strObjIdContext%>&parentOID=<%=strObjIdContext%>&prodId=<%=strProdId%>&sortColumnName=Name&freezePane=ActionIcons,Name&postProcessURL=../configuration/ConfigSBApplyProcess.jsp&table=<%=strTableName%>&program=emxFTRPart:getActiveGBOMStructure&selection=multiple&header=emxProduct.GBOMStructureBrowser.ViewGBOMPartTableHeader&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&toolbar=FTRContextGBOMStructureToolbarActions,FTRGBOMCustomFilterToolbar&massUpdate=true&editLink=<%=XSSUtil.encodeForJavaScript(context,editLink)%>&type=type_Part&HelpMarker=emxhelpgbomparttableview&"
                    		+"appendURL=<%=strAppendURL%>&effectivityFilterMode=150&effectivityRelationship=relationship_GBOM&postProcessJPO=LogicalFeature:EffectivityGridApplyProcess&postProcessURL=../configuration/ConfigSBApplyProcess.jsp?applyContext=GBOM";
                    //showNonModalDialog(url,860,600,true, '', 'MediumTall');
                    
                    self.location.href = url;
                </script>
              <%                                               
          } 
      } 
      else if(ProductLineCommon.isNotNull(strContext) && strContext.equalsIgnoreCase("GBOMCategory")){//DEPRECATED SECTION------------------------

          strObjIdContext = XSSUtil.encodeForURL(context,emxGetParameter(request, "objectId"));
          
          boolean isEffectivityGridActive = ConfigurationUtil.isEffectivityGridActive(context);
          
          if(isEffectivityGridActive){
              %>
              <script language="javascript" type="text/javaScript">          
                    var url= "../common/emxIndentedTable.jsp?objectId=<%=strObjIdContext%>&parentOID=<%=strObjIdContext%>&table=FTRGBOMStructureTable&program=emxFTRPart:getCompleteGBOMStructure&selection=multiple&header=emxProduct.Heading.Parts&toolbar=FTRGBOMStructureToolbarActions&type=type_Part&editLink=<%=XSSUtil.encodeForJavaScript(context,editLink)%>&HelpMarker=emxhelpgbom&appendURL=StructureEffectivityMultiRootReadOnly|Effectivity&effectivityFilterMode=150&categoryTreeName=type_LogicalFeature&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration";
                    self.location.href = url;
                </script>
             <%          
          }
          else{
              %>
              <script language="javascript" type="text/javaScript">          
                      var url= "../common/emxIndentedTable.jsp?objectId=<%=strObjIdContext%>&parentOID=<%=strObjIdContext%>&table=FTRGBOMStructureTable&program=emxFTRPart:getCompleteGBOMStructure&selection=multiple&header=emxProduct.Heading.Parts&toolbar=FTRGBOMStructureToolbarActions&type=type_Part&editLink=<%=XSSUtil.encodeForJavaScript(context,editLink)%>&HelpMarker=emxhelpgbom&appendURL=StructureEffectivityForExpand|Effectivity&effectivityFilterMode=150&categoryTreeName=type_LogicalFeature&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration";
                      self.location.href = url;
                </script>
              <%                                               
          } 
      }  
  }
  catch(Exception e){
            session.putValue("error.message", e.getMessage());
  }
  %>
  <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
