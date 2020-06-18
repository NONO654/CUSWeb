<%--  emxLibraryCentralAddAttributeGroupsPreProcess.jsp -
   Copyright (c) 1993-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxMultipleClassificationUtils.inc" %>
<jsp:useBean id="attributeGroupBean" class="com.matrixone.apps.classification.AttributeGroup" scope="session"/>

<%
    final String PARAM_SELECTED_ATTRIBUTEGROUPS          = "selectedAttributeGroups";
     //----Getting parameter from request---------------------------


    String objectId                 = emxGetParameter(request, "objectId");
    String strAttributeGroup        = "";
    String[] emxTableRowIds         = null;
    StringList slAttributeGroup     = new StringList();
    try{
        emxTableRowIds          = (String[]) emxGetParameterValues(request, "emxTableRowId");
    }
    catch (Exception ex){
        String emxSingleRowId   = emxGetParameter(request, "emxTableRowId");
        emxTableRowIds          = new String[1];
        emxTableRowIds[0]       = emxSingleRowId;
    }
    if (emxTableRowIds != null && emxTableRowIds.length > 0) {
        for (int cnt=0;cnt<emxTableRowIds.length;cnt++) {
              strAttributeGroup = emxTableRowIds[cnt];
              strAttributeGroup = strAttributeGroup.substring(1,strAttributeGroup.length());
              strAttributeGroup = strAttributeGroup.substring(0,strAttributeGroup.indexOf("|"));
              slAttributeGroup.addElement(strAttributeGroup);
         }
    }
    attributeGroupBean.setAttributeGroups(slAttributeGroup);
    String language             = request.getHeader("Accept-Language");
    String strAttr              = "";
    StringList attributesList   = new StringList();
    Iterator itrAttributeGroup  = slAttributeGroup.iterator();
    com.matrixone.apps.classification.AttributeGroup agObject;
    while (itrAttributeGroup.hasNext()){
          strAttr = (String)itrAttributeGroup.next();
          agObject      = com.matrixone.apps.classification.AttributeGroup.getInstance(context,strAttr);
          if(agObject.getAttributes() != null && agObject.getAttributes().size() > 0) {
                attributesList.addAll(agObject.getAttributes());
          }
    }
    com.matrixone.apps.classification.Classification clsObject = (com.matrixone.apps.classification.Classification)DomainObject.newInstance(context, objectId, "Classification");
    StringList relatedAttributeGroups   = clsObject.getAttributeGroups(context, true);
    StringList addedAttributesList      = new StringList();
    Iterator itrAttribute                         = relatedAttributeGroups.iterator();
    while(itrAttribute .hasNext()) {
        agObject = com.matrixone.apps.classification.AttributeGroup.getInstance(context,(String)itrAttribute .next());
        if(agObject.getAttributes() != null && agObject.getAttributes().size() > 0) {
            addedAttributesList.addAll(agObject.getAttributes());
        }
    }
    itrAttribute                  = attributesList.iterator();
    boolean hasAttribute = false;
    while(itrAttribute.hasNext()) {
        hasAttribute     = addedAttributesList.contains(itrAttribute.next());
        if(hasAttribute) {
            break;
        }
    }
    //strAttributeGroup   = FrameworkUtil.encodeNonAlphaNumeric(strAttributeGroup,Framework.getCharacterEncoding(request));
    String fwdUrl       = "../documentcentral/emxLibraryCentralAddAttributeGroupsProcess.jsp?objectId=" + objectId;
    if(hasAttribute) {
        String confirmMsg = EnoviaResourceBundle.getProperty(context,"emxLibraryCentralStringResource",new Locale( language),"emxMultipleClassification.AttributeGroup.Message.AddExistingAttributesConfirmation");
%>
		<form name="formForward" method="post" target = "listHidden" action="<%=XSSUtil.encodeForHTMLAttribute(context,fwdUrl)%>">
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
        <script language="javascript">
            if(confirm("<xss:encodeForJavaScript><%=confirmMsg%></xss:encodeForJavaScript>"))
            {
                <%-- document.location.href="<xss:encodeForJavaScript><%=fwdUrl%></xss:encodeForJavaScript>"; --%>
                document.formForward.submit();
            }
            else
            {
                getTopWindow().closeWindow();
            }
        </script>
        </form>
<%
    } else {
%>
		<form name="formForward" method="post" target = "listHidden" action="<%=XSSUtil.encodeForHTMLAttribute(context,fwdUrl)%>">
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
        <script language="javascript">
        	<%-- document.location.href="<xss:encodeForJavaScript><%=fwdUrl%></xss:encodeForJavaScript>";--%>
        	document.formForward.submit();
        </script>
        </form>
<%
    }
%>
<%@include file ="../common/emxNavigatorBottomErrorInclude.inc"%>
