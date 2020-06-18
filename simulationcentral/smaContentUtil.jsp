<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Process various SLM commands on the Simulation and Activity
  content page.
--%>

<%--
[1-Aug-2007]
Special emxForm.jsp handling:

The Content page is currently set up as a Portal/Channel/Tab page.
The framework flags this as a portal page by passing portalMode=true
to the page's commands. This portalMode flag causes a change in look
and behavior in emxForm.jsp. Thus, in order for emxForm.jsp to function
correctly from a portal page, the portalMode parameter must be stripped
off the url.
(This is the reason the Create Folder form is directed through this
jsp.)

Additionally, emxFormEditFooter.jsp has the behavior that if
getTopWindow().document.location.href is not emxForm.jsp, the Cancel button is
not displayed. So, again, for emxForm.jsp to function right, this
jsp has to force the browser to redirect to emxForm.

[Dev note: I tried to use jsp:forward, but this caused a problem
within emxform.jsp on the url references for its frames - the urls
reference the target jsp without a path. These urls are considered
relative to the original request, which was to SimulationCentral
(not Common), so the subject jsps are not found. ]
--%>

<%@page import="com.dassault_systemes.smaslm.matrix.server.SlmUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.Simulation"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationContentUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="com.matrixone.apps.domain.util.MqlUtil"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.util.ContextUtil"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkException"%>
<%@page import="com.matrixone.apps.framework.ui.UIUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainRelationship"%>
<%@page import="com.matrixone.apps.common.CommonDocument"%>
<%@page import="com.matrixone.apps.domain.DomainConstants"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.AccessUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.FileUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationCategory"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.server.SimulationActivity"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.ErrorUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.Parameters"%>
<%@page import="com.dassault_systemes.smaslm.matrix.web.SlmUIUtil"%>


<%@page import="matrix.db.Context"%>
<%@page import="matrix.db.BusinessObject"%>
<%@page import="matrix.db.User"%>
<%@page import="matrix.util.StringList"%>
<%@page import="matrix.util.MatrixException"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.Enumeration"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.HashSet"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Set"%>
<%@page import="java.io.UnsupportedEncodingException"%>
<%@page import="javax.servlet.http.HttpServletRequest"%>

<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file="../simulationcentral/smaWebUtil.inc"%>


<script type="text/javascript"  src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript" src="../simulationcentral/smaStructureBrowser.js"></script>
<script type="text/javascript" src="../common/scripts/emxUICore.js"></script>
<script type="text/javascript" src="../common/scripts/emxUITableUtil.js"></script>  

