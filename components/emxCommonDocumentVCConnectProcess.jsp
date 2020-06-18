<%--  emxComponentsCheckinProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentVCConnectProcess.jsp.rca 1.5.2.13.2.5 Wed Oct 22 16:18:53 2008 przemek Experimental przemek $"
--%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@include file = "emxComponentsSetCompanyKeyInRPE.inc"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>

<%  
  String objectAction = "";
  String objectId   = "";
  String appProcessPage = "";
  String appDir         = "";
  Map objectMap = new HashMap();
  Map emxCommonDocumentCheckinData = null;
  try
  {
      //save type ahead values
      String typeAheadFormName = emxGetParameter(request, "typeAheadFormName");
      String tagDisplayValue = emxGetParameter(request, "path");
%>
      <emxUtil:saveTypeAheadValues
        context="<%= context %>"
        form="<%= typeAheadFormName %>"
        field="path"
        displayFieldValue="<%= XSSUtil.encodeForXML(context, tagDisplayValue) %>"
        />
<%
      tagDisplayValue = emxGetParameter(request, "selector");
%>
      <emxUtil:saveTypeAheadValues
        context="<%= context %>"
        form="<%= typeAheadFormName %>"
        field="selector"
        displayFieldValue="<%= XSSUtil.encodeForHTML(context, tagDisplayValue) %>"
        />
      <emxUtil:commitTypeAheadValues context="<%= context %>" />
<%     
  
      emxCommonDocumentCheckinData = (Map) session.getAttribute("emxCommonDocumentCheckinData");
      session.removeAttribute("emxCommonDocumentCheckinData");
      Enumeration enumParam = request.getParameterNames();

      // Loop through the request elements and
      // stuff into emxCommonDocumentCheckinData
      while (enumParam.hasMoreElements())
      {
          String name  = (String) enumParam.nextElement();
          String value = request.getParameter(name);
          if(name.equals("selector") && (value == null || value.trim().equals("")))
          {
            value="Trunk:Latest";
          }
          emxCommonDocumentCheckinData.put(name, value);
      }

      objectAction = (String)emxCommonDocumentCheckinData.get("objectAction");
      objectId   = (String)emxCommonDocumentCheckinData.get("objectId");
      appProcessPage = (String)emxCommonDocumentCheckinData.get("appProcessPage");
      appDir         = (String)emxCommonDocumentCheckinData.get("appDir");
      String jpoName = (String)emxCommonDocumentCheckinData.get("JPOName");
      String methodName = (String)emxCommonDocumentCheckinData.get("methodName");
    String path = (String)emxCommonDocumentCheckinData.get("path");
      String documentType = (String) emxCommonDocumentCheckinData.get("realType");
      emxCommonDocumentCheckinData.put("type", documentType);

      if(documentType == null)
      {
          documentType = CommonDocument.TYPE_DOCUMENT;
      }

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
      objectId = (String)objectMap.get("objectId");
      String title = (String)emxCommonDocumentCheckinData.get("title");
      String vcDocumentType = (String)emxCommonDocumentCheckinData.get("vcDocumentType");
    if(objectId != null && !"".equals(objectId))
     {
        DomainObject object = new DomainObject(objectId);
        SelectList sList = new SelectList(3);
        sList.add("vcfile[1].vcname");
        sList.add("vcfolder[1].path");
        sList.add("vcmodule[1].path");
        Map objMap = object.getInfo(context,sList);
        if(title == null || "".equals(title)){
            if("File".equalsIgnoreCase(vcDocumentType)){
              String vcfile = (String) objMap.get("vcfile[1].vcname");
              if(vcfile != null && !"".equals(vcfile))
                  object.setAttributeValue( context, CommonDocument.ATTRIBUTE_TITLE, vcfile);
              else
                  object.setAttributeValue( context, CommonDocument.ATTRIBUTE_TITLE, object.getName());

            }
            else if("Folder".equalsIgnoreCase(vcDocumentType)){
              String vcfolder = (String) objMap.get("vcfolder[1].path");
              if(vcfolder != null && !"".equals(vcfolder))
                 object.setAttributeValue( context, CommonDocument.ATTRIBUTE_TITLE, vcfolder);
              else
                  object.setAttributeValue( context, CommonDocument.ATTRIBUTE_TITLE, object.getName());
            }
            
            else if("Module".equalsIgnoreCase(vcDocumentType) || "Version".equalsIgnoreCase(vcDocumentType)){
                String vcmodule = (String) objMap.get("vcmodule[1].path");
                if(vcmodule != null && !"".equals(vcmodule))
                   object.setAttributeValue( context, CommonDocument.ATTRIBUTE_TITLE, vcmodule);
                else
                    object.setAttributeValue( context, CommonDocument.ATTRIBUTE_TITLE, object.getName());
              }
          }
      }
      if( objectMap != null )
      {
        session.setAttribute("error.message", objectMap.get("errorMessage"));
      }
  } catch (Exception ex) {
      String errMessage = ex.getMessage();
      ex.printStackTrace();
      session.putValue("error.message", errMessage);
  }
   String newURL = UINavigatorUtil.getCommonDirectory(context) + "/emxTree.jsp?objectId=" + XSSUtil.encodeForURL(context, objectId);
    newURL +="&emxSuiteDirectory="+XSSUtil.encodeForURL(context, appDirectory);
  if ( appProcessPage != null && !"".equals(appProcessPage) && !"null".equals(appProcessPage) )
  {
      appProcessPage = "../" + appDir + "/" + appProcessPage;
      context.shutdown();
%>
      <jsp:forward page="<%=XSSUtil.encodeForHTML(context, appProcessPage)%>" >
        <jsp:param name ="objectId" value  ="<xss:encodeForHTMLAttribute><%=objectId%></xss:encodeForHTMLAttribute>" />
        <jsp:param name ="fromPage" value  ="multi" />
      </jsp:forward>
<%
  }
  else
  {
      // The function javascript findFrame is added to the page since IE not recognizing js include
      // with document.write which is needed in Applet version of file upload
%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
<script language="javascript" type="text/javascript">
    var tree          = getTopWindow().getWindowOpener().getTopWindow().objStructureTree;
    var frameContent1 = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"content");

    function findFrame(objWindow, strName)
    {
      if (strName == "_top") {
        return getTopWindow();
      } else if (strName == "_self") {
        return self;
      } else if (strName == "_parent") {
        return parent;
      } else {
        var objFrame = null;

        for (var i = 0; i < objWindow.frames.length && !objFrame; i++)
        {
          if (objWindow.frames[i].name == strName) {
            objFrame = objWindow.frames[i];
          }
        }
        if (!objFrame) {
          for (var i=0; i < objWindow.frames.length && !objFrame; i++) {
            objFrame = findFrame(objWindow.frames[i], strName);
          }
        }
        return objFrame;
      }
    }
