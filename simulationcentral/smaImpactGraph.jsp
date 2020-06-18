<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Frameset page for the Impact Graph.
--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<html>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ImpactGraphUI"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>


<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>



<%
    // Get the mode for the page, if no mode is passed then it is basic mode by default
    // This page has been made equivalent to emxLifeCycle.jsp
    // Change done for HF-144123V6R2013x

    String strMode = emxGetParameter(request, "mode");
    String action = emxGetParameter(request, "action");
    if (action != null)
    {
        String timeStamp = emxGetParameter(request, "timeStamp");
        ImpactGraphUI.removeGraph(context,timeStamp);
        return;
    }

    String timeStampImpGph = ImpactGraphUI.getTimeStamp();

    String exclFolderName = SimulationUtil.getProperty(context,"smaSimulationCentral.ImpactGraph.ExclCatagoryAndFolder");

    //--- Get Object Id
    String physicalId = emxGetParameter(request, "physicalId");
    String objectId = null;
    if(physicalId != null && (!physicalId.equals(""))){
    	DomainObject obj = DomainObject.newInstance(context,physicalId);
    	obj.openObject(context);
    	objectId = obj.getInfo(context,"id");
    }

    if(objectId == null || objectId.equals(""))
        objectId = emxGetParameter(request, "objectId");


    String headerPg = emxGetParameter(request, "pageHeader");

    String pageHeader=UIUtil.getWindowTitleName(context,null,objectId,headerPg);
    if (strMode == null || "".equals(strMode.trim()) || "null".equals(strMode.trim())) {
        strMode = "basic";
    }
    String emxTableRowId = emxGetParameter(request, "emxTableRowId");
    String sObjectId = null;
    StringTokenizer st = null;
    matrix.util.StringList sList = null;
    if(emxTableRowId != null)
    {
        if(emxTableRowId.indexOf("|") != -1){
            st = new StringTokenizer(emxTableRowId, "|");
            sList = com.matrixone.apps.domain.util.FrameworkUtil.split(emxTableRowId,"|");
            if(sList.size() == 3){

                sObjectId = (String)sList.get(0);
            }else{
                sObjectId = (String)sList.get(1);
            }
        }else{
            sObjectId = emxTableRowId;
        }
   }else{
       sObjectId = emxGetParameter(request, "objectId" );
   }

        //String appendParams = emxGetQueryString(request);

        // Avoid sending the HelpMarker parameter ahead,
        // the lifecycle header page will form the specific helpmarker for each policy
        StringBuffer sbufAppendParams = new StringBuffer(64);
        Enumeration enumeration = emxGetParameterNames(request);
        while (enumeration.hasMoreElements()) {
            String strParamName = (String)enumeration.nextElement();
            if ("HelpMarker".equals(strParamName)) {
                continue;
            }

            String strParamValue = emxGetParameter(request, strParamName);
            if ("objectId".equals(strParamName) && sObjectId != null) {
                strParamValue = sObjectId;
            }

            if (sbufAppendParams.length() > 0) {
                sbufAppendParams.append("&");
            }

            sbufAppendParams.append(strParamName).append("=").append(strParamValue);
        }
        String appendParams = sbufAppendParams.toString();

        String impactgraphExcludeFld = emxGetParameter(request, "excludeFolders");
        if(impactgraphExcludeFld == null){
        		impactgraphExcludeFld = "false";
        }

        String objectLifecycleBodyURL = "smaImpactGraphDisplay.jsp?" + appendParams+"&timeStamp="+timeStampImpGph+"&excludeFolders="+impactgraphExcludeFld;

        // check if "promote/demote" is going on in the background on this Object
      //  String objectId = emxGetParameter(request, "objectId");
        String inProgressFlag = objectId + "_inProgress";
        String isBackgroundProcessInProgress = (String)session.getAttribute(inProgressFlag);
        String toolbar = emxGetParameter(request, "toolbar");
        String header = emxGetParameter(request, "pageHeader");
        String suiteKey = emxGetParameter(request, "suiteKey");
        String tipPage = emxGetParameter(request, "TipPage");
        String printerFriendly = emxGetParameter(request, "PrinterFriendly");
        String relId = emxGetParameter(request, "relId");
        String timeStamp = emxGetParameter(request, "timeStamp");
        timeStamp = timeStampImpGph;
        String export = emxGetParameter(request, "export");


        String languageStr = request.getHeader("Accept-Language");
        String sHelpMarker = emxGetParameter(request, "helpMarker");
        if(sHelpMarker == null){
            sHelpMarker =  "SMACommon_ImpactGraphShowButterfly";
        }
        String registeredSuite = "";
        String suiteDir = "";
        String stringResFileId = "";

        try
        {

            registeredSuite = suiteKey;

            if ( (registeredSuite != null) && (registeredSuite.trim().length() > 0 ) )
            {
                suiteDir = UINavigatorUtil.getRegisteredDirectory(registeredSuite);
                stringResFileId = UINavigatorUtil.getStringResourceFileId(context,registeredSuite);
            }

            if( header != null && header.trim().length() > 0 )
            {
              header = EnoviaResourceBundle.getProperty(context,stringResFileId,context.getLocale(),header);
            } else{
              header = SimulationUtil.getI18NString(context,"ImpactGraph.PageHeading");
            }

            // Then if the label contain macros, parse them
            if (header.indexOf("$") >= 0 )
            {
                if (objectId != null && objectId.length() > 0 )
                {
                    header = UIExpression.substituteValues(context, header, objectId);
                }
                else
                {
                    header = UIExpression.substituteValues(context, header);
                }
            }
        }
        catch (Exception ex)
        {
             if( ( ex.toString()!=null )
                && (ex.toString().trim()).length()>0)
             {
                emxNavErrorObject.addMessage(ex.toString().trim());
             }
        }

        if( "true".equals(isBackgroundProcessInProgress)){
%>
<META HTTP-EQUIV=REFRESH CONTENT=4>
<%
        }
