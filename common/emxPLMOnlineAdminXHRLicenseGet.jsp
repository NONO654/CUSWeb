<?xml version="1.0" encoding="UTF-8"?>
<%@page contentType="text/xml"%>
<%@ page import="com.matrixone.servlet.Framework"%>
<%@ page import="matrix.db.Context"%>
<%@ page import="java.io.IOException"%>
<%@ page import="java.util.TreeMap,java.util.Iterator,java.util.Collection,java.io.PrintWriter"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.List"%>
<%@ page import="java.text.DateFormat"%>
<%@ page import="com.matrixone.vplm.posmodel.license.LicenseInfo"%>
<%@ page import="com.matrixone.vplm.posbusinessmodel.PeopleConstants" %>
<%@ page import="com.matrixone.apps.common.Person" %>
<%@ page import="com.dassault_systemes.vplmposadministrationui.uiutil.AdminUtilities"%>
<%@include file = "../common/emxPLMOnlineAdminAttributesCalculation.jsp"%>
<%@include file = "../emxRequestWrapperMethods.inc"%>
<%@include file = "../common/emxPLMOnlineAdminAuthorize.jsp"%>
<%!
    private static final String gsHTML_LT  = "&lt;";
    private static final String gsHTML_GT  = "&gt;";
    private static final String gsHTML_AMP = "&amp;";
    /**
     * 
     */
    public String htmlize(String str) {
        StringBuffer buf = new StringBuffer();
        int lng = str.length();
		if(lng>64) lng = 64;//license title are limited to 64 chars
        for (int i = 0; i < lng; i++) {
            char c =  str.charAt(i);
            switch (c) {
                case '<': buf.append(gsHTML_LT);  break;
                case '>': buf.append(gsHTML_GT);  break;
                case '&': buf.append(gsHTML_AMP); break;
                default : buf.append(c);
            }
        }
        return buf.toString();
    }

    /**
     * 
     */
    public void returnSection(JspWriter out, String section, TreeMap lics) throws IOException {
        Collection licinfos = lics.values();
        // JIC 14:04:02 Added expire date
        DateFormat dateFormat = DateFormat.getDateInstance(DateFormat.MEDIUM, getNLSCatalog().getLocale());
        for (Iterator it = licinfos.iterator(); it.hasNext();) {
            LicenseInfo licenseInfo = (LicenseInfo)it.next();
            String title = htmlize(licenseInfo.getTitle());
            if (title==null || title.length()==0) title = licenseInfo.getName();
            String titleExpireDate = "";
            Date expireDate = licenseInfo.getExpireDate();
            if (expireDate != null) {
                titleExpireDate = " (" + getNLS("LicenseExpires") + " " + dateFormat.format(expireDate) + ")";
            }
            out.print("<"+section+" id=\""+licenseInfo.getName()+"\" title=\""+title+titleExpireDate+"\" />");
        }
    }

    // JIC 15:04:15 Added function returnSection2
    public void returnSection2(JspWriter out, String section, TreeMap lics, TreeMap mapUserLicenses, boolean bTypeHasChanged) throws IOException {
        Collection licinfos = lics.values();
        DateFormat dateFormat = DateFormat.getDateInstance(DateFormat.MEDIUM, getNLSCatalog().getLocale());
        for (Iterator it = licinfos.iterator(); it.hasNext();) {
            LicenseInfo licenseInfo = (LicenseInfo)it.next();
            String title = htmlize(licenseInfo.getTitle());
            if (title==null || title.length()==0) title = licenseInfo.getName();
            String titleExpireDate = "";
            Date expireDate = licenseInfo.getExpireDate();
            if (expireDate != null) {
                titleExpireDate = " (" + getNLS("LicenseExpires") + " " + dateFormat.format(expireDate) + ")";
            }
            String state = licenseInfo.isAvailable()?"Available":"Unavailable";
            // JIC 15:04:21 Added check on user licenses
            String checked = "false";
            // Only check for assigned licenses if license type hasn't changed (otherwise all licenses are uncheked)
            if (!bTypeHasChanged) {
                /*
                for (int i = 0; i < lListUserLicenses.size(); i++) {
                    if (((String)lListUserLicenses.get(i)).equals(licenseInfo.getName())) {
                        checked = "true";
                        break;
                    }
                }
                */
                if (mapUserLicenses.containsKey(licenseInfo.getName())) {
                    checked = "true";
                }
            }
            out.print("<"+section+" id=\""+licenseInfo.getName()+"\" title=\""+title+titleExpireDate+"\" state=\""+state+"\" checked=\""+checked+"\"/>");
        }
    }
    %>
    <%
    //System.out.println("get license info");

    // get current context
    Context context = (Context)request.getAttribute("__AEF_FrameContext__");
	if (context == null)
	{
		context = Framework. getFrameContext(session);
		request.setAttribute("__AEF_FrameContext__",context);
	}

    %><licenses><%
    // JIC 15:04:08 Added Casual hour support
	int casualHour = 0;
    if (emxGetParameter(request, "CasualHour") != null)
    {
        casualHour = new Integer(emxGetParameter(request, "CasualHour")).intValue();
    }

    // JIC 15:04:21 Added User ID support
	String sPersonId = emxGetParameter(request, "User");

    // get license information from DB and License servers
    TreeMap lics = new TreeMap();
    try {
        LicenseInfo.getDeclaredLicenses(context, lics, null);
        LicenseInfo.updateLicensesStatus(context, lics);
        Collection licinfos = lics.values();

        // JIC 15:04:21 Added user licenses
        TreeMap mapUserLicenses = new TreeMap();
        if (sPersonId != null) {
            Vector lListUserLicenses = new Vector();
            LicenseInfo.getUserLicenses(context, sPersonId, lListUserLicenses);
            for (int i = 0; i < lListUserLicenses.size(); i++) {
                String s = (String)lListUserLicenses.get(i);
                mapUserLicenses.put(s,s);
            }
        }

        // JIC 15:04:21 Added casual hour
        int personCasualHour = 0;
        if (sPersonId != null) {
            Person person = Person.getPerson(context, sPersonId);
            personCasualHour = new Integer(person.getAttributeValue(context, PeopleConstants.ATTRIBUTE_CASUAL_HOUR)).intValue();
        }

        %><status>OK</status><%

        // send 
        // JIC 15:04:15 Added assigned licenses
        TreeMap lics_assigned     = new TreeMap();
        TreeMap lics_avail        = new TreeMap();
        TreeMap lics_unavail_rich = new TreeMap();
        TreeMap lics_unavail_serv = new TreeMap();
        for (Iterator it = licinfos.iterator(); it.hasNext();) {
            LicenseInfo licenseInfo = (LicenseInfo)it.next();
            // JIC 15:04:08 Added Casual hour support
            List<Integer> lstCasualHour = licenseInfo.getCasualHours();
            for (int i = 0; i < lstCasualHour.size(); i++)
            {
                int licenseCasualHour = new Integer(lstCasualHour.get(i)).intValue();
                if (licenseCasualHour == casualHour) {
                    // JIC 15:06:03 IR IR-375897-3DEXPERIENCER2015x: Moved back to single "is assigned" information coming from MCS rather than N coming from license server
                    if (licenseInfo.isAssigned()) {
                        lics_assigned.put(licenseInfo.getName(), licenseInfo);
                    }
                    if (licenseInfo.isAvailable()) {
                        %><lic id="<%=licenseInfo.getName()%>" /><%
                        lics_avail.put(licenseInfo.getName(), licenseInfo);
                    }
                    else {
                        if (licenseInfo.isRichclient()) {
                            lics_unavail_rich.put(licenseInfo.getName(), licenseInfo);
                        }
                        else {
                            lics_unavail_serv.put(licenseInfo.getName(), licenseInfo);
                        }
                    }
                    break;
                }
            }

            // JIC 15:04:08 Added specific case when license has no Casual hour (case of unavailable licenses)
            if (lstCasualHour.size() == 0) {
                if (licenseInfo.isRichclient()) {
                    lics_unavail_rich.put(licenseInfo.getName(), licenseInfo);
                }
                else {
                    lics_unavail_serv.put(licenseInfo.getName(), licenseInfo);
                }
            }
        }
        returnSection2(out, "assigned", lics_assigned, mapUserLicenses, personCasualHour != casualHour);
        returnSection(out, "available", lics_avail);
        returnSection(out, "unavail_rich", lics_unavail_rich);
        returnSection(out, "unavail_server", lics_unavail_serv);
    }
    catch (Exception ex) {
        %><status>FAIL</status><exception><%=ex.getMessage()%></exception><%
    }
%></licenses>
