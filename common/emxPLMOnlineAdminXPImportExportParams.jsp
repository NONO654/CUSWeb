<html>
<HEAD>
<!-- 
//@fullReview ZUR 11/01/27 V6R2012x HL ENOVIA TEAM Parameterization Import/Export
//@fullReview ZUR 12/05/10 V6R2013x - IR-164539V6R2013x
-->

		<link rel=stylesheet type="text/css" href="styles/emxUIDOMLayout.css">
		<link rel=stylesheet type="text/css" href="styles/emxUIDefault.css">
		<link rel=stylesheet type="text/css" href="styles/emxUIPlmOnline.css">  
        
		<%@ page import="java.util.*"%>  
		<%@ page import="com.matrixone.vplm.parameterizationUtilities.MatrixUtilities" %>
		<%@ page import ="com.matrixone.vplm.FreezeServerParamsSMB.FreezeServerParamsSMB"%>
		<%@ page import ="com.matrixone.vplm.parameterizationUtilities.NLSUtilities.ParameterizationNLSCatalog"%>
		
		<script language="javascript" src="scripts/emxPLMOnlineAdminJS.js"></script>
		<script src="scripts/expand.js" type="text/javascript"></script> 
		<script src="scripts/emxUIAdminConsoleUtil.js" type="text/javascript"></script>
		
		<%@include file = "../common/emxNavigatorInclude.inc"%>
		<%@include file = "../emxTagLibInclude.inc"%>	
		
		<%
		Locale currentLocale = request.getLocale();
		
		ParameterizationNLSCatalog myNLS = new ParameterizationNLSCatalog(context, currentLocale, "myMenu");
		
		String NonAppropriateContext	= myNLS.getMessage("NonAppropriateContext");
		String NonAppropriateSolution	= myNLS.getMessage("NonAppropriateSolution");
		String NonAppropriateXMLFormat	= myNLS.getMessage("NonAppropriateXMLFormat"); 
		String XMLFileChoosenImport 	= myNLS.getMessage("XMLFileChoosenImport");//"XML File to import";
	
		String ImportExportTitle 		= myNLS.getMessage("ImportExportTitle");
		String DownloadCATNlsTitle 		= myNLS.getMessage("DownloadCATNlsTitle");	
		String ImportExportToolXMLTip 	= myNLS.getMessage("ImportExportToolXMLTip");	
			
		String ExportXMLText = myNLS.getMessage("ExportXMLText");			
		String SubmitXMLFileTooltip = myNLS.getMessage("SubmitXMLFileTooltip");	
		String ExportXMLFileTooltip = myNLS.getMessage("ExportXMLFileTooltip");	
		String ImportXMLTitle 		= myNLS.getMessage("ImportXMLTitle");	
		String ExportXMLTitle 		= myNLS.getMessage("ExportXMLTitle");	
		String BrowseFileSystemTooltip = myNLS.getMessage("BrowseFileSystemTooltip");
		
		String ImportParamsFileSucceeded 	= myNLS.getMessage("ImportParamsFileSucceeded");
		String ImportParamsFileFailed		= myNLS.getMessage("ImportParamsFileFailed");		
		
		String Deploycmd 	= myNLS.getMessage("Deploycmd");		
		String DeployTitle 	= myNLS.getMessage("DeployTitle");
		String Deploysuccess 	= myNLS.getMessage("Deploysuccess");
		String Deployfail 		= myNLS.getMessage("Deployfail");
		String Freezemessage	= myNLS.getMessage("Freezemessage");	
		
		String DeployAllAndImportedParameters 	= myNLS.getMessage("DeployAllAndImportedParametersTooltip");		
		String ExportParamsFileFailed 			= myNLS.getMessage("ExportParamsFileFailed");
		String DeployAllParameters 				= myNLS.getMessage("DeployAllParametersLabel");
		
		String downloadCATNlsZip = myNLS.getMessage("downloadCATNlsZip");
		String downloadMsg		 = myNLS.getMessage("downloadMsg");
				 
		String admincontext="VPLMAdmin";
		String displayhidediv ="block";
		String displayhidecontrol="none";

		String currentcontext = context.getRole();

		String CurrentUISolution = MatrixUtilities.getCurrentSolution(context);

		//the Administration console will be accessible only if the Current Solution is "TEAM" (=MatrixUtilities.RACE_SOLUTION)
		boolean contextSolutionIsTeam = false;
		if (CurrentUISolution.equalsIgnoreCase(MatrixUtilities.RACE_SOLUTION))
			contextSolutionIsTeam = true;
			
		//the Administration console is accessible only for Admin
		if (currentcontext.indexOf(admincontext) >=0)
		{
			displayhidediv ="none";
			displayhidecontrol="block";
		}		
				
		String importResult = emxGetParameter(request,"importResult");
		
		//Retrieves the "Freeze" status of the command APPXPParamImportExport		 
		FreezeServerParamsSMB Frz = new FreezeServerParamsSMB();
		int iret = Frz.GetServerFreezeStatusDB(context,"APPXPParamImportExport");
		
		String fStatus = "";

		if (iret == Frz.S_FROZEN)	
			fStatus = "disabled";	
		else
			fStatus = "";		
		
		%>						
		