<%
    // Note: selectRevision action is called from both the Content
    //       page and the Activities page.

    // What is it that we want to do?
    // Possible objectAction values:
    //    access
    //    addCategory
    //    addExisting
    //    checkin
    //    checkinBigFile
    //    checkout
    //    checkoutBigFile
    //    createFolder
    //    download
    //    downloadBigFile
    //    lock/unlock
    //    moveItem
    //    pasteFromClipboard
    //    remove
    //    selectRevision
    //    setToInput
    //    setToIO
    //    setToNothing
    //    setToOutput
    //    showReferences
    //    update
    //    uploadImage
    //    view
    //    createExportRule
    //    createImportRule
    //    updateBigFile

    
    Map requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);

    // ve4 + m6d starts
    String row = emxGetParameter(request, "emxTableRowId");
 // ve4 + m6d ends

    String objectAction = emxGetParameter(request, "objectAction");
    //String locale = context.getSession().getLanguage();
    String titleSpec = "true" ;
    if ( (objectAction == null) || (objectAction.equals("")) )
    {
        String sError = SimulationUtil.getI18NString(context,
            "Error.ContentUtil.NoAction");
        emxNavErrorObject.addMessage(sError);
        objectAction = "";
    }

    String refreshFrame = emxGetParameter(request, "refreshFrame");

    boolean refreshPage = true;
    boolean isPopup = true;
    boolean isSlidein = false;

    String[] sRowIds = null;
    String objectId = null;
    String parentId = null;
    String errMsg = "";
    String relid = null;
    
    
    String rootParentId = emxGetParameter(request, "objectId");

    /////////////////
    // Get selected rows from the request map
    //
    // Add Category does not have anything selected
    // Fake the remaining code out by making the parent selected
    if (objectAction.equals("addCategory"))
    {
        sRowIds = new String[]{"||"+rootParentId+"|"};
    }
    else
    {
        sRowIds = emxGetParameterValues(request, "emxTableRowId");
    }


    /////////////////
    // sRowIds should never be null since these commands must have a
    // selection single/multiple setting and are thus caught
    // by M1 if nothing is selected
    if ( (sRowIds == null) || (sRowIds.length == 0) )
    {
        String msg = SimulationUtil.getI18NString(context,
            "Error.ContentUtil.SelectOne");
        emxNavErrorObject.addMessage(msg);
    }

    // Something was selected, get the object and parent ids
    else
    {
        // Select revision may be coming from the Activities page.
        // If so, add parent to end of element
        // Note that it won't hurt adding it to end of the element
        // when coming from Content page
        if ( objectAction.equals("selectRevision") )
        {
    for ( int ii=0; ii<sRowIds.length; ii++ )
        sRowIds[ii] += "|"+rootParentId;
        }

        // Many of the commands below are single select commands
        // so get the object id from the first item selected
        StringList sIds = SimulationContentUtil.convertRowId( sRowIds[0] );
        relid = (String)sIds.get(0);
        objectId = (String)sIds.get(1);
        parentId = (String)sIds.get(2);
    }


    /////////////////
    // The following are all the commands that do NOT open a popup
    // window (not including the javascript prompt).  If popup is
    // not popped up, don't close it ;-)
    if (objectAction.equals("setToInput")   ||
        objectAction.equals("setToOutput")  ||
        objectAction.equals("setToIO")      ||
        objectAction.equals("setToNothing") ||
        objectAction.equals("remove")       ||
        objectAction.equals("lock")         ||
        objectAction.equals("unlock")       ||
        objectAction.equals("createFolder")
        )
    {
        isPopup = false;
    }
    else
    {
        isPopup = true;
    }
    
    if(objectAction.equals("addCategory") )
    {
        isSlidein = true;
    }
    
    /////////////////
    // Contains URL for action
    URLBuilder contentURL = getURLBuilder(request);

    // Set default refresh command
    String returnAction = "";
    String returnMsg = "";

    // VE4 changed the name of this DomainObject from dobj 
    // as there are other local variables with same name
    // hence it was causing mkmk build errors.
    // 8/10/2012
    DomainObject dobjforcheckingversion = new DomainObject();
    boolean isVersionableType = false;
    String documentType = "";
    if(objectId!=null && !"".equals(objectId))
    {
        dobjforcheckingversion.setId(objectId);
        documentType =
    dobjforcheckingversion.getInfo(context, DomainConstants.SELECT_TYPE);
         isVersionableType =
    CommonDocument.checkVersionableType(context, documentType);  
    }
    
    try
    {
        // Do the actual work...

        // Check if the arguments are correct, if the user has access
        // and if items are not locked (and if user is not the locker)
        // If all this passes, then proceed with the action
        if (SimulationContentUtil.argumentsAreGood(
        context, sRowIds, objectAction, emxNavErrorObject) &&
    SimulationContentUtil.hasAccess(
        context, sRowIds, objectAction, emxNavErrorObject) &&
    SimulationContentUtil.isNotLocked(
        context, sRowIds, objectAction, emxNavErrorObject) )
        {
    if (objectAction.equals("addCategory") )
    {
        //JPO function to filter for all objects.
        final String ALL_FILTER_PROGRAM =
            "jpo.simulation.SimulationContent:getFilterAll";

        //Get the JPO function that was used to filter.
        String selectedProgram =
            emxGetParameter(request, "selectedProgram");
        
        selectedProgram = 
            selectedProgram==null?
                ALL_FILTER_PROGRAM:selectedProgram;
        
        if (selectedProgram.equals(ALL_FILTER_PROGRAM))
        {
            addCategory(context, request,
                rootParentId, contentURL, emxNavErrorObject);
        }
        else
        {
            //////////
            //Add Category should not be allowed on any other
            //filter choice.
            errMsg = SimulationUtil.getI18NString(context, 
                 "smaSimulationCentral.Content.ErrMsg.cannotaddcat");
            emxNavErrorObject.addMessage(errMsg);
        }
    }

    else if (objectAction.equals("addExisting"))
    {
        String hlp = emxGetParameter(request, "HelpMarker");
        String srcDestRelName = 
            emxGetParameter(request, "srcDestRelName");

        contentURL
           .append("../simulationcentral/smaSearchUtil.jsp")
           .append("?slmmode=addexisting")
           .append("&objectId=").append(objectId)
           .append("&HelpMarker=").append(hlp)
           .append("&emxTableRowId=").append(sRowIds[0])
           .append("&refreshFrame=").append(refreshFrame)
           .append("&srcDestRelName=").append(srcDestRelName);
    }

    else if (objectAction.equals("pasteFromClipboard"))
    {
        String hlp = emxGetParameter(request, "HelpMarker");
        String srcDestRelName = 
            emxGetParameter(request, "srcDestRelName");
        
        if ( srcDestRelName == null || 
            srcDestRelName.length() == 0 )
        {
            srcDestRelName = 
                "relationship_SimulationContent_Referenced";
        }
        
        // get program gets filtered clipboard objects
        // from all the user's clipboards.  It will filter
        // for objects that can be added as referenced content
        String program = 
            "smaAEFCollection:getClipboardObjects";
                                      
        String hdr = SimulationUtil.getI18NString(context, 
            "smaSimulationCentral.Content.PasteFromClipboard");
        
        // bring up table with the clipboard objects
        contentURL
           .append("../common/emxTable.jsp")
           .append("?program=").append(program)
           .append("&emxTableRowId=").append(sRowIds[0])
           .append("&objectId=").append(objectId)
           .append("&HelpMarker=emxhelpcollectionitems")
           .append("&table=AEFCollectionItems")
           .append("&objectBased=true")
           .append("&sortColumnName=Name")
           .append("&header=").append(hdr)
           .append("&selection=multiple")
           .append("&PrinterFriendly=true")
           .append("&showClipboard=false")
           .append("&CancelButton=true")
           .append("&suiteKey=Framework")
           .append("&refreshFrame=").append(refreshFrame)
           .append("&srcDestRelName=").append(srcDestRelName)
           .append("&SubmitURL=../simulationcentral/smaContentConnect.jsp?")
           .append("openedBy=").append("fromCollections");
    }


    else if (objectAction.equals("checkin"))
    {
        // Clear session variable because M1 doesn't on cancel
        // old values then hang around
    	session.removeAttribute("emxCommonDocumentCheckinData");
   		contentURL.append(
               "../components/emxCommonDocumentPreCheckin.jsp")
   			.append("?objectAction=checkin")
   			.append("&msfBypass=true")
   			.append("&suiteKey=Components")
   			.append("&StringResourceFileId=emxComponentsStringResource")
   			.append("&SuiteDirectory=components");
   			appendIdParamsToURL(context,contentURL, parentId, objectId)
   			.append("&targetLocation=popup");
    }

    else if (objectAction.equals("checkinBigFile"))
    {
        // Clear session variable because M1 doesn't on cancel
        // old values then hang around
        session.removeAttribute("emxCommonDocumentCheckinData");
        contentURL.append(
            "../components/emxCommonDocumentPreCheckin.jsp")
            .append("?objectAction=checkin")
            .append("&forceApplet=true")
            .append("&showComments=true");
        appendIdParamsToURL(context,contentURL, parentId, objectId)
            .append("&appDir=simulationcentral")
            .append("&appProcessPage=smaStructureBrowserUtil.jsp?action=refresh");
    }

    else if (objectAction.equals("update") && isVersionableType)
    {
        // Clear session variable because M1 doesn't on cancel
        // old values then hang around
        session.removeAttribute("emxCommonDocumentCheckinData");
        objectId = FileUtil.getObjectIdFromFileId(context,objectId);
        String updateAction = "update";
        
        BusinessObject bo = new BusinessObject(objectId);
        boolean objectIsLocked = bo.isLocked(context);
        
        // To check if this object is document
        StringList selects = new StringList();
        String selectIsVersionObj = "attribute[Is Version Object]";
        
        selects.addElement(selectIsVersionObj);
        
        MapList mapList = DomainObject.getInfo(context, new String[]{objectId}, selects);
        
        Map map = (Map)mapList.get(0);
        boolean isDocumentObject = !(Boolean.parseBoolean((String)map.get(selectIsVersionObj))),                
        itemUpdatable = false;
        
        // To check if item (file/doc) is updatable
        if(objectIsLocked)
         itemUpdatable = true;
        else if(isDocumentObject){
        
            CommonDocument document = new CommonDocument(bo);
            HashMap lockedFilesInfoMap = document.getLockedFiles(context);
            
            for(Object infoKey : lockedFilesInfoMap.keySet()){
                                    
                int lockedFileCount = ((StringList)lockedFilesInfoMap.get(infoKey)).size();                 
                if(lockedFileCount > 0)
                    itemUpdatable = true;
                break;
            }
        }
        
        if(itemUpdatable){
            
            contentURL.append(
                "../components/emxCommonDocumentPreCheckin.jsp")
                .append("?objectAction=").append(updateAction)
                .append("&showFormat=readonly")
                .append("&showComments=required");
            appendIdParamsToURL(context,contentURL, parentId, objectId)
                .append("&appDir=simulationcentral")
                .append("&appProcessPage=smaCustomRefresh.jsp?emxTableRowId=")
                .append(XSSUtil.encodeURLForServer(context, URLEncoder.encode(row,URLBuilder.DEFAULT_ENCODING)));
        }
        else{
                     String sError = SimulationUtil.getI18NString(context,"Error.ContentUtil.ItemUnlocked");
             emxNavErrorObject.addMessage(sError);
             objectAction = "";
        }                
    }
    
    else if(objectAction.equals("updateBigFile") && isVersionableType == true){
        
        /**
         *Changes for IR-206957V6R2014 - x86
         *Adding a validation to check if the file is locked
         */
        boolean isFile = FileUtil.isFileId(objectId);
        if(isFile)
        {
        String fileId = FileUtil.getObjectIdFromFileId(context,objectId);
        DomainObject obj = new DomainObject(fileId);
        boolean isfileLocked = AccessUtil.isLocked( context, obj, false );
		if (!isfileLocked)
                {
                    String errMsgUp = SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Content.ErrMsg.NotLockedFile");
                    throw new Exception(errMsgUp);  
                }
        }
      //Changes for IR-206957V6R2014 ends here
      
        session.removeAttribute("emxCommonDocumentCheckinData");
        
        objectId = FileUtil.getObjectIdFromFileId(context,objectId);
        String updateAction = "update";
        
        contentURL.append(
            "../components/emxCommonDocumentPreCheckin.jsp")
            .append("?objectAction=").append(updateAction)
            .append("&largeFileUpdate=true")
            .append("&forceApplet=true")
            .append("&showFormat=readonly")
            .append("&showComments=required");
        appendIdParamsToURL(context, contentURL, parentId, objectId)
            .append("&appDir=simulationcentral")
            .append("&appProcessPage=smaCustomRefresh.jsp?emxTableRowId=")
            .append(XSSUtil.encodeURLForServer(context, URLEncoder.encode(row,URLBuilder.DEFAULT_ENCODING)));
    }
    else if (objectAction.equals("checkout"))
    {
        contentURL.append(
            "../components/emxCommonDocumentPreCheckout.jsp")
            .append("?action=checkout")
            .append("&refresh=false");
        appendIdParamsToURL(context,contentURL, parentId, objectId)
            .append("&appDir=simulationcentral")
            .append("&isAppPreProcess=true")                    
            .append("&appProcessPage=undefined");
    }

    else if (objectAction.equals("checkoutBigFile"))
    {
        contentURL.append(
            "../components/emxCommonDocumentPreCheckout.jsp")
            .append("?action=checkout")
            .append("&refresh=false")
            .append("&forceApplet=true");
        appendIdParamsToURL(context,contentURL, parentId, objectId)
            .append("&appDir=simulationcentral")
            .append("&isAppPreProcess=true")
            .append("&appProcessPage=undefined");
    }

    else if (objectAction.equals("view"))
    {
        doViewAction(context, parentId, objectId, contentURL);
    }

    else if (objectAction.equals("download"))
    {
        /* fix for IR-262446V6R2014x:
        'appProcessPage' parameter is handle of post checkout-process (mostly for refresh)
        
        but 'appProcessPage' parameter is added here with no value, 
        to avoid below mentioned block
        
        emxCommonDocumentCheckout.jsp: line 475-477 (Enovia build of 1341)
        if (appProcessPage != "undefined" && appProcessPage.length > 0) {
            setTimeout("closeWindow()", 500);
        }
        */
        contentURL.append(
            "../components/emxCommonDocumentPreCheckout.jsp")
            .append("?action=download").append("&isAppPreProcess=true&appProcessPage=");//Setting for BPS processing - IR-199271V6R2014 - pt6
        appendIdParamsToURL(context,contentURL, parentId, objectId);
    }

    else if (objectAction.equals("downloadBigFile"))
    {
        contentURL.append(
            "../components/emxCommonDocumentPreCheckout.jsp")
            .append("?action=download")
            .append("&forceApplet=true")
            .append("&isAppPreProcess=true");//Setting for BPS processing - IR-199271V6R2014 - pt6
        appendIdParamsToURL(context,contentURL, parentId, objectId);
    }

    else if (objectAction.equals("createFolder"))
    {
        isSlidein = true;
       String lang = context.getSession().getLanguage();
       final String header =
            		   SimulationUtil.getI18NString(context,
                    "Common.AddFolder.PageHeading");

               contentURL.append("../common/emxForm.jsp")
         .append("?form=SMAFolder_CreateViewEdit")
         .append("&mode=edit")
         .append("&formHeader=").append(header)
         .append("&postProcessURL=")
         .append("../simulationcentral/smaCreateFolderUtil.jsp")
         .append("&objectId=").append(objectId)
         .append("&isPopup=false") // see comment below
         .append("&isSlidein=true")
         .append("&emxTableRowId=").append(sRowIds[0]);

        // NOTE: isPopup=false is used above so that
        // emxFormEditProcess.jsp does not try to update the
        // content page
    }

    else if (objectAction.equals("uploadImage"))
    {
        String strType =  DomainObject.TYPE_IMAGE_HOLDER;
        String strPolicy = DomainObject.POLICY_IMAGE_HOLDER;

        contentURL.append(
            "../components/emxCommonDocumentPreCheckin.jsp")
            .append("?objectAction=image")
            .append("&objectId=").append(objectId)
            .append("&JPOName=emxImageManager")
            .append("&methodName=associateImage")
            .append("&override=false")
            .append("&showFormat=false")
            .append("&realType=").append(strType)
            .append("&type=").append(strType)
            .append("&policy=").append(strPolicy)
            .append("&showComments=false")
            .append("&HelpMarker=emxhelpimagesupload")
            .append("&appDir=simulationcentral")
            .append("&appProcessPage=smaStructureBrowserUtil.jsp?action=refresh");
    }

    else if (objectAction.equals("showReferences"))
    {
        DomainObject obj = new DomainObject();
        obj.setId(objectId);
        String sName =
            SimulationUtil.getObjectName(context, obj);
        String sRev = obj.getInfo(
            context, DomainConstants.SELECT_REVISION);

        String REL_SIM_CAT =
          SimulationUtil.getSchemaProperty(
            SimulationConstants.
              SYMBOLIC_relationship_SimulationCategory);
        String REL_CAT_FLDR =
          SimulationUtil.getSchemaProperty(
            SimulationConstants.
              SYMBOLIC_relationship_SimulationSubFolder);
        String REL_CONTENT_OWNED =
          SimulationUtil.getSchemaProperty(
            SimulationConstants.
              SYMBOLIC_relationship_SimulationContent_Owned);
        String REL_CONTENT_REFED =
          SimulationUtil.getSchemaProperty(
            SimulationConstants.
              SYMBOLIC_relationship_SimulationContent_Referenced);

        StringBuffer relTypes = new StringBuffer(150);
        relTypes
            .append(REL_SIM_CAT).append(",")
            .append(REL_CAT_FLDR).append(",")
            .append(REL_CONTENT_OWNED)
            .append(REL_CONTENT_REFED);

        // Define what business types to return
        String FOLDERS =
          SimulationUtil.getSchemaProperty(
            SimulationConstants.
              SYMBOLIC_type_SimulationFolders);
        String SIMULATIONS =
          SimulationUtil.getSchemaProperty(
            SimulationConstants.
              SYMBOLIC_type_SIMULATIONS);

        StringBuffer searchTypes = new StringBuffer(125);
        searchTypes
            .append(SIMULATIONS).append(",")
            .append(FOLDERS).append(",");

        String sTypes = searchTypes.toString();
        String sRel = relTypes.toString();

        contentURL.append(
            "../simulationcentral/smaShowRelated.jsp")
            .append("?objectId=").append(objectId)
            .append("&revision=").append(sRev)
            .append("&name=").append(sName)
            .append("&relationships=").append(sRel)
            .append("&type=").append(sTypes);
    }

    else if (objectAction.equals("selectRevision"))
    {
        // Invoke the JPO to get the relationship id between the process and the activity.
        Map argsMap = new HashMap();
        argsMap.put("objectId", objectId);

        if(relid == null || relid.equalsIgnoreCase("dummy"))
        {
            // If relationship id is null, get the relationship id
            relid = (String) JPO.invoke(
            context,
            "jpo.simulation.SimulationUtil",
            null,
            "getRelationshipId",
            JPO.packArgs(argsMap),
            String.class);
        } 
        
        
        //sRowIds[0] = relid + sRowIds[0]; 
        
        String hlp = emxGetParameter(request, "HelpMarker");
        String tableType = emxGetParameter(request, "tableType");

        contentURL
            .append("../common/emxTable.jsp")
            .append("?table=SMASimulation_Revisions")
            .append("&program=jpo.simulation.SimulationUI")
            .append(":getRevisionsToSelect")
            .append("&header=smaSimulationCentral.SelectRevision")
            .append("&selection=single")
            .append("&CancelButton=true")
            .append("&objectId=").append(objectId)
            .append("&ContentRowIds=").append(sRowIds[0])
            .append("&ParentOID=").append(rootParentId)
            .append("&HelpMarker=").append(hlp)
            .append("&tableType=").append(tableType)
            .append("&suiteKey=SimulationCentral")
            .append("&SubmitURL=")
            .append("../simulationcentral/smaSelectRevisionUtil.jsp");
    }

    else if (objectAction.equals("moveItem"))
    {
        contentURL.append( "../common/emxBlank.jsp")
            .append("&objectId=").append(objectId)
            .append("&ParentOID=").append(parentId)
            .append("&ContentRowIds=").append(sRowIds[0]);
    }

    else if (objectAction.equals("setToInput") ||
             objectAction.equals("setToOutput") ||
             objectAction.equals("setToIO") ||
             objectAction.equals("setToNothing"))
    {
        String confirmMsg = null;  
        String refFolderWarningMsg = null ;
        sRowIds = emxGetParameterValues(request, "emxTableRowId");        
        String confirmParamName = "confirmSetContentIOStatus";
        Boolean okToSet = true ;

        if (!"setToNothing".equals(objectAction))
        {
            /* check for a parameter that indicates that the user
             * has confirmed this delete operation
             */
            if (emxGetParameter(request, confirmParamName) == null)
            {
                Map argsMap = new HashMap();
                String[] objectIds = getObjectIds(sRowIds);
                argsMap.put("objectIds", objectIds);
                
                Boolean hasContent = (Boolean) JPO.invoke(
                    context,
                    "jpo.simulation.SimulationContent",
                    null,
                    "hasContent",
                    JPO.packArgs(argsMap),
                    Boolean.class),
                    isAnyObjRefFolder = false,
                    isParentContainerReferencedForAnyObj = false;
                
                DomainObject parentSIMULATIONObject = DomainObject.newInstance(context, rootParentId);
                MapList nonReferencedChildren = null;
                //Check if any of the selected objects corresopnd to referenced folder (of any type i.e. Workspace Folder OR Simulation Folder)
                for(int i=0; i<objectIds.length; i++){
                    
                    String currentObjectId = objectIds[i],
                        parentObjId = sRowIds[i].split("\\|")[2];
                    DomainObject currentObject = DomainObject.newInstance(context, currentObjectId);
                    String currentObjectType = FrameworkUtil.getType(context, currentObject);
                    if(currentObjectType.equals(DomainConstants.TYPE_WORKSPACE_VAULT)){
                        isAnyObjRefFolder = true;//Workspace folder can only be referenced (can't be owned) in content page of SIMULATIONS
                        break;
                    }
                    else if(currentObjectType.equals(SimulationConstants.TYPE_SIMULATION_FOLDER)){                        
                        DomainObject parentObj = DomainObject.newInstance(context, parentObjId);
                        StringList busSelects = new StringList();
                        busSelects.add(DomainConstants.SELECT_ID);
                        MapList connectedObjects = parentObj.getRelatedObjects(context, SimulationConstants.RELATIONSHIP_SIMULATION_CONTENT_REFERENCED, SimulationConstants.TYPE_SIMULATION_FOLDER, busSelects, null, false, true, (short) 1, "id=="+currentObjectId, "", 0);
                        if(!connectedObjects.isEmpty()){
                            isAnyObjRefFolder = true;
                            break;
                        }
                    }
                    
                    //Check if any of the parent container is referenced
                    if(!isAnyObjRefFolder) {
                        String ownedParentSIMULATION = SlmUtil.getAncestorSimulationObjectId(context, parentObjId);//we have passed parent here, since we want to check relationship of each parent with it's immediate parent (passing currentObjectId will also involve relationship of child itself, which we don't want to include) 
                        if(!rootParentId.equals(ownedParentSIMULATION)){//ownedParentSIMULATION will be null if any of the parent is referenced WS folder (but still code will work since string comparison with null will return false)
                            isParentContainerReferencedForAnyObj = true;
                            break;
                        }
                    }
                }
                
                if(isAnyObjRefFolder.booleanValue())
                {
                    refFolderWarningMsg = SimulationUtil.
                    getI18NString(context, SimulationConstants.STRING_RESOURCE_KEY_REF_FOLDER_CANT_BE_IO);
                    emxNavErrorObject.addMessage(refFolderWarningMsg);
                    okToSet = false ;
                    
                }
                else if(isParentContainerReferencedForAnyObj.booleanValue()){
                    
                    String refParentWarningMsg = SimulationUtil.
                        getI18NString(context, SimulationConstants.STRING_RESOURCE_KEY_CONTAINER_IS_REF);
                        emxNavErrorObject.addMessage(refParentWarningMsg);
                        okToSet = false ;
                }
                else if (hasContent.booleanValue())
                {
                    confirmMsg = UINavigatorUtil.
                        getI18nString(
                            "smaSimulationCentral.SimulationFolderContent.confirmSetIOStatus",
                            "smaSimulationCentralStringResource",
                            context.getSession().getLanguage());
                }
                
            }
        }
    
        if (confirmMsg != null)
        {
            String requestUrl = "../simulationcentral/smaContentUtil.jsp?"+confirmParamName+"=true";
%>
<html>
<body>

    <jsp:include page="../simulationcentral/smaPreserveParamsForm.jsp">
        <jsp:param name="smaPreserveParamsFormAction"
            value="<%= requestUrl %>" />
        <jsp:param name="smaPreserveParamsIncludeQueryParams" value="true" />
        <jsp:param name="smaPreserveParamsConfirmMessage"
            value="<%= confirmMsg %>" />
    </jsp:include>

</body>
</html>
<%
                    return;
                }
                if(okToSet.booleanValue()){
                setInputOutput(
                    context, rootParentId, sRowIds,
                        objectAction, emxNavErrorObject);
                returnAction = "refresh";
                }
            }

            else if (objectAction.equals("remove") )
            {
                String confirmMsg = null;
                String confirmParamName = null;

                /* check for a parameter that indicates that the user
                 * has confirmed this delete operation
                 */
                if (emxGetParameter(request, "confirmOwnedRevsDelete") == null ||
                    emxGetParameter(request, "confirmOwnedWithRefs") == null)
                {
                    try
                    {
                        String confirmKey = null;

                        String[] deleteOids = getObjectIds(sRowIds);

                        if (emxGetParameter(request, "confirmOwnedRevsDelete") == null)
                        {
                            Boolean isOwnedWithRevs = (Boolean) JPO.invoke(
                                context,
                                "jpo.simulation.SimulationUtil",
                                null,
                                "isOwnedContentWithMultipleRevisions",
                                deleteOids,
                                Boolean.class);

                            if (isOwnedWithRevs.booleanValue())
                            {
                                confirmParamName = "confirmOwnedRevsDelete";
                                confirmKey = "smaSimulationCentral.OwnedContentWithRevisions.confirmDelete";
                            }
                        }

                        // check to see if the content is owned by the
                        // parent and referenced elsewhere
                        if (confirmKey == null &&
                            emxGetParameter(request, "confirmOwnedWithRefs") == null)
                        {
                            Map paramMap = new HashMap();
                            paramMap.put("parentOID", parentId);
                            paramMap.put("objectIDs", deleteOids);

                            Boolean isStandaloneWithRefs = (Boolean) JPO.invoke(
                                context,
                                "jpo.simulation.SimulationUtil",
                                null,
                                "isOwnedContentWithReferences",
                                JPO.packArgs(paramMap),
                                Boolean.class);

                            if (isStandaloneWithRefs.booleanValue())
                            {
                                confirmParamName = "confirmOwnedWithRefs";
                                confirmKey = "smaSimulationCentral.OwnedContentWithReference.confirmDelete";
                            }
                        }

                        // if we have a key get the prompt string
                        if (confirmKey != null)
                        {
                            confirmMsg = SimulationUtil.getI18NString(context,
                                    confirmKey);
                        }
                    }
                    /* if something fails during the check proceed
                     * with the delete
                     */
                    catch (Exception ignore) {}
                }

                if (confirmMsg == null)
                {
                	 HashMap messageMap = SimulationContentUtil.removeItem(context, sRowIds);
                     returnAction = "remove";
                     returnMsg = (String) messageMap.get("message");
                     if (returnMsg != null && returnMsg.length() > 0)
                         returnAction = "error";
                                      
                     if("true".equalsIgnoreCase(emxGetParameter(request, "isFromRMB")) && "remove".equalsIgnoreCase(returnAction)){
                         
                         %>
                         <script type="text/javascript">
                             var frameHome = findFrame(getTopWindow(), "detailsDisplay");
                               if(frameHome){
                             	  var rowsToRemove = new Array();
                             	  rowsToRemove[0] = "<%=sRowIds[0].toString()%>";
                                   frameHome.removeRows(rowsToRemove);
                                }
                               else{
                             	  //Unable to refresh UI as, unable to find frame. RMB will always called from detailsDisplay frame, otherwise need to pass correct frame and use it here
                             	  //Do Nothing
                             	  console.log("details display frame not found. Please check with administrator");
                               }
                         </script>
                         <%
                     }
                     else{
                     
                         // The message gets passed as a URL parameter, so encode it.
                         returnMsg =XSSUtil.encodeForURL(context,returnMsg);

                         contentURL
                             .append( "../simulationcentral/smaStructureBrowserUtil.jsp")
                             .append("?action=").append(returnAction)
                             .append("&message=").append(returnMsg)
                             .append("&closeWindow=").append("false")
                             .append("&currentWindowOp=").append("true"); 
                         %>
                          <script type="text/javascript">
                             var frame = null;  
                             frame = sbFindFrame(getTopWindow(),"listHidden");
                             frame.location.href = "<%=contentURL.toString()%>";
                         </script>
                         <%
                       }
                    return;

                }
                else
                {                   
                	%>
                	<html>
                	<head>
                	<script language="JavaScript">
                	                    <!--
                	                    function pageLoaded()
                	                    {
                	                        if (confirm('<%= confirmMsg %>'))
                	                        {
                	                        	
                	                            document.preserveParamsForm.target = this.name;
                	                            document.preserveParamsForm.submit();
                	                        }
                	                    }
                	                    //-->
                	                </script>
                	</head>
                	<body onload="pageLoaded()">
                	    <form name="preserveParamsForm" method="POST"
                	        action="../simulationcentral/smaContentUtil.jsp?<%= confirmParamName %>=true">
                	        <%
                	                    // add the rest of the parameters to the request
                	                    for (Iterator iter = Parameters.getParameterList(request).iterator();
                	                         iter.hasNext();)
                	                    {
                	                        Parameters.Parameter param = (Parameters.Parameter) iter.next();
                	                        String paramName = param.getName();

                	                        if (paramName == null ||
                	                            paramName.equals(confirmParamName))
                	                        {
                	                            continue;
                	                        }
                	%>
                	        <input name="<%= paramName %>"
                	            <%
                	                        String paramValue = param.getValue();
                	                        if (paramValue != null)
                	                        {
                	%>
                	            value="<%= paramValue %>" <%
                	                        }
                	%>
                	            type="hidden" />
                	        <%
                	                    }
                	%>
                	    </form>
                	</body>
                	</html>
                	<%
                }
            }

            else if ( objectAction.equals("lock") ||
                      objectAction.equals("unlock") )
            {
                DomainObject obj = new DomainObject();

                // Loop through all selected
                for (int iii=0; iii<sRowIds.length; iii++)
                {
                    StringList sIds = SimulationContentUtil.convertRowId( sRowIds[iii] );
                    String selObjectId = (String)sIds.get(1);
                    if (FileUtil.isFileId(selObjectId))
                    {
                        selObjectId = FileUtil.
                            getObjectIdFromFileId(context,selObjectId);
                    }

                    obj.setId(selObjectId);

                    if (objectAction.equalsIgnoreCase("lock"))
                    {
                        obj.lock(context);
                    }
                    else if (objectAction.equalsIgnoreCase("unlock"))
                    {
                        obj.unlock(context);
                    }
                }
                returnAction = "refresh";
            }
           
            else if (objectAction.equals("createImportRule") ||
                objectAction.equals("createExportRule") ||
                objectAction.equals("createDeleteRule") ||
                objectAction.equals("createImporterImportRule") ||
                objectAction.equals("createWorkSpaceFolderImportRule")||
                objectAction.equals("createWorkSpaceFolderExportRule")) //...RKP new condition
            {
                String type_SimulationCategory = 
                    SimulationUtil.getSchemaProperty(
                    SimulationConstants.SYMBOLIC_type_SimulationCategory);
                    
                for(int index = 0;index<sRowIds.length; index++){
                    StringList sIds = SimulationContentUtil.convertRowId( sRowIds[0] );
                    String objID = (String)sIds.get(1);
                    
                    DomainObject domainObject = new DomainObject(objID);

                }

                Map argsMap = new HashMap();
                argsMap.put("objectId", rootParentId);
                argsMap.put("rowIds", sRowIds);
                
                String TYPE_WORKSPACE_VAULT =
                    SimulationUtil.getSchemaProperty(
                        SimulationConstants.SYMBOLIC_type_WorkspaceVault); //...RKP end
                String TYPE_SIMULATION_FOLDER =
                    SimulationUtil.getSchemaProperty(
                                SimulationConstants.SYMBOLIC_type_SimulationFolder);
                String TYPE_SIMULATION_FOLDERS =
                    SimulationUtil.getSchemaProperty(
                                SimulationConstants.SYMBOLIC_type_SimulationCategory);
                
                DomainObject dynObj = new DomainObject();
                dynObj.setId(objectId);
                
                if(documentType.equals(TYPE_SIMULATION_FOLDER) ||
                    documentType.equals(TYPE_WORKSPACE_VAULT) ||
                    dynObj.isKindOf(context, TYPE_SIMULATION_FOLDERS))
                {
                    if("createExportRule".equals(objectAction))
                        objectAction = "createWorkSpaceFolderExportRule";
                    else if("createImportRule".equals(objectAction))
                        objectAction = "createWorkSpaceFolderImportRule";
                }
                
                
                boolean returnVal = SimulationActivity.getStepsFromActivity(context, rootParentId, objectAction);
                if(returnVal==false)
                {
                    String stepName = "";
                    if("createImportRule".equals(objectAction)||"createImporterImportRule".equals(objectAction)||"createWorkSpaceFolderImportRule".equals(objectAction))
                        stepName = "Upload";
                    else if("createExportRule".equals(objectAction)||"createWorkSpaceFolderExportRule".equals(objectAction))
                        stepName = "Download";
                    else if ("createDeleteRule".equals(objectAction))
                        stepName = "Delete Content";
                    errMsg =
                        SimulationUtil.getI18NString(context,
                            "smaSimulationCentral.error.StepIsAbsent",
                            "stepName", stepName);
                            
                    
                    // VE4 alerting exception. The functionality 
                    //is mostly tested in Chrome where emxNavErrorObject
                    // does not explicitly throw error.
                    
                    %>
<script>  
                         alert("<%=errMsg%>");
                         getTopWindow().closeWindow();
                        </script>
<%
                       //emxNavErrorObject.addMessage(errMsg);
                     
                }
                else{
                    StringList allData = new StringList();
                
                    if(objectAction.equals("createDeleteRule"))
                        allData = (StringList)JPO.invoke(context,
                            "jpo.simulation.ImportExport", null,
                            "createDeleteRuleFromContent", 
                            JPO.packArgs(argsMap), StringList.class);
                    else
                        allData = (StringList)JPO.invoke(context,
                        "jpo.simulation.ImportExport", null,
                        "getAllDataToCreateRule", 
                        JPO.packArgs(argsMap), StringList.class);
                
                String docTitle = "";
                String docType = "";
                String docPolicy = "";
                String category = "";
                String contentRel = "";
                String impactRel = "";
                String docId = "";
                String fileName = "";
                String folderType = ""; //...RKP change
                String folderTitle = "";
                if(allData.size()==10)
                {
                    docTitle = (String)allData.get(0);
                    docType = (String)allData.get(1);
                    docPolicy = (String)allData.get(2);
                    category = (String)allData.get(3);
                    contentRel = (String)allData.get(4);
                    impactRel = (String)allData.get(5);
                    docId = (String)allData.get(6);
                    fileName = (String)allData.get(7);
                    folderType = (String)allData.get(8); //...RKP change
                    folderTitle = (String)allData.get(9);
                }
                else
                {
                    errMsg = SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Content.ErrMsg.createRule" );
                       emxNavErrorObject.addMessage(errMsg);
                }
                
                //EEF - pt6 - To check if the id(selected object) is of category or not
                /*DomainObject dObj = null;                
                if(!(docId.equalsIgnoreCase("")) && (docId != null)){
                    dObj = new DomainObject(docId);
                }*/
                
                String lang = context.getSession().getLanguage();
                
                // set up for create import rule
                String header = SimulationUtil.getI18NString(context,
                    "smaSimulationCentral.CreateImportRule.Form" );
                String formName = "SMAContentImportRule_Create";
                String tableTag = "ImportRules";
                String postProcessJPO = "jpo.simulation.ImportExport:createRule";
                String formHeader = 
                    "smaSimulationCentral.CreateImportRule.Form";
                String helpMarker = "SMAImportRule_ListCreate";
                
                // if creating export rule...reset with export rule data
                if (objectAction.equals("createExportRule"))
                {
                    header = SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.CreateExportRule.Form" );
                    // VE4 BO Export Start
                    StringList typestocheck =
                    SimulationUtil.getRangeList(context,
                        "ExportBO.Type");

                    DomainObject dobj = new DomainObject();
                    dobj.setId(objectId);
                
                    Boolean ifBOisKindOF = 
                    SimulationUIUtil.checkifBOisKindOF(context,dobj,typestocheck,null);
                   
                    if(!ifBOisKindOF)
                      formName = "SMAContentExportRule_Create";
                    else
                      formName = "SMAContentBOExportRule_Create";
                    // VE4 BO Export End
                    tableTag = "ExportRules";
                    formHeader = 
                        "smaSimulationCentral.CreateExportRule.Form";
                    helpMarker = "SMAExportRule_ListCreate";
                }
                else if (objectAction.equals("createDeleteRule"))
                {                   
                    header = SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.CreateDeleteRule.Form");
                    formName = "SMAContentDeleteRule_Create";
                    
                    tableTag = "DeleteRules";
                    formHeader = 
                        "smaSimulationCentral.CreateDeleteRule.Form";
                    helpMarker = "SMAExportRule_ListCreate";                              
                }

                else if (objectAction.equals("createImporterImportRule"))
                {
                    //selecting the correct form
                    formName = "SMAContentImporterImportRule_CreateEdit";
                    postProcessJPO = "jpo.simulation.ImportExport:createImporterRule";
                } //...RKP start
                else if (objectAction.equals("createWorkSpaceFolderImportRule"))
                {
                    //selecting the correct form
                    formName = "SMAContentWorkSpaceFolderImportRule_CreateEdit";
                    postProcessJPO = "jpo.simulation.ImportExport:createWorkspaceFolderRule";
                    tableTag = "ImportRules";
                    titleSpec = "false";
                    header = SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.Content.CreateWorkSpaceFolderImportRule");
                } //...RKP end
                else if (objectAction.equals("createWorkSpaceFolderExportRule"))
                {
                    //selecting the correct form
                    formName = "SMAContentWorkSpaceFolderExportRule_CreateEdit";
                    postProcessJPO = "jpo.simulation.ImportExport:createWorkspaceFolderRule";
                    tableTag = "ExportRules";
                    titleSpec = "false";
                    header = SimulationUtil.getI18NString(context,
                        "smaSimulationCentral.CreateWorkspaceVaultExportRule.Command");
                } //...RKP end
                if(header != null)
	                header = "\"+encodeURI('"+ header +"')+\"";
                
                if(objectAction.equals("createWorkSpaceFolderImportRule") || objectAction.equals("createWorkSpaceFolderExportRule"))
                {
                    contentURL
                    .append("../common/emxForm.jsp")
                    .append("?form=").append(formName)
                    .append("&formHeader=").append(header)
                    .append("&objectBased=false")
                    .append("&mode=edit")
                    .append("&suiteKey=SimulationCentral")
                    .append("&preProcessJPO=jpo.simulation.ImportExport:getDisplayValue")
                    .append("&postProcessJPO=").append(postProcessJPO)
                    .append("&xmlAttribute=attribute_Definition")
                    .append("&xmlRootTag=Simulation")
                    .append("&xmlTableTag=").append(tableTag)
                    .append("&xmlRowTag=Rule")
                    .append("&header=").append(formHeader)
                    .append("&HelpMarker=").append(helpMarker)
                    .append("&objectId=").append(objectId)
                    .append("&parentOID=").append(rootParentId)
                    .append("&titleSpec=").append(titleSpec)
                    .append("&folderTitle=").appendEncoded(context,folderTitle)
                    .append("&docType=").appendEncoded(context,docType)
                    .append("&docPolicy=").appendEncoded(context,docPolicy)
                    .append("&category=").appendEncoded(context,category)
                    .append("&contentRel=").appendEncoded(context,contentRel)
                    .append("&impactRel=").appendEncoded(context,impactRel)
                    .append("&folderType=").appendEncoded(context,folderType)
                    .append("&documentId=").append(docId)
                    .append("&fileName=").appendEncoded(context,fileName)
                    .append("&submitAction=doNothing")
                    .append("&checkIt=true")
                    .append("&postProcessURL=../simulationcentral/smaStructureBrowserUtil.jsp?action=refresh");
                    
                }
                else{
                contentURL
                    .append("../common/emxForm.jsp")
                    .append("?form=").append(formName)
                    .append("&formHeader=").append(header)
                    .append("&objectBased=false")
                    .append("&mode=edit")
                    .append("&suiteKey=SimulationCentral")
                    .append("&preProcessJPO=jpo.simulation.ImportExport:getDisplayValue")
                    .append("&postProcessJPO=").append(postProcessJPO)
                    .append("&xmlAttribute=attribute_Definition")
                    .append("&xmlRootTag=Simulation")
                    .append("&xmlTableTag=").append(tableTag)
                    .append("&xmlRowTag=Rule")
                    .append("&header=").append(formHeader)
                    .append("&HelpMarker=").append(helpMarker)
                    .append("&objectId=").append(objectId)
                    .append("&parentOID=").append(rootParentId)
                    .append("&titleSpec=").append(titleSpec)
                    .append("&docTitle=").appendEncoded(context,docTitle)
                    .append("&docType=").appendEncoded(context,docType)
                    .append("&docPolicy=").appendEncoded(context,docPolicy)
                    .append("&category=").appendEncoded(context,category)
                    .append("&contentRel=").appendEncoded(context,contentRel)
                    .append("&impactRel=").appendEncoded(context,impactRel)
                    .append("&documentId=").append(docId)
                    .append("&fileName=").appendEncoded(context,fileName)
                    .append("&submitAction=doNothing")
                    .append("&checkIt=true")
                    .append("&postProcessURL=../simulationcentral/smaStructureBrowserUtil.jsp?action=refresh");
                    /* if(objectAction.equalsIgnoreCase("createDeleteRule"))
                    {
                        contentURL.append("&objectId=").append(rootParentId);
                    } */
                     //...RKP Change
                     
                     /*if(dObj.isKindOf(context, "Simulation Category")){//EEF - pt6
                         contentURL
                              .append("&preProcessJavaScript=").append("smaEEFCheckboxCallBack_ContentCreate")
                              .append("&exportEmpty=true");
                     }*/
                } 
                }
            } 
        }
        
      
    }
    catch (Exception ex)
    {
        emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex, false));
    }


    // Check for error
    String errorMsg = emxNavErrorObject.toString().trim();
    if ( errorMsg != null && errorMsg.length() > 0 )
    {
        returnAction = "error";

        // For those commands whose target location is popup we must
        // handle the error message differently than if there is not a
        // popup.
        // For popups...
        // Open the utility jsp in the popup window which will then
        // send the XML return code to the listHidden frame.  In the
        // future, hopefully there will be a direct structure browser
        // function to call.
        // For non-popups...
        // Just return the appropriate XML string (non-popups target
        // location is listHidden)
        if ( isPopup )
        {
           errorMsg=XSSUtil.encodeForURL(context,errorMsg);

            contentURL
            .append( "../simulationcentral/smaStructureBrowserUtil.jsp")
            .append("?action=").append(returnAction)
            .append("&message=").append(errorMsg);
%>
<script language="javascript">
              getTopWindow().location.href = "<%=contentURL.toString()%>";
          </script>
<%
        }
        else
        {
            out.clear();
            response.setContentType("text/xml; charset=UTF-8");
%>
<mxRoot> <action><![CDATA[<%= returnAction %>]]></action> <message><![CDATA[<%= errorMsg   %>]]></message>
</mxRoot>
<%
        }
    }

    // No Errors!!!
    else
    {        
        if(isSlidein)
        { %>
<script language="javascript">
            getTopWindow().showSlideInDialog("<%=contentURL.toString()%>");       
            </script>
<%}
        // If action opened a popup window, use it
        else if (isPopup)
        {
%>
<script language="javascript">
                getTopWindow().location.href = "<%=contentURL.toString()%>";
            </script>
<%
        }
        // Return appropriate code for commands that don't open a window
        else
        {
            
                out.clear();
                response.setContentType("text/xml; charset=UTF-8");
%>
<mxRoot> <action><![CDATA[<%= returnAction %>]]></action> <message><![CDATA[<%= returnMsg   %>]]></message>
</mxRoot>

<%
            
        }
    }
