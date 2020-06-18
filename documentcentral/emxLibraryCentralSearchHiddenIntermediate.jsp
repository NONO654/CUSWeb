<%--  emxLibraryCentralSearchHiddenIntermediate.jsp  -
   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@include file="../emxUIFramesetUtil.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>
<jsp:useBean id="LibraryCentralBean" class="com.matrixone.apps.library.Libraries" scope="session"/>

<%
    try  
    {
        StringBuffer contentURL          = new StringBuffer("../common/emxFullSearch.jsp?field=TYPES="); 
        String useMode                   = emxGetParameter(request,"useMode");
        String languageStr               = request.getHeader("Accept-Language");
        String emxTableRowIds[]          = getTableRowIDsArray(emxGetParameterValues(request,"emxTableRowId"));
        String parentOId                 = emxGetParameter(request, "objectId");
        String sSymbolicParentType       = "";
        String sType                     = "";
        useMode                          = UIUtil.isNullOrEmpty(useMode)?"":useMode;
        boolean isValidType              = true;
        String strAllowedItems           = (String)JSPUtil.getCentralProperty(application,session,"emxLibraryCentral","Record.SupportedTypes");
        StringTokenizer stAllowedTypes   = new StringTokenizer(strAllowedItems, ",");
        parentOId                        = emxTableRowIds[0];
        DomainObject domObj              = new DomainObject(parentOId);
        while (stAllowedTypes.hasMoreTokens()) {
            String allowedType      = stAllowedTypes.nextToken();                
            isValidType             =  domObj.isKindOf(context, PropertyUtil.getSchemaProperty(context,allowedType));
            if(isValidType) {
                break;
               }
        }
        if(!isValidType) {
            sType                   = domObj.getType(context);
            sType                   = i18nNow.getTypeI18NString(sType,languageStr);
        }
          contentURL.append("type_RetentionRecord,type_RetentionHold&selection=multiple&");
          contentURL.append("table=AEFGeneralSearchResults&excludeOIDprogram=emxLibraryCentralFindObjects:getAddExisitingExcludeOIDs&");
          contentURL.append("submitURL=../documentcentral/emxLibraryCentralAddExistingProcess.jsp&HelpMarker=emxhelpfullsearch&useMode=");
          contentURL.append(useMode);
          contentURL.append("&objectId=");
          contentURL.append(parentOId);
 %>
  <script language="JavaScript" src="../common/scripts/emxUIModal.js"></script>
  <script type="text/javascript">
            if("true" == "<xss:encodeForJavaScript><%=isValidType%></xss:encodeForJavaScript>") {
                    showModalDialog("<xss:encodeForJavaScript><%=contentURL.toString()%></xss:encodeForJavaScript>");
            } else {
                var errorMessage =  "<emxUtil:i18nScript localize = "i18nId">emxLibraryCentral.Common.ChoosenType</emxUtil:i18nScript>";
                errorMessage = errorMessage +" "+"<xss:encodeForJavaScript><%=sType%></xss:encodeForJavaScript>";
               alert(errorMessage);
            }
        </script>
<%
    }
    catch (Exception ex){
        ex.printStackTrace();
    }
%>
