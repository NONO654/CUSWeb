<%-- emxLifecycleHeader.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxLifecycleHeader.jsp.rca 1.27 Wed Oct 22 15:48:30 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%
String toolbar = emxGetParameter(request, "toolbar");
String header = emxGetParameter(request, "header");
String suiteKey = emxGetParameter(request, "suiteKey");
String tipPage = emxGetParameter(request, "TipPage");
String printerFriendly = emxGetParameter(request, "PrinterFriendly");
String objectId = emxGetParameter(request, "objectId");
String relId = emxGetParameter(request, "relId");
String timeStamp = emxGetParameter(request, "timeStamp");
String export = emxGetParameter(request, "export");
String sHelpMarker = "emxhelp";

String languageStr = request.getHeader("Accept-Language");

//Open the current BusinessObject
DomainObject boGeneric = DomainObject.newInstance(context, objectId);
SelectList objectSelects = boGeneric.getObjectSelectList(2);
objectSelects.addElement(boGeneric.SELECT_ID);
objectSelects.addElement(boGeneric.SELECT_POLICY);

Map map = boGeneric.getInfo(context, objectSelects);

// Use symbolic policy name to generate help marker for lifecycle (10.5 change)
// The help marker will be the prefix "emxhelp" plus the symbolic name
// of the policy converted to lower case (i.e. emxhelppolicy_ecpart)
// 
String sPolicy = (String)map.get(boGeneric.SELECT_POLICY);
String symbolicPolicy = FrameworkUtil.getAliasForAdmin(context, "policy", sPolicy, true);

if (symbolicPolicy != null) {
sHelpMarker = sHelpMarker + symbolicPolicy.toLowerCase();
}

String registeredSuite = "";
String suiteDir = "";
String stringResFileId = "";

try
{
    if ( suiteKey != null && suiteKey.startsWith("eServiceSuite") )
    {
        registeredSuite = suiteKey.substring(13);
    } else if( suiteKey != null) {
        registeredSuite = suiteKey;
    }

    if ( (registeredSuite != null) && (registeredSuite.trim().length() > 0 ) )
    {
        suiteDir = UINavigatorUtil.getRegisteredDirectory(context,registeredSuite);
        stringResFileId = UINavigatorUtil.getStringResourceFileId(context,registeredSuite);
    }

    if( header != null && header.trim().length() > 0 )
    {
      header = UINavigatorUtil.getI18nString(header, stringResFileId , request.getHeader("Accept-Language"));
    } else{
      header = UINavigatorUtil.getI18nString("emxFramework.Lifecycle.LifeCyclePageHeading", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
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
 
%>
<html>
<head>
<title></title>
<%@include file = "emxUIConstantsInclude.inc"%>

<%@include file = "../emxStyleDefaultInclude.inc"%>
<script language="JavaScript" type="text/javascript">
    addStyleSheet("emxUIToolbar");
    addStyleSheet("emxUIMenu");
</script>

<script language="JavaScript" type="text/javascript" src="scripts/emxUIToolbar.js"></script>
<script language="JavaScript" type="text/javascript" src="scripts/emxUIModal.js"></script>
<script language="JavaScript" type="text/javascript" src="scripts/emxUIPopups.js"></script>
<script language="JavaScript" type="text/javascript" src="scripts/emxNavigatorHelp.js"></script>
<script language="JavaScript" type="text/javascript" src="scripts/emxUILifecycleUtils.js"></script>
<script language="JavaScript" type="text/javascript" src="../emxUIPageUtility.js"></script>
     
</head>
    <body>
        <form name="Lifecycle" method="post" >
        
        <table border="0" cellspacing="2" cellpadding="0" width="100%">
                <tr>
                    <td width="99%">
                        <table border="0" cellspacing="0" cellpadding="0" width="100%">
                                <tr>
                                        <td class="pageBorder"><img src="images/utilSpacer.gif" width="1" height="1" alt="" /></td>
                                </tr>
                        </table>
                        <table border="0" width="100%" cellspacing="0" cellpadding="0">
                                <tr>
                                        <td width="1%" nowrap><span class="pageHeader">&nbsp;<xss:encodeForHTML><%=header%></xss:encodeForHTML></span></td>
                                        <%                                            
                                            String progressImage = "../common/images/utilProgressBlue.gif";
                                            String processingText = UINavigatorUtil.getProcessingText(context, languageStr);    
                                        %>                                        
                                        <!-- //XSSOK -->                                
                                        <td nowrap><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align="absmiddle" />&nbsp;<i><%=processingText%></i></div></td>
                                        <td width="1%"><img src="images/utilSpacer.gif" width="1" height="32" border="0" alt="" vspace="6" /></td>
                                        <td align="right" class="filter">&nbsp;</td>
                                </tr>
                        </table>
                                                              
<jsp:include page = "emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value="<%=XSSUtil.encodeForURL(context, toolbar)%>"/>
    <jsp:param name="objectId" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
    <jsp:param name="relId" value="<%=XSSUtil.encodeForURL(context, relId)%>"/>
    <jsp:param name="parentOID" value="<%=XSSUtil.encodeForURL(context, objectId)%>"/>
    <jsp:param name="timeStamp" value="<%=XSSUtil.encodeForURL(context, timeStamp)%>"/>
    <jsp:param name="header" value="<%=XSSUtil.encodeForURL(context, header)%>"/>
    <jsp:param name="PrinterFriendly" value="<%=XSSUtil.encodeForURL(context, printerFriendly)%>"/>
    <jsp:param name="export" value="<%=XSSUtil.encodeForURL(context, export)%>"/>
    <jsp:param name="helpMarker" value="<%=XSSUtil.encodeForURL(context, sHelpMarker)%>"/>
    <jsp:param name="tipPage" value="<%=XSSUtil.encodeForURL(context, tipPage)%>"/>
    <jsp:param name="suiteKey" value="<%=XSSUtil.encodeForURL(context, suiteKey)%>"/>
</jsp:include> 
                                </td>
                                <td><img src="images/utilSpacer.gif" alt="" width="4" /></td>
                        </tr>
        </table>
    </form> 
<%@include file = "emxNavigatorBottomErrorInclude.inc"%> 
</body>
</html>
