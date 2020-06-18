<%--  emxProgramCentralFolderSearchFiles.jsp  - This page displays choices for searching Persons

  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program.

--%>

<%@include file="emxProgramGlobals2.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../emxUICommonAppInclude.inc"%>

<head>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<script language="javascript" type="text/javascript"
	src="../common/scripts/emxUICalendar.js"></script>
</head>


<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%><html>
<head>
<title></title>
</head>
<body class="white">
<!-- content begins here -->
<%
            com.matrixone.apps.program.Task task = (com.matrixone.apps.program.Task) DomainObject
                    .newInstance(context, DomainConstants.TYPE_TASK,
                            DomainConstants.PROGRAM);
            com.matrixone.apps.common.WorkspaceVault workspaceVault = (com.matrixone.apps.common.WorkspaceVault) DomainObject
                    .newInstance(context, DomainConstants.TYPE_WORKSPACE_VAULT);

            String expandType = EnoviaResourceBundle.getProperty(context, "eServiceProgramCentral.IndentedTable.GeneralTypes");
            String expandRel  = EnoviaResourceBundle.getProperty(context, "eServiceProgramCentral.IndentedTable.GeneralRelationships");
            String direction  = EnoviaResourceBundle.getProperty(context, "eServiceProgramCentral.IndentedTable.GeneralDirection");

            String strUnmanagedFiles = emxGetParameter(request, "UnmanagedFiles");
            String myParentId = "";
            String symbolicType = "";

            // Must set content relstionship to correct value
            workspaceVault
                    .setContentRelationshipType(workspaceVault.RELATIONSHIP_VAULTED_OBJECTS_REV2);
            // used to find policies

            StringList allDocTypes = new StringList();
            StringList docTypes = new StringList();

            if ((strUnmanagedFiles == null) && (allDocTypes.isEmpty())) {
                allDocTypes = workspaceVault.getContentBusinessTypes(context,
                        true);
                docTypes = workspaceVault.getContentBusinessTypes(context,
                        false);
            } else {
                if ((strUnmanagedFiles != null) && (allDocTypes.isEmpty())) {

                    StringList docTypes2 = workspaceVault
                            .getContentBusinessTypes(context, false);
                    docTypes = task.getDeliverablesBusinessTypes(context);
                    Iterator docListItr = docTypes2.iterator();
                    while (docListItr.hasNext()) {
                        String documentType = (String) docListItr.next();
                        if (!docTypes.contains(documentType)) {
                            docTypes.add(documentType);
                        }
                    }
                    docTypes.sort();
                }
            }
            String docTypesStr = "";

            StringBuffer arrTypeArrayContent = new StringBuffer();
            StringList levelPattern = new StringList();
            Iterator documentListItr = docTypes.iterator();

            //Check for VPLM Tasks to remove unwanted types
            String vplmTask = PropertyUtil
                    .getSchemaProperty(
                            context,
                            com.matrixone.apps.domain.DomainSymbolicConstants.SYMBOLIC_type_VPLMTask);
            boolean isVPLMTask = false;

            if (myParentId != null && !"".equals(myParentId)) {
                DomainObject domnObj = new DomainObject(myParentId);
                String parentOjectType = domnObj.getInfo(context,
                        task.SELECT_TYPE);
                if (parentOjectType.equals(vplmTask))
                    isVPLMTask = true;
            }

            String excludeTypeList = "";
            if (isVPLMTask)
                excludeTypeList = EnoviaResourceBundle.getProperty(context, "emxProgramCentral.VPLMMapping.DeliverableExcludeTypes");
            excludeTypeList += ",";

            while (documentListItr.hasNext()) {
                String documentType = (String) documentListItr.next();
                BusinessType baseType = new BusinessType(documentType, context
                        .getVault());
                baseType.open(context);
                String sParentType = baseType.getParent(context);
                baseType.close(context);
                if (sParentType == null || "".equals(sParentType)
                        || !docTypes.contains(sParentType)) {
                    // **Start**
                    if (ProjectSpace.isEPMInstalled(context)) {
                        if (!(documentType
                                .equals(DomainConstants.TYPE_IC_DOCUMENT) || documentType
                                .equals(DomainConstants.TYPE_IC_FOLDER))) {
                            arrTypeArrayContent.append(FrameworkUtil
                                    .getAliasForAdmin(context, "type",
                                            documentType, true));
                            levelPattern.add(FrameworkUtil
                                    .getAliasForAdmin(context, "type",
                                            documentType, true));
                            docTypesStr += documentType;
                        }
                        if (documentListItr.hasNext()) {
                            if (!(documentType
                                    .equals(DomainConstants.TYPE_IC_DOCUMENT) || documentType
                                    .equals(DomainConstants.TYPE_IC_FOLDER))) {
                                docTypesStr += ",";
                            }
                        }
                    }
                    // **End**
                    else {
                        String appendSymbolicType = FrameworkUtil
                                .getAliasForAdmin(context, "type",
                                        documentType, true);
                        String checkSymbolicType = appendSymbolicType;
                        // arrTypeArrayContent.append(FrameworkUtil.getAliasForAdmin(context,
                        // "type", documentType, true));
                        if (!isVPLMTask
                                || excludeTypeList.indexOf(appendSymbolicType) < 0) {
                            arrTypeArrayContent.append(checkSymbolicType);
                            levelPattern.add(checkSymbolicType);

                            docTypesStr += documentType;
                            if (documentListItr.hasNext()) {
                                docTypesStr += ",";
                            }
                        }
                    }
                }
            }
            symbolicType = arrTypeArrayContent.toString();
            String strSymbolic = "";
            strSymbolic = com.matrixone.apps.domain.util.FrameworkUtil.join(levelPattern,",");
%>
	<form name = "FilesSearch" method = "post" action = "../common/emxFullSearch.jsp?formInclusionList=PRG_FOLDER_NAME,PRG_FOLDER_PROJECTSPACE_NAME" target="_parent">
      <%@include file = "../common/enoviaCSRFTokenInjection.inc"%>	
		<input type="hidden" name="relationship" value="<xss:encodeForHTMLAttribute><%=expandRel%></xss:encodeForHTMLAttribute>" />
	    <input type="hidden" name="type" value="<xss:encodeForHTMLAttribute><%=expandType%></xss:encodeForHTMLAttribute>" />
	    <input type="hidden" name="direction" value="<xss:encodeForHTMLAttribute><%=direction%></xss:encodeForHTMLAttribute>" />
	    <input type="hidden" name="table" value="PMCGeneralSearchResults " />
		<input type="hidden" name="field" value="<xss:encodeForHTMLAttribute>TYPES=<%=strSymbolic%></xss:encodeForHTMLAttribute>" />
   	    <input type="hidden" name="cancelLabel" value="emxFramework.Common.Close" />
	</form>
</body>
<script language="javascript" type="text/javaScript">
		document.FilesSearch.submit();
</script>

</html>
