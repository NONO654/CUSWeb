<%--  emxComponentsCheckinProcess.jsp -
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = "$Id: emxCommonDocumentVCInformation.jsp.rca 1.25.1.3.2.5.2.1 Tue Dec 23 05:46:57 2008 ds-hkarthikeyan Experimental $"
--%>
<%
  // This is added because adding emxUICommonHeaderEndInclude.inc add
  request.setAttribute("warn", "false");
%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxComponentsNoCache.inc"%>
<%@include file = "emxComponentsCommonUtilAppInclude.inc"%>
<script language="javascript" src="../common/scripts/emxTypeAhead.js"></script>
<%
  String dsObjectId = emxGetParameter(request,"objectId");
  String path = emxGetParameter(request,"path");
  String fileORfolder = emxGetParameter(request,"vcDocumentType");
  String selector = emxGetParameter(request,"selector");
  String server = emxGetParameter(request,"server");
  String defaultFormat = emxGetParameter(request,"format");
  String showFormat = emxGetParameter(request,"showFormat");
  String defaultDocumentPolicyName = emxGetParameter(request,"defaultDocumentPolicyName");
  String objectAction = emxGetParameter(request,"objectAction");
  String viewOnly = emxGetParameter(request,"viewOnly");
  String icSearch = emxGetParameter(request,"icSearch");
  String createProjectSpace = emxGetParameter(request,"createProjectSpace");
  String populateDefaults = emxGetParameter(request,"populateDefaults");
  String disableFileFolder = emxGetParameter(request, "disableFileFolder");
  String reloadPage = emxGetParameter(request, "reloadPage");
  String suiteKey = emxGetParameter(request, "suiteKey");
  String typeAheadFormName = request.getServletPath();
  String disableFormat = "false";
%>
<script language="javascript">
  function showDSFANavigator()
  {
    var strURL="../components/emxCommonVCStoreIntermediateProcess.jsp?storeName="+document.frmMain.server.value+"&objectAction="+document.frmMain.objectAction.value+"&suiteKey=<%=XSSUtil.encodeForURL(context, suiteKey)%>&vcDocumentType="+document.frmMain.vcDocumentType.value;
    var win = showModalDialog(strURL, 650, 550, true);
  }
</script>
<%  
  if ( fileORfolder == null || "".equals(fileORfolder) || "null".equals(fileORfolder) )
  {
      fileORfolder = "";
  } 
  else if (fileORfolder.equals("Folder"))
  {
	  disableFormat = "true";
  }
  
  if ( viewOnly == null || "".equals(viewOnly) || "null".equals(viewOnly) )
  {
      viewOnly = "false";
  } 
 
  if ( createProjectSpace == null || "".equals(createProjectSpace) || "null".equals(createProjectSpace) )
  {
      createProjectSpace = "false";
  } 
 
  if( selector != null && "".equals(selector) )
  {
      selector = null;
  }
  if (showFormat == null || showFormat.equals("") )
  {
	showFormat = "true";
  }
  
  if ( disableFileFolder == null || "".equals(disableFileFolder) || "null".equals(disableFileFolder) )
  {
      disableFileFolder = "false";
  }
  
  if (viewOnly.equalsIgnoreCase("true"))
  {
	  disableFileFolder = "true";
  }
  
  if ( icSearch == null || "".equals(icSearch) || "null".equals(icSearch) )
  {
      icSearch = "false";
  }
  else  
  {
      selector = "";
  }
  
  if ( reloadPage == null || "".equals(reloadPage) || "null".equals(reloadPage) )
  {
      reloadPage = "false";
  } 
  
  String noStore = "";
  String strNone = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.None");
  if (createProjectSpace.equalsIgnoreCase("true"))
  {
	  noStore = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.Common.None");
  }
  else
  {
	  noStore = EnoviaResourceBundle.getProperty(context, "emxComponentsStringResource", context.getLocale(), "emxComponents.VCDocument.RelativePath");
  }

  if (  objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_COPY_FROM_VC) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_CHECKIN_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) ||
        objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONVERT_COPY_FROM_VC) )
    {

/*
      Iterator storeItr = Store.getStores(context).iterator();
      StringList servers = new StringList(3);
      Store store;
      String storeType;
      String storeName;
      while(storeItr.hasNext())
      {
          store = (Store)storeItr.next();
          store.open(context);
          storeType = store.getType(context);
          storeName = store.getName();
          if( "designsync".equalsIgnoreCase(storeType) )
          {
              servers.add(storeName);
          }

      }
*/
      String localPath = "";
      String localServer = "";
      String populateLocalServerData = "false";
      try
      {
          localPath = EnoviaResourceBundle.getProperty(context,"emxComponents.LocalDSPath");
          localServer = EnoviaResourceBundle.getProperty(context,"emxComponents.LocalDSServer");
          populateLocalServerData = EnoviaResourceBundle.getProperty(context,"emxComponents.PopulateLocalServerData");
      } catch(Exception ex)
      {
          //Skip because properties might not be defined
      }
      if( populateDefaults == null || "".equals(populateDefaults) || "null".equals(populateDefaults) )
      {
          populateDefaults = populateLocalServerData;
      }
      
      if( populateDefaults != null && "true".equalsIgnoreCase(populateDefaults) )
      {
          if( server == null || "".equals(server) )
          {
              server = localServer;
          }
          if( path == null || "".equals(path))
          {
              path = localPath;
          }
      }
      
      String stores = MqlUtil.mqlCommand(context, "list store" );
      StringList storeList = FrameworkUtil.split(stores, "\n");
      Iterator storeItr = storeList.iterator();
      StringList servers = new StringList(1);
      String storeType;
      String storeName;
      while(storeItr.hasNext())
      {
          storeName = (String) storeItr.next();
          storeType = MqlUtil.mqlCommand(context, "print store '" + storeName + "' select type dump;" );
          if( "designsync".equalsIgnoreCase(storeType) )
          {
              servers.add(storeName);
          }
      }
       
      // If State Sensitive (EPM) need option for no store.  Creating a Project from a Template requires a store. 
      if (objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER))
      {
	      // State Sensitive Documents will default to 'Use Relative Path' and inherit info from the project.
	      servers.add(noStore);
	      if ((!createProjectSpace.equalsIgnoreCase("true")) && (reloadPage.equalsIgnoreCase("false")))
		    server = noStore;
		    
		  if ("None".equals(server))
		    server = noStore;
      }
        
      String formats = MqlUtil.mqlCommand(context, "print policy '" + defaultDocumentPolicyName + "' select format dump |" );
      StringList formatList = FrameworkUtil.split(formats, "|");
      if ( defaultFormat == null || "".equals(defaultFormat) || "null".equals(defaultFormat) )
      {
          defaultFormat = MqlUtil.mqlCommand(context, "print policy '" + defaultDocumentPolicyName + "' select defaultformat dump |" );
      }
