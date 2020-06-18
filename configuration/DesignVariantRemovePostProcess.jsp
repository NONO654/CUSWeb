<%--
  DesignVariantRemovePostProcess.jsp
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

<%@page import = "com.matrixone.apps.configuration.LogicalFeature"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
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
      String strObjID = emxGetParameter(request, "objectId");      
      String strContextObjectId[] =emxGetParameterValues(request, "emxTableRowId");
      String strdvMode = emxGetParameter(request, "dvMode");
      boolean isSlideInDV=false;
      if("slideindv".equalsIgnoreCase(strdvMode)){
    	  isSlideInDV=true;
      }
      //in case of quick action
      String strMode = emxGetParameter(request, "mode");
      if(null != strMode && strMode.equalsIgnoreCase("quickAction")){
	      	try{        
	      	  String strDVRELID = emxGetParameter(request, "DVRELID");  
	      	  String strDVOID = emxGetParameter(request, "DVOID");
				if(ConfigurationUtil.isFrozenState(context,strObjID)){
					out.write("responseMsg=FROZEN#");		
				}else{
			          LogicalFeature logicalFTR= new LogicalFeature(strObjID);
			          StringList slDVRemove=new StringList();
			          slDVRemove.add(strDVOID);
			          boolean bFlag = logicalFTR.removeDesignVariants(context,slDVRemove);  
			          out.write("responseMsg="+bFlag+"#");
				}
	      }    
	      catch(Exception e){ 
	      	out.write("responseMsg="+e.getMessage()+"#");
	      }
	      out.println();
	      out.flush();
      }
      else{
	      StringList sListObjectToRemove = new StringList(strContextObjectId.length);
	      String strDVId = "";
	      for(int i=0;i<strContextObjectId.length;i++)
	      {
	             StringTokenizer strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");
	             strTokenizer.nextToken(); //Realationship ID
	             strDVId=strTokenizer.nextToken(); //Selected DV to remove
	             sListObjectToRemove.add(strDVId);
	      }
		  try{
			    StringTokenizer strTokenizerObjectID = new StringTokenizer(strObjID,",");
			    String strObjId="";
			    strObjId = strTokenizerObjectID.nextToken();
			    String contextProductOID = "";
			    
			    if(null != strObjID){
			        StringTokenizer objIDs = new StringTokenizer(strObjID, ",");
					if(objIDs.countTokens()>1){
						// Context Feature ID
						strObjId = objIDs.nextToken().trim();
						// Context Product ID
						contextProductOID = objIDs.nextToken().trim();
					}else{
			      		 contextProductOID = (String)emxGetParameter(request, "contextProductOID");
					}
				 }else{
		      		contextProductOID = (String)emxGetParameter(request, "contextProductOID");
		      		strObjId = contextProductOID;
				 }
			    
				if(ConfigurationUtil.isFrozenState(context,strObjId)){
	                %>
	                <script language = "javascript">
	                    alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.DVActionsDisabledReleasedorBeyond</emxUtil:i18n>");
	                </script>
	                <%				
				}else{
					LogicalFeature lfBean = new LogicalFeature(strObjId);
					lfBean.removeDesignVariants(context,sListObjectToRemove);  
					//String url= "../common/emxIndentedTable.jsp?table=FTRDVConfigurationOptionTable&program=ConfigurationFeature:expandConfigurationOptions&portalMode=true&toolbar=FTRCommonGroupTopActionBarToolbarMenu,FTRDVConfigurationOptionsCustomFilterToolbar&header=emxProduct.DesignVariantStructureBrowser.ViewDesignVariantOptionsHeader&selection=multiple&HelpMarker=emxhelpcommongroupview&objectId="+XSSUtil.encodeForURL(contextProductOID);
					//String urlLFContext= "../common/emxIndentedTable.jsp?table=FTRDVConfigurationOptionTable&program=ConfigurationFeature:expandConfigurationOptions&portalMode=true&toolbar=FTRCommonGroupTopActionBarToolbarMenu,FTRDVConfigurationOptionsCustomFilterToolbar&header=emxProduct.DesignVariantStructureBrowser.ViewDesignVariantOptionsHeader&selection=multiple&HelpMarker=emxhelpcommongroupview&objectId="+XSSUtil.encodeForURL(strObjId);
					if (true) {
						%>
			           <script language="javascript" type="text/javaScript">
			           var isSlideInDV='<%=isSlideInDV%>';
			           var contentFrameObj = findFrame(getTopWindow(),"FTRDVConfigurationOptionCommand");
			           if(contentFrameObj!= null){
				           contentFrameObj.document.location.href= "../common/emxIndentedTable.jsp?table=FTRDVConfigurationOptionTable&program=ConfigurationFeature:expandConfigurationOptions&portalMode=true&toolbar=FTRCommonGroupTopActionBarToolbarMenu,FTRDVConfigurationOptionsCustomFilterToolbar&header=emxProduct.DesignVariantStructureBrowser.ViewDesignVariantOptionsHeader&selection=multiple&HelpMarker=emxhelpcommongroupview&objectId="+'<%=XSSUtil.encodeForURL(contextProductOID)%>';
				           parent.location.href = parent.location.href;
			           }if(isSlideInDV == 'true'){
			           		var slideInFrame = findFrame(getTopWindow(),"slideInFrame");
			           		slideInFrame.editableTable.loadData();
			           		slideInFrame.emxEditableTable.refreshStructureWithOutSort(); 
			           }else{
			               parent.editableTable.loadData();
			               parent.rebuildView();
				           var contentFrameObj = findFrame(getTopWindow(),"FTRDVConfigurationOptionContextCommand");
				           contentFrameObj.document.location.href= "../common/emxIndentedTable.jsp?table=FTRDVConfigurationOptionTable&program=ConfigurationFeature:expandConfigurationOptions&portalMode=true&toolbar=FTRCommonGroupTopActionBarToolbarMenu,FTRDVConfigurationOptionsCustomFilterToolbar&header=emxProduct.DesignVariantStructureBrowser.ViewDesignVariantOptionsHeader&selection=multiple&HelpMarker=emxhelpcommongroupview&objectId="+'<%=XSSUtil.encodeForURL(strObjId)%>';
			           }
			           </script>
			   <%}
			  }
		   }catch(Exception e){		   
	           throw new FrameworkException(e);
			 }
      }
   }catch(Exception e)
   { 
	    session.putValue("error.message", e.getMessage());
   }
   %>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
