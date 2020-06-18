<%-- smaShowRelated.jsp

   Copyright (c) 1999-2007 MatrixOne, Inc.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@page import = "matrix.db.JPO"%>
<%@page import = "com.matrixone.apps.domain.DomainObject"%>
<%@page import = "com.matrixone.apps.domain.DomainSymbolicConstants" %>
<%@page import = "com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<head>
<%
    // Get page title
    String locale = context.getSession().getLanguage();
    String pageTitle = SimulationUtil.getI18NString(context,
        "smaSimulationCentral.smaShowRelated.PageTitle");
%>
<title><%=pageTitle %></title>
</head>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script language="Javascript" src="../common/scripts/emxUIToolbar.js"></script>
<script language="Javascript" src="../common/scripts/emxNavigatorHelp.js"></script>

<script type="text/javascript" language="javascript" >

    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIList");
    addStyleSheet("emxUIMenu");    
    addStyleSheet("emxUIToolbar");

</script>


<%
    String uiType = emxGetParameter(request,"uiType");
	String sHelpMarker = emxGetParameter(request,"HelpMarker");
	String suiteKey = emxGetParameter(request, "suiteKey");

    String sObjectId = ""; 
    if ( "structureBrowser".equalsIgnoreCase(uiType) )
    {
        String[] sObjectIds = 
            emxGetParameterValues(request, "emxTableRowId");
        sObjectId = sObjectIds[0];
        
        if ( sObjectId.indexOf("|") > -1 )
        {
            StringList objIds = FrameworkUtil.split(sObjectId, "|");
            sObjectId = (String) objIds.get(1);
            
            // Special case if the root was selected
            if ( sObjectId == null || sObjectId.length() == 0 )
                sObjectId = (String) objIds.get(0);
        }
    }
    else if ( "table".equalsIgnoreCase(uiType) )
    {
        sObjectId = emxGetParameter(request,"emxTableRowId");
    }
    else
    {
        // Get object id of item to get references for
        sObjectId = emxGetParameter(request,"objectId");
    }

//    if ( sObjectId == null || sObjectId.length() == 0 )
//    {
//        String[] sObjectIds = 
//            emxGetParameterValues(request, "emxTableRowId");
//        sObjectId = sObjectIds[0];
//    }

    // Get item title/name and revision
    DomainObject DO = new DomainObject();
    DO.setId(sObjectId);

    String selectTitle = 
        SimulationUtil.getAttributeSelect(
            DomainSymbolicConstants.SYMBOLIC_attribute_Title);

    String sDocName = DO.getInfo(context,selectTitle);
    if ( sDocName == null || sDocName.length() == 0 )
    {
        // If VPM Object - get the external name
        String selectVPLMExternalId =
                SimulationUtil.getSchemaProperty(
                SimulationConstants.SYMBOLIC_attribute_VPM_NAME);
        String extVPMName = DO.getAttributeValue(context, selectVPLMExternalId); 
        
        if (extVPMName == null || extVPMName.length() == 0)
        {
            sDocName = DO.getInfo(context,"name");
        }
        else
        {
            sDocName = extVPMName;
        }
    }
    String sDocRev  = DO.getInfo(context,"revision");

    // Call JPO to retrieve path which will be a comma separated string
    String[] args = new String[1];
    args[0] = sObjectId;

    // Get various string translations
    String sPath = (String)JPO.invoke(context, 
        "jpo.simulation.SimulationContent", 
            null, "getRelatedToReferences", args, String.class);

    String refMsg = SimulationUtil.getI18NString(context,
        "smaSimulationCentral.smaShowRelated.References");

    String headerRef= SimulationUtil.getI18NString(context,
        "smaSimulationCentral.smaShowRelated.HeaderReference");
    
    String sRev= SimulationUtil.getI18NString(context,
        "smaSimulationCentral.smaShowRelated.Rev");

%>

<body onload="turnOffProgress()">
    <!--  Page header plus progress clock  -->
    <table border="0" width="100%" cellspacing="0" cellpadding="0">
    <tr>
        <td width="1%" nowrap>
            <span class="pageHeader">
            <%=sDocName%> <%= sRev %> <%=sDocRev%> <%=refMsg %></span>
        </td>
        <td nowrap>
            <div id="imgProgressDiv">&nbsp;
            <img src="images/utilProgressSummary.gif" 
                width="34" height="28" name="progress" 
                align=absmiddle>&nbsp;<i></i></div>
        </td>
        <td width="1%">
            <img src="images/utilSpacer.gif" 
                width="1" height="28" border="0" alt="" vspace="6">
        </td>
    </tr>
    </table>
	
<%
	String sToolbarName = "";
	if ( sToolbarName!= null)
	{
%>
		<jsp:include page = "../common/emxToolbar.jsp" flush="false">
			<jsp:param name="toolbar" value="<%=sToolbarName%>"/>
			<jsp:param name="objectId" value="<%= sObjectId %>"/>
			<jsp:param name="suiteKey" value="<%= suiteKey %>"/>
			<jsp:param name="HelpMarker" value="<%= sHelpMarker %>"/>
			<jsp:param name="topActionbar" value=""/>
			<jsp:param name="bottomActionbar" value=""/>
			<jsp:param name="uiType" value="none"/>
			<jsp:param name="objectCompare" value="false"/>		
		</jsp:include>
<%
	}
%>		

    <!--  Header row for table  -->
    <table border="0" width="99%" cellpadding="5" cellspacing="2">
    <tr>
        <th><%=headerRef %></th>
    </tr>

<%
try
{
    // If no references found, write appropriate message
    if ( sPath.length() == 0 )
    {
        String msg = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.smaShowRelated.noReferencesFound");

%>
        <tr class="even">
            <td align="center" colspan="2"><%=msg %></td>
        </tr>
<%
    }

    // References found, write them out
    else
    {
        boolean odd = true;
        
        // Remove line breaks in path...
        sPath = sPath.replaceAll(",<br>","^");
    
        StringList sPaths = FrameworkUtil.split(sPath, "^");
        int iSize = sPaths.size();
        
        // Loop through list, each element is a reference
        for ( int ii=iSize-1; ii>=0; ii-- )
        {
            // Split element into path & reference
            String sPth = (String) sPaths.get(ii);
            String[] sItem = sPth.split("\\|");
            String sLocation = sItem[0];
            String sRefed = "";
            if( sItem.length > 1 )
            {
                sRefed = sItem[1].replace(" ","");
                
    
                // Get translated reference string
                String[]relationType = sRefed.split(",");
                sRefed = SimulationUtil.getI18NString(context,
                    "smaSimulationCentral.Relationship."+relationType[0]+".ShortName");
                sRefed = " (" + sRefed + ")";
            }
    
            // Even/odd causes different background color
            odd = ( odd ? false : true );
            String trClass = "";
            if ( odd )
                trClass = "odd";
            else
                trClass = "even";
%>
        <tr class="<%=trClass %>">
            <td class="inputField" nowrap="nowrap"><%=sLocation %> <%=sRefed %></td>
        </tr>
<%
        }
    }
}

catch (Exception ex)
{
    emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
}
%>
    
    </table>

<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
    
<iframe name="listHidden" id="listHidden" src="emxBlank.jsp" style="display: none" noresize="noresize" marginheight="0" marginwidth="0" border="0" scrolling="no" height="0" width="0"/>

</body>

