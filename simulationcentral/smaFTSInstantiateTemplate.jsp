<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Process instantiate template commands.
--%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Template"%>

<%@page import="matrix.util.StringList"%>
<%@include file="../common/emxNavigatorInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>

<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript"
    src="../simulationcentral/smaStructureNavigator.js"></script>
<script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>

<!-- Used to load "findFrame" -->
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="javascript" src="../common/scripts/jquery-latest.js"></script>
<%
String objectId  = emxGetParameter(request, "objectId");
String parentId  = emxGetParameter(request, "parentOID");
String connected         = emxGetParameter(request, "connected");
String fromAct           = emxGetParameter(request, "fromAct");
String toAct             = emxGetParameter(request, "toAct");
String fromWidget  = emxGetParameter(request, "fromWidget");
String timestamp = emxGetParameter(request, "timeStamp");
String refreshFrame = emxGetParameter(request, "refreshFrame");
String lang = request.getHeader("Accept-Language");
 
    //remove session data if the template is being instantiated
    // in parent folder
    if(objectId==null&&parentId==null)
    {
        session.removeAttribute("TargetFolder");
    }
    //added and modified for Template enhancements <Release R2012>
    String strMode = emxGetParameter(request, "mode");
    String optType = emxGetParameter(request, "optionType");
    String showApply = emxGetParameter(request, "showApply");
    if (optType == null || optType.length() == 0) 
        optType = "viewableFields";

    // Should only happen via internal errors
    if ( objectId == null || objectId.length() == 0 )
    {
        String msg = SimulationUtil.getI18NString(
            context, "Error.Internal.NoSelection", lang);
        emxNavErrorObject.addMessage(msg);
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%
    }
    // Got the objectId, lets show the table
    else
    {
        String parentRowId = emxGetParameter(request, "parentRowId");
        if ( parentRowId == null || parentRowId.length() == 0 )
            parentRowId = emxGetParameter(request, "emxTableRowId");
        
        if (strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_IN_ACTIVITY) && 
            parentRowId != null && parentRowId.indexOf('|') != -1 )
        {
            objectId = parentRowId.split("\\|")[1];
            parentId = parentRowId.split("\\|")[2];
        }

        StringBuffer href = new StringBuffer(256);
        href
            .append("../common/emxTableEdit.jsp")            
            .append("?objectId=").append(objectId)
            .append("&table=SMATemplate_Instantiate")
            //commented for Template enhancements <Release R2012> 
            //.append("&header=Template.Instantiate.PageHeading") 
            //.append("&editToolbar=SMATemplate_InstantiateToolbar")
            .append("&selection=none")
            .append("&HelpMarker=SMATemplate_NavTreeInstantiate")
            .append("&Export=false")
            .append("&PrinterFriendly=true")
            .append("&program=jpo.simulation.Template:getOptions")
            .append("&postProcessURL=../simulationcentral/smaInstantiateTemplateProcess.jsp")
            .append("&disableSorting=true")
            .append("&multiColumnSort=false")
            .append("&headerRepeat=0")
            .append("&objectBased=false")
            .append("&customize=false")
            .append("&findMxLink=false")
            .append("&pagination=0")
            .append("&massUpdate=false")
            .append("&suiteKey=SimulationCentral")
            .append("&origTimestamp=").append(timestamp)
            .append("&cancelProcessJPO=jpo.simulation.Template:cancelInstantiate")
            .append("&isPopup=true")
            .append("&stopOOTBRefresh=false")
            .append("&parentOID=").append(parentId)
            .append("&parentRowId=").append(parentRowId)
            .append("&refreshFrame=").append(refreshFrame)
	       .append("&fromWidget=").append(fromWidget)
	       .append("&connected=").append(connected)
	       .append("&fromAct=").append(fromAct)
	       .append("&toAct=").append(toAct);
        
        if(showApply!=null && showApply.equalsIgnoreCase("true"))
            href.append("&showApply=true");
        
        //added for Template enhancements <Release R2012> - Start
        if(strMode.equalsIgnoreCase(SimulationConstants.TEMPLATE_MODE_INSTANTIATE_IN_ACTIVITY))
        {
            href.append("&header=Template.Instantiate.PageHeading");
            href.append("&editToolbar=SMATemplate_InstantiateOnlyToolbar");
        }
        href.append("&mode=").append(strMode);   
        href.append("&optionType=").append(optType);
        
if (timestamp != null)
{
    %>
    <script>
            try
            {
                var hrefURL = "<%=href.toString()%>";

                getTopWindow().location.href = hrefURL;
            }
            catch(error)
            {
                console.log(error);
            }
            </script>
    <%
} else {
    %>
    <script>
            try
            {
                var hrefURL = "<%=href.toString()%>";
                var val = "<%=fromWidget%>";
                if(val === 'true')
                    {
                    getTopWindow().location.href = hrefURL;
                    }else
                        {
                showModalDialog('<%=XSSUtil.encodeForJavaScript(context, href.toString())%>');
                        }
            }
            catch(error)
            {
                console.log(error);
            }
            </script>
    <%
}

}
%>

