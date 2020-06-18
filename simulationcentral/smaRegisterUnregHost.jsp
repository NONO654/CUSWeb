<%--
 *---------------------------------------------------------------------
 * (c) Dassault Systemes, 2007, 2008
 * Jsp launched from register/unregister host
 *---------------------------------------------------------------------
--%>


<%-- Common Includes --%>
<%@page import="com.dassault_systemes.smaslm.common.util.XMLUtil"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>

<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.common.util.MessageServices"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "java.io.File"%>
<%@page import = "com.matrixone.jdom.Document"%>
<%@page import = "com.matrixone.jdom.input.SAXBuilder"%>
<%@page import = "com.matrixone.jdom.output.XMLOutputter"%>
<%@page import = "java.lang.ClassLoader"%>


<script language="Javascript" src="../common/scripts/emxUIConstants.js"/>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"/>

<%
    String operation = emxGetParameter(request, "mode");
    String result = "";
    
    if ( context != null )
    {
        try
        {    
    InputStream inStream =
        getServletConfig().getServletContext().getResourceAsStream(
        "/simulationcentral/config/hostConfigInfo.xml");
    SAXBuilder xmlBuilder = XMLUtil.createInstanceOfSecuredSaxBuilder();//wu4-XXE Security Vulnerability
    Document  xmlDoc= xmlBuilder.build(inStream );
//          Document  xmlDoc= 
//              xmlBuilder.build( new File("hostConfigInfo.xml"));
    XMLOutputter xmlOutputter = new XMLOutputter();
    String xmlOutput = xmlOutputter.outputString(xmlDoc);

    HashMap paramMap = new HashMap();
    paramMap.put("configFile",xmlOutput);

    String[] methodargs = JPO.packArgs(paramMap);
    result = (String)JPO.invoke(
        context,"jpo.simulation.SimulationHost",null,operation,
        methodargs, String.class);
    if (result.length() > 0)
    {
        emxNavErrorObject.addMessage(
            MessageServices.massageMessage(result));  
    }
        }
        catch ( Exception e )
        {
    //assumes two modes register/unregister
    String errMsg = "";
    String lang = request.getHeader("Accept-Language");
    if (operation.equals("register"))
    {
        errMsg = SimulationUtil.getI18NString(context,
            "smaSimulation.RegisterHost.RegisterError");
    }
    else
    {
        errMsg = SimulationUtil.getI18NString(context,
            "smaSimulation.RegisterHost.UnregisterError");
    }
    
    errMsg = StringResource.format(
        errMsg, "P1", ErrorUtil.getMessage(e));
    emxNavErrorObject.addMessage(errMsg);  
        }            

   }
%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
<script language="javascript">    
    getTopWindow().location.href = getTopWindow().location.href;
</script>
