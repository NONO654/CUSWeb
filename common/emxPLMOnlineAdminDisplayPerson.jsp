<%-- JIC 13:07:04 IR IR-241854V6R2013x: Created file                       --%>
<%@ page import=" java.util.Hashtable"%>
<%@ page import=" java.util.Vector"%>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import=" java.net.URLEncoder"%>
<%@ page import=" matrix.util.StringList"%>
<%@ page import="com.matrixone.vplm.posws.stubsaccess.ClientWithoutWS" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%> 
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<html>
    <head>
    	<%String WAR_EmailNotValid = getNLSMessageWithParameter("ERR_NotValid", "Email");
    	String WAR_HomeNotValid = getNLSMessageWithParameter("ERR_NotValid", "HomePhone");
    	String WAR_WorkNotValid = getNLSMessageWithParameter("ERR_NotValid", "WorkPhone");
    	String ResultString[]= new String[2];
    	ResultString[0] = getNLS("YourPersonHasBeenUpdated");
	    ResultString[1] = getNLSMessageWithParameter("ERR_CreationRight","UserID");
		String CannotRemLic = getNLS("ERR_CannotRemoveLicenses");
		%>
		<script>
		    var xmlreqs = new Array();

	function getSelectedCheckboxInForm(){
    	    	var middleFrame=window.frames['middleFrame'].document;
          var elements = middleFrame.getElementsByTagName("input");
          var selectToSend = "";

          for(var i = 0 ; i < elements.length ; i++){
              if ((elements[i].checked) && (elements[i].id.indexOf("lic_") == 0)&& (elements[i].type=="checkbox") && !(elements[i].disabled=="true")){
                selectToSend = selectToSend+elements[i].id+",,";
              }
          }
          return selectToSend;
     }
			
			
    	    function getTop(number){
	    	    DisplayLoading();
    	    	var middleFrame=window.frames['middleFrame'].document;
	        	var plmID= middleFrame.getElementById('PLM_ExternalID').firstChild.data;

		        var URLToSend = "PLM_ExternalID="+encodeURIComponent(plmID)+"&";
    		    var personAttributes = middleFrame.getElementsByTagName("input");
        		for(var i = 0 ; i < personAttributes.length ; i++){
        		    if( (personAttributes[i].id != "") && (personAttributes[i].type == "text") ){
                		URLToSend=URLToSend+personAttributes[i].id+"="+encodeURIComponent(personAttributes[i].value)+"&";
		            }
    		    }
				
                URLToSend=URLToSend+"Country=";
                var country="";
                if(middleFrame.getElementById('CountryId').selectedIndex != -1){
					if(middleFrame.getElementById("CountryId").options[middleFrame.getElementById("CountryId").selectedIndex].value == "```manualEntryOptionDisplay```") {
						country=middleFrame.getElementById("CountryIdtxt").value;
					} else {
						country=middleFrame.getElementById("CountryId").options[middleFrame.getElementById("CountryId").selectedIndex].value;
					}
                }
                URLToSend=URLToSend+encodeURIComponent(country)+"&";

		        if (middleFrame.getElementById('Accreditation') != null){
    		        var Accreditation= middleFrame.getElementById('Accreditation').value;
        		    URLToSend = URLToSend + "Accreditation="+encodeURIComponent(Accreditation);
	        	}
	    	    var Alias= middleFrame.getElementById('Alias').value;
    	    	if (Alias == null ){
        	    	Alias= middleFrame.getElementById('Alias').innerHTML.htmlDecode();
	        	}
				if(!IsEMail(middleFrame.getElementById('V_email').value)){
    	    	    HideLoading();
	    	        alert("<%=WAR_EmailNotValid%>");}
    	    	else if(!IsPhoneNumber(middleFrame.getElementById('V_phone').value) && (middleFrame.getElementById('V_phone').value.length >0) ){
	        	    HideLoading();
    	        	alert("<%=WAR_HomeNotValid%>");}
        		else if(!IsPhoneNumber(middleFrame.getElementById('Work_Phone_Number').value) && (middleFrame.getElementById('Work_Phone_Number').value.length >0) ){
            		HideLoading();
	            	alert("<%=WAR_WorkNotValid%>");}
	    	    else{
    	    	    if(number == 0){
        	    	    URLToSend = URLToSend + "&Alias="+encodeURIComponent(Alias);
	        	    }
    	        	else{
        	        	var Active = "false";
	            	    if( middleFrame.getElementById('Active').checked){
    	            	    Active = "true";
	    	            }
    	    	        var ctx= middleFrame.getElementById('stockAdd').value;
        	    	    var ctxRemove= middleFrame.getElementById('stockRemove').value;
            	    	URLToSend = URLToSend +"&Source=Admin&Ctx2Add="+encodeURIComponent(ctx)+"&Ctx2Remove="+encodeURIComponent(ctxRemove)+"&Active="+Active;
                        // JIC 2014:10:24 Added Contractor support
                        URLToSend=URLToSend+"&Contractor="+(middleFrame.getElementById("Contractor").checked?"true":"false");
                        // JIC 2015:04:23 Added Casual Hour support
                        if (middleFrame.getElementById("Casual") != null) {
                            URLToSend=URLToSend+"&CasualHour="+(middleFrame.getElementById("Casual").checked==true?"40":"0");
                        }
						var Licences = getSelectedCheckboxInForm();
						URLToSend=URLToSend+"&licences="+Licences;
		            }
    		        xmlreq("emxPLMOnlineAdminUpdatePerson.jsp",URLToSend,updatePersonDB,0);
				}
	        }

    	    function updatePersonDB(){
            	var xmlhttp=xmlreqs[0];

	            xmlhttp.onreadystatechange=function()
    	        {
        	        if(xmlhttp.readyState==4)
            	    {
                	    var updateResult = xmlhttp.responseXML.getElementsByTagName("updateResult");
						var createLicenseResult = xmlhttp.responseXML.getElementsByTagName("LicMessage");
                    	HideLoading();
						
						window.frames['middleFrame'].document.location.href = window.frames['middleFrame'].document.location.href;

						if (createLicenseResult[0].firstChild.data != "Rien"){
							if (createLicenseResult[0].firstChild.data.length > 2){
								alert(createLicenseResult[0].firstChild.data);
							}else{
								alert("<%=CannotRemLic%>");
							}
						} else {
							<% for (int i = 0 ; i <2 ; i++){%>
								if (<%=i%> == updateResult[0].firstChild.data){
									alert("<%=ResultString[i]%>");
								}
							<%}%>
						}
	                }
    	        }
        	}
    	</script>
	</head>

	<%//Check if we are in the administration side
	String source = emxGetParameter(request, "source");
	if (source == null)
	{
	    source="";
	}
	if (!source.equals("Admin"))
	{%>
  	  	<body onload="javascript:affiche()">
       		<script>addTransparentLoading();</script>
    <%}
	else
	{%>
   		<body>
       		<script>addTransparentLoading();</script>
	<%}

		String UpdateLabel = getNLS("Update");

		// Check for SMB configuration
    	String configuration = "";
		String result = MqlUtil.mqlCommand(mainContext, "list command $1", "APPVPLMAdministration");
	    if (result.length() == 0)
    	{
    	configuration = "SMB";
	    }

		// Get person identifier
    	String personID = "";
	    if (!source.equals("Admin"))
    	{
	    	personID = mainContext.getUser();
    	}
	    else
    	{
			personID = emxGetParameter(request, "PLM_ExternalID");
	    }

		// Build target
    	String target = "emxPLMOnlineAdminPersonForm.jsp?PLM_ExternalID=" + URLEncoder.encode(personID, "UTF-8");
    	if (!(configuration.equals("SMB") || !source.equals("Admin"))){
        	target = target + "&source=Admin";
	    }%>

		<%
		String titre = EncodeUtil.escape(personID+" "+emxGetParameter(request, "FirstName")+" "+emxGetParameter(request, "LastName"));
		%>
		<script>
    		addHeader("images/iconSmallPeople.gif","<%=titre%>");
		</script>
		<div style="height:90%">
    		<iframe  id="middleFrame" name="middleFrame" style=" margin-top: 0% ; border: 0px" width="100%" height="100%" src="<%=target%>"></iframe>
	    </div>
    	<script>
    		<%if (!source.equals("Admin")){%>
      			addFooter("javascript:getTop('0');","images/buttonDialogDone.gif","<%=UpdateLabel%>","<%=UpdateLabel%>");
        	<%}
    		else
    		{%>
            	addFooter("javascript:getTop('1');","images/buttonDialogDone.gif","<%=UpdateLabel%>","<%=UpdateLabel%>");
        	<%}%>
    	</script>
    </body>
</html>
