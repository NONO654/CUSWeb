<%--
   emxCommonDocumentCheckout.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentCheckout.jsp.rca 1.26 Wed Apr  2 16:26:32 2008 przemek Experimental przemek $"
--%>
<!DOCTYPE html>
<%@page import="com.matrixone.client.fcs.FcsClient"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="emxComponentsUtil.inc"%>
<%@include file="emxComponentsNoCache.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxContentTypeInclude.inc"%>
<%@include file="emxComponentsAppletInclude.inc"%>
<%@ page import = "com.matrixone.apps.framework.ui.UIUtil"%>

<%
    //check if user is logged in then create FCS Variables
    if (!Framework.isLoggedIn(request)) {
        String loginPage = Framework.getPropertyValue("ematrix.login.page");
%>
        <!-- //XSSOK-->
        <jsp:forward page="<%=loginPage%>" />
<%
        return;
    }

    //create context variable for use in pages
    matrix.db.Context context = Framework.getFrameContext(session);
%>
  <html>
    <head>
      <script language="javascript" src="../common/scripts/emxUIModal.js" type="text/javascript"></script>
      <script type="text/javascript">
	     var callCloseWindow = false;
      // Here this method is added so that in <body onload="doSubmit();"> will get the reference of this method and
      // it wont throw the 'object expected' error if the checkout operation is performed more than once from the action menu.
      function doSubmit() {
          //do nothing
      }
      </script>
      <script language="javascript" src="../emxUIPageUtility.js" type="text/javascript"></script>
      <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css"/>
      <title>Download Progress</title>
    </head>
    <body class="download-progress" onLoad="doSubmit();">
<%
    Map emxCommonDocumentCheckoutData = (Map) session.getAttribute("emxCommonDocumentCheckoutData");
    String errorMessage = (String) emxCommonDocumentCheckoutData.get("error.message");
    String warningMessage = (String) emxCommonDocumentCheckoutData.get("warning.message");
    String objectId = (String) emxCommonDocumentCheckoutData.get("objectId");
    String portalMode = (String) emxCommonDocumentCheckoutData.get("portalMode");
    String portalFrame = (String) emxCommonDocumentCheckoutData.get("frameName");

    String[] objectIds = (String[]) emxCommonDocumentCheckoutData.get("objectIds");
    String action = (String) emxCommonDocumentCheckoutData.get("action");
    boolean multipleObjectIds = ((Boolean) emxCommonDocumentCheckoutData.get("multipleObjectIds")).booleanValue();
    //Added for Bug #371651 starts
    String customSortColumns = (String) emxCommonDocumentCheckoutData.get("customSortColumns");
    String customSortDirections = (String) emxCommonDocumentCheckoutData.get("customSortDirections");
    String uiType = (String) emxCommonDocumentCheckoutData.get("uiType");
    String table = (String) emxCommonDocumentCheckoutData.get("table");
    //Added for Bug #371651 ends
    boolean showPopup = true;
    String closeWindowErrorMessage = ComponentsUtil.i18nStringNow("emxComponents.CommonDocument.SuspendVersioningCheckout", sLanguage);
    String checkedoutConfirmMsg = EnoviaResourceBundle.getProperty(context,"emxComponentsStringResource",context.getLocale(),"emxComponents.Document.CheckedoutDocumentConfirmMessage");
    boolean override = true;
    String overrideStr = (String) emxCommonDocumentCheckoutData.get("override");
    if (overrideStr != null && "false".equalsIgnoreCase(overrideStr)) {
        override = false;
    }

	//IR-670955 : To retrieve flag values from URL
	//changes for AppletFree Download Structure for DEC operation.
	//we added flag as, isRequiredPath in URL parameter to set value for paths parameter.
	// Value for paths parameter is set to "null" to get all files in one folder ( no subfolder required).
	//This changes is down to open all structure in CAD Tool once downloaded.
	// This can be dependent on isRequiredPath flag(URL parameter)
	
	String isRequiredPath = (String)emxGetParameter(request, "isRequiredPath");
	
	//IR-670955 : END OF CODE
	
    boolean useDownloadApplet = false;
    String useDownloadAppletStr = (String) emxCommonDocumentCheckoutData.get("useDownloadApplet");

    if (useDownloadAppletStr != null && "true".equalsIgnoreCase(useDownloadAppletStr)) {
        useDownloadApplet = true;
    }

    String downloadErrorMessage = (errorMessage != null && !"".equals(errorMessage) && !"null".equals(errorMessage)) ? errorMessage :
                    (warningMessage != null && !"".equals(warningMessage) && !"null".equals(warningMessage)) ? warningMessage : null;
