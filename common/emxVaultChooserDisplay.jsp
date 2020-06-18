<%--  emxVaultChooserDisplay.jsp  -  This page displays a Dialog to Create a Line Item for a RTS.

  Copyright (c) 1992-2018 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne, Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = "$Id: emxVaultChooserDisplay.jsp.rca 1.13.2.1 Wed Dec 17 01:22:53 2008 ds-arsingh Experimental $"
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>

<%

  String jsTreeID = emxGetParameter(request,"jsTreeID");
  String suiteKey = emxGetParameter(request,"suiteKey");
  String fieldName = emxGetParameter(request,"fieldName");
  String fieldNameActual = emxGetParameter(request,"fieldNameActual");
  String fieldNameDisplay = emxGetParameter(request,"fieldNameDisplay");
  String action = emxGetParameter(request,"action");
  String multiSelect = emxGetParameter(request,"multiSelect");
  String fromSearch = emxGetParameter(request,"isFromSearchForm");
  String objectId = emxGetParameter(request,"objectId");
  String incCollPartners = emxGetParameter(request,"incCollPartners");
  String formName = emxGetParameter(request,"formName");
  String CallbackFunction = emxGetParameter(request,"callbackFunction");
  String frameName = emxGetParameter(request,"frameName");
  String allowNoSelection = emxGetParameter(request,"allowNoSelection");
  String languageStr = request.getHeader("Accept-Language");

  String vaultsDisplayMap = "";

  String selectType = "";
  String strRefinementSep =EnoviaResourceBundle.getProperty(context, "emxFramework.FullTextSearch.RefinementSeparator");
  MapList vaultsList = new MapList();
  String secondaryVaults = "" ;
  try
  {
      if("createCompany".equalsIgnoreCase(action))
      {
          vaultsList = VaultUtil.getVaults(context);
      }
      else if("editCompany".equalsIgnoreCase(action))
      {
          //vaultsList = VaultUtil.getVaults(context);
          vaultsList = VaultUtil.getVaults(context, objectId);
          secondaryVaults = OrganizationUtil.getSecondaryVaults(context, objectId);
      }
      else
      {
          boolean incCollaborationPartners = false;
          if("true".equalsIgnoreCase(incCollPartners))
          {
             incCollaborationPartners = true;
          }
          vaultsList = OrganizationUtil.getAllVaultsDetails(context, incCollaborationPartners);
      }

      if (secondaryVaults == null )
      {
          secondaryVaults = "";
      }

      //build translated vault names string
      Iterator itr = vaultsList.iterator();
      while(itr.hasNext())
      {
          Map vaultMap = (Map) itr.next();
          String vault = (String) vaultMap.get(DomainConstants.SELECT_NAME);
          String vaultDisplay = i18nNow.getAdminI18NString("Vault", vault, languageStr);

          //for displaying purpose
          if("".equals(vaultsDisplayMap))
          {
             vaultsDisplayMap = vault + "|" + vaultDisplay;
          }
          else
          {
             vaultsDisplayMap += "," + vault + "|" + vaultDisplay;
          }
      }

  }
  catch(Exception ex)
  {
      ex.printStackTrace();
  }

  String strParams = "&jsTreeID="+XSSUtil.encodeForHTML(context, jsTreeID)+ "&suiteKey="+XSSUtil.encodeForHTML(context, suiteKey);

%>

<html>
<%
    // Assign the style sheet to be used based on the input
    String cssFile = EnoviaResourceBundle.getProperty(context, "emxNavigator.UITable.Style.List");
    boolean useDefaultCSS=false;
    if ( cssFile == null || cssFile.trim().length() == 0){
        useDefaultCSS=true;
    }
	if (formName == null || formName.length() == 0) {
        formName = "0";
    } else {
        formName = "\"" + formName + "\"";
    }
%>

