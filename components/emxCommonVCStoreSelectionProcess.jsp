<%--
  emxCommonVCStoreSelectionProcess.jsp

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxCommonVCStoreSelectionProcess.jsp.rca 3.1 Dec 14 2012 fzz $
--%>


<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsUtil.inc"%>
<%@page import  = "com.matrixone.apps.common.VCDocument"%>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%!
public static void Trace (String msg) {
    final String prefix = "[SelectionProcess.jsp] ";
    System.out.println(prefix.concat(msg));
}
public static void Trace (int line) {
    Trace("@" + line);
}
public static void Trace (int line, String ... msg) {
    String out =  "@" + line;
    for (String m : msg)
        out += " " + m;
    Trace(out);
}

// unlike getQueryString this handles both, GET and POST methods
public void ShowParameters (HttpServletRequest request) {
   Trace("Request parameters, method=" + request.getMethod());
   Enumeration paramNames = request.getParameterNames();
   while (paramNames.hasMoreElements()) {
      String paramName = (String)paramNames.nextElement();
      String[] paramValues = request.getParameterValues(paramName);
      int count = paramValues.length;
      if (count == 0) {
          System.out.println (paramName + " <empty>");
      } else if (count == 1) {
          System.out.println (paramName + " = " + paramValues[0]);
      } else {
          System.out.println (paramName + " is an array:");
          for (int i=0; i < count; i++)
             System.out.println (paramName + "["+i+"] = " + paramValues[i]);
      }
   }
   System.out.println ("--- Finished printing Request parameters ---\n");
}
%>

<%
    //ShowParameters(request);
    String languageStr = request.getHeader("Accept-Language");
    String objectId = emxGetParameter(request, "objectId");
    String fromPage = emxGetParameter(request, "fromPage");
    String objectAction = emxGetParameter(request,"objectAction");
    String parentId = emxGetParameter(request,"parentOID");
    String emxTableRowId = emxGetParameter(request,"emxTableRowId");
    String formName = emxGetParameter(request,"formName");
    String fieldNameActual = emxGetParameter(request,"fieldNameActual");
    String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
    String storePath = emxGetParameter(request,"storePath");
    String customMode = emxGetParameter(request,"customMode");
    String dsfaTag = emxGetParameter(request,"dsfaTag");
    String allowedTypes = emxGetParameter(request,"allowedTypes");
    String selectedPath = "";

    if (languageStr == null || languageStr.isEmpty()) {
        languageStr = context.getSession().getLanguage();
    }

    String DS_SELECTOR = "DSFA:Latest";
    // In HDM dsfa tags are undesirable
    if (dsfaTag != null && dsfaTag.equalsIgnoreCase("no")) {
        DS_SELECTOR = "Trunk:Latest";
    }

    // If no allowedTypes given, allow all.
    if (allowedTypes == null) {
        allowedTypes = "";
    }

%>

<script language="javascript"  type="text/javascript">
function handleHDMImport(formname, path, selector) {
    var theForm = eval ("getTopWindow().getWindowOpener().document." + formname);

    // mind hidden fields?
    theForm.Path.value = path;
    theForm.Selector.value = selector;
    getTopWindow().closeWindow();
}

function handleConnectOrConvertVcFileFolder(formname, _path, _selector, fileOrFolder, radioEntry) {
    var theForm = eval ("getTopWindow().getWindowOpener().document." + formname);

    with (theForm) {
        if(path != "undefined"){
            path.value = _path;
        }
        if(selector != "undefined"){
            selector.value = _selector;
        }
        if(vcDocumentType != "undefined"){
            vcDocumentType.value = fileOrFolder;
        }

        if (fileOrFolder == "module" || fileOrFolder == "version" || fileOrFolder == "branch") {
            if (typeof(theForm.format) != 'undefined') {
                format.disabled = true;
            }
        }
        if (radioEntry != -1)
            vcDocumentTmp[radioEntry].checked = true;

    }

    getTopWindow().closeWindow();
}

function handleDefaultForm(_path, _selector, fileOrFolder, radioEntry) {
    with (getTopWindow().getWindowOpener().document.frmMain) {
        path.value = _path;
        selector.value = _selector;
        vcDocumentType.value = fileOrFolder;

        if (fileOrFolder == "module" || fileOrFolder == "version" || fileOrFolder == "branch") {
            if (typeof(getTopWindow().getWindowOpener().document.frmMain.format) != 'undefined')
                format.disabled = true;
        }
        if (radioEntry != -1)
            vcDocumentTmp[radioEntry].checked = true;
    }

    getTopWindow().closeWindow();
}

</script>

