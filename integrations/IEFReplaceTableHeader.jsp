<%--  IEFReplaceTableHeader.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file = "../common/emxNavigatorInclude.inc"%>

<%@ page import= "com.matrixone.MCADIntegration.server.beans.*,com.matrixone.MCADIntegration.utils.*,				 com.matrixone.MCADIntegration.server.*" %>
<%@ page import = "com.matrixone.MCADIntegration.server.beans.MCADMxUtil"%>

<%!
	public ArrayList busTypeNames = null;

    public String getVerticalViewSelectControlString(Context _context, String lang)throws Exception
    {
        StringBuffer viewSelectControlBuffer = new StringBuffer(" <select name=\"replaceTypeComboControl\" >\n");
        if(busTypeNames != null)
        {
            for(int i=0; i<busTypeNames.size(); i++)
            {
                String option = (String)busTypeNames.get(i);
                String optionStr = "";
                optionStr = MCADMxUtil.getNLSName(_context, "Type", option, "", "", lang);

                viewSelectControlBuffer.append(" <option value=\"" + option + "\">" + optionStr + "</option>\n");
            }
        }
        viewSelectControlBuffer.append(" </select>\n");
        return viewSelectControlBuffer.toString();
    }
%>

<%
	String objectID								= emxGetParameter(request, "objectId");
	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
    context										= integSessionData.getClonedContext(session);

	BusinessObject bus  = new BusinessObject(objectID);
	bus.open(context);
	String busTypeName1 = bus.getTypeName();
	MCADMxUtil util		= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	String busTypeName2 = util.getCorrespondingType(context, busTypeName1);
	busTypeNames = new ArrayList();
	busTypeNames.add(busTypeName1);
	busTypeNames.add(busTypeName2);

	MCADServerResourceBundle serverResourceBundle = integSessionData.getResourceBundle();
	String replaceTitle							  = serverResourceBundle.getString("mcadIntegration.Server.Title.ReplaceTitle");
	String selectDesignForReplace				  = serverResourceBundle.getString("mcadIntegration.Server.FieldName.SelectDesignForReplacement");
	String type									  = serverResourceBundle.getString("mcadIntegration.Server.FieldName.Type");
	String name									  = serverResourceBundle.getString("mcadIntegration.Server.FieldName.Name");
	String revision								  = serverResourceBundle.getString("mcadIntegration.Server.FieldName.Revision");
	String find									  = serverResourceBundle.getString("mcadIntegration.Server.ButtonName.Find");

	String language		= request.getHeader("Accept-Language");
	String HelpMarker	= "emxhelpdscreplacedesign";
	String strHelp		= UINavigatorUtil.getI18nString("emxFramework.Common.Tooltip.Help", "emxFrameworkStringResource", language);
%>

<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="javascript">
var framecontentFrame = null;

function onNameInput()
{
	framecontentFrame = findFrame(parent,"contentFrame");
	if(framecontentFrame.document.forms[1].replaceWithSetter)
	{
      framecontentFrame.document.forms[1].replaceWithSetter.value = "manual";
	}
}
function onRevInput()
{
	framecontentFrame = findFrame(parent,"contentFrame");
	if(framecontentFrame.document.forms[1].replaceWithSetter)
		{
			framecontentFrame.document.forms[1].replaceWithSetter.value = "manual";
		}
}
function searchDesign()
{
	framecontentFrame = findFrame(parent,"contentFrame");
	framecontentFrame.showSearchDialog();
}
</script>

		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css" />
		<link rel="stylesheet" type="text/css" href="../common/styles/emxUIList.css" />

	<title>Replace</title>
	<link rel="stylesheet" href="./styles/emxIEFCommonUI.css" type="text/css">
</head>
<body>
<script language="javascript" src="./scripts/IEFHelpInclude.js">
</script>
	<form name="replaceWith">

<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td>
	<table border="0" width="100%" cellpadding="0">
        <tr>
               <!--<td width="1%" nowrap><span class="pageHeader" id="pageHeader">&nbsp;<emxUtil:i18n localize="i18nId">emxIEFDesignCenter.Common.ReplaceTitle</emxUtil:i18n></span></td> -->
			   <td width="1%" nowrap><span class="pageHeader" id="pageHeader">&nbsp;<%=replaceTitle%></span></td>
			   <td>&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/utilSpace.gif" width="26" height="22" name="imgProgress"></td>
			   <td align="right" ><a href='javascript:openIEFHelp("<%=HelpMarker%>")'><img src="images/buttonContextHelp.gif" width="16" height="16" border="0" title="<%=strHelp%>"></a></td>
 		</tr>
        </table>
</td>
</tr>
</table>

<table border="0" cellspacing="0" cellpadding="0" width="100%">
<tr>
<td>

<table border="1" cellspacing="0" cellpadding="0" width="100%">
        <tr>
            <td><img src="images/utilSpace.gif" width="1" height="1"></img></td>
        </tr>
        <tr>
            <img src="images/utilSpace.gif" width="1" height="1"></img>
        </tr>
        </table>

        <table border="0" cellspacing="0" cellpadding="0" width="100%">

		<tr>
		       <td nowrap width="1%"><b><%=selectDesignForReplace%></b></td>
			   <td>&nbsp;&nbsp;&nbsp;&nbsp;<img src="images/utilSpace.gif" width="2" height="2" name="imgProgress"></td>
			   <td nowrap align="left" class="label"><b><%=type%></b>
                <%=getVerticalViewSelectControlString(context, language)%>
               </td>
				<td width="50" class="label"><b><%=name%></b></td>
				<td class="inputField">
				<input type="text" name="txtName" size="20" id="name" value="" onclick="onNameInput()" onfocus="onNameInput()">
				</td>
			    <td class="label"><b><%=revision%></b></td>
				<td class="inputField"><input type="text" name="txtRev" size="5" value="" onclick="onRevInput()" onfocus="onRevInput()"></td>
				<td>
				       <input type=button name="selDesign" value="<%=find%>" onclick="searchDesign()";>
				</td>

        </tr>
    </table>
</td>
</tr>
</table>


	</form>
</body>
</html>



