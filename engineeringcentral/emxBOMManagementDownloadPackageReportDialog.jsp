<%-- emxBOMManagementDownloadPackageReportDialog.jsp
  Copyright (c) 1998-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program
static const char RCSID[] = $Id: emxComponentsPackageReportDialog.jsp.rca 1.15 Wed Oct 22 16:18:40 2008 przemek Experimental przemek $
--%>
<%@ include file = "emxDesignTopInclude.inc"%>
<%@include file = "emxEngrVisiblePageInclude.inc"%>
<%@ include file = "../emxUICommonHeaderBeginInclude.inc"%>
<%@ include file = "../emxJSValidation.inc" %>
<%@page import="com.matrixone.apps.domain.util.XSSUtil"%>
<%@page import="com.matrixone.apps.engineering.Part"%>


<script language="javascript" src="../common/scripts/emxUIModal.js"></script>

<%
  //code to test whether teamcentral is installed or not.
  boolean bTeam = FrameworkUtil.isSuiteRegistered(context,"featureVersionTeamCentral",false,null,null);

   String objectId         = emxGetParameter(request,"objectId");
   String languageStr  = request.getHeader("Accept-Language");

   DomainObject part =DomainObject.newInstance(context,DomainConstants.TYPE_PART);
 
 //alert msg to enter only whole numbers
  String qtyMessage = i18nNow.getI18nString("emxBOMManagement.DownloadPackage.LevelHasToBeAWholeNumber", "emxEngineeringCentralStringResource",languageStr);
  //display all & level option
  String allString  = i18nNow.getI18nString("emxBOMManagement.DownloadPackage.All", "emxEngineeringCentralStringResource",languageStr);
  String levelStr   = i18nNow.getI18nString("emxBOMManagement.DownloadPackage.Levels", "emxEngineeringCentralStringResource",languageStr);

  
  
  
  
  
  String maxShort   = Short.toString(Short.MAX_VALUE);
  String partName;
  String partRev;
  String partType;
  String strSpace=" ";
        
  try
  {
    // set the part id
    part.setId(objectId);
    StringList sList = new StringList(1);
    sList.addElement(DomainConstants.SELECT_NAME);
    sList.addElement(DomainConstants.SELECT_REVISION);
    sList.addElement(DomainConstants.SELECT_TYPE);
    
    Map partMap = part.getInfo(context,sList);
    partName = (String) partMap.get(DomainConstants.SELECT_NAME);
    partRev    = (String) partMap.get(DomainConstants.SELECT_REVISION);
    partType  = (String) partMap.get(DomainConstants.SELECT_TYPE);
  }
  catch(Exception e)
  {
      throw e;
  }

 //display icon
  String typeIcon = null;
  String defaultTypeIcon = JSPUtil.getCentralProperty(application, session, "type_Default","SmallIcon");
  String alias           = FrameworkUtil.getAliasForAdmin(context, "type", partType, true);

  if ( alias != null && !alias.equals(""))
  {
    typeIcon = JSPUtil.getCentralProperty(application, session, alias, "SmallIcon");
  }

  if (typeIcon == null || "".equals(typeIcon))
  {
      //modified to display the type icon
      String sSmallIcon=UINavigatorUtil.getTypeIconFromCache(partType);

      if(sSmallIcon != null && !sSmallIcon.equals("")) 
      {
        typeIcon = sSmallIcon;
      }
      else
      { 
        typeIcon = defaultTypeIcon;
      }
  }
  
  // first get level if coming from previous
  String sLevel = emxGetParameter(request,"selectedlevel");
  if (sLevel == null || "null".equals(sLevel) || sLevel.length() <= 0 )
  {
      // Get default value with levels to expand the structure
      sLevel = JSPUtil.getCentralProperty(application, session, "eServiceToolbarMLBM" ,"DefaultLevelToExpand");
      if (sLevel == null)
      {
        sLevel = "";  // If not defined in properties set a default value
      }
  }
  //if level specified, uncheck the 'alllevels' button
  String allLevelsChecked = "checked";
  if (sLevel != null && sLevel.length() > 0)
  {
      // if value is zero, this means 'all', leave all levels checked and blank out sLevel
      if (!sLevel.equals("0"))
      {
          allLevelsChecked = "";
      }
      else
      {
          sLevel = "";
      }
  }
  
  String incBOMStructure = emxGetParameter(request,"incBOMStructure");
  String includeChecked = "checked";
 
  if (incBOMStructure == null || "null".equals(incBOMStructure) || incBOMStructure.length() <= 0 )
  {
      includeChecked = "checked";
  }
  else if ("false".equals(incBOMStructure))
  {
      includeChecked = "";
  }  

%>

