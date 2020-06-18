<%--  emxLibraryCentralFolderAccessAdd.jsp   - The Processing Access Add

   Copyright (c) 1992-2016 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxTreeUtilInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="emxLibraryCentralUtils.inc"%>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%!

    public String getMarkup(Context context,String selFolderObjectId, String[] selectedItems, String sAction,String langStr) throws Exception {
        String selectedId;
        int length                  = (selectedItems == null) ? 0 : selectedItems.length;
        StringBuffer sbOut          = new StringBuffer(length * 150 + 100);
        boolean  isAddPerson        = "addPerson".equalsIgnoreCase(sAction);
        boolean  isAddRole          = "addRole".equalsIgnoreCase(sAction);
        String memberDisplayType    = FrameworkUtil.findAndReplace(EnoviaResourceBundle.getProperty(context,"emxDocumentCentralStringResource",new Locale(langStr),"emxDocumentCentral.Common.Group"),"'","\\'");
        String memberType           = "Group";
        String memberName           = "";
        String memberDisplayName    = "";
        String memberOrganization   = "-";
        if(isAddPerson) {
            memberDisplayType       = FrameworkUtil.findAndReplace(EnoviaResourceBundle.getProperty(context,"emxDocumentCentralStringResource",new Locale(langStr),"emxDocumentCentral.Common.Person"),"'","\\'");
            memberType              = "Person";
        } else if(isAddRole){
            memberDisplayType       = FrameworkUtil.findAndReplace(EnoviaResourceBundle.getProperty(context,"emxDocumentCentralStringResource",new Locale(langStr),"emxDocumentCentral.Common.Role"),"'","\\'");
            memberType              = "Role";
        }
        
        String access               ="Add";
        String sAccessDisplay       = "emxComponents.ObjectAccess."+access.trim();
        sAccessDisplay              = FrameworkUtil.findAndReplace(EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource", new Locale(langStr),sAccessDisplay),"'","\\'");
        sbOut.append("<mxRoot>").append("<action>add</action>").append("<data status=\"pending\">");
        for (int i = 0; i < length; i++) {
            selectedId              = (String) FrameworkUtil.split(selectedItems[i], "|").get(0);
            if(isAddPerson) {
                Person person       = new Person(selectedId);
                selectedId          = person.getName(context);
                memberName          = selectedId;
                memberDisplayName   = person.getDisplayName(context, selectedId);
                Company comp        = person.getCompany(context);
                memberOrganization  = (null == comp)?"   ":comp.getName(context);
            } else {
                memberName          = selectedId;
                memberDisplayName   = com.matrixone.apps.domain.util.i18nNow.getAdminI18NString(memberType,memberName,langStr);
            }
            memberDisplayName =  FrameworkUtil.findAndReplace(memberDisplayName,"'","\\'");
            sbOut.append("<item oid=\"").append(selFolderObjectId);
            sbOut.append("\" pid=\"").append(selFolderObjectId);
            sbOut.append("\" direction=\"").append(selectedId);
             sbOut.append("\" relType=\"\">");
            sbOut.append("<column name=\"Name\" actual=\"").append(memberName).append("\" >");
            sbOut.append(memberDisplayName).append("</column>");
            sbOut.append("<column name=\"Type\" actual=\"").append(memberType).append("\" >");
            sbOut.append(memberDisplayType).append("</column>");
            sbOut.append("<column name=\"Organization\">");
            sbOut.append(memberOrganization).append("</column>");
            sbOut.append("<column name=\"Access\" actual=\"").append(access).append("\">");
            sbOut.append(sAccessDisplay).append("</column>");
            sbOut.append("</item>");
        }
        sbOut.append("</data>").append("</mxRoot>");
        return sbOut.toString();
    }
%>

<%

      String objectId               = emxGetParameter(request, "objectId");
      String sAction                = emxGetParameter(request, "useMode");
      String[] selectedItems        = emxGetParameterValues(request, "emxTableRowId");
      String langStr                = request.getHeader("Accept-Language");
      String strInput               = "";
      String callbackFunctionName   = "addToSelected";
      sAction                       = UIUtil.isNullOrEmpty(sAction)?"":sAction;
      try {
          strInput                  = getMarkup(context , objectId, selectedItems,sAction,langStr);
      } catch (Exception ex) {
          if (ex.toString() != null && (ex.toString().trim()).length() > 0) {
              emxNavErrorObject.addMessage(ex.toString().trim());
          }
      }
%>

    <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

    <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>

    <script language="Javascript">

          //refresh the calling structure browser and close the search window
          var callback      = eval(getTopWindow().getWindowOpener().emxEditableTable.<xss:encodeForJavaScript><%=callbackFunctionName%></xss:encodeForJavaScript>);
          var status        = callback('<xss:encodeForJavaScript><%=strInput%></xss:encodeForJavaScript>');
          getTopWindow().closeWindow();

    </script>