<head>
    <title></title>
    <%@include file = "emxUIConstantsInclude.inc"%>
    <%@include file = "../emxStyleDefaultInclude.inc"%>

    <%
     if(useDefaultCSS)
     {
     %>
        <%@include file = "../emxStyleListInclude.inc"%>
     <%}else{
     %>
     <script>
          //XSSOK
          addStyleSheet("<%=cssFile%>");
    </script>
    <% }
    %>

    <script type="text/javascript" language="JavaScript" src="scripts/emxUIModal.js" ></script>
    <script type="text/javascript" language="JavaScript" src="scripts/emxUIFormUtil.js"></script>
    <script language="JavaScript">
        var strPageIDs = "~";
    </script>
    <script type="text/javascript" language="JavaScript" src="scripts/emxUIVaultChooser.js"></script>

    <script language="JavaScript">
    var checkedValue = "";
    var displayValueRefSep = "";
    var displayValues = "";
    //var formName = "";
    var callbackFunction = "";
    var bAllowNoSelection= "";
    var targetFrame = findFrame(getTopWindow().getWindowOpener().getTopWindow(), "<xss:encodeForJavaScript><%=frameName%></xss:encodeForJavaScript>");
    
	<% if(CallbackFunction != null && CallbackFunction.trim().length() > 0){ %>
    if(targetFrame!=null)
    {
        var callbackFunction = targetFrame.<%= XSSUtil.encodeForJavaScript(context, CallbackFunction) %>;
    } else
    {
        var callbackFunction = getTopWindow().getWindowOpener().<%= XSSUtil.encodeForJavaScript(context, CallbackFunction) %>;
    }

    <% } %>
	    
    
    <% if(allowNoSelection != null && !"".equals(allowNoSelection) && !"null".equals(allowNoSelection)){ %>
       bAllowNoSelection = "<xss:encodeForJavaScript><%=allowNoSelection.trim()%></xss:encodeForJavaScript>";
    <% } else { %>
       bAllowNoSelection = "false";
    <% }%>


  function submitFn()
  {
    for ( var i = 0; i < document.vaultsForm.elements.length; i++ ) {
          if (document.vaultsForm.elements[i].type == "checkbox" ||document.vaultsForm.elements[i].type == "radio"){
              if( document.vaultsForm.elements[i].checked && document.vaultsForm.elements[i].name.indexOf('vaults') > -1){
                checkedValue += document.vaultsForm.elements[i].value + ",";
			  }

          }

    }

    if(checkedValue == "" && "true" != bAllowNoSelection) {
       alert("<emxUtil:i18nScript localize="i18nId">emxFramework.Common.ErrorMsg.SelectVault</emxUtil:i18nScript>");
       return;
    }

    checkedValue = checkedValue.substring(0,checkedValue.length-1);

    var checkedValueArr = checkedValue.split(",");
    //XSSOK
    var vaultsDisplayMap = "<%=vaultsDisplayMap%>";
    var vaultsDisplayArr = vaultsDisplayMap.split(",");
    var STR_REFINEMENT_SEPARATOR = "<%=strRefinementSep%>";

    //get translated vault names
    for(var j=0; j < checkedValueArr.length; j++)
    {
       for(var k=0; k < vaultsDisplayArr.length; k++)
       {
           var vaultDisplayPair = vaultsDisplayArr[k].split("|");
           var actualVaultName = vaultDisplayPair[0];
           var translatedVaultName = vaultDisplayPair[1];

           //find and add translated vault names
           if(checkedValueArr[j] == actualVaultName)
           {
           if(<%=XSSUtil.encodeForURL(context, formName)%>=="full_search"){
              displayValues += translatedVaultName + emxUIConstants.STR_REFINEMENT_SEPARATOR;
           }else{
              displayValues += translatedVaultName + ",";
           }
             break;              
           }
       }
    }

    displayValues = displayValues.substring(0,displayValues.length-1);


    var fieldName = "<xss:encodeForJavaScript><%=fieldName%></xss:encodeForJavaScript>";
    var fieldNameActual = "<xss:encodeForJavaScript><%=fieldNameActual%></xss:encodeForJavaScript>";
    var fieldNameDisplay = "<xss:encodeForJavaScript><%=fieldNameDisplay%></xss:encodeForJavaScript>";

    if(<%= XSSUtil.encodeForURL(context, fromSearch)%>) {
    
     // Modified for Search Component Consolidated View Feature
    var topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"pageContent");
     // null check added for Bug Id- 365391
      if(topFrameObj != null && topFrameObj.contentWindow)
     {
     	topFrameObj = topFrameObj.contentWindow;
     }       
     
    // Ended for Search Component Consolidated View Feature

      if(topFrameObj=="" || topFrameObj==null)
      {
         topFrameObj = findFrame(getTopWindow().getWindowOpener().getTopWindow(),"searchPane");
      }

      //set actual vault names
      var temp = null;
      
      //Modified for Search Component Consolidated View Feature
      
		var objForm = emxUICore.getNamedForm(topFrameObj,<%=XSSUtil.encodeForJavaScript(context, formName)%>);    
      
     //Ended for Search Component Consolidated View Feature

      if(fieldName != null && fieldName != "" && fieldName != "undefined" && fieldName != "null")
      {
         eval("temp = objForm.elements[\"<xss:encodeForHTML><%=fieldName%></xss:encodeForHTML>\"]");
         temp.value = checkedValue;
      }

      if(fieldNameActual != null && fieldNameActual != "" && fieldNameActual != "undefined" && fieldNameActual != "null")
      {
             eval("temp2 = objForm.elements[\"vaultOption\"]")
        	 topFrameObj.document.getElementById(fieldNameActual).value=checkedValue;
         	 temp2[2].value=checkedValue;
        	 
      }

      //set translated vault names
      if(fieldNameDisplay != null && fieldNameDisplay != "" &&
         fieldNameDisplay != "undefined" && fieldNameDisplay != "null")
      {
    	  topFrameObj.document.getElementById(fieldNameDisplay).value=checkedValue;
      }
    }
    else {
      var objForm = emxUICore.getNamedForm(parent.window.getWindowOpener(),<%=XSSUtil.encodeForJavaScript(context, formName)%>);

      //set actual vault names
      if(fieldName != null && fieldName != "" && fieldName != "undefined" && fieldName != "null")
      {
         eval("objForm.elements[\"<xss:encodeForHTML><%=fieldName%></xss:encodeForHTML>\"].value = \""+ checkedValue +"\";");
      }

      //set actual vault names
      if(fieldNameActual != null && fieldNameActual != "" && fieldNameActual != "undefined" && fieldNameActual != "null")
      {
         eval("objForm.elements[\"<xss:encodeForHTML><%=fieldNameActual%></xss:encodeForHTML>\"].value = \""+ checkedValue +"\";");
      }

      //set translated vault names
      if(fieldNameDisplay != null && fieldNameDisplay != "" &&fieldNameDisplay != "undefined" && fieldNameDisplay != "null")
      {
         eval("objForm.elements[\"<xss:encodeForHTML><%=fieldNameDisplay%></xss:encodeForHTML>\"].value = \""+ displayValues +"\";");
      }
    }

    //called if a callbackFunction is passed
    if(callbackFunction != null && callbackFunction != "" && callbackFunction != "undefined" && callbackFunction != "null") {
		   callbackFunction();
     }

    windowClose();
  }

