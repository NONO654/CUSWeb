<%--
   Copyright (c) 1992-2015 Dassault Systemes.
   All Rights Reserved.
--%>
<%@page import="com.matrixone.apps.framework.tree.Tree"%>
<%@include file = "../common/emxNavigatorNoDocTypeInclude.inc"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<jsp:useBean id="shortcutInfo" class="com.matrixone.apps.framework.ui.UIShortcut" scope="session" />
<%@page import = "matrix.db.JPO"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.library.LibraryCentralConstants"%>
<!DOCTYPE html>

<body>
<%
   String emxSuiteDirectory = emxGetParameter(request,"emxSuiteDirectory");
   String suiteKey = emxGetParameter(request, "suiteKey");
   String parentOID = emxGetParameter(request, "parentOID");
   String objectId = emxGetParameter(request, "objectId");
   String mode =  emxGetParameter(request, "mode");
   
   String command = "print bus $1 select $2 dump";
   String revision = MqlUtil.mqlCommand(context, command, objectId, "revision");
   
   DomainObject domainObject = new DomainObject(objectId);
   StringBuffer relList = new StringBuffer();
   relList.append("Data Vaults");
   relList.append(",").append("Sub Vaults");
   MapList folderParentDetails = new MapList();
   String parentType = null;
   ContextUtil.pushContext(context);
   try
   {
       StringList typeSelects = new StringList(1);
       typeSelects.add(DomainObject.SELECT_ID);
       folderParentDetails = domainObject.getRelatedObjects(context,
                                       relList.toString(),
                                       "*",
                                       typeSelects,
                                       new StringList(),
                                       true,
                                       false,
                                       (short) 1,
                                       null,
                                       null);
       int size = folderParentDetails.size();
       for(int i = 0; i < size; i++){
    	   Map folderParent = (Map)folderParentDetails.get(i);
    	   parentType = (String)folderParent.get("type");
       }
   }catch (Exception e){
       throw new FrameworkException(e);
   }
   ContextUtil.pushContext(context);
   
   StringBuffer appendParams = new StringBuffer();
   appendParams.append("mode=");
   appendParams.append(mode);
   appendParams.append("&relId=&parentOID=");
   appendParams.append(parentOID);
   appendParams.append("&objectId=");
   appendParams.append(objectId);
   appendParams.append("&jsTreeID=");
   
   if(revision != null && !("".equals(revision))){
	   if(parentType != null && !("".equals(parentType))){
		   if(parentType.equalsIgnoreCase("Workspace")){
			   appendParams.append("&emxSuiteDirectory=teamcentral");
			   appendParams.append("&suiteKey=TeamCentral");		   
		   } else if(parentType.equalsIgnoreCase("Workspace Vault")){
			   appendParams.append("&emxSuiteDirectory=teamcentral");
			   appendParams.append("&suiteKey=TeamCentral");		   
		   } else if(parentType.equalsIgnoreCase("Project Space")){
			   appendParams.append("&emxSuiteDirectory=programcentral");
			   appendParams.append("&suiteKey=ProgramCentral");		   
		   } else {
		       appendParams.append("&emxSuiteDirectory=");
		       appendParams.append(emxSuiteDirectory);
		       appendParams.append("&suiteKey=");
		       appendParams.append(suiteKey);		   
		   }		   
	   } else {
		   appendParams.append("&emxSuiteDirectory=");
		   appendParams.append(emxSuiteDirectory);
		   appendParams.append("&suiteKey=");
		   appendParams.append(suiteKey);		   
	   }
   } else {
	   appendParams.append("&emxSuiteDirectory=");
	   appendParams.append(emxSuiteDirectory);
	   appendParams.append("&suiteKey=");
	   appendParams.append(suiteKey);
   }
   String strForwardURL = "../common/emxTree.jsp?"+appendParams.toString();
   response.sendRedirect(strForwardURL);
%>
</body>
</html>
