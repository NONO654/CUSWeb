<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "ECMDesignTopInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%@page import="com.dassault_systemes.enovia.enterprisechangemgt.common.ChangeConstants"%>
<jsp:useBean id="changeUtil" class="com.dassault_systemes.enovia.enterprisechangemgt.util.ChangeUtil" scope="session"/>


<%!
public final String appendURLParameters(Context context,HttpServletRequest request,Enumeration requestParams,StringBuffer url) {
    String paramName,paramValue;    
    while( requestParams.hasMoreElements()) {
        paramName  = (String)requestParams.nextElement();
        paramValue = (String)emxGetParameter(request,paramName);
        url.append(paramName);
        url.append("=");
        url.append(XSSUtil.encodeForURL(context,paramValue));
        if(requestParams.hasMoreElements()){
        	url.append("&");
        }
	}
   return XSSUtil.encodeForJavaScript(context, url.toString());    
}
%>

<%
  	String strId = "";
	StringList slTableRowIds = new StringList(10); 
  	String[] arrTableRowIds = emxGetParameterValues(request,"emxTableRowId");
  	String[] strArrObjectId = emxGetParameterValues(request,"objectId");
  	String strMode = emxGetParameter(request,"mode");
  	String strObjectId = strArrObjectId[0];
  	i18nNow i18nnow = new i18nNow();
  	String strSelectAlertMessage = EnoviaResourceBundle.getProperty(context, "emxEnterpriseChangeMgtStringResource", context.getLocale(),"EnterpriseChangeMgt.Alert.SelectOne"); 
  	
	// Getting Object Ids From the tableRowId  	   
	String functionality = emxGetParameter(request,"functionality");
	String tableRowId = emxGetParameter(request, "emxTableRowId");
	
	// CAREFUL when calling change UTIL api for getting string list of object ids , because that may fail when this jsp was executed for RMB.
	String rowId = "";
	String objectId = emxGetParameter(request,"objectId");
	String helpmarker = emxGetParameter(request,"HelpMarker");
	StringBuffer actionURL = new StringBuffer(1000);
	if("viewCOFromRMB".equalsIgnoreCase(functionality) || "viewCRFromRMB".equalsIgnoreCase(functionality) || "viewCAFromRMB".equalsIgnoreCase(functionality) ||
		"editCOFromRMB".equalsIgnoreCase(functionality) || "editCRFromRMB".equalsIgnoreCase(functionality) || "editCAFromRMB".equalsIgnoreCase(functionality)) {		
		StringList sList  = FrameworkUtil.split(tableRowId, "|");  
		
	    if (sList.size() == 3) {
	    	objectId = (String) sList.get(0);
	    	rowId = (String) sList.get(2);
	    } else if (sList.size() == 4) {
	    	objectId = (String) sList.get(1);
	    	rowId = (String) sList.get(3);
	    } else if (sList.size() == 2) {
	    	objectId = (String) sList.get(1);
	    } else {
	    	objectId = (String) sList.get(0);
	    }
	    
	    actionURL = actionURL.append("../common/emxForm.jsp?&HelpMarker="+helpmarker+"&SuiteDirectory=enterprisechangemgt&suiteKey=EnterpriseChangeMgt&");
	    
%>
	    <script language="Javascript">
	    	getTopWindow().commandName = [];
			getTopWindow().commandName["targetFrameToRefresh"] = parent.name;		
			//XSSOK
			getTopWindow().showModalDialog("<%=appendURLParameters(context,request,emxGetParameterNames(request),actionURL)%>", "600", "500");
		</script>
<%
	}
	
%>

 <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
 
