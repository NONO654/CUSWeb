<%@page import="com.dassault_systemes.smaslm.matrix.server.Simulation"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.common.CommonDocument"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.FileUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationCategory"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationActivity"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.Parameters"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>


<%@page import="matrix.db.Context"%>
<%@page import="matrix.db.BusinessObject"%>
<%@page import="matrix.db.User"%>
<%@page import="matrix.util.StringList"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Set"%>
<%@page import="java.io.UnsupportedEncodingException"%>
<%@page import="javax.servlet.http.HttpServletRequest"%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../simulationcentral/smaWebUtil.inc"%>

<script type="text/javascript"
    src="../simulationcentral/smaStructureBrowser.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
String oid   = (String)requestMap.get("objectId");
String childId = emxGetParameter(request, "emxTableRowId");
String objectAction = emxGetParameter(request, "action");
DomainObject DOparent = DomainObject.newInstance(context,oid);
String sObjectId = null;

if(objectAction.equals("remove")){
    
    matrix.util.StringList sList = null;
    
    sList = com.matrixone.apps.domain.util.FrameworkUtil.split(childId,"|");
    if(sList.size() == 3){
        sObjectId = (String)sList.get(0);
    }else{
        sObjectId = (String)sList.get(1);
    }
    
    //app1
    String[] linkedObjectIds = (String[])emxGetParameterValues(request, "emxTableRowId");
    StringList relIds = new StringList();
    
    for (int i = 0; i<linkedObjectIds.length; i++){
        String dataSetId = linkedObjectIds[i];
        int idx = dataSetId.indexOf("|");
        if (idx > 0){
            relIds.add(dataSetId.substring(0, idx));
        }
    }
    //app2
    StringList objSelects = new StringList(2);
    objSelects.add(DomainConstants.SELECT_ID);
    String type_SimulationTemplate =
        SimulationUtil.getSchemaProperty(
            SimulationConstants
            .SYMBOLIC_type_SimulationTemplate);
    String type_Simulation =
        SimulationUtil.getSchemaProperty(
            SimulationConstants
            .SYMBOLIC_type_Simulation);
    StringBuffer sbTypes = new StringBuffer(160);
    sbTypes
    .append(type_SimulationTemplate).append(",")
    .append(type_Simulation);
    StringList relSelects = new StringList(1);
    relSelects.add(DomainConstants.SELECT_RELATIONSHIP_ID);
    relSelects.add(DomainConstants.SELECT_TO_ID);
    
    DomainObject DO = DomainObject.newInstance(context,sObjectId);
    final String RELATIONSHIP_ReferencedSimulations =
        SimulationUtil.getSchemaProperty(
            SimulationConstants.SYMBOLIC_relationship_ReferencedSimulations);
    MapList expandMap =
        DOparent.getRelatedObjects(context,
            RELATIONSHIP_ReferencedSimulations,
            sbTypes.toString(),
            objSelects,
            relSelects,
            true,
            true,
            (short)0,
            "",
            "",
            100);
    if(expandMap != null)
    {
        for(int i=0; i<expandMap.size();i++)
        {
            Map tempMap = (Map)expandMap.get(i);
            String currentsdOID = (String)
            tempMap.get(DomainConstants.SELECT_ID);
            String sdRelId = (String)
            tempMap.get(DomainConstants.SELECT_RELATIONSHIP_ID);
            DomainRelationship doRel = new DomainRelationship(sdRelId);
            BusinessObject toId = doRel.getTo();
            String name = doRel.getName();
            if(sObjectId.equals(currentsdOID))
                {   if(sdRelId != null)
                    DomainRelationship.disconnect(context,sdRelId);
                    }
        }
    }
    
%>
    <script language="javascript" type="text/javaScript">
    
    	getTopWindow().getWindowOpener().location.href = getTopWindow().getWindowOpener().location.href;
    	getTopWindow().closeWindow();
    
//]]>
    </script>
<%
    }
%>



