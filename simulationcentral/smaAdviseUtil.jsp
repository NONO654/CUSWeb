<%-- (c) Dassault Systemes, 2013 --%>
<%--
  Process various Advise commands on Advise Home page.
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>

<%@page import="java.util.Map"%>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript"	src="./smaAdviseLaunchHelper.js"></script>

<%

	Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
			
	StringBuilder contentURL = new StringBuilder(175);
	String tableRowId        = emxGetParameter(request, "emxTableRowId");
    String objectAction      = emxGetParameter(request, "objectAction");
	String objectId =  emxGetParameter(request, "objectId");
    
    if(tableRowId==null) {
    	System.out.println("tableRowId is null in adviseUtil, trying to get it from object");
    	if(objectId!=null) {
    		tableRowId = "|"+objectId+"||0,0";
    	} else {
        	System.out.println("objectId is also null in adviseUtil, trying to get it from session");
    		tableRowId = session.getAttribute("specialRowID").toString();
    	}
        System.out.println("tableRowId : "+tableRowId);
    }
    
    if(objectId == null && tableRowId!=null && tableRowId.length()>0){
		String[] sRowIds = tableRowId.split("(\\Q" + "|" + "\\E)+");
		// we open only one case, so choose the first item from the selected list
		objectId = sRowIds[1];
    }
    
    //What is it that we want to do?
    // Possible loadAction values:
    // loadAction   0  : load in contents frame
    //              1  : pop-up
    //              2  : slide-in
    
    String loadAction        = "0";
    
    
    if ( objectAction.equals("openAdvise") )  //////////////
    {
        session.setAttribute("specialRowID",tableRowId);
        
        contentURL.append("../simulationcentral/smaRunAdviseJob.jsp?")
        .append("emxTableRowId=").append(tableRowId);
        
        loadAction = "0";

    }
    if ( objectAction.equals("openAdviseAs") )  //////////////
    {
        session.setAttribute("specialRowID",tableRowId);
        
        contentURL.append("../simulationcentral/smaRunAdviseJobAs.jsp?")
        .append("emxTableRowId=").append(tableRowId);
        
        loadAction = "0";

    }
    if ( objectAction.equals("editAdviseCase") )  //////////////
    {
        session.setAttribute("specialRowID",tableRowId);
        contentURL.append("../common/emxForm.jsp?form=SMAAnalyticsCase_Edit&&suiteKey=SimulationCentral&StringResourceFileId=smaSimulationCentralStringResource&SuiteDirectory=simulationcentral&emxSuiteDirectory=simulationcentral&mode=edit&submitAction=refreshCaller");
        if(tableRowId!=null)
        	contentURL.append("&emxTableRowId=").append(tableRowId);
        
        loadAction = "0";

    }
    if ( objectAction.equals("showDetails") )  //////////////
    {
    	

   		DomainObject doObj = new DomainObject();
   		doObj.setId(objectId);
   		if(doObj.isKindOf(context,com.matrixone.apps.common.CommonDocument.TYPE_DOCUMENTS)) {
   			contentURL.append("../common/emxForm.jsp?form=type_DOCUMENTS&toolbar=APPDocumentToolBar&HelpMarker=emxhelpdocumentproperties&formHeader=emxComponents.Common.PropertiesPageHeading&subHeader=emxComponents.Menu.SubHeaderDocuments&Export=False&displayCDMFileSummary=true&suiteKey=Components&StringResourceFileId=emxComponentsStringResource&SuiteDirectory=components&emxSuiteDirectory=components");
   		} else {
   	        session.setAttribute("specialRowID",tableRowId);
   	     	contentURL.append("../common/emxTree.jsp?mode=insert&emxSuiteDirectory=simulationcentral&treeMenu=type_AnalyticsCase&portalCmdName=SMAHome_SMAHome_Advise_TabCases");
   			//contentURL.append("../simulationcentral/smaAdviseCaseDetails.jsp?_=1");
   		}
        if(tableRowId!=null)
        	contentURL.append("&emxTableRowId=").append(tableRowId);
        if(objectId!=null)
        	contentURL.append("&objectId=").append(objectId);
        
        loadAction = "0";

    }
    if ( objectAction.equals("widgetview") )  //////////////
    {
        
        contentURL.append("../widget/bpsWidget.jsp?bps_widget=IsightAdvise");
        
        loadAction = "0";

    }
    
    %>
    <script>
        initiateLoad("<%=contentURL.toString()%>","<%=loadAction%>");
    </script>
	<%		
%>
