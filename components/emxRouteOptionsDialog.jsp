<%--  emxRouteOptionsDialog.jsp   -   Display Start Route Dialog

   Copyright (c) 1992-2018 Dassault Systemes.All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteOptionsDialog.jsp.rca 1.22 Wed Oct 22 16:17:50 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc" %>
<%@include file = "emxRouteInclude.inc" %>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>



<%

  Map paramMap = (Map) session.getAttribute("strParams");
  Iterator keyItr = paramMap.keySet().iterator();
  while (keyItr.hasNext())
  {
    String name = (String) keyItr.next();
    String value = (String) paramMap.get(name);
    request.setAttribute(name, value);
  }

  String languageStr          = request.getHeader("Accept-Language");
  String routeId              = emxGetParameter(request,"routeId");
  String projectId            = emxGetParameter(request,"objectId");
  String routeOrder           = emxGetParameter(request, "routeOrder");
  String routeAction          = emxGetParameter(request, "routeAction");
  String routeInstructions    = emxGetParameter(request, "routeInstructions");
  String routeTime            = emxGetParameter(request,"routeTime");
  String personName           = emxGetParameter(request,"personName");
  String templateId           = emxGetParameter(request,"templateId");
  String templateName         = emxGetParameter(request,"templateName");
  String routeNodes           = emxGetParameter(request,"routeNodes");
  String assigneeType         = emxGetParameter(request,"assigneeType");
  String selectedAction       = emxGetParameter(request,"selectedAction");
  String portalMode           = emxGetParameter(request,"portalMode");

  String sOriginated          = "attribute_Originated";
  String sAttrOriginated      = PropertyUtil.getSchemaProperty(context,sOriginated);

  // Route node id's are put in session as routeNode, is param routeNodes not exists
  // take from routeNode
  if(routeNodes == null || "".equals(routeNodes) || "null".equals(routeNodes) ){
    routeNodes = emxGetParameter(request,"routeNode");
  }

  BusinessObject boRoute = new BusinessObject(routeId);
  boRoute.open(context);
  String sRouteName      = boRoute.getName();
  String sDescription    = boRoute.getDescription();
  sOriginated=boRoute.getCreated();

  String strRelObjectRoute    = "relationship_ObjectRoute";
  String strRouteRel          = PropertyUtil.getSchemaProperty(context, strRelObjectRoute );
  String typeContent          = PropertyUtil.getSchemaProperty(context, "type_Document");
  Pattern typePattern         = new Pattern(typeContent);
  Pattern relPattern          = new Pattern(strRouteRel);

  boRoute.close(context);
%>

<script language="JavaScript">

  function closeWindow() {
    parent.window.getWindowOpener().parent.location = parent.window.getWindowOpener().parent.location.href;
    window.closeWindow();
    return;
  }

  function goBack() {

    document.optionsDialog.action="emxRouteActionRequiredDialogFS.jsp?portalMode=<%= XSSUtil.encodeForJavaScript(context,portalMode)%>";
    document.optionsDialog.submit();
 }

  function submitForm() {
    // Make sure user doesnt double clicks
    if (jsDblClick()) {
      document.optionsDialog.submit();
      return;
    }

  }

</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<form method="post" name="optionsDialog" action="emxRouteStartProcess.jsp" target="_parent">
<input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=projectId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeOrder" value="<xss:encodeForHTMLAttribute><%=routeOrder%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeInstructions" value="<xss:encodeForHTMLAttribute><%=routeInstructions%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeTime" value="<xss:encodeForHTMLAttribute><%=routeTime%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="personName" value="<xss:encodeForHTMLAttribute><%=personName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeAction" value="<xss:encodeForHTMLAttribute><%=routeAction%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=templateId%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=templateName%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="routeNode" value="<xss:encodeForHTMLAttribute><%=routeNodes%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="assigneeType" value="<xss:encodeForHTMLAttribute><%=assigneeType%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="selectedAction" value="<xss:encodeForHTMLAttribute><%=selectedAction%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="portalMode" value="<xss:encodeForHTMLAttribute><%=portalMode%></xss:encodeForHTMLAttribute>" />


  <table border="0" cellpadding="5" cellspacing="2" width="100%">
    <tr>
      <td width="150" class="label"><label for="Name"><emxUtil:i18n localize="i18nId">emxComponents.Common.Name</emxUtil:i18n></label>&nbsp;</td>
      <td width="380" class="inputField"><%=sRouteName%></td>
    </tr>

    <tr>
      <td width="150" class="label"><label for="StartDate"><emxUtil:i18n localize="i18nId">emxComponents.OptionsDialog.StartDate</emxUtil:i18n></label>&nbsp;</td>
      <td width="380" class="inputField"><emxUtil:lzDate displaydate="true" displaytime="true" localize="i18nId" tz='<%=(String)session.getValue("timeZone")%>' format='<%=DateFrm %>' ><%=sOriginated%></emxUtil:lzDate>&nbsp;</td>
    </tr>

    <tr>
      <td width="150" class="label"><label for="Description"><emxUtil:i18n localize="i18nId">emxComponents.Common.Description</emxUtil:i18n></label>&nbsp;</td>
      <td width="380" class="inputField"><%=sDescription%></td>
    </tr>

    <tr>
      <td width="150" class="labelRequired">
        <label for="Stage"><emxUtil:i18n localize="i18nId">emxComponents.OptionsDialog.Stage</emxUtil:i18n></label>
      </td>
      <td class="inputField" width="380">
        <table border="0">
          <tr>
            <td>
              <input type="radio" value="start" name="Stage" id="Stage" />
            </td>
            <td><%=i18nNow.getI18nString("emxComponents.OptionsDialog.StartRoute", "emxComponentsStringResource", languageStr)%></td>
          </tr>
          <tr>
            <td>
              <input type="radio" checked value="later" name="Stage" id="Stage" />
            </td>
            <td><%=i18nNow.getI18nString("emxComponents.OptionsDialog.StartRouteManually", "emxComponentsStringResource", languageStr)%></td>
          </tr>
        </table>
      </td>
    </tr>

  </table>

</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
