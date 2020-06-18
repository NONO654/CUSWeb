
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
 
      String strObjId = emxGetParameter(request, "objectId");
      String strLanguage = context.getSession().getLanguage();
      String parentId = (String)emxGetParameter(request, "parentOID");
   	  String strVariabilityAllocationNotSupportedForCFCO = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.VariabilityAllocation.Alert.ConfigurationFeatureNotAllowed", strLanguage);
	  StringBuffer sbSelectedTableIds = new StringBuffer();
	  String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
	  if(arrTableRowIds != null && arrTableRowIds.length > 0){
	      // check if the selected row is root node, if yes then throw exception that 
	      // Allocation cannot be done on Root Node.
	      if(arrTableRowIds[0].endsWith("|0"))
	      {
	          %>
	          <script language="javascript" type="text/javaScript">
	              alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.CannotPerform</emxUtil:i18n>");
	          </script>
	         <%
	      }else{
	    	  boolean isCFCO = false;
    		  StringList strObjectIdList = new StringList();
    	      StringTokenizer strTokenizer = null;
    		  String strObjectID = "";
  	          StringList variantSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIANT);
  	          StringList variantValueSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIANTVALUE);
  	          StringList variabilityGroupSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIABILITYGROUP);
  	          StringList variabilityOptionSubTypes = ProductLineUtil.getChildTypesIncludingSelf(context, ConfigurationConstants.TYPE_VARIABILITYOPTION);
    	      for(int i=0;i<arrTableRowIds.length;i++)
    		    { 
    		    	if(arrTableRowIds[i].indexOf("|") > 0){
    		              strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
    		              strTokenizer.nextToken();				              				              
    		              strObjectID = strTokenizer.nextToken() ;				              
    		              strObjectIdList.add(strObjectID);
    		          }
    		          else{
    		        	  strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
    		        	  strObjectID = strTokenizer.nextToken() ;
    		        	  strObjectIdList.add(strObjectID);				        	  
    		          }
    		    }
    	      
    	      String[] oidsArray = new String[strObjectIdList.size()];
    	      StringList objectSelects = new StringList();
    	      objectSelects.addElement(ConfigurationConstants.SELECT_TYPE);
    	      objectSelects.addElement(ConfigurationConstants.SELECT_ID);
    	      MapList mapList = new MapList();
    	      mapList = DomainObject.getInfo(context, (String[]) strObjectIdList.toArray(oidsArray), objectSelects);
    	      for(int j = 0; j < mapList.size(); j++){
	    		  Map objMap = (Map)mapList.get(j);	
	        	  String strType = (String)objMap.get(ConfigurationConstants.SELECT_TYPE);
	        	  String ObjId = (String)objMap.get(ConfigurationConstants.SELECT_ID);
      	          if(!variantSubTypes.contains(strType) && !variantValueSubTypes.contains(strType) &&
        	        		!variabilityGroupSubTypes.contains(strType) && !variabilityOptionSubTypes.contains(strType) ){
        	        	  %>
                          <script language="javascript" type="text/javaScript">
                                alert("<%=XSSUtil.encodeForJavaScript(context,strVariabilityAllocationNotSupportedForCFCO)%>");
                          </script>
                         <%
                         isCFCO = true;
                         break;
        	          }
      	          sbSelectedTableIds.append(ObjId);
      	          sbSelectedTableIds.append(",");      	          
	    	  }  	  
    	      
    	      if(!isCFCO){
        	      String strSelectedTableIds = sbSelectedTableIds.substring(0, sbSelectedTableIds.lastIndexOf(","));
        	      //dvMode = slideindv passed to re-use showheader() in FeatureOptionValidation
        	      %>
                  <script language="javascript" type="text/javaScript">          
                   var urlStr= "../common/emxIndentedTable.jsp?program=ConfigurationFeature:getVariabilityStructureAllocationMatixProductContext"+
                  	  "&freezePane=DisplayName"+
                 		  "&parentID=<%=XSSUtil.encodeForJavaScript(context,parentId)%>"+
                 		  "&objectId=<%=XSSUtil.encodeForJavaScript(context,parentId)%>"+
                 		  "&emxTableRowId=<%=strSelectedTableIds%>"+
                 		  "&AutoFilter=false&editLink=false&table=FTRAllocationMatrixTable&dvMode=slideindv"+
                 		  "&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&emxSuiteDirectory=configuration"+
                 		  "&massPromoteDemote=false&objectCompare=false&mode=view&showClipboard=false&displayView=detail&showPageURLIcon=false"+
                 		  "&rowGrouping=false&rowGroupingColumnNames=Parent&export=false&multiColumnSort=false&PrinterFriendly=false&autofilter=false&cellwrap=false"+
                 		  "&HelpMarker=emxhelpvariantallocation&autoFilter=false&hideHeader=false&header=emxConfiguration.Table.Heading.VariabilityAllocation"+
                 		  "&submitLabel=emxProduct.Button.Close"+
                 		  "&submitURL=javascript:getTopWindow().closeSlideInDialog()";
                   getTopWindow().showSlideInDialog(urlStr, "false","","","600");
                  </script>
                  <%
    	      }
	      }		  
	  }else{
	      %>
          <script language="javascript" type="text/javaScript">          
           var urlStr= "../common/emxIndentedTable.jsp?program=ConfigurationFeature:getVariabilityStructureAllocationMatixProductContext"+
          	  "&freezePane=DisplayName"+
         		  "&parentID=<%=XSSUtil.encodeForJavaScript(context,parentId)%>"+
         		  "&objectId=<%=XSSUtil.encodeForJavaScript(context,parentId)%>"+
         		  "&emxTableRowId=<%=sbSelectedTableIds.toString()%>"+
         		  "&AutoFilter=false&editLink=false&table=FTRAllocationMatrixTable&dvMode=slideindv"+
         		  "&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&emxSuiteDirectory=configuration"+
         		  "&massPromoteDemote=false&objectCompare=false&mode=view&showClipboard=false&displayView=detail&showPageURLIcon=false"+
         		  "&rowGrouping=false&rowGroupingColumnNames=Parent&export=false&multiColumnSort=false&PrinterFriendly=false&autofilter=false&cellwrap=false"+
         		  "&HelpMarker=emxhelpvariantallocation&autoFilter=false&hideHeader=false&header=emxConfiguration.Table.Heading.VariabilityAllocation"+
         		  "&submitLabel=emxProduct.Button.Close"+
         		  "&submitURL=javascript:getTopWindow().closeSlideInDialog()";
           getTopWindow().showSlideInDialog(urlStr, "false","","","600");
          </script>
          <%
	  }

  }catch(Exception e)
     {
            session.putValue("error.message", e.getMessage());
     }
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

