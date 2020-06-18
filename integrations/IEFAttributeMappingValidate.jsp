<%@ include file="MCADTopInclude.inc" %>
<%@ include file="MCADTopErrorInclude.inc" %>
<%@ page import="com.matrixone.apps.domain.util.*" %>
<%
	//clear the output buffer
	out.clear(); 
	response.setContentType("text/plain; charset=UTF-8");

	String statusMessage		= "true";
	String isBusMapping		=Request.getParameter(request,"isBusMapping");
	String integrationName		=Request.getParameter(request,"integrationName");

	String fromType			=Request.getParameter(request,"fromType");
	String fromAttribute		=Request.getParameter(request,"fromAttribute");
	String toType			=Request.getParameter(request,"toType");
	String toAttribute		=Request.getParameter(request,"toAttribute");

	MCADIntegrationSessionData integSessionData = (MCADIntegrationSessionData) session.getAttribute("MCADIntegrationSessionDataObject");	
	Context context                             = integSessionData.getClonedContext(session);
	boolean bEnableAppletFreeUI = MCADMxUtil.IsAppletFreeUI(context);   
if(bEnableAppletFreeUI == true)
{
	statusMessage					= com.matrixone.MCADIntegration.server.beans.util.IEFPreferenceValidator.validate(context,statusMessage,isBusMapping,integrationName , fromType , fromAttribute, toType,toAttribute , integSessionData );
}
else
{
	MCADGlobalConfigObject gco					= integSessionData.getGlobalConfigObject(integrationName,context);

	MCADMxUtil util								= new MCADMxUtil(context, integSessionData.getLogger(), integSessionData.getResourceBundle(), integSessionData.getGlobalCache());
	MCADServerGeneralUtil serverGeneralUtil		= new MCADServerGeneralUtil(context, integSessionData, integrationName);
	
	if(isBusMapping.equalsIgnoreCase("true"))
	{
		Vector mappedTypes					 = gco.getAllMappedTypes();

		if(mappedTypes.contains(fromType) || !gco.getCorrespondingType(fromType).equals(""))
		{
			if((serverGeneralUtil.doesAttributeExistsOnType(context, fromType, fromAttribute)) || serverGeneralUtil.doesRACEAttrExistOnInterface(context, fromType, fromAttribute) || fromAttribute.equalsIgnoreCase("$$Description$$") || fromAttribute.equalsIgnoreCase("$$Owner$$"))
			{
				String partType = util.getActualNameForAEFData(context,"type_Part");

				String Args[]= new String[2];
				Args[0]= toType;
				Args[1]="kindof";
				if(util.executeMQL(context, "print type $1 select $2 dump",Args).startsWith("true|" + partType ))
				{
					String strInterfaceAttr = MqlUtil.mqlCommand(context,"print interface $1 select $2 dump $3", "XP_Part_Ext","attribute", "|");
					String tempToAttribute = StringUtil.split(toAttribute, ".").size() > 1 ? (String) StringUtil.split(toAttribute, ".").get(1) : toAttribute;
					if((!serverGeneralUtil.doesAttributeExistsOnType(context, toType, toAttribute)) && !StringUtil.split(strInterfaceAttr, "|").contains(tempToAttribute) && !toAttribute.equalsIgnoreCase("$$Description$$") && !toAttribute.equalsIgnoreCase("$$Owner$$"))
					{
						Hashtable messageDetails = new Hashtable(2);
                        messageDetails.put("TYPE", toType);
                        messageDetails.put("ATTRNAME", toAttribute);
                                
                        statusMessage = "false|" + integSessionData.getStringResource("mcadIntegration.Server.Message.AttributeDoesNotExistsOnType", messageDetails);
					}
				}
				else
				{
					Hashtable messageDetails = new Hashtable(2);
					messageDetails.put("TYPE", toType);
                                
					statusMessage = "false|" + integSessionData.getStringResource("mcadIntegration.Server.Message.PartTypeisInvalid", messageDetails);
				}
			}
			else
			{
				Hashtable messageDetails = new Hashtable(2);
                messageDetails.put("TYPE", fromType);
                messageDetails.put("ATTRNAME", fromAttribute);
                                
                statusMessage = "false|" + integSessionData.getStringResource("mcadIntegration.Server.Message.AttributeDoesNotExistsOnType", messageDetails);
			}
		}
		else
		{
			Hashtable messageDetails = new Hashtable(2);
            messageDetails.put("TYPE", fromType);
                                
            statusMessage = "false|" + integSessionData.getStringResource("mcadIntegration.Server.Message.TypeInvalidForIntegration", messageDetails);
		}
	
	}
	else
	{
		Hashtable relsAndEnds =  gco.getRelationshipsOfClass(MCADAppletServletProtocol.ASSEMBLY_LIKE);
		
		if(relsAndEnds.containsKey(fromType))
		{
			if(util.getAllAttributeNamesOnRelationship(context, fromType).contains(fromAttribute))
			{

				String Args[]= new String[2];
				Args[0]= toType;
				Args[1] = "name";
				if(util.executeMQL(context, "print relationship $1 select $2 dump",Args).startsWith("true|"))
				{
					if(!util.getAllAttributeNamesOnRelationship(context, toType).contains(toAttribute))
					{
							Hashtable messageDetails = new Hashtable(2);
							messageDetails.put("TYPE", toType);
			                messageDetails.put("ATTRNAME", toAttribute);
                                
							statusMessage = "false|" + integSessionData.getStringResource("mcadIntegration.Server.Message.AttributeDoesNotExistsOnRelType", messageDetails);
					}
				}
				else
				{
					Hashtable messageDetails = new Hashtable(2);
					messageDetails.put("TYPE", toType);
					statusMessage = "false|" + integSessionData.getStringResource("mcadIntegration.Server.Message.RelationshipDoesNotExists", messageDetails);
				}
			}
			else
			{
				Hashtable messageDetails = new Hashtable(2);
                messageDetails.put("TYPE", fromType);
                messageDetails.put("ATTRNAME", fromAttribute);
                                
                statusMessage = "false|" + integSessionData.getStringResource("mcadIntegration.Server.Message.AttributeDoesNotExistsOnRelType", messageDetails);
			}
		}
		else
		{
			Hashtable messageDetails = new Hashtable(2);
			messageDetails.put("NAME", fromType);
			statusMessage = "false|" + integSessionData.getStringResource("mcadIntegration.Server.Message.RelIsNotValidForEBOM", messageDetails);
		}
	
	}
}
	out.write(statusMessage);
%>
