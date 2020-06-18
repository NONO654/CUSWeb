<%--  IEFAttributeTransferUpdate.jsp

   Copyright (c) 2016 Dassault Systemes. All rights reserved.
   This program contains proprietary and trade secret information of
   Dassault Systemes and its subsidiaries. Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

--%>
<%@ include file ="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>

<%	
	MCADIntegrationSessionData integSessionData  = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	Context context								 = integSessionData.getClonedContext(session);
    
	//String form				 =Request.getParameter(request,"subForm");
	String textData          =Request.getParameter(request,"tableData");
	String prefName			 =Request.getParameter(request,"prefAttrName");	
	String objectID			 =Request.getParameter(request,"objectId");
	String integrationName	 =Request.getParameter(request,"integrationName");
	String result            = "";		
	String integName		 = "";
	String tempData			 = "";
	String tempAttrValue	 = "";
	String prefAttrElement	 = "";
	String prefValue		 = "";
	
	Hashtable prefAttrElementMap = new Hashtable();
	
	int len = textData.length();
	//Removing last @ from String....
	if(len > 0 )
	{
		textData = textData.substring(0,len-1);
	}
	
	BusinessObject busObj = new BusinessObject(objectID);
	
	busObj.open(context);
	
	Attribute prefAttribute	= busObj.getAttributeValues(context, prefName);
	String prefAttrValue = prefAttribute.getValue();

	if(prefAttrValue!=null && !prefAttrValue.trim().equals(""))
	{
		StringTokenizer prefAttrValueToken		= new StringTokenizer(prefAttrValue, "\n");
		while(prefAttrValueToken.hasMoreElements())
		{
			prefAttrElement = (String)prefAttrValueToken.nextElement();
			
			int firstIndex = prefAttrElement.indexOf("|");
			integName =	prefAttrElement.substring(0,firstIndex);
			prefValue =  prefAttrElement.substring(firstIndex+1,prefAttrElement.length());
			prefAttrElementMap.put(integName, prefValue);
		}
			
			Enumeration d = prefAttrElementMap.keys();
			while(d.hasMoreElements())
			{
				integName = (String)d.nextElement();
				if (integName.equals(integrationName))
					{
						tempAttrValue =  textData;
						prefAttrElementMap.put(integName, tempAttrValue);
					}
			}
	}
	else
	{	
		tempAttrValue = integrationName +"|"+ textData;
		
	}
	tempAttrValue = "";
	Enumeration e = prefAttrElementMap.keys();
	while(e.hasMoreElements())
	{
		integName = (String)e.nextElement();
		prefValue = (String)prefAttrElementMap.get(integName);
		
		tempAttrValue += integName+ "|" +prefValue+ "\n";
	}
	
	if(tempAttrValue.length() > 0)
	{
		tempAttrValue = tempAttrValue.substring(0, tempAttrValue.length() - 1);
	}
	
	busObj.setAttributeValue(context, prefName, tempAttrValue);
	
	busObj.close(context);
%>