<script language="javascript">

	var xmlreqs = new Array();
	var currentfreeze;
	currentfreeze="<%=fStatus%>";

	// function that ignites the import
	function submitImport()
    {         
	    var ChoosenFile = document.frmImportData.file.value;

    	if (IsChoosenFileXML(ChoosenFile)==false)           	
    		alert("<%=NonAppropriateXMLFormat%>");
    	else
    	{  
    		document.getElementById('LoadingDiv').style.display='block';
			document.getElementById('divPageFoot').style.display='none';
        	document.frmImportData.submit();
    	}
    }
        
	function submitExport()
    {    
        document.frmExportData.submit();
    }
	
	function submitExportZIP()
    {    
        document.frmExportZIP.submit();
    }

    function IsChoosenFileXML(filename) 
    {
        var regex = new RegExp("\\w+\\.xml$", "i");
		if (!regex.test(filename))
			return false;
		else
			return true;
	}
  
    //Deploys All Params in "Param" 
    function DeployAllParams(iInput)
    {
        var srvsend="";

        if (currentfreeze=="disabled")
		    alert("<%=Freezemessage%>");
	    else
		{
			var srvsend ="";		
 			
 			document.getElementById('LoadingDiv').style.display='block';
  			document.getElementById('divPageFoot').style.display='none';
  			//	alert(srvsend);  			
  			xmlreq("emxPLMOnlineAdminXPDeployAllParamsAjax.jsp",srvsend,DeployAllParamsRet,0);
 		}
    }

    function DeployAllParamsRet()
    {
        var xmlhttpRet = xmlreqs[0];

    	if (xmlhttpRet.readyState==4)
        {    
    		var usermessage="";    		
    		var Deploy_result =xmlhttpRet.responseXML.getElementsByTagName("DeployResult");
   
    		if (Deploy_result.item(0)!=null)
			{          	           
				if (Deploy_result.item(0).firstChild.data =="S_OK")
			  		usermessage=usermessage+"\n<%=Deploysuccess%>";
			  	else   
            		usermessage=usermessage+"\n<%=Deployfail%>";          	
			}
    		else 
    			usermessage=usermessage+"\n<%=Deployfail%>";

    		
			document.getElementById('LoadingDiv').style.display='none';
			document.getElementById('divPageFoot').style.display='block';

			alert(usermessage);       
		}	
    	  
    }    
       
	function addTableControllingDiv0(DivID,iTitle,toolbarWidth,iconFileName,iconToolTip)
	{
		document.write('<table border="0" width="'+toolbarWidth+'" >');
		document.write('<tr bgcolor="#6691AA" align="left">');
		document.write('<td class="pic" style="border:0"><img src="../common/images/'+iconFileName+'" title="'+iconToolTip+'"/></td>');
		document.write('<td><b><font color="white">'+iTitle+'</font></b></td>');
		document.write('<td class="pic" style="border:0" align="center"><img src="images/xpcollapse1_s.gif" onclick="SwitchMenuParams(\''+DivID+'\', this);"/></td>');
		document.write('</tr>')
		document.write('</table>');
	}

</script>

</HEAD>

<body>

<script type="text/javascript">
addTransparentLoadingInSession("none","LoadingDiv");
addDivForNonAppropriateContext("<%=displayhidediv%>","<%=NonAppropriateContext%>","100%","100%");
</script>

