<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.EncodeUtil" %>
<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@include file = "../emxJSValidation.inc" %>
<script type="text/javascript" src="scripts/emxUICore.js"></script>
<html>
<%
    String YoudonotHaveRights       =  getNLS("NonAppropriateContext");
    String plmid = "";
	String escplmid = "";
    StringList listElem = new StringList();

    Enumeration eNumObj  = emxGetParameterNames(request);
    int size = listElem.size();
    while (eNumObj.hasMoreElements())
    {
        String nextElem = (String)eNumObj.nextElement();
        listElem.addElement(nextElem);
    }
    if (listElem.contains("PLM_ExternalID")) {
        plmid = (String)emxGetParameter(request,"PLM_ExternalID");
		escplmid = EncodeUtil.escape(plmid);
    }
    String message =  (String) emxGetParameter(request,"message");
                if (message == null) message="";

    String OrgName = getNLS("OrganizationName");
    String OrgID = getNLS("OrganizationID");
    String Address = getNLS("Address");
    String Street = getNLS("Street");
    String City = getNLS("City");
    String State = getNLS("State");
    String PostalCode = getNLS("PostalCode");
    String Country = getNLS("Country");
    String OrganizationParent = getNLS("OrganizationParent");
	String ChildrenNLS = getNLS("Children");
    String OrganizationType = getNLS("OrganizationType");
    String Update = getNLS("Update");
    String Remove = getNLS("Remove");
    String Edit = getNLS("Edit");
    String Change = getNLS("Change");
    String CancelModificationButton= getNLS("CancelModificationButton");
    String TabInteger[] = new String[2];
    TabInteger[0]=OrgName;
    TabInteger[1]=getNLS("Special");
    String ERRCannotContain = myNLS.getMessage("ERR_ProjectCannotContain",TabInteger);
