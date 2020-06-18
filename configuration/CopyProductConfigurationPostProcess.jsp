<%-- CopyProductConfigurationPostProcess.jsp --%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxProductCommonInclude.inc" %>
<%@include file = "../emxUICommonAppInclude.inc"%>

<%@page import="com.matrixone.apps.configuration.ConfigurationConstants"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.configuration.ProductConfiguration"%>
<%@page import="com.matrixone.apps.configuration.Product"%>
<%@page import="com.matrixone.apps.productline.ProductLineUtil"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.MessageUtil"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="Javascript" src="../common/scripts/emxUIFreezePane.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<html>

<body>
<%
try {
	//this will be Hardware Product
	String objectId = emxGetParameter(request,"objectId");
	//get the selected Objects from the Full Search Results page
    String arrTableRowIds[] = emxGetParameterValues(request, "emxTableRowId");
	
    //If the selection is empty given an alert to user
    if(arrTableRowIds==null){   
    %>    
      <script language="javascript" type="text/javaScript">
          alert("<emxUtil:i18n localize='i18nId'>emxProduct.Alert.FullSearch.Selection</emxUtil:i18n>");
      </script>
    <%
    }
    //If the selections are made in Search results page then
    else{
    	String arrObjectIds[] = null;
    	Map mapFromTree = (Map)ProductLineUtil.getObjectIdsRelIds(arrTableRowIds);
    	arrObjectIds = (String[])mapFromTree.get("ObjId");
    	String arrPCIds[] = new String[arrObjectIds.length];
    	int selectedPCIds = arrObjectIds.length;
    	//retrieve the Parameter settings
    	String exp = "MaxPCCloneArgValue";
    	String CmdExp = "print expression $1 select value dump";
    	String Result = MqlUtil.mqlCommand(context,CmdExp,exp).trim();
    	
    	int allowedPCIds = 5; //Default Value
    	try{
    	allowedPCIds = Integer.parseInt(Result);
    	}catch (Exception ex) {
    		//set allowedPCIds to default value 5
    		allowedPCIds = 5;
    	}
    	
    	//If allowedPCIds value comes negative then set it to default value 5
    	if(allowedPCIds<=0){
    		allowedPCIds = 5;
    	}
    	
    	String[] MaxPCCloneValue = new String[1];
    	MaxPCCloneValue[0] = String.valueOf(allowedPCIds);
    	    	
    	//If the number of selected PCs exceeds the maximum allowed number, send an alert
    	if(selectedPCIds>0 && !(selectedPCIds<=allowedPCIds)){
    		String MaxPCSelectionMessage = MessageUtil.getMessage(context,
                                                				  null,
					                                              "emxProduct.Alert.FullSearch.ProductConfigurationSelection",
					                                              MaxPCCloneValue,
					                                              null,
					                                              request.getLocale(),
					                                              "emxConfigurationStringResource");
    		%>    
            <script language="javascript" type="text/javaScript">
                  alert("<%=XSSUtil.encodeForJavaScript(context,MaxPCSelectionMessage)%>");
            </script>
          <%
    	}else{
    		for(int i=0;i<arrObjectIds.length;i++){
        		StringTokenizer st = new StringTokenizer(arrObjectIds[i],"|");
        		String selectedPCID = st.nextToken();
        		arrPCIds[i] = selectedPCID;
        	}
    		String[] sArrayPartialClonedPIDs = new String[arrPCIds.length];
        	Product configProduct = new Product(objectId);
        	String[] strClonePCIds = configProduct.cloneProductConfiguration(context,objectId,arrPCIds,sArrayPartialClonedPIDs);

        	ArrayList<String> list = new ArrayList<String>();
            for(String s : sArrayPartialClonedPIDs) {
               if(s != null && s.length() > 0) {
                  list.add(s);
               }
            }
            sArrayPartialClonedPIDs = list.toArray(new String[list.size()]);
        	//If any of the selected PCs failed to copy completely i.e Partially copied, send a message to user
        	String strAlertMessage = new String();
        	if(sArrayPartialClonedPIDs.length>0){
        		strAlertMessage = i18nStringNowUtil("emxProduct.Alert.CopyProductConfigurationPartially",bundle,acceptLanguage);
        		StringList objectSelects = new StringList(ConfigurationConstants.SELECT_NAME);
        		StringList partialClonedPCs = new StringList();
        		// get the name from object id
    			MapList objMapList =  DomainObject.getInfo( context,sArrayPartialClonedPIDs, objectSelects);
    			for(int index=0; index<objMapList.size();index++) {
    				Map<?, ?> objMap = (Map<?, ?>) objMapList.get(index);
    				String pcName = (String) objMap.get(ConfigurationConstants.SELECT_NAME);
    				partialClonedPCs.add(pcName);
    				strAlertMessage = strAlertMessage + " \n " +pcName;
    			}
        	}

        	%>
            <script language="javascript" type="text/javaScript">
            var PartialClonedPIDs = '<%=sArrayPartialClonedPIDs.length%>';
            var alertMessage = '<%=XSSUtil.encodeForJavaScript(context,strAlertMessage)%>';
            var parentWindowToRefresh=getTopWindow().findFrame(getTopWindow().getWindowOpener().parent.parent,"detailsDisplay");

			if(parentWindowToRefresh==undefined || parentWindowToRefresh==null){
            	  parentWindowToRefresh=getTopWindow().findFrame(getTopWindow().getWindowOpener().parent.parent.parent.parent,"detailsDisplay");
              }
            getTopWindow().closeWindow();
            
            if(PartialClonedPIDs!=0){
            	parentWindowToRefresh.showAlertAfterPCClone(alertMessage);
            }
            parentWindowToRefresh.location.href  = parentWindowToRefresh.location.href;
            </script>
            <%   
    	}   
    }
} 
catch (Exception e) {
	session.putValue("error.message", e.getMessage());
}
%>
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
</body>
</html>

