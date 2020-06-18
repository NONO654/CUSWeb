<%-- JIC 13:07:04 IR IR-241854V6R2013x: Created file                       --%>
<%@page import="com.matrixone.vplm.posbusinessmodel.SecurityContext"%>
<%@page import="com.matrixone.vplm.posbusinessmodel.PeopleUtil"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="com.dassault_systemes.pos.resource.interfaces.PLMxPosTableServices" %>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfig"%>
<%@ page import="com.dassault_systemes.vplmadmin.InstallConfigManager"%>
<%@ page import="com.matrixone.apps.common.Person" %>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo" %>
<%@ page import="matrix.db.BusinessObjectWithSelect" %>
<%@ page import="matrix.util.StringList" %>
<%@ page import="com.matrixone.apps.domain.DomainConstants" %>
<%@ page import="com.matrixone.vplm.posbusinessmodel.PeopleConstants" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../emxJSValidation.inc" %>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%!
    /*

     * Adds a line to a section
     *
     * @param id    the line id
     * @param chk   the 'checkbox' checked flag
     * @param state the line state (unknown, available, unavailable)
     * @param title the line title
     */
    public void addLine(JspWriter out, String id, boolean checked, String state, String nls_state, String title) throws IOException {
        out.println("<tr>");
        String sChecked = checked ? " checked=\"checked\"" : "";
        out.println("  <td></td>");
		// ALU4 17:08:24 IR-536079-3DEXPERIENCER2017x IFW and CSV are selected by default. This IR consists in making CSV optional.
		if(id.equals("IFW"))
        out.println("  <td><input type=\"checkbox\" id=\"lic_"+id+"_chk\" name=\"lic_"+id+"_chk\" value=\""+id+"\" onclick=\"clic(this);\" checked=\"checked\" disabled=\"disabled\"></td>");
		else
        out.println("  <td><input type=\"checkbox\" id=\"lic_"+id+"_chk\" name=\"lic_"+id+"_chk\" value=\""+id+"\" onclick=\"clic(this);\""+sChecked+"></td>");
        out.println("  <td></td>");
        out.println("  <td><img src=\"images/iconLicense"+state+".gif\" id=\"lic_"+id+"\" title=\""+nls_state+"\" style=\"cursor:pointer\"></td>");
        out.println("  <td><div id=\"lic_"+id+"_txt\">"+title+"</div></td>");
        out.println("</tr>");
    }
	    %>
<%

    String nlsINFO_UNKNOWN      =  getNLS("LicenseUnknown");
    String nlsINFO_UNAVAIL      =  getNLS("LicenseUnavailable");
    String nlsINFO_UNAVAIL_WARN =  getNLS("LicenseUnavailableWarning");
    String nlsINFO_AVAILABLE    =  getNLS("LicenseAvailable");
    String nlsINFO_SELECTALL    =  getNLS("LicenseSectionSelectUnselectAll");
    String nlsLicSection1       =  getNLS("LicenseSectionUsed");
    String nlsLicSectionFilter  =  getNLS("LicenseSectionFilter");
    String nlsLicSection2       =  getNLS("LicenseSectionOther");
    String nlsWARNING_CONTRACTOR_AVAILABLE = getNLS("WarningAdminSecurityContextsRemovedBecauseOfContractor");
    String nlsWARNING_CONTRACTOR_ASSIGNED = getNLS("WarningAdminSecurityContextsUnassignedBecauseOfContractor");
    String nlsCONFIRM_CONTRACTOR = getNLS("msgConfirmContractor");
	
        // Get person ID
        String PLM_ExternalID = emxGetParameter(request, "PLM_ExternalID");