%>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>

            function ASubmitFunction(){
                DisplayLoading();
                var URLToSend = "";
                var orgAttributes = document.getElementsByTagName("input");
				var theOrgName = $("OrgPLMId").innerHTML.htmlDecode();
				var theOrgParent = $("OrgParent").innerHTML.htmlDecode();
				var newOrg = "";

                for(var i = 0 ; i < orgAttributes.length ; i++){
                    if( (orgAttributes[i].name != "") && (orgAttributes[i].type == "text") ){
                        URLToSend=URLToSend+orgAttributes[i].name+"="+encodeURIComponent(orgAttributes[i].value)+"&";
                    }
                }
                URLToSend=URLToSend+"Country=";
                var country="";
                if(document.getElementById("CountryId").selectedIndex != -1){
					if(document.getElementById("CountryId").options[document.getElementById("CountryId").selectedIndex].value == "```manualEntryOptionDisplay```") {
						country=document.getElementById("CountryIdtxt").value;
					} else {
						country=document.getElementById("CountryId").options[document.getElementById("CountryId").selectedIndex].value;
					}
                }
                URLToSend=URLToSend+encodeURIComponent(country)+"&";

                if ( (theOrgName ==null) || (theOrgName.indexOf('input')>-1) || (theOrgName.indexOf('INPUT')>-1) ) {
                	theOrgName=orgName;
                	newOrg= $("OrgPLMIdIn").value;
                }
                if ( (theOrgParent.indexOf('emxPLMOnlineAdminOrganizationSubTree')>-1) ) {
					theOrgParent = $("OrgParent").firstChild.innerHTML.htmlDecode();
				}
                //Check that name doesn't contain illegal characters only if it has been changed, to support old illegal names.
                if(newOrg !== theOrgName && hasSpecialChar(newOrg)){
                	alert("<%=ERRCannotContain%>" + ": " + emxUIAdminConsoleUtil.FORBIDDEN_CHARACTERS);
                    HideLoading();
                }else{
                	URLToSend=URLToSend+"&PLM_ExternalID="+encodeURIComponent(theOrgName)+"&NewOrgName="+encodeURIComponent(newOrg)+"&Org_Parent="+encodeURIComponent(theOrgParent);
                	xmlreq("emxPLMOnlineAdminUpdateOrganization.jsp",URLToSend,updateOrgDB,1);
                }
           }

           function updateOrgDB(){
                var xmlhttp = xmlreqs[1];

                xmlhttp.onreadystatechange=function()
                {
                    if(xmlhttp.readyState==4){

                        var updateResult = xmlhttp.responseXML.getElementsByTagName("updateResult");
                        var done = xmlhttp.responseXML.getElementsByTagName("Done");

                        document.getElementById("hidethisone").style.display="block";
                        document.getElementById("messageError").innerHTML=updateResult[0].firstChild.data;
                        var theOrgName = $("OrgPLMId").innerHTML.htmlDecode();
                        if ( (theOrgName ==null) || (theOrgName.indexOf('input')>-1)  || (theOrgName.indexOf('INPUT')>-1)) {
                        	theOrgName= $("OrgPLMIdIn").value;
                        }

                       	if(done[0].firstChild.data == "true"){
                       		initOrganization(theOrgName);
                       	}else{
                       		HideLoading();
                       	}
                    }
                }
           }


            function initOrganization(plmid){
            	 xmlreq("emxPLMOnlineAdminAjaxResponse.jsp","source=Organization&Destination=UpdatePage&responseOrg=org_Type,street,city,state,country,postalCode,org_Parent,v_name,child&filterOrg="+encodeURIComponent(plmid),formatResponse,0);
            }

            var xmlreqs = new Array();

            function formatResponse()
            {
                var xmlhttp = xmlreqs[0];

                xmlhttp.onreadystatechange=function()
                {
                    if(xmlhttp.readyState==4)

                    {
						// JIC 16:05:13 IR IR-441308-3DEXPERIENCER2016x: Replaced "firstChild.data.htmlEncode()" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                        //$("OrgPLMId").innerHTML = xmlhttp.responseXML.getElementsByTagName("PLM_ExternalID")[0].firstChild.data.htmlEncode();
                        var childNodes = xmlhttp.responseXML.getElementsByTagName("PLM_ExternalID")[0].childNodes;
                        var orgPLMId = ""
                        for (var i = 0; i < childNodes.length; i++)
                        {
                            orgPLMId = orgPLMId + childNodes[i].data.htmlEncode();
                        }
                        $("OrgPLMId").innerHTML = orgPLMId;
                    	if ( (xmlhttp.responseXML.getElementsByTagName("org_Parent").length >0) && (xmlhttp.responseXML.getElementsByTagName("org_Parent")[0].firstChild != null)){
							var oparent = xmlhttp.responseXML.getElementsByTagName("org_Parent")[0].firstChild.data;
                            $("OrgParent").innerHTML = '<a href="emxPLMOnlineAdminOrganizationSubTree.jsp?suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common&PLM_ExternalID='+encodeURIComponent(oparent)+'">'+oparent.htmlEncode()+'<a>';
                        }else{
                        	$("OrgParent").style.color ="gray";
                        	$("OrgParent").innerHTML = "None";
                        }
                        $("OrgType").innerHTML = xmlhttp.responseXML.getElementsByTagName("org_Type")[0].firstChild.data;
						if (($("OrgType").innerHTML == 'Company') && ($("removeButton") != null)){
							$("removeButton").style.display = 'block';
						}

                    	if (xmlhttp.responseXML.getElementsByTagName("v_name")[0].firstChild != null){
                            // JIC 16:05:13 IR IR-441308-3DEXPERIENCER2016x: Replaced "firstChild.data" with loop on all nodes as Internet Explorer 10 splits text containins hyphens into several nodes (and "textContext" is not supported prior to Internet Explorer 9...)
                    		//$("OrgV_Name").value = xmlhttp.responseXML.getElementsByTagName("v_name")[0].firstChild.data;
                            var childNodes = xmlhttp.responseXML.getElementsByTagName("v_name")[0].childNodes;
                            var orgName = ""
                            for (var i = 0; i < childNodes.length; i++)
                            {
                                orgName = orgName + childNodes[i].data;
                            }
                            $("OrgV_Name").value = orgName;
                        }
                        if (xmlhttp.responseXML.getElementsByTagName("city")[0].firstChild != null){
                            $("OrgCity").value = xmlhttp.responseXML.getElementsByTagName("city")[0].firstChild.data;
                        }
                        if (xmlhttp.responseXML.getElementsByTagName("state")[0].firstChild != null){
                            $("OrgState").value = xmlhttp.responseXML.getElementsByTagName("state")[0].firstChild.data;
                        }
                        if (xmlhttp.responseXML.getElementsByTagName("postalCode")[0].firstChild != null){
                            $("OrgPostalCode").value = xmlhttp.responseXML.getElementsByTagName("postalCode")[0].firstChild.data;
                        }
                        if (xmlhttp.responseXML.getElementsByTagName("country")[0].firstChild != null){
							$("CountryId").value = xmlhttp.responseXML.getElementsByTagName("country")[0].firstChild.data;
							if($("CountryId").value=="") {
								$("CountryIdtxt").disabled = false;
								$("CountryIdtxt").style = "";
								$("CountryIdtxt").value = xmlhttp.responseXML.getElementsByTagName("country")[0].firstChild.data;
								$("CountryId").value = "```manualEntryOptionDisplay```";
							}
                        }
                        if (xmlhttp.responseXML.getElementsByTagName("street")[0].firstChild != null){
                           $("OrgStreet").value = xmlhttp.responseXML.getElementsByTagName("street")[0].firstChild.data;
                        }
						var children = xmlhttp.responseXML.getElementsByTagName("child");
                        if (children!=null && children.length!=0){
							var table=document.getElementById('OrgChildren');
							while(table.hasChildNodes()) table.removeChild(table.lastChild);
							for (var i = 0 ; i <children.length ; i++){
								var row=table.insertRow(-1);
								var cell=row.insertCell(-1);
								var ochild = children.item(i).firstChild.data;
								cell.innerHTML='<a href="emxPLMOnlineAdminOrganizationSubTree.jsp?suiteKey=Framework&StringResourceFileId=emxFrameworkStringResource&SuiteDirectory=common&PLM_ExternalID='+encodeURIComponent(ochild)+'">'+ochild.htmlEncode()+'<a>';
								cell.title=ochild;
							}
						}
                        if((orgName != "") && (orgName != $("OrgPLMId").innerHTML.htmlDecode())){
                          	orgName="";
                        }
						var localporg = $("OrgParent").innerHTML;
						if(localporg.indexOf('emxPLMOnlineAdminOrganizationSubTree')>-1) {
							localporg = $("OrgParent").firstChild.innerHTML.htmlDecode();
						}
                        if((orgParentName != "") && (orgParentName != localporg)) {
    	                    orgParentName="";
                        }

						HideLoading();
                    }
                }
            }

            var orgName="";
            var orgParentName="";

            function renameOrg(){
            	if( ($("OrgPLMId").innerHTML.indexOf("input")==-1) && $("OrgPLMId").innerHTML.indexOf("INPUT")==-1){
					orgName=$("OrgPLMId").innerHTML.htmlDecode();
					$("OrgPLMId").innerHTML='<input type="text" name="OrgPLMIdIn" id="OrgPLMIdIn" value="'+orgName+'" >';
            	}
            }

            function modifyParent(remove){
            	orgParentName=$("OrgParent").innerHTML.htmlDecode();
				if (orgParentName.indexOf('emxPLMOnlineAdminOrganizationSubTree')>-1){
					orgParentName=$("OrgParent").firstChild.innerHTML.htmlDecode();
				}
            	var plmID = $("OrgPLMId").innerHTML.htmlDecode();
				if (remove == "Remove"){
					$("OrgParent").innerHTML = "None" ;
            	}else{
					if( (plmID.indexOf("input") > -1) || (plmID.indexOf("INPUT") > -1) ) plmID=$("OrgPLMIdIn").value;
					if(orgName != ""){
						top.showSlideInDialog("emxPLMOnlineAdminModifyCurrentOrganizaton.jsp?Source=VPLMAdmin&OrgName="+encodeURIComponent(orgName)+"&OrgType="+encodeURIComponent($("OrgType").innerHTML)+"&orgParentName="+encodeURIComponent(orgParentName), true);
            		}else{
						top.showSlideInDialog("emxPLMOnlineAdminModifyCurrentOrganizaton.jsp?Source=VPLMAdmin&OrgName="+encodeURIComponent(plmID)+"&OrgType="+encodeURIComponent($("OrgType").innerHTML)+"&orgParentName="+encodeURIComponent(orgParentName), true);
					}
				}
			}

			function cancelChanges(){
                initOrganization('<%=plmid%>');
            }
        </script>
    </head>
    <%if (AdminUtilities.isProjectAdmin(mainContext)){%>
        <body>
            <script>addTransparentLoading("<%=YoudonotHaveRights%>","display");</script>
        </body>
    <%}else{
    %>
    <body onload="javascript:initOrganization('<%=escplmid%>')">
         <script>addReturnMessage();</script>
         <script>addTransparentLoading("","display");</script>
            <form action="emxPLMOnlineAdminUpdateOrganization.jsp" id="submitForm" name="submitForm"  method="POST">
            <%
                if (!(message.equals("")))
                {%>
                    <script>alert("<%=message%>");</script>
                <%}%>
                 <div id="pageContentDiv" class="divPageBodyVPLM"  style=" overflow: auto">
                    <table style="height:95% ; border-color: white" border="1px">
                         <tr style="height:30px"><td class="MatrixLabel"><%=OrganizationType%> </td><td class="MatrixFeel" id ="OrgType" name="org_Type"></td></tr>
                       <tr style="height:30px"><td class="MatrixLabel"><%=OrgName%></td><td class="MatrixFeel"><table style="padding-left : -1px" width="100%" ><tr><td class="MatrixFeel" id="OrgPLMId"></td><td align="right"> <input type="button" name="btnparentName" title="<%=Edit%>" value="<%=Edit%>" onclick="javascript:renameOrg()"></td></tr></table></td></tr>
                         <tr style="height:30px"><td class="MatrixLabel"><%=OrgID%></td><td class="MatrixFeel"><input type="text" name="OrgV_Name" id="OrgV_Name" value="" ></td></tr>
                       <tr style="height:30px"><td  width="200px"></td><td></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel"><%=Address%></td><td ></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel" align="right"><%=Street%></td><td class="MatrixFeel"><input type="text" name="Street" id="OrgStreet" value="" ></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel" align="right"><%=City%></td><td class="MatrixFeel"><input class="MatrixFeel" type="text" name="City" id="OrgCity" value="" ></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel" align="right"><%=State%></td><td class="MatrixFeel"><input type="text" name="State" id="OrgState" value="" ></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel" align="right"><%=PostalCode%></td><td class="MatrixFeel"><input type="text" name="postalCode" id="OrgPostalCode" value="" ></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel" align="right"><%=Country%></td>
						<td class="MatrixFeel">
									<%
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
	java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");
	String countryDefaultValue = (String)countryChoiceDetails.get("default");
									%>
         <framework:editOptionList disabled="false" name="Country" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="<%=countryDefaultValue%>" manualEntryList="<%=manualEntryList%>"/>
						</td></tr>
                        <tr style="height:30px"><td  width="200px"></td><td></td></tr>
                        <tr style="height:30px">
                        	<td class="MatrixLabel" name="Org_Parent"><%=OrganizationParent%></td>
                          	<td class="MatrixFeel" >
                          	<table width="100%" ><tr>
                          	<td class="MatrixFeel" name="OrgParent" id="OrgParent"></td>
                        <%
                        String result = MqlUtil.mqlCommand(mainContext,"list command $1","APPVPLMAdministration");
                        String mode ="VPM";
                        if (result.length() == 0){mode = "SMB"; }
                        if (!mode.equals("SMB")){ %>
                        <td align="right"><input type="button" name="btnparentName" value="<%=Change%> ..." title="<%=Change%>" onclick="javascript:modifyParent()"></td></tr>
				<td></td><td align="right" style="display:none" id="removeButton"><input type="button" name="btnparentName" value="<%=Remove%>" title="<%=Remove%>" onclick="javascript:modifyParent('Remove')"></td></tr>
			<%}%>
                        </table>
                        </td></tr>
                       <tr style="height:30px"><td  width="200px"></td><td></td></tr>
                        <tr style="height:30px"><td class="MatrixLabel"><%=ChildrenNLS%></td>
                         	<td class="MatrixFeel" >
							<table width="100%" id="OrgChildren">
							</table>
							</td>
						</tr>
                        <tr><hr></tr>
                    </table>
                </div>
        </form>
	<script>
            addFooter("javascript:cancelChanges();","images/buttonDialogCancel.gif","<%=CancelModificationButton%>","<%=CancelModificationButton%>","javascript:ASubmitFunction();","images/buttonDialogDone.gif","<%=Update%>","<%=Update%>");

        </script>
  </body>
<%}%>
</html>
