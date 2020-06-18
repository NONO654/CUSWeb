<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@ include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../teamcentral/emxTeamCommonUtilAppInclude.inc" %>
<%@include file = "../teamcentral/emxTeamStartUpdateTransaction.inc"%>
<%@include file = "../teamcentral/eServiceUtil.inc"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script> 
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<%@page import = "com.matrixone.apps.common.util.ComponentsUIUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="matrix.db.BusinessObject" %>
<%@page import="matrix.db.RelationshipType" %>
<%@page import="matrix.db.Relationship" %>
<%@page import="java.util.Map"%>

<%
try {
    Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    String oid   = (String)requestMap.get("objectId");

    boolean  oldTransaction  =  context.isTransactionActive();
    if  (oldTransaction)  {  
    context.commit();  
    }  

    ContextUtil.startTransaction(context, true);

    DomainObject DOparent = DomainObject.newInstance(context,oid);

    DOparent.open(context);
    String[] childIds = ComponentsUIUtil.getSplitTableRowIds(emxGetParameterValues(request, "emxTableRowId"));

    if(childIds != null){
    	for(int i=0;i<childIds.length;i++){
    		DomainObject childObj = DomainObject.newInstance(context,childIds[i]);
    		childObj.open(context);
    	    DomainRelationship DR = DOparent.connectTo(context,"Referenced Simulations", childObj);
    	    childObj.close(context); 
    	}
    }

    DOparent.close(context);

    ContextUtil.commitTransaction(context);  
                
%>
    <script language="javascript">
    getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
    getTopWindow().getWindowOpener().location.reload();
    getTopWindow().closeWindow();
    </script>

<%
    } catch (Exception ex){
    session.putValue("error.message",ex.getMessage());
%>
    <%@  include file="../teamcentral/emxTeamAbortTransaction.inc" %>
<%
  }
%>