%>

    <tr>
    <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
    <td class="heading1" colspan="2"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.DesignSyncURL</emxUtil:i18n>&nbsp;
        </td>
    </tr>
    <tr>
    <td width="10%" class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Server</emxUtil:i18n>&nbsp;
    </td>
<%   
     if ( viewOnly.equalsIgnoreCase("false") )
     {
%>
    <td colspan="1" class="inputField">
          <select id="server" name="server">&nbsp;
<%
          Iterator serverItr = servers.iterator();
          while(serverItr.hasNext())
          {
            String serverName = (String)serverItr.next();
			//modified for the bug 
            if (serverName.equals(noStore))
            {
%><!-- //XSSOK -->
            </option><option value="None" <%=serverName.equals(server)?"selected":""%> ><%=XSSUtil.encodeForHTML(context, noStore)%>&nbsp;</option>
<%
            }
            else
            {
%><!-- //XSSOK -->
            </option><option value="<%=XSSUtil.encodeForHTMLAttribute(context, serverName)%>" <%=serverName.equals(server)?"selected":""%> ><%=XSSUtil.encodeForHTML(context, serverName)%>&nbsp;</option>
<%
            }
          }
%>
        </select>
        &nbsp;&nbsp;
        
        </td>

     
<%   
     }
     else
     {
         if ( server == null || "".equals(server) || "null".equals(server) )
         {
           String vcSelect = "vcfile";
           if (fileORfolder != null && fileORfolder.equals("Folder"))
             vcSelect = "vcfolder";
           else if(fileORfolder != null && fileORfolder.equals("Module"))
           {
               vcSelect = "vcmodule";
           }
           StringBuffer dsCmd = new StringBuffer(128);
           dsCmd.append("print bus ");
           dsCmd.append(dsObjectId);
           dsCmd.append(" select ");
           dsCmd.append(vcSelect);
           dsCmd.append(".store ");
           dsCmd.append(vcSelect);
           dsCmd.append(".path dump |");
           String storeInfo = MqlUtil.mqlCommand(context, dsCmd.toString());
           int index = storeInfo.indexOf("|");
           if (index < 0)
           {
	           server = noStore;
	           path = "/";
           }
           else
           {
             server = storeInfo.substring(0, index);
             if ((server == null) || (server.equals("ADMINISTRATION")) || (server.equals("")))
               server = noStore;
               
             path = storeInfo.substring(index + 1);
           }
         }
%>
       <td>
       <input type="text" value="<%=XSSUtil.encodeForHTMLAttribute(context, server)%>" name="server" size="30" readonly="readonly" />
       </td>
<%   
     }
