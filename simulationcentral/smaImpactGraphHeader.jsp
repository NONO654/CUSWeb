<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Header for the Impact Graph.
--%>
<%@page import = "com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>

<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

<%
String toolbar = emxGetParameter(request, "toolbar");
String header = emxGetParameter(request, "pageHeader");
String suiteKey = emxGetParameter(request, "suiteKey");
String tipPage = emxGetParameter(request, "TipPage");
String printerFriendly = emxGetParameter(request, "PrinterFriendly");
String objectId = emxGetParameter(request, "objectId");
String timeStamp = emxGetParameter(request, "timeStamp");
String export = emxGetParameter(request, "export");
String sHelpMarker = emxGetParameter(request, "helpMarker");

String languageStr = request.getHeader("Accept-Language");

String registeredSuite = null;
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

    if ( (registeredSuite != null)
        && (registeredSuite.trim().length() > 0 ) )
    {
        suiteDir = 
            UINavigatorUtil.getRegisteredDirectory(registeredSuite);
        stringResFileId = 
            UINavigatorUtil.getStringResourceFileId(context,registeredSuite);
    }

    if( header != null && header.trim().length() > 0 )
    {
      header = EnoviaResourceBundle.getProperty(context,stringResFileId,context.getLocale(),
          header);
    }
    if (header == null)
        header = "Impact Graph";

    // Then if the label contain macros, parse them
    if (header.indexOf("$") >= 0 )
    {
        if (objectId != null && objectId.length() > 0 )
        {
            header =
                UIExpression.substituteValues(
                    context, pageContext, header, objectId);
        }
        else
        {
            header = UIExpression.substituteValues(context, header);
        }
    }
}
catch (Exception ex)
{
    String msg = ErrorUtil.getMessage(ex).trim();
     if( msg.length() > 0)
     {
      	emxNavErrorObject.addMessage(msg);
     }
}
 
%>
<html>
<head>
<title></title>
<%@include file = "../common/emxUIConstantsInclude.inc"%>

<%@include file = "../emxStyleDefaultInclude.inc"%>
<script>
	addStyleSheet("emxUIToolbar");
	addStyleSheet("emxUIMenu");
</script>

<script src="../common/scripts/emxUIToolbar.js"></script>
<script src="../common/scripts/emxUIModal.js"></script>
<script src="../common/scripts/emxUIPopups.js"></script>
<script src="../common/scripts/emxNavigatorHelp.js"></script>
<script src="../common/scripts/emxUILifecycleUtils.js"></script>
<script src="../emxUIPageUtility.js"></script>

<script language="JavaScript">
  <!--
  function refreshImpactGraph()
  {
	  parent.refreshImpactGraph();
	  return false;
  }
  //-->
</script>

</head>
   <body>
    <form name="ImpactGraph" method="post" >
    
      <table border="0" cellspacing="2" cellpadding="0" width="100%">
         <tr>
            <td width="99%">
               <table border="0" cellspacing="0" cellpadding="0" width="100%">
                   <tr>
                       <td class="pageBorder"><img src="../common/images/utilSpacer.gif" width="1" height="1" alt=""></td>
                   </tr>
               </table>
               <table border="0" width="100%" cellspacing="0" cellpadding="0">
                  <tr>
                     <td width="1%" nowrap><span class="pageHeader">&nbsp;<%=header%></span></td>
                        <%                                            
                            String progressImage = "../common/images/utilProgressSummary.gif";
                            String processingText = UINavigatorUtil.getProcessingText(context, languageStr);    
                        %>                                        
                        <td nowrap><div id="imgProgressDiv">&nbsp;<img src="<%=progressImage%>" width="34" height="28" name="progress" align=absmiddle>&nbsp;<i><%=processingText%></i></div></td>
                     <td width="1%"><img src="../common/images/utilSpacer.gif" width="1" height="32" border="0" alt="" vspace="6"></td>
                     <td align="right" class="filter">&nbsp;</td>
                  </tr>
               </table>
                                                              
<jsp:include page = "../common/emxToolbar.jsp" flush="true">
    <jsp:param name="toolbar" value="<%=toolbar%>"/>
    <jsp:param name="objectId" value="<%=objectId%>"/>
    <jsp:param name="parentOID" value="<%=objectId%>"/>
    <jsp:param name="timeStamp" value="<%=timeStamp%>"/>
    <jsp:param name="header" value="<%=header%>"/>
    <jsp:param name="PrinterFriendly" value="<%=printerFriendly%>"/>
    <jsp:param name="export" value="<%=export%>"/>
    <jsp:param name="helpMarker" value="<%=sHelpMarker%>"/>
    <jsp:param name="tipPage" value="<%=tipPage%>"/>
    <jsp:param name="suiteKey" value="<%=suiteKey%>"/>
</jsp:include> 
            </td>
            <td><img src="../common/images/utilSpacer.gif" alt="" width="4"></td>
         </tr>
      </table>
	</form> 
<%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%> 
</body>
</html>
