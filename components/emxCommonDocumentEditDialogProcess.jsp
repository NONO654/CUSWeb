<%--  emxCommonDocumentEditDialogProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentEditDialogProcess.jsp.rca 1.15.2.1 Tue Dec 23 05:44:46 2008 ds-hkarthikeyan Experimental $"
--%>

<%@include file = "emxComponentsDesignTopInclude.inc"%>
<%@include file = "emxComponentsVisiblePageInclude.inc"%>
<%@ include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@ include file = "../common/enoviaCSRFTokenValidation.inc"%>

<%
   boolean errFalg = false;
  String attrDesc = DomainConstants.ATTRIBUTE_DESCRIPTION;
  String sAttrAccessType = DomainConstants.ATTRIBUTE_ACCESS_TYPE;
  String sAttrTitle   = DomainConstants.ATTRIBUTE_TITLE;
  String sAttrReason   = DomainConstants.ATTRIBUTE_CHECKIN_REASON;

  String documentId = emxGetParameter(request,"objectId");
  String versionFlag = emxGetParameter(request,"versionObject");

  // Get DSFA Info
  String newSelector = emxGetParameter(request,"selector");
  if( newSelector ==  null || "".equals(newSelector) || "null".equals(newSelector))
     newSelector = "";

  String newStore = emxGetParameter(request,"server");
  if( newStore ==  null || "".equals(newStore) || "null".equals(newStore) || "None".equalsIgnoreCase(newStore) )
     newStore = "";

  String newPath = emxGetParameter(request,"path");
  if( newPath ==  null || "".equals(newPath) || "null".equals(newPath))
     newPath = "";

  String newFile = emxGetParameter(request,"vcfilename");
  if( newFile ==  null || "".equals(newFile) || "null".equals(newFile))
     newFile = "";

  String strRelTaskDeliverableId = emxGetParameter(request,"relTaskDelId");
    if( strRelTaskDeliverableId ==  null || "".equals(strRelTaskDeliverableId) || "null".equals(strRelTaskDeliverableId))
      strRelTaskDeliverableId = "";

  String strOldCompletionState = emxGetParameter(request,"OldCompleteState");
    if( strOldCompletionState ==  null || "".equals(strOldCompletionState) || "null".equals(strOldCompletionState))
      strOldCompletionState = "";

  String strNewCompletionState = emxGetParameter(request,"state");
    if( strNewCompletionState ==  null || "".equals(strNewCompletionState) || "null".equals(strNewCompletionState))
      strNewCompletionState = "";

  DomainObject domainObject = DomainObject.newInstance(context);
  domainObject.setId(documentId);
  String documentOwner = emxGetParameter(request,"person");
  /*Begin of Add by Raman,Infosys for Bug#300662,3/24/2005*/
  String relId = emxGetParameter(request, "relId");
  String suiteKey      = emxGetParameter(request,"suiteKey");
  /*End of Add by Raman,Infosys for Bug#300662,3/24/2005*/
  StringList stringList = new StringList();
  stringList.add("name");
  stringList.add("type");
  stringList.add("policy");
  stringList.add("current");
  stringList.add("revision");
  stringList.add("vcfile[1].specifier");
  stringList.add("vcfolder[1].config");
  stringList.add("vcfile[1].store");
  stringList.add("vcfolder[1].store");
  stringList.add("vcfile[1].path");
  stringList.add("vcfolder[1].path");
  stringList.add("vcmodule[1].store");
  stringList.add("vcmodule[1].path");
  stringList.add("vcmodule[1].specifier");

  Map infoMap = domainObject.getInfo(context, stringList);
  String documentName = (String)infoMap.get("name");
  String documentType = (String)infoMap.get("type");
  String documentPolicy = (String)infoMap.get("policy");
  String documentState = (String)infoMap.get("current");
  String documentRev = (String)infoMap.get("revision");

  String oldStore = "";
  String oldPath = "";
  String oldFile = "";
  String tmp = "";
  int index = 0;

  boolean isVCFolder = false;
  boolean isVCModule = false;
  boolean isDSFA = false;
  String oldSelector = (String)infoMap.get("vcfile[1].specifier");
  if( oldSelector ==  null || "".equals(oldSelector) || "null".equals(oldSelector))
  {
      oldSelector = (String)infoMap.get("vcfolder[1].config");
      if( oldSelector ==  null || "".equals(oldSelector) || "null".equals(oldSelector))
        oldSelector = "";
      else
         isVCFolder = true;
  }
  else
  {
      isDSFA = true;
  }
  String strmodSelector = (String)infoMap.get("vcmodule[1].specifier");
  
  
  if(strmodSelector == null || "".equals(strmodSelector) || "null".equals(strmodSelector))
  {
  
    strmodSelector = "";
  }
  else
  {
    isVCModule = true;
  
  }
  if (isVCFolder)
  {
      oldStore = (String)infoMap.get("vcfolder[1].store");
      tmp = (String)infoMap.get("vcfolder[1].path");
      index = tmp.lastIndexOf('/');
      oldFile = tmp.substring(index + 1);
      if (index < 0)
      {
         oldPath = "/";
      }
      else{
      oldPath = tmp.substring(0, index);
      }
  }
   if (isVCModule)
  {
      oldStore = (String)infoMap.get("vcmodule[1].store");
      tmp = (String)infoMap.get("vcmodule[1].path");
      index = tmp.lastIndexOf('/');
      oldFile = tmp.substring(index + 1);
      if (index < 0)
      {
         oldPath = "/";
      }
      else{
      oldPath = tmp.substring(0, index);
      }
  }
  else if (isDSFA)
  {
      oldStore = (String)infoMap.get("vcfile[1].store");
      tmp = (String)infoMap.get("vcfile[1].path");
      index = tmp.lastIndexOf('/');
      oldFile = tmp.substring(index + 1);
      if (index < 0)
      {
         oldPath = "/";
      }
      else
      {
          oldPath = tmp.substring(0, index);
      }
  }

  boolean icURLChange = false;
  if ((!newStore.equals(oldStore)) || (!newFile.equals(oldFile)) || (!newPath.equals(oldPath)) || (!newSelector.equals(oldSelector)) || (!newSelector.equals(strmodSelector)))
    icURLChange = true;

  Map attribMap = new HashMap();

  try
  {
    if( "False".equalsIgnoreCase(versionFlag)){

      String passedType = emxGetParameter(request,"realType");
      String passedPolicy = emxGetParameter(request,"policy");
      String passedName = emxGetParameter(request,"txtDocumentName");

      // Modify type and policy of the object if select type or policy are not same as of object
      if(!passedType.equals(documentType) || !passedPolicy.equals(documentPolicy))
      {
          domainObject.change(context, passedType, passedName, documentRev, domainObject.getVault(), passedPolicy);
      }
      else if(!documentName.equals(passedName))
      {
        domainObject.setName(context, passedName);
      }

      // If there is a Task Deliverable rel and the Completion state changed then set it. (EPM)
      if ((!"".equals(strRelTaskDeliverableId)) && (!strNewCompletionState.equals(strOldCompletionState)))
      {
        HashMap attrMap = new HashMap();

        //Set the Reached Completion state to Yes if the Current state equals to Completion State attribute
        if(strNewCompletionState.equals(documentState))
        {
             attrMap.put(DomainConstants.ATTRIBUTE_REACHED_COMPLETION, "Yes");
        }
        attrMap.put(DomainConstants.ATTRIBUTE_COMPLETION_STATE, strNewCompletionState);
        DomainRelationship.setAttributeValues(context, strRelTaskDeliverableId, attrMap);
      }

      String documentTitle = emxGetParameter(request,"txtDocumentTitle");
      String documentDescription = emxGetParameter(request,"txtDocumentdescription");
      String documentAccessType = emxGetParameter(request,"AccessType");

      attribMap.put(sAttrAccessType, documentAccessType);
      attribMap.put(sAttrTitle, documentTitle);

      domainObject.setDescription(context, documentDescription);

    } else {
      String documentReason = emxGetParameter(request,"txtDocumentReason");
      attribMap.put(sAttrReason, documentReason);
    }

    // Only change IC Url if needed.
    StringBuffer DSUrl = new StringBuffer(128);
    if (icURLChange)
    {
        newSelector = VCDocument.processSelector(context, newSelector);

        StringBuffer cmd = new StringBuffer(128);
        cmd.append("modify bus \"");
        cmd.append(documentId);
        cmd.append("\" vcconnection store \"");
        cmd.append(newStore);
        cmd.append("\" path \"");
        cmd.append(newPath);
        cmd.append("/");
        cmd.append(newFile);
        if (isVCFolder || isVCModule)
          cmd.append("\" config \"");
        else
          cmd.append("\" selector \"");
        cmd.append(newSelector);
        cmd.append("\"");

        MqlUtil.mqlCommand(context, cmd.toString());

        // Build IC URL
        StringBuffer storeCmd = new StringBuffer(128);
        if (!"".equals(newStore))
        {
            storeCmd.append("print store '");
            storeCmd.append(newStore);
            storeCmd.append("' select protocol host port path dump |;" );
            String storeData = MqlUtil.mqlCommand(context, storeCmd.toString());

            StringTokenizer storeTok = new StringTokenizer(storeData, "|");
            String protocol = "";
            if (storeTok.hasMoreTokens())
              protocol = storeTok.nextToken(); // protocol
            if (protocol.indexOf("http") == 0)
              protocol = "sync";
            else if (protocol.indexOf("https") == 0)
              protocol = "syncs";

            DSUrl.append(protocol);
            DSUrl.append("://");
           if (storeTok.hasMoreTokens())
             DSUrl.append(storeTok.nextToken());  // host
           else
             DSUrl.append("localhost");  // host
           DSUrl.append(":");
           if (storeTok.hasMoreTokens())
             DSUrl.append(storeTok.nextToken());  // port
          else
             DSUrl.append("2647");  // port
          if (storeTok.hasMoreTokens())
          {
            String tmpPath = storeTok.nextToken();
            tmpPath = VCDocument.processSyncUrlData(context, tmpPath);
            if (tmpPath.indexOf("/") != 0)
              DSUrl.append("/");

            if ((tmpPath.lastIndexOf("/")) == (tmpPath.length() - 1) && (!"/".equals(tmpPath)))
              tmpPath = tmpPath.substring(0, tmpPath.length() - 1);
            else if ("/".equals(tmpPath))
              tmpPath = "";

            DSUrl.append(tmpPath);  // path
          }
        }

        newPath = VCDocument.processSyncUrlData(context, newPath);
        if (newPath.indexOf("/") != 0)
          DSUrl.append("/");
       if(newPath.length() > 0)
       {
        if ((newPath.lastIndexOf("/")) == (newPath.length() - 1) && (!"/".equals(newPath)))
          newPath = newPath.substring(0, newPath.length() - 1);
        else if ("/".equals(newPath))
          newPath = "";
        }
        DSUrl.append(newPath);
        if (newFile.indexOf("/") != 0)
          DSUrl.append("/");

        DSUrl.append(newFile);
    }

    double tz = Double.parseDouble((String) session.getAttribute ( "timeZone" ));
    // put the document attribute values into formBean
    // since JPO expects the attributes in a map, stuff the formBean with attribute map
    // get the list of Attribute names
    MapList attributeMapList = mxType.getAttributes( context, documentType);

    Iterator i = attributeMapList.iterator();
    String attributeName = null;
    String attrValue = "";
    String attrType = "";
    while(i.hasNext())
    {
        Map attrMap = (Map)i.next();
        attributeName = (String)attrMap.get("name");
        attrValue = (String) emxGetParameter(request,attributeName);
        attrType = (String)attrMap.get("type");
        // Fixed Bug#314442 - removed the check for empty string
        if ( attrValue != null && !"null".equals(attrValue) )
        {
            if("timestamp".equals(attrType) && !"".equals(attrValue))
            {
               attrValue = eMatrixDateFormat.getFormattedInputDate(context, attrValue, tz,request.getLocale());
            }
            attribMap.put( attributeName, attrValue);
        }
        if ((attributeName.equals(DomainConstants.ATTRIBUTE_IC_URL)) && (icURLChange))
        {
            attribMap.put( attributeName, DSUrl.toString());
        }
    }

    domainObject.setAttributeValues(context, attribMap);
//Modified for the bug no:344439 
	boolean isLCInstalled = FrameworkUtil.isSuiteRegistered(context,"appVersionLibraryCentral",false,null,null);

   if(isLCInstalled && ("False".equalsIgnoreCase(versionFlag))) {
     HashMap requestMap = UINavigatorUtil.getRequestParameterMap(request);

     HashMap mainMap = new HashMap();
     HashMap paramMap = new HashMap();
     String timeZoneString   = (String)session.getValue("timeZone");
     requestMap.put("timeZone",timeZoneString);


     mainMap.put("requestMap", requestMap);
     mainMap.put("paramMap", paramMap);
     paramMap.put("objectId", documentId);

     String[] args = JPO.packArgs(mainMap);
     String[] constructor = { null };

     JPO.invoke(context, "emxMultipleClassificationAttributeFormHtml",
         constructor, "updateFields", args, void.class);

  }

    /*Begin of Add by Raman,Infosys for Bug#300662,3/24/2005*/
    UIMenu emxMenu = new UIMenu();
    String stMenuName=UITreeUtil.getTreeMenuName(application, session, context, documentId,suiteKey);
    Map objMenuMap = emxMenu.getMenu(context, stMenuName);
    Map menuJSNodeMap = UITreeUtil.getJSNodeMap(application, session, request, context, (HashMap)objMenuMap, documentId, relId);
    String strRootNodeLabel = (String)menuJSNodeMap.get("nodeLabel");
	strRootNodeLabel = FrameworkUtil.findAndReplace(strRootNodeLabel, "\"", "\\\"");
   /*End of Add by Raman,Infosys for Bug#300662,3/24/2005*/
   
    //Fix for 356047, changing the owner (setting owner) at the end, so that other operations on document will not fail.
    //If the owner is changed the current user will not have access to the document and any operations on the document will fail.
    //e.g. changing the attribute (title) and and owner, 
    //if we change the owner first, attribute update action will fail, since the current user (owner) doesn't have access to the document. 
    domainObject.setOwner(context, documentOwner);
%>
  <script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
  <script language="JavaScript" src="../common/scripts/emxUICore.js" type="text/javascript"></script>
  <script language="Javascript">
//IR-010034V6R2010x START : Replaced Code 
        contextTree = getTopWindow().getWindowOpener().getTopWindow().objStructureTree; 
		var objNode = null;		
		if(contextTree != null && contextTree !="undefined"){		
			objNode = contextTree.findNodeByObjectID("<%=XSSUtil.encodeForJavaScript(context, documentId)%>");		
		}		
		// verify that node was found		
		if (objNode != null){		
			objNode.changeObjectName("<%=strRootNodeLabel%>",true); 		
		}		
		//Added for bug 370584		
		else{		
			// look for the pagecontent frame
			var frame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), 'pagecontent');
			if (frame != null){		
				// if found, reload just that frame
				frame.location.href = frame.location.href;
			}else{		
				getTopWindow().getWindowOpener().location.reload();
			}		
		}		
		//end 370584 		
		getTopWindow().closeWindow();
//IR-010034V6R2010x END
</script>
<%

  }
  catch (Exception exp)
  {
    errFalg = true;
    session.setAttribute("error.message", exp.getMessage());
  }
%>
<%@ include file = "../common/emxNavigatorBottomErrorInclude.inc"%>

<% if(errFalg)
{%>
         <script language="javascript">
          getTopWindow().document.location.href="emxCommonDocumentEditDialogFS.jsp?objectId=<%=XSSUtil.encodeForURL(context, documentId)%>";
        </script>
<%}%>

