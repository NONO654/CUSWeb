<%--  emxPackagesConfigurationCreateDeploymentExtension.jsp  --  Create a Deployement extension object
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreateDeploymentExtension.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuCustoDictionary"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuType"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%
String packageId = emxGetParameter(request, "objectId");
String extensionName = emxGetParameter(request, "deployExtName");
String scope = emxGetParameter(request, "deployTypesOID");
String isStatic = emxGetParameter(request, "staticAssociation");
String ExtComment = emxGetParameter(request, "userComment");
//String parentfieldValueOID = emxGetParameter(request, "parentfieldValueOID");

/*System.out.println("GMX - CreateDeploymentExtension - hashMap");
Enumeration eNumParameters = emxGetParameterNames(request);
String parmValue = "";
String tableRowIds[] = null;
while( eNumParameters.hasMoreElements())
{
	String parmName  = (String)eNumParameters.nextElement();
	System.out.println("param  : " + parmName + " - value : " + emxGetParameter(request, parmName));
}
System.out.println("GMX - CreateDeploymentExtension - hashMap");*/

String nlsTrue = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanTrue");
String nlsFalse = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanFalse");

boolean extStaticAssociation = false; 
if(isStatic!=null && !isStatic.isEmpty())
	extStaticAssociation = nlsTrue.equals(isStatic) ? true : false;

if ((null != extensionName) && !extensionName.isEmpty() && (null != scope) && !scope.isEmpty() && (null != packageId) && !packageId.isEmpty())
{
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			IDAuPackage deploymentPackage = manager.getPackageFromId(context, packageId);
			//System.out.println("YI3 - CreateExtension - packageName : " + deploymentPackage.getName(context));
			
			//ArrayList<IDAuPackage> deploymentPackages = manager.getDeploymentPackages(context);
			//if ((null != deploymentPackages) && (1 == deploymentPackages.size()))
				//deploymentPackage = deploymentPackages.get(0);
			//if (null == deploymentPackage)
				//deploymentPackage = manager.createDeploymentPackage(context, "???", "DeploymentPackage", "Package for deployment Extensions");
			if (null != deploymentPackage)
			{
	     
				ArrayList<IDAuType> extendedTypes = new ArrayList<IDAuType>();
				StringTokenizer strTokenizer = new StringTokenizer(scope, "|");
				while (strTokenizer.hasMoreTokens())
				{
					String typeId = strTokenizer.nextToken();
					if ((null != typeId) && !typeId.isEmpty())
					{
						DAuData data = manager.getTypeOrExtensionFromId(context, typeId);
						if (null != data)
						{
							IDAuType type_i = data.IDAUTYPE;
							if (type_i == null)
								type_i = data.IDAUINSTANCE;
							if (null != type_i)
								extendedTypes.add(type_i);
						}
					}
				}
				
				if ((null != extendedTypes) && (extendedTypes.size() > 0))
				{
					IDAuExtension newExtension = deploymentPackage.createDeploymentExtension(context, extensionName, extendedTypes,extStaticAssociation,ExtComment);
					newExtension.setStaticAssociation(context,extStaticAssociation,false);
					if (null != newExtension)
					{
						%>
						<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
						<%
					}
					else
					{
						%>
						<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
						<%
					}
				}
			}
			else
			{
				%>
				<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
				<%
			}
		}
		catch (Exception e)
		{
			session.putValue("error.message", e.getMessage());
			%>
			<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
			<%
		}
	}
}
%>