%>
    </tr>
    <tr>
<%
      String classLabel = "label";
      if (createProjectSpace.equalsIgnoreCase("false"))
      {
         classLabel = "labelRequired";
      }
    %>
	<!-- //XSSOK -->
    <td width="10%" class="<%=classLabel%>"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Path</emxUtil:i18n>&nbsp;
<%   
     if (viewOnly.equalsIgnoreCase("false"))
     {
%>
        </td><td colspan="1" class="inputField">
          <input type="text" name="path" size="30" value="<xss:encodeForHTMLAttribute><%=path==null?"":path%></xss:encodeForHTMLAttribute>" />
          <emxUtil:displayTypeAheadValues
            context="<%= context %>"
            form="<%= XSSUtil.encodeForXML(context, typeAheadFormName) %>"
            field="path"
            displayField="path"
            hiddenField=""
            program=""
            function=""
            characterCount=""/>
            
            <%
        if ((createProjectSpace.equalsIgnoreCase("true")) || (objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER)))
        {
	        // don't show button
        }
        else
        {
%>
          <input type="button" value="..." onclick="javascript:showDSFANavigator();"/>
          <emxUtil:i18n localize="i18nId">emxComponents.VersionControl.SelectFileFolderfromServer</emxUtil:i18n>
<%
        }
%>

            </td>
            </tr>
            
            <tr>
            <td colspan="1" class="labelRequired""></td>
            <td colspan="1" class="inputField">
<%
            if ("true".equalsIgnoreCase(disableFileFolder))
            {
              if (createProjectSpace.equalsIgnoreCase("false"))
              {
	            if ( fileORfolder != null && "File".equalsIgnoreCase(fileORfolder) )
                {
%>
                   <input type="radio" name="vcDocumentTmp" value="File" disabled checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                   <input type="radio" name="vcDocumentTmp" value="Folder" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                   <input type="radio" name="vcDocumentTmp" value="Module" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                   <input type="hidden" name="vcDocumentType" value="File"/>
<%
                }
                else if ( fileORfolder != null && "Folder".equalsIgnoreCase(fileORfolder) )
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" disabled checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="Folder"/>
<%
                }
	            
                else if ( fileORfolder != null && ("Module".equalsIgnoreCase(fileORfolder) || "Version".equalsIgnoreCase(fileORfolder) ))
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" disabled checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="Module"/>
<% 
                }
                else
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" disabled checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="File"/>
<%
                }
              }
            }
            else
            {
              if (createProjectSpace.equalsIgnoreCase("false"))
              {
	            if ( fileORfolder != null && "File".equalsIgnoreCase(fileORfolder) )
                {
%>
                   <input type="radio" name="vcDocumentTmp" value="File" checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                   <input type="radio" name="vcDocumentTmp" value="Folder" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                   <input type="radio" name="vcDocumentTmp" value="Module" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                   <input type="hidden" name="vcDocumentType" value="File"/>
<%
                }
                else if ( fileORfolder != null && "Folder".equalsIgnoreCase(fileORfolder) )
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="Folder"/>
<%
                }
	            
                else if ( fileORfolder != null && ("Module".equalsIgnoreCase(fileORfolder) || "Version".equalsIgnoreCase(fileORfolder) ))
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder"<%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="Module"/>
<%
                }
                else
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="File"/>
<%
                }
              }
            }
%>
        </td>
        </tr>
<%   
     }
     else
     {
%>
       <td>
       <input type="text" value="<%=XSSUtil.encodeForHTMLAttribute(context, path)%>" name="path" size="30" readonly="readonly" />
       </td>
<%   
            if ("true".equalsIgnoreCase(disableFileFolder))
            {
              if (createProjectSpace.equalsIgnoreCase("false"))
              {
	            if ( fileORfolder != null && "File".equalsIgnoreCase(fileORfolder) )
                {
%>
                   <input type="radio" name="vcDocumentTmp" value="File" disabled checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                   <input type="radio" name="vcDocumentTmp" value="Folder" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                   <input type="radio" name="vcDocumentTmp" value="Module" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                   <input type="hidden" name="vcDocumentType" value="File"/>
<%
                }
                else if ( fileORfolder != null && "Folder".equalsIgnoreCase(fileORfolder) )
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" disabled checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="Folder"/>
<%
                }
	            
                else if ( fileORfolder != null && ("Module".equalsIgnoreCase(fileORfolder) || "Version".equalsIgnoreCase(fileORfolder) ))
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" disabled checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="Module"/>
<%
                }
	            
                else
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" disabled checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" disabled <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="File"/>
<%
                }
              }
            }
            else
            {
              if (createProjectSpace.equalsIgnoreCase("false"))
              {
	            if ( fileORfolder != null && "File".equalsIgnoreCase(fileORfolder) )
                {
%>
                   <input type="radio" name="vcDocumentTmp" value="File" checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                   <input type="radio" name="vcDocumentTmp" value="Folder" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                   <input type="radio" name="vcDocumentTmp" value="Module" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                   <input type="hidden" name="vcDocumentType" value="File"/>
<%
                }
                else if ( fileORfolder != null && "Folder".equalsIgnoreCase(fileORfolder) )
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="Folder"/>
<%
                }
	            
                else if ( fileORfolder != null && ("Module".equalsIgnoreCase(fileORfolder) || "Version".equalsIgnoreCase(fileORfolder) ))
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="Module"/>
<%
                }
	            
                else
                {
%>
                  <input type="radio" name="vcDocumentTmp" value="File" checked <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.File </emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Folder" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Folder</emxUtil:i18n>&nbsp;&nbsp;
                  <input type="radio" name="vcDocumentTmp" value="Module" <%if("true".equals(showFormat)){ %>onfocus="onFileFolderSelect(this)" <%}%>/><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Module</emxUtil:i18n>&nbsp;&nbsp;&nbsp;&nbsp;
                  <input type="hidden" name="vcDocumentType" value="File"/>
<%
                }
              }
            }
     }