<%
    // if we don't have a selection display error message and return
    if (emxTableRowId == null || "".equals(emxTableRowId)) {
        %>
          <script language="Javascript">
            alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.NoFileFolderSelected</emxUtil:i18nScript>");
          </script>
        <%
        return;
    }

    String folderPath = "";
    String fileOrFolder = "";
    String path = "";
    String filePath = "";
    String versionId = "";
    String selector = "";
    String modulePath = "";
    String moduleName = "";

    StringTokenizer strtk1 = new StringTokenizer(emxTableRowId,"|");
    String tokenString = strtk1.nextToken();

    if (tokenString.contains("$")) {
        StringTokenizer strtk = new StringTokenizer(tokenString,"$");
        fileOrFolder = strtk.nextToken();

        // make sure we have a legitimate selection type
        String selectionError = "";
        if (fileOrFolder.equalsIgnoreCase("category")) {
            selectionError = "emxComponents.VCDocument.CategoryNotAllowed";
        } else if (fileOrFolder.equalsIgnoreCase("branch")) {
            selectionError = "emxComponents.VCDocument.OperationNotAllowed";
        } else if (fileOrFolder.equalsIgnoreCase("href")) {
            selectionError = "emxComponents.VCDocument.HrefNotAllowed";
        } else if(!checkAllowedTypes(fileOrFolder, allowedTypes)) {
            // In this case, see if there is a specific message based on the
            // allowed types, else pick a generic one.
            selectionError = "emxComponents.VCDocument.TypeNotAllowed."+allowedTypes;
            String emsg2 = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), selectionError);
            if (emsg2.equals(selectionError))
                selectionError = "emxComponents.VCDocument.TypeNotAllowed.generic";
        }

        // for non-supported type display error message and return
        // NOTE: We close the window. That is annoying for the user, but
        // if we don't then the browser doens't allow another object to be
        // selected anyway: it complains the last operation is still in progress.
        if (!selectionError.isEmpty()) {
            String emsg = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), selectionError);
            %>
              <script language="Javascript">
                  alert("<%=XSSUtil.encodeForJavaScript(context, emsg)%>");
                  getTopWindow().closeWindow();
              </script>
            <%
            return;
        }

        if (matchesOneOf(fileOrFolder, "file","folder")) {
            selector = "Trunk:Latest";
        } else {
            selector = DS_SELECTOR;
        }

        strtk.nextToken();

        if (matchesOneOf(fileOrFolder, "module","version","branch","href")) {
            modulePath = strtk.nextToken();
            moduleName = strtk.nextToken();
            strtk.nextToken();
        } else {
            folderPath = strtk.nextToken();
        }

        if ("file".equalsIgnoreCase(fileOrFolder)) {
            filePath = strtk.nextToken();
        }

        objectId = strtk.nextToken();

        String strPath = "";
        String strBranch = "";
        String strVersion = "";

        if ("version".equalsIgnoreCase(fileOrFolder)
                && objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER)) {
            selectedPath = strtk.nextToken();
            strPath = selectedPath.substring(0,selectedPath.lastIndexOf("/"));
            strVersion = selectedPath.substring(selectedPath.lastIndexOf("/")+1,selectedPath.length());
            strBranch = strPath.substring(strPath.lastIndexOf("/")+1,strPath.length());
            selector = strVersion;
        } else if ("module".equalsIgnoreCase(fileOrFolder)
                    && objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER)) {
            moduleName = strtk.nextToken();
        }

        if ("version".equalsIgnoreCase(fileOrFolder)
                && objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC)) {
            selectedPath = strtk.nextToken();
            strPath = selectedPath.substring(0,selectedPath.lastIndexOf("/"));
            strVersion = selectedPath.substring(selectedPath.lastIndexOf("/")+1,selectedPath.length());
            strBranch = strPath.substring(strPath.lastIndexOf("/")+1,strPath.length());
            selector = strVersion;
        } else if ("module".equalsIgnoreCase(fileOrFolder)
                    && objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC)) {
            // strPath = selectedPath.substring(0,selectedPath.lastIndexOf("/"));
            moduleName = strtk.nextToken();
        }

        if ( "file".equalsIgnoreCase(fileOrFolder)) {
            versionId = strtk.nextToken();
            selector = versionId;
        }

    } // tokenString contains "$"


    if ("None".equalsIgnoreCase(folderPath)) {
        folderPath = "";
    }

    if (matchesOneOf(fileOrFolder, "file","folder")) {
        if (fileOrFolder.equalsIgnoreCase("file")) {
            path += "/" + folderPath + "/" + filePath;
            StringTokenizer newstrtk1 = new StringTokenizer(versionId,".");
            int nooftokens = newstrtk1.countTokens();
            if (versionId.equalsIgnoreCase("Blank") || (nooftokens % 2) !=0) {
                %>
                  <script language="javascript" type="text/javascript">
                    alert("<emxUtil:i18nScript localize="i18nId">emxComponents.VCDocument.TrunkBranchActions</emxUtil:i18nScript>");
                  </script>
                <%
                return;
            }
        } else {
            path += "/" + folderPath;
        }
        path = VCDocument.processSyncUrlData(context, path);
        selector = VCDocument.processSelector(context, selector);
    } else if (matchesOneOf(fileOrFolder, "module","version","branch","href")) {
        path = moduleName;
        if (path.equals(" ")) {
            // path=selectedPath.substring(0,selectedPath.indexOf("/"));
            path=".";
        }
        // IR-195627V6R2014
        if (fileOrFolder.equalsIgnoreCase("version")) {
        	path = selectedPath.replaceFirst("/[0-9.]+$", "");
        }
    }

    if ("folder".equalsIgnoreCase(fileOrFolder) && (objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
         objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER)) &&
         (storePath.equals("/") || storePath.equals("")) && folderPath.equals("Modules"))
      {
          fileOrFolder="module";
          path="Modules/";
          selector = DS_SELECTOR;
      }


    // Work out the radio field entry to update.
    // Do this in the Java section and pass to the JavaScript function later.
    // Must do as late as possible, so code above can adjust the type if needed.
    int radioEntry = getRadioEntry(fileOrFolder, allowedTypes);

    if ((objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER))
        && (formName!=null) && (formName.length()>0))
    {
        // to make this jsp more versatile we support custom handlers.
        // a custom java or js function can be added as necessary, and will
        // be invoked if the caller passed the appropriate customMode parameter
        // note that each of these js functions close the window in the end.
        if (customMode != null && !customMode.trim().isEmpty()) {
            // add new customMode handlers as needed
            if (customMode.equals("hdmImport")) {
            %>
                <script language="javascript" type="text/javascript">
                    handleHDMImport("<%=XSSUtil.encodeForJavaScript(context, formName)%>", "<%=XSSUtil.encodeForJavaScript(context, path)%>", "<%=XSSUtil.encodeForJavaScript(context, selector)%>");
                </script>
            <%
            }
        }

        // if this wasn't a custom call invoke the regular action handler
        %>
         <script language="javascript" type="text/javascript">
            handleConnectOrConvertVcFileFolder("<%=XSSUtil.encodeForJavaScript(context, formName)%>", "<%=XSSUtil.encodeForJavaScript(context, path)%>", "<%=XSSUtil.encodeForJavaScript(context, selector)%>", "<%=XSSUtil.encodeForJavaScript(context, fileOrFolder)%>", <%=radioEntry%>);
         </script>
        <%

    } else {
        // formName wasn't given, assume the default form process
        %>
         <script language="javascript" type="text/javascript">
             handleDefaultForm("<%=XSSUtil.encodeForJavaScript(context, path)%>", "<%=XSSUtil.encodeForJavaScript(context, selector)%>", "<%=XSSUtil.encodeForJavaScript(context, fileOrFolder)%>", <%=radioEntry%>);
         </script>
        <%
    }

