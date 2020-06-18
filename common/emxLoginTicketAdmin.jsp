<%-- 
    Document   : emxLoginTicketAdmin
    Created on : Aug 28, 2014, 7:22:55 PM
    Author     : jpa
--%>


<%@page import="com.dassault_systemes.vplmsecurity.util.PLMUtil"%>
<%@page import="com.dassault_systemes.vplmsecurity.PLMSecurityManager"%>
<%@page import="com.dassault_systemes.plmsecurity.ticket.LoginTicket"%>
<%@page import="com.dassault_systemes.plmsecurity.ticket.LoginTicketServices"%>
<%@page import="com.matrixone.apps.domain.util.MapList"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="java.io.IOException"%>
<%@page import="java.text.MessageFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.Enumeration" %>
<%@page import="java.util.Set" %>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.Locale" %>
<%@page import="java.util.ResourceBundle"%>
<%@page import="matrix.db.BusinessObject"%>
<%@page import="matrix.db.Attribute"%>
<%@page import="matrix.db.AttributeList"%>
<%@page import="matrix.db.User"%>
<%@page import="matrix.util.StringList"%>
<%@page import="matrix.util.StringItr"%>

<!--%@page contentType="text/html" pageEncoding="UTF-8"%-->

<%@include file = "../common/emxNavigatorInclude.inc"%>

