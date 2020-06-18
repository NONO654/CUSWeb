<%--  emxHelpAbout.jsp   -

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program.

   static const char RCSID[] = $Id: emxHelpAbout.jsp.rca 1.13 Tue Oct 28 18:55:07 2008 przemek Experimental przemek $
--%>

<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxUIConstantsInclude.inc"%>

<%
  String replaceVersion = "V6R2008-2.0";
  String newVersion = "V6R2009";
  int versionLength = replaceVersion.length();
  
  ServerVersion version = new ServerVersion();
  version.open(context);

  String host = version.getHost(context);
  String user = version.getUser(context);
  String dbServerName = version.getDatabaseServerName(context);
  String dbServerVersion = version.getDatabaseServerVersion(context);
  String driverName = version.getDatabaseDriverName(context);
  String driverVersion = version.getDatabaseDriverVersion(context);
  String serverVersion = version.getVersion(context);
  int versionIndex = serverVersion.indexOf(replaceVersion);
  if (versionIndex >= 0)
  {
  	serverVersion = newVersion + serverVersion.substring(versionLength);
  }
  
  String strAppName = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout.ApplicationName");

  version.close(context);

  String osName = System.getProperty("os.name");
  String osArch = System.getProperty("os.arch");
  String osArchDataModel = System.getProperty("os.arch.data.model");	
  if(osArchDataModel== null || osArchDataModel.length()==0)
          osArchDataModel = System.getProperty("sun.arch.data.model");

  String osVersion = System.getProperty("os.version");				

  String javaVersion = System.getProperty("java.version");
  String javaVendor = System.getProperty("java.vendor");
  
  //Added for Advanced Help
  Hashtable advList = new Hashtable();
  String filterValue = emxGetParameter(request,"mx.page.filter");
  if(filterValue == null || "".equals(filterValue) || "null".equals(filterValue))
  {
    filterValue = "All";
  }
  if(filterValue.equalsIgnoreCase("All") || filterValue.equalsIgnoreCase("HotFixesInstalled") || filterValue.equalsIgnoreCase("ConversionsRun") || filterValue.equalsIgnoreCase("Schema"))
  {
    advList = com.matrixone.apps.domain.util.FrameworkUtil.getAdvancedHelpInfo(context);
  }
  
  // 2/22/11-oeo- IR 0939999V6R2012
  // Only Administration Manager can see Infrastructure section.
  Vector userRoles = UICache.getUserRoles(context);
  String strAdminMgrRole = PropertyUtil.getSchemaProperty(context,"role_AdministrationManager");
  boolean isAdminManager = userRoles.contains(strAdminMgrRole);

  //get applications installed and versions
  //EXECUTE THE TCL PROGRAM

  String Result = "";
  String error = "";
  String sErrorCode = "";

  MQLCommand prMQL  = new MQLCommand();
  prMQL.open(context);

  prMQL.executeCommand(context,"execute program $1 $2","eServiceHelpAbout.tcl","TRUE");
  Result = prMQL.getResult().trim();
  error = prMQL.getError();
 
  String baseVersion = "";
  try{
	baseVersion = com.matrixone.apps.domain.util.MqlUtil.mqlCommand(context, "print prog $1 select $2 dump",
                      "eServiceSystemInformation.tcl","property[version].value");
  }catch (Exception ex){
      error = ex.getMessage();
  }
  
  MessageFormat messFmt = new MessageFormat("{0}.{1}");
  try{
      Object[] arrBaseVersion = messFmt.parse(baseVersion);
      baseVersion = (String)arrBaseVersion[0];
  }catch(ParseException parseEx){
      error = parseEx.getMessage();
  }
  
  int baseVersionIndex = baseVersion.indexOf(replaceVersion);
  if (baseVersionIndex >= 0)
  {
  	baseVersion = FrameworkUtil.findAndReplace(baseVersion,replaceVersion, newVersion);
  }
  
  if( Result.equals(""))//tcl program does not exist
  {
    session.putValue("Error",error);

%>
  <!-- //XSSOK -->
  <emxUtil:i18n localize="i18nId">emxFramework.Common.Error</emxUtil:i18n>: <%=error%>
<%
  }

  StringTokenizer token = new StringTokenizer(Result, "|", false);
  sErrorCode = token.nextToken().trim();//first token

  if( sErrorCode.equals("1"))//internal failure of tcl program
  {
    session.putValue("Error",token.nextToken().trim());//second token

%>
    <!-- //XSSOK -->
    <emxUtil:i18n localize="i18nId">emxFramework.Common.Error</emxUtil:i18n>: <%=error%>
<%
  }
