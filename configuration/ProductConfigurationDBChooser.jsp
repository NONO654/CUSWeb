<%-- ProductConfigurationDBChooser.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

    static const char RCSID[] = "$Id: /web/configuration/ProductConfigurationUtil.jsp 1.70.2.7.1.2.1.1 Wed Dec 17 12:39:33 2008 GMT ds-dpathak Experimental$: ProductConfigurationUtil.jsp";
--%>
<%-- Common Includes --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import = "com.matrixone.apps.configuration.*"%>
<%@page import = "com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import = "com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import = "java.util.StringTokenizer"%>
<%@page import = "java.util.Vector"%>

<SCRIPT language="javascript" src="../common/scripts/emxUIConstants.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUIModal.js"></SCRIPT>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<SCRIPT language="javascript" src="../emxUIPageUtility.js"></SCRIPT>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<SCRIPT language="javascript" src="./scripts/emxUIDynamicProductConfigurator.js"></SCRIPT>

<%

ProductConfiguration pcObj = (ProductConfiguration)session.getAttribute("productconfiguration");
String mode = emxGetParameter(request, "mode");
String optionId = ConfigurationConstants.EMPTY_STRING;

ServletContext svltContext = getServletConfig().getServletContext();
java.io.InputStream inputStream=null;
try{
	 inputStream = svltContext.getResourceAsStream("/configuration/ProductConfigurationDisplay.xsl");
}catch (Exception e){
	 throw new FrameworkException(e.getMessage());
}

if(mode.equals("remove"))
{
	String featureId = emxGetParameter(request, "FeatureId");
	String parentFeatureId = emxGetParameter(request, "parentFeatureId");
	if(ConfigurationConstants.VALUE_SAT.equalsIgnoreCase(pcObj.getSolverType()))
	{
		 pcObj.updateSelectionStatusXML(context,featureId,parentFeatureId,false);
		 //String pcFeatureXML = pcObj.getUpdatedHTMLForOptionsDisplay(context,pcObj.getCachedXML(),new LinkedHashMap(),"edit");
		 //pcObj.setCachedXML(pcFeatureXML);
		 
		 String pcFeatureXML = pcObj.getCachedXML();
		 
		 out.clear();
		 out.write(pcFeatureXML);
		 out.flush();
		
	}
	else 
	{
		IProductConfigurationFeature feature = (IProductConfigurationFeature)pcObj.getFeature(featureId).get(0);
	if(feature != null)
		feature.setSelectedState(context, false,false);
	//pconf.setCurrentUserSelectionId(featureId);
	out.clear();
		out.write(pcObj.getHTMLForOptionsDisplay(context,inputStream, "edit"));
	out.flush();
}
}
else
{
	try
	{
String strContextObjectId[] = emxGetParameterValues(request, "emxTableRowId");
String parentFeatureId = emxGetParameter(request, "parentFeatureId");
		StringTokenizer strTokenizer = null;
		
		if(ConfigurationConstants.VALUE_SAT.equalsIgnoreCase(pcObj.getSolverType()))
		{
			
for(int i=0;i<strContextObjectId.length;i++)
{
   strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");
			   optionId = strTokenizer.nextToken();
			    optionId = pcObj.getPhysicalId(context,optionId,pcObj.getCachedXML());
			   pcObj.updateSelectionStatusXML(context,optionId,parentFeatureId,true);
   
			}
			
		}
		else
		{
	
			for(int i=0;i<strContextObjectId.length;i++)
			{
			   strTokenizer = new StringTokenizer(strContextObjectId[i] ,"|");
			   optionId = strTokenizer.nextToken();
			   IProductConfigurationFeature pFeature = null;
			    pFeature = pcObj.loadFeature(context, optionId, parentFeatureId);
        if(pFeature != null)
            {
   IProductConfigurationFeature pParentFeature = pFeature.getParent();
   if(pFeature!=null && pParentFeature.getId().equals(parentFeatureId))
   {
	   pFeature.setSelectedStateDBChooser(context,true,false);
	  // pconf.setCurrentUserSelectionId(Id);
	   if(pParentFeature.getSelectionType().equals("Single"))
	   {
		    Vector childFeatures = pParentFeature.getChildren();
		    for(int count = 0; count < childFeatures.size(); count++)
		        {
		    	   IProductConfigurationFeature pChildFeature = (IProductConfigurationFeature)childFeatures.get(count);
		    	   if(!pChildFeature.equals(pFeature))
		    		   {
		    		    pChildFeature.clearChildSelections(context);
		    		    pChildFeature.setSelectedState(context, false,false);
		    		    }
   }
			       			}
			   			}
			     }	
			}
		   
            }
	}
	catch(Exception ep)
	{
		throw new FrameworkException(ep.getMessage());
	}
%>
 <script language="javascript" type="text/javaScript">
   var mainDiv = getTopWindow().getWindowOpener().document.getElementById("mx_divBody");
            //XSSOK
	   		mainDiv.innerHTML = '<%=pcObj.getHTMLForOptionsDisplay(context,inputStream,"edit").replaceAll("'", "\\\\'")%>';
   //getTopWindow().location.href = "../common/emxCloseWindow.jsp";
   getTopWindow().closeWindow();
 </script>
	 <% 	
  }
%>
