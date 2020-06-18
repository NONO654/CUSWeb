<%--  DSCAppletUtils.inc

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%--
  $Archive: DSCAppletUtils.inc $
  $Revision: 1.3.1.3$
  $Author: ds-mbalakrishnan$

--%>
<%@ page import="com.matrixone.apps.domain.util.*, com.matrixone.MCADIntegration.server.beans.*" %>
<%!
 public static String getDesignerCentralProperty(ServletContext servletcontext, 
	    HttpSession httpsession, String strGroup, String strKey)
    {
        String strPropFile = (String) servletcontext.getAttribute("eServiceSuiteDesignerCentral.PropertyFileAlias");
	    String strMatrixPropFile = "eMatrixProperties";
        String strPropertyValue = null;
        if(strPropFile == null || strPropFile.equals(""))
        {
            if(strMatrixPropFile == null || strMatrixPropFile.equals(""))
                return null;
            Properties properties = (Properties)servletcontext.getAttribute(strMatrixPropFile);
            if(properties == null)
                return null;
            strPropertyValue = properties.getProperty(strGroup + "." + strKey);
        } else
        {
            Properties properties1 = (Properties)servletcontext.getAttribute(strPropFile);
            if(properties1 == null)
                return null;
            String strCompleteKey = "";
            if(strGroup == null || strGroup.equals(""))
            {
                if(strKey == null || strKey.equals(""))
                    strCompleteKey = "";
                else
                    strCompleteKey = strKey;
            }
	    else if(strKey == null || strKey.equals(""))
                strCompleteKey = strGroup;
            else
                strCompleteKey = strGroup + "." + strKey;

            strPropertyValue = properties1.getProperty(strCompleteKey);
            if(strPropertyValue == null || strPropertyValue.equals(""))
            {
                if(strMatrixPropFile == null || strMatrixPropFile.equals(""))
                    return null;
                Properties properties2 = (Properties)servletcontext.getAttribute( strMatrixPropFile );
                if(properties2 == null)
                    return null;
                strPropertyValue = properties2.getProperty(strCompleteKey);
            }
        }
        if(strPropertyValue == null || strPropertyValue.equals(""))
            return null;
        else
            return strPropertyValue;
    }
%>

<%
   MCADIntegrationSessionData integrationSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");

   boolean appletLoaded = false;
   if (integrationSessionData == null)
   {
	  long elapsedTime = 0L;
	  long timeOutInterval = 10 * 1000L;
	  String sTimeOutInterval = getDesignerCentralProperty(application,
											  session,
											  "eServiceInfoCentral",
											  "AbortTimeOutInSecs");
	  if (sTimeOutInterval != null && sTimeOutInterval.length() > 0)
	  {
		   timeOutInterval = Long.parseLong(sTimeOutInterval) * 1000L;
	  }
	  while(false == appletLoaded && timeOutInterval > elapsedTime)
	  {
	     Thread.sleep(1000);
	     elapsedTime += 1000L;     
	     try
	     {
	         integrationSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	         if (integrationSessionData != null)
	         {
	            Context integContext = integrationSessionData.getClonedContext(session);
	            appletLoaded = true;
	            break;
	         } 
	     }
	     catch (Exception e)
	     {
	         // basically continue;
	         continue;
	     }
	  }	  
	  if (false == appletLoaded)
      {
              String targetPage = "/integrations/emxAppletTimeOutErrorPage.jsp"; 
	      
              // No encoding required for the variable 'targetpage' as it is internal variable
          %> 
				<jsp:forward page="<%=targetPage%>" />              
          <%
      }
   }

%>
