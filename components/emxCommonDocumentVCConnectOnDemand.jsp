<%--  emxComponentsCheckinProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentVCConnectOnDemand.jsp.rca 1.19.2.5 Wed Oct 22 16:18:34 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "emxComponentsSetCompanyKeyInRPE.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<%
  Document document = (Document)DomainObject.newInstance(context, DomainConstants.TYPE_DOCUMENT);
    String fromPage = emxGetParameter(request, "fromPage");
    String strFormName = emxGetParameter(request, "formName");
    String calledPage = emxGetParameter(request, "calledPage");
    String strFieldNameActual  = emxGetParameter(request, "fieldNameActual");
    String strFieldNameDisplay  = emxGetParameter(request, "fieldNameDisplay");
    String suiteKey  = emxGetParameter(request, "suiteKey");
    String parentId =emxGetParameter(request, "parentId");
    String relName = emxGetParameter(request,"srcDestRelName");
    String selector=emxGetParameter(request,"selector");

   Map emxCommonDocumentCheckinData = new HashMap();
   String folderPath = "";
   String fileName = "";
   String level = "";
   String fileOrFolder = "";
   String objectId  ="";
    Enumeration enumParam1 = request.getParameterNames();
    while (enumParam1.hasMoreElements())
    {
        String name  = (String) enumParam1.nextElement();
        String value = emxGetParameter(request, name);
       if(name.equalsIgnoreCase("emxTableRowId")){
            StringTokenizer strtk = new StringTokenizer(value,"|");
            String tokenString = strtk.nextToken();
            StringTokenizer strtk1 = new StringTokenizer(tokenString,"$");
            fileOrFolder = strtk1.nextToken();
            strtk1.nextToken();
            if ( "module".equalsIgnoreCase(fileOrFolder)|| "version".equalsIgnoreCase(fileOrFolder)){
                strtk1.nextToken();
                folderPath = strtk1.nextToken();
                selector=strtk1.nextToken();
                objectId = strtk1.nextToken();               
                
            }
            if ( "folder".equalsIgnoreCase(fileOrFolder)|| "file".equalsIgnoreCase(fileOrFolder)){
            folderPath = strtk1.nextToken();
            if( "file".equalsIgnoreCase(fileOrFolder)){
                fileName = strtk1.nextToken();
            }
           objectId = strtk1.nextToken();
         }
       }    
       else{
        emxCommonDocumentCheckinData.put(name, value);
       }
    }
    String objectAction ="";
    //objectId   = (String)emxCommonDocumentCheckinData.get("objectId");
    String appProcessPage = (String)emxCommonDocumentCheckinData.get("appProcessPage");
    String appDir         = (String)emxCommonDocumentCheckinData.get("appDir");
    String jpoName = (String)emxCommonDocumentCheckinData.get("JPOName");
    String methodName = (String)emxCommonDocumentCheckinData.get("methodName");

    Map objectMap = new HashMap();
    document.setId(objectId);
    SelectList selectList = new SelectList();
    selectList.add("type");
    selectList.add("policy");
    selectList.add("vault");
    selectList.add("id");
    selectList.add("format");
    if ( "folder".equalsIgnoreCase(fileOrFolder)|| "file".equalsIgnoreCase(fileOrFolder)){
        selectList.add("vcfolder");
        selectList.add("vcfolder.store");
   	    selectList.add("vcfolder.path");
        selectList.add("vcfile.specifier");
        selectList.add("vcfolder.config");
        selectList.add("vcfolder.comment");
    }
    if ( "module".equalsIgnoreCase(fileOrFolder)|| "version".equalsIgnoreCase(fileOrFolder)){
        
        selectList.add("vcmodule.store");               
    }
    
    Map mapDocumentInfo = document.getInfo(context,selectList);
    String server = "";
    String path = "";
    String documentType = (String)mapDocumentInfo.get("type");
    String documentPolicy = (String)mapDocumentInfo.get("policy");
    String format = (String)mapDocumentInfo.get("format");
    String vault = (String)mapDocumentInfo.get("vault");

    if("None".equalsIgnoreCase(folderPath)){
      folderPath = "";
     }
    
    if ( "folder".equalsIgnoreCase(fileOrFolder)|| "file".equalsIgnoreCase(fileOrFolder)){
        
    server = (String)mapDocumentInfo.get("vcfolder[1].store");
    path = (String)mapDocumentInfo.get("vcfolder[1].path");
    if( "file".equalsIgnoreCase(fileOrFolder)){
          path += "/" + folderPath + "/" + fileName;
          path = path.replace('\\','/');

          if(selector == null || selector.trim().equals(""))
          {
            selector="Trunk:Latest";
          }
     }
     else if( "folder".equalsIgnoreCase(fileOrFolder) )
      {
          path += "/" + folderPath;
          fileName = VCDocument.processSyncUrlData(context, path);
          path = path.replace('\\','/');
          if(selector == null || selector.trim().equals(""))
          {
            selector="Trunk:Latest";
          }
      }
    	path = VCDocument.processSyncUrlData(context, path);
    	selector = VCDocument.processSelector(context, selector);
    }
    
    if ( "module".equalsIgnoreCase(fileOrFolder)|| "version".equalsIgnoreCase(fileOrFolder)){
        server = (String)mapDocumentInfo.get("vcmodule[1].store");
        //path = (String)mapDocumentInfo.get("vcmodule[1].vcpath");
        path=folderPath;
        fileName = path;
        if(selector.equals("null") || selector.trim().equals(""))
        {
          selector="DSFA:Latest";
        }
    }
      if ((server != null) && !("".equals(server)) && !("null".equals(server)))
      {
        String symbolicName = FrameworkUtil.getAliasForAdmin(context, "store", server.trim(), true);
        emxCommonDocumentCheckinData.put("store", symbolicName);
      }

      

      emxCommonDocumentCheckinData.put("path", path);
      emxCommonDocumentCheckinData.put("selector", selector);
      emxCommonDocumentCheckinData.put("server", server);
      emxCommonDocumentCheckinData.put("vcDocumentType", fileOrFolder);

      emxCommonDocumentCheckinData.put("format", "generic");
      String symbolicDocumentType = "";
      if( documentType != null)
      {
        symbolicDocumentType = FrameworkUtil.getAliasForAdmin(context, "type", PropertyUtil.getSchemaProperty(context,documentType), true);
      }
      else
      {
        symbolicDocumentType = FrameworkUtil.getAliasForAdmin(context, "type", PropertyUtil.getSchemaProperty(context, "type_DOCUMENTS"), true);
      }
     if( documentPolicy == null || "null".equals(documentPolicy) || "".equals(documentPolicy) )
     {
      try
      {
        documentPolicy = EnoviaResourceBundle.getProperty(context,"emxComponents.DefaultPolicy." + symbolicDocumentType);
        if( documentPolicy != null && !"".equals(documentPolicy.trim()))
        {
          documentPolicy = PropertyUtil.getSchemaProperty(context, documentPolicy);
        }
        else
        {
          documentPolicy = null;
        }
      }
      catch (Exception e)
      {
        documentPolicy = null;
      }
     }
  MapList documentPolicies         = mxType.getPolicies( context, documentType, false);
  Map defaultDocumentPolicyMap     = null;
  Map documentPolicyMap            = new HashMap();
  String defaultDocumentPolicyName = null;
  StringList documentPolicyNames   = new StringList();
  Iterator documentPolicyItr       = null;
  String policyName = null;
  String documentRevision = null;
  if ( documentPolicies != null && !documentPolicies.isEmpty())
  {
      documentPolicyItr = documentPolicies.iterator();
      while( documentPolicyItr.hasNext())
      {
        documentPolicyMap = (Map)documentPolicyItr.next();
        policyName        = (String)documentPolicyMap.get("name");

           documentPolicyNames.add(policyName);
        if(documentPolicy == null)
        {
          defaultDocumentPolicyMap = (Map) documentPolicies.get(0);
        }
        else if (policyName.equals(documentPolicy))
        {
          defaultDocumentPolicyMap = documentPolicyMap;
        }
      }

      if(defaultDocumentPolicyMap == null)
      {
        defaultDocumentPolicyMap = (Map) documentPolicies.get(0);
      }

      defaultDocumentPolicyName = (String)defaultDocumentPolicyMap.get("name");

      documentRevision = (String)defaultDocumentPolicyMap.get("revision");
  }
      if("FolderContentsFirst".equalsIgnoreCase(fromPage)){
           emxCommonDocumentCheckinData.put("type",documentType);
      emxCommonDocumentCheckinData.put("policy", documentPolicy);
      }
      else{
           emxCommonDocumentCheckinData.put("type",DomainConstants.TYPE_DOCUMENT);
           emxCommonDocumentCheckinData.put("policy", DomainConstants.POLICY_DOCUMENT);
      }
      emxCommonDocumentCheckinData.put("name", "");
      emxCommonDocumentCheckinData.put("revision", documentRevision);
      emxCommonDocumentCheckinData.put("description", "");
      emxCommonDocumentCheckinData.put("title",fileName);
      emxCommonDocumentCheckinData.put("accessType", "");
      emxCommonDocumentCheckinData.put("vault", vault);
      emxCommonDocumentCheckinData.put("objectId",objectId);
      emxCommonDocumentCheckinData.put("parentId",emxGetParameter(request, "parentId"));
      // put the document attribute values into formBean
      // since JPO expects the attributes in a map, stuff the formBean with attribute map
      // get the list of Attribute names
      MapList attributeMapList = mxType.getAttributes( context, documentType);

      Iterator i = attributeMapList.iterator();
      String attributeName = null;
      String attrValue = "";
      String attrType = "";
      double tz = Double.parseDouble((String) session.getAttribute ( "timeZone" ));
      Map attributeMap = new HashMap();
      while(i.hasNext())
      {
          Map attrMap = (Map)i.next();
          attributeName = (String)attrMap.get("name");
          attrValue = (String) emxCommonDocumentCheckinData.get(attributeName);
          attrType = (String)attrMap.get("type");
          if ( attrValue != null && !"".equals(attrValue) && !"null".equals(attrValue) )
          {
              if("timestamp".equals(attrType))
              {
                 attrValue = eMatrixDateFormat.getFormattedInputDate(context, attrValue, tz,request.getLocale());
              }
              attributeMap.put( attributeName, attrValue);
          }
      }
      String accessType = (String)emxCommonDocumentCheckinData.get("AccessType");
      String accessAttrStr = PropertyUtil.getSchemaProperty(context, "attribute_AccessType");
      if ( accessType != null && !"".equals(accessType) && !"null".equals(accessType))
      {
          attributeMap.put( accessAttrStr, accessType);
      }

      // stuff the formBean with attribute map
      emxCommonDocumentCheckinData.put( "attributeMap", attributeMap);
