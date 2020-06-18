<%@include file = "../common/emxNavigatorInclude.inc"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.DateFormat"%>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities" %>
<%@include file = "../common/emxPLMOnlineIncludeStylesScript.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo" %>
<%@ page import="com.matrixone.vplm.posbusinessmodel.PeopleConstants" %>
<%@ page import="com.matrixone.apps.common.Person" %>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%--
    Document   : emxPLMOnlineLocalAdminAssignLicences.jsp
    Author     : LXM
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
      String message = (String)emxGetParameter(request,"message");

    
    String nlsINFO_UNKNOWN      =  getNLS("LicenseUnknown");
    String nlsINFO_UNAVAIL      =  getNLS("LicenseUnavailable");
    String nlsINFO_UNAVAIL_WARN =  getNLS("LicenseUnavailableWarning");
    String nlsINFO_AVAILABLE    =  getNLS("LicenseAvailable");
    String nlsINFO_SELECTALL    =  getNLS("LicenseSectionSelectUnselectAll");
    String nlsLicSection1       =  getNLS("LicenseSectionUsed");
    String nlsLicSectionFilter  =  getNLS("LicenseSectionFilter");
    String nlsLicSection2       =  getNLS("LicenseSectionOther");
	String Update =  getNLS("Update");

    TreeMap mapUserLicenses = new TreeMap();
    String sPersonId="";
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

    // JIC 15:04:21 Added casual hour
    int casualHour = 0;
    if (sPersonId.length()>0) {
        Person person = Person.getPerson(context, sPersonId);
    	casualHour = new Integer(person.getAttributeValue(context, PeopleConstants.ATTRIBUTE_CASUAL_HOUR)).intValue();
    }
%>

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
               <style>
            div.horiz      { width:100%; position:relative; }
            div.entete   { height:7%; }
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

// update NLS title help
nlsINFO_SELECTALL      = "<%=nlsINFO_SELECTALL%>";
nlsINFO_AVAILABLE      = "<%=nlsINFO_AVAILABLE%>";
nlsINFO_UNAVAIL        = "<%=nlsINFO_UNAVAIL%>";
nlsSECTION_AVAIL          = "<%=getNLS("LicenseSectionAvailable")%>";
nlsSECTION_UNAVAIL_RICH   = "<%=getNLS("LicenseSectionUnavailableRich")%>";
nlsSECTION_UNAVAIL_SERVER = "<%=getNLS("LicenseSectionUnavailableServer")%>";
//

var prev_filter_lic = "";
var filter_lic = false;

/*
if(!Array.indexOf){
  Array.prototype.indexOf = function(obj){
   for(var i=0; i<this.length; i++){
    if(this[i]==obj){
     return i;
    }
   }
   return -1;
  }
}
*/


var xmlreqs = new Array();



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

        function initXPPerson(){
            xmlreq("emxPLMOnlineAdminXHRLicenseGet.jsp","",getLicensesResponse,1);

        }


        function UpdateUsers(users){
            var licences = getSelectedCheckbox();
            
            var listOfCtx = document.getElementById("listCtxAdmin");
            var CtxNames = "";
            for (var i = 0 ; i < listOfCtx.length ; i++){
                var text =document.getElementById("listCtxAdmin").options[i].selected;
                if (text == true){
                    CtxNames=CtxNames+document.getElementById("listCtxAdmin").options[i].text+",,";
                }
            }
            document.getElementById("submitForm").action = document.getElementById("submitForm").action+"?users="+users+"&secContexts="+CtxNames+"&licences="+licences;
            document.getElementById("submitForm").submit();
            
        }

        </script>

    </head>
    <body onload="javascript:initXPPerson();">
         <form action="emxPLMOnlineLocalAdminUpdateLicences.jsp" id="submitForm" name="submitForm"  method="POST">
               <%if (message != null) {%>
               <script type="text/javascript">setTime("<%=message%>");</script>
                 <%}%>
                  <div class="divHauts horiz" id="divHauts" style=" border: 1px ; border-color: white">
                <div class="scroll-cont">
                    <%  String Users= emxGetParameter(request,"users");
                        StringList ListCtxFinalString = AdminUtilities.getLocalAdminAssignableContexts(mainContext);
                        ListCtxFinalString.sort();%>
                      <table style="height:100%" width="100%">
                          <tr align="center">
                              <td class="titleAdmin"><%=getNLS("SecurityContexts")%> :</td>
                              <td align="center" >
                                            <%if (ListCtxFinalString.size() < 10 ){%>
                                            <select multiple id="listCtxAdmin" size="<%=ListCtxFinalString.size()%>">
                                            <%}else{%>
                                            <select multiple id="listCtxAdmin" size="10">
                                                <%}%>
                                                <%
                                                for (int i = 0; i < ListCtxFinalString.size() ; i++){

                                                %>
                                                <option value="<%=ListCtxFinalString.get(i)%>"><%=ListCtxFinalString.get(i)%>
                                                <%}%>
                                            </select>
                                        </td>
                                    </tr>
                                </table>
                </div>
            <!-- ici commence le frame des licenses -->
            <div id="lics" style="margin-left:3px;" class="scroll-cont">
                <div id="lics_section1_container">
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
                        <table class="titleLic" id="lics_section1_table" border="0" cellspacing="0" cellpadding="0" width="100%">
                            <colgroup>
                                <col class="tableLicMargin" />
                                <col class="tableLicCheckbox" />
                                <col class="tableLicAvailability" />
                                <col class="tableLicTitle" />
                            </colgroup>
                            <%
                                // JIC 14:04:02 Added expire date
                                DateFormat dateFormat = DateFormat.getDateInstance(DateFormat.MEDIUM, getNLSCatalog().getLocale());
                                for (Iterator it = licinfos.iterator(); it.hasNext();) {
                                    LicenseInfo licenseInfo = (LicenseInfo)it.next();
                                    boolean bAssignedToUser = (sPersonId.length()>0) && mapUserLicenses.containsKey(licenseInfo.getName());
                                    // JIC 15:04:21 Added multiple casual hour/assignment support
                                    java.util.List<Integer> lstCasualHour = licenseInfo.getCasualHours();
                                    for (int i = 0; i < lstCasualHour.size(); i++) {
                                        // JIC 15:06:03 IR IR-375897-3DEXPERIENCER2015x: Moved back to single "is assigned" information coming from MCS rather than N coming from license server
                                        if (lstCasualHour.get(i).equals(casualHour) && licenseInfo.isAssigned()) {
                                            String titleExpireDate = "";
                                            Date expireDate = licenseInfo.getExpireDate();
                                            if (expireDate != null) {
                                                titleExpireDate = " (" + getNLS("LicenseExpires") + " " + dateFormat.format(expireDate) + ")";
                                            }
                                            addLine(out, licenseInfo.getName(), bAssignedToUser, "Unknown", nlsINFO_UNKNOWN, licenseInfo.getTitle()+titleExpireDate);
                                        }
                                    }
                                }

                            %>

                        </table>
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
            

            <textarea style="display:none"  name="HiddenElement" id="HiddenElement"></textarea>
        </form>
<script>addFooter("javascript:UpdateUsers('<%=Users%>')","images/buttonDialogDone.gif","<%=Update%>","<%=Update%>");</script>
  </body>
</html>



















