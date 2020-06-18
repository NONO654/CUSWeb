<%--
  ConfigurationFeatureCommitPreProcess.jsp
  Copyright (c) 1993-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of
  Dassault Systemes.
  Copyright notice is precautionary only and does not evidence any actual
  or intended publication of such program
--%>

<%-- Common Includes --%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import = "java.util.Enumeration" %>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="java.util.HashMap"%>
<%@page import = "matrix.util.StringList"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationUtil"%>
<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>


<%
boolean bIsError = false;
boolean isCandidateFeatureSelected = true;
boolean isObsoleteStateSelected = false;
StringTokenizer strTokenizer = null;
String strParentOID = "";
String tempBusID = "";
String currentState = "";
boolean isMobileMode = UINavigatorUtil.isMobile(context);
String editLink="true";
if(isMobileMode){
	  editLink="false";
}

  try
  {	        
      String strObjIdContext = emxGetParameter(request, "objectId");
      String[] arrTableRowIds = emxGetParameterValues(request, "emxTableRowId");
      String[] strObjectIdList = new String[arrTableRowIds.length];
      String strLanguage = context.getSession().getLanguage();   
      String strInvalidStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.EditStructureNotAllowed",strLanguage);
      String strObsoleteStateCheck = EnoviaResourceBundle.getProperty(context,"Configuration","emxProduct.Alert.ObsoleteFeatureCommitError",strLanguage);
      String strInvalidCandidate = EnoviaResourceBundle.getProperty(context,"Configuration","emxConfiguration.Alert.CannotPerformNonCandidate",strLanguage);
      
      boolean bInvalidState = ConfigurationUtil.isFrozenState(context, strObjIdContext);
      
      for(int i=0;i<arrTableRowIds.length;i++)
      {     	  
          if(arrTableRowIds[i].indexOf("|") > 0){
                strTokenizer = new StringTokenizer(arrTableRowIds[i] , "|");
                strTokenizer.nextToken();
                tempBusID = strTokenizer.nextToken() ;
                currentState = new DomainObject(tempBusID).getInfo(context,ConfigurationConstants.SELECT_CURRENT);
                strObjectIdList[i] = tempBusID;
                strParentOID = strTokenizer.nextToken() ;
                if(!strObjIdContext.equals(strParentOID)){
                	isCandidateFeatureSelected = false;
                	break;
                }
                if(currentState.equals(ConfigurationConstants.STATE_OBSOLETE)){
                	isObsoleteStateSelected = true;
                	break;
                }
            }
            else{
            	isCandidateFeatureSelected = false;
            	break;
            }
      }
      
      if(isCandidateFeatureSelected == false){    	  
    	    %>
          <script language="javascript" type="text/javaScript">
                alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidCandidate)%>");   
          </script>
            <%
      }
      else if(isObsoleteStateSelected == true){
          %>
          <script language="javascript" type="text/javaScript">
                alert("<%=XSSUtil.encodeForJavaScript(context,strObsoleteStateCheck)%>");
          </script>
         <%
      }
      else if(bInvalidState == true){
          %>
          <script language="javascript" type="text/javaScript">
                alert("<%=XSSUtil.encodeForJavaScript(context,strInvalidStateCheck)%>");
          </script>
         <%
      }
      else{ 
    	  session.setAttribute("selectedCandidateConfigurationFeatures",strObjectIdList);
     %>
     <body>   
     <form name="FTRModelConnectedProductSelection" method="post">
     
     <script language="Javascript">     
         var submitURL = "../common/emxIndentedTable.jsp?program=LogicalFeature:getRelatedProductsForContext&expandProgram=ManufacturingFeature:getTempCommittedManufacturingFeatures&table=FTRModelCommitToProductTable&selection=multiple&header=emxProduct.GBOMStructureBrowser.ViewGBOMPartTableHeader&toolbar=FTRModelManufacturingFeatureCommitToToolbar&objectCompare=false&mode=edit&editLink=<%=XSSUtil.encodeForURL(context,editLink)%>&suiteKey=Configuration&StringResourceFileId=emxConfigurationStringResource&SuiteDirectory=configuration&massPromoteDemote=false&parentOID=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&objectId=<%=XSSUtil.encodeForURL(context,strObjIdContext)%>&connectionProgram=ManufacturingFeature:commitCandidateFeatureToProduct&postProcessJPO=ManufacturingFeature:refreshCandidateFeaturePageOnApply&context=ManufacturingFeature&HelpMarker=emxhelpmanufacturingfeaturecommit";
         showModalDialog(submitURL,575,900,"true","Large"); 
     </script>
     </form>
     </body>
     <% 
    }
      
  }catch(Exception e)
     {
    	    bIsError=true;
    	    session.putValue("error.message", e.getMessage());
     }
     %>
     
     <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