%>
<head>
<title><%=pageHeader %></title>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<script language="JavaScript" type="text/javascript">
    addStyleSheet("emxUIDOMLayout");
    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIMenu");
</script>
<script>
function cleanupSession(timeStampImpGph)
{
  emxUICore.getData('smaImpactGraph.jsp?action=cleanup&timeStamp=' + timeStampImpGph);
}

<%
       String categoryTreeName = emxGetParameter(request, 
        "categoryTreeName");

String href = "";
    if(categoryTreeName != null && 
        categoryTreeName.equals("type_DOCUMENTS"))
        href = SlmUIUtil.getCommandHref(
        context,
        "SMADOCUMENTS_NavTreeImpactGraph",
        emxGetParameter(request, "objectId"),
        null,
        new HashMap());

    else
        href = SlmUIUtil.getCommandHref(
        context,
        "SMASimulation_NavTreeImpactGraph",
        emxGetParameter(request, "objectId"),
        null,
        new HashMap());
%>
function refreshImpactGraph()
{
	var impactgraphExcludeFolders = sessionStorage.getItem('impactgraphExcludeFolders');
    var frame = findFrame(getTopWindow(),"detailsDisplay");
    if(frame != null){
	document.location.href = '<%= href %>'+"&excludeFolders="+impactgraphExcludeFolders;
	}else{
        getTopWindow().location.href = '<%= href %>'+"&excludeFolders="+impactgraphExcludeFolders+"&physicalId="+'<%= physicalId %>';
    }
}
</script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIToolbar.js"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUIPopups.js"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
<script language="JavaScript" type="text/javascript" src="../common/scripts/emxUILifecycleUtils.js"></script>
<script language="JavaScript" type="text/javascript" src="../emxUIPageUtility.js"></script>
<script language="javascript" src="../common/scripts/jquery-latest.js"></script>

<script>
	$(document).ready( function(){
		var impactgraphExcludeFolders = sessionStorage.getItem('impactgraphExcludeFolders');
		if(impactgraphExcludeFolders == "true"){
			$('#excludeFolders').prop('checked', true);
		}else{
			$('#excludeFolders').prop('checked', false);
		}
		$("#excludeFolders").change(function(){
			if(this.checked){
				sessionStorage.setItem("impactgraphExcludeFolders", "true");
			}
			else{
				sessionStorage.setItem("impactgraphExcludeFolders", "false");
			}
			refreshImpactGraph();
		});
	});
</script>

</head>
<body class="no-footer" onload="turnOffProgress();">

<form method="post">
   <table>
     <tr>
    <td class="page-title">
      <h2><%=header%></h2>
    </td>
    <%
       String processingText = UINavigatorUtil.getProcessingText(context, languageStr);
    %>
        <td class="functions">
            <table>
              <tr>
                <td class="progress-indicator"><div id="imgProgressDiv"><%=processingText%></div></td>
            </tr></table>
        </td>
        </tr>
        </table>

<jsp:include page = "../common/emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value="<%=toolbar%>"/>
    <jsp:param name="objectId" value="<%=objectId%>"/>
    <jsp:param name="relId" value="<%=relId%>"/>
    <jsp:param name="parentOID" value="<%=objectId%>"/>
    <jsp:param name="timeStamp" value="<%=timeStamp%>"/>
    <jsp:param name="header" value="<%=header%>"/>
    <jsp:param name="PrinterFriendly" value="<%=printerFriendly%>"/>
    <jsp:param name="export" value="<%=export%>"/>
    <jsp:param name="HelpMarker" value="<%=sHelpMarker%>"/>
    <jsp:param name="tipPage" value="<%=tipPage%>"/>
    <jsp:param name="suiteKey" value="<%=suiteKey%>"/>
</jsp:include>
</form>

        <div id="divPageBody">
            <style type="text/css">
                 #impactGraphChoice{ border: 1px ; height: 20px; position: absolute; left: 10; top: 0;width: 100%; z-index: 10;}
                 #impactGraphContent{ height: 100%; width: 100% margin: 0; z-index: 1;}
            </style>
            <div id="impactGraphChoice">
                <table id=choiceTable>
                <tr>
                    <td><input type="checkbox" id="excludeFolders" value="exclfolders" />Exclude Category/Folders</td>
                    <td></td>
                </tr>
                </table>
            </div>
            <iframe id="impactGraphContent" name="impactGraphContent" src="<%=objectLifecycleBodyURL%>"  frameborder="0" border="0"></iframe>
            <iframe class="hidden-frame" name="hiddenImpactGraph" src="emxBlank.jsp"></iframe>
        </div>
</body>
<script><%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%></script>
</html>

