    <%--  ImportStructureOptions.jsp

    Copyright (c) 1999-2018 Dassault Systemes.

    All Rights Reserved.
    This program contains proprietary and trade secret information
    of MatrixOne, Inc.  Copyright notice is precautionary only and
    does not evidence any actual or intended publication of such program

 
      @quickreview qyg     17:07:03 : IR-522003-3DEXPERIENCER2018x show initial search result 
    --%>
 <!-- /*
* @quickreview LX6 18 Sep 12("Enhancement of import Existing Structure : filtering of the import list" )
* @quickreview LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
* @quickreview ZUD 17 Nov 16 IR-478884-3DEXPERIENCER2018x:R419-STP: Inconsistency in"duplication string" while duplicating structure from Wintop & webtop.
*/ -->   
 <%-- @quickreview T25  OEP 04 Oct 2012  (IR-178519V6R2014  TVTZ,DE-V6R2013x-CATIA-RMT-Wk32.3-
      Import_Existing_Structure -T3/S27 On Import From Exsitng- option window chapter, requirement, comment,usecase,Test case 
      are not getting translated into specific language ) 
 --%>  
 <%-- @quickreview T25 OEP 10 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags are added under
       respective scriplet
      @quickreview T25 OEP  18 Dec 2012  HL ENOVIA_GOV_RMT XSS Output Filter . XSS Output filter corresponding tags Lib is included
      @quickreview T25 DJH  18 Oct 2013  HL ENOVIA GOV RMT Cloud security (prevent XSRF & JPO injection) .corresponding .inc is included.
      @quickreview HAT1 ZUD 31 Dec 2015  IR-332062-3DEXPERIENCER2016 Prefix field is required when AutoName option is selected to Duplicate a Requirement Specification. 
      @quickreview KIE1 ZUD 15:02:24 : HL TSK447636 - TRM [Widgetization] Web app accessed as a 3D Dashboard widget.
      @quickreview HAT1 ZUD 17:08:03 : IR-512136-3DEXPERIENCER2018x: R419-FUN055837: In "Import from Existing" prefix field should not be mandatory.
      @quickreview HAT1 ZUD 17:11:29 : IR-559643-3DEXPERIENCER2018x: R419-STP:When Duplicating Requirement Specification clone relationship is created even if user unselect the option "Create clone relation ". 
 --%> 
    <%-- Include JSP for error handling --%>
    <%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>

    <%-- Common Includes --%>
    <%@include file = "emxProductCommonInclude.inc" %>
    <%@include file = "../emxUICommonAppInclude.inc"%>
    <%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
    <%@include file = "../common/emxUIConstantsInclude.inc"%>
    <%@include file = "../emxTagLibInclude.inc"%>

    <%@page import = "com.matrixone.apps.productline.*,com.matrixone.apps.domain.DomainConstants,java.util.*,java.text.*"%>
    <%@page import = "com.matrixone.apps.domain.util.FrameworkProperties,com.matrixone.apps.domain.util.FrameworkUtil,com.matrixone.apps.domain.util.PropertyUtil" %>
    <%@page import = "com.matrixone.apps.requirements.RequirementsUtil"%>
    <%@page import = "com.matrixone.apps.requirements.SpecificationStructure"%>
    <%@page import = "com.dassault_systemes.requirements.ReqConstants"%>
    <%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

    <%
        	try {
//START : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
        		String isCopyReqSpec = (emxGetParameter(request,"copyReqSpec")==null)?"false":emxGetParameter(request,"copyReqSpec");
//END : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
        		String languageStr = request.getHeader("Accept-Language");
        		String suiteKey = emxGetParameter(request, "suiteKey");
//Start:LX6:Enhancement of the import structure list        		
        		String emxTableRowId = emxGetParameter(request, "selectedObject");
        		String exludeOIDProgram = "excludeOIDprogram=emxSpecificationStructureBase:getParentsAndChildrenIds&";
//End:LX6:Enhancement of the import structure list        		
	            String Result = "";
				String actionURL = "";
        		//if cloning complete structure, SubmitLabel should be done, SubmitURL should point to ImportStructureProcess.jsp;
        		//otherwise SubmitLabel should be Next,  SubmitURL should point to ImportStructureSubmitTable.jsp.
        		//need to append targetTableRowId and choices on the form to SubmitURL
//Start:LX6:Enhancement of the import structure list
//START : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
				if(!isCopyReqSpec.equalsIgnoreCase("true"))
				{
					//this variable is only used for import structure, not for duplicate
					actionURL = "../common/emxFullSearch.jsp?field=TYPES=type_SoftwareRequirementSpecification&" + exludeOIDProgram + "emxTableRowId=" + emxTableRowId + "&" 
	        				+ "table=RMTSearchSpecificationsTable&formName=requirementSpecForm&selection=single&cancelButton=true&showInitialResults=true&"
	        				+ "showSavedQuery=True&searchCollectionEnabled=True&HelpMarker=emxhelpfullsearch&cancelLabel=emxRequirements.Button.Cancel&suiteKey=Requirements&submitAction=refreshCaller&submitURL=../requirements/MultiObjectSelect.jsp?frameName=searchPane&fieldNameActual=emxTableRowId&fieldNameDisplay=emxTableRowName";
				 
				}
//END : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
//End:LX6:Enhancement of the import structure list
        		
        		String key = emxGetParameter(request, "key");
        		Map params = (Map) session.getAttribute(key);
        		actionURL += "&key="+key;
        		String typesProperty = "";
        		//LX6: Set Parametrized requirements as a GA feature
        		//To use PlmParameterType,
        		typesProperty = EnoviaResourceBundle.getProperty(context, "emxRequirements.CloneTypes.type_RequirementSpecificationWithParameters");
        		//String typesProperty = EnoviaResourceBundle.getProperty(context, (String)params.get("typelist"));
        		String relationshipProperty = EnoviaResourceBundle.getProperty(context, (String) params.get("relationshiplist"));

        		if (relationshipProperty != null) {
        			typesProperty = typesProperty + "," + relationshipProperty;
        		}
        		
        		// ++ HAT1 ZUD: OSLC Sub and Derived Requirement Proxy. ++
        		if(typesProperty.contains("type_RequirementProxy"))
        		{
        			typesProperty = typesProperty.replace("type_RequirementProxy", 
        					"SubRequirementProxy, DerivedRequirementProxy");
        		}
        		// -- HAT1 ZUD: OSLC Sub and Derived Requirement Proxy. --

        		String[] symbolicTypes = typesProperty.split("[,]");
        		
        		String specIdToExclude = emxGetParameter(request, "specIdToExclude");
        		if(specIdToExclude == null){
        			specIdToExclude = "";
        		}
        		
        		String strTableRowId = emxTableRowId.split("[|]")[1];
        		if("".equalsIgnoreCase(specIdToExclude))
        		{
        			specIdToExclude = strTableRowId;	
        		}
        		
        		// ++ HAT1 ZUD: IR-559643-3DEXPERIENCER2018x ++
            	String fromWebApp = "";
            	fromWebApp = (String) params.get(ReqConstants.FROM_WEB_APP);
            	if(fromWebApp.equals(""))
            	{
            		fromWebApp += "";
            	}
        		// -- HAT1 ZUD: IR-559643-3DEXPERIENCER2018x --
        		String specificationLable = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.ImportStructure.ImportFrom");
        		String strObjname = "";
        		if("true".equalsIgnoreCase(isCopyReqSpec))
        		{
        			strObjname = FrameworkUtil.getObjectName(context, strTableRowId);
        			specificationLable = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.ImportStructure.copyOF");
        		}

        %>

    <%@include file = "emxValidationInclude.inc" %>
    <script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
    <script language="javascript" src="../common/scripts/emxUIModal.js"></script>
    <script language="javascript" src="../components/emxComponentsJSFunctions.js"></script>
    <script language="javascript" type="text/javaScript">
	var options = new Array();
	
    //when 'Cancel' button is pressed in Dialog Page
    function closeWindow()
    {
        //Releasing Mouse Events
	  //KIE1 ZUD TSK447636 
        parent.closeWindow();
    }
   
    // ++ HAT1 ZUD OSLC: Import Structure ++
    function validateReqOptions(value)
    {
    	//-- HAT1 ZUD: OSLC Sub and Derived Requirement Proxy.--
    	var reqProxyOptionsArr = [document.getElementsByName("SubRequirementProxy"), 
    						   document.getElementsByName("DerivedRequirementProxy")] ;
    	
    	
    	for(var i = 0; i < reqProxyOptionsArr.length; i++)
    	{
    		var reqProxyOptions = reqProxyOptionsArr[i];
    		switch(value)
        	{
        		case "Copy":
        			if(reqProxyOptions.length == 2)
        			{
        				//Requirement Duplicate -> "Req Proxy" Reference & None enabled. 
        				reqProxyOptions[0].disabled = false;
        				reqProxyOptions[1].disabled = false;
        				//Requirement Duplicate -> "Req Proxy" Reference checked.
        				reqProxyOptions[0].checked = true;
        				reqProxyOptions[1].checked = false;
        			}
        			break;
        		case "Reference":
        			if(reqProxyOptions.length == 2)
        			{
        				//Requirement Reference -> "Req Proxy" Reference enabled & None disabled. 
        				reqProxyOptions[0].disabled = false;
        				reqProxyOptions[1].disabled = true;
        				//Requirement Reference -> "Req Proxy" Reference checked & None unchecked.
        				reqProxyOptions[0].checked = true;
        				reqProxyOptions[1].checked = false;
        			}
        			break;
        		case "None":
        			if(reqProxyOptions.length == 2)
        			{
        				//Requirement None -> "Req Proxy" Reference disabled & None disabled. 
        				reqProxyOptions[0].disabled = true;
        				reqProxyOptions[1].disabled = false;
        				//Requirement None -> "Req Proxy" Reference unchecked & None unchecked.
        				reqProxyOptions[0].checked = false;
        				reqProxyOptions[1].checked = true;
        			}
        			break;
        		default:
    		}	
    	}
    }
 // -- HAT1 ZUD OSLC: Import Structure --
    
//START : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
    function duplicateReqSpec()
    {
    	 var namebadCharName = checkForNameBadCharsList(document.requirementSpecForm.prefix);	
    	if (namebadCharName.length != 0)    
        {
            alert( "<emxUtil:i18nScript localize="i18nId">emxRequirements.Alert.InvalidChars</emxUtil:i18nScript>" + namebadCharName + "<emxUtil:i18nScript localize="i18nId">emxRequirements.Alert.RemoveInvalidChars</emxUtil:i18nScript>" );
            document.requirementSpecForm.prefix.focus();
            return;
        }
    	
    	 if(document.requirementSpecForm.prefix.value != "")
         {
             var CMN = document.requirementSpecForm.prefix.value;
             // this will get rid of leading spaces
             while (CMN.substring(0,1) == ' ')
                 CMN = CMN.substring(1, CMN.length);

             // this will get rid of trailing spaces
             //while (CMN.substring(CMN.length-1,CMN.length) == ' ')
             //    CMN = CMN.substring(0, CMN.length-1);

             eval("document.requirementSpecForm.prefix.value = CMN");
         } 
 		// HAT1 ZUD IR-332062-3DEXPERIENCER2016
     
     	if(document.requirementSpecForm.isComplete[0].checked){
    		document.requirementSpecForm.action += "&submitLabel=emxRequirements.Button.Done&submitURL=../requirements/ImportStructureProcess.jsp?"; //complete
    	
    	}else{
    		document.requirementSpecForm.action += "&submitLabel=emxRequirements.Button.Next&submitURL=../requirements/ImportStructureSubmitTable.jsp?";
    	}
     	document.requirementSpecForm.action += "&copyReqSpec=true";
     	document.requirementSpecForm.action += "&options=";

		// HAT1 ZUD: IR-559643-3DEXPERIENCER2018x 
    	document.requirementSpecForm.action += "<xss:encodeForJavaScript><%=ReqConstants.FROM_WEB_APP%></xss:encodeForJavaScript>:<xss:encodeForJavaScript><%=fromWebApp%></xss:encodeForJavaScript>;";
    	document.requirementSpecForm.action += "isComplete:" + document.requirementSpecForm.isComplete[0].checked;
    	//document.requirementSpecForm.action += ";autoName:" + document.requirementSpecForm.Autoname.checked;
    	document.requirementSpecForm.action += ";key:<xss:encodeForJavaScript><%=key%></xss:encodeForJavaScript>;";
    	document.requirementSpecForm.action += ";key:<xss:encodeForJavaScript><%=key%></xss:encodeForJavaScript>;";
    	if((document.requirementSpecForm.CopyWithLink != null)&&(document.requirementSpecForm.CopyWithLink != "undefined"))
    	{
    	    document.requirementSpecForm.action += "CopyWithLink:" + document.requirementSpecForm.CopyWithLink.checked.toString() + ";";
    	}
    	
    	for(var i = 0; i < options.length; i++){
    		var option = options[i];
    		for(var j = 0; j < option.length; j++){
    			if(option[j].checked){
    				switch (option[j].value){// ++ HAT1 ZUD OSLC: Import Structure ++
					case "Copy": 
    						document.requirementSpecForm.action += option[j].name + ":" + "Copy;";
    						break;
					case "Reference":
    						document.requirementSpecForm.action += option[j].name + ":" + "Reference;";
    						break;
    				case "None":
	    					document.requirementSpecForm.action += option[j].name + ":" + "None;";
    						break;
 					}// -- HAT1 ZUD OSLC: Import Structure --
    				break;
    			}
    		}
    	}
    	
        document.requirementSpecForm.submit();
    			//getTopWindow().opener = "x";
		//getTopWindow().close();
    }
//END : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications   
    //When Next button Pressed on the form
    function submitForm()
    {
    	//if(!document.requirementSpecForm.Autoname.checked){
         var namebadCharName = checkForNameBadCharsList(document.requirementSpecForm.prefix);
         if (namebadCharName.length != 0)    
            {
                alert( "<emxUtil:i18nScript localize="i18nId">emxRequirements.Alert.InvalidChars</emxUtil:i18nScript>" + namebadCharName + "<emxUtil:i18nScript localize="i18nId">emxRequirements.Alert.RemoveInvalidChars</emxUtil:i18nScript>" );
                document.requirementSpecForm.prefix.focus();
                return;
            }
         if(document.requirementSpecForm.prefix.value != "")
            {
                var CMN = document.requirementSpecForm.prefix.value;
                // this will get rid of leading spaces
                while (CMN.substring(0,1) == ' ')
                    CMN = CMN.substring(1, CMN.length);

                // this will get rid of trailing spaces
                //while (CMN.substring(CMN.length-1,CMN.length) == ' ')
                //    CMN = CMN.substring(0, CMN.length-1);

                eval("document.requirementSpecForm.prefix.value = CMN");
            }
    	
         if(document.requirementSpecForm.emxTableRowName.value == "")
  		{
  			alert( "<emxUtil:i18nScript localize="i18nId">emxRequirements.Alert.emptySpecification</emxUtil:i18nScript>");
  			document.requirementSpecForm.emxTableRowName.focus();
  			return;
  		}
         	                
    	if(document.requirementSpecForm.isComplete[0].checked){
    	
    		document.requirementSpecForm.action = "../requirements/ImportStructureProcess.jsp?"; //complete
    	
    	}else{
    		document.requirementSpecForm.action = "../requirements/ImportStructureSubmitTable.jsp?submitLabel=emxRequirements.Button.Next&cancelLabel=emxRequirements.Button.Cancel&suiteKey=Requirements&cancleButton=true&";
    	}
    	
    	document.requirementSpecForm.action += "options=";

    	
    	document.requirementSpecForm.action += "<xss:encodeForJavaScript><%=ReqConstants.FROM_WEB_APP%></xss:encodeForJavaScript>:<xss:encodeForJavaScript><%=fromWebApp%></xss:encodeForJavaScript>;";
    	document.requirementSpecForm.action += "isComplete:" + document.requirementSpecForm.isComplete[0].checked;
    	//document.requirementSpecForm.action += ";autoName:" + document.requirementSpecForm.Autoname.checked;
   		//requirementSpecForm.action += ";prefix:" + document.requirementSpecForm.prefix.value; //i18n characters in URL causing problems
    	document.requirementSpecForm.action += ";key:<xss:encodeForJavaScript><%=key%></xss:encodeForJavaScript>;";
    	if((document.requirementSpecForm.CopyWithLink != null)&&(document.requirementSpecForm.CopyWithLink != "undefined"))
    	{
    	    document.requirementSpecForm.action += "CopyWithLink:" + document.requirementSpecForm.CopyWithLink.checked.toString() + ";";
    	}
    	
    	for(var i = 0; i < options.length; i++){
    		var option = options[i];
    		for(var j = 0; j < option.length; j++){
    			if(option[j].checked){
    				switch (option[j].value){// ++ HAT1 ZUD OSLC: Import Structure ++
    					case "Copy": 
    						document.requirementSpecForm.action += option[j].name + ":" + "Copy;";
    						break;
    					case "Reference":
    						document.requirementSpecForm.action += option[j].name + ":" + "Reference;";
    						break;
	    				case "None":
	    					document.requirementSpecForm.action += option[j].name + ":" + "None;";
    						break;
     				}// -- HAT1 ZUD OSLC: Import Structure --
    				break;
    			}
    		}
    	}
    	
        document.requirementSpecForm.submit();
    }

    	
    function findParentSpec()
    {
		var url = "<xss:encodeForJavaScript><%=actionURL%></xss:encodeForJavaScript>";
		url+= "&excludeOID=" + "<xss:encodeForJavaScript><%=specIdToExclude%></xss:encodeForJavaScript>";
		url+= "&key=<xss:encodeForJavaScript><%=key%></xss:encodeForJavaScript>";
		showChooser(url, 700,500);
    }
    function checkParent()
    {
    	alert("hi");
    }
    
    function clearField()
    {
    	document.getElementsByName("emxTableRowName")[0].value = "";
    }
	function handleAutoName(){
		document.requirementSpecForm.prefix.disabled=document.requirementSpecForm.Autoname.checked;
	}
//START : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
	function completeChecked(){
	document.requirementSpecForm.action = "../requirements/ImportStructureProcess.jsp?" + "copyReqSpec=true"+"&emxTableRowId=" + "<%=XSSUtil.encodeForJavaScript(context, emxTableRowId)%>" + "&selectedProgram=emxSpecificationStructure:expandTreeWithRefCopyObjects";
	}
	function partialChecked(){
	document.requirementSpecForm.action = "../requirements/ImportStructureSubmitTable.jsp?" + "copyReqSpec=true"+"&emxTableRowId=" + "<%=XSSUtil.encodeForJavaScript(context, emxTableRowId)%>" + "&selectedProgram=emxSpecificationStructure:expandTreeWithRefCopyObjects";
	}
	
	function lableDone()
	{ 
		parent.document.getElementById("bottomCommonForm").elements[0].textContent = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Button.Done")%></xss:encodeForJavaScript>";
	}
	function lableNext()
	{ 
		parent.document.getElementById("bottomCommonForm").elements[0].textContent  = "<xss:encodeForJavaScript><%=EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(), "emxRequirements.Button.Next")%></xss:encodeForJavaScript>";
	}
//END : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
    </script>
    
    <%@include file = "../emxUICommonHeaderEndInclude.inc"%>
<!-- //START : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications -->
	<%
    if(isCopyReqSpec.equalsIgnoreCase("true"))
    {
    %>
    	<form name="requirementSpecForm" method="post" action="<xss:encodeForHTMLAttribute><%=actionURL%></xss:encodeForHTMLAttribute>" target="_parent" onsubmit="javascript:duplicateReqSpec(); return false">
    	<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
	<% 
    }
    else
    {
	%>
		<form name="requirementSpecForm" method="post" action="<xss:encodeForHTMLAttribute><%=actionURL%></xss:encodeForHTMLAttribute>" target="_parent" onsubmit="javascript:submitForm(); return false">	
		<%@include file = "../common/enoviaCSRFTokenInjection.inc"%>
			
	<%
    }
	%>
	
<!-- //END : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications -->
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
      <tr>
        <td width="200" class="label" >
                <emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.CopyorRef</emxUtil:i18n> 
        </td>
        <td  class="inputField">
<!-- //START : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications -->
   <%
    if(isCopyReqSpec.equalsIgnoreCase("true"))
    {
    %>
    
    	<input type="radio"  name="isComplete" value="complete" onchange="completeChecked()" checked/><emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.Complete</emxUtil:i18n><br/>
        <input type="radio"  name="isComplete" value="partial" onchange="partialChecked()"/><emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.Partial</emxUtil:i18n>
    	
          
    <%
    }
    else
    {
    %>
	     <input type="radio"  name="isComplete" value="complete" onchange="lableDone()" /><emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.Complete</emxUtil:i18n><br/>
         <input type="radio"  name="isComplete" value="partial" onchange="lableNext()" checked/><emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.Partial</emxUtil:i18n>
    <%
    }    
    %>
<!-- //START : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications -->
        </td>
      </tr>  
      <tr>
        <td width="200" class="label" >
                <emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.CopyWithLink</emxUtil:i18n> 
        </td>
       	<td class="inputField">
	    	<input class="inputField"type="checkbox" name="CopyWithLink" checked />
	        <emxUtil:i18n localize="i18nId">emxRequirements.Label.CreateCopyRelation</emxUtil:i18n>
	    </td>
      </tr>
	</table>
	
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
<%
	for (int i = 0; i < symbolicTypes.length; i++) {
			String symbolicType = symbolicTypes[i].trim();
			
			String realType = "";
			String i18nType = "";
			if(symbolicType.equalsIgnoreCase("SubRequirementProxy"))
			{
				realType = "Sub Requirement Proxy";
			}
			else if(symbolicType.equalsIgnoreCase("DerivedRequirementProxy"))
			{
				realType = "Derived Requirement Proxy";
			}
			else
			{
				realType = PropertyUtil.getSchemaProperty(context,
						symbolicType);
			}
			
	   		// Start:IR-178519V6R2014:T25
	  		//Review:OEP0		
			i18nType = i18nNow.getTypeI18NString(realType, languageStr);
	  		//END:IR-178519V6R2014:T25
	  
			if (i18nType.equalsIgnoreCase("Sub Requirement")
					|| i18nType.equalsIgnoreCase("Derived Requirement")) {
				String strReplaceType = i18nType.replace(" ", "");
				String sbStatus = "emxRequirements.ActionLink.";
				sbStatus += strReplaceType;
				i18nType = EnoviaResourceBundle.getProperty(context, "emxRequirementsStringResource", context.getLocale(),sbStatus);
			}

			String action = FrameworkProperties
					.getProperty(context, "emxRequirements.CloneTypes."
							+ symbolicType + ".Default");
			if (action == null || action.trim().length() == 0) {
				action = "Copy";
			}
%>
      <tr>
        <td width="200" class="label" >
            <xss:encodeForHTML><%=i18nType%></xss:encodeForHTML>
        </td>
        <td  class="inputField">
          <!--  Start HAT1 ZUD OSLC: Import Structure  --> 
          <%
          if(symbolicType.equals("SubRequirementProxy") 
        		  || symbolicType.equals("DerivedRequirementProxy"))
          {
	          %>
	          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="Reference" <%="Reference".equalsIgnoreCase(action) ? "checked": ""%> /><emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.Reference</emxUtil:i18n>
	          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="None" <%="None".equalsIgnoreCase(action) ? "checked" : ""%> disabled=true /><emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.None</emxUtil:i18n>
			  <%
          }
          else if(symbolicType.equals("type_Requirement"))
          {
        	  %>
	          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="Copy" 
	          		onchange="validateReqOptions(this.value)"  <%= "Copy".equalsIgnoreCase(action) ? "checked" : ""%> /> <emxUtil:i18n localize="i18nId">emxRequirements.Label.CopyReqSpec</emxUtil:i18n>
	
	          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="Reference" 
	          		 onchange=validateReqOptions(this.value) <%="Reference".equalsIgnoreCase(action) ? "checked": ""%> /> <emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.Reference</emxUtil:i18n>
	          
	          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="None" 
	          		 onchange=validateReqOptions(this.value) <%="None".equalsIgnoreCase(action) ? "checked" : ""%> /> <emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.None</emxUtil:i18n>
	          <%
          }
          else
          {
        	  %>
          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="Copy" <%="Copy".equalsIgnoreCase(action) ? "checked" : ""%> /><emxUtil:i18n localize="i18nId">emxRequirements.Label.CopyReqSpec</emxUtil:i18n>
	          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="Reference" <%="Reference".equalsIgnoreCase(action) ? "checked": ""%> /><emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.Reference</emxUtil:i18n>
          <input type="radio"  name="<xss:encodeForHTMLAttribute><%=symbolicType%></xss:encodeForHTMLAttribute>" value="None" <%="None".equalsIgnoreCase(action) ? "checked" : ""%> /><emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.None</emxUtil:i18n>
	          <%
          }
          
          %>
          <!--  End HAT1 ZUD OSLC: Import Structure  --> 
        </td>
      </tr>
<script language="javascript" type="text/javaScript">
//START : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
<%
if(isCopyReqSpec.equalsIgnoreCase("true"))
{
%>
	document.requirementSpecForm.action = "../requirements/ImportStructureProcess.jsp?" + "copyReqSpec=true"+"&emxTableRowId=" + "<%=XSSUtil.encodeForJavaScript(context, emxTableRowId)%>" + "&selectedProgram=emxSpecificationStructure:expandTreeWithRefCopyObjects";
<%
}
%>
//END : LX6 17 Jul 13 Function_037278 ENOVIA GOV RMT Duplicate Requirement Specifications
	options.push(document.requirementSpecForm.<xss:encodeForJavaScript><%=symbolicType%></xss:encodeForJavaScript>);
</script>

<%
	}
%>
	<table border="0" cellpadding="5" cellspacing="2" width="100%">
	<tr>
	 	<td width="150" nowrap="nowrap" class="labelRequired">
        		<label><%=specificationLable%></label>
       </td>
		<td nowrap="nowrap" class="field">
			 <input type="text" name="emxTableRowName" size="20" readonly="readonly" value="<xss:encodeForHTMLAttribute><%=strObjname%></xss:encodeForHTMLAttribute>" required="required"/>
         	 <input type="hidden" name=emxTableRowId value="<xss:encodeForHTMLAttribute><%= emxTableRowId %></xss:encodeForHTMLAttribute>" />
         	
	         
	          <%
		    if(!isCopyReqSpec.equalsIgnoreCase("true"))
		    {
		    %>
		   		<input class="button" type="button" name="btnType" size="200" value="..." alt=""  onClick="javascript:findParentSpec();"/>
			 	<input class="button" type="reset" name="reset" size="200" value="<emxUtil:i18n localize="i18nId">emxRequirements.Button.Clear</emxUtil:i18n>" alt=""  onClick="javascript:clearField();"/>
		    <%
		    }    
		    %>
		    
	          
       </td>
       </tr>
	<table>
	</table>
	
    <table border="0" cellpadding="5" cellspacing="2" width="100%">
	    <tr>
	    <td class="label" width="200" >  <!--  HAT1 ZUD: IR-512136-3DEXPERIENCER2018x fix -->
	        <emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Label.Prefix</emxUtil:i18n>
	    </td>
<%
if(isCopyReqSpec.equalsIgnoreCase("true"))
{
%>
	    <td class="inputField" align="left"><input type="text" name="prefix" size="20" value="<emxUtil:i18n localize="i18nId">emxRequirements.CopyReqSpec.Prefix.Default</emxUtil:i18n>"/>
<%
}
else
{
%>
		<td class="inputField" align="left"><input type="text" name="prefix" size="20" value="<emxUtil:i18n localize="i18nId">emxRequirements.ImportStructure.Prefix.Default</emxUtil:i18n>"/>	    
<%
}
%>
		</td>
	    </tr>
	</table>
       
	</form>
    <%
    	} catch (Exception ex) {
    		session.putValue("error.message", ex.getMessage());
    	}
    %>

   <%@include file = "../common/emxNavigatorBottomErrorInclude.inc"%>
   <%@include file = "../emxUICommonEndOfPageInclude.inc"%>

