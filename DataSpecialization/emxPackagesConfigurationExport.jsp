<%--  emxPackagesConfigurationExport.jsp  --  Export the selected packages
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreatePackage.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>

<%@page import="java.util.ArrayList"%>
<%@page import="java.util.HashMap"%>
<%@page import="java.util.Arrays"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuI18N"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.BufferedInputStream"%>
<%@page import="java.io.BufferedOutputStream"%>
<%@page import="java.io.File"%>
<%@page import="java.util.List"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
//HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
String selLangIds[] = emxGetParameterValues(request, "emxTableRowId");
List<String> Languages = new ArrayList<String>();
if(selLangIds!=null)
{
	for(int i =0;i <selLangIds.length;i++)
	{
	  String tmp[]= selLangIds[i].split("\\|");
	  String lang = tmp[1];
	  Languages.add(lang);
	}
}
String emxParentIds= emxGetParameter(request, "emxParentIds");
String selPacksIds[] = null;
if(emxParentIds!=null){ 
  selPacksIds = emxParentIds.split("\\~");
}
Enumeration eNumParameters = emxGetParameterNames(request);
String parmValue = "";
String tableRowIds[] = null;
/*while( eNumParameters.hasMoreElements() ) {
	String parmName  = (String)eNumParameters.nextElement();
	System.out.println("param  : " + parmName);
}*/
int nbPacks = (null != selPacksIds) ? selPacksIds.length : -1;
int k = 0;
System.out.println(nbPacks + " package(s) to export");
if (nbPacks < 1)
{
	String packId = emxGetParameter(request, "objectId");
	if ((null != packId) && !packId.isEmpty())
	{
		selPacksIds = new String[1];
		selPacksIds[0] = packId;
		nbPacks = 1;
	}
	else
	{
		// In the deployment package page, there no mean to get the id.
		//System.out.println("Export of the deployement package ?");
		IDAuManager manager = DAuManagerAccess.getDAuManager();
		ArrayList<IDAuPackage> deploymentPackages = manager.getDeploymentPackages(context);
			if ((null != deploymentPackages) && (1 == deploymentPackages.size()))
			{
				IDAuPackage deploymentPackage = deploymentPackages.get(0);
				if (null != deploymentPackage)
				{
					selPacksIds = new String[1];
					selPacksIds[0] = deploymentPackage.getID(context);
					nbPacks = 1;					
				}
			}
	}
}
if ((null != selPacksIds) )
{
	int nbExportedPacks = 0;
	IDAuManager manager = DAuManagerAccess.getDAuManager();
	if (null != manager)
	{
		try
		{
		    ArrayList<String> listFiles = new ArrayList<String>();
		    IDAuI18N I18N = null;
		    if(nbPacks!=0 && Languages.size()!=0)
		    {
				I18N = manager.getI18N(Languages);
		    }
			for (k = 0; k<nbPacks; k++)
			{
			String packId = selPacksIds[k];
				if (packId.startsWith("|") == true ) {
					packId = packId.substring(1);
				}
				int idxPipes = packId.indexOf("||");
				if (idxPipes > 0 ) {								
					packId = packId.substring(0,idxPipes);
				}
				IDAuPackage pack = manager.getPackageFromId(context,packId);
				if (null != pack){
				  if(I18N !=null){
 				  	pack.setI18N(context, I18N);
				  }
					boolean isExportable = true;
					//isExportable = pack.canBeExportted(context);
					if (isExportable) {
						String packPath = pack.export(context);
						if (packPath != null && !packPath.isEmpty()) {
							listFiles.add(packPath);
							nbExportedPacks++;
						}
					}
				}
				else
					System.out.println("ERROR : Package " + packId + " not found");
			}
			if(nbPacks!=0&&null!=I18N)
			{
		    	I18N.closeWriter();
			  	List<String> nlsPropFiles = I18N.getNLSProperties();
			  	for(String propFile : nlsPropFiles)
			  	{
			  	  listFiles.add(propFile);
			  	}
			}
			if (nbExportedPacks > 0) {
				// set the http content type to "APPLICATION/OCTET-STREAM"
				String contentType = "APPLICATION/ZIP";
				//HttpServletResponse response = ((ABCActionHttpContext)ctx).getResponse();
				response.setContentType(contentType);
				String zipExportedName = "PackagesExport.zip";
				// initialize the http content-disposition header to indicate a file attachment with the default zipExportedName
				String dispHeader = "Attachment; Filename=\"" + zipExportedName + "\"";
				response.setHeader("Content-Disposition",dispHeader);
				//response.setHeader  ("Content-Disposition","attachment;  filename=\""  +  zipExportedName  +"\""); 
				//Transfer now the file
				byte[] zipBytes = manager.createZip(listFiles);
				BufferedOutputStream output = null;
				try {
					int DEFAULT_BUFFER_SIZE = zipBytes.length; // 10K
					// Open streams.
					output = new BufferedOutputStream(response.getOutputStream(),DEFAULT_BUFFER_SIZE);
					// Write file contents to response.
					output.write(zipBytes, 0, DEFAULT_BUFFER_SIZE);
				} 
				finally {
					// close streams.
					output.close();
				}
			}
			System.out.println("Export OK. " + nbExportedPacks + " exported on " + nbPacks );
			//%>
			//<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
			//<% 
		}
		catch (Exception e)
		{
			System.out.println("Export KO" + e.getMessage());
			emxNavErrorObject.addMessage("Export KO : " + e.getMessage());									
			%>
			<%@ include file = "emxPackagesConfigurationAbortTransaction.inc" %>
			<%
		}		
	}
}
%>
<%@include file="../common/emxNavigatorBottomErrorInclude.inc"%>
<%-- Reload the page --%>
<script language="Javascript" >
window.parent.location.href = window.parent.location.href ;	
</script>
