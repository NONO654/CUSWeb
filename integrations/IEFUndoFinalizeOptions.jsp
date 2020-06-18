<%--  IEFUndoFinalizeOptions.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>

<%@ include file ="MCADTopInclude.inc" %>
<%@page import="com.matrixone.apps.domain.util.ENOCsrfGuard"%>

<%
 matrix.db.Context context = Framework.getFrameContext(session);
%>

<%
    MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
    Context _context                            = integSessionData.getClonedContext(session);
    MCADMxUtil _util                            = new MCADMxUtil(_context, integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
        
    String integrationName  = emxGetParameter(request, "integrationName");
    String refreshBasePage  = emxGetParameter(request, "refresh");
    String objectID         = emxGetParameter(request, "busId");
    String instanceName     = emxGetParameter(request, "instanceName");
    String localeLanguage   = integSessionData.getLanguageName();
    MCADGlobalConfigObject  globalConfigObject  = integSessionData.getGlobalConfigObject(integrationName,_context);
    String currentState                         = _util.getCurrentState(_context, objectID);
    BusinessObject busObj                       = new BusinessObject(objectID);
    currentState	                        = MCADMxUtil.getNLSName(_context, "State", currentState, "Policy", busObj.getPolicy(_context).getName() , localeLanguage);
    
    String finalizationState        = globalConfigObject.getFinalizationState(busObj.getPolicy(_context).getName());
    boolean isInfinalizationState   = currentState.equalsIgnoreCase(finalizationState)?true:false;
    String busDetails       = integrationName + "|" + refreshBasePage + "|" + objectID;
    if(instanceName != null && !"".equals(instanceName))
        busDetails += "|" + instanceName;
%>

<html>
<head>

<link rel="stylesheet" href="./styles/emxIEFMiscUI.css" type="text/css">


<script src="scripts/MCADUtilMethods.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="JavaScript">
function doneMethod()
{
    var breakPartSpec = "false";
    if(document.UndoFinalizeOption.breakPartSpec && document.UndoFinalizeOption.breakPartSpec.checked == true)
        breakPartSpec = "true";

    document.UndoFinalize.breakPartSpec.value = breakPartSpec;
    document.UndoFinalize.submit();
}
</script>
</head>
<body>
 <table border="0" width="100%">
    <tr>
        <td>
            <form name="UndoFinalizeOption" action="javascript:parent.frames['contentPage'].doneMethod()" method="post" target="_top">

<%
boolean csrfEnabled = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled)
{
  Map csrfTokenMap = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName = (String)csrfTokenMap .get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue = (String)csrfTokenMap.get(csrfTokenName);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName%>" value="<%=csrfTokenValue%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>

            <table border="0" width="100%">
                <tr>
                    <td>
                       <table border="0" width="100%">
			 <!--XSSOK-->
                         <tr><th width="100%"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.Options")%></th></tr>
                        </table>
            
                    </td>
                </tr>
                 <tr>
                    <td>
                     <table border="0" width="100%" cellspacing="2" cellpadding="4">
                          <tr>
			      <!--XSSOK-->
                              <td width="30%"><%=integSessionData.getStringResourceWithHtmlSpaces("mcadIntegration.Server.Heading.CurrentState")%></td>

                              <td width="70%"><b><%=XSSUtil.encodeForHTML(_context, currentState)%></b></td>
                          </tr>
                     </table>
            <% if(isInfinalizationState && FrameworkUtil.isSuiteRegistered(context,"appVersionX-BOMEngineering",false,null,null)) {
            %>
                    </td>
                </tr>
                 <tr>
                    <td>
                                   <% } %>
                    </td>
                </tr>
            </table>
            </form>
        </td>
    </tr>
    <tr>
        <td>
            <form name="UndoFinalize" action="MCADUndoFinalization.jsp" method="post" target="_top">

<%
boolean csrfEnabled1 = ENOCsrfGuard.isCSRFEnabled(context);
if(csrfEnabled1)
{
  Map csrfTokenMap1 = ENOCsrfGuard.getCSRFTokenMap(context, session);
  String csrfTokenName1 = (String)csrfTokenMap1.get(ENOCsrfGuard.CSRF_TOKEN_NAME);
  String csrfTokenValue1 = (String)csrfTokenMap1.get(csrfTokenName1);
%>
  <!--XSSOK-->
  <input type="hidden" name= "<%=ENOCsrfGuard.CSRF_TOKEN_NAME%>" value="<%=csrfTokenName1%>" />
  <!--XSSOK-->
  <input type="hidden" name= "<%=csrfTokenName1%>" value="<%=csrfTokenValue1%>" />
<%
}
//System.out.println("CSRFINJECTION");
%>
            <!--XSSOK-->
            <input type="hidden" name="busDetails" value="<%=XSSUtil.encodeForHTMLAttribute(_context,busDetails)%>">
            <input type="hidden" name="breakPartSpec">
            </form>
        </td>
    </tr>
</table>
</body>
</html>
