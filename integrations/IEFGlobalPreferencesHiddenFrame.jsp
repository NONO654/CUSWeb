<%--  IEFGlobalPreferencesHiddenFrame.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>


<%@page import = "com.matrixone.MCADIntegration.server.cache.*" %>



<%
	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context = integSessionData.getClonedContext(session);

	String gcoName		   = emxGetParameter(request, "gcoName");	
	String attrNameValList = emxGetParameter(request, "attrNameValList");
	
	String statusMsg = "";

	if(attrNameValList != null && !attrNameValList.equals(""))
	{	
%>
		<%@include file = "../common/enoviaCSRFTokenValidation.inc"%>
<%
	//	System.out.println("Validation::IEFGLobalPereferenceHiddenFrame");
		try
		{
				AttributeList attributeList = new AttributeList();

				StringTokenizer tokens = new StringTokenizer(attrNameValList, ";");
				while(tokens.hasMoreTokens())
				{
					String attrNameValStr = tokens.nextToken();					
				
					int index = attrNameValStr.indexOf("|");
					String attrName		= attrNameValStr.substring(0, index);
					String attrValue	= attrNameValStr.substring(index + 1);
									
 					String defaultFolderAttrType = "";
					String defaultFolderValue = "";
					String defaultFolderType = "";
					String defaultFolderName = "";
					String defaultFolderRev  = "";
					String defaultFolderTNR = "";
					
					if(attrName!= null && attrName.equalsIgnoreCase("IEF-Pref-IEF-DefaultFolder"))
					{
						StringTokenizer st = new  StringTokenizer(attrValue,")");
						while(st.countTokens()>1)
						{
							String defaultFolderAttrType1 = (String)st.nextToken();
							defaultFolderValue = (String)st.nextToken();
							defaultFolderAttrType = defaultFolderAttrType1 + ")";
							
							
							StringTokenizer checkValue = new  StringTokenizer(defaultFolderValue,",");
							if(checkValue.countTokens()!= 3)
							{
								if(defaultFolderValue!= null && defaultFolderValue!= "")
								{ 

									if(defaultFolderValue.startsWith("p_"))
										defaultFolderValue = defaultFolderValue.substring(2);
											
									BusinessObject folderObj = new BusinessObject(defaultFolderValue);
									folderObj.open(context);
									defaultFolderType = folderObj.getTypeName();
									defaultFolderName = folderObj.getName();
									defaultFolderRev = folderObj.getRevision();
									folderObj.close(context);
									defaultFolderTNR = defaultFolderType + "," + defaultFolderName + "," + defaultFolderRev;
								}
						
							String args = defaultFolderAttrType + defaultFolderTNR;
							attrValue = args;
							}
						}
					}		  
			  
					AttributeType attributeType = new AttributeType(attrName);
					Attribute attribute = new Attribute(attributeType, attrValue);
					attributeList.addElement(attribute);
				
				
				MCADMxUtil util	= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());

				String globalConfigObjectID			= util.getGlobalConfigObjectID(context, "MCADInteg-GlobalConfig", gcoName);
				BusinessObject globalConfigObject	= new BusinessObject(globalConfigObjectID);

				globalConfigObject.open(context);
				globalConfigObject.setAttributeValues(context, attributeList);
				globalConfigObject.close(context);
				
				statusMsg = "true|";
			}
			
				IEFCache iefCacheObj = integSessionData.getGlobalCache();
				iefCacheObj.clearCache(context, IEFCache.CACHETYPE_USERGCO_DEFINITION);
				iefCacheObj.clearCache(context, IEFCache.CACHETYPE_USER_FULLGCO_DEFINITION);
			
			}
		catch(Exception e)
		{
			System.out.println("ERROR : " + e.getMessage());
			statusMsg =  "false|" + e.getMessage();
		}
	}
%>
<html>
<body>
	<script language="javascript">
	//XSSOK
		var statusMsg = "<%= statusMsg %>";
		if(statusMsg != "")
		{
			parent.done(statusMsg);
		}
	</script>
</body>
</html
