
<%
    String nlsINFO_UNKNOWN      =  getNLS("LicenseUnknown");
    String nlsINFO_UNAVAIL      =  getNLS("LicenseUnavailable");
    String nlsINFO_UNAVAIL_WARN =  getNLS("LicenseUnavailableWarning");
    String nlsINFO_AVAILABLE    =  getNLS("LicenseAvailable");
    String nlsINFO_SELECTALL    =  getNLS("LicenseSectionSelectUnselectAll");
    String nlsLicSectionFilter  =  getNLS("LicenseSectionFilter");
    String nlsLicSection2       =  getNLS("LicenseSectionOther");
    String YoudonotHaveRights   =  getNLS("NonAppropriateContext");
    

%>
<%!
    /*
     * Adds a line to a section
     *
     * @param id    the line id
     * @param chk   the 'checkbox' checked flag
     * @param state the line state (unknown, available, unavailable)
     * @param title the line title
     */
    public void addLine(JspWriter out, String id, boolean checked, String state, String nls_state, String title,String casualHour) throws java.io.IOException {
        String TabInteger[] = new String[3];
        TabInteger[0]=getNLS("0");
        TabInteger[1]=getNLS("40");
        TabInteger[2]=getNLS("40");
        
        String nlsINFO_FullCasual = myNLS.getMessage("LicenSectionFullOrCasual",TabInteger);

        // JIC 15:03:03 Removed Casual Hour combo
    	out.println("<tr>");
        String sChecked = checked ? " checked=\"checked\"" : "";
        out.println("  <td></td>");
		if(id.equals("IFW") || id.equals("CSV"))
            out.println("  <td><input type=\"checkbox\" id=\"lic_"+id+"_chk\" name=\"lic_"+id+"_chk\" value=\""+id+"\" onclick=\"clic(this);\" checked=\"checked\" disabled=\"disabled\"></td>");
		else
            out.println("  <td><input type=\"checkbox\" id=\"lic_"+id+"_chk\" name=\"lic_"+id+"_chk\" value=\""+id+"\" onclick=\"clic(this);\""+sChecked+"></td>");
        /*
        if(!checked){
            out.println("  <td id=\"lic_"+id+"_sel\" style=\"visibility:hidden\"><select id=\"lic_"+id+"_selected\" onchange=\"updateLicenseImage('"+id+"',this)\"  title=\""+nlsINFO_FullCasual+"\" style=\"cursor:pointer\"><option>0</option><option>40</option></select></td>");
        }
        else{
            if (casualHour.equals("40")){
                out.println("  <td id=\"lic_"+id+"_sel\"><select id=\"lic_"+id+"_selected\" onchange=\"updateLicenseImage('"+id+"',this)\"  title=\""+nlsINFO_FullCasual+"\" style=\"cursor:pointer\"><option>0</option><option selected>40</option></select></td>");
            }else{
                out.println("  <td id=\"lic_"+id+"_sel\"><select id=\"lic_"+id+"_selected\" onchange=\"updateLicenseImage('"+id+"',this)\"  title=\""+nlsINFO_FullCasual+"\" style=\"cursor:pointer\"><option>0</option><option>40</option></select></td>");
            }
        }
        */
        out.println("  <td/>");
        out.println("  <td><img src=\"images/iconLicense"+state+".gif\" id=\"lic_"+id+"\" title=\""+nls_state+"\" style=\"cursor:pointer\"></td>");
        out.println("  <td><div id=\"lic_"+id+"_txt\">"+title+"</div></td>");
        out.println("</tr>");
    }

%>
<%!
  public void addFirstLicenseSection(JspWriter out) throws java.io.IOException{
        String nlsLicSection1       =  getNLS("LicenseSectionUsed");
        String nlsINFO_SELECTALL    =  getNLS("LicenseSectionSelectUnselectAll");
        out.println("<div id=\"lics_section1\">");
        out.println("<table class=\"titleLic\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"100%\">");
        out.println("<colgroup>");
        out.println("<col class=\"tableLicCheckbox\" /><col class=\"tableLicCheckbox\" /><col class=\"tableLicTitle\" />");
        out.println("</colgroup>");
        out.println("<tr>");
        out.println("<td onclick=\"toggleSection('lics_section1')\">");
        out.println("<img src=\"images/iconSectionCollapse.gif\" id=\"lics_section1_img\">");
        out.println("</td>");
        out.println("<td>");
        // JIC 05:06:05: IR IR-375010-3DEXPERIENCER2015x: Changed "toggleCheck" into "toggleCheckLicense"
        out.println("<input id=\"lics_section1_chk\" type=\"checkbox\" title=\""+nlsINFO_SELECTALL+"\" onclick=\"toggleCheckLicense(this,'lics_section1_table');\" >" );
        out.println("</td>");
        out.println("<td>");
        out.println(nlsLicSection1);
        out.println("</td>");
        out.println("</tr>");
        out.println("</table>");
        out.println("</div>");
    }
%>
<%!
  public String getCasualLicencesAssigned(Context mainContext,String userName, String casualHour) throws Exception{
       int casualhour = Integer.parseInt(casualHour);
        String result = MqlUtil.mqlCommand(mainContext,"print person $1 select $2 dump $3",userName,"casualhour["+casualhour+"].product",",");
        return result;
    }
%>





