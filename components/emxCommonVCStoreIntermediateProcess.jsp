<%--
  emxCommonVCStoreIntermediateProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCommonVCStoreIntermediateProcess.jsp.rca $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>

<%@page import = "com.matrixone.apps.common.VCDocument"%>
<%@page import = "com.matrixone.apps.common.CommonDocument"%>
<%@page import = "com.matrixone.apps.framework.ui.UIUtil"%>

<html>
<body>
<form name="VCStore" method="post" action="../common/emxIndentedTable.jsp">

<%
    String storeName = emxGetParameter(request, "storeName");

     // IR-113617V6R2012x  --
     if (UIUtil.isNullOrEmpty(storeName)) {
       %>
         <script language="javascript">
            // here top == self
            getTopWindow().window.resizeTo(emxUIConstants.ARR_PopupWidth['Small'],
                            emxUIConstants.ARR_PopupHeight['Small'] / 2);
            var eMsg = "<emxUtil:i18nScript localize="i18nId">emxComponents.CommonDocument.NoStoreGiven</emxUtil:i18nScript>";
            var theForm = getTopWindow().document.forms["VCStore"];
            if (theForm == null)
                theForm = getTopWindow().document.forms[0];
            theForm.action = "javascript:getTopWindow().closeWindow()";
            theForm.method = "POST";
            getTopWindow().document.writeln("<p>&nbsp;</p>");
            getTopWindow().document.writeln("<p align='center'><span class='pageHeader'>");
            getTopWindow().document.writeln(eMsg);
            getTopWindow().document.writeln("</span></p><br/>");
            getTopWindow().document.writeln("<p align='center'>");
            getTopWindow().document.writeln("<input type='submit' value='<emxUtil:i18n localize="i18nId">emxComponents.Button.Close</emxUtil:i18n>'/>");
            getTopWindow().document.writeln("</p>");
            getTopWindow().document.writeln("</form></body></html>");
         </script>
       <%
       return;
    }
    // --

    String storePath = MqlUtil.mqlCommand(context, "print store '" + storeName + "' select path dump;" );
    String objectId = "";
    String objectIdModule = "";
    String sSuiteKey = "Components";
    String jsTreeID = emxGetParameter(request,"jsTreeID");
    String objectAction = emxGetParameter(request,"objectAction");
    String strForm = emxGetParameter(request, "formName");
    String customMode = emxGetParameter(request, "customMode");
    String dsfaTag = emxGetParameter(request, "dsfaTag");
    String strSubmitURL = emxGetParameter(request,"submitURL");
    String strAllowedTypes = emxGetParameter(request,"allowedTypes");
    if (strAllowedTypes == null)
        strAllowedTypes = "";

    if (UIUtil.isNullOrEmpty(strSubmitURL)) {
        strSubmitURL = "../components/emxCommonVCStoreSelectionProcess.jsp";
    }

    DomainObject dObj = null;
    DomainObject dObjModule = null;
    BusinessObject bObj = null;
    BusinessObject bObjModule = null;
    String dsfaHolderType = PropertyUtil.getSchemaProperty(context, "type_mxsysDSFAHolder");
    String dsfaHolderPolicy = PropertyUtil.getSchemaProperty(context, "policy_mxsysDSFAHolder");

    // for the root or empty path process both, otherwise go by the path type
    if (storePath.equals("/") || storePath.equals("")) {
        objectId = processFolders(context,bObj,dObj,dsfaHolderType,dsfaHolderPolicy,storeName,objectId);
        objectIdModule = processModules(context,bObjModule,dObjModule,dsfaHolderType,dsfaHolderPolicy,storeName,objectIdModule);
    } else if (storePath.matches("^/?Modules(/.*)?")) {
        objectIdModule = processModules(context,bObjModule,dObjModule,dsfaHolderType,dsfaHolderPolicy,storeName,objectIdModule);
    } else {
        objectId = processFolders(context,bObj,dObj,dsfaHolderType,dsfaHolderPolicy,storeName,objectId);
    }

    String url = null;
    %>
      <input type="hidden" name="formName" value="<xss:encodeForHTMLAttribute><%=strForm%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="expandProgram" value="emxVCDocumentUI:getVCAllContents"/>
      <input type="hidden" name="table" value="APPVCFolderContentsSummary"/>
      <input type="hidden" name="header" value="emxComponents.Heading.Select"/>
      <input type="hidden" name="sortColumnName" value="Name"/>
      <input type="hidden" name="sortDirection" value="ascending"/>
      <input type="hidden" name="PrinterFriendly" value="false"/>
      <input type="hidden" name="export" value="false"/>
      <input type="hidden" name="selection" value="single"/>
      <input type="hidden" name="objectBased" value="false"/>
      <input type="hidden" name="objectId" value="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="objectIdModule" value="<xss:encodeForHTMLAttribute><%=objectIdModule%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=sSuiteKey%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="jsTreeID" value="<xss:encodeForHTMLAttribute><%=jsTreeID%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="storeName" value="<xss:encodeForHTMLAttribute><%=storeName%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="storePath" value="<xss:encodeForHTMLAttribute><%=storePath%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="cancelLabel" value="emxComponents.Button.Cancel"/>
      <input type="hidden" name="submitLabel" value="emxComponents.Button.Submit"/>
      <input type="hidden" name="submitURL" value="<xss:encodeForHTMLAttribute><%=strSubmitURL%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="Style" value="dialog"/>
      <input type="hidden" name="fromPage" value="FolderContentsAll"/>
      <input type="hidden" name="objectAction" value="<xss:encodeForHTMLAttribute><%=objectAction%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="helpMarker" value="emxhelpdsfaselect"/>
      <input type="hidden" name="customMode" value="<xss:encodeForHTMLAttribute><%=customMode%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="dsfaTag" value="<xss:encodeForHTMLAttribute><%=dsfaTag%></xss:encodeForHTMLAttribute>"/>
      <input type="hidden" name="allowedTypes" value="<xss:encodeForHTMLAttribute><%=strAllowedTypes%></xss:encodeForHTMLAttribute>"/>
      <!-- Bug 340039 -->
      <input type="hidden" name="editRootNode" value="false"/>
      <!-- Bug 368781 -->
      <input type="hidden" name="showClipboard" value="false"/>
    <%

    if ( objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
         objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
         objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC) ||
         objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
         objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER))
    {
      %>
        <input type="hidden" name="fromPage" value="FolderContentsAll"/>
      <%
    } else {
      %>
        <input type="hidden" name="fromPage" value="FolderContentsFoldersOnly"/>
      <%
    }
 %>


