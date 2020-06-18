<%-- emxCommonDocumentVCOnDemandIntermediateProcess.jsp --

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxCommonDocumentVCOnDemandIntermediateProcess.jsp.rca 1.26.2.5.2.1 Tue Dec 23 05:51:28 2008 ds-hkarthikeyan Experimental $
--%>

<%@ include file="../emxUICommonAppInclude.inc" %>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "emxComponentsUtil.inc"%>
<html>
<head>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
</head>

<body>

<%
    boolean check = false;
    String languageStr = request.getHeader("Accept-Language");
    String objectId = emxGetParameter(request, "objectId");
//Bug  Fix 333590 and 333588
    String defaultType = "";
  if(objectId!=null)
  {
  DomainObject object2 = new DomainObject (objectId);

  defaultType   = FrameworkUtil.getAliasForAdmin( context,
                                                               "type", object2.getType(context), true);
  }
 //End
    String fromPage = emxGetParameter(request, "fromPage");
    String calledPage = emxGetParameter(request, "calledPage");
    String relName = emxGetParameter(request,"srcDestRelName");

    String objectAction = emxGetParameter(request,"objectAction");
    String parentId = emxGetParameter(request,"parentOID");
    String parentRelName = "";
  //Bug  Fix 333590 and 333588
  String includeTypes = FrameworkUtil.getAliasForAdmin(context, "type", PropertyUtil.getSchemaProperty(context, "type_DOCUMENTS"), true);
    //End
    if(parentId == null && "".equals(parentId))
    {
        parentId = emxGetParameter(request,"parentId");
    }
    if(parentId == null || "".equals(parentId))
    {
      parentId = emxGetParameter(request,"folderId");
    }

  if(fromPage != null && "Navigate".equalsIgnoreCase(fromPage)){
    Map emxCommonDocumentNavigateData = (Map) session.getAttribute("emxCommonDocumentNavigateData");
     if(emxCommonDocumentNavigateData != null){
         parentId = (String) emxCommonDocumentNavigateData.get("parentOID");
         parentRelName = "relationship_VaultedDocuments";
    //Bug  Fix 333590 and 333588
    defaultType = "type_Document";
    //End
         check = true;
     }
    }

    if(parentId != null && !"".equals(parentId) && !check)
    {
      if(parentId != objectId)
      {
        DomainObject object = new DomainObject (parentId);
        StringList objectSelects11 = new StringList();
        objectSelects11.add(DomainConstants.SELECT_ID);
        MapList list11 = object.getRelatedObjects(context,"*","*",objectSelects11,null,true,true,(short)1,"id == "+objectId,null);
        if (list11.size() > 0)
        {
          Map assigneeMap = (Map)list11.get(0);
          parentRelName = FrameworkUtil.getAliasForAdmin(context, "relationship",(String) assigneeMap.get("relationship"),true);
        }
      }
    }


    String emxTableRowId = emxGetParameter(request,"emxTableRowId");
    String formName = emxGetParameter(request,"formName");
    String fieldNameActual = emxGetParameter(request,"fieldNameActual");
    String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
    String suiteKey = emxGetParameter(request,"suiteKey");
    String associateId = "";
    String title = "";
    String selector ="Trunk:Latest";
    String tokenString = "";
   if(emxTableRowId != null && !emxTableRowId.equals("")){
        StringTokenizer strtk1 = new StringTokenizer(emxTableRowId,"|");
        tokenString = strtk1.nextToken();
    if(emxTableRowId.indexOf("$") != -1){

    StringTokenizer strtk = new StringTokenizer(tokenString,"$");
    String fileorFolder = strtk.nextToken();
    strtk.nextToken();
    String folderPath = strtk.nextToken();
    String path = "";
    String filePath = "";
    String versionId = "";
    String server = "";
    
    
    if ( fileorFolder.equalsIgnoreCase("file") || fileorFolder.equalsIgnoreCase("folder")){   
        
    if( "file".equalsIgnoreCase(fileorFolder)){
        
        filePath = strtk.nextToken();
        objectId = strtk.nextToken();
        versionId = strtk.nextToken();
        selector = versionId;
		associateId = strtk.nextToken();
    }
    
    	if( "folder".equalsIgnoreCase(fileorFolder)){
        
			objectId = strtk.nextToken(); 
			strtk.nextToken();
            associateId = strtk.nextToken();
        
    }
    
   // String server = "";
    SelectList selectList = new SelectList();
    selectList.add("vcfolder.store");
    selectList.add("vcfolder.path");

    DomainObject object = new DomainObject(objectId);
    //object.setId();
    Map mapDocumentInfo = object.getInfo(context,selectList);
    server = (String)mapDocumentInfo.get("vcfolder[1].store");
    path = (String)mapDocumentInfo.get("vcfolder[1].path");
    if("None".equalsIgnoreCase(folderPath)){
      folderPath = "";
     }


    if(fileorFolder.equalsIgnoreCase("file")){
        if(path == null) {
            path = "";
    }

      path += "/" + folderPath + "/" + filePath;
      title = filePath;

    StringTokenizer newstrtk1 = new StringTokenizer(versionId,".");
    int nooftokens = newstrtk1.countTokens();
      if(versionId.equalsIgnoreCase("Blank") || (nooftokens%2) !=0)
      {%>
      <script language="javascript" type="text/javascript">

        alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.TrunkBranchActions</emxUtil:i18nScript>");

      </script>
      <% return;
      }

    }
    else {
      path += "/" + folderPath;
      title = path;
    }
    path = VCDocument.processSyncUrlData(context, path);
    selector = VCDocument.processSelector(context, selector);

    }
    else{
        StringTokenizer strtkModule = new StringTokenizer(tokenString,"$");
        String moduleName="";
        String modPath="";
        String modConfig="";
        String modRelPath="";
        
        strtkModule.nextToken();
        strtkModule.nextToken();        
        moduleName = strtkModule.nextToken();
        modPath=strtkModule.nextToken();
        modConfig=strtkModule.nextToken();
        objectId=strtkModule.nextToken();
        modRelPath=strtkModule.nextToken();
        associateId="None";
        
        String strPath = "";
  	    String strBranch = "";
  	    String strVersion = "";
        
        if(fileorFolder.equalsIgnoreCase("module")){
            selector = "DSFA:Latest";
        }
        
        else if(fileorFolder.equalsIgnoreCase("version")){
            strPath = modRelPath.substring(0,modRelPath.lastIndexOf("/"));
  	      	strVersion = modRelPath.substring(modRelPath.lastIndexOf("/")+1,modRelPath.length());
  	      	strBranch = strPath.substring(strPath.lastIndexOf("/")+1,strPath.length());
  	      	selector = strVersion;
            }
        
        
        SelectList selectListModule = new SelectList();
        selectListModule.add("vcmodule[1].store");
        selectListModule.add("vcmodule[1].path");
        
        DomainObject object3 = new DomainObject(objectId);
        
        Map mapDocumentInfoModule = object3.getInfo(context,selectListModule);
        server = (String)mapDocumentInfoModule.get("vcmodule[1].store");
        //path = (String)mapDocumentInfoModule.get("vcmodule[1].path");
        path=modPath;
        if(path.equals(" ")){
              path=".";
         	}
    }
    String url = "";

    // Collect all the parameters passed-in and forward them to Tree Display frame.
    String appendParams = "";

    if (request.getQueryString() != null)
        appendParams = request.getQueryString();

    boolean checking = true;
    
    if(fileorFolder.equalsIgnoreCase("category")){
        checking = false;
        
        %>
           <script language="javascript" type="text/javascript">
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.CategoryNotAllowed</emxUtil:i18nScript>");
           </script>
        <% }
            
            
    else  if(fileorFolder.equalsIgnoreCase("branch")){
        checking = false;
        %>
           <script language="javascript" type="text/javascript">
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.OperationNotAllowed</emxUtil:i18nScript>");
           </script>
        <% }
            
            
    else  if(fileorFolder.equalsIgnoreCase("href")){
        checking = false;
        %>
           <script language="javascript" type="text/javascript">
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.HrefNotAllowed</emxUtil:i18nScript>");
           </script>
        <% }
    
    else  if(fileorFolder.equalsIgnoreCase("unresolved")){
        checking = false;
        %>
           <script language="javascript" type="text/javascript">
                alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.UnresolvedNotAllowed</emxUtil:i18nScript>");
           </script>
        <% }
    
    String showDialog =EnoviaResourceBundle.getProperty(context,"emxComponents.DSFAConnect.ShowDialog");
    
     if(showDialog != null && "true".equalsIgnoreCase(showDialog) && associateId.equalsIgnoreCase("None") && !"createVCFileFolderOnDemand".equals(objectAction)
             && !fileorFolder.equalsIgnoreCase("category") && fileorFolder.equalsIgnoreCase("branch") && fileorFolder.equalsIgnoreCase("href") && fileorFolder.equalsIgnoreCase("unresolved") ){

        if("connectVCFileFolderOnDemand".equals(objectAction)){     
            
           url ="./emxCommonDocumentPreCheckin.jsp?stepOneHeader=emxComponents.Header.ConnectToDesignSyncFileFolder&showName=false&showTitle=false&showOwner=false&showPolicy=false&actionURL=emxCommonDocumentVCConnectProcess.jsp&"+appendParams+"&parentId="+parentId+"&selector="+selector+"&path="+path+"&server="+server+"&vcDocumentType="+fileorFolder+"&objectAction="+objectAction+"&parentRelName="+parentRelName+"&fromPage="+fromPage+"&title="+title+"&defaultType="+defaultType+"&includeTypes="+includeTypes;
           
        }
        else if((VCDocument.OBJECT_ACTION_CONNECT_VC_FROM_ISSUE_SEARCH).equals(objectAction)){                      
          
           url ="./emxCommonDocumentPreCheckin.jsp?stepOneHeader=emxComponents.Header.ConnectToDesignSyncFileFolder&showName=false&showTitle=false&showOwner=false&showPolicy=false&actionURL=emxCommonDocumentVCConnectProcess.jsp&"+appendParams+"&parentId="+parentId+"&selector="+selector+"&path="+path+"&server="+server+"&vcDocumentType="+fileorFolder+"&objectAction="+objectAction+"&title="+title+"&formName="+formName+"&parentId="+parentId+"&RelName="+relName;
           
        }

 if(checking){
%>
<script language="javascript" type="text/javascript">
   var win = emxShowModalDialog("<%=XSSUtil.encodeForJavaScript(context, url)%>",780,570);
 // document.location.href="<%=url%>";
</script>

<% }
    }
    else if(associateId != null && !associateId.equalsIgnoreCase("None"))
    {

       if("createIssue".equalsIgnoreCase(calledPage)){
%>
        <script language="javascript" type="text/javascript">
           showModalDialog("../components/emxCommonFS.jsp?functionality=IssueCreateFSInstanceOnDemand&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>&objectId=<%=XSSUtil.encodeForURL(context, associateId)%>","620","570");
        </script>
<%  }
         else if("searchVCDocuments".equalsIgnoreCase(fromPage)){
     if (formName != null && fieldNameDisplay != null && fieldNameActual!= null){
          DomainObject object1 = new DomainObject(associateId);
      object1.open(context);
          String objectName1 = object1.getName();
      object1.close(context);
%>
        <script language="javascript" type="text/javascript">
        txtTypeDisplay = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,formName)%>.<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>; //XSSOK: used to get field
        txtTypeActual = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,formName)%>.<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>;  //XSSOK: used to get field
        txtTypeDisplay.value = "<%=objectName1%>";
        txtTypeActual.value = "<%=XSSUtil.encodeForJavaScript(context,associateId)%>";
        getTopWindow().closeWindow();
        </script>

<%
}
else {
   relName        = PropertyUtil.getSchemaProperty(context, relName);
      DomainObject object12 = new DomainObject(associateId);
      object12.open(context);
      DomainObject parentobject = new DomainObject(parentId);
      parentobject.open(context);
      DomainRelationship RDORel =DomainRelationship.connect(context,parentobject, relName,object12);
      parentobject.close(context);
      object12.close(context);
%>
    <script language="javascript" type="text/javascript">
	getTopWindow().closeWindow();
    </script>
    <%
}
}
      else if("createVCFileFolderOnDemand".equals(objectAction)) {
             if(fileorFolder.equalsIgnoreCase("file")){
                 checking = false;
         %>
            <script language="javascript" type="text/javascript">
                 alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.CreateOnDemandAlert</emxUtil:i18nScript>");
            </script>
         <% }
     else {
          url ="./emxCommonDocumentPreCheckin.jsp?showName=false&showTitle=false&showOwner=false&showPolicy=false&"+appendParams+"&parentId="+parentId+"&selector="+selector+"&path="+path+"&server="+server+"&JPOName=emxVCDocument&methodName=checkinUpdate&vcDocumentType="+fileorFolder+"&parentRelName="+parentRelName+"&fromPage="+fromPage+"&title="+title+"&defaultType="+defaultType+"&includeTypes="+includeTypes;
 %>
        <script language="javascript" type="text/javascript">
           var win = emxShowModalDialog("<%=XSSUtil.encodeForJavaScript(context, url)%>",780,570);
         // document.location.href="<%=url%>";
        </script>

        <%
            }
        }
     else {
 %>
        <script language="javascript" type="text/javascript">
          alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.AlreadyAssociatedAlert</emxUtil:i18nScript>");
        </script>
<%    }
    }
    else{
      if(!fileorFolder.equalsIgnoreCase("category") && !fileorFolder.equalsIgnoreCase("branch") && !fileorFolder.equalsIgnoreCase("href") && !fileorFolder.equalsIgnoreCase("unresolved") ){
        
          if("createVCFileFolderOnDemand".equals(objectAction)){
             if(fileorFolder.equalsIgnoreCase("file")){
%>
            <script language="javascript" type="text/javascript">
                 alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.CreateOnDemandAlert</emxUtil:i18nScript>");
            </script>
         <% }
             
            
                     
            else{
          url ="./emxCommonDocumentPreCheckin.jsp?showName=false&showTitle=false&showOwner=false&showPolicy=false&"+appendParams+"&parentId="+parentId+"&selector="+selector+"&path="+path+"&server="+server+"&JPOName=emxVCDocument&methodName=checkinUpdate&vcDocumentType="+fileorFolder+"&parentRelName="+parentRelName+"&fromPage="+fromPage+"&title="+title+"&defaultType="+defaultType+"&includeTypes="+includeTypes;

          %>
        <script language="javascript" type="text/javascript">
           var win = emxShowModalDialog("<%=XSSUtil.encodeForJavaScript(context, url)%>",780,570);
         // document.location.href="<%=url%>";
        </script>
        <%
            }
        }
        else{
%>
    <form name="VCForm" action="../components/emxCommonDocumentVCConnectOnDemand.jsp">
    <input type="hidden" name="emxTableRowId" value="<xss:encodeForHTMLAttribute><%=emxTableRowId%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="objectAction" value="<xss:encodeForHTMLAttribute><%=objectAction%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="selector" value="<xss:encodeForHTMLAttribute><%=selector%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="parentId" value="<%=XSSUtil.encodeForHTMLAttribute(context, parentId)%>"/>
    <input type="hidden" name="fromPage" value="<xss:encodeForHTMLAttribute><%=fromPage%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="formName" value="<xss:encodeForHTMLAttribute><%=formName%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="calledPage" value="<xss:encodeForHTMLAttribute><%=calledPage%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="fieldNameActual" value="<xss:encodeForHTMLAttribute><%=fieldNameActual%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="fieldNameDisplay" value="<xss:encodeForHTMLAttribute><%=fieldNameDisplay%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="suiteKey" value="<xss:encodeForHTMLAttribute><%=suiteKey%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="parentRelName" value="<xss:encodeForHTMLAttribute><%=parentRelName%></xss:encodeForHTMLAttribute>"/>
    <input type="hidden" name="srcDestRelName" value="<xss:encodeForHTMLAttribute><%=relName%></xss:encodeForHTMLAttribute>"/>
    </form>
    <script language="javascript" type="text/javascript">
      document.VCForm.submit();
    </script>
<%   }
    }
   }    
  }
 else if(fromPage.equals("searchVCDocuments")){

if (formName != null && fieldNameDisplay != null && fieldNameActual!= null) {

           DomainObject object = new DomainObject(tokenString);
      object.open(context);
      String objectName = object.getName();
      object.close(context);
%>
<script language="javascript" type="text/javascript">
    txtTypeDisplay = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,formName)%>.<%=XSSUtil.encodeForJavaScript(context,fieldNameDisplay)%>; //XSSOK: used to get field
    txtTypeActual = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context,formName)%>.<%=XSSUtil.encodeForJavaScript(context,fieldNameActual)%>; //XSSOK: used to get field
    txtTypeDisplay.value = "<%=objectName%>";
    txtTypeActual.value = "<%=XSSUtil.encodeForJavaScript(context, tokenString)%>";
    getTopWindow().closeWindow();

