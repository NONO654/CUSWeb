<%--  emxPackagesConfigurationExport.jsp  --  Export the selected packages
  Copyright (c) 1992-2011 Dassault Systemes.
  All Rights Reserved.
  This program contains proprietary and trade secret information of MatrixOne,Inc.
  Copyright notice is precautionary only and does not evidence any actual or intended publication of such program

  static const char RCSID[] = $Id: emxPackagesConfigurationCreatePackage.jsp.rca 1.35 Wed Oct 22 16:06:17 2008 przemek Experimental przemek $
 --%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<%@page import = "com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@include file = "emxPackagesConfigurationStartTransaction.inc"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.DAuManagerAccess"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuManager"%>
<%@page import = "com.dassault_systemes.DictionaryAuthor_itfs.IDAuPackage"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.io.BufferedInputStream"%>
<%@page import="java.io.BufferedOutputStream"%>
<%@page import="java.io.File"%>
<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
<%
//HashMap requestMap = UINavigatorUtil.getRequestParameterMap(pageContext);
String selPacksIds[] = emxGetParameterValues(request, "emxTableRowId");
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
		    ArrayList<String> listMetadata = new ArrayList<String>();
			String property = "java.io.tmpdir";
			String tmpDir = System.getProperty(property);
			property = "file.separator";
			String separator = System.getProperty(property);
			if (!tmpDir.endsWith(separator)) {
				tmpDir = tmpDir + separator;
			}
			String sessionId = context.getSession().getSessionId();
			int idx = sessionId.indexOf(":(");
			if (idx > 0 ) {								
				sessionId = sessionId.substring(0,idx);
			}	
			sessionId = sessionId.replace(":","_");
			String masksDirName = tmpDir+"MASK"+separator;
			String custoTmpDir = masksDirName + sessionId;

			File custoDir = new File(custoTmpDir);
			if (custoDir.exists()) {
				tmpDir = custoTmpDir + separator;
			}
			else {
			// try to create it
				if (custoDir.mkdirs()) {
					tmpDir = custoTmpDir + separator;
				}
			}
			String destPath = custoDir.getAbsolutePath();
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
				

				Map argsHash = new HashMap();
				if (null != pack){
					boolean isExportable = true;
					String status = pack.getPublishStatus(context);
					if (isExportable) {
						argsHash.put("packId", packId);
						argsHash.put("destPath", destPath);
	
						// Pack arguments into string array.
						String[] args = JPO.packArgs(argsHash);
						String packPath =(String) JPO.invoke(context, "emxPackagesConfigurationProgram", null, "generateMaskForPackage", args, String.class);

						//String packPath = pack.export(context);
						
						if (packPath != null && !packPath.isEmpty()) {
							listMetadata.add(packPath);
							nbExportedPacks++;
						}
					}
				}
				else
					System.out.println("ERROR : Package " + packId + " not found");
			}
			if (nbExportedPacks > 0) {
				// set the http content type to "APPLICATION/OCTET-STREAM"
				String contentType = "APPLICATION/ZIP";
				//HttpServletResponse response = ((ABCActionHttpContext)ctx).getResponse();
				response.setContentType(contentType);
				String zipExportedName = "PackagesMasksExport.zip";
				// initialize the http content-disposition header to indicate a file attachment with the default zipExportedName
				String dispHeader = "Attachment; Filename=\"" + zipExportedName + "\"";
				response.setHeader("Content-Disposition",dispHeader);
				//response.setHeader  ("Content-Disposition","attachment;  filename=\""  +  zipExportedName  +"\""); 
				//Transfer now the file
				byte[] zipBytes = manager.createZip(listMetadata);
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
					manager.deleteFolder(masksDirName);
				}
			}
			System.out.println("Export Masks OK. " + nbExportedPacks + " exported on " + nbPacks );
			//%>
			//<%@ include file = "emxPackagesConfigurationCommitTransaction.inc" %>
			//<%
		}
		catch (Exception e)
		{
			System.out.println("Export Masks KO" + e.getMessage());
			emxNavErrorObject.addMessage("Export Masks KO : " + e.getMessage());									
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