%>

<HTML lang="en-US">
  <HEAD>
    <TITLE><emxUtil:i18n localize="i18nId">emxFramework.About.About</emxUtil:i18n></TITLE>
    <META http-equiv="imagetoolbar" content="no" />
    <SCRIPT language="JavaScript" src="scripts/emxUIModal.js"
          type="text/javascript">
    </SCRIPT>
    <SCRIPT language="JavaScript" src="scripts/emxUIPopups.js" type="text/javascript">
    </SCRIPT>
    <LINK rel="stylesheet" href="styles/emxUIDefault.css"  type="text/css" />
    <LINK rel="stylesheet" href="styles/emxUIForm.css" type="text/css" />
    <LINK rel="stylesheet" href="styles/emxUIList.css" type="text/css" />
  </HEAD>
  <BODY class="content" onload="turnOffProgress()">
    <FORM>
      <TABLE>
		<TR>
          <TD class="label">
            <LABEL for="Copyright"><emxUtil:i18n localize="i18nId">emxFramework.About.Copyright</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <emxUtil:i18n localize="i18nId">emxFramework.Copyright</emxUtil:i18n>
          </TD>
        </TR>
        <TR>
          <TD class="label">
            <LABEL for="Application Vendor"><emxUtil:i18n localize="i18nId">emxFramework.About.ApplicationVendor</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <%=strAppName%>
          </TD>
        </TR>
      </TABLE><BR/>