%>

<form action="javascript:closeAppletWindow()" method="post">
    <div id="emxDialogBody">
        <div id="progress">
            <h1><emxUtil:i18n localize="i18nId">emxComponents.CommonDownload.Downloading</emxUtil:i18n></h1>
            <p><emxUtil:i18n localize="i18nId">emxComponents.CommonDownload.DownloadingMessage</emxUtil:i18n></p>
        </div>

        <div id="error">
          <h2><emxUtil:i18n localize="i18nId"> emxComponents.CommonDownload.DownloadErrorHeader </emxUtil:i18n></h2>
          <p><emxUtil:i18n localize="i18nId"> <%=XSSUtil.encodeForHTML(context, downloadErrorMessage)%> </emxUtil:i18n></p>
          <p><BR/></p>
          <p><emxUtil:i18n localize="i18nId">emxComponents.Window.CloseMessage</emxUtil:i18n></p>
        </div>

        <div id="complete">
            <h1><emxUtil:i18n localize="i18nId">emxComponents.CommonDownload.DownloadComplete</emxUtil:i18n></h1>
            <p><emxUtil:i18n localize="i18nId">emxComponents.CommonDownload.DownloadCompleteMessage</emxUtil:i18n></p>
        </div>
    </div>
    <div id="emxDialogFoot">
        <div id ="closeButton" ><input type="submit" value="<emxUtil:i18n localize="i18nId">emxComponents.Button.Close</emxUtil:i18n>" /></div>
    </div>
</form>