</script>

</head>

<%
  // ------------------------ Page content body below  ---------------------
%>

<body onload="turnOffProgress()">


  <form name="vaultsForm" method="post" action="" onsubmit="submitFn(); return false">
 <script language="Javascript">
  	addStyleSheet("emxUIDefault");
	addStyleSheet("emxUIList");
 </script>  
  <framework:sortInit
      defaultSortKey="<%= DomainConstants.SELECT_NAME %>"
      defaultSortType="string"
      resourceBundle="emxFrameworkStringResource"
      mapList="<%= vaultsList %>"
      ascendText="SortAscending.Common.SortAscending"
      descendText="SortAscending.Common.SortDescending"
      params = "<%=strParams%>"  />

  <table class="list">
  <!-- Table Column Headers -->
  <tr>
<%
  if(multiSelect.equalsIgnoreCase("true"))
  {
    selectType = "checkbox";
%>
    <th width="5%" style="text-align:center"><input type="checkbox" name="chkList" id="chkList" onclick="doCheck()" /></th>
<%
  } else {
    selectType = "radio";
%>
    <th width="5%" style="text-align:center">&nbsp;</th>
<%
  }
%>
    <th nowrap="nowrap">
      <framework:sortColumnHeader
          title="emxFramework.Common.Name"
          sortKey="<%= DomainConstants.SELECT_NAME %>"
          sortType="string"
          />
    </th>
    <th nowrap="nowrap">
      <framework:sortColumnHeader
          title="emxFramework.Common.Description"
          sortKey="<%= DomainConstants.SELECT_DESCRIPTION %>"
          sortType="string"
          />
    </th>
  </tr>
	<!-- //XSSOK -->
    <framework:mapListItr mapList="<%= vaultsList %>" mapName="vaultsMap">
    <tr class='<framework:swap id="1"/>'>

<%
      String vault = (String) vaultsMap.get(DomainConstants.SELECT_NAME);

      if(action == null || "".equals(action) || "null".equals(action))
      {
%>
         <!-- //XSSOK -->
         <td style="text-align:center"><input type="<%=selectType%>" name="vaults" value="<%=XSSUtil.encodeForHTMLAttribute(context, vault)%>" onclick="updateCheck('<%=selectType%>')" /></td>
<%    }
      else
      {
         String isVaultUsed = (String)vaultsMap.get("used");//DomainConstants.SELECT_USED);
         StringList secondaryVaultsList = FrameworkUtil.split(secondaryVaults, ",");

         if(isVaultUsed == null || "".equals(isVaultUsed) || "null".equals(isVaultUsed))
         {
            if (secondaryVaultsList.contains(vault))
            {
%>
               <!-- //XSSOK -->
               <td style="text-align:center"><input type="<%=selectType%>" name="vaults" value="<%=XSSUtil.encodeForHTMLAttribute(context, vault)%>" checked onclick="updateCheck('<%=selectType%>')" /></td>
<%
            }
            else
            {
%>
               <!-- //XSSOK -->
               <td style="text-align:center"><input type="<%=selectType%>" name="vaults" value="<%=XSSUtil.encodeForHTMLAttribute(context, vault)%>" onclick="updateCheck('<%=selectType%>')" /></td>
<%
            }
         }
         else
         {
%>
            <td style="text-align:center"><img src="../common/images/utilCheckOffDisabled.gif" alt="" /></td>
<%
            if (secondaryVaultsList.contains(vault))
            {
%>
               <script language="javascript">
                   checkedValue += '<%=XSSUtil.encodeForHTML(context, vault)%>' + ",";
               </script>
<%
            }
         }
      }
      String description	= i18nNow.getAdminDescriptionI18NString("eService Production","Vault", languageStr);
%>
        <td><xss:encodeForHTML><%=i18nNow.getAdminI18NString("Vault", vault, languageStr)%></xss:encodeForHTML></td>
        <td><xss:encodeForHTML><%=description%></xss:encodeForHTML></td>
    </tr>
  </framework:mapListItr>

  </table>
  </form>

<%
  // ------------------------ Page content above here  ---------------------
%>

</body>
<%@include file = "emxNavigatorBottomErrorInclude.inc"%>

</html>


