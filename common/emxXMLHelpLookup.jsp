<%--  emxXMLHelpLookup.jsp

   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
--%>
<%@include file="emxNavigatorNoDocTypeInclude.inc"%>
<%
	String strLanguage = emxGetParameter(request, "language");
	String emxAEFSuiteDir = emxGetParameter(request, "suiteDir");
	String pageTopic = emxGetParameter(request, "pageTopic");
	String suiteKey = emxGetParameter(request, "suiteKey");

	if (suiteKey == null || "null".equals(suiteKey)
			|| "undefined".equalsIgnoreCase(suiteKey)) {
		suiteKey = FrameworkProperties.getSuiteKeyFromSuiteDir(emxAEFSuiteDir);
	}
	if (suiteKey == null || "null".equals(suiteKey)
			|| "undefined".equalsIgnoreCase(suiteKey)) {
		suiteKey = "Framework";
	}

	// eServiceSuite<SuiteKey>.HelpFile = emx<SuiteKey>OnlineHelp.properties
	// In the above key format, <SuiteKey> represents the suite key of application which is migrated to XML authored help. 
	// If this key is not found, it is assumed that the help is not migrated to new system and defaults to old (Pre V6R2012) helps

	if (suiteKey.startsWith("eServiceSuite")) {
		suiteKey = suiteKey.substring("eServiceSuite".length());
	}
	String helpPropertiesFile = "eServiceSuite" + suiteKey + ".HelpFile";
	String helpDirectory = "eServiceSuite" + suiteKey + ".Help.Directory";
	String strBundle = "";
	String strTitle = "";
	String strDirectory = "";

	//This try catch block verifies whether XML help is available by reading the emxSystem property
	try {
		strBundle = EnoviaResourceBundle.getProperty(context,
				helpPropertiesFile);
		strBundle = strBundle.substring(0, strBundle.indexOf(".properties"));

		//This try catch block verifies whether the specific help topic is present in the corresponding application specific help properties file.
		//If the help topic if found, print the corresponding help file name, otherwise, print the boolean string in catch block
		try {
			strDirectory = EnoviaResourceBundle.getProperty(context,
					helpDirectory);
			if (strDirectory == null || strDirectory.length() == 0) {
				StringList appList = PersonUtil.getLicenseProductsBySuiteKey(suiteKey);
				String parentApp = null;
				for(int i = 0; i < appList.size(); i++){
					String app = (String)appList.get(i);
					try {
						FrameworkLicenseUtil.checkLicenseReserved(context, app,"");
						parentApp = FrameworkLicenseUtil.getProductSuiteKey(context, app);
						break;
					} catch (Exception e) {
						//do nothing
					}
					
				}
				if (parentApp == null) {
					throw new Exception();
				} else {
					strDirectory = EnoviaResourceBundle.getProperty(context, "eServiceSuite" + parentApp + ".Help.Directory");
				}
			}
			strDirectory = strDirectory.concat("/");
			strTitle = EnoviaResourceBundle.getHelpProperty(context, strBundle, pageTopic);
			strTitle = strDirectory.concat(strTitle);
			response.setHeader("Content-Type",
					"text/plain; charset=UTF-8");
			response.setContentType("text/plain; charset=UTF-8");
			out.clear();
			out.print(strTitle);
		} catch (Exception e) {
			out.print("true");
		}
	} catch (Exception e) {
		out.clear();
		out.print("false");
	}
%>


