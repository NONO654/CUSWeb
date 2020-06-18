<%--  emxPackagesConfigurationCreateExtension.jsp  --  Creating Package object
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreateExtension.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuCustoDictionary"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuExtension"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuType"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuData"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>

<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<%
String packageId = emxGetParameter(request, "objectId");
String extensionName = emxGetParameter(request, "custoExtName");
String parentExtension = emxGetParameter(request, "parent");
String ExtComment = emxGetParameter(request, "userComment");
String ExtScopes = emxGetParameter(request, "extScopes");
String iconName = emxGetParameter(request, "iconName");
//if("null".equals(ExtScopes))
  // ExtScopes = emxGetParameter(request, "extScopesInfo");
String ExtScopesOID = emxGetParameter(request, "extScopesOID");  
String parentfieldValueOID = emxGetParameter(request, "parentfieldValueOID");
//System.out.println("GMX - CreateExtension - packageId : " + packageId);
//System.out.println("GMX - CreateExtension - extensionName : " + extensionName);
//System.out.println("GMX - CreateExtension - parentExtension : " + parentExtension);
//System.out.println("GMX - CreateExtension - parentfieldValueOID : " + parentfieldValueOID);
//System.out.println("YI3 - CreateExtension - Scopes : " + ExtScopes);
//System.out.println("YI3 - CreateExtension - ScopesOID : " + ExtScopesOID);


/*
System.out.println("YI3 - CreateExtension - hashMap");
Enumeration eNumParameters = emxGetParameterNames(request);
String parmValue = "";
String tableRowIds[] = null;
while( eNumParameters.hasMoreElements())
{
  String parmName  = (String)eNumParameters.nextElement();
  System.out.println("param  : " + parmName + " - value : " + emxGetParameter(request, parmName));
}
System.out.println("YI3 - CreateExtension - hashMap");*/

String sIsAbstract = emxGetParameter(request, "abstractOption");

String nlsTrue = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanTrue");
String nlsFalse = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.BooleanFalse");

boolean isAbstract = false; 
if(sIsAbstract!=null && !sIsAbstract.isEmpty())
  isAbstract = nlsTrue.equals(sIsAbstract) ? true : false;

IDAuManager manager = DAuManagerAccess.getDAuManager();
ArrayList<IDAuType> extendedTypes = new ArrayList<IDAuType>();
IDAuExtension newExtension = null;
IDAuPackage custoPackage = null;
boolean subExtensionCreation=false;
//create list of types in the scope
if(null != ExtScopes && !ExtScopes.isEmpty()){

StringTokenizer strTokenizer = new StringTokenizer(ExtScopesOID, "|");
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
      if (null != type_i){
        extendedTypes.add(type_i);
      }
    }
  }
}
}

if ((null != packageId) && !packageId.isEmpty() && (null != extensionName) && !extensionName.isEmpty() && (null != parentfieldValueOID) && !parentfieldValueOID.isEmpty())
{
	if (null != manager)
	{
		try
		{
			custoPackage = manager.getPackageFromId(context, parentfieldValueOID);
			if (null != custoPackage)
			{
				
				// si l'extension n'a pas de parent alors c'est une customer extension
				// si son parent n'est pas dans le package custo alors c'est une specialization extension
				// sinon il faut tester le type de l'extension parente
				if ((null != parentExtension) && !parentExtension.isEmpty())
				{
					subExtensionCreation=true;
					IDAuExtension parentExt = custoPackage.getExtension(context, parentExtension);
					if (null != parentExt)
					{
						System.out.println("GMX - CreateExtension - Creation d'une extension du meme type que son extension parente");
						int parentExtType = parentExt.getNatureInfos(context);
						//c.e 2,3
						if ((parentExtType & DAuCustoDictionary.USAGE_EXTENSION_CUSTOMER) == DAuCustoDictionary.USAGE_EXTENSION_CUSTOMER){
							if(!parentExt.getScopes(context,false).isEmpty() && !parentExt.getInheritedScopes(context).isEmpty())
							 newExtension = custoPackage.createCustomerExtension(context, extensionName, parentExt.getName(), null,ExtComment,isAbstract);
							else
							 newExtension = custoPackage.createCustomerExtension(context, extensionName, parentExt.getName(), extendedTypes,ExtComment,isAbstract);
								
						}
						//s.e 2
						else if ((parentExtType & DAuCustoDictionary.USAGE_EXTENSION_SPECIALIZATION) == DAuCustoDictionary.USAGE_EXTENSION_SPECIALIZATION){
							newExtension = custoPackage.createSpecializationExtension(context, extensionName, parentExt.getName(), null,ExtComment);
							if(null != iconName && !iconName.isEmpty()){
								newExtension.setIconName(context,iconName,false);
							}
						}
					}
					else
					{
						//s.e 1
						// soit l'extension parente est dans le package pere, soit ... il y a un souci
						//IDAuPackage parentPackage = custoPackage.getDirectParent(context);
						ArrayList parentsPackage = custoPackage.getDirectParents(context);
						IDAuPackage parentPackage = null;
						if (parentsPackage != null) {
							int nSize =  parentsPackage.size();
							if (nSize > 0) {
								if (nSize == 1) {
									parentPackage = (IDAuPackage)parentsPackage.get(0);
								}
								else {
									// This package was modified outside of Custo tool
									emxNavErrorObject.addMessage("Package modified outside of Custo tool and contains multiple parents.");
									%>
									<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
									<%
								}
							}
						}
						if (null != parentPackage)
						{
							parentExt = parentPackage.getExtension(context, parentExtension);
							if (null != parentExt){
								newExtension = custoPackage.createSpecializationExtension(context, extensionName, parentExt.getName(), extendedTypes,ExtComment);
								if(null != iconName && !iconName.isEmpty()){
									newExtension.setIconName(context,iconName,false);
								}
							}
							else
							{
								// gros probleme, la recuperation du parent a echoue
								//System.out.println("GMX - createExtension - PROBLEME : impossible de retrouver le pere de l'extension a creer");
								%>
								<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
								<%
							}
						}
					}
				}
				else
				{
					//System.out.println("GMX - CreateExtension - Creation d'une extension custo sans pere");
					
					newExtension = custoPackage.createCustomerExtension(context, extensionName, null, extendedTypes,ExtComment,isAbstract);
				}
					
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
			else
			{
				//System.out.println("GMX - CreateExtension - Impossible de recuperer le package custo");
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
<script language="Javascript" src="../common/scripts/emxUIUtility.js"></script>
<script language="javascript">
var subExt = "<%=subExtensionCreation%>";
//YI3 - (02072013) Refresh of frame - IR: HF-197248V6R2013x_ 
var sbWindow = findFrame(top, "PackageConfigExtsCmd");
if (sbWindow){
	if(sbWindow.editableTable){
		if(subExt=="true"){ 
			if(typeof sbWindow.emxEditableTable != 'undefined' && sbWindow.emxEditableTable.refreshStructureWithOutSort ){
			   sbWindow.emxEditableTable.refreshStructureWithOutSort();
			   sbWindow.refreshRows();
			   sbWindow.expandAll();
			}
		}else{
			sbWindow.editableTable.loadData();
			sbWindow.RefreshTableHeaders();
			sbWindow.rebuildView();
		}
	}
}
</script> 

<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
