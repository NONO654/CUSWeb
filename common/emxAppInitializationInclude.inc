<%--  emxAppInitializationInclude.jsp
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,
   Inc.  Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

   static const char RCSID[] = $Id: emxAppInitializationInclude.inc.rca 1.14 Wed Oct 22 15:48:15 2008 przemek Experimental przemek $
--%>

<%@page import="java.util.Iterator"%>
<%@page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%

    HashMap directorySuiteMap = new HashMap();
    
    // Load the common initialization file
    String commonInitializationFile = EnoviaResourceBundle.getProperty(context, "eServiceSuiteFramework.InitializationFile");

     if (commonInitializationFile != null && commonInitializationFile.length() > 0 )
     {
%>
        <jsp:include page = "<%=commonInitializationFile%>" flush="true" />
<%
     }
     directorySuiteMap = CacheManager.getDirSuiteMap(context,application);
     Iterator it = directorySuiteMap.entrySet().iterator();
     while(it.hasNext()){
    	Map.Entry entry = (Map.Entry)it.next();
		String suiteDirectory = (String)entry.getKey();
		String suiteKey = (String)entry.getValue();
        String suiteInitializationKey = suiteKey + ".InitializationFile";
        String suiteInitializationFile = "";
                     try{
                            suiteInitializationFile = EnoviaResourceBundle.getProperty(context, suiteInitializationKey);
                        }catch(Exception e){
                             suiteInitializationFile = null;
                        }
                     if (suiteInitializationFile != null && suiteInitializationFile.length() > 0 )
                      {
                            StringBuffer suiteInitializationFileBuffer = new StringBuffer(48);
                            suiteInitializationFileBuffer.append("../");
                            suiteInitializationFileBuffer.append(suiteDirectory);
                            suiteInitializationFileBuffer.append("/");
                            suiteInitializationFileBuffer.append(suiteInitializationFile);
%>
                            <!-- //XSSOK -->
                            <jsp:include page = "<%=suiteInitializationFileBuffer.toString()%>" flush="true" />
<%
                      }
             }
     // Get the initailization file name from the key "suiteInitializationKey"
%>
