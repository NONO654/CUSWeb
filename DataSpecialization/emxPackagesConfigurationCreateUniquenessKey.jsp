<%--  emxPackagesConfigurationCreateUniquenessKey.jsp  --  Creating Package object
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreateUniquenessKey.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuCustoDictionary"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuType"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuAttribute"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuUniquenessKey"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%
String packageId = emxGetParameter(request, "objectId");
String keyName = emxGetParameter(request, "ukName");
String keyType = emxGetParameter(request, "ukTypeOID");
String keyExtension = emxGetParameter(request, "ukExtension");
if ((null != keyName) && !keyName.isEmpty() && (null != keyType) && !keyType.isEmpty())
{
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
			DAuData data = manager.getTypeOrExtensionFromId(context, keyType);
			if (null != data)
			{
				IDAuType type = data.IDAUTYPE;
				if(type == null){
					type = data.IDAUINSTANCE;
				}
				IDAuPackage deploymentPackage = null;
				deploymentPackage = manager.getPackageFromId(context, packageId);
				if (null != type)
				{
					ArrayList<IDAuAttribute> attributes = new ArrayList<IDAuAttribute> (); //No_attributes: type.getAttributes(context);
					IDAuExtension extension = null;
					if ((null != keyExtension) && !keyExtension.isEmpty())
					{
						
					    
							if (null != deploymentPackage)
							{ 

								ArrayList<IDAuExtension> extensions = deploymentPackage.getExtensions(context);
								if (null != extensions)
								{
									Iterator<IDAuExtension> itr = extensions.iterator();
									if (null != itr)
									{
										boolean found = false;
										while (itr.hasNext() && !found)
										{
											IDAuExtension ext_i = itr.next();
											if (null != ext_i)
											{
												String name = ext_i.getName(context);
												if ((null != name) && !name.isEmpty() && name.equals(keyExtension))
												{
													found = true;
													extension = ext_i;
												}
											}
										}
										//No_attributes: attributes.addAll(extension.getAttributes(context));
									}
								}
							}
						//}
					}
					IDAuUniquenessKey key = type.createUniquenessKey(context, keyName, extension, attributes,deploymentPackage,true,false);
					if (null != key)
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
