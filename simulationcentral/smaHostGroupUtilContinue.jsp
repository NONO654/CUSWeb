<%-- (c) Dassault Systemes, 2014 --%>
<%--
  Actions for host groups
--%>

<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.util.MatrixException"%>

<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="matrix.db.Context"%>
<%@page import="matrix.util.MatrixException"%>

<%@page import="java.util.HashMap"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="matrix.db.JPO"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%
	// What is it that we want to do?
    // Possible objectAction values: 
    // pushToCos continuation of push to cos command to set sync attribute

    String objectAction = emxGetParameter(request, "objectAction");
    String locale = context.getSession().getLanguage();
    String sError = "";    
    // sanity check should never happen
    if ( (objectAction == null) || (objectAction.equals("")) )
    {
        sError = SimulationUtil.getI18NString(context,
                "Error.ContentUtil.NoAction");
        emxNavErrorObject.addMessage(sError);
        objectAction = "";
    }
    else
    {
        // get an interned string ref for faster reference compares
        objectAction = objectAction.intern();
    }
    String objectIdStr = emxGetParameter(request, "objIdStr");
    if ("pushToCos".equalsIgnoreCase(objectAction))
    {
		String[] methodargs = new String[] { objectIdStr };
	    JPO.invoke( context, 
	            "jpo.simulation.SimulationHostGroup", null, 
	            "setSynced", methodargs, null);

    }
    if ("pushToCosClose".equalsIgnoreCase(objectAction))
    {
		String[] methodargs = new String[] { objectIdStr };
	    JPO.invoke( context, 
	            "jpo.simulation.SimulationHostGroup", null, 
	            "setSynced", methodargs, null);
	    %>
	    <script language=javascript>
	    window.closeWindow();
	    </script>
	    <%
    }
    else if ("pushToCosEdit".equalsIgnoreCase(objectAction))
    {
		String[] methodargs = new String[] { objectIdStr };
	    JPO.invoke( context, 
	            "jpo.simulation.SimulationHostGroup", null, 
	            "setSynced", methodargs, null);

	    %>
	      <script language="javascript">
        if ( getTopWindow().refreshTablePage )
        {
            getTopWindow().closeSlideInDialog();
            getTopWindow().closeWindow();
        }
	      </script>
<%
    }
    else if ("pushToCosAddHost".equalsIgnoreCase(objectAction))
    {
		String[] methodargs = new String[] { objectIdStr,"true" };
	    JPO.invoke( context, 
	            "jpo.simulation.SimulationHostGroup", null, 
	            "setSynced", methodargs, null);
    }

%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
