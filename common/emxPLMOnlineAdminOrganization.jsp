<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%@include file = "../emxJSValidation.inc" %>
<html>
        <%
        String ByOrganizationInfo = getNLS("ByOrganizationInfo");
        String ByAddressInfo = getNLS("ByAddressInfo");
        String ByParentInfo= getNLS("ByParentInfo");
        String Street= getNLS("Street");
        String City= getNLS("City");
        String State= getNLS("State");
        String PostalCode= getNLS("PostalCode");
        String Country= getNLS("Country");
        String OrganizationParent = getNLS("OrganizationParent");
        String Search = getNLS("Search");
        String Name = getNLS("Name");
        String OrganizationID = getNLS("OrganizationID");
        
        String dest = (String)emxGetParameter(request,"dest");
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
	java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");
        
        %>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
           function getValue(){
            var plmId = document.getElementById('send');
            var target = plmId.href;
 
            var PLM_ExternalID = document.getElementById("PLM_ExternalID").value;
            var v_name = document.getElementById("v_name").value;
            var street = document.getElementById("street").value;
            var city = document.getElementById("city").value;
            var state = document.getElementById("state").value;
            var postalCode = document.getElementById("postalCode").value;
            for(var i = 0 ; i <document.submitForm.elements.length-1 ; i++ ){
                if( (document.submitForm.elements[i].name != null) && (document.submitForm.elements[i].name == "Country") ){
                    var country = document.submitForm.elements[i].value;
                }
            }
			var org_Parent = document.getElementById("org_parent").value;
            
            
            var newTarget = target + encodeURIComponent(PLM_ExternalID) + "&Param2=" + encodeURIComponent(street) + "&Param3=" + encodeURIComponent(city) + "&Param4=" + encodeURIComponent(state) + "&Param5=" + encodeURIComponent(postalCode) + "&Param6=" + encodeURIComponent(country) + "&Param7=" + encodeURIComponent(org_Parent) +"&Param8=" + encodeURIComponent(v_name);
            if(null != "<%=dest%>") newTarget=newTarget+"&dest="+"<%=dest%>";
			parent.document.getElementById("frameCol").cols="20,80";
			parent.Topos.location.href=newTarget;
            }
        </script>
    </head>
    <body>  
        <form action="emxPLMOnlineAdminQueryOrganization.jsp?Param1=" name="submitForm" id="submitForm"><a id="send" href="emxPLMOnlineAdminQueryOrganization.jsp?Param1="></a>
            <%if (dest == null){%> 
            	<a href="javascript:CreationFrame('Organization')" class="link"><%=getNLS("New")%></a>
            <%}%> 
            <table width="100%">
                <tr> 
                    <td border="1" >          
                        <table width="100%">
                            <script>
                            addTable("iconSmallOrganization.gif","<%=ByOrganizationInfo%>",1);
                            addTdRE("<%=Name%>","PLM_ExternalID","*","getValue");
                            addTd("<%=OrganizationID%>","v_name","getValue");
                            addCloseTag();
                            </script>
                            <script>
                            addTable("iconSmallAddress.gif","<%=ByAddressInfo%>",2);
                            addTd("<%=Street%>","street","getValue");
                            addTd("<%=City%>","city","getValue");
                            addTd("<%=State%>","state","getValue");
                            addTd("<%=PostalCode%>","postalCode","getValue");
                            </script>
							<tr><td class="title" width="50%"><%=Country%></td>
							<td><framework:editOptionList disabled="false" name="Country" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="" manualEntryList="<%=manualEntryList%>"/></td></tr>							
                            <script>
                            addCloseTag();
                            </script>
                            <script>
                            addTable("iconSmallOrganization.gif","<%=ByParentInfo%>",3);
                            addTd("<%=OrganizationParent%>","org_parent","getValue");
                            addCloseTag();
                          </script>         
                        </table>
                    </td>
                </tr>
            </table>
        </form>
        <script>addFooter("javascript:getValue()","images/buttonDialogApply.gif","<%=Search%>","<%=Search%>");</script>
    </body>
</html>
