<%-- emxToolbar.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxToolbar.jsp.rca 1.51 Wed Oct 22 15:48:37 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorNoDocTypeInclude.inc"%>

<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxToolbarInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil,
                com.matrixone.apps.domain.util.XSSUtil"%>

<%@page import="com.matrixone.servlet.Framework"%>

<%
HashSet tableParamList = new HashSet();
HashMap specialParamMap = new HashMap();
String uiType = emxGetParameter(request,"uiType");
if("table".equalsIgnoreCase(uiType)){
	StringList toolbarParameters = FrameworkUtil.splitString(emxGetParameter(request, "otherToolbarParameters"),",");
	for(int i = 0; i < toolbarParameters.size(); i++){
	    String currentParameter = (String)toolbarParameters.get(i);
	    String[] parameterValues = emxGetParameterValues(request, currentParameter);
	    String appendString = "";
	    if(parameterValues != null ) {
	      for(int j = 0; j < parameterValues.length; j++){
	          if(j==0){
	              appendString += XSSUtil.encodeForURL(context, (String)parameterValues[j]);
	          }else{
	              appendString += "~sep~" + XSSUtil.encodeForURL(context, (String)parameterValues[j]);
	          }
	      }
	    }
	    specialParamMap.put(currentParameter, appendString);
	}
	StringList otherTollbarParams = FrameworkUtil.splitString(emxGetParameter(request, "otherTollbarParams"),",");
	tableParamList.addAll(toolbarParameters);
	tableParamList.addAll(otherTollbarParams);

	tableParamList.add("portalCmdName");
	tableParamList.add("portalCmdName"); 
	tableParamList.add("TransactionType"); 
	tableParamList.add("sortColumnName");
	tableParamList.add("showRMB");
	tableParamList.add("uiType");
	tableParamList.add("multiColumnSort");
	tableParamList.add("showClipboard");
	tableParamList.add("massPromoteDemote");
	tableParamList.add("disableSorting"); 
	tableParamList.add("submitMethod"); 
	tableParamList.add("toolbar");
	tableParamList.add("objectId");
	tableParamList.add("relId");
	tableParamList.add("parentOID");
	tableParamList.add("parentID");
	tableParamList.add("timeStamp");
	tableParamList.add("editLink");
	tableParamList.add("header");
	tableParamList.add("PrinterFriendly");
	tableParamList.add("showPageURLIcon");
	tableParamList.add("export");
	tableParamList.add("showChartOptions");
	tableParamList.add("showTableCalcOptions");
	tableParamList.add("helpMarker");
	tableParamList.add("tipPage");
	tableParamList.add("suiteKey");
	tableParamList.add("topActionbar");
	tableParamList.add("bottomActionbar");
	tableParamList.add("AutoFilter");
	tableParamList.add("CurrencyConverter");
	tableParamList.add("objectCompare");
	tableParamList.add("objectBased");
	tableParamList.add("selection");
	tableParamList.add("selectedFilter");
	tableParamList.add("findMxLink");
	tableParamList.add("customize");
	tableParamList.add("triggerValidation");
	tableParamList.add("targetLocation");
	tableParamList.add("categoryTreeName");
	tableParamList.add("IsStructureCompare");
	tableParamList.add("portalMode");
    tableParamList.add("otherToolbarParameters");
    tableParamList.add("otherTollbarParams");
}

    StringBuffer qString = new StringBuffer(); 
    Enumeration eNumParameters = emxGetParameterNames(request); 
    while( eNumParameters.hasMoreElements() ) { 
        String parmName = (String)eNumParameters.nextElement(); 
        if("header".equals(parmName) ||"parsedHeader".equals(parmName) ) 
		{ 
			continue;     
		}
        if("table".equalsIgnoreCase(uiType) && !tableParamList.contains(parmName)){
			continue;     
		}
        qString.append(XSSUtil.encodeForURL(context, parmName)); 
        qString.append("="); 
        if(parmName.equals("treeLabel")) {
        	String encodedTreeLabel = XSSUtil.encodeForURL(context, emxGetParameter(request,parmName));
        	qString.append(encodedTreeLabel);
        } else if(specialParamMap.keySet().contains(parmName)){
        	qString.append((String)specialParamMap.get(parmName));
        } else{
            qString.append(XSSUtil.encodeForURL(context, emxGetParameter(request,parmName))); 
        }
        
        if(eNumParameters.hasMoreElements()){ 
            qString.append("&"); 
        } 
    } 
%>

    <script type="text/javascript">
        addStyleSheet("emxUIMenu");
		if(getTopWindow().isMobile || getTopWindow().isPCTouch){
			addStyleSheet("emxUIMobile", '../common/mobile/styles/');
        }
       
    </script>
    
<script language="javascript" src="../common/scripts/emxUICalendar.js"></script>
<script language="JavaScript" src="../common/scripts/jquery-latest.js" type="text/javascript"></script>
<!-- //XSSOK -->

<%
    //get emxToolbarJavaScript.jsp response here to avoid server side unnecesary round trip
    CharArrayWriterResponse customResponse  = new CharArrayWriterResponse(response);

    StringBuffer toolbarURL = new StringBuffer("../common/emxToolbarJavaScript.jsp?");
    toolbarURL.append(qString.toString());

    request.getRequestDispatcher(toolbarURL.toString()).include(request, customResponse);
    String toolbarCode = customResponse.toString().replaceAll("\"", "'");
    toolbarCode = toolbarCode.replaceAll("\n"," ");
    toolbarCode = toolbarCode.replaceAll("\r"," ");
%>

    <script type="text/javascript">
        <%=customResponse.toString()%>
    </script>
<!-- id is given to be used in the init method of emxUIToolbar.js -->
<!--Modified for Form Custom Filter Bar-->
<div class="toolbar-container" id="divToolbarContainer">
	<div id="divToolbar" class="toolbar-frame"></div>
</div>

