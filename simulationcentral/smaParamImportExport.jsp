<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Process various import/export commands on the Simulation and Activity
  parameter page.  This will use an applet so processing occurs on the
  client machine.
--%>



<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.common.util.StringValidator"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.URLBuilder"%>

<%@include file = "../simulationcentral/smaWebUtil.inc"%>
<%@page import="matrix.db.Context" %>
<%@page import="matrix.util.MatrixException"%>
<%@page import = "matrix.util.StringResource"%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>

<%
    String objectAction = emxGetParameter(request, "objectAction");
    String ErrorStr =  "";

    // applet parameters
    String objId = emxGetParameter(request, "objectId");
    
    //For HL Improved Job Object pt6
    if(objId == null){
        objId = emxGetParameter(request, "emxTableRowId");            
    }
    
    
    String hostName = "localhost";
    String userName = StringValidator.validate(context.getUser());
    String userPass = StringValidator.validate(context.getPassword());

    // since we are running locally, startCommand used to pass file name
    // for import or the selected parameters for export
    String startCommand ="";
    
    // additional applet parameters for import
    String overwrite = "no";
    String title = "";
    String btnLabel = "";
    String tooltip = "";
    String confirmMsg = "";
    String confirmTitle = "";

    String locale = context.getSession().getLanguage();
    if ("parameterImport".equals(objectAction))
    {
        String overwriteDup =
            emxGetParameter(request,"overwriteDuplicates");
        
        if ("overwriteDuplicates".equalsIgnoreCase(overwriteDup))
            overwrite = "yes";

        title = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.ParameterImport.DialogTitle");
            
        btnLabel = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.ParameterImport.ButtonLabel");
            
        tooltip = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.ParameterImport.ButtonTooltip");
            
    }
    else if ("attributeImport".equals(objectAction))
    {

        title = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.AttributeImport.DialogTitle");
        btnLabel = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.AttributeImport.ButtonLabel");
            
        tooltip = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.AttributeImport.ButtonTooltip");
            
    }
    else if ("parameterExport".equals(objectAction))
    {
        try
        {
            String sRowIds[] = 
                emxGetParameterValues(request, "emxTableRowId");
            int numRows = (sRowIds != null) ?  sRowIds.length: 0;
            StringBuilder rowStr = new StringBuilder();
            
            // create row id string as comma separated list
            for (int ii=0; ii<numRows; ii++ )
            {
                if (rowStr.length() > 0)
                    rowStr = rowStr.append(",");
                rowStr = rowStr.append(sRowIds[ii]);
            }
            startCommand = rowStr.toString();

            title = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.DialogTitle");
                
            btnLabel = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.ButtonLabel");
                
            tooltip = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.ButtonTooltip");
                
            confirmMsg = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.ConfirmMsg");
                
            confirmTitle = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.ParameterExport.ConfirmTitle");
                
        }
        catch (Exception ex)
        {
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
        }
    }
    else if ("attributeExport".equals(objectAction))
    {
        try
        {
            startCommand = "";

            title = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.AttributeExport.DialogTitle");
                
            btnLabel = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.AttributeExport.ButtonLabel");
                
            tooltip = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.AttributeExport.ButtonTooltip");
                
            confirmMsg = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.AttributeExport.ConfirmMsg");
                
            confirmTitle = SimulationUtil.getI18NString(context,
                "smaSimulationCentral.AttributeExport.ConfirmTitle");
                
        }
        catch (Exception ex)
        {
            emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
        }
    }
    // not a valid action
    else  
    {
        String errorMsg = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.Parameter.InvalidAction");
        ErrorStr  = StringResource.format(
            errorMsg, "P1", objectAction);
        emxNavErrorObject.addMessage(ErrorStr);
    }


%>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<%
    if (ErrorStr.length() > 0)
    {
%>
<script language="javascript">
    getTopWindow().closeWindow();
</script>
<%
        return;  
    }else{ 
        URLBuilder contentURL = new URLBuilder(request.getRequestURI().length(),request.getCharacterEncoding());
        contentURL.append("../simulationcentral/smaExecutionApplet.jsp?");
        contentURL.append("locale=").appendEncoded(context,locale);
%>
<form name="exportParam" action="<%=contentURL.toString()%>" method="post">
<input type="hidden" name="AppletWidth" value="10"/>
<input type="hidden" name="AppletHeight" value="10"/>
<input type="hidden" name="TNR" value="<%=objId%>"/>
<input type="hidden" name="HOST" value="<%=hostName%>"/>
<input type="hidden" name="USERNAME" value="<%=userName%>"/>
<input type="hidden" name="USERPASS" value="<%=userPass%>"/>
<input type="hidden" name="OPERATION" value="<%=objectAction%>"/>
<input type="hidden" name="STARTCOMMAND" value="<%=startCommand%>"/>
<input type="hidden" name="OVERWRITEDUPLICATES" value="<%=overwrite%>"/>
<input type="hidden" name="TITLE" value="<%=title%>"/>
<input type="hidden" name="BTNLABEL" value="<%=btnLabel%>"/>
<input type="hidden" name="TOOLTIP" value="<%=tooltip%>"/>
<input type="hidden" name="CONFIRMMSG" value="<%=confirmMsg%>"/>
<input type="hidden" name="CONFIRMTITLE" value="<%=confirmTitle%>"/>

</form>

<script language="javascript">
document.forms["exportParam"].submit();
</script>
<%  
    }    
   
%>

