<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%@page import="matrix.db.Context"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>

<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.common.Person"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.AnalyticsCaseEntityWUtil"%>

<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session"/>

<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	
	<script language="javascript" src="../common/scripts/emxUICore.js"></script>
	<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
	<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

	<script	src="../plugins/libs/jquery/2.0.0/jquery.min.js" type="text/javascript"></script>
</head>
<body>
	
	<%
	
	
	String[] childRowIds = request.getParameterValues("emxTableRowId");
    
    %>
    <script>
    var persons = [];
    <% for(int i=0;i<childRowIds.length;i++) {
    	
    	//the tablerow id is in the format |objId||
    	
    	String objId = childRowIds[i].substring(childRowIds[i].indexOf("|")+1, 
    			childRowIds[i].substring(childRowIds[i].indexOf("|")+1).indexOf("|")+1);
    	
    	Person person = new Person(objId);
    	
    	%>
    	var thisPerson = {};
    	
    	/*add more attributes here as needed*/
    	thisPerson.userEmail = '<%= person.getAttributeValue(context, Person.ATTRIBUTE_EMAIL_ADDRESS)%>';
    	persons.push(thisPerson);
    	
    	<%
    }
    	%>
   	var opener = getTopWindow().getWindowOpener().frames['content'].frames['widgetframe'].contentWindow 
   		|| getTopWindow().getWindowOpener().frames['content'].frames['widgetframe'].window;
   	if (opener){
   		if(opener.proxy){
   			opener.proxy.fireNamedCallback('getUsersAfterSearch', persons);
   		}
   		else{
   			throw 'proxy not found';
   		}
   		getTopWindow().closeWindow();
   	}
    </script>
    
</body>
</html>