%>


<%!


private void doViewAction(
        Context context, String parentOid, String objectId, URLBuilder contentURL)
    throws FrameworkException,
           MatrixException,
           UnsupportedEncodingException
{
    if (FileUtil.isFileId(objectId))
    {
        doViewFileAction(context, parentOid, objectId, contentURL);
    }
    else
    {
        doViewDocumentAction(context, parentOid, objectId, contentURL);
    }
}


/**
 * Opens the viewer for a file.
 */
private void doViewFileAction(
        Context context, String parentOid, String fileId, URLBuilder contentURL)
    throws FrameworkException,
           MatrixException,
           UnsupportedEncodingException
{
    contentURL.
        append("../components/emxCommonDocumentPreCheckout.jsp").
        append("?action=view").
        append("&isAppPreProcess=true").
        append("&appProcessPage=undefined");
    appendIdParamsToURL(context,contentURL, parentOid, fileId);
}


/**
 * Opens the viewer for a document.
 */
private void doViewDocumentAction(
    Context context, String parentOid, String objectId, URLBuilder contentURL)
    throws FrameworkException, MatrixException
{
    DomainObject obj = new DomainObject();
    obj.setId(objectId);

    matrix.db.FileList files = obj.getFiles(context);

    // If only 1 file is found, view it immediately
    // otherwise go to file list page to allow user to
    // pick which one to view from there
    if ( files.size() <= 1 )
    {
        contentURL.append(
            "../components/emxCommonDocumentPreCheckout.jsp")
            .append("?action=view")
            .append("&isAppPreProcess=true")//Setting for BPS processing - IR-199271V6R2014 - pt6
            .append("&appProcessPage=");
    }
    else
    {
        String docType =
            obj.getInfo(context, DomainConstants.SELECT_TYPE);
        boolean isVersionableType =
            CommonDocument.checkVersionableType(context, docType);

        if ( isVersionableType )
        {
            contentURL.append("../common/emxTable.jsp")
                .append("?program=emxCommonFileUI:getFiles")
                .append("&table=APPFileSummary")
                .append("&sortColumnName=Name");
        }
        else
        {
            contentURL.append("../common/emxTable.jsp")
                .append("?program=emxCommonFileUI")
                .append(":getNonVersionableFiles")
                .append("&table=APPNonVersionableFileSummary")
                .append("&sortColumnName=Name");
        }

        contentURL.append("&popup=true")
            .append("&sortDirection=ascending")
            .append("&header=emxComponents.Menu.Files")
            .append("&subHeader=emxComponents.Menu.SubHeaderDocuments")
            .append("&HelpMarker=emxhelpcommondocuments")
            .append("&suiteKey=Components")
            .append("&FilterFramePage=")
            .append("../components/emxCommonDocumentCheckoutUtil.jsp")
            .append("&FilterFrameSize=1");
    }

    contentURL.append("&objectId=").append(objectId);
}

