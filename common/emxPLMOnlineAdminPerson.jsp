<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../emxJSValidation.inc" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>

<%--
    Document   : emxPLMOnlineAdminPerson.jsp
    Author     : LXM
    Modified :  19/10/2010 -> New UI (New WS spec)
                26/05/2011 -> Replace Post by GEt for AIX
--%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <script>
            function appelFramePerson(){
                var resultat="";
                var responseType = "OTHERS";
                var source = document.getElementById("source").name;

                for(var i = 0 ; i <document.submitForm.elements.length-1 ; i++ ){
                    if( (document.submitForm.elements[i].name != null) || (document.submitForm.elements[i].name != "") ){
                        resultat = resultat + document.submitForm.elements[i].name + "=" + encodeURIComponent(document.submitForm.elements[i].value)+"&";
                    }
                }
        
                resultat = resultat+document.submitForm.elements[document.submitForm.elements.length-1].name+ "=" + encodeURIComponent(document.submitForm.elements[document.submitForm.elements.length-1].value);
                if (document.getElementById("Active").checked){
                    resultat = resultat+"&Active=true";
                }else{
                    resultat = resultat+"&Active=false";
                }
                parent.document.getElementById('frameCol').cols="20,80";
                if (source == "XPPerson"){
                    parent.document.getElementById('Topos').src="emxPLMOnlineAdminQueryPerson.jsp?source=XPPerson&responseType=BASICS&"+resultat;
                }else if(source == "LocalAdmin"){
                    parent.document.getElementById('Topos').src="emxPLMOnlineLocalAdminQueryPerson.jsp?source=LocalAdmin&"+resultat;
                }else{
  			  if(document.getElementById("UserBasics").checked) responseType="BASICS";
                    parent.document.getElementById('Topos').src="emxPLMOnlineAdminQueryPerson.jsp?source=Admin&responseType="+responseType+"&"+resultat;
                }
            }





       </script>
    </head>
    <%  String source="";
        Enumeration filter = emxGetParameterNames(request);
        boolean exist = false;

        while(filter.hasMoreElements()){
            String nextElement = (String)filter.nextElement();
            if(nextElement.equals("source")){
                source = (String)emxGetParameter(request,"source");
                if (source.equals("Admin") || source.equals("XPPerson")){
                    exist=true;
                }
            }
			if(nextElement.equals("dest")){
				String dest = (String)emxGetParameter(request,"dest");
				if(null!=dest) {
					exist=true;
				}
			}
        }

	if (AdminUtilities.isLocalAdmin(mainContext)){
            exist =true;
            source = "LocalAdmin";
        }

         String personFilter = "*";
        if (source.equals("XPPerson")){
           personFilter=prefUtil.getUserPreferredUIPersonFilter(mainContext);
        }

        String PersonalID =  getNLS("ByPersonalInfo");
        String AdressInfo =  getNLS("ByAddressInfo");
        String SeachMode =  myNLS.getMessage("SearchMode");
        String UserId = getNLS("UserID");
        String Email = getNLS("Email");
        String FirstName = getNLS("FirstName");
        String LastName = getNLS("LastName");
        String Phone = getNLS("Phone");
        String Street = getNLS("Street");
        String City = getNLS("City");
        String State = getNLS("State");
        String PostalCode = getNLS("PostalCode");
        String Country = getNLS("Country");
        String Search = getNLS("Search");
	String Active = getNLS("Active");
        String UserProfile = myNLS.getMessage("UserProfile");
       String AllUserData= myNLS.getMessage("AllUserData");
	java.util.Map countryChoiceDetails = (java.util.Map) matrix.db.JPO.invoke(context, "emxOrganization", null, "getCountryChooserDetailsForHTMLDisplay", new String[]{request.getHeader("Accept-Language")}, java.util.HashMap.class);
	java.util.List optionList =  (java.util.List)countryChoiceDetails.get("optionList");
	java.util.List valueList =  (java.util.List)countryChoiceDetails.get("valueList");
	java.util.List manualEntryList =  (java.util.List)countryChoiceDetails.get("manualEntryList");

      %>
      <body>
        <form action="javascript:appelFramePerson()" name="submitForm" id="submitForm" method="GET">
        <%if (!exist){%>
            <a  id="link" href="javascript:CreationFrame('Person')" class="link" ><%=getNLS("New")%></a>
        <%}%>
        <table width="100%">
            <a id="source" name="<%=source%>"></a>
            <tr> 
                <td>
                    <table width="100%">
                        <script>
                            addTable("iconSmallPeople.gif","<%=PersonalID%>",1);
                            addTdRE("<%=UserId%>","plm_ExternalID","<%=personFilter%>","appelFramePerson");
                            addTd("<%=Email%>","v_email","appelFramePerson");
                            addTd("<%=FirstName%>","v_first_name","appelFramePerson");
                            addTd("<%=LastName%>","v_last_name","appelFramePerson");
                            addTd("<%=Phone%>","v_phone","appelFramePerson");
                            document.write('<tr><td class="title"  width="50%"><%=Active%></td>');
                            document.write('<td><input type="checkbox" checked  id="Active"></td></tr>');
                            addCloseTag();
                            addTable("iconSmallAddress.gif","<%=AdressInfo%>",2);
                            addTd("<%=Street%>","street","appelFramePerson");
                            addTd("<%=City%>","city","appelFramePerson");
                            addTd("<%=State%>","state","appelFramePerson");
                            addTd("<%=PostalCode%>","postalCode","appelFramePerson");
                         </script>
							<tr><td class="title" width="50%"><%=Country%></td>
							<td><framework:editOptionList disabled="false" name="Country" optionList="<%=optionList%>" valueList="<%=valueList%>" sortDirection="ascending" selected="" manualEntryList="<%=manualEntryList%>"/></td></tr>
                        <script>
                            addCloseTag();
                         </script>
                                <% if (!source.equals("XPPerson") ){%>
                                <script>
                                    addTable("iconSmallSearch.gif","<%=SeachMode%>",3);
                                document.write('<tr><td class="title"  width="50%">'+"<%=UserProfile%>"+'</td>');
                                document.write('<td><input type="radio" name="SearchMode" checked id="UserBasics" ></td></tr>');
                                document.write('<tr><td class="title"  width="50%">'+"<%=AllUserData%>"+'</td>');
                                document.write('<td><input type="radio" name="SearchMode" id="UserFullMode" ></td></tr>');
                                addCloseTag();
                                </script>
                                <%}%>
                    </table>
                </td>
            </tr>
        </table>
        </form>
        <script>addFooter("javascript:appelFramePerson()","images/buttonDialogApply.gif","<%=Search%>","<%=Search%>");</script>
      </body>
</html>
