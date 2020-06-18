<%@include file = "emxNavigatorInclude.inc"%>
<%@ page import="java.io.BufferedReader"%>
<%@ page import="java.io.File"%>
<%@ page import="java.io.FileReader"%>


<%

// /etc/aboutpod.txt file contains 2 lines; 
// BuildTransactionID=R216-eu1-20140325T194500Z
// DeployID=eu1-r216132-2014x.D4.R216relBSF201403252045
 String[] infos ; 
 String deployid = "";      
 String buildid = "";
 String podtype = System.getenv("PodDefinitionName");
 
 if (null!=podtype && podtype.equals("EV6MT")) {
	File aboutfile = new File ("/etc/aboutpod.txt");
    if (aboutfile.exists()){
		try {                        
            BufferedReader br = new BufferedReader(new FileReader(aboutfile));      
            String strline;
            while ((strline = br.readLine()) != null) {
                          if (strline.startsWith("BuildTransactionID")) {
                                infos = strline.split("=");
              buildid = "Space-" + infos[1];				
                          } else if (strline.startsWith("DeployID")) {
								infos = strline.split("=");
								deployid = infos[1];
                          }
            }
            } catch (Exception ex) {
               //do nothing
            }
        }
		
}
%>
<html>
	<head>
		<meta charset="ISO-8859-1">
		<link rel="stylesheet" type="text/css" href="styles/emxUIDefault.css"/>
		<title><emxUtil:i18n localize="i18nId">emxFramework.About.3DEXPERIENCEPlatformTitle</emxUtil:i18n></title>
	</head>
	<body class="about">
		<h1><emxUtil:i18n localize="i18nId">emxFramework.About.3DEXPERIENCEPlatformTitle</emxUtil:i18n></h1>
		<!-- //XSSOK-->
        <p class="copyright"><emxUtil:i18n localize="i18nId">emxFramework.About.3DEXPERIENCEPlatform</emxUtil:i18n><br/><%=buildid%><br/><%=deployid%></p>
	
	</body>
</html>