<script type="text/javascript">
addTableControllingDiv0("globalDivParams","<%=ImportExportTitle%>","100%","iconParameterizationImportExport.gif","<%=ImportExportToolXMLTip%>");
</script>
<div id="globalDivParams" style="width: 97%; background-color:#F3F3F3; height:25%; min-height:10%; overflow-y:auto; overflow-x:hidden">

<div id="importParamsDiv" style="width: 97%; background-color:#F3F3F3; height:25%; min-height:20%; overflow-x:hidden">
<form name="frmImportData" method="post" enctype="multipart/form-data" action="emxPLMOnlineAdminXPImportProcess.jsp?<%=request.getQueryString()%>"   >

  <table width="100%" height="10%" border="0" cellspacing="3" cellpadding="2">
    <tr>
      <td width="20%"> <%=XMLFileChoosenImport%></td>
      <td width="20%"><input type="file" name="file" id="BrowseButton" title="<%=BrowseFileSystemTooltip%>" <%=fStatus%>></input></td>
      <td width="60%"> </td>
    </tr>
    <tr>     
      <td width="20%"> </td>
      <td width="20%"><input type=button name="Submit" id="ImportButton" title="<%=SubmitXMLFileTooltip%>" value="<%=ImportXMLTitle%>" <%=fStatus%> onclick="javascript:submitImport()"></td>
      <td width="60%"> </td>
    </tr>    
   </table>   
   </form> 
   </div>  

 	<br>
 	<br>
 	<br> 	
 	
   <div id="exportParamsDiv" style="width: 97%; background-color:#F3F3F3; height:15%; min-height:10%; overflow-x:hidden">
   <form name="frmExportData" method="post" action="emxPLMOnlineAdminXPExchangeParams.jsp?exportFileName=Parameterization_Export.xml&fileFormat=xml">
    
   <table width="100%" height="10%" border="0" cellspacing="3" cellpadding="2">
     <tr>     	
        <td width="20%"><%=ExportXMLText%></td>
     	<td width="20%"><input type=button name="Submit" title="<%=ExportXMLFileTooltip%>" rows="5" cols="36" wrap value="<%=ExportXMLTitle%>" onclick="javascript:submitExport()"></td>   
     	<td width="60%"></td>
     </tr>   
  </table> 
   
   </form> 
   </div>
    
  </div>
 
 <br>
 <br>

<%
if (contextSolutionIsTeam)
{
%>
	<script type="text/javascript">
	addTableControllingDiv0("DownloadCATNLS","<%=DownloadCATNlsTitle%>","100%","iconParameterizationDownload.gif","<%=DownloadCATNlsTitle%>");
	</script> 
	
	<div id="DownloadCATNLS" style="width: 97%; background-color:#F3F3F3; height:16%; min-height:10%; max-height: 45%; overflow-y:auto; overflow-x:hidden">	
	
	 <form name="frmExportZIP" method="post" action="emxPLMOnlineAdminXPExchangeParams.jsp?exportFileName=ParameterizationCATNls.zip&fileFormat=zip">    
   		<table width="100%" height="10%" border="0" cellspacing="3" cellpadding="2">
     	<tr>     	
        	<td width="20%"><%=downloadCATNlsZip%></td>
     		<td width="20%"><input type=button name="Submit" title="<%=DownloadCATNlsTitle%>" rows="5" cols="36" wrap value="<%=downloadMsg%>" onclick="javascript:submitExportZIP()"></td>   
     		<td width="60%"></td>
     	</tr>    
  		</table>   
   	 </form>
	
   	</div>
 <%
 }
 %>

<script>
<%
if (importResult.equals("SUCCESS"))
{
	%>
	alert("<%=ImportParamsFileSucceeded%>");
	<%
}
else if (importResult.equals("ERROR"))
{
	%>
	alert("<%=ImportParamsFileFailed%>");
	<%	
}

importResult="INIT";
%>

addFooter("javascript:DeployAllParams('nofreeze')","images/buttonParameterizationDeploy.gif","<%=DeployAllParameters%>","<%=DeployAllAndImportedParameters%>",null,null,null,null,null,null,null,null,"<%=displayhidecontrol%>");
</script>

</body>

</html>
