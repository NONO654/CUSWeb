<%--
    DSCDownloadStructureAppletFree.jsp

    Copyright (c) 2019 Dassault Systemes.
    All Rights Reserved  This program contains proprietary and trade secret
    information of MatrixOne, Inc.
    Copyright notice is precautionary only and does not evidence any
    actual or intended publication of such program

--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@ page import="com.matrixone.MCADIntegration.server.MCADServerResourceBundle" %>
<%@ page import="com.matrixone.MCADIntegration.utils.*" %>
<%@ page import="com.matrixone.MCADIntegration.server.beans.*" %>
<%@ page import="com.matrixone.MCADIntegration.server.MCADServerException" %>
<%@ page import="com.matrixone.MCADIntegration.server.MCADServerLogger" %>
<%@ page import="com.matrixone.MCADIntegration.utils.xml.IEFXmlNode" %>
<%@ page import="matrix.db.JPO" %>
<%@ page import="java.util.*" %>
<%@ page import="matrix.db.Context" %>
<%@ page import="matrix.db.BusinessObject" %>
<%

	String contextObjectId = (String)emxGetParameter(request, "objectId");
	String contextObjectAction = (String)emxGetParameter(request, "action");
	
	MCADIntegrationSessionData integSessionData	= (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");
	String languageStr								= request.getHeader("Accept-Language");
	MCADServerResourceBundle serverResourceBundle	= new MCADServerResourceBundle(languageStr);
	MCADMxUtil mcadMxUtil				= new MCADMxUtil(context, serverResourceBundle, integSessionData.getGlobalCache());
	String integrationName	= mcadMxUtil.getIntegrationName(context, contextObjectId);
	MCADGlobalConfigObject globalConfigObject              = integSessionData.getGlobalConfigObject(integrationName,context);
	MCADLocalConfigObject localConfigObject     = integSessionData.getLocalConfigObject();
	
	MCADServerGeneralUtil serverGeneralUtil			= new MCADServerGeneralUtil(context, integSessionData, integrationName);
	MCADServerLogger logger								= null;
	logger				= integSessionData.getLogger();
	boolean isDebugOn									= false;
	isDebugOn			= localConfigObject.isTurnDebugOn(); 
	if(null != logger)
			isDebugOn			= true; 
	try
	{
		 //IR-670955 : Start of code to get object Ids by expanding structure
		 //we added flag as, isExpandFromDEC and isRequiredPath in URL parameter to execute this code.
		//Fetched object ids after expansion are put in session.
		String oidList[] = null;
		oidList = expand(context,contextObjectId,mcadMxUtil,globalConfigObject,localConfigObject,integrationName,serverResourceBundle,integSessionData,serverGeneralUtil,logger,isDebugOn);
		session.setAttribute("strExpandedobjectIds", oidList);

			if(isDebugOn && (null != logger))
				logger.logDebug("[DSCDownloadStructureAppletFree]oidList already expanded..."+Arrays.toString(oidList));
		
		String site = new String(" ../components/emxCommonDocumentPreCheckout.jsp?action=download&objectId="+contextObjectId+"&isExpandFromDEC=" + "true"+"&isRequiredPath=" + "false");
		response.setStatus(response.SC_MOVED_TEMPORARILY);
		response.setHeader("Location", site);
	}
	catch(Exception e)
			{
				e.printStackTrace();
				
			}
%>
<%!
private String[] expand(Context context,String TopID,MCADMxUtil mcadMxUtil,MCADGlobalConfigObject globalConfigObject,MCADLocalConfigObject localConfigObject,String integrationName,MCADServerResourceBundle serverResourceBundle,MCADIntegrationSessionData integSessionData,MCADServerGeneralUtil serverGeneralUtil,MCADServerLogger logger,boolean isDebugOn) throws Exception 
	{ 
		BusinessObject rootBusObject = new BusinessObject(TopID);
		String cadType = mcadMxUtil.getCADTypeForBO(context, rootBusObject);
		
		String instanceId = TopID;
		if(globalConfigObject.isTypeOfClass(cadType, MCADAppletServletProtocol.TYPE_FAMILY_LIKE))
				instanceId = serverGeneralUtil.getInstanceIdFromFamilyIdForNavigation(context,TopID); 
				
		String jpoName		= "DSCProductStructureEditor";
		String jpoMethod	= "getExpandedBusObjects";
		String[] init		= new String[] {};
		
		HashMap jpoArgs	= new HashMap();
		
		jpoArgs.put("LocaleLanguage", serverResourceBundle.getLanguageName());
		jpoArgs.put("objectId",instanceId);
		jpoArgs.put("expandLevel", "All");
		jpoArgs.put("GCO", globalConfigObject);	
		
		MapList ExpandOutput = (MapList)JPO.invoke(context, jpoName, init, jpoMethod, JPO.packArgs(jpoArgs), MapList.class);
		ListIterator litr = null;
		litr=ExpandOutput.listIterator();
		
		HashMap expandedHashMap = new HashMap();
		
		ArrayList oidListfromJPO = new ArrayList();
		Hashtable busIdAlreadyExpandedNodeDetails = new Hashtable();
		
		oidListfromJPO.add(instanceId);
		busIdAlreadyExpandedNodeDetails.put(instanceId, new HashSet(Arrays.asList(instanceId)));
		int i =1;
		while(litr.hasNext())
		{
			expandedHashMap.clear();
			expandedHashMap = (HashMap)litr.next();
			if(expandedHashMap.containsKey("id"))
			{
				if(!oidListfromJPO.contains((String)expandedHashMap.get("id")))
				{ 
						
				oidListfromJPO.add((String)expandedHashMap.get("id"));
				busIdAlreadyExpandedNodeDetails.put((String)expandedHashMap.get("id"), new HashSet(oidListfromJPO));
				
				}
			}
		}
		
		HashSet returnTable     =getRelatedDrawingIDs(context,instanceId,mcadMxUtil,globalConfigObject,localConfigObject,busIdAlreadyExpandedNodeDetails,integrationName,serverResourceBundle,integSessionData,logger,isDebugOn);
		
		
		String typeClassMapping = globalConfigObject.TypeClassMapToString();
		
		if(isDebugOn && (null != logger))
		{
				logger.logDebug("[DSCDownloadStructureAppletFree.expand]oidListfromJPO already expanded..."+oidListfromJPO);
				logger.logDebug("[DSCDownloadStructureAppletFree.expand]returnTable already expanded drawing Ids..."+returnTable);
				logger.logDebug("[DSCDownloadStructureAppletFree.expand]typeClassMapping..."+typeClassMapping);
		}
		
		if(typeClassMapping.contains("TYPE_INSTANCE_LIKE") || typeClassMapping.contains("TYPE_FAMILY_LIKE"))
		{
		
		Iterator<String> iter = oidListfromJPO.iterator(); 
		
		while(iter.hasNext())
		{
			String objId= (String)iter.next();
			
			if(null != objId)
			{
				BusinessObject busObject = new BusinessObject(objId);
					String busCadType = mcadMxUtil.getCADTypeForBO(context, busObject);
				if(globalConfigObject.isTypeOfClass(busCadType, MCADAppletServletProtocol.TYPE_INSTANCE_LIKE))
				{
					String		familyID 	= serverGeneralUtil.getTopLevelFamilyObjectForInstance(context,objId);
					if(!oidListfromJPO.contains(familyID))
					{
						int index = oidListfromJPO.indexOf(objId);
						oidListfromJPO.set(index,familyID);
					}
					else
					{
						iter.remove(); 
					}
				}
			}
			
		}
		}
		if(null !=returnTable && !returnTable.isEmpty())
			oidListfromJPO.addAll(returnTable);
		
		String[] oids = new String[oidListfromJPO.size()];
		oidListfromJPO.toArray(oids);
	
		if(isDebugOn && (null != logger))
				logger.logDebug("[DSCDownloadStructureAppletFree.expand]oids already expanded..."+Arrays.toString(oids));
			
		return oids;
}
	
private HashSet getRelatedDrawingIDs(Context context,String busId1,MCADMxUtil mcadMxUtil,MCADGlobalConfigObject globalConfigObject,MCADLocalConfigObject localConfigObject,Hashtable busIdAlreadyExpandedNodeDetails,String integrationName,MCADServerResourceBundle serverResourceBundle,MCADIntegrationSessionData integSessionData,MCADServerLogger logger,boolean isDebugOn) throws Exception 
{
		Hashtable resultTable  			 = new Hashtable(busIdAlreadyExpandedNodeDetails.size());
		Hashtable requestTable 			 = new Hashtable(busIdAlreadyExpandedNodeDetails.size());
		Hashtable busIDVerticalViewDetailsCache   	= new Hashtable();
		Hashtable verticalNavigationProgNameMapping 	= null;
		
		String verticalViewName	= "";
		
		if(localConfigObject!=null)
		{
			verticalViewName = localConfigObject.getDefaultVerticalView(integrationName);
		}
		else
		{
			String defaultVerticalViewAttrName	= mcadMxUtil.getActualNameForAEFData(context, "attribute_IEF-Pref-IEF-DefaultVerticalView");
			verticalViewName	= globalConfigObject.getPreferenceValue(defaultVerticalViewAttrName);
		}
		
		if(verticalViewName.equals(MCADAppletServletProtocol.VIEW_NONE))
		return null;

		if(localConfigObject != null)
    	{
    		String checkoutViewRegistryName 		 = localConfigObject.getViewRegistryName(integrationName);
    		verticalNavigationProgNameMapping   = mcadMxUtil.readVerticalNavigationProgNameMapping(context, checkoutViewRegistryName);
    		
    	}
    	else
    	{
    		String viewRegistryAttrName	= mcadMxUtil.getActualNameForAEFData(context, "attribute_IEF-Pref-MCADInteg-ViewRegistryName");
    		String viewRegistryName 	= globalConfigObject.getPreferenceValue(viewRegistryAttrName);
    		verticalNavigationProgNameMapping   = mcadMxUtil.readVerticalNavigationProgNameMapping(context, viewRegistryName);
    	}
		
		Vector verticalViewProgDetails   = (Vector)verticalNavigationProgNameMapping.get(verticalViewName);
		String viewProgram               = (String)verticalViewProgDetails.elementAt(0);
		
		if(isDebugOn && (null != logger))
		{
				logger.logDebug("[DSCDownloadStructureAppletFree.getRelatedDrawingIDs]verticalViewName..."+verticalViewName);
				logger.logDebug("[DSCDownloadStructureAppletFree.getRelatedDrawingIDs]viewProgram..."+viewProgram);
		}
		
		Enumeration busids 				 = busIdAlreadyExpandedNodeDetails.keys();
        String busId =null;
        while(busids.hasMoreElements())
        {
				 busId = (String)busids.nextElement();
				 if(busIDVerticalViewDetailsCache.containsKey(busId))
				 {	
						resultTable.put(busId, busIDVerticalViewDetailsCache.get(busId));
				 }
				 else
				 {	
					requestTable.put(busId, busIdAlreadyExpandedNodeDetails.get(busId));
				 }
        }
		
		if(isDebugOn && (null != logger))
				logger.logDebug("[DSCDownloadStructureAppletFree.getRelatedDrawingIDs]requestTable..."+requestTable);
		
        if(requestTable.size() > 0)
        {
            try
            {
        		Hashtable argsTable = new Hashtable();
        		argsTable.put("GCO",globalConfigObject);
        		argsTable.put("language",serverResourceBundle.getLanguageName());
        	    String []initArgs = JPO.packArgs(argsTable);
        	    
            	Vector argsVector = new Vector(2);
            	argsVector.addElement(requestTable);
            	argsVector.addElement("true");
            	String []args = JPO.packArgs(argsVector);
                
                Hashtable jpoReturnTable   = (Hashtable)mcadMxUtil.executeJPO(context, viewProgram, initArgs, "getVerticalViewBOIDsForObjectIds", args, Hashtable.class);
               
                if(jpoReturnTable != null)
                {
                	busIDVerticalViewDetailsCache.putAll(jpoReturnTable);
                    resultTable.putAll(jpoReturnTable);
                }
            }
            catch(Exception exception) 
            {
            	String errorMessage = integSessionData.getStringResource("mcadIntegration.Server.Message.IEF0042200201");
    			MCADServerException.createManagedException("IEF0042200201", errorMessage, exception);
            }
        }
	   HashSet alreadyExpandedNodes				= new HashSet();
	   Enumeration busidsresult 				 = busIdAlreadyExpandedNodeDetails.keys();
	   while(busidsresult.hasMoreElements())
        {
            String busIdresult = (String)busidsresult.nextElement();
			if(resultTable.containsKey(busIdresult))
			{
			IEFXmlNode verticalViewDetails = (IEFXmlNode)resultTable.get(busIdresult);
			Enumeration viewNodes = verticalViewDetails.getChildrenByName("node");
			
			while (viewNodes.hasMoreElements())
			{
					IEFXmlNode viewNode = (IEFXmlNode)viewNodes.nextElement();
					String relID = (String) viewNode.getAttribute("relid");
					String relatedDocumentObjID = (String) viewNode.getAttribute("busid");
					if(isDebugOn && (null != logger))
					{
						logger.logDebug("[DSCDownloadStructureAppletFree.getRelatedDrawingIDs]relID..."+relID);
						logger.logDebug("[DSCDownloadStructureAppletFree.getRelatedDrawingIDs]relatedDocumentObjID..."+relatedDocumentObjID);
					}
					alreadyExpandedNodes.add(relatedDocumentObjID);
			}
			}
		}
		
		if(isDebugOn && (null != logger))
				logger.logDebug("[DSCDownloadStructureAppletFree.getRelatedDrawingIDs]alreadyExpandedNodes already expanded drawing Ids..."+alreadyExpandedNodes);
		
		return alreadyExpandedNodes;

}
%>