private void setInputOutput(
    Context context, String parentId, String[] sRowIds,
    String objectAction, FrameworkException emxNavErrorObject)
{
    // Determine what user wanted to do
    boolean setInput = false;
    boolean setOutput = false;
    if (objectAction.equals("setToInput") )
        setInput = true;
    else if ( objectAction.equals("setToOutput") )
        setOutput = true;
    else if ( objectAction.equals("setToIO") )
    {
        setInput = true;
        setOutput = true;
    }

    try
    {
        Map inputMap = new HashMap();

        // Remove all but the object ids from selected elements array
        SimulationContentUtil.convertRowIds(sRowIds);

        // Set up param map with user choices
        inputMap.put("ParentOID", parentId);
        inputMap.put("ObjectIds", sRowIds);

        if (setInput)
            inputMap.put("SetInput", Boolean.TRUE);
        else
            inputMap.put("SetInput", Boolean.FALSE);

        if (setOutput)
            inputMap.put("SetOutput", Boolean.TRUE);
        else
            inputMap.put("SetOutput", Boolean.FALSE);

        // Create the relationships
        FrameworkException messages = (FrameworkException)
            JPO.invoke(context,
                "jpo.simulation.SimulationContent", new String[0],
                "setInputOutput", JPO.packArgs(inputMap),
                FrameworkException.class);

        if (messages != null
            && messages.getMessages().size() > 0)
        {
            emxNavErrorObject.addMessage(
                ErrorUtil.getMessage(messages, false));
        }
    }
    catch (Exception exJPO)
    {
        emxNavErrorObject.addMessage(ErrorUtil.getMessage(exJPO));
    }
}