try{
      request.setAttribute("requestMap", emxCommonDocumentCheckinData);

      String[] args = JPO.packArgs(emxCommonDocumentCheckinData);

      if ( "".equals(objectId) || "null".equals(objectId) )
      {
        objectId = null;
      }
      if (jpoName == null || "".equals(jpoName) || "null".equals(jpoName) )
      {
        jpoName = "emxVCDocument";
      }
      if (methodName == null || "".equals(methodName) || "null".equals(methodName) )
      {
        methodName = "vcDocumentConnectCheckin";
      }
	  FrameworkUtil.validateMethodBeforeInvoke(context, jpoName, methodName, "Program");
      objectMap = (Map)JPO.invoke(context, jpoName, null, methodName, args, Map.class);
      request.setAttribute("objectMap", objectMap);
      request.setAttribute("requestMap", emxCommonDocumentCheckinData);
      if( objectMap != null )
      {
        session.setAttribute("error.message", objectMap.get("errorMessage"));
      }
  } catch (Exception ex) {
      String errMessage = ex.getMessage();
      ex.printStackTrace();
      session.putValue("error.message", errMessage);
  }
%>
    <script language="Javascript">
<%
    if(fromPage.equals("searchVCDocuments")){
      String createdId = (String)objectMap.get("objectId");
    if (strFormName != null && strFieldNameDisplay != null && strFieldNameActual != null){

      DomainObject object = new DomainObject(createdId);
      object.open(context);
      String objectName = object.getName();
      object.close(context);
%>
    txtTypeDisplay = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameDisplay)%>;
    txtTypeActual = getTopWindow().getWindowOpener().document.<%=XSSUtil.encodeForJavaScript(context, strFormName)%>.<%=XSSUtil.encodeForJavaScript(context, strFieldNameActual)%>;
    txtTypeDisplay.value = "<%=XSSUtil.encodeForJavaScript(context,objectName)%>";
    txtTypeActual.value = "<%=XSSUtil.encodeForJavaScript(context,createdId)%>";
	getTopWindow().closeWindow();
<%}
   else{

      DomainObject createdObject = new DomainObject(createdId);
      createdObject.open(context);
      DomainObject parentobject = new DomainObject(parentId);
      parentobject.open(context);
      relName        = PropertyUtil.getSchemaProperty(context, relName);
      DomainRelationship.connect(context, new DomainObject(parentobject), relName,  new DomainObject(createdObject));
      createdObject.close(context);
      parentobject.close(context);

%>
	getTopWindow().closeWindow();
<%
  }
}else if("createIssue".equalsIgnoreCase(calledPage)){
      String createdId = (String)objectMap.get("objectId");
%>
 showModalDialog("../components/emxCommonFS.jsp?functionality=IssueCreateFSInstanceOnDemand&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>&objectId=<%=XSSUtil.encodeForURL(context, createdId)%>","620","570");
 getTopWindow().closeWindow();
 getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
 
<%
}
else{
    
%>
 var detailsFrameObj = findFrame(parent.parent,"detailsDisplay");
 if(detailsFrameObj != null){
  detailsFrameObj.document.location.href = detailsFrameObj.document.location.href ;
 }
  getTopWindow().closeWindow();   
  getTopWindow().getWindowOpener().getTopWindow().refreshTablePage();
 
<% }%>
</script>
