<%--  emxPackagesConfigurationCreatePackage.jsp - Creating Package object
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreatePackage.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek
--%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuUtilities"%>
<%
String packageName = emxGetParameter(request, "custoPackageName");
String packageParent = emxGetParameter(request, "parent");
String packagePrefix = emxGetParameter(request, "prefix");
String packageNewPrefix = emxGetParameter(request, "newPrefix");
String packageComment = emxGetParameter(request, "userComment");
String strLang = context.getSession().getLanguage();
String strInvalidOption = DAuUtilities.getSpecializationStringResource(context,"emxDataSpecialization.label.PackageEnterNewPrefix","Default Value");
String packNature="";
if ((null != packageName) && !packageName.isEmpty() && (null != packagePrefix) && !packagePrefix.isEmpty())
{
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
		    if (null != packageNewPrefix && !packageNewPrefix.isEmpty()) {
				packagePrefix = packageNewPrefix;
			} 
			else {
				if (packagePrefix.equals(strInvalidOption)) {
					emxNavErrorObject.addMessage("Must enter valid value for prefix.");									
					%>
					<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
					<%
					return;
				}
			}
			IDAuPackage newPackage = null;
			if((null != packageParent) && !packageParent.isEmpty()){
				newPackage = manager.createSpecializationPackage(context, packagePrefix, packageName, packageParent, packageComment);
				packNature="specialization";
			}else {
				newPackage = manager.createDeploymentPackage(context, packagePrefix, packageName, packageComment);
				packNature="deployment";
			}
			if (null != newPackage)
			{
				String packageId = newPackage.getID(context);
				if ((null != packageId) && !packageId.isEmpty())
				{
					%>
					<%--  Update the admin index value in a HttpSession variable --%>
					<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
					<script language="javascript">
						function redirection(iFrame, iURL)
						{
							iFrame.document.location.href = iURL;
						}
						var packageNature = "<%=packNature%>"; 
						var contentFrame = openerFindFrame(top, "content");
						var url = "";
						if (null != contentFrame)
						{
							// YI3-140116 : IR-270088
							//if KWD
							if(packageNature == "specialization")
								url = "../common/emxPortal.jsp?portal=PackageConfigurationPortal&toolbar=PackagePublicationToolbar&header=<%=packageName%>&emxSuiteDirectory=DataSpecialization&relId=null&parentOID=null&jsTreeID=null&suiteKey=DataSpecialization&objectId=<%=packageId%>";
							//if DMA
							else if(packageNature == "deployment")
								url = "../common/emxPortal.jsp?portal=DeploymentConfigurationPortal&toolbar=DeploymentGeneralToolbar&header=<%=packageName%>&emxSuiteDirectory=DataSpecialization&relId=null&parentOID=null&jsTreeID=null&suiteKey=DataSpecialization&objectId=<%=packageId%>";

							setTimeout('redirection(contentFrame, url)', 100);
							//redirection(contentFrame, url);
						}
					</script>
					<%
					// YI3 - don't set index-cache variable in the new deployment package
          if((null != packageParent) && !packageParent.isEmpty()){
          %>
            <%-- BMN2 19/09/2018 IR-633070 : After analysis with JPI, we found that this line is no more useful.
             include file = "emxPackagesConfigurationUpdateAdminIndexes.inc" --%>
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