<%!
    private static String PARAM_USER    = "user";
    private static String PARAM_CTX     = "ctx";
    private static String PARAM_USETYPE = "usetype";
    private static String PARAM_USENB   = "maxuse";
    //
    private SimpleDateFormat _tsFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    private SimpleDateFormat _stFmt = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss a");
    //----------------------------------------------------------------------
    public ResourceBundle initBundle(Locale locale)
    {
        Locale finalLocale = (locale==null) ? Locale.getDefault() : locale;
        try {
            ResourceBundle rb = ResourceBundle.getBundle("PLMSecurityLoginTicket", finalLocale);
            return rb;
        } catch (Exception ex) {
            System.out.println("ERROR: could not find bundle for 'emxLoginTicket");
        }
        return null;
    }
    //----------------------------------------------------------------------
	public String getNLS(ResourceBundle myNLS, String tag)
	{
        String value = tag;
        if (myNLS!=null) {
            try {
                value = myNLS.getString(tag);
            }
            catch (MissingResourceException ex) {
                value = "[missing: "+tag+"]";
            }
        }
        return value;
    }
    //----------------------------------------------------------------------
	public String getNLS(ResourceBundle myNLS, String tag, Object[] params)
	{
        String value = tag;
        if (myNLS!=null) {
            try {
                String sFormatMsg = myNLS.getString(tag);
                try {
                    value = MessageFormat.format(sFormatMsg, params);
                }
                catch (Exception mex) {
                    value = "[fmt error: "+sFormatMsg+"]";
                }
            }
            catch (MissingResourceException ex) {
                value = "[missing: "+tag+"]";
            }
        }
        return value;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Login Ticket Administration page</title>
<style>
body          {font-family: arial;}
tr.deleting   {color: red; }
td.key        {background-color: #efefef; font-family: courier, monospace;}
td.number     {text-align: center}
td.owner      {color: lightgray}
td.date       {font-family: courier, monospace;}
th            {background-color: #cfefef; }
.btnRefresh   {background-image:url(images/buttonDialogRefresh.gif)}
</style>
<script>
    /**
     * setUse(nb, setTextEntryModifiable)
     */
    function setUse(nb, setTextEntryModifiable) {
        //alert("setUse( nb="+nb+", edit="+setTextEntryModifiable );
        with (document.forms.LTCreate.nbuse) {
            value   = nb;
            readonly = setTextEntryModifiable ? null : "true";
        }
        return false;
    }
    /**
     * doSubmit
     */
    function doSubmit(action) {
        //alert("action: "+action+", formaction: "+document.forms.tickets.action );
        //document.forms.tickets.b_action.value = action;
        document.forms.LTCreate.submit();
        return false;
    }
</script>
</head>
<body>

<%
    matrix.db.Context mainCtx = (matrix.db.Context)session.getAttribute("ematrix.context");
    if (mainCtx==null) 
    {
        response.addHeader("Location", request.getServletContext().getContextPath());
        response.sendError(HttpServletResponse.SC_MOVED_TEMPORARILY);
        return;
    }
    String sCurrentUser = mainCtx.getUser() == null ? "guest" : mainCtx.getUser();
    String sCurrentCtx  = mainCtx.getRole() == null ? "" : PLMUtil.M1RoleToContext(mainCtx.getRole());
    PLMSecurityManager scm = new PLMSecurityManager(mainCtx);
    StringList listOfContexts = scm.getSecurityContextIds();

    // NLS catalog
    ResourceBundle myNLS = initBundle(request.getLocale());
    String emxLTCreate_title         = getNLS(myNLS, "emxLTCreate.title");
    String emxLTCreate_created_title = getNLS(myNLS, "emxLTCreate.created.title");
    String emxLTCreate_created_value = getNLS(myNLS, "emxLTCreate.created.value");
    String emxLTCreate_user          = getNLS(myNLS, "emxLTCreate.user");
    String emxLTCreate_ctx           = getNLS(myNLS, "emxLTCreate.ctx");
    String emxLTCreate_type          = getNLS(myNLS, "emxLTCreate.type");
    String emxLTCreate_type_infinite = getNLS(myNLS, "emxLTCreate.type.infinite");
    String emxLTCreate_type_once     = getNLS(myNLS, "emxLTCreate.type.once");
    String emxLTCreate_type_number   = getNLS(myNLS, "emxLTCreate.type.number");
    String emxLTCreate_button_create = getNLS(myNLS, "emxLTCreate.button.create");

    String err_invalid_negative      = getNLS(myNLS, "emxLTCreate.created.error.InvalidNegativeNumber");
    String err_invalid_number        = getNLS(myNLS, "emxLTCreate.created.error.InvalidNumber");
    String err_invalid_type          = getNLS(myNLS, "emxLTCreate.created.error.UnsupportedType");

    // FIXME use frame context (must also shutdown it finally)
    matrix.db.Context frameCtx = mainCtx;

    // DEBUG+
    /*
    Enumeration parameters = request.getParameterNames();
    for (;parameters.hasMoreElements();) {
        String paramName = (String)parameters.nextElement();
        System.out.println("==> param["+paramName+"] = "+request.getParameter(paramName));
        }
    */
    // DEBUG-

%>
<h1><%=emxLTCreate_title%></h1>
<%
    // ---------------------------------------------------
    // create ticket, if one was required
    // ---------------------------------------------------
    String button_action = request.getParameter("b_action");
    if ("create".equals(button_action))
    {
%>
        <p><%=emxLTCreate_created_title%>:</p>
<%
        int nMaxUse = 0;
        String i_user    = sCurrentUser; // Use current user for security (cf IR-512656) request.getParameter(PARAM_USER);
        String i_ctx     = request.getParameter(PARAM_CTX);
        String i_usetype = request.getParameter(PARAM_USETYPE);
        String i_usenb   = request.getParameter(PARAM_USENB);
        try {
        // Add xss enclosing for ctx (see  IR-723932 for details).
%>
        <p>- user: <%=i_user%></p>
        <p>- ctx : <xss:encodeForHTML><%=i_ctx%></xss:encodeForHTML></p>
<%
            if ("infinite".equals(i_usetype)) {
%>
        <p>- tk  : infinite</p>
<%
            }
            else if ("once".equals(i_usetype)) {
                nMaxUse = 1;
%>
        <p>- tk  : once</p>
<%
            }
            else if ("number".equals(i_usetype)) {
                try {
                    nMaxUse = Integer.parseInt(i_usenb);
                    if (nMaxUse < 0) {
                        throw new IllegalArgumentException(err_invalid_negative);
                    }
                } catch (NumberFormatException numex) {
                    throw new IllegalArgumentException(err_invalid_number, numex);
                }
%>
        <p>- tk  : number=<%=i_usenb%></p>
<%
            }
            else {
                throw new IllegalArgumentException(err_invalid_type);
            }

            Date date_NONE = null;
            Set<String> clientRestrictions = null;
            LoginTicket lt = LoginTicketServices.requireLoginTicket(frameCtx, i_user, i_ctx, date_NONE, date_NONE, nMaxUse, clientRestrictions);
            String sToken = lt.getToken();
%>
        <p><%=emxLTCreate_created_value%> = <code><%=sToken%></code></p>
<%
        }
        catch (Exception ex) {
        // Add xss enclosing for error (see  IR-723932 for details).
%>
        <p>ERROR = <code><xss:encodeForHTML><%=ex.getMessage()%></xss:encodeForHTML></code></p>
<%
        }
    }

    // ---------------------------------------------------
    // display login ticket creation form
    // ---------------------------------------------------
%>
    <form id="LTCreate" name="LTCreate" action="emxLoginTicketAdmin.jsp" method="post">
    <input type="hidden" name="b_action" value="create"/>
    <table border="1">
        <tr>
            <td><%=emxLTCreate_user%>:</td>
            <td><input name="<%=PARAM_USER%>" type="text" size="60" value="<%=sCurrentUser%>" readonly="true" /></td>
        </tr>
        <tr>
            <td><%=emxLTCreate_ctx%>:</td>
            <td>
                <select name="<%=PARAM_CTX%>">
<%
    StringItr itr = new StringItr(listOfContexts);
    while (itr.next())
    {
        String sCtx = itr.obj();
        if (sCtx!=null) {
            if (sCtx.equals(sCurrentCtx)) {
                %><option selected="true"><%=sCtx%></option><%
            } else {
                %><option><%=sCtx%></option><%
            }
        }
    }
%>
                </select>
            </td>
        </tr>
        <tr>
            <td><%=emxLTCreate_type%>:</td>
            <td> 
                <input type="radio" name="<%=PARAM_USETYPE%>" value="infinite" onClick="setUse(0,false);" checked="true"><%=emxLTCreate_type_infinite%></input> 
                <input type="radio" name="<%=PARAM_USETYPE%>" value="once"     onClick="setUse(1,false);"><%=emxLTCreate_type_once%></input>
            </td>
        </tr>
        <tr>
            <td colspan="2">
                <center><input type="button" name="b_create" value="<%=emxLTCreate_button_create%>" class="btnCreate"  onclick="doSubmit('create');"/></center>
            </td>
        </tr>
    </table>
    </form>
    </body>
</html>