%>
    </tr>
    <tr>
<%   
     if ( (viewOnly.equalsIgnoreCase("false")) && (disableFileFolder.equalsIgnoreCase("false")) && (createProjectSpace.equalsIgnoreCase("false")) )
     {
%>
       <td width="10%" class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Selector</emxUtil:i18n>&nbsp;
        <td class="inputField">
          <input type="text" name="selector" size="30" value="<xss:encodeForHTMLAttribute><%=selector==null?"Trunk:Latest":selector%></xss:encodeForHTMLAttribute>" />
          <emxUtil:displayTypeAheadValues
            context="<%= context %>"
            form="<%= XSSUtil.encodeForHTML(context, typeAheadFormName) %>"
            field="selector"
            displayField="selector"
            hiddenField=""
            program=""
            function=""
            characterCount=""/>
        </td>
<%   
     }
     else
     {
%>
       <td width="10%" class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.CommonDocument.Selector</emxUtil:i18n>&nbsp;
       <td><!-- //XSSOK -->
       <input type="text" value="<%=selector==null?"Trunk:Latest":XSSUtil.encodeForHTMLAttribute(context, selector)%>" name="selector" size="30" readonly="readonly"/>
       </td>
<%   
     }
%>        
    </tr>
<%
//    if ( objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_STATE_SENSITIVE_CONNECT_VC_FILE_FOLDER) ||
//          objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CONNECT_VC_FILE_FOLDER) )
//    {

        if ("true".equals(showFormat) )
        {

%>
        <tr>
        <td width="10%" class="labelRequired"><emxUtil:i18n localize="i18nId">emxComponents.VersionControl.Format</emxUtil:i18n>&nbsp;
            </td><td colspan="1" class="inputField">
              <select id="format" name="format" <%if("true".equals(disableFormat)){ %>disabled<%}%>>&nbsp;
<%
              Iterator formatItr = formatList.iterator();
              while(formatItr.hasNext())
              {
                String format = (String)formatItr.next();
                String i18nFormat = i18nNow.getMXI18NString(format, "", sLanguage, "Format");
%><!-- //XSSOK -->
                </option><option value="<%=XSSUtil.encodeForHTMLAttribute(context, format)%>" <%=format.equals(defaultFormat)?"selected":""%> ><%=i18nFormat%>&nbsp;</option>
<%
              }
%>
              </select>
              <input type="hidden" name="defaultFormat" value="<xss:encodeForHTMLAttribute><%=defaultFormat%></xss:encodeForHTMLAttribute>"/>
            </td>
        </tr>
<%
     // }
    } else {
%>
      <input type="hidden" name="format" value="<xss:encodeForHTMLAttribute><%=defaultFormat%></xss:encodeForHTMLAttribute>"/>
<%
    }
%>

    <tr>
    <td colspan="2">&nbsp;</td>
    </tr>

<%
    } else if( objectAction.equalsIgnoreCase(VCDocument.OBJECT_ACTION_CREATE_VC_ZIP_TAR_GZ) ) {
        //String server = VCDocument.getConfiguredLocalServer(context);
        //String path = VCDocument..getConfiguredPath(context);
    }
%>
    <input type="hidden" name="typeAheadFormName" value="<xss:encodeForHTMLAttribute><%= typeAheadFormName %></xss:encodeForHTMLAttribute>" />
    <input type="hidden" name="objectAction" value="<xss:encodeForHTMLAttribute><%= objectAction %></xss:encodeForHTMLAttribute>" />
 