</script>
  <%
}
else {
    DomainObject object = new DomainObject(tokenString);
      object.open(context);
      DomainObject parentobject = new DomainObject(parentId);
      parentobject.open(context);
     relName        = PropertyUtil.getSchemaProperty(context, relName);
  try{
    DomainRelationship RDORel =DomainRelationship.connect(context,parentobject, relName,object);
  // DomainRelationship.connect(context,parentId,relName,tokenString,false);
  }catch (Exception e){
    e.printStackTrace();
  }

%>
  <script language="javascript" type="text/javascript">
  parent.window.getWindowOpener().parent.location.href =parent.window.getWindowOpener().parent.location.href;
  getTopWindow().closeWindow();
  </script>

<%
    }
 }
//modified for the bug 334216
   else if(calledPage !=null && calledPage.equals("createIssue") && emxTableRowId != null && emxTableRowId.indexOf("$") != -1){
%>
<script language="javascript" type="text/javascript">
showModalDialog("../components/emxCommonFS.jsp?functionality=IssueCreateFSInstanceOnDemand&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>&objectId=<%=XSSUtil.encodeForURL(context, tokenString)%>","620","570");
</script>
<% }
//added for the bug 334216
else
{%>
<script language="javascript" type="text/javascript">
  alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.RootActions</emxUtil:i18nScript>");

</script>
<% }
//end of the bug 334216
 } // eof if emxTableRowId
else if("searchVCDocuments".equalsIgnoreCase(fromPage))
     {%>
<script language="javascript" type="text/javascript">
    alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.NoFileFolderSelected</emxUtil:i18nScript>");

</script>
   <%  }

%>
</body>
</html>
