<%--
  emxCommonDocumentVCIntermediateProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCommonDocumentVCIntermediateProcess.jsp.rca $
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "../common/emxUIConstantsInclude.inc"%>
<%@include file = "emxComponentsCommonInclude.inc"%>

<%
    String languageStr = request.getHeader("Accept-Language");
    String objectId  = emxGetParameter(request, "objectId");
    String fromPage  = emxGetParameter(request, "fromPage");
    String sSuiteKey = XSSUtil.encodeForURL(context, emxGetParameter(request, "suiteKey"));
    String jsTreeID  = emxGetParameter(request, "jsTreeID");
    String parentId  = emxGetParameter(request, "parentOID");

    if (parentId == null || parentId.isEmpty()) {
        parentId = emxGetParameter(request, "parentId");
    }
    if (parentId == null || parentId.isEmpty()) {
        parentId = emxGetParameter(request, "folderId");
    }

    DomainObject doc = new DomainObject(objectId);
    StringList strList = new StringList();
    strList.add("vcfile.checkinstatus");
    strList.add("vcfolder.checkinstatus");
    strList.add("vcmodule.checkinstatus");
    Map infoMap = doc.getInfo(context,strList);
    String vcfileCheckinStatus = (String) infoMap.get("vcfile[1].checkinstatus");
    String vcfolderCheckinStatus = (String) infoMap.get("vcfolder[1].checkinstatus");
    String vcmoduleCheckinStatus = (String) infoMap.get("vcmodule[1].checkinstatus");

    //
    // If there are any checkin status failures display error message and return
    //
    if ("FAILED".equalsIgnoreCase(vcfileCheckinStatus) || "FAILED".equalsIgnoreCase(vcfolderCheckinStatus) || "FAILED".equalsIgnoreCase(vcmoduleCheckinStatus)) {
        String strProperties = i18nNow.getI18nString("emxComponents.Common.Properties","emxComponentsStringResource",languageStr);
        %>
          <script language="javascript">
              var contentFrameObj = findFrame(getTopWindow(), "content");
              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.CheckinStatusAlert</emxUtil:i18nScript>");
              var tree = getTopWindow().objStructureTree;
              //Find the node of the context object in the details tree thru the Object ID
              var objNode = tree.findNodeByObjectID("<%=XSSUtil.encodeForJavaScript(context, objectId)%>");
              var propObjNode = tree.findContextObjectNodeByName(objNode.nodeID, "<%=strProperties%>");
              if (propObjNode) {
                  objNode = propObjNode;
              }
              tree.setSelectedNode(objNode,true);
              //Set the node to the context node.
              document.location.href = tree.getSelectedNode().getURL();
          </script>
        <%
        return;
    }


    //
    // there are no status errors, follow the normal process
    //
    String url = "";
    if ("VCFileVersions".equals(fromPage)) {
        url = "../common/emxTable.jsp?program=emxVCDocumentUI:getVCFileVersions&table=APPVCFileVersionsSummary&header=emxComponents.Common.DocumentVersionsPageHeading&HelpMarker=emxhelpsdfaversionsummarypage&FilterFramePage=../components/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1&objectId="+XSSUtil.encodeForURL(context, objectId)+"&suiteKey="+XSSUtil.encodeForURL(context, sSuiteKey)+"&fromPage="+XSSUtil.encodeForURL(context, fromPage) + "&jsTreeID=" + XSSUtil.encodeForURL(context, jsTreeID);
    } else if ("VCFolderContents".equals(fromPage)) {
        // Fix for the Bug 333590
        DomainObject doNewObj = new DomainObject(objectId);
        String strType = doNewObj.getInfo(context,DomainConstants.SELECT_TYPE);
        String typeProducts = PropertyUtil.getSchemaProperty(context, DomainSymbolicConstants.SYMBOLIC_type_Products);
        if (parentId == null) {
            if (strType.equals(DomainConstants.TYPE_CAD_DRAWING)
                || strType.equals(DomainConstants.TYPE_CAD_MODEL)
                || strType.equals(DomainConstants.TYPE_DRAWINGPRINT)
                || strType.equals("Part Specification")
                || strType.equals(DomainConstants.TYPE_SKETCH))
            {
                String strParentId = doNewObj.getInfo(context,"relationship[Part Specification].from.id");
                parentId = strParentId;
            }
        }
        // End Fix for the Bug 333590

        //LQA: Actually IDC
        boolean addMenu = true;
        if (doNewObj.isKindOf(context, typeProducts)) {
            addMenu = false;
        }
        url = "../common/emxIndentedTable.jsp?expandProgram=emxVCDocumentUI:getVCFolderContents&table=APPVCFolderContentsSummary&";
        if (addMenu) {
            url += "toolbar=APPVCFolderContentToolBar&";
        }
        url += "header=emxComponents.VersionControl.FolderContents&sortColumnName=Name&sortDirection=ascending&PrinterFriendly=true&fromPage=FolderContentsFirst&selection=single&objectBased=false&FilterFramePage=../components/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1&appendparameters=true&objectId="+XSSUtil.encodeForURL(context, objectId)+"&suiteKey="+XSSUtil.encodeForURL(context, sSuiteKey)+"&jsTreeID="+XSSUtil.encodeForURL(context, jsTreeID)+"&parentOID="+XSSUtil.encodeForURL(context, parentId)+"&HelpMarker=emxhelpdsfaviewfoldercontent&editRootNode=false";
        //LQA: end. Note command above modified.
    } else if ("VCFolderConfigurations".equals(fromPage)){
        url = "../common/emxTable.jsp?program=emxVCDocumentUI:getVCFolderConfigurations&table=APPVCFolderConfigurationsSummary&header=emxComponents.VersionControl.DocumentConfigurationsPageHeading&HelpMarker=emxhelpdsfaviewfolderconfiguration&objectId="+XSSUtil.encodeForURL(context, objectId)+"&suiteKey="+XSSUtil.encodeForURL(context, sSuiteKey)+"&fromPage="+XSSUtil.encodeForURL(context, fromPage) + "&jsTreeID=" + XSSUtil.encodeForURL(context, jsTreeID);
    } else if ("VCModuleContents".equals(fromPage)) {
        //LQA: Actually IDC
        DomainObject doNewObj = new DomainObject(objectId);
        String strType = doNewObj.getInfo(context,DomainConstants.SELECT_TYPE);
        String typeProducts = PropertyUtil.getSchemaProperty(context, DomainSymbolicConstants.SYMBOLIC_type_Products);
        boolean addMenu = true;
        if (doNewObj.isKindOf(context, typeProducts)) {
            addMenu = false;
        }
        url = "../common/emxIndentedTable.jsp?expandProgram=emxVCDocumentUI:getVCModuleContents&table=APPVCModuleContentsSummary&";
        if (addMenu) {
            url += "toolbar=APPVCFolderContentToolBar&";
        }
        url += "header=emxComponents.VersionControl.ModuleContents&sortColumnName=Name&sortDirection=ascending&PrinterFriendly=true&fromPage=VCModuleContents&selection=single&objectBased=false&FilterFramePage=../components/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1&appendparameters=true&objectId="+XSSUtil.encodeForURL(context, objectId)+"&suiteKey="+XSSUtil.encodeForURL(context, sSuiteKey)+"&jsTreeID="+XSSUtil.encodeForURL(context, jsTreeID)+"&parentOID="+XSSUtil.encodeForURL(context, parentId)+"&HelpMarker=emxhelpdsfaviewmodulecontent&editRootNode=false&showClipboard=false&customize=false";
        //LQA end. Note command above modified.
    }

    url += "&categoryTreeName="+XSSUtil.encodeForURL(context, emxGetParameter(request, "categoryTreeName"));

    %>
      <script language="javascript" type="text/javascript">
      //XSSOK
          document.location.href="<%=url%>";
      </script>
    <%

%>


