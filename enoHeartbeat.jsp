<%--  enoHearbeat.jsp - Heartbeat check for ENOVIA application stack.

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   
   Changed for: IR-390875-3DEXPERIENCER2017x
--%>

<%@ page import="matrix.db.*, matrix.util.*, com.matrixone.servlet.*,com.matrixone.apps.domain.util.*" %>

<%

    // initialize local vars
    Context context = null;
    MQLCommand mql = null;

    //
    // This servlet tests a DB connection so that a load balancer can check that
    // a server is alive. The ENOVIA database needs to contain the following:
    //
    // Admin User: "Test Heartbeat" standard privelage, no assignements
    // Business Object Person: "Test Heartbeat" in Vault "eService Administration"
    //
    String serverUsername = "Test Heartbeat";
    String serverPassword = "Test Heartbeat";
    String serverVault = "eService Administration";
    String testUsername = "Test Everything";
    String testVault = "eService Production";

    boolean success = false;
    long elapsedTime = 0L;
    String serverHost = Framework.getPropertyValue("ematrix.server.host");
    if (serverHost == null) {
        serverHost = "localhost";
    }

    // try a db connection
    try {

        context = new Context(serverHost);
        context.setSessionId(session.getId());
        context.setUser(serverUsername);
        context.setPassword(serverPassword);
        context.setVault(serverVault);
        context.setLocale(Framework.getLocale(request.getHeader("Accept-Language")));
        context.setLanguage(request.getHeader("Accept-Language"));
        context.setTimezone(request.getHeader("mx-timezone"));

        elapsedTime = System.nanoTime();
        context.connect();

        // test the connection
        mql = new MQLCommand();
        mql.executeCommand(context, "print bus $1 $2 $3 in $4 select $5 dump","Person",testUsername,"-",testVault,"id");        
        String errorMsg = mql.getError();
        if (errorMsg != null && errorMsg.length() != 0) {
            throw new MatrixException(errorMsg);
        }
        String objId = mql.getResult().trim();

        // get the elapsed time of the connect test
        elapsedTime = System.nanoTime() - elapsedTime;
        success = true;

    } catch (MatrixException e) {

        e.printStackTrace(System.err);
        Framework.setError(request,
            new MatrixServletException(HttpServletResponse.SC_ACCEPTED, e));
        success = false;

    }
    
    //Now check to see if the all the properties used by the login page are available
    try {
        String sProperty = null;
        sProperty = FrameworkProperties.getProperty("emxFramework.External.Authentication");
        sProperty = FrameworkProperties.getProperty("emxFramework.Application.LoginImage");
        sProperty = FrameworkProperties.getProperty("emxLogin.FrameworkTarget");        
        sProperty = FrameworkProperties.getProperty("emxLogin.UseLoginInclude");
        sProperty = FrameworkProperties.getProperty("emxLogin.LoginIncludePage");
        sProperty = FrameworkProperties.getProperty("emxLogin.BodyColor");
        sProperty = FrameworkProperties.getProperty("emxLogin.BodyImage");
        sProperty = FrameworkProperties.getProperty("emxLogin.FormAction");
    } catch (FrameworkException ex) {
        success = false;
    }
    
    // destroy the context
    if (context != null) {
        try {
            context.shutdown();
        } catch( MatrixException e ) {
        }
    }

    // if there was a successful connection
    if (success) {
%>

<html>
    <body>
        <!-- //XSSOK -->
        ALIVE [<%=elapsedTime%> nanoseconds]
    </body>
</html>

<%
    } else {
%>

<html>
    <body>
       <!-- //XSSOK -->
        DEAD [<%=elapsedTime%> nanoseconds]
    </body>
</html>

<%
    }
%>