<%!
public String processModules(Context context, BusinessObject bObjModule,DomainObject dObjModule,String dsfaHolderType,String dsfaHolderPolicy,String storeName,String objectIdModule )throws Exception
{
  try{
    bObjModule=new BusinessObject(dsfaHolderType, storeName, "Modules", context.getVault().getName());

    if (!bObjModule.exists(context)) {
        String vcDocument = CommonDocument.INTERFACE_VC_DOCUMENT;
        dObjModule = DomainObject.newInstance(context);
        dObjModule.createObject(context, dsfaHolderType, storeName, "Modules", dsfaHolderPolicy, context.getVault().getName());
        StringBuffer cmd = new StringBuffer(128);
        cmd.append("connect bus \"");
        cmd.append(dObjModule.getObjectId());
        cmd.append("\" vcmodule \" ");
        cmd.append("\" selector Trunk:Latest complete store \"");
        cmd.append(storeName);
        cmd.append("\" format generic");
        MqlUtil.mqlCommand(context, cmd.toString() );
        cmd = new StringBuffer(250);
        cmd.append("modify bus '");
        cmd.append(dObjModule.getObjectId());
        cmd.append("' add interface '");
        cmd.append(vcDocument);
        cmd.append("';");
        MqlUtil.mqlCommand(context, cmd.toString() );
        objectIdModule=dObjModule.getInfo(context,"id");
    } else {
        bObjModule.open(context);
        bObjModule.close(context);
        dObjModule = DomainObject.newInstance(context, bObjModule);
        objectIdModule=dObjModule.getInfo(context,"id");
    }
  } catch(Exception e) {}
  return objectIdModule;
}

public String processFolders(Context context, BusinessObject bObj,DomainObject dObj,String dsfaHolderType,String dsfaHolderPolicy,String storeName,String objectId)throws Exception
{
  try {
    bObj = new BusinessObject(dsfaHolderType, storeName, "-", context.getVault().getName());

    if (!bObj.exists(context)) {
        String vcDocument = CommonDocument.INTERFACE_VC_DOCUMENT;
        dObj = DomainObject.newInstance(context);
        dObj.createObject(context, dsfaHolderType, storeName, "-", dsfaHolderPolicy, context.getVault().getName());
        StringBuffer cmd = new StringBuffer(128);
        cmd.append("connect bus \"");
        cmd.append(dObj.getObjectId());
        cmd.append("\" vcfolder \"");
        cmd.append("\" config Trunk:Latest complete store \"");
        cmd.append(storeName);
        cmd.append("\" format generic");
        MqlUtil.mqlCommand(context, cmd.toString() );
        cmd = new StringBuffer(250);
        cmd.append("modify bus '");
        cmd.append(dObj.getObjectId());
        cmd.append("' add interface '");
        cmd.append(vcDocument);
        cmd.append("';");
        MqlUtil.mqlCommand(context, cmd.toString() );
        objectId = dObj.getInfo(context,"id");
    } else {
        bObj.open(context);
        bObj.close(context);
        dObj = DomainObject.newInstance(context, bObj);
        objectId = dObj.getInfo(context,"id");
    }
  } catch(Exception e){}

  return objectId;
}

%>

<script language="javascript" type="text/javascript">
  document.VCStore.submit();
</script>

</form>
</body>
</html>