private void addCategory(
    Context context, HttpServletRequest request, String objectId,
    URLBuilder contentURL, FrameworkException emxNavErrorObject)
{
    String sHelpMarker = emxGetParameter(request,"HelpMarker");
    String export = emxGetParameter(request, "export");
    String suiteKey = emxGetParameter(request, "suiteKey");
    String sPrinterFriendly = emxGetParameter(request, "PrinterFriendly");
    try
    {
        String catRelName =
            SimulationUtil.getSchemaProperty(
                SimulationConstants
                    .SYMBOLIC_relationship_SimulationCategory);

        String catTypeName =
            SimulationUtil.getSchemaProperty(
                SimulationConstants
                    .SYMBOLIC_type_SimulationCategory);

        // Get list of all possible categories
        StringList sCatNms = SimulationCategory.getCategoryNames(context);
        StringList categoriesToAdd = new StringList();
        categoriesToAdd.addAll(sCatNms);

        StringList selects = new StringList(1);
        selects.add(DomainConstants.SELECT_NAME);

        StringList currentCategories = SimulationCategory.getCurrentCatgories(context, objectId);
        categoriesToAdd.removeAll(currentCategories);

        String sParams = categoriesToAdd.toString();
        sParams = URLEncoder.encode(sParams);
        
        contentURL.append("../simulationcentral/smaAddCategoryFS.jsp")
            .append("?objectId=").append(objectId)
            .append("&categories=").append(sParams)
            .append("&helpMarker=").append(sHelpMarker)
            .append("&export=").append(export)
            .append("&suiteKey=").append(suiteKey)
            .append("&PrinterFriendly=").append(sPrinterFriendly);

    }
    catch (Exception ex)
    {
        emxNavErrorObject.addMessage(ErrorUtil.getMessage(ex));
    }
}



