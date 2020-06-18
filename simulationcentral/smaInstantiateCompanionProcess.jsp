<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Process instantiate template commands
--%>

<%@page import="java.util.Map"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Template"%>
<%@page import="matrix.db.Context"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@include file="../common/emxNavigatorInclude.inc"%>

<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import = "java.util.Enumeration"%>
<%@page import = "java.util.List"%>
<%@page import = "matrix.db.JPO"%>

<%@page import="com.matrixone.apps.domain.DomainObject"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal/emxUIModal.js"></script>
<script type="text/javascript" src="../common/scripts/jquery-latest.js"></script>

<jsp:useBean id="createBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>
<%
     
    // Obtain the correct context from the request
         matrix.db.Context context2 = 
         (matrix.db.Context)request.getAttribute("context");
     if (context2 != null)
         context = context2;

    String  timeStamp = emxGetParameter(request, "timeStamp");
    HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
    HashMap formData = createBean.getFormData(timeStamp);
    HashMap programMap = new HashMap();
    
    String tempId = emxGetParameter(request,"TemplateChooser");
    String title = emxGetParameter(request,"Title");
    String desc = emxGetParameter(request,"Description");
    
    programMap.put("tempId",tempId);
    programMap.put("title",title);
    programMap.put("description",desc);
    
    String[] args = JPO.packArgs(programMap);
    String newObjectId = null;

    // If the JPO throws an exception, clean up messgae and rethrow
    // it will be caught (and handled} by the JSP
    try
    {
    	newObjectId = (String)JPO.invoke(context, 
            "jpo.simulation.Template", null,
            "instantiateSimulationCompanion", args, String.class);
        
        if (newObjectId != null && newObjectId.length() > 0)   
        {
            StringBuilder contentURL1 = new StringBuilder(175);
            /* contentURL1.append("../simulationcentral/smaHomeUtil.jsp?")
            .append("objectAction=showInBrowseTab")
            .append("&objectId=").append(newObjectId); */
             String url = SimulationUtil.getProperty(context,
                "smaSimulationCentral.Entry.SMAProc_ad-app");
            contentURL1.append(url)
            .append("?emxSuiteDirectory=simulationcentral&suiteKey=SimulationCentral")
            .append("&objectId=").append(newObjectId);
        
%>
            <script language="javascript">
            
            var topFrm = getTopWindow();
            frame = findFrame(topFrm,"content");
            if (frame == null || frame == undefined)
                {
                topFrm = getTopWindow().getWindowOpener().getTopWindow();
                frame = findFrame(topFrm,"content");
                }
            topFrm.currentApp = "SIMCOMP_AP";
            var appsMenuList = new Array();
            appsMenuList[0] = 'SMAScenario_Definition_New';
            topFrm.changeProduct('SIMULIA', 'Simulation Companion', 'SIMCOMP_AP', appsMenuList, 'SIMCOMP_AP', null); 
            topFrm.showMyDesk();
            
            try
            {
               var hFra = findFrame(getTopWindow(),"content");
               hFra.location.href = "<%=contentURL1.toString()%>";
            }
            catch(error)
            {}
            </script>
<%
        }
    }
  
    catch (Exception ex)
    {
        String message = ErrorUtil.getMessage(ex);

        // put the error message on the request for ENOVIA to handle
        request.setAttribute("error.message", message);
    }

%>
<script language="javascript">
getTopWindow().closeSlideInDialog();
</script>


            










