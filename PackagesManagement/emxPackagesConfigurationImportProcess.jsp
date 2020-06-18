<%--  emxPackagesConfigurationImportProcess.jsp - Import files 
  Copyright (c) 2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  by MFL 2011/09/29
--%>
<%@ page import="java.io.*" %>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<%@page import = "com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<%        
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager) {
		try {
		    //IR-219705: on WAS application server, the charachterEncoding is not present in the request
			//String charsetName = request.getCharacterEncoding();
			String charsetName = Framework.getCharacterEncoding(request);
			String contentType = request.getContentType();
			System.out.println("MFL - ContentType = " + contentType);
			InputStream inputStream = request.getInputStream();
			int inputLength	= request.getContentLength();
			boolean bSaveOnTmpDir = true;
			String resMsg = manager.importFiles(context,charsetName,contentType,inputStream,inputLength,bSaveOnTmpDir);

			// Update the current user roles in session variable
			UICache.loadUserRoles(context, session);		        
    
			// reset the cache in the remote APP servers (incl. RMI gateway), if configured
			StringList errAppSeverList = CacheManager.resetRemoteAPPServerCache(context, pageContext);     
    
			// reset the cache in RMI servers specified in the emxReloadCacheServerInfo JPO
			CacheManager.resetRMIServerCache(context);    	
    
			StringBuffer sCacheResetMsg = new StringBuffer();
			if(errAppSeverList != null && errAppSeverList.size() > 0)    
			{
				// JPI sCacheResetMsg.append(getI18NString("emxFrameworkStringResource","emxNavigator.UIMenu.ResetRemoteCacheFailedMessage", request.getHeader("Accept-Language")));
				//sCacheResetMsg.append("Reset Cache Failed");
				String CacheRestFailMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.UIMenu.ResetRemoteCacheFailedMessage");
				sCacheResetMsg.append(CacheRestFailMsg);
				for(int i=0; i < errAppSeverList.size(); i++)
				{
					if(i > 0)
					{
						sCacheResetMsg.append(",");   
					}
            
					sCacheResetMsg.append(" ");
					sCacheResetMsg.append(errAppSeverList.get(i));
				}              
			}
			else
			{
				String CacheRestMsg = EnoviaResourceBundle.getProperty(context, "emxFrameworkStringResource", context.getLocale(), "emxFramework.UIMenu.ResetCacheMessage");
				sCacheResetMsg.append(CacheRestMsg);
				HashMap lookup = null;
				//If the lookup table is not there, create and populate it.
				if (lookup == null) {
					try {
					MQLCommand getSchemaNames = new MQLCommand();
					getSchemaNames.executeCommand(
						context,
						"execute program 'eServiceListSchemaNames.tcl'");
					StringTokenizer parser =
						new StringTokenizer(getSchemaNames.getResult(), "|");
					lookup = new HashMap();
					boolean isValue = true;
					String key = null;
					String value = null;
					while (parser.hasMoreTokens()) {
						if (isValue) {
							value = parser.nextToken();
							isValue = false;
						} else {
							key = parser.nextToken();
							if (value != null && value.startsWith("type_")) {
								lookup.put(key, value);
							}
							isValue = true;
						}
					}
					application.setAttribute("TypeLookup", lookup);
				} catch (Exception e) {
					System.out.println("Exception caught " + e.toString());
					return;
					}
				}
			}
			emxNavErrorObject.addMessage(resMsg);			
			%>			
			<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>		
			<%
		}
		catch (Exception e) {
			session.putValue("error.message", e.getMessage());
			%>
			<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
			<%
		}
	}
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%-- Reload the page --%>
<script language="javascript" type="text/javaScript">
top.closeSlideInDialog(); 
top.content.location.href = top.content.location.href; 
//parent.window.close();
</script>