%>

<%!
/**
* matchesOneOf - case insensitive string match
* @param str - string to be matched
* @param values - var string args to compare against
* @returns boolean indicating whether str matches one of the values
*/
static boolean matchesOneOf(String str, String ... values) {
    if (values != null) {
        for (String val : values) {
            if (str.equalsIgnoreCase(val))
                return true;
        }
    }

    return false;
}

/**
 * checkAllowedTypes - check the type selected is one that the calling form
 *    supports
 * @param type - type of object user selected
 * @param allowedTypes - comman separated list of type allowed, must
 *    be subset of file, folder and module and must match the order of
 *    the items in the radio buttons for the type.
 */
static boolean checkAllowedTypes(String type, String allowedTypes) {
    if ((allowedTypes==null) || allowedTypes.isEmpty())
        return true;
    // Map version and branch to module for these purposes.
    // This matches how the map to the radio buttons is done below,
    // though in theory branch could not be supplied, as that type
    // is forbidden earlier in the process.
    if ("version".equals(type) || "branch".equals(type))
        type = "module";
    for (String val : allowedTypes.split(",")) {
        if (type.equals(val))
            return true;
    }
    return false;
}

/**
 * getRadioEntry - gets the radio button index for the selected type
 *    supports. If there i only one type returns -1 as assume there is
*   no radio button in that case.
 * @param type - type of object user selected
 * @param allowedTypes - comman separated list of type allowed, must
 *    be subset of file, folder and module and must match the order of
 *    the items in the radio buttons for the type.
 */
static int getRadioEntry(String type, String allowedTypes) {
    if ((allowedTypes==null) || allowedTypes.isEmpty())
        allowedTypes = "file,folder,module";
    int i = 0;
    int count = 0;

    int res = 0;
    for (String val : allowedTypes.split(",")) {
        count++;
        if("folder".equals(val) && "folder".equals(type))
            res = i;
        else if("module".equals(val) && 
             ("module".equals(type) || "version".equals(type) || "branch".equals(type)))
            res = i;
        else if("file".equals(val) &&
            (!"module".equals(type) && !"version".equals(type) && !"branch".equals(type) &&
             !"folder".equals(type)))
            res = i;
        i++;
    }
    // If there was only 1 allowed type, then there will be no
    // radio fields, so return value of -1.
    if (count == 1)
        return -1;
    return res;
}
%>


