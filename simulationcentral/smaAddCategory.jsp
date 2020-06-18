<%-- smaShowRelated.jsp

   Copyright (c) 1999-2007 MatrixOne, Inc.
   All Rights Reserved.

   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@page import="java.net.URLDecoder"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.common.CommonDocument"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants" %>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>

<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil" %>
<%@page import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants" %>
<%@page import="matrix.util.StringList"%>
 <%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>

<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUITableUtil.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<script language="Javascript" src="../common/scripts/emxUIToolbar.js"></script>
<script language="Javascript" src="../common/scripts/emxNavigatorHelp.js"></script>

<%
    String sObjectId = emxGetParameter(request,"objectId");
    String sCats     = emxGetParameter(request,"categories");
    String sHelpMarker = emxGetParameter(request,"helpMarker");
    String export = emxGetParameter(request, "export");
    String suiteKey = emxGetParameter(request, "suiteKey");
    
    sCats = URLDecoder.decode(sCats);
    sCats = sCats.replace("[","");
    sCats = sCats.replace("]","");
    sCats = sCats.replace(", ",",");
    
    final String locale = context.getSession().getLanguage();
    String header = SimulationUtil.getI18NString(context,
        "Common.AddCategory.Title" );

%>
<script type="text/javascript" language="javascript" >

    addStyleSheet("emxUIDefault");
    addStyleSheet("emxUIList");
    addStyleSheet("emxUIMenu");
    addStyleSheet("emxUIToolbar");

</script>

<body onload="turnOffProgress()">
	
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
		</jsp:include>
<%
	}
%>		
		
	<br>
	
    <form name="addCategoryForm" id="addCategoryForm">

    <table border="0" width="99%" cellpadding="5" cellspacing="2">
    <tr>
        <th><%=header %></th>
    </tr>
    </table>

<%
try
{
    if ( sCats.length() == 0 )
    {
        String msg = EnoviaResourceBundle.getProperty(context,"SimulationCentral",
            "smaSimulationCentral.Content.ErrMsg.nomorecategories",
            locale);
%>
        <p class="error"><%=msg %></p>
<%
    }
    else
    {
        String[] sCat = sCats.split(",");
    
        for ( int ii=0; ii<sCat.length; ii++ )
        {
            String type= new String();
            type = SimulationUIUtil.getLocalizedValues(context, sCat[ii]);
%>
        <input type="checkbox" id="<%=sCat[ii]%>"/><%=type%><br>
<%
        }
    }
}
catch (Exception e)
{
    System.out.println("error: " + e.toString());
}
%>
    </form>

</body>

