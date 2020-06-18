<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@ page import="com.matrixone.vplm.posbusinessmodel.PeopleConstants" %>
<%@ page import="com.matrixone.apps.common.Person" %>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%--
    Document   : emxPLMOnlineLocalAdminQueryContextUser.jsp
    Author     : LXM
    Modified : 10/11/2010 -> New UI (New WS spec)
    Modified :   26/05/2011 -> Replace Post by GEt for AIX
--%>
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
        out.println("  <td><input type=\"checkbox\" id=\"lic_"+id+"_chk\" name=\"lic_"+id+"_chk\" value=\""+id+"\" onclick=\"clic(this);\""+sChecked+"></td>");
        out.println("  <td><img src=\"images/iconLicense"+state+".gif\" id=\"lic_"+id+"\" title=\""+nls_state+"\" style=\"cursor:pointer\"></td>");
        out.println("  <td><div id=\"lic_"+id+"_txt\">"+title+"</div></td>");
        out.println("</tr>");
    }
    %>
<%
    String target="";
   
    String nlsINFO_UNKNOWN      =  getNLS("LicenseUnknown");
    String nlsINFO_UNAVAIL      =  getNLS("LicenseUnavailable");
    String nlsINFO_UNAVAIL_WARN =  getNLS("LicenseUnavailableWarning");
    String nlsINFO_AVAILABLE    =  getNLS("LicenseAvailable");
    String nlsINFO_SELECTALL    =  getNLS("LicenseSectionSelectUnselectAll");
    String nlsLicSection1       =  getNLS("LicenseSectionUsed");
    String nlsLicSectionFilter  =  getNLS("LicenseSectionFilter");
    String nlsLicSection2       =  getNLS("LicenseSectionOther");

    String FilterBy=  getNLS("FilterBy");
    String Updating       =  getNLS("Updating");
    String Update 	     =  getNLS("Update");
    String NoFilter	     =  getNLS("NoFilter");

    String source = (String)emxGetParameter(request,"source");
    String message = (String)emxGetParameter(request,"message");

    String sPersonId = emxGetParameter(request,"PLM_ExternalID");
    String ctxUser = emxGetParameter(request,"ctxUser");

    TreeMap mapUserLicenses = new TreeMap();
    if (sPersonId.length()>0) {
        Vector lListOfUserLicenses = new Vector();
        LicenseInfo.getUserLicenses(context, sPersonId, lListOfUserLicenses);
        
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


    Map fin = new HashMap();
    Map listperson = new HashMap();
    Map person = new HashMap();

    //Getting the list of users contexts
    String[] ListCtxUser = ctxUser.split(",");
    StringList ListCtxUserString =  new StringList();
    String stringForJsp = "";


    StringList ListCtxFinalString = AdminUtilities.getLocalAdminAssignableContexts(mainContext);
    ListCtxFinalString.sort();

    for (int i = 0 ; i < ListCtxUser.length ; i++){
        if (ListCtxFinalString.contains(ListCtxUser[i])){ListCtxFinalString.remove(ListCtxUser[i]);}
        ListCtxUserString.addElement(ListCtxUser[i]);
    }

    //getting the list of admin context to display so there will not be duplicata
    for (int j = 0 ; j < ListCtxFinalString.size() ; j++){
        stringForJsp = stringForJsp + "," + ListCtxFinalString.get(j);
    }

    // JIC 15:04:21 Added casual hour
    int casualHour = 0;
    if (sPersonId.length()>0) {
        Person person2 = Person.getPerson(context, sPersonId);
    	casualHour = new Integer(person2.getAttributeValue(context, PeopleConstants.ATTRIBUTE_CASUAL_HOUR)).intValue();
    }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <style>
            div.horiz      { width:100%; position:relative; }
            div.divHauts   { height:83%; }
            div.divBass    { height:6%; width:100%; }
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
  
    function callMethod(source){
        // JIC 15:04:24 Replaced call to getSelectedCheckbox with getSelectedLicencesCheckbox
        var licences = getSelectedLicencesCheckbox();
        var target = source + "&Ctx2Remove="+ document.getElementById("stockAdd").name + "&Ctx2Add="+ document.getElementById("stockRemove").name +"&Source="+"Local Admin"+"&licences="+licences;;
        // JIC 2015:03:17 Added Casual Hour support
        target = target+"&CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
        document.location.href = target;
    }
            

      /*    function effacer(){
            //Index of the Administrator selected value
            var selecAdmin = document.getElementById("listCtxAdmin");
            //Index of the User selection
            var selecUser = document.getElementById("listCtxUser");
            
            for (var i=0; i < selecAdmin.options.length ; i++){
                    if (selecAdmin.options[i].selected == true)
                    {
                        var text = selecAdmin.options[i].value;
                        document.getElementById("stockRemove").name = document.getElementById("stockRemove").name+ "," + text;
                        selecAdmin.options[ selecAdmin.options.selectedIndex]=null;
                        var opt = new Option(text,text);
                        if (selecUser.size <20){
                        selecUser.size = selecUser.size +1;
                        }
                        selecAdmin.size = selecAdmin.size -1;
                        selecUser.options[selecUser.options.length]=opt;
                    }
                }
                  
           }
                      
         function ajouter(){
            var index = document.getElementById("listCtxUser").options[ document.getElementById("listCtxUser").options.selectedIndex];
            var text = index.value;
             document.getElementById("stockAdd").name = document.getElementById("stockAdd").name + "," + text;
            document.getElementById("listCtxUser").options[ document.getElementById("listCtxUser").options.selectedIndex]=null;
            var opt = new Option(text,text);
            if(document.getElementById("listCtxAdmin").size < 20){
            document.getElementById("listCtxAdmin").size = document.getElementById("listCtxAdmin").size + 1;
            }
            if(document.getElementById("listCtxUser").size > 0){
            document.getElementById("listCtxUser").size = document.getElementById("listCtxUser").size -1;
            }
            document.getElementById("listCtxAdmin").options[ document.getElementById("listCtxAdmin").options.length]=opt;
           }
*/
    function effacer(){
               var selectBox = document.getElementById("listCtxAdmin");
                var sizeSelectBox = selectBox.options.length - 1;

               while (sizeSelectBox >= 0){
                   if(selectBox.options[sizeSelectBox].selected){
                       var text = selectBox.options[sizeSelectBox].value;
                       selectBox.options[sizeSelectBox]=null;
                       var opt = new Option(text,text);
    
                       document.getElementById("listCtxUser").options[ document.getElementById("listCtxUser").options.length]=opt;
                      document.getElementById("stockRemove").name = document.getElementById("stockRemove").name+ "," + text;
			if(document.getElementById("stockAdd").name.indexOf(text) > -1){
				var idStock = document.getElementById("stockAdd").name;
				document.getElementById("stockAdd").name =idStock.substring(0,idStock.indexOf("," + text)) + idStock.substring(idStock.indexOf("," + text)+text.length+1,idStock.length);
			}
			
                   }
                   sizeSelectBox = sizeSelectBox - 1;
               }
               if (document.getElementById("listCtxUser").options.length <20){
            	   document.getElementById("listCtxUser").size = document.getElementById("listCtxUser").options.length;
               }else{
            	   document.getElementById("listCtxUser").size=20;
               }
              
               }





            function ajouter(){
            	
                var selectBox = document.getElementById("listCtxUser");
               var sizeSelectBox = selectBox.options.length - 1;

                while (sizeSelectBox >= 0){
                   if(selectBox.options[sizeSelectBox].selected){
                       var text = selectBox.options[sizeSelectBox].value;
                       selectBox.options[sizeSelectBox]=null;
                       var opt = new Option(text,text);
                       document.getElementById("listCtxAdmin").options[ document.getElementById("listCtxAdmin").options.length]=opt;
                       document.getElementById("stockAdd").name = document.getElementById("stockAdd").name + "," + text;
			if(document.getElementById("stockRemove").name.indexOf(text) > -1){
				var idStock = document.getElementById("stockRemove").name;
				document.getElementById("stockRemove").name =idStock.substring(0,idStock.indexOf("," + text)) + idStock.substring(idStock.indexOf("," + text)+text.length+1,idStock.length);
			}
                }
                   sizeSelectBox = sizeSelectBox - 1;
               }
                if (document.getElementById("listCtxAdmin").options.length <20){ 	
                	document.getElementById("listCtxAdmin").size = document.getElementById("listCtxAdmin").options.length;
                }else{
             	   document.getElementById("listCtxAdmin").size=20;
                }
            }


         function sendToUpdatePage(){
            // JIC 15:04:24 Replaced call to getSelectedCheckbox with getSelectedLicencesCheckbox
            var res = getSelectedLicencesCheckbox();
             document.getElementById("HiddenElement").innerHTML=res;
          document.getElementById("submitForm").submit();

        }


   


        function CheckContext(){
             var ctxHidden = document.getElementById("context").firstChild.data;
             var tabCtx = ctxHidden.split(",,");
            var ctxFinal ="";
           for (var i = 0 ; i < tabCtx.length-1 ; i++){
			var ctxExist = document.getElementById(tabCtx[i]);
			if (ctxExist != null){
	                 document.getElementById(tabCtx[i]).checked = true;
				ctxFinal = ctxFinal + tabCtx[i] + ",,";
			}
             }
		document.getElementById("context").innerHTML=ctxFinal;
        }


// update NLS title help
nlsINFO_SELECTALL      = "<%=nlsINFO_SELECTALL%>";
nlsINFO_AVAILABLE      = "<%=nlsINFO_AVAILABLE%>";
nlsINFO_UNAVAIL        = "<%=nlsINFO_UNAVAIL%>";
nlsSECTION_AVAIL          = "<%=myNLS.getMessage("LicenseSectionAvailable")%>";
nlsSECTION_UNAVAIL_RICH   = "<%=myNLS.getMessage("LicenseSectionUnavailableRich")%>";
nlsSECTION_UNAVAIL_SERVER = "<%=myNLS.getMessage("LicenseSectionUnavailableServer")%>";


var xmlreqs = new Array();
var prev_filter_lic = "";
var filter_lic = false;


 
        function initXPPerson(){
            /* Request to get the Licenses */
            // JIC 15:04:21 Added parameters "CasualHour" and "User"
            var destCasualHour = "User="+encodeURIComponent("<%=sPersonId%>")+"&CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp",destCasualHour,getLicensesResponse,1);
        }

        // JIC 15:04:24 Added function "CheckUncheckCasual"
        function CheckUncheckCasual() {     
            DisplayLoading();
            var destCasualHour = "User="+encodeURIComponent("<%=sPersonId%>")+"&CasualHour="+(document.getElementById("Casual").checked==true?"40":"0");
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp",destCasualHour,getLicensesResponse,1);
        }
        
        </script>
    </head>
    <body onload="javascript:initXPPerson()">
        <a id="stockAdd" name="" href=""></a> 
        <a id="stockRemove" name=""></a>
        <form action="" id="submitForm" name="submitForm"  method="GET">
            <%if (message != null) {%>
                <script type="text/javascript">setTime("<%=message%>");</script>
            <%}%>
              <div class="divHauts horiz" id="divHauts" style=" border: 1px ; border-color: white"  >
                  <div class="scroll-cont">
                      <table style="height:100%"  width="100%" >
                        <tr style="height:5%" ><td class="titleAdmin" colspan="3"><%=Updating%> <%=emxGetParameter(request,"PLM_ExternalID")%></td></tr>
                        <tr align="center">
                           <td width="40%">
                           <table style="height:100%" >
                                    <th height="30px" valign="top"  align="right" style="font-family: verdana, helvetica, arial, sans-serif; font-size: 10pt;">
                                    <br><%=FilterBy%> :
                                    <select  id="nameFilter" onchange="javascript:displayChoice('<%=stringForJsp%>')"><option><%=NoFilter%><option>Role<option>Organization<option>Project</select>
                                    <select id="valueFilter"></select>
                                    <img style="cursor:pointer" src="images/iconActionSearch.gif" onclick="javascript:filterBy('<%=stringForJsp%>')"></th>
                                    <tr>
                                    <td >
                                        <%if (ListCtxFinalString.size() < 10 ){%>
                                            <select multiple id="listCtxAdmin" size="<%=ListCtxFinalString.size()%>">
                                        <%}else{%>
                                            <select multiple id="listCtxAdmin" size="10">
                                        <%}%>
                                        <%for (int i = 0; i < ListCtxFinalString.size() ; i++){%>
                                            <option value="<%=ListCtxFinalString.get(i)%>"><%=ListCtxFinalString.get(i)%>
                                        <%}%>
                                        </select>
                                    </td>
                                    </tr>
                                </table>
                            </td>
                            <td width="10%">
                                <table>
                                    <tr><td><img src="images/buttonActionbarNext.gif" onclick="javascript:effacer()"></td></tr>
                                    <tr></tr>
                                    <tr><td><img src="images/buttonActionbarPrev.gif" onclick="javascript:ajouter()"></td></tr>
                                </table>
                            </td>
                            <td width="40%">
                                <table>
                                    <tr  ><td align="middle"  style="font-family: Arial, helvetica, arial, sans-serif; font-weight:bold; font-size: 10pt;text-decoration: italic;color : #67738d ;" ><%=emxGetParameter(request,"PLM_ExternalID")%> <%=getNLS("Contexts")%></td></tr>
                                    <tr  ><td ></td></tr>
                                    <tr >
                                        <td>
                                            <%if (ListCtxUser.length < 20 ){%>
                                            <select multiple id="listCtxUser" size="<%=ListCtxUser.length%>">
                                            <%}else{%>
                                            <select multiple id="listCtxUser" size="20">
                                                <%}%>
                                                <%
                                                if(!ListCtxUser[0].equals("[]") &&  !(ListCtxUser[0] == null) ){
                                                for (int i = 0; i < ListCtxUser.length; i++){

                                                %>
                                                <option value="<%=ListCtxUser[i]%>"><%=ListCtxUser[i]%>
                                                <%}}%>
                                            </select>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                 </div>
                 <div id="lics" style="margin-left:3px;" class="scroll-cont">
                <div id="lics_section1_container">
                    <!-- JIC 15:04:24 Added License type -->
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
            </div>
            <!-- ici finit le frame des licenses -->
            </div>
           </div>
             
            <textarea style="display:none"  name="HiddenElement" id="HiddenElement"></textarea>
</form>
<%
    String sources = "emxPLMOnlineLocalAdminUpdatePerson.jsp?PLM_ExternalID="+sPersonId+"&ctxAdmin="+stringForJsp+"&ctxUser="+ListCtxUser;
%>
<script>addFooter("javascript:callMethod('<%=sources%>')","images/buttonDialogDone.gif","<%=Update%>","<%=Update%>");</script>
  </body>

</html>






           
           
                
      