<%
    if (objectAction.indexOf("create") != -1)
    {
%>
      if(getTopWindow().getWindowOpener().getTopWindow().modalDialog)
      {
          getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
      }
<%
    }
%>
      var frameContent;
      if(getTopWindow().getWindowOpener()) {
        frameContent = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"detailsDisplay");
      } else {
        frameContent = findFrame(getTopWindow(),"detailsDisplay");
      }
      var checking = true;
      if ( frameContent != null )
      {
<%
        if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER) || 
	      objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC)){
%>
         if(tree){
           var SelectedNodeParent =tree.getSelectedNode().parent.parent;
           if((SelectedNodeParent != null )&&(SelectedNodeParent != 'undefined'))
           {
             tempNodeID = SelectedNodeParent.nodeID;
           tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, objectId)%>",false);
           frameContent1.addStructureNode("<%=XSSUtil.encodeForJavaScript(context, objectId)%>","",tempNodeID,"<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>");
        }
           else{
        	   //XSSOK
             frameContent1.document.location.href="<%=newURL%>";
         checking = false;
           }
        }
<% 
   }
%>  
<%
    if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_ON_DEMAND)){
      String calledPage = "";
      String fromPage = "";

      if(emxCommonDocumentCheckinData.get("calledPage") != null) 
      {
        calledPage = (String)emxCommonDocumentCheckinData.get("calledPage");
      }
      if(emxCommonDocumentCheckinData.get("fromPage") != null) 
      {
        fromPage = (String)emxCommonDocumentCheckinData.get("fromPage");
      }
      String createdId = (String)objectMap.get("objectId");
      if(calledPage.equalsIgnoreCase("createIssue")){
%>
    checking = false;
    showModalDialog("../components/emxCommonFS.jsp?functionality=IssueCreateFSInstanceOnDemand&suiteKey=Components&objectId=<%=XSSUtil.encodeForURL(context, createdId)%>","576","756");
         <%
             if(fromPage.equalsIgnoreCase("Navigate"))
          {
            %>
                getTopWindow().getWindowOpener().getTopWindow().document.location.href =  "../components/emxCommonDocumentVCNavigateProcess.jsp";
            <%
          }
          else
          {
              %>
                  setTimeout("getTopWindow().getWindowOpener().focus()", 50000);
                  window.getWindowOpener().parent.location.href = window.getWindowOpener().parent.location.href;
              <%
          }
    }
else if (fromPage.equalsIgnoreCase("Navigate"))
{

%>
    checking = false;

getTopWindow().getWindowOpener().getTopWindow().document.location.href =  "../components/emxCommonDocumentVCNavigateProcess.jsp";
<% } 
   }