<%
    if (errorMessage != null && !"".equals(errorMessage) && !"null".equals(errorMessage)) {
%>
        <script type="text/javascript">
            //Added for Bug #371651 starts
            var customSortColumns = "<%=XSSUtil.encodeForJavaScript(context, customSortColumns)%>";
            var customSortDirections = "<%=XSSUtil.encodeForJavaScript(context, customSortDirections)%>";
            var tblName = "<%=XSSUtil.encodeForJavaScript(context, table)%>";
            var uiType = "<%=XSSUtil.encodeForJavaScript(context, uiType)%>";
            //Added for Bug #371651 ends

            if (<%=XSSUtil.encodeForJavaScript(context, request.getParameter("refreshContent"))%>) {
                if (uiType != null && "Table" != uiType) {
                    if ( frameContent != null ) {
                        frameContent.document.location.href = frameContent.document.location.href;
                    } else {
                        getTopWindow().getWindowOpener().getTopWindow().document.location.href = getTopWindow().getWindowOpener().getTopWindow().document.location.href;
                    }
                } else {
                    var timeStamp = getTopWindow().getWindowOpener().document.forms['emxTableForm'].timeStamp.value;
                    getTopWindow().getWindowOpener().refreshTable(tblName,customSortColumns,customSortDirections,timeStamp,uiType);
                }
            }


            function closeAppletWindow() {
                getTopWindow().closeWindow();
            }
            window.resizeTo(550,350);
            document.body.className = "download-error";
        </script>
<%
    } else if (objectIds.length == 0) {
%>
        <script type="text/javascript">
            function closeAppletWindow() {
                getTopWindow().closeWindow();	
            }
            if(getTopWindow().getWindowOpener().getTopWindow().modalDialog) {
                getTopWindow().getWindowOpener().getTopWindow().modalDialog.releaseMouse();
            }
            window.resizeTo(550,350);
            document.body.className = "download-error";
        </script>
<%
    } else {
        if (UIUtil.isNullOrEmpty(objectId) && (objectIds != null && objectIds.length >= 0)) {
            objectId = objectIds[0];
        }
        String popupId = objectId;
        if (multipleObjectIds) {
            StringList masterSelects = new StringList(2);
            masterSelects.add(CommonDocument.SELECT_MASTER_ID);
            MapList mlist = DomainObject.getInfo(context, objectIds, masterSelects);
            Iterator itr = mlist.iterator();
            String firstId = "";
            String secondId = "";
            while (itr.hasNext()) {
                Map m = (Map) itr.next();
                firstId = (String) m.get(CommonDocument.SELECT_MASTER_ID);
                if (firstId == null) {
                    showPopup = false;
                    break;
                }

                if (!secondId.equals("") && !firstId.equals(secondId)) {
                } else {
                    secondId = firstId;
                }
            }
            if (showPopup && firstId != null) {
                popupId = firstId;
            }
        } else {
            //When only one file is selected to download and the selected file is locked we need to show popup
            //with all file summary table of Master doc to which this file is connected.
            //That we are doing only in case parentOID is passed in the checkout map
            String parentOID = (String) emxCommonDocumentCheckoutData.get("parentOID");
            if(parentOID != null && !"".equals(parentOID) && !"null".equalsIgnoreCase(parentOID)) {
                String materId = new com.matrixone.apps.domain.DomainObject(objectId).getInfo(context, CommonDocument.SELECT_MASTER_ID);
                if(parentOID.equals(materId)) {
                    popupId = materId;
                }
            }
        }
        // Modified for IR-048106V6R2011x -Starts
        // boolean versionable = CommonDocument.allowFileVersioning(context, popupId);
        boolean versionable;
        try {
            versionable = CommonDocument.allowFileVersioning(context, popupId);
        } catch (FrameworkException e) {
%>
            <jsp:forward page="../common/emxTreeNoDisplay.jsp" />
<%
        } catch (Exception ex) {
            throw ex;
        }
        // Modified for IR-048106V6R2011x -Ends
        errorMessage = (String) emxCommonDocumentCheckoutData.get("warning.message");
        String refreshStr = (String) emxCommonDocumentCheckoutData.get("refresh");
        String format = (String) emxCommonDocumentCheckoutData.get("format");
        String fileName = (String) emxCommonDocumentCheckoutData.get("fileName");
        String version = (String) emxCommonDocumentCheckoutData.get("version");
        String appName = (String) emxCommonDocumentCheckoutData.get("appName");
        String appDir = (String) emxCommonDocumentCheckoutData.get("appDir");
        String appProcessPage = (String) emxCommonDocumentCheckoutData.get("appProcessPage");
        String closeWindow = (String) emxCommonDocumentCheckoutData.get("closeWindow");
        String zipOutput = (String) emxCommonDocumentCheckoutData.get("zipOutPut");
        String sLock = "false";
        String ematrix = Framework.getPagePathURL("");
        String noOfObjects = (String) emxCommonDocumentCheckoutData.get("noOfObjects");
        if (action == null) {
            action = "download";
        }

        if (UIUtil.isNullOrEmpty(closeWindow)) {
            closeWindow = "true";
        }

        boolean refresh = "true".equalsIgnoreCase(refreshStr);
        if (UIUtil.isNullOrEmpty(refreshStr)) {
            refresh = true;
        }

        if (UIUtil.isNullOrEmpty(portalMode)) {
        	portalMode = "false";
        }

        int interval = session.getMaxInactiveInterval();
        int maxInterval = Integer.parseInt((String) EnoviaResourceBundle.getProperty(context,"emxFramework.ServerTimeOutInSec"));
        if (interval != maxInterval) {
            session.setMaxInactiveInterval(maxInterval);
            session.setAttribute("InactiveInterval", new Integer(interval));
        }
        StringList lockedIds = new StringList();
        Map checkoutMap = new HashMap();
        String actionCommand = null;
        if (override && versionable) {
          CommonDocumentable commonDocument = (CommonDocumentable) DomainObject.newInstance(context, objectId);
          if (action.equals("download")) {
            actionCommand = commonDocument.getDownloadCommand(context);
          } else if (action.equals("checkout")) {
            actionCommand = commonDocument.getCheckoutCommand(context);
          }
        }
        if (actionCommand != null) {
            Map commandMap = UICache.getCommand(context, actionCommand);
            String actionURL = UIMenu.getHRef(commandMap);
%>
            <form name="integration" action="<%=XSSUtil.encodeForHTML(context, actionURL)%>">
                <table>
<%
                java.util.Set set = emxCommonDocumentCheckoutData.keySet();
                Iterator itr = set.iterator();
                // Loop through the request elements and stuff into emxCommonDocumentCheckinData
                while (itr.hasNext()) {
                    String name = (String) itr.next();
                    Object value = (Object) emxCommonDocumentCheckoutData.get(name);
%>
                    <input type="hidden" name="<xss:encodeForHTMLAttribute><%=name%></xss:encodeForHTMLAttribute>" value="<xss:encodeForHTMLAttribute><%=value%></xss:encodeForHTMLAttribute>" />
<%
                }
%>
                </table>
            </form>
            <script language="javascript" type="text/javascript">
                document.integration.submit();
            </script>
<%
        } else {
            boolean shouldSubmitPageForCheckOut = true;

            CommonDocument commonDocument = (CommonDocument) DomainObject.newInstance(context, CommonDocument.TYPE_DOCUMENTS);
            commonDocument.setId(objectId);
            if (isDSFAObjectType(context, commonDocument)) {
                commonDocument = (CommonDocument) DomainObject
                    .newInstance(context, objectId, null, CommonDocument.INTERFACE_VC_DOCUMENT);
            }
            if (!UIUtil.isNullOrEmpty(fileName) && !UIUtil.isNullOrEmpty(format)) {
                checkoutMap = ((CommonDocument) commonDocument).checkout(context, action, fileName, format, version);
          } else {
                java.util.List oids = Arrays.asList(objectIds);
                checkoutMap = CommonDocument.checkout(context, oids, action);
          }

          objectIds = (String[]) checkoutMap.get(CommonDocument.CHECKOUT_OBJECT_IDS);
          String[] fileNames = (String[]) checkoutMap.get(CommonDocument.CHECKOUT_FILE_NAMES);
          String[] formats = (String[]) checkoutMap.get(CommonDocument.CHECKOUT_FORMATS);
          String[] locks = (String[]) checkoutMap.get(CommonDocument.CHECKOUT_LOCKS);
          String[] paths = (String[]) checkoutMap.get(CommonDocument.CHECKOUT_PATHS);
          String[] versions = (String[]) checkoutMap.get(CommonDocument.CHECKOUT_VC_VERSIONS);
          StringList hasCheckoutAccess = (StringList)checkoutMap.get(CommonDocument.CHECKOUT_ACCESS);
          long[] vcIndexs = (long[]) checkoutMap.get(CommonDocument.CHECKOUT_VC_INDEXS);
          String zipName = (String) checkoutMap.get(CommonDocument.CHECKOUT_ZIP_NAME);

          lockedIds = (StringList) checkoutMap.get(CommonDocument.CHECKOUT_LOCKED_IDS);
          String errorPage = "/" + appDirectory + "/emxComponentsError.jsp";
          String error = (String) checkoutMap.get(CommonDocument.CHECKOUT_ERROR_MESSAGE);

          if (error != null && error.indexOf(",") > 0) {
				session.removeAttribute("downloadInProgress-"+customSortColumns+"-"+fileName);
                shouldSubmitPageForCheckOut  = false;
                Iterator itr = lockedIds.iterator();
                while (itr.hasNext()) {
                    String oid = (String) itr.next();
                    DomainObject doc = DomainObject.newInstance(context, oid);
                    doc.unlock(context);
                }
                if (showPopup) {
                    String url = ematrix;
                    if (versionable) {
                        url += "common/emxTable.jsp?objectId="
                            + XSSUtil.encodeForURL(context, popupId)
                            + "&program=emxCommonFileUI:getFiles&table=APPFileSummary&sortColumnName=Name&"
                            + "sortDirection=ascending&header=emxComponents.Menu.Files&subHeader=emxComponents.Menu.SubHeaderDocuments&popup=true"
                            + "&HelpMarker=emxhelpdocumentfilelist&suiteKey=Components&FilterFramePage=../components/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1";
                    } else {
                        url += "common/emxTable.jsp?objectId="
                            + XSSUtil.encodeForURL(context, popupId)
                            + "&program=emxCommonFileUI:getNonVersionableFiles&table=APPNonVersionableFileSummary&sortColumnName=Name&"
                            + "sortDirection=ascending&header=emxComponents.Menu.Files&subHeader=emxComponents.Menu.SubHeaderDocuments&popup=true"
                            + "&HelpMarker=emxhelpdocumentfilelist&suiteKey=Components&FilterFramePage=../components/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1";
                    }
%>
                    <script language="javascript" type="text/javascript">
                        if(confirm("<%=checkedoutConfirmMsg%>")){
                        //XSSOK
                        showModalDialog("<%=url%>" , 875, 525, true);
                        }
                    </script>
<%
                } else {
                    //session.putValue("error.message", closeWindowErrorMessage);
%>
                    <script language="javascript" type="text/javascript">
                    	alert("<%=closeWindowErrorMessage%>");//XSSOK
                        if ( frameContent != null ) {
                            frameContent.document.location.href = frameContent.document.location.href;
                        } else {
                            getTopWindow().getWindowOpener().getTopWindow().document.location.href = getTopWindow().getWindowOpener().getTopWindow().document.location.href;
                        }
                        getTopWindow().closeWindow();
                    </script>
<%
                }
            }

            if(shouldSubmitPageForCheckOut) {
                boolean zipOutPut = true;
                if (!UIUtil.isNullOrEmpty(zipOutput)) {
                    zipOutPut = (new Boolean(zipOutput)).booleanValue();
                } else if (objectIds.length == 1 && !multipleObjectIds) {
                    zipOutPut = false;
                }
                if (zipName != null) {
                    zipName = zipName + ".zip";
                }
                //300034 - Modified below method signature and passed one extra parameter to unlock the objects
                // in case checkout is failed.
            // allow file sync only if the context user has checkout access
            if (!hasCheckoutAccess.contains("FALSE")) {
            	try{
					//IR-670955: changes for AppletFree Download Structure for DEC operation.
					// Value for paths parameter is set to "null" to get all files in one folder ( no subfolder required).
					//This changes is down to open all structure in CAD Tool once downloaded.
					// This can be dependent on isRequiredPath flag(URL parameter)
					
            		if("false".equalsIgnoreCase(isRequiredPath))
					{
						checkoutMap = getFileStreamURL(context, request, response, objectIds,
                                            fileNames, formats, locks, vcIndexs, versions, null,
                                            zipOutPut, zipName, errorPage, action, lockedIds);
					}
					else
                checkoutMap = getFileStreamURL(context, request, response, objectIds,
                                            fileNames, formats, locks, vcIndexs, versions, paths,
                                            zipOutPut, zipName, errorPage, action, lockedIds);
            	} finally
            	{
        	        interval = session.getMaxInactiveInterval();
        	        maxInterval = Integer.parseInt((String)EnoviaResourceBundle.getProperty(context,"emxFramework.ServerTimeOutInSec"));
        	        if( interval == maxInterval )
        	        {
        		  	    if(session.getAttribute("InactiveInterval")!=null)
        		  	    {
        		  			interval = ((Integer)session.getAttribute("InactiveInterval")).intValue();
        		  			session.setMaxInactiveInterval(interval);
        		  		}
        	        }
            	}
            } else {
                String checkoutAccessError = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource",context.getLocale(), "emxComponents.FileDownload.NoCheckOutAccess");
                throw new Exception(checkoutAccessError);
            }
          }
            if (checkoutMap == null) {
                shouldSubmitPageForCheckOut  = false;
                Iterator itr = lockedIds.iterator();
                while (itr.hasNext()) {
                    String oid = (String) itr.next();
                    DomainObject doc = DomainObject.newInstance(context, oid);
                    doc.unlock(context);
                }
                if (showPopup) {
                    String url = ematrix;
                    if (versionable) {
                        url += "common/emxTable.jsp?objectId="
                            + XSSUtil.encodeForURL(context, popupId)
                            + "&program=emxCommonFileUI:getFiles&table=APPFileSummary&sortColumnName=Name&"
                            + "sortDirection=ascending&header=emxComponents.Menu.Files&subHeader=emxComponents.Menu.SubHeaderDocuments&popup=true"
                            + "&HelpMarker=emxhelpdocumentfilelist&suiteKey=Components&FilterFramePage=../components/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1";
                    } else {
                        url += "common/emxTable.jsp?objectId="
                            + XSSUtil.encodeForURL(context, popupId)
                            + "&program=emxCommonFileUI:getNonVersionableFiles&table=APPNonVersionableFileSummary&sortColumnName=Name&"
                            + "sortDirection=ascending&header=emxComponents.Menu.Files&subHeader=emxComponents.Menu.SubHeaderDocuments&popup=true"
                            + "&HelpMarker=emxhelpdocumentfilelist&suiteKey=Components&FilterFramePage=../components/emxCommonDocumentCheckoutUtil.jsp&FilterFrameSize=1";
                    }
%>
                    <script language="javascript" type="text/javascript">
                    //XSSOK    
                    showModalDialog("<%=url%>" , 875, 525, true);
                    </script>
<%
                } else {
                    session.putValue("error.message", closeWindowErrorMessage);
%>
                    <script language="javascript" type="text/javascript">
                    if ( frameContent != null ) {
                        frameContent.document.location.href = frameContent.document.location.href;
                    } else {
                        getTopWindow().getWindowOpener().getTopWindow().document.location.href = getTopWindow().getWindowOpener().getTopWindow().document.location.href;
                    }
                    getTopWindow().closeWindow();
                    </script>
<%
                }
            } else if (shouldSubmitPageForCheckOut) {
                String actionURL = (String) checkoutMap.remove("action");
                // IR-260227V6R2014x: fcs applet dies if a pathname
                // appended to the url has encoded "/", decode it.
                String actionURLPath = actionURL.substring(0, actionURL.lastIndexOf("/")); 
                actionURL = XSSUtil.decodeFromURL(actionURLPath) + "/" + actionURL.substring(actionURL.lastIndexOf("/")+1, actionURL.length());
                String ticket = (String) checkoutMap.remove("ticket");
                HashMap hash = new HashMap(checkoutMap);
                String target = "";

            	session.removeAttribute("downloadInProgress-"+customSortColumns+"-"+fileName);
                if (useDownloadApplet) {
                    String  systemDefaultCheckoutFolder   = FrameworkProperties.getProperty(context,"emxFramework.DefaultCheckoutDirectory");
                    String userDefaultCheckoutFolder = PropertyUtil.getAdminProperty(context, DomainConstants.TYPE_PERSON, context.getUser(), "preference_DefaultCheckoutDirectory");

                    if (UIUtil.isNullOrEmpty (userDefaultCheckoutFolder)) {
                        userDefaultCheckoutFolder = systemDefaultCheckoutFolder;
                    }
                    userDefaultCheckoutFolder = FrameworkUtil.findAndReplace (userDefaultCheckoutFolder , "\\", "\\\\");

                    HashMap props = new HashMap();
                    props.put("jobTicket", ticket);
                    props.put("fcsURL", actionURL);
                    props.put("refresherURL",Framework.getFullClientSideURL(request,response,""));
                    props.put("outDir", userDefaultCheckoutFolder);
                    props.put("debug", "true");
                    props.put("java_status_events", "true");
                    props.put("action",action);
                    String firstLang = sLanguage.split(",")[0];
                    String locale = firstLang.split("-")[0];
                    props.put("locale", locale);

                    addApplet(request, response, out, context, "com.matrixone.fcs.applet.FileDownloadApplet", 1, 1, props);
%>

                    <script>
                    // IR-158505: Define this variable only in case of Applet. The pop will be closed only in this case.
                    var callCloseWindow = true;

                        function doSubmit()
                        {
                            var applet = getApplet();
                            applet.doWork();
                            var frameContent = openerFindFrame(getTopWindow(), "detailsDisplay");

                            frameContent = frameContent == null ? openerFindFrame(getTopWindow(), "listDisplay"): frameContent;
                            frameContent = frameContent == null ? openerFindFrame(getTopWindow(), "content"): frameContent;
                            if (frameContent != null) {
                                frameContent.location.href = frameContent.location.href;
                            } else {
                                getTopWindow().location.href = getTopWindow().location.href;
                            }
                        }
                    </script>
<%
                } else {
%>
                    <script>
                        function doSubmit() {
                            var appProcessPage =  "<%= XSSUtil.encodeForJavaScript(context, appProcessPage) %>";
                            setTimeout("refreshPage()", 500);
                            document.body.className = "download-complete";
                            document.checkout.submit();
                            if (appProcessPage != "undefined" && appProcessPage.length > 0) {
                                setTimeout("closeAppletWindow()", 500);
                            }
                        }

                        function refreshCaller() {
                            frameContent.document.location.href = frameContent.document.location.href;
                        }
                    </script>

                    <form name="checkout" method="post" action="<%=XSSUtil.encodeForHTML(context, actionURL)%>" target="<%=XSSUtil.encodeForHTML(context, target)%>">
<%
                        if (ticket != null) {
%>
                            <input type="hidden" name="<%=FcsClient.resolveFcsParam("jobTicket")%>" value="<xss:encodeForHTMLAttribute><%=ticket%></xss:encodeForHTMLAttribute>" />
<%
                        }
                        Iterator iter = hash.keySet().iterator();
                        while (iter.hasNext()) {
                            String name = (String) iter.next();
                            String value = (String) hash.get(name);
%>
                            <input type="hidden" name="<%=XSSUtil.encodeForHTML(context, name)%>" value="<xss:encodeForHTMLAttribute><%=value%></xss:encodeForHTMLAttribute>"></input>
<%
                        }
%>
                    </form>
<%
                }
                //this method create the download objects if not exist otherwise, and Create a connection between Download and Document Object.
                if(Download.isTrackDownloadOn(context)) {
                    String strPartId = emxGetParameter(request, "trackUsagePartId");
                    if(strPartId != null) {
                        Download.create(context, strPartId, emxCommonDocumentCheckoutData);
                    }
                }

                if ( appProcessPage == null )
                    appProcessPage = "";
%>
                <script language="javascript" type="text/javascript">
                    function closeAppletWindow() {
                        var appProcessPage =  "<%= XSSUtil.encodeForJavaScript(context, appProcessPage) %>";
                        var refreshURL = "../<%= XSSUtil.encodeForURL(context, appDir) %>/<%= XSSUtil.encodeForURL(context, appProcessPage) %>"+'?actionMode='+"<%=XSSUtil.encodeForURL(context, action)%>";
                        // To allow checkout to return information to a structure browser, if a SB URL has been passed in
                        // then load it into the listHidden frame
                        if (appProcessPage != "undefined" && appProcessPage.length > 0) {
                            var listHidden = null;
                            if (getTopWindow().getWindowOpener()) {
                                  listHidden = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"listHidden");
                            } else {
                                listHidden = findFrame(getTopWindow(),"listHidden");
                            }
                            if (listHidden != null) {
                                listHidden.location.href = refreshURL;
                            }
                        }
                        // IR-158505: Call getTopWindow().close() only if callCloseWindow is defined and set to true (only in case of applet)
                        if (typeof(callCloseWindow) != "undefined") {
                            if (callCloseWindow) {
                                getTopWindow().closeWindow();
                            }
                        } else {
                            if (getTopWindow().getWindowOpener() && getTopWindow() == self){
                                getTopWindow().closeWindow();
                            }
                        }
                    }

                    function refreshPage() {
                        var action= "<%=XSSUtil.encodeForJavaScript(context, action) %>";
                        //XSSOK
                        var refresh = <%=refresh%>;
                        var portalMode = <%= XSSUtil.encodeForJavaScript(context,portalMode)%>;

                        var postProcessPage = "<%= XSSUtil.encodeForJavaScript(context, appProcessPage) %>";
                        if ("checkout" == action && refresh) {
                            if (portalMode) {
                            	//XSSOK
                                var frameContent = findFrame(getTopWindow(), "<%=portalFrame%>");
                            } else {
                                var frameContent = findFrame(getTopWindow(), "detailsDisplay");
                                frameContent = frameContent == null ? findFrame(getTopWindow(), "listDisplay"): frameContent;
                                frameContent = frameContent == null ? findFrame(getTopWindow(), "content"): frameContent;
                            }

                            if (frameContent != null ) {
                                var refreshURL = frameContent.location.href;
                            	refreshURL = refreshURL.replace("persist=true","");
                            	frameContent.location.href=refreshURL;
                            } else {
                                var refreshURL = getTopWindow().location.href;
                				refreshURL = refreshURL.replace("persist=true","");
                				getTopWindow().location.href = refreshURL;
                            }
                        }
                    }
<%
                    if ("hiddenFrame".equals(target)) {
%>
                        getTopWindow().closeWindow();
<%
                    }
                }
%>
                </script>
<%
            }
        }