<%if(filterValue.equalsIgnoreCase("ProductVersion") || filterValue.equalsIgnoreCase("All")){%>

	<% 
	//added for - easy version string               
	String vServer = FrameworkUtil.findAndReplace(serverVersion," ", "_"); 
    boolean serverKeyFound = false;
    try{
        String versionStrFromProp = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout.Version." + vServer);
    	if( versionStrFromProp!= null && !"".equalsIgnoreCase(versionStrFromProp)){
    	    serverVersion = versionStrFromProp;
    	    serverKeyFound = true;
    	}
    }catch(Exception e){
    }
    if(!serverKeyFound){
        if (serverVersion.indexOf(baseVersion) != -1){
    	    try{
    	        String serverVerFromProp = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout.Version." + baseVersion);
    	        if( serverVerFromProp!= null && !"".equalsIgnoreCase(serverVerFromProp)){
    	            serverVersion = FrameworkUtil.findAndReplace(serverVersion,baseVersion, serverVerFromProp); 
    	        }
    	    }catch(Exception e){}
        }
    }
    //end - easy version string
	
	%>
       
      <TABLE>
        <TR>
          <Td class="heading1" colspan="2">
            <LABEL for="Applications"><emxUtil:i18n localize="i18nId">emxFramework.About.Applications</emxUtil:i18n></LABEL>
          </Td>
        </TR>
   <TR>
          <TD class="label">
            <LABEL for="Ematrix Version"><emxUtil:i18n localize="i18nId">emxFramework.About.EmatrixVersion</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <xss:encodeForHTML><%=serverVersion%></xss:encodeForHTML>
          </TD>
        </TR> 
<%
                StringList applicationList=new StringList();
                applicationList.add("Framework");
                applicationList.add("BusinessMetrics");
                applicationList.add("CommonComponents");
                applicationList.add("TeamCentral");

                 while (token.hasMoreTokens())
                 {
                    String sApplicationName = (String)token.nextToken();
                    String versionValue = (String)token.nextToken();
                    versionIndex = versionValue.indexOf(replaceVersion);
                    if (versionIndex >= 0)
                    {
  	                   versionValue = newVersion + versionValue.substring(versionLength);
                    }
                    //added for - easy version string
                    String vStr = FrameworkUtil.findAndReplace(versionValue," ", "_"); 
                    boolean keyFound = false;
                    try{
                        String versionStrFromProp = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout.Version." + vStr);
                    	if( versionStrFromProp!= null && !"".equalsIgnoreCase(versionStrFromProp)){
                    	    versionValue = versionStrFromProp ;
                    	    keyFound = true;
                    	}
                    }catch(Exception e){
                    }
                    if(!keyFound){
                        if (versionValue.indexOf(baseVersion) != -1){
                        try{
                            String versionStrFromProp = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout.Version." + baseVersion);
                            if( versionStrFromProp!= null && !"".equalsIgnoreCase(versionStrFromProp)){
                               versionValue = FrameworkUtil.findAndReplace(versionValue,baseVersion, versionStrFromProp); 
                            }
                        }catch(Exception ex){}  
                        }
                    }
                    //end - easy version string
                    if (!applicationList.contains(sApplicationName))
                    {
                            try 
                            {
                                sApplicationName = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout." + sApplicationName);
                            }
                            catch(Exception ex)
                            {
                            }
                    }
                    else
                    {
                        continue;
                    }
%>
        <TR>
          <TD class="label">
            <LABEL for="Application"><xss:encodeForHTML><%=sApplicationName%></xss:encodeForHTML></LABEL>
          </TD>
          <TD class="inputField">
            <xss:encodeForHTML><%=versionValue%></xss:encodeForHTML>
          </TD>
        </TR>
        
<%
            }
%>
      </TABLE><BR/>
     <%}%> 
     
<%if(filterValue.equalsIgnoreCase("Schema") || filterValue.equalsIgnoreCase("All")){%>
       
      <TABLE>
        <TR>
          <td class="heading1" colspan="2">
            <LABEL for="Schemas"><emxUtil:i18n localize="i18nId">emxFramework.AdvancedHelp.Schema</emxUtil:i18n></LABEL>
          </td>
        </TR>
        <%
          HashMap schemas =(HashMap)advList.get("Schema");
          if(schemas.size()>0){
            java.util.Set keySet = schemas.keySet();
            Iterator itr = keySet.iterator();
            while(itr.hasNext()){
            String str = (String)itr.next();
            String versionStr = ((String)schemas.get(str)).trim();
            boolean keyFound = false;
            versionIndex = versionStr.indexOf(replaceVersion);
            if (versionIndex >= 0)
            {
  	        	versionStr = newVersion + versionStr.substring(versionLength);
            }
            //added for - easy version string
            try{
	            String vStr = FrameworkUtil.findAndReplace(versionStr," ", "_");
	            String versionStrFromProp = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout.Version." + vStr);
	        	if( versionStrFromProp!= null && !"".equalsIgnoreCase(versionStrFromProp)){
	        	    versionStr = versionStrFromProp ;
	        	    keyFound = true;
	        	}
            }catch(Exception e){}
            if(!keyFound){
	            if (versionStr.indexOf(baseVersion) != -1){
	            try{
		            String versionStrFromProp = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout.Version." + baseVersion);
		            if( versionStrFromProp!= null && !"".equalsIgnoreCase(versionStrFromProp)){
		        	    versionStr = FrameworkUtil.findAndReplace(versionStr,baseVersion, versionStrFromProp);
		            }
	            }catch(Exception e){}
	            }
            }
            //end - easy version string
        %>
        <TR>
          <TD class="label">
            <LABEL for="Schema"><xss:encodeForHTML><%=str%></xss:encodeForHTML></LABEL>
          </TD>
          <TD class="inputField">
          <xss:encodeForHTML><%=versionStr%></xss:encodeForHTML>
          </TD>
        </TR>
        <%}
        }else{%>
        <TR>
          <TD class="inputField">
            <emxUtil:i18n localize="i18nId">emxFramework.AdvancedHelp.NoSchema</emxUtil:i18n>
          </TD>
        </TR>
        <%}%>
      </TABLE><BR/>
      <%}%> 