%>

    if(checking){
          frameContent.document.location.href = frameContent.document.location.href;
        }
      } else {
<%
        if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER) || 
	      objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC)){
%>
         if(tree){
           var SelectedNodeParent =tree.getSelectedNode().parent.parent;
           if((SelectedNodeParent != null )&&(SelectedNodeParent != 'undefined'))
           {
             tempNodeID = SelectedNodeParent.nodeID;
           tree.deleteObject("<%=XSSUtil.encodeForJavaScript(context, objectId)%>",false);
           frameContent1.addStructureNode("<%=XSSUtil.encodeForJavaScript(context, objectId)%>","",tempNodeID,"<%=XSSUtil.encodeForJavaScript(context, appDirectory)%>");
        }
           else{
          checking= false;
          //XSSOK
              frameContent1.document.location.href="<%=newURL%>";
           }
        }
<% 
   }
%>
<%
    if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FROM_ISSUE_SEARCH)){
      String createdId = (String)objectMap.get("objectId");
	  String formName =(String)emxCommonDocumentCheckinData.get("formName");
	  if(formName !=null) {
      DomainObject object = new DomainObject(createdId);
      object.open(context);
      String objectName = object.getName();
      object.close(context);
%>
     checking = false;
    txtTypeDisplay = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().document.IssueCreate.txtIssueAffectedItem;
    txtTypeActual = getTopWindow().getWindowOpener().getTopWindow().getWindowOpener().document.IssueCreate.txtActualAffectedItem;
    txtTypeDisplay.value = "<%=XSSUtil.encodeForJavaScript(context, objectName)%>";
    txtTypeActual.value = "<%=XSSUtil.encodeForJavaScript(context, createdId)%>";
    getTopWindow().getWindowOpener().getTopWindow().closeWindow();
<% 
   }else{
         String parentId =(String)emxCommonDocumentCheckinData.get("parentId");
	     String relName =(String)emxCommonDocumentCheckinData.get("RelName");
		 relName        = PropertyUtil.getSchemaProperty(context, "relationship_Issue");
         DomainObject object12 = new DomainObject(createdId);
         object12.open(context);
         DomainObject parentobject = new DomainObject(parentId);
         parentobject.open(context);
          DomainRelationship RDORel =DomainRelationship.connect(context,parentobject, relName,object12);
          parentobject.close(context);
          object12.close(context);
         %>
             getTopWindow().getWindowOpener().getTopWindow().closeWindow();
             checking = false;
<%
}//else
}//if
%>
<%
    if(objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_ON_DEMAND)){
      String calledPage = "";
      String fromPage = "";

      if(emxCommonDocumentCheckinData.get("calledPage") != null) 
      {
        calledPage = (String)emxCommonDocumentCheckinData.get("calledPage");
      }
      if(emxCommonDocumentCheckinData.get("fromPage") != null) 
      {
        fromPage = (String)emxCommonDocumentCheckinData.get("fromPage");
      }

      String createdId = (String)objectMap.get("objectId");
      if(calledPage.equalsIgnoreCase("createIssue")){
%>
        checking = false;
       showModalDialog("../components/emxCommonFS.jsp?functionality=IssueCreateFSInstanceOnDemand&suiteKey=Components&objectId=<%=XSSUtil.encodeForURL(context, createdId)%>","620","570");
       <%
             if(fromPage.equalsIgnoreCase("Navigate"))
          {
            %>
                getTopWindow().getWindowOpener().getTopWindow().document.location.href =  "../components/emxCommonDocumentVCNavigateProcess.jsp";
            <%
          }
          else
          {
              %>
                  setTimeout("getTopWindow().getWindowOpener().focus()", 50000);
                  window.getWindowOpener().parent.location.href = window.getWindowOpener().parent.location.href;
              <%
          }

    } //eof if called pahge
    else if ("Navigate".equalsIgnoreCase(fromPage)){
%>
      checking = false;
      getTopWindow().getWindowOpener().getTopWindow().document.location.href =  "../components/emxCommonDocumentVCNavigateProcess.jsp";
<%   } // eof else if
   } //eof If 
%>
         if(checking){
          getTopWindow().getWindowOpener().getTopWindow().document.location.href = getTopWindow().getWindowOpener().getTopWindow().document.location.href;
      }
      }
      getTopWindow().closeWindow();
    </script>
<%
  }
%>