%>
    </body>
</html>


<%!
public static Map getFileStreamURL(Context context, HttpServletRequest request,
                                            HttpServletResponse response,
                                            String[] objectIds,
                                            String[] fileNames,
                                            String[] formats,
                                            String[] locks,
                                            long[] vcIndexs,
                                            String[] versions,
                                            String[] paths,
                                            boolean zipOutput,
                                            String outFileName,
                                            String errorPage,
                                            String action,
                                            StringList lockedIds) throws FrameworkException {
    Map checkoutMap = new HashMap();
    try {
        double rndNum = java.lang.Math.random();
        if ( action == null ) {
            action = "download";
        }
        checkoutMap = DocumentUtil.checkout(context, objectIds,
                                    fileNames, formats,
                                    locks, vcIndexs, versions, paths, zipOutput, outFileName, errorPage, request, response);
        if (!action.equals("view")) {
            checkoutMap.put(com.matrixone.fcs.mcs.McsBase.resolveFcsParam("attachment"), "true");
        }
        checkoutMap.put("noCache", new Double(rndNum).toString());
        return checkoutMap;
    } catch(Exception e) {
        //Bug 300034 - Added below code to unlock objects
        DomainObject domainObj = DomainObject.newInstance(context);
        Iterator idItr = lockedIds.iterator();
        while (idItr.hasNext()) {
            String oid = (String) idItr.next();
            domainObj.setId(oid);
            try {
                if(domainObj.isLocked(context)) {
                    domainObj.unlock(context);
                }
            } catch(Exception mxe) {}
        }
        e.printStackTrace();
        throw new FrameworkException(e);
    }
}

public static boolean isDSFAObjectType(Context context, CommonDocument cdoc) {
    try {
        if (cdoc.isKindOf(context, CommonDocument.TYPE_DOCUMENTS))
            return true;

        // IR-122973V6R2013 the HDM Product types are also downoadable
        String typeProduct = PropertyUtil.getSchemaProperty(context, "type_Products");
        if (cdoc.isKindOf(context, typeProduct))
            return true;

        return false;

    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}

%>

