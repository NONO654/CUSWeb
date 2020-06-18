<%--  emxRouteRemoveContentProcess.jsp - Removes Content from the route .
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne, Inc
   Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxRouteRemoveContentProcess.jsp.rca 1.14 Wed Oct 22 16:18:40 2008 przemek Experimental przemek $
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxRouteInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>


<%
  Route boRoute = (Route)DomainObject.newInstance(context,DomainConstants.TYPE_ROUTE);
  String routeId   = emxGetParameter(request, "routeId");
  String supplierOrgId = emxGetParameter(request,"supplierOrgId");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String[] selPersons   = emxGetParameterValues(request, "chkItem");
  boRoute.setId(routeId);
  try {
    boRoute.RemoveContent(context, selPersons);
  } catch(Exception e) {
     System.out.println("error:" + e.getMessage());
  }

  String relatedObjectId = emxGetParameter(request,"objectId");
  String sTemplateId   = emxGetParameter(request,"templateId");
  String scopeId   = emxGetParameter(request,"scopeId");
  String sTemplateName   = emxGetParameter(request,"templateName");
  String sDelete   = emxGetParameter(request,"deletefromsummary");

%>
<%@include file = "../emxUICommonHeaderEndInclude.inc"%>

<form name="ContenForm" method="post" target="_parent">
  <input type="hidden" name="routeId" value="<xss:encodeForHTMLAttribute><%=routeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=relatedObjectId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="templateId" value="<xss:encodeForHTMLAttribute><%=sTemplateId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="scopeId" value="<xss:encodeForHTMLAttribute><%=scopeId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="templateName" value="<xss:encodeForHTMLAttribute><%=sTemplateName%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="supplierOrgId" value="<xss:encodeForHTMLAttribute><%=supplierOrgId%></xss:encodeForHTMLAttribute>"/>
  <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>

</form>
<%
if ((sDelete!= null) && !(sDelete.equals("")) && (sDelete.equalsIgnoreCase("true"))) {
%>
<!-- Added for the Bug No: 326829 12/6/2006 Begin -->
<script language="Javascript" >
  var frameContent = findFrame(getTopWindow(),"detailsDisplay");
  var contTree = getTopWindow().objStructureTree;
  if(contTree == null) {
      if (frameContent != null )
      {
        frameContent.document.location.href = frameContent.document.location.href;
      } else {
        getTopWindow().document.location.href = getTopWindow().document.location.href;
      }
  } else {
<%
      for (int i=0;i<selPersons.length;i++){
        String objId = selPersons[i];
%>
          contTree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, objId)%>", false);
<%
        }
%>
    if (frameContent != null )
    {
		parent.location.href = parent.location.href;
    } else {
      getTopWindow().document.location.href = getTopWindow().document.location.href;
    }
  }
</script>

<!-- <script language="javascript">
  document.ContenForm.action="emxRouteContentSummaryFS.jsp";
  document.ContenForm.submit();
</script> -->
<!-- Added for the Bug No: 326829 12/6/2006 End -->

<%
}

else {
%>
<script language="javascript">
  document.ContenForm.action="emxRouteAddAttachmentsDialogFS.jsp";
  document.ContenForm.submit();
</script>
<%
}
%>

<%@include file = "../emxUICommonEndOfPageInclude.inc"%>