<%if((filterValue.equalsIgnoreCase("Infrastructure") || filterValue.equalsIgnoreCase("All")) && isAdminManager){%>

      <TABLE>
        <TR>
          <TD class='heading1' colspan="2">
            <LABEL for="Infrastructure"><emxUtil:i18n localize="i18nId">emxFramework.About.Infrastructure</emxUtil:i18n></LABEL>
          </TD>
        </TR>
        <TR>
          <TD class="label">
            <LABEL for="OS Name"><emxUtil:i18n localize="i18nId">emxFramework.About.OSName</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <xss:encodeForHTML><%=osName%></xss:encodeForHTML>
          </TD>
        </TR>
        <TR>
          <TD class="label">
            <LABEL for="OS Version"><emxUtil:i18n localize="i18nId">emxFramework.About.OSVersion</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <xss:encodeForHTML><%=osVersion%></xss:encodeForHTML>
          </TD>
        </TR>
        <TR>
          <TD class="label">
            <LABEL for="OS Architecture"><emxUtil:i18n localize="i18nId">emxFramework.About.OSArchitecture</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <xss:encodeForHTML><%=osArch%></xss:encodeForHTML>
          </TD>
        </TR>
        <TR>
          <TD width="150" class="label">
            <LABEL for="OS Data Model"><emxUtil:i18n localize="i18nId">emxFramework.About.OSArchDataModel</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <xss:encodeForHTML><%=osArchDataModel%></xss:encodeForHTML>
          </TD>
        </TR>
        <TR>
          <TD class="label">
            <LABEL for="Java Vendor"><emxUtil:i18n localize="i18nId">emxFramework.About.JavaVendor</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <xss:encodeForHTML><%=javaVendor%></xss:encodeForHTML>
          </TD>
        </TR>
        <TR>
          <TD class="label">
            <LABEL for="Java Version"><emxUtil:i18n localize="i18nId">emxFramework.About.JavaVersion</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <xss:encodeForHTML><%=javaVersion%></xss:encodeForHTML>
          </TD>
        </TR>
        <TR>
          <TD class="label">
            <LABEL for="DB Connection"><emxUtil:i18n localize="i18nId">emxFramework.About.DBConnection</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
           <xss:encodeForHTML> <%=user%></xss:encodeForHTML>
          </TD>
        </TR>
        <TR>
          <TD class="label">
            <LABEL for="DB Vendor"><emxUtil:i18n localize="i18nId">emxFramework.About.DBVendor</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <xss:encodeForHTML><%=dbServerName%></xss:encodeForHTML>
          </TD>
        </TR>
        <TR>
          <TD class="label">
            <LABEL for="Driver Name"><emxUtil:i18n localize="i18nId">emxFramework.About.DriverName</emxUtil:i18n></LABEL>
          </TD>
          <TD class="inputField">
            <xss:encodeForHTML><%=driverName%></xss:encodeForHTML>
          </TD>
        </TR>
      </TABLE><BR/>
     <%}%> 
     
     <!--Added For Hot-Fixes -->
      <%
      if(filterValue.equalsIgnoreCase("HotFixesInstalled") || filterValue.equalsIgnoreCase("All")){

      %>
        <TABLE>
          <TR>
            <TD class='heading1' colspan="2">
              <emxUtil:i18n localize="i18nId">emxFramework.AdvancedHelp.HotFixesInstalled</emxUtil:i18n>
            </TD>
          </TR>
      <%
      HashMap hotFixes =(HashMap)advList.get("HotFixesInstalled");
      if(hotFixes.size()>0){
        java.util.Set keySet = hotFixes.keySet();
        Iterator itr = keySet.iterator();
        while(itr.hasNext()){
          String str = ((String)itr.next()).trim();
		//added for - easy version string
		  String displayStr = FrameworkUtil.findAndReplace(str," ", "_");
          try{
	            String versionStrFromProp = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout.Version." + displayStr);
	            if( versionStrFromProp!= null && !"".equalsIgnoreCase(versionStrFromProp)){
	                displayStr = versionStrFromProp;
	        	}
          }catch(Exception e){}
          //end - easy version string
        %>
          <TR>
            <TD class="label">
              <LABEL for="Hot Fixes"><xss:encodeForHTML><%=displayStr%></xss:encodeForHTML></LABEL>
            </TD>
          </TR>
          <%
          String strVersion = (String)hotFixes.get(str);
          StringTokenizer strTok = new StringTokenizer(strVersion, ",");
          while(strTok.hasMoreElements())
          {
          %> 
          <TR>
            <TD class="inputField">
              <xss:encodeForHTML><%=strTok.nextToken()%></xss:encodeForHTML>
            </TD>
          </TR>
        <%
          }
        }  
      }else{%>
        <TR>
          <TD class="inputField">
            <emxUtil:i18n localize="i18nId">emxFramework.AdvancedHelp.NoHotFixesInstalled</emxUtil:i18n>
          </TD>
        </TR>
      <%}%>
      </TABLE><BR/>
      <%}%> 
     
      <!--Added For Conversions -->
      <%if(filterValue.equalsIgnoreCase("ConversionsRun") || filterValue.equalsIgnoreCase("All")){%>
        <TABLE>
          <TR>
             <TD class='heading1' colspan="2">
               <emxUtil:i18n localize="i18nId">emxFramework.AdvancedHelp.ConversionsRun</emxUtil:i18n>
             </TD>
          </TR>
      <%
      Map conversions =(Map)advList.get("ConversionsRun");
      if(conversions.size()>0){
        java.util.Set keySet = conversions.keySet();
        Iterator itr = keySet.iterator();
        while(itr.hasNext()){
          String str = ((String)itr.next()).trim();
          if (str.length() == 0) {
        %>
          <TR>
            <TD colspan="2" class="label">
                <LABEL for="Conversions"><emxUtil:i18n localize="i18nId">emxFramework.About.Unknown.version</emxUtil:i18n></LABEL>
            </TD>
          </TR>
          <%
          } else {
			  //added for - easy version string
			  String vStr = FrameworkUtil.findAndReplace(str," ", "_");
              try{
                String versionStrFromProp = EnoviaResourceBundle.getProperty(context, "emxFramework.HelpAbout.Version." + vStr);
            		if( versionStrFromProp!= null && !"".equalsIgnoreCase(versionStrFromProp)){
            		    vStr = versionStrFromProp ;
            		}
              }catch(Exception e){}           
              //end - easy version string
        %>
          <TR>
            <TD colspan="2" class="label">
                <LABEL for="Conversions"><emxUtil:i18n localize="i18nId">emxFramework.About.version</emxUtil:i18n> <xss:encodeForHTML><%=vStr%></xss:encodeForHTML></LABEL>
            </TD>
          </TR>
          <%
          }
          String strVersion = (String)conversions.get(str);
          StringTokenizer strTok = new StringTokenizer(strVersion, ",");
          while(strTok.hasMoreElements())
          {
          %> 
            <TR>
              <TD colspan="2" class="inputField">
                <xss:encodeForHTML><%=strTok.nextToken()%></xss:encodeForHTML>
              </TD>
            </TR>
          <%
          }
        }
      }else{%>
        <TR>
          <TD class="inputField">
            <emxUtil:i18n localize="i18nId">emxFramework.AdvancedHelp.NoConversionsRun</emxUtil:i18n>
          </TD>
        </TR>
      <%}%>
      </TABLE><BR/>
      <%}%> 
    </FORM>
  </BODY>
</HTML>