private static String[] getObjectIds(String[] rowIds)
{
    return SlmUIUtil.getObjectIdsFromRowIds(rowIds);
}


/**
 * Inspects the specified OID and appends it to the specified
 * {@link com.dassault_systemes.smaslm.matrix.web.URLBuilder} such'
 * that the parameters are correctly split if the OID represents a
 * file.
 * @param buf The
 * {@link com.dassault_systemes.smaslm.matrix.web.URLBuilder} to which
 * to append the parameters.
 * @param objectId The OID information to append to the specified
 * buffer.
 * @param Context
 */
private static URLBuilder appendIdParamsToURL(Context context,
        URLBuilder buf, String parentOid, String objectId)
    throws UnsupportedEncodingException
{
    // look for the start of the query string
    if (!buf.toString().contains("?"))
    {
        // if none, start the query string
        buf.append("?");
    }
    else
    {
        // already a query string => new parameter
        buf.append("&");
    }

    // append the objectId parameter
    buf.append("objectId=");
    if (!FileUtil.isFileId(objectId))
    {
        // if not a file just use the OID
        buf.append(objectId);
    }
    else
    {
        // get the document OID from the file ID
        String docOid = FileUtil.getObjectIdFromFileId(context,objectId);

        // if it does not match the parent, this is a versioned doc
        if (parentOid != null && !parentOid.equals(docOid))
        {
            // use the parent document OID
            docOid = parentOid;
        }

        // file => split and append the file ID components
        buf.append(docOid).
            append("&fileName=").
            appendEncoded(context,FileUtil.getFileNameFromFileId(context,objectId)).
            append("&format=").
            appendEncoded(context,FileUtil.getFileFormatFromFileId(context,objectId));
    }

    // return a reference to the buffer
    return buf;
}


%>

 