<script language="Javascript" >


  function updatelevel()
  {
    document.getPackageLevels.level.value="";
  }

  function alertLevelInput() {
    var field = document.getPackageLevels.allLevels;
    if(field.checked ==true) {
       field.focus();
      alert("<emxUtil:i18nScript localize="i18nId">emxBOMManagement.DownloadPackage.AlreadyChosenAllLevel</emxUtil:i18nScript>");
      document.getPackageLevels.level.value="";
      return false;
    }
  }

  function doneMethod(){
	  
 
    var level = document.getPackageLevels.level.value;
 
    // commented by pn4
	//level = jsTrim(document.getPackageLevels.level.value);

	
    if ((!document.getPackageLevels.allLevels.checked) && (level==null || level=="")){
        alert("<emxUtil:i18nScript localize="i18nId">emxBOMManagement.DownloadPackage.SelectEitherLevelOrCheckbox</emxUtil:i18nScript>");
        document.getPackageLevels.level.focus();
        return;
    }
    if (document.getPackageLevels.allLevels.checked && level != null && level != "")
    {
      alert("<emxUtil:i18nScript localize="i18nId">emxBOMManagement.DownloadPackage.SelectLevelorCheckbox</emxUtil:i18nScript>");
      document.getPackageLevels.level.focus();
      return;
    }

    //New Feature:P & T functionality
    var workspaceFolderId =null;
    var archiveName =null;

    //return Object only  when TeamCentral is installed
  /*  if(document.getPackageLevels.txtWSFolder)
    {
         workspaceFolderId =document.getPackageLevels.folderId.value;
         archiveName =jsTrim(document.getPackageLevels.txtArchiveName.value);
         if(workspaceFolderId !="" && archiveName == "" )
         {
               alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Package.PleaseEnterArchiveName</emxUtil:i18nScript>");
               document.getPackageLevels.txtArchiveName.focus();
               return;
         }
         else if(workspaceFolderId == "" && archiveName != "" )
         {
               alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Package.SelectWorkspaceFolder</emxUtil:i18nScript>");
               document.getPackageLevels.txtWSFolder.focus();
               return;
         }

         var namebadCharName = checkForNameBadCharsList(document.getPackageLevels.txtArchiveName);
         if (namebadCharName.length != 0)
         {
              alert("<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertInValidChars</emxUtil:i18nScript>"+namebadCharName+"<emxUtil:i18nScript localize="i18nId">emxComponents.Common.AlertRemoveInValidChars</emxUtil:i18nScript>");      //
              document.getPackageLevels.txtArchiveName.value="";
              document.getPackageLevels.txtArchiveName.focus();
              return;
         }
    }*/
    // End Feature

<%
    Enumeration paramEnum = emxGetParameterNames (request);
	StringBuffer contentURL = new StringBuffer();
	contentURL.append("emxBOMManagementDownloadPackageReportSummaryFS.jsp?");
	while (paramEnum.hasMoreElements()) {
		String parameter = (String)paramEnum.nextElement();
		String[] values = emxGetParameterValues(request, parameter);
		contentURL.append(XSSUtil.encodeForJavaScript(context,parameter)).append("=").append(XSSUtil.encodeForJavaScript(context,values[0])).append("&");
	}
	
    %>
    
if (document.getPackageLevels.level.value==null || document.getPackageLevels.level.value=="")
    {
        if (!document.getPackageLevels.allLevels.checked)
        {
            alert("<emxUtil:i18nScript localize="i18nId">emxBOMManagement.DownloadPackage.SelectLevel</emxUtil:i18nScript>");
            document.getPackageLevels.level.focus();
            return;
        }
        else
        {
            // assigining value of hidden variable to 'tokenall' when alllevels checkbox is selected and passed as value to parameter tokenalllevels with URL
            tokenall = document.getPackageLevels.tokenalllevels.value;
            //XSSOK
            var winurl ="<%=contentURL%>level=0&tokenalllevels="+tokenall+"&bTeam=<%=bTeam%>";
            document.getPackageLevels.action = winurl;
            document.getPackageLevels.submit();
        }
    }
        // The condition "level <= 0" changed to "level < 0" so as to allow user to enter a value of 0
    //XSSOK
    else if ((level >= <%=maxShort%>) || (level < 0) || (!isNumeric(level)) || charExists(level, "."))
    {
        //XSSOK
        alert("<emxUtil:i18nScript localize="i18nId">emxBOMManagement.DownloadPackage.InvalidLevelRange</emxUtil:i18nScript> " + <%=maxShort%>);
        document.getPackageLevels.level.focus();
        return;
    }
    else
    {
        // assigining value "" to variable 'tokenall' when alllevels checkbox is not selected and passed as value to parameter tokenalllevels with URL
        tokenall = "";
        //XSSOK
        var url ="<%=contentURL%>level="+parseInt(level,10)+"&tokenalllevels="+tokenall+"&bTeam=<%=bTeam%>";
        alert("url ="+url);
        document.getPackageLevels.action =url;
        document.getPackageLevels.submit();
    }
  }

   function selectWorkspaceFolder()
   {
        showTreeDialog("../common/emxIndentedTable.jsp?expandProgram=emxWorkspace:getWorkspaceVaults&table=TMCSelectFolder&program=emxWorkspace:getDisabledWorkspaces&header=emxFramework.IconMail.Common.SelectOneFolder&submitURL=../components/emxCommonSelectWorkspaceFolderProcess.jsp&cancelLabel=Cancel&submitLabel=Done");
       // showTreeDialog("../components/emxCommonSelectWorkspaceFolderDialogFS.jsp?select=multiple&folderAccessMember=yes");
        return;
   }

   function clearAll()
   {
        document.getPackageLevels.folderId.value = "";
        document.getPackageLevels.txtWSFolder.value  = "";
        return;
    }
