
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="java.io.InputStream"%>
<%@page import="com.matrixone.apps.configuration.IProductConfigurationFeature"%>
<%@ page import="java.util.StringTokenizer"%>
<%@ page import = "java.util.Vector" %>
<%@ page import="com.matrixone.apps.configuration.ProductConfiguration" %>

<%
out.clear();

String featureSelectionList = emxGetParameter(request, "featureSelectionList");
String featureDeselectionList = emxGetParameter(request, "featureDeselectionList");
String strIsForOrdrdQntty = emxGetParameter(request, "isForOrderedQntty");
String strFtrLstId = emxGetParameter(request, "ftrLstId");
String strMode = emxGetParameter(request, "mode");

ServletContext svltContext = getServletConfig().getServletContext();
InputStream inputStream=null;
try{
	 inputStream = svltContext.getResourceAsStream("/configuration/ProductConfigurationDisplay.xsl");
}catch (Exception e){
	throw new FrameworkException(e.getMessage());
}


if(strMode == null)
    strMode = "";
if(strMode.equalsIgnoreCase("editOptions"))
    {    
	ProductConfiguration pConf = (ProductConfiguration)session.getAttribute("productconfiguration");
	StringTokenizer selectedIds=new StringTokenizer(featureSelectionList, ",");
	Vector selectedIdsList = new Vector();
	while(selectedIds.hasMoreTokens())
	{
		selectedIdsList.addElement(selectedIds.nextElement());
	        }
	StringTokenizer deSelectedIds=new StringTokenizer(featureDeselectionList, ",");
    Vector deSelectedIdsList = new Vector();
    while(deSelectedIds.hasMoreTokens())
         {
    	   String nextId = (String)deSelectedIds.nextElement();
    	if(!selectedIdsList.contains(nextId))
    	    deSelectedIdsList.addElement(nextId);
                 }
   // pConf.setCurrentUserSelectionId(userSelectedFtrLstId);
	pConf.deselectConfigurationOptions(context, deSelectedIdsList);
	pConf.selectConfigurationOptions(context, selectedIdsList);

	out.write(pConf.getHTMLForOptionsDisplay(context,inputStream,"edit"));
	out.flush();
             }
else if(strMode.equalsIgnoreCase("updateKeyInValue"))
{
	String value = emxGetParameter(request,"value");
	String id = emxGetParameter(request,"featureId");
	id = id.replaceAll("Cal_","");
	ProductConfiguration pConf = (ProductConfiguration)session.getAttribute("productconfiguration");
	IProductConfigurationFeature pFeat = (IProductConfigurationFeature)pConf.getFeature(id).get(0);
	pFeat.setKeyInValue(context, value);
	out.write(pConf.getHTMLForOptionsDisplay(context,inputStream, "edit"));
    out.flush();
}
else if(strIsForOrdrdQntty != null && strIsForOrdrdQntty.equalsIgnoreCase("true"))
             {
	 String strOrderedQuantity = emxGetParameter(request, "ordrdQntty");
	 ProductConfiguration pConf = (ProductConfiguration)session.getAttribute("productconfiguration");
	 IProductConfigurationFeature pOption = (IProductConfigurationFeature)pConf.getFeature(strFtrLstId).get(0);
	 double orderedQuantity = Double.parseDouble(strOrderedQuantity);
	 pOption.setOrderedQuantity(context, orderedQuantity);  
     out.write(pConf.getHTMLForOptionsDisplay(context,inputStream,"edit"));
     out.flush();

             }
else if(strMode.equalsIgnoreCase("cleanupsession"))
             {
            session.removeAttribute("productconfiguration");
}

%>