%>
<html>
	<head>
        <style>
            div.horiz      { width:100%; position:relative; }
            div.divHauts   { height:45%; }
            div.divMilieus { height:50%; margin-left:-1px; overflow:auto; }
            div.divBass    { height:6%; }
            div.scroll-cont{ 
                            float:left; overflow:auto;
                            width:49%;   /* a cause des marges (et de leur gestion differente par IE et FF, il  */
                                         /* faut prendre un % de longueur inferieur a 50%                       */
                            height:100%; /* il est capital de fixer height pour que scroll-bloc ne deborde pas! */
            }
            div.licHeader {border:0px; background:#dfdfdf;}
            .tableLicMargin       {width:32; background:white; }
            .tableLicCheckbox     {width:32;}
            .tableLicAvailability {width:32;}
            .tableLicTitle        {}
        </style>
        <script>
		
  function clic(elem)
  {
      var id = elem.id.substring(0,elem.id.length-4);
      var img = $(id);
      if (!elem.checked) {
          // now unchecked
          // checking whether there was a 'warning' msg
          if (img != undefined) {
              if (img.src.indexOf('iconLicenseError.gif')>=0) {
                  // there was a warning : reset to 'unavailable'
                  setUnavailable(img);
              }
          }
      }
      else {
            // now checked
          if (img != undefined) {
              if (img.src.indexOf('iconLicenseUnavailable.gif')>=0) {
                  // warning : reset to 'unavailable'
                  setUnavailable(img);
              }
          }
      }
  }

  function searchKeyPress(e)
    {
        if (typeof e == 'undefined' && window.event) { e = window.event; }
        if (e.keyCode == 13)
        {
			var butt = "btn";
			if(e.target) butt = butt+e.target.id;
			else if(e.srcElement) butt = butt+e.srcElement.id;
            document.getElementById(butt).click();
        }
    }
	
			function effacer() // left <--
            {
                var selectBox = document.getElementById("SecurityContextsElse");
                var sizeSelectBox = selectBox.options.length - 1;

                while (sizeSelectBox >= 0)
                {
                    if(selectBox.options[sizeSelectBox].selected)
                    {
                    	//RBR2: FUN [080973] Title based Operations
                        var textValue = selectBox.options[sizeSelectBox].value;
                        var textID = selectBox.options[sizeSelectBox].value;
                        var text = selectBox.options[sizeSelectBox].text.toString();
                    	selectBox.options[sizeSelectBox]=null;
                    	var opt = new Option(text,textID);
                    	opt.id = textID; 
                    	opt.setAttribute("title","Name: "+textID);
                    	document.getElementById("SecurityContextsHas").options[ document.getElementById("SecurityContextsHas").options.length] = opt;
                   		document.getElementById("stockAdd").value = document.getElementById("stockAdd").value+ "," + textID; // existing + new name
			 			if (document.getElementById("stockRemove").value.indexOf(","+textID) != -1)
			 			{
			 				var value2Add = document.getElementById("stockRemove").value;
			 				document.getElementById("stockRemove").value = value2Add.substring(0,value2Add.indexOf("," + textID)) + value2Add.substring(value2Add.indexOf("," + textID)+textID.length+1,value2Add.length);
			 			}
                	}
                	sizeSelectBox = sizeSelectBox - 1;
            	}
            }

	        function ajouter() //Right -->
	        {
                var selectBox = document.getElementById("SecurityContextsHas");
            	var sizeSelectBox = selectBox.options.length - 1;

                while (sizeSelectBox >= 0)
                {
                	if(selectBox.options[sizeSelectBox].selected)
                	{	
                		//RBR2:FUN [080973]  Title based Operations
                		var textValue = selectBox.options[sizeSelectBox].value; 
                        var textID = selectBox.options[sizeSelectBox].value; 
                        var text = selectBox.options[sizeSelectBox].text.toString(); 
                    	selectBox.options[sizeSelectBox]=null;
                    	var opt = new Option(text,textID);
                    	opt.id = textID;
                    	opt.setAttribute("title","Name: "+textID);
                    	document.getElementById("SecurityContextsElse").options[ document.getElementById("SecurityContextsElse").options.length]=opt;
                    	document.getElementById("stockRemove").value = document.getElementById("stockRemove").value + "," + textID;
			 			if (document.getElementById("stockAdd").value.indexOf(","+textID) != -1)
			 			{
			 				// Removing the entry of Removed Sec Ctx Name from "StockAdd" element
							var value2Add = document.getElementById("stockAdd").value;
							document.getElementById("stockAdd").value = value2Add.substring(0,value2Add.indexOf("," + textID)) + value2Add.substring(value2Add.indexOf("," + textID)+textID.length+1,value2Add.length);
			 			}
		            }
                	sizeSelectBox = sizeSelectBox - 1;
	            }
			}
			
        var xmlreqs = new Array();
	   
        function filtrer(){
           // RBR2:Operates for Title now
           var filter = document.getElementById("sctxstoadd").value;
		   if(filter==null || filter=="") filter = "*";
    		xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Context&Destination=VPLMAdmin&saveFilter=yes&ctxFilter="+encodeURIComponent(filter),formatResponseCtx,0);
        }

        function filtrer2(){
            // RBR2:Operates for Title now
            var filter = document.getElementById("sctxsassigned").value;
		    if(filter==null || filter=="") filter = "*";
    		xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=UserCtx&Destination=VPLMAdmin&ctxFilter="+encodeURIComponent(filter)+"&SearchUser="+encodeURIComponent("<%=PLM_ExternalID%>"),formatResponseCtx2,2);
		}
		
        // This recieves the Already assigned context
    	function formatResponseCtx()
        {
            var xmlhttp= xmlreqs[0];

            xmlhttp.onreadystatechange=function()
            {
               if(xmlhttp.readyState==4)
                { 
					var has = document.getElementById("stockAssigned").value; // This will give ID 
                    var tableCtxHas = document.getElementById("SecurityContextsHas");
                    var tableCtxElse = document.getElementById("SecurityContextsElse");
					while(tableCtxElse.hasChildNodes()) tableCtxElse.removeChild(tableCtxElse.lastChild);
                    var ctxs = xmlhttp.responseXML.getElementsByTagName("PLM_ExternalID");
                    var ctxsTitle = xmlhttp.responseXML.getElementsByTagName("V_Name");
					for(var i = 0 ; i < ctxs.length ; i++ ){
						var sctx = ctxs[i].firstChild.data;
						var scTxTitle = ctxsTitle[i].firstChild.data;
						if(has.indexOf(","+sctx+",") != -1) continue;
                    	var opt = new Option(scTxTitle,sctx,false,false); // Title as text to be displayed
                    	opt.id = sctx; // Assign Name as ID
                    	opt.setAttribute("title","Name: "+sctx);
                    	tableCtxElse.options[tableCtxElse.options.length] = opt;
                    }
					refreshAdminSecurityContexts();
                }
            }
		}
		
    	// This recieves the response of ctx those can be assigned.
    	function formatResponseCtx2()
        {
            var xmlhttp1= xmlreqs[2];

            xmlhttp1.onreadystatechange=function()
            {
               if(xmlhttp1.readyState==4)
                { 
                    var tableCtxHas = document.getElementById("SecurityContextsHas");
					while(tableCtxHas.hasChildNodes()) tableCtxHas.removeChild(tableCtxHas.lastChild);
                    var ctxs = xmlhttp1.responseXML.getElementsByTagName("PLM_ExternalID");
                    var ctxsTitle = xmlhttp1.responseXML.getElementsByTagName("V_Name");
					for(var i = 0 ; i < ctxs.length ; i++ ){
						var sctx = ctxs[i].firstChild.data;
						var scTxTitle = ctxsTitle[i].firstChild.data;
                    	var opt = new Option(scTxTitle,sctx,false,false);
                    	opt.id = sctx; // Assign Name as ID
                    	opt.setAttribute("title","Name: "+sctx);
                    	tableCtxHas.options[tableCtxHas.options.length] = opt;
                    }
					refreshAdminSecurityContexts();
                }
            }
		}

        // update NLS title help
        nlsINFO_SELECTALL      = "<%=nlsINFO_SELECTALL%>";
        nlsINFO_AVAILABLE      = "<%=nlsINFO_AVAILABLE%>";
        nlsINFO_UNAVAIL        = "<%=nlsINFO_UNAVAIL%>";
        nlsSECTION_AVAIL          = "<%=myNLS.getMessage("LicenseSectionAvailable")%>";
        nlsSECTION_UNAVAIL_RICH   = "<%=myNLS.getMessage("LicenseSectionUnavailableRich")%>";
        nlsSECTION_UNAVAIL_SERVER = "<%=myNLS.getMessage("LicenseSectionUnavailableServer")%>";
        nlsWARNING_CONTRACTOR_ASSIGNED  = "<%=nlsWARNING_CONTRACTOR_ASSIGNED%>";
        nlsWARNING_CONTRACTOR_AVAILABLE  = "<%=nlsWARNING_CONTRACTOR_AVAILABLE%>";
        nlsCONFIRM_CONTRACTOR  = "<%=nlsCONFIRM_CONTRACTOR%>";

        var prev_filter_lic = "";
        var filter_lic = false;

        function initXPPerson(){
             /* Request to get the Licenses */
            // JIC 15:04:21 Added parameters "CasualHour" and "User"
            var destCasualHour = "User="+encodeURIComponent("<%=PLM_ExternalID%>")+"&CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp",destCasualHour,getLicensesResponse,1);
        }

        // JIC 15:04:23 Added function "CheckUncheckCasual"
        function CheckUncheckCasual() {     
            var destCasualHour = "User="+encodeURIComponent("<%=PLM_ExternalID%>")+"&CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp",destCasualHour,getLicensesResponse,1);
        }

        // 2014:10:24 Added method "refreshAdminSecurityContexts" for Contractor support
        // RBR2: FUN[080973] shifted from inner Text to attribute ID of Options holding Context
        function refreshAdminSecurityContexts() {
			var ctxadminremoved = "\n";
            var isHiddenContext = false;
            var isContractor = document.getElementById("Contractor").checked;

            var contexts = document.getElementById("SecurityContextsHas");
            for (var j=0; j<contexts.options.length ;j++){
                var contextTitle = contexts.options[j].text; // RBR2: Now provides the Title
                var contextName = contexts.options[j].id; // RBR2: Provided name
                var roleName = contextName.substring(0, contextName.indexOf("."));
                // Note: Following code will not work with custom admin roles
                if (roleName == "VPLMAdmin") {
                    if (isContractor){
                        contexts.options[j].selected = true;
						ctxadminremoved = ctxadminremoved+contextName+"\n";
                        isHiddenContext = true;
                    }
                }
            }
			
            if (isHiddenContext){
                var r = confirm(nlsWARNING_CONTRACTOR_ASSIGNED+ctxadminremoved+nlsCONFIRM_CONTRACTOR);
				if(r == true) {
					ajouter();
				} else {
					document.getElementById("Contractor").checked = false;
					contexts = document.getElementById("SecurityContextsHas");
					for (var j=0; j<contexts.options.length ;j++){
                        contexts.options[j].selected = false;
                    }
					return;
				}
            }
			
            contexts = document.getElementById("SecurityContextsElse");
            for (var j=0; j<contexts.options.length ;j++){
                var contextTitle = contexts.options[j].text; // RBR2: Now provides the Title
                var contextName = contexts.options[j].id; // RBR2: Provided name
                var roleName = contextName.substring(0, contextName.indexOf("."));
                // Note: Following code will not work with custom admin roles
                if (roleName == "VPLMAdmin") {
                    if (isContractor){
                        contexts.options[j].selected = false;
                        contexts.options[j].disabled = 'true';
                   }
                    else{
                        contexts.options[j].disabled = '';
                    }
                }
            }
        }
        </script>
    </head>
    <body onload="javascript:initXPPerson();refreshAdminSecurityContexts()">
        <%
    TreeMap mapUserLicenses = new TreeMap();
    if (PLM_ExternalID.length()>0) {
        Vector lListOfUserLicenses = new Vector();
        LicenseInfo.getUserLicenses(context, PLM_ExternalID, lListOfUserLicenses);
        for (int i = 0; i < lListOfUserLicenses.size(); i++) {
            String s = (String)lListOfUserLicenses.get(i);
            mapUserLicenses.put(s,s);
        }
    }
    TreeMap lics = new TreeMap();
    LicenseInfo.getDeclaredLicenses(context, lics, request.getLocale());
    //JIC 14:04:02 Added license status update
    LicenseInfo.updateLicensesStatus(context, lics);
    Collection licinfos = lics.values();
		
	String HostCompanyName= getHostCompanyName(mainContext);

	PreferencesUtil pouf = new PreferencesUtil();
    String CtxFilterHas= pouf.getUserPreferredUIAssignedCtxFilter(mainContext);
    String CtxFilterElse= pouf.getUserPreferredUIAvailableCtxFilter(mainContext);
		
        String source = (String)emxGetParameter(request, "source");
        if (source==null)
        {
            source = "";
        }

       	String name = PLM_ExternalID;
        String firstName = "";
   	    String lastName = "";
       	String emailAddress = "";
        String address = "";
   	    String city = "";
       	String postalCode = "";
       	String stateRegion = "";
       	String country = "";
        String homePhoneNumber = "";
	    String workPhoneNumber = "";
	    String alias = "";
		String currentState = "";
        // JIC 2014:10:24 Added Contractor support
        boolean isContractor = false;
		String employeeCompanyName = "";
		String memberOrganizationNames = "";
		String assignedSecurityContextNames = ",";
		// RBR2: Added this FUN [080973]
		String assignedSecurityContextTitles = ",";
		String secLevel = "";
        // JIC 15:03:18 Adde Casual Hour support
        int casualHour = 0;
        try
        {
	        // Get person
	        Person person = Person.getPerson(mainContext, PLM_ExternalID);

	        // Get person information
	        person.open(mainContext);
        	name = PLM_ExternalID;
	        StringList lstAttributeName = new StringList();
	        lstAttributeName.addElement(Person.ATTRIBUTE_FIRST_NAME);
	        lstAttributeName.addElement(Person.ATTRIBUTE_LAST_NAME);
	        lstAttributeName.addElement(Person.ATTRIBUTE_EMAIL_ADDRESS);
	        lstAttributeName.addElement(Person.ATTRIBUTE_ADDRESS);
	        lstAttributeName.addElement(Person.ATTRIBUTE_CITY);
	        lstAttributeName.addElement(Person.ATTRIBUTE_POSTAL_CODE);
	        lstAttributeName.addElement(Person.ATTRIBUTE_STATE_REGION);
	        lstAttributeName.addElement(Person.ATTRIBUTE_COUNTRY);
	        lstAttributeName.addElement(Person.ATTRIBUTE_HOME_PHONE_NUMBER);
	        lstAttributeName.addElement(Person.ATTRIBUTE_WORK_PHONE_NUMBER);
            lstAttributeName.addElement(PeopleConstants.ATTRIBUTE_CASUAL_HOUR);
	        AttributeList lstAttribute = person.getAttributeValues(mainContext, lstAttributeName);
	        for (int i = 0; i < lstAttribute.size(); i++)
	        {
	            Attribute attribute = (Attribute)lstAttribute.get(i);
	            if (attribute.getName().equals(Person.ATTRIBUTE_FIRST_NAME))
	            {
	                firstName = attribute.getValue();
	            }
	            else if (attribute.getName().equals(Person.ATTRIBUTE_LAST_NAME))
	            {
	                lastName = attribute.getValue();
	            }
	            else if (attribute.getName().equals(Person.ATTRIBUTE_EMAIL_ADDRESS))
	            {
	                emailAddress = attribute.getValue();
	            }
	            else if (attribute.getName().equals(Person.ATTRIBUTE_ADDRESS))
	            {
	                address = attribute.getValue();
	            }
	            else if (attribute.getName().equals(Person.ATTRIBUTE_CITY))
	            {
	                city = attribute.getValue();
	            }
	            else if (attribute.getName().equals(Person.ATTRIBUTE_POSTAL_CODE))
	            {
	                postalCode = attribute.getValue();
	            }
	            else if (attribute.getName().equals(Person.ATTRIBUTE_STATE_REGION))
	            {
	                stateRegion = attribute.getValue();
	            }
	            else if (attribute.getName().equals(Person.ATTRIBUTE_COUNTRY))
	            {
	                country = attribute.getValue();
	            }
	            else if (attribute.getName().equals(Person.ATTRIBUTE_HOME_PHONE_NUMBER))
	            {
	                homePhoneNumber = attribute.getValue();
	            }
	            else if (attribute.getName().equals(Person.ATTRIBUTE_WORK_PHONE_NUMBER))
	            {
	                workPhoneNumber = attribute.getValue();
	            }
	            else if (attribute.getName().equals(PeopleConstants.ATTRIBUTE_CASUAL_HOUR))
	            {
	                casualHour = new Integer(attribute.getValue()).intValue();
	            }
	        }

	        // Note: For some unknown reason Person.getAttributeValues() never returns "Distinguished Name" so it must be retrieved explicitly
	        alias = person.getAttributeValue(context,
	                                         "Distinguished Name");

			currentState=person.getInfo(mainContext, "current");

			employeeCompanyName = person.getCompany(mainContext).getName();

            // JIC 2014:10:24 Added contractor support
            String employmentTypeSelectable="to["+DomainConstants.RELATIONSHIP_EMPLOYEE+"].attribute["+PeopleConstants.ATTRIBUTE_EMPLOYMENTTYPE+"].value";
            BusinessObjectWithSelect personWithSelect=person.select(mainContext,
                                                                    new StringList(employmentTypeSelectable));
            isContractor=personWithSelect.getSelectData(employmentTypeSelectable).equals("Contractor")?true:false;

			StringList lstSelectable=new StringList(1);
            lstSelectable.addElement(DomainConstants.SELECT_TYPE);
            lstSelectable.addElement(DomainConstants.SELECT_NAME);
            MapList lstOrganization = person.getRelatedObjects(mainContext,
                                                               Person.RELATIONSHIP_MEMBER,
                                                               DomainConstants.QUERY_WILDCARD,
                                                               lstSelectable,
                                                               DomainConstants.EMPTY_STRINGLIST,
                                                               true,
                                                               false,
                                                               (short)1,
                                                               DomainConstants.EMPTY_STRING,
                                                               DomainConstants.EMPTY_STRING);
			if (lstOrganization != null)
            {
            	for (int i = 0; i < lstOrganization.size(); i++)
                {
					String type=(String)((Map)lstOrganization.get(i)).get(DomainConstants.SELECT_TYPE);
					if (type.equals(DomainConstants.TYPE_BUSINESS_UNIT) ||
					    type.equals(DomainConstants.TYPE_COMPANY) ||
					    type.equals(DomainConstants.TYPE_DEPARTMENT) ||
					    type.equals(DomainConstants.TYPE_ORGANIZATION))
					{
					    if (memberOrganizationNames.length() != 0)
					    {
					        memberOrganizationNames = memberOrganizationNames + ",";
					    }
						memberOrganizationNames = memberOrganizationNames + (String)((Map)lstOrganization.get(i)).get(DomainConstants.SELECT_NAME);
					}
                }
            }

			lstSelectable = new StringList(1);
            lstSelectable.addElement(DomainConstants.SELECT_NAME);
            // RBR2: FUN [080973] Added selection of Title
            lstSelectable.addElement(DomainConstants.SELECT_ATTRIBUTE_TITLE);
            MapList lstSecurityContext = SecurityContext.getSecurityContexts(mainContext,
                                                                             person,
                                                                             DomainConstants.QUERY_WILDCARD,
                                                                             lstSelectable,
                                                                             null);
			if (lstSecurityContext != null)
			{
				lstSecurityContext.addSortKey(DomainConstants.SELECT_NAME, "ascending", "string");
			    lstSecurityContext.sort();
				for (int i = 0; i < lstSecurityContext.size(); i++)
				{
					assignedSecurityContextNames = assignedSecurityContextNames + (String)((Map)lstSecurityContext.get(i)).get(DomainConstants.SELECT_NAME);
				    assignedSecurityContextNames = assignedSecurityContextNames + ",";
					
				    // RBR2: Holds the Title
				    assignedSecurityContextTitles = assignedSecurityContextTitles + (String)((Map)lstSecurityContext.get(i)).get(DomainConstants.SELECT_ATTRIBUTE_TITLE);
				    assignedSecurityContextTitles = assignedSecurityContextTitles + ",";
				}
			}

			person.close(mainContext);
    	    
	        secLevel = PeopleUtil.getPersonAccreditation(mainContext, person);
        }
        catch (FrameworkException exception)
        {
            exception.printStackTrace(System.err);
        }
  
        // Get installation mode
        String mode="";
        InstallConfigManager icm = new InstallConfigManager();
        try
        {
	        InstallConfig ic = icm.getInstallConfig(context);
            mode = ic.getMode();
        }
        catch (Exception e)
        {
        }%>
        <form style="width:100%"  action="" name="submitForm" id="submitForm">
	       	<div class="divHauts horiz" >
	       	<div class="scroll-cont" style="width: 60%">
    	        <table  width="100%" id="middle" align="center" >
        	        <%String UserAlias = getNLS("UserAlias");%>
            	    <tr>
                	    <td valign="top" align="right"><img src="images/iconSmallDescription.gif"></td>
                    	<td valign="top" rowspan=2>
                        	<table class="basic">
                            	<tr style="height:30px"><td class="title"><%=getNLS("UserID")%></td><td class="MatrixFeel" id="PLM_ExternalID"><%=PLM_ExternalID%></td></tr>
	                            <tr style="height:30px">
    	                            <td class="title"><%=UserAlias%></td>
        	                        <%if (! source.equals("Admin"))
            	                    {%>
                	                    <td class="MatrixFeel" id="Alias"><%=alias%></td>
                    	            <%}
                        	        else
                            	    {%>
                                	    <td class="MatrixFeel"><input type="text" id="Alias" name="Alias" maxlength="40" value="<%=alias%>"></td>
	                                <%}%>
    	                        </tr>
        	                    <tr style="height:30px">
            	                    <td class="title"><%=getNLS("FirstName")%></td>
                	                <td class="MatrixFeel"><input type="text" id="V_first_name" name="V_first_name" maxlength="40" value="<%=firstName%>"></td>
                    	        </tr>
                        	    <tr style="height:30px">
                            		<td class="title"><%=getNLS("LastName")%></td>
                            		<td class="MatrixFeel"><input type="text" id="V_last_name" maxlength="40" value="<%=lastName%>"></td>
	                            </tr>
    	                        <tr style="height:30px">
        	                    	<td class="title"><%=getNLS("HomePhone")%></td>
            	                	<td class="MatrixFeel"><input type="text" id="V_phone" maxlength="20" value="<%=homePhoneNumber%>" ></td>
                	            </tr>
                    	        <tr style="height:30px">
                        	    	<td class="title"><%=getNLS("WorkPhone")%></td>
                            		<td class="MatrixFeel"><input type="text" id="Work_Phone_Number" maxlength="20" value="<%=workPhoneNumber%>" ></td>
	                            </tr>
    	                        <tr style="height:30px">
        	                    	<td class="title"><%=getNLS("Email")%></td>
            	                	<td class="MatrixFeel"><input type="text" id="V_email" maxlength="50" value="<%=emailAddress%>"></td>
                	            </tr>
                    	        <%if (source.equals("Admin"))
                        	    {%>
                            		<tr style="height:30px">
                                		<td class="title"><%=getNLS("Active")%></td>
                                    	<td class="MatrixFeel">
	                                    	<%if (currentState.equals("Active"))
    	                                	{%>
        	                            		<input type="checkbox" id="Active" maxlength="50" checked >
            	                        	<%}
                	                    	else
                    	                	{%>
                        	                	<input type="checkbox" id="Active" maxlength="50" >
                            	        	<%}%>
                                	    </td>
	                            	</tr>
    	                        <%}%>
                                <!-- 2014:10:24 Added "Contractor" checkbox for Contractor support -->
                                <tr><td  class="title"><%=getNLS("Contractor")%></td>
                                    <td>
                                    <%if (isContractor)
                                    {%>
                                    <input type="checkbox" id="Contractor" name="Contractor" checked onchange="refreshAdminSecurityContexts()">
                                    <%}
                                    else
                                    {%>
                                    <input type="checkbox" id="Contractor" name="Contractor" onchange="refreshAdminSecurityContexts()">
                                    <%}%>
                                    </td>
                                </tr>
        	                    <tr><hr></tr>
            	            </table>
                	    </td>
	        	        <td valign="top" align="right"><img src="images/iconSmallAddress.gif"></td>
    	        	    <td valign="top" rowspan=2>
	    	                <table class="basic">
    	    	                <tr style="height:30px">
        	    	            	<td class="title"><%=getNLS("Street")%></td>
            	    	        	<td class="MatrixFeel"><input type="text" maxlength="40" id="Street" value="<%=address%>"></td>
                	    	    </tr>
	                        	<tr style="height:30px">
	    	                    	<td class="title"><%=getNLS("City")%></td>
    	    	                	<td class="MatrixFeel"><input type="text" maxlength="40" id="City" value="<%=city%>"></td>
        	    	            </tr>
	        	                <tr style="height:30px">
    	        	            	<td class="title"><%=getNLS("State")%></td>
        	        	        	<td class="MatrixFeel"><input type="text" maxlength="40" id="State" value="<%=stateRegion%>"></td>
            	        	    </tr>
	                	        <tr style="height:30px">
    	                	    	<td class="title"><%=getNLS("PostalCode")%></td>
        	                		<td class="MatrixFeel"><input type="text" maxlength="40" id="PostalCode" value="<%=postalCode%>"></td>
	        	                </tr>
    	        	            <tr style="height:30px">
        	        	        	<td class="title"><%=getNLS("Country")%></td>
									<%
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
	java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");
									%>
            	        	    	<td class="MatrixFeel">
         <framework:editOptionList disabled="false" name="Country" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="<%=country%>" manualEntryList="<%=manualEntryList%>"/>									
									</td>
                	        	</tr>
		                      <tr><hr></tr>
    		                </table>
	        	        </td>
						<%if (!(mode.equals("SMB")))
						{%>
	                		<td valign="top" align="right"><img src="images/iconSmallCompany.gif"></td>
    	                	<td valign="top" >
	    	                	<table class="basic">
    	                    		<tr style="height:30px"><td class="title"><%=getNLS("Employee")%></td><td class="MatrixFeel"><%=employeeCompanyName%></td></tr>
        			                <tr style="height:30px"><td class="title"><%=getNLS("Member")%></td><td class="MatrixFeel"><%=memberOrganizationNames%></td></tr>
            	    	        	<tr><hr></tr>
                	    	    </table>
	                    	</td>
						<%}%>
		            </tr>
        		    	<tr><td></td><td></td>
							<%if (!mode.equals("SMB") )
							{
							String Accreditation = getNLS("Accreditation");%>
            		    	<td valign="top" align="right"><img src="images/iconSmallConfidentiality.gif"></td>
                			<td valign="top" >
                    			<table class="basic">
                        			<tr style="height:30px">
                        				<td class="title"><%=Accreditation%></td>
                            			<%if (source.equals("Admin"))
	                            		{%>
	    	                        		<td class="MatrixFeel">
    	    	                     	 	<select name="Accreditation" id="Accreditation">
        	    	                	    <option style="color:gray ; font-style : italic" selected value="_NONE_"><%=getNLS("None")%></option>
											<%manageContextTransaction(mainContext,"start");
                	    	   				MapList mpl = PLMxPosTableServices.getTableRows(mainContext, "Confidentiality");
                    	    	    	    manageContextTransaction(mainContext,"end");

						             	    for (int mi=0; mi<mpl.size(); ++mi)
						             	    {
						              	    	Hashtable h = (Hashtable)mpl.get(mi);
            		    					    String allSecLevel = (String)h.get("V_row_name");

							            	    if (allSecLevel.equals(secLevel))
							            	    {%>
						    	         	    	<option selected value="<%=h.get("V_row_name")%>"><%=h.get("V_row_name")%></option>
            	        						<%}
						            	 	    else
						             		    {%>
							         	    		<option value="<%=h.get("V_row_name")%>"><%=h.get("V_row_name")%></option>
	                    						<%}
						        	  	    }
					           	 		}
	            	                	else
    	            	            	{%>
        	            	 				<td class="MatrixFeel" name="Accreditation" id="Accreditation">
            	        					<%=secLevel%>
                	    				<%}%>
                    	  				</td>
		                            </tr>
				                	<tr><hr></tr>
				            	</table>
	            	    	</td>
							<%}%>
            			</tr>
    			</table>
    		</div>
            <div id="lics" style="width:38%; margin-left:3px;" class="scroll-cont">
				 <table ><tr>
				 <td valign="top" align="right"><img src="../common/images/iconSmallCommonLicensingApp.gif"></td>
				 <td valign="top">
					<table class="basic"><tr><td>
                <div id="lics_section1_container">
                    <!-- JIC 15:03:03 Added License type -->
                    <div>
                        <table class="titleLic" border="0" cellspacing="0" cellpadding="0" width="100%">
                            <colgroup>
                                <col class="tableLicMargin" />
                                <col class="tableLicCheckbox" />
                                <col class="tableLicTitle" />
                            </colgroup>
                            <tr>
                                <td/>
                                <td>
                                <%if (casualHour != 0){%>
                                    <input type="checkbox" id="Casual" name="Casual" checked onchange="javascript:CheckUncheckCasual()" />
                                <%}else{%>
                                    <input type="checkbox" id="Casual" name="Casual" onchange="javascript:CheckUncheckCasual()"/>
                                <%}%>
                                </td>
                                <td/>
                                <td><div id="CasualLicenseType"><%=getNLS("LicenseAssignCasual")%></div></td>
                            </tr>
                        </table>
                    </div>
                    <div id="lics_section1_w_filter" class="licHeader">
                    <table  border="0" cellspacing="0" cellpadding="0" width="100%" colspan="4*,*"><tr>
                        <td><div id="lics_section1">
                                <table class="titleLic" border="0" cellspacing="0" cellpadding="0" width="100%">
                                <colgroup>
                                    <col class="tableLicCheckbox" />
                                    <col class="tableLicCheckbox" />
                                    <col class="tableLicTitle" />
                                </colgroup>
                                <tr>
                                    <td onclick="toggleSection('lics_section1');">
                                        <img src="images/iconSectionCollapse.gif" id="lics_section1_img">
                                    </td>
                                    <td>
                                        <!-- JIC 05:06:05: IR IR-375010-3DEXPERIENCER2015x: Changed "toggleCheck" into "toggleCheckLicense" -->
                                        <input id="lics_section1_chk" type="checkbox" onclick="toggleCheckLicense(this,'lics_section1_table');" title="<%=nlsINFO_SELECTALL%>">
                                    </td>
                                    <td >
                                        <%=nlsLicSection1%>
                                    </td>
                                </tr>
                            </table>
                        </div></td>
                        <td >
                            <div>
                                <input id="lic_filter" type="text" title="<%=nlsLicSectionFilter%>" value="" onkeyup="license_filter(this,['lics_section1_table','lics_Available_table','lics_UnavailRich_table','lics_UnavailServer_table']);" />
                            </div>
                        </td>
                    </tr></table>
                    </div>
                    <div id="lics_section1_body" width="100%">
                        <!-- JIC 15:04:16 Removed div contents (added automatically by getLicensesResponse instead) -->
                    </div>
                </div>
                <div id="lics_section0_container">
                    <div id="lics_section0" class="licHeader">
                            <table class="titleLic" border="0" cellspacing="0" cellpadding="0" width="100%">
                                <colgroup>
                                    <col class="tableLicCheckbox" />
                                    <col class="tableLicCheckbox" />
                                    <col class="tableLicTitle" />
                                </colgroup>
                                <tr>
                                    <td>
                                        <img src="images/iconSectionCollapse.gif" id="lics_section0_img">
                                    </td>
                                    <td>
                                    </td>
                                    <td>
                                        <%=nlsLicSection2%>
                                    </td>
                                </tr>
                            </table>
                    </div>
                    <div id="lics_section0_body" width="100%">
                        <table class="titleLic" id="lics_section1_table" border="0" cellspacing="0" cellpadding="0" width="100%">
                            <colgroup>
                                <col class="tableLicMargin" />
                                <col class="tableLicCheckbox" />
                                <col class="tableLicAvailability" />
                                <col class="tableLicTitle" />
                            </colgroup>
                                <tr>
                                    <td> </td>
                                    <td> </td>
                                    <td> </td>
                                    <td>
                                        <img src="images/iconLoader.gif">
                                    </td>
                                </tr>

                        </table>
                    </div>
                </div>
                <div id="lics_section3_container" style="display:none;">
                </div>
				</td></tr><tr><hr></tr></table>
				</td></tr></table>
            </div>
	       	</div>
			
            <div class="divMilieus horiz" >
                    <table width="100%" style="height:95%" >
        	            <%if (source.equals("Admin")){%>
						<tr>
        	    		<td valign="top" align="right"><img src="images/iconSmallContext.gif"></td>
	            	    <td valign="top" align="right" colspan=5 >
    	            		<table class="basic">
								<tr><td class="MatrixFeel" align="left"><%=getNLS("AssignedSecurityContexts")%></td>
									<td></td>
									<td class="MatrixFeel" align="left"><%=getNLS("AvailableSecurityContexts")%></td></tr>
								<tr><td class="MatrixFeel" align="left"><input type="text" maxlength="40" id="sctxsassigned" value="<%=CtxFilterHas%>" onkeypress="searchKeyPress(event);">
													<input id="btnsctxsassigned" type="button" value="<%=getNLS("Filter")%>" onclick="javascript:filtrer2();"></td>
									<td></td>
									<td class="MatrixFeel" align="left"><input type="text" maxlength="40" id="sctxstoadd" value="<%=CtxFilterElse%>" onkeypress="searchKeyPress(event);">
									<input id="btnsctxstoadd" type="button" value="<%=getNLS("Filter")%>" onclick="javascript:filtrer();"></td></tr>
        	            		<tr>
                	            	<%
										Map parametrec= new HashMap();
        	                	        Map lisc= new HashMap();
            	                	    Map fin= new HashMap();
	                	                parametrec.put("PLM_ExternalID", CtxFilterElse); // Coming from Person preferred props
	                	                lisc.put("context0",parametrec);
	                        	        fin.put("method","queryContext");
	                            	    fin.put("iContextInfo",lisc);
                                        // JIC 18:07:03 FUN076129: Removed use of PLM key/added context
    	                            	ClientWithoutWS client = new ClientWithoutWS(mainContext);                                      
	    	                            Map result = client.serviceCall(fin);
    	    	                        Map contextResult = (Map)result.get("context");
										
        	    	                    String[] tab = assignedSecurityContextNames.split(",");
            	    	                StringList tabCtx = new StringList();
                	                	// RBR2: Get Titles
            	    	                String[] tabTitle = assignedSecurityContextTitles.split(",");
            	    	                StringList tabCtxTitle = new StringList();
										// RBR2: This pattern will be applied on name only
            	    	                Pattern pattern = AdminUtilities.buildSearchPattern(CtxFilterHas); // Preferred Props

	                	                for (int j = 0 ; j < tab.length ; j++)
    	                	            {
        	                	        	String[] tabSec = tab[j].split("\n");
            	                	        tabCtx.addElement(tabSec[0]);
                	                	}
                	                	// RBR2: FUN[080973] Get Titles
	                	                for (int idx = 0 ; idx < tabTitle.length ; idx++)
    	                	            {
        	                	        	String[] tabSecTitle = tabTitle[idx].split("\n");
        	                	        	tabCtxTitle.addElement(tabSecTitle[0]);
                	                	}
                	                	// Added Title to Name colelction check 
                	                	
                	                	%>

										<td class="MatrixFeel">
    	                	            	<div style="width : 500px ; height : auto ; overflow :auto ">
        	                	            	<select style="min-width : 100%; width : auto" size="12" id="SecurityContextsHas" multiple>
            	                	            <%for (int j = 0 ; j <  tabCtx.size() ; j++)
                	                	        {
													if(!((String)tabCtx.get(j)).isEmpty())
													{
														String nom = (String)tabCtx.get(j);
														Matcher matcher = pattern.matcher(nom);
														if(matcher.matches()) {%>
															 <!-- RBR2: Now hold name as ID and value as Title -->
															 <option id="<%=tabCtx.get(j)%>" value="<%=tabCtx.get(j)%>" title="Name: <%=tabCtx.get(j)%>"><%=tabCtxTitle.get(j)%></option> 
														<%}
													}
												}%>
    	                            	        </select>
        	                            	</div>
	        	                        </td>
    	                        	<td align="center" valign="center"><img src="images/buttonActionbarPrev.gif" onclick="effacer();">
									<img src="images/buttonActionbarNext.gif" onclick="ajouter();"></td>
    	        	                    <td class="MatrixFeel">
        	        	                	<div style="width : 500px ; height : auto ; overflow :auto">
            	        	                	<select style="min-width : 100%; width : auto" size="12" id="SecurityContextsElse" multiple>
                	        	                	<%for (int i = 0 ; i < contextResult.size() ; i++)
	                	        	                {
    	                	        	            	Map temp = (Map)contextResult.get("context"+i);
        	                	        	            String PLM = (String)temp.get("PLM_ExternalID");
        	                	        	            // RBR2: FUN[080973] Push the Title
        	                	        	            String V_Name = (String)temp.get("V_Name");
            	                	        	        if (!(tabCtx.contains(PLM))) // If not there in assigned list
                	                	        	    {%>
															<option value="<%=PLM%>" id="<%=PLM%>" title="Name: <%=PLM%>"><%=V_Name%></option>
		                        	                    <%}%>
    		                        	                <br>
        		                        	        <%}%>
            		                            </select>
	                	                    </div>
	                    	            </td>
                        	    	</tr>
				                	<tr><hr></tr>
    	            		</table>
        	        	</td>
	                </tr>
        	    	<%}%>
					<%if(!source.equals("Admin")) {%>
					<tr>
        	    		<td valign="top" align="right"><img src="images/iconSmallContext.gif"></td>
	            	    <td>
    	            		<table class="basic">
        	            		<tr>
            	            		<td class="title"><%=getNLS("SecurityContexts")%></td>
	                    	     	<%if ((mode.equals("SMB")))
    	                    	   	{%>
        	                    	   	<td class="MatrixFeel">
            	                    	   	<div style="height : 60px ; overflow :auto ">
                	                    	    <%String[] tab = assignedSecurityContextNames.split(",");
												
	                	                        for (int i = 0 ; i < tab.length ; i++)
    	                	                    {
        	                	                	String[] tabSec = tab[i].split("\n");
            	                	                if (tabSec[0].indexOf(HostCompanyName) != -1)
                	                	            {
                    	                	        	String nameSec = tabSec[0].substring(0,tabSec[0].indexOf(".")) + " in " + tabSec[0].substring(tabSec[0].lastIndexOf(".")+1, tabSec[0].length());
                        	                	    	%><%=nameSec%>
                            	                		<br>
	                                	            <%}
    	                                	    }%>
	    	                                </div>
    	    	                        </td>
            	                    <%}
                	         		else
                    	     		{%>
                        	        	<td class="MatrixFeel">
                            	        	<%String[] tab = assignedSecurityContextNames.split(",");
                                	    	for (int i = 0 ; i < tab.length ; i++)
                                    		{
												// Source : Admin is pending RBR2
												String[] tabSec = tab[i].split("\n");
	                                        	%><%=tabSec[0]%>
	    	                                    <br>
    	    	                            <%}%>
        	                            </td>
                	                <%}%>
								</tr>
	                        	<tr><hr></tr>
    	            		</table>
        	        	</td>
            		</tr>
					<%}%>
                    </table>
            </div>
    	</form>
    	<%if (source.equals("Admin"))
        {%>
        	<textarea id="stockAdd" style="visibility : hidden" cols="1" rows="1"></textarea>
	        <textarea id="stockRemove" style="visibility : hidden" cols="1" rows="1"></textarea>
			<textarea id="stockAssigned" style="visibility : hidden" cols="1" rows="1" ><%=assignedSecurityContextNames%></textarea>
			<textarea id="stockAssignedTitle" style="visibility : hidden" cols="1" rows="1" ><%=assignedSecurityContextTitles%></textarea>
        <%}%>
        <div class="footer" style="height : 5%" id="footer"/>
	</body>
</html>