</script>

<%@include file = "../emxUICommonHeaderEndInclude.inc" %>

<%
  String nameHeading = partName + " rev " + partRev;
%>

<form name="getPackageLevels" method="post" action="" onSubmit="return false" target="_parent">
<table border="0" cellpadding="5" cellspacing="2" width="100%">

<tr>
    <td width="150" class="label"><label for="part"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Part</emxUtil:i18n></label></td>
    <!-- //XSSOK -->
	<td class="field"><img src="../common/images/<%=typeIcon%>" align="absmiddle" border="0" />&nbsp;<B><%=XSSUtil.encodeForHTML(context, nameHeading)%></B></td>
</tr>

<tr>
    <td width="150" class="labelRequired"><label for="Levels"><emxUtil:i18n localize="i18nId">emxBOMManagement.DownloadPackage.Level</emxUtil:i18n></label></td>
    <td class="inputField"><input type="text" name="level" id="" onfocus="javascript:alertLevelInput()" value="<xss:encodeForHTMLAttribute><%=sLevel%></xss:encodeForHTMLAttribute>"/>&nbsp;
    <!-- //XSSOK -->
    <input type="checkbox" name="allLevels" value="" onClick="javascript:updatelevel()" <%=allLevelsChecked%>/>
    <emxUtil:i18n localize="i18nId">emxBOMManagement.DownloadPackage.AllLevel</emxUtil:i18n>
    </td>
    <input type="hidden" name="tokenalllevels" value="all"/>
</tr>

<tr>
    <td width="150" class="labelRequired"><label for="ZipFormat"><emxUtil:i18n localize="i18nId">emxBOMManagement.DownloadPackage.ZipFormat</emxUtil:i18n></label></td>
    <td class="inputField">  
       <!-- //XSSOK --> 
       <input type="radio" name="incBOMStructure" value="true" <%="checked".equals(includeChecked)?"checked":""%>/><emxUtil:i18n localize="i18nId">emxBOMManagement.DownloadPackage.BOMStructure</emxUtil:i18n>
       <!-- //XSSOK --> 
       <input type="radio" name="incBOMStructure" value="false" <%="checked".equals(includeChecked)?"":"checked"%>/><emxUtil:i18n localize="i18nId">emxBOMManagement.DownloadPackage.PartListOnly</emxUtil:i18n>
    </td>
</tr>

<%
    if(bTeam)
    {
         String sWorkspaceFolderId    = "";
         String sArchiveName = "";
         String sWorkspaceFolderName   = "";
         String prevmode = emxGetParameter(request,"prevmode");
         //taking user entered value from session.Done for displaying correct Internationalization characters.
         Properties createPackageprop = (Properties) session.getAttribute("createPackage_KEY");

         if(prevmode !=null && !"".equals(prevmode) && !"null".equals(prevmode))
         {
             sWorkspaceFolderId = createPackageprop.getProperty("workspaceFolderId_KEY");
             sArchiveName = createPackageprop.getProperty("archiveName_KEY");
             sWorkspaceFolderName  = createPackageprop.getProperty("workspaceFolderName_KEY");
         }
         else
         {
              if(createPackageprop !=null)
              {
                 //removing session if user visit the page first time.
                 session.removeAttribute("createPackage_KEY");
              }
         }
%>
      <tr>
        <td width="100%" colspan="2" class="heading1"><emxUtil:i18n localize="i18nId">emxBOMManagement.DownloadPackage.SaveWorkspaceMsg</emxUtil:i18n></td>
      </tr>
      <tr>
        <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxBOMManagement.DownloadPackage.WorkspaceFolder</emxUtil:i18n></td>
        <td class="inputField">
        <input type="text" name="txtWSFolder" readonly value="<xss:encodeForHTMLAttribute><%=sWorkspaceFolderName%></xss:encodeForHTMLAttribute>"/>
        <input type="button" name="butClear" id="" value="..." onclick="selectWorkspaceFolder()"/>&nbsp;&nbsp;<a href="javascript:clearAll()"><emxUtil:i18n localize="i18nId">emxEngineeringCentral.Common.Clear</emxUtil:i18n></a></td>
        <input type="hidden" name="folderId" value="<%=XSSUtil.encodeForHTMLAttribute(context, sWorkspaceFolderId)%>"/>
      </tr>
      <tr>
        <td width="150" class="label"><emxUtil:i18n localize="i18nId">emxBOMManagement.DownloadPackage.ArchiveFileName</emxUtil:i18n></td>
        <td class="inputField"><input type="text" name="txtArchiveName" id="" value="<xss:encodeForHTMLAttribute><%=sArchiveName%></xss:encodeForHTMLAttribute>" />
      </td>
      </tr>
<%
      }
%>
</table>
</form>

<%@include file = "../emxUICommonEndOfPageInclude.inc" %>
