<%--  emxCommonSelectWorkspaceFolderProcess.jsp   -   Display Folders
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonSelectWorkspaceFolderProcess.jsp.rca
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>

<%
String[] strTableRowIds = emxGetParameterValues( request, "emxTableRowId" );

String fromPage = (String) emxGetParameter(request,"fromPage");
String strLanguage = request.getHeader("Accept-Language");

if(strTableRowIds==null)
{
   %> <script language="javascript">
   		 alert("<%=EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Message.PleaseMakeASelection")%>");
   	</script>
   		<%
    return;
}

  if(com.matrixone.apps.framework.ui.UIUtil.isNullOrEmpty(fromPage))
  {
      fromPage="";
  }

strTableRowIds = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds(strTableRowIds);
StringBuffer ids = new StringBuffer(strTableRowIds.length * 20);
StringBuffer names = new StringBuffer(strTableRowIds.length * 10);

matrix.util.StringList selectables = new matrix.util.StringList(2);
String nameSelect = com.matrixone.apps.domain.DomainConstants.SELECT_NAME;
String idSelect = com.matrixone.apps.domain.DomainConstants.SELECT_ID;
selectables.add(idSelect);
selectables.add(nameSelect);

com.matrixone.apps.domain.util.MapList nameList = 
    com.matrixone.apps.domain.DomainObject.getInfo(context, strTableRowIds, selectables);

int index = 0;
for (; index < strTableRowIds.length - 1; index++) { 
    java.util.Map info = (java.util.Map)nameList.get(index);
    ids.append(info.get(idSelect)).append(';');
    names.append(info.get(nameSelect)).append(';');
    }
java.util.Map info = (java.util.Map)nameList.get(index);
ids.append(info.get(idSelect));
names.append(info.get(nameSelect));
%>
<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="Javascript">

<% if(fromPage.equals("routeWizard")){ %>

     var objForm = getTopWindow().getWindowOpener().document.forms[0].workspaceFolder;
     var objID = getTopWindow().getWindowOpener().document.forms[0].workspaceFolderId;
     objForm.value = "<%=XSSUtil.encodeForJavaScript(context, names.toString())%>";
     objID.value = "<%=XSSUtil.encodeForJavaScript(context, ids.toString())%>";
     getTopWindow().closeWindow();

 <% } else if(fromPage.equals("routeTemplateWizard")){%>

     var objForm = getTopWindow().getWindowOpener().document.forms[0].WorkspaceAvailable;
     var objID = getTopWindow().getWindowOpener().document.forms[0].WorkspaceId;
     objForm.value = "<%=XSSUtil.encodeForJavaScript(context, names.toString())%>";
     objID.value = "<%=XSSUtil.encodeForJavaScript(context, ids.toString())%>";
     getTopWindow().closeWindow();

<% }  else { %>

     var objForm = getTopWindow().getWindowOpener().document.forms[0].txtWSFolder;
     var objID = getTopWindow().getWindowOpener().document.forms[0].folderId;
     objForm.value = "<%=XSSUtil.encodeForJavaScript(context, names.toString())%>";
     objID.value = "<%=XSSUtil.encodeForJavaScript(context, ids.toString())%>";
     getTopWindow().closeWindow();

<% } %>

</script>



