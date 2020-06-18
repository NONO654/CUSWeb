<%--  emxBOMManagementDownloadPackageTransferProcess.jsp   -

   All Rights Reserved.
   This program contains proprietary and trade secret information of MatrixOne,Inc.
   Copyright notice is precautionary only
   and does not evidence any actual or intended publication of such program

 static const char RCSID[] = $Id: emxComponentsPackageTransferProcess.jsp.rca 1.12 Wed Oct 22 16:18:57 2008 przemek Experimental przemek $
--%>


<%@page import="com.matrixone.apps.domain.util.EnoviaBrowserUtility.Browsers"%>
<%@page import="com.matrixone.client.fcs.FcsClient"%>
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file="emxEngrNoCache.inc"%>
<%@ include file="emxEngrUtil.inc"%>
<%@include file="emxEngrAppletInclude.inc"%>

<%@page import = "com.matrixone.apps.domain.DomainObject"%>

<%@ page
import="com.matrixone.servlet.*,matrix.db.*,com.matrixone.fcs.http.*,com.matrixone.fcs.common.*,com.matrixone.fcs.mcs.*"%>

 <link rel="stylesheet" type="text/css" href="../common/styles/emxUIDefault.css"/>        
<html>

<%
try{
//get the selected checkbox values
  String stUser = context.getUser().toString().trim();
  String partId = emxGetParameter(request,"objectId");
  String fileObjs[] = emxGetParameterValues(request,"checkBoxName");
  String selectedlevel = emxGetParameter(request,"selectedlevel");
  String sGenericFormat = DomainObject.FORMAT_GENERIC;
  String errorPage = "../components/emxComponentsError.jsp";
  String incBOMStructure =  emxGetParameter(request,"incBOMStructure");
  boolean bIncBOMStructure = true;
  
  if(incBOMStructure != null && "false".equals(incBOMStructure))
  {
      bIncBOMStructure = false;
  }  
 
  Date nowDate = new Date();

  double iTimeZone = (new Double((String)session.getValue("timeZone"))).doubleValue(); //60*60*1000 *-1;

		String strDownloadDateTime = nowDate.toString();

  		HashMap programMap = new HashMap();
        programMap.put("partId", partId);
        programMap.put("fileObjs", fileObjs);
        programMap.put("selectedlevel", selectedlevel);
        programMap.put("strDownloadDateTime", strDownloadDateTime);
        programMap.put("errorPage", errorPage);
        programMap.put("request", request);
        programMap.put("response", response);
        programMap.put("bIncBOMStructure", bIncBOMStructure);
        
        TicketWrapper ticketWrp =  (TicketWrapper)JPO.invoke(context, "enoDownloadPackage", null, "getDownloadPackage", JPO.packArgs (programMap), TicketWrapper.class);
               
		String ticketStr = ticketWrp.getExportString();
		String ftaAction = ticketWrp.getActionURL();

    // Added the code for Applet functionality
    boolean useApplet = false;
    try {
        useApplet = (("true".equals(EnoviaResourceBundle.getProperty(context,"emxFramework.UseDownloadApplet"))));
    } catch(Exception e) {
    // do nothing useApplet already false
    }

    // since there is no java plug-in with version 1.5 or above available for Mac OS 10.2.6
    // do not use Applet for Mac requests
    
    if(EnoviaBrowserUtility.is(request,Browsers.MAC_OS))
    {
        useApplet = false;
    }
    
  //fix to check download file size<2GB
        String filenames = ""; 
        String formats ="";
        String specId = "";
        String parentEBOMId = "";
        String insideZipDir = "";
        long totalSize = 0;
 if( useApplet )
       {
        try {
         
              if(fileObjs != null)
              {
                for(int j=0;j<fileObjs.length;j++)
                {
                    StringTokenizer fileTokens    =   new StringTokenizer(fileObjs[j],"&");
                    if(fileTokens.hasMoreTokens())
                    {
                        insideZipDir = fileTokens.nextToken();
                        String  objIds   =   fileTokens.nextToken();
                        formats = fileTokens.nextToken();
                        filenames   =   fileTokens.nextToken();

                        StringTokenizer idTokens = new StringTokenizer(objIds,"|");
                        if(idTokens.hasMoreTokens())
                        {
                            parentEBOMId   =   idTokens.nextToken();
                            specId    =   idTokens.nextToken();
                        }
            //get file size
                        String select = "print bus " + specId + " select format[" + formats + "].file[" + filenames + "].size dump";
                        String fileSize = MqlUtil.mqlCommand(context,select);
                    if ( fileSize != null )
                    {
                        totalSize += (new Long(fileSize)).longValue();
                    }
                    if( totalSize >= 2048000000 )
                    {
                        useApplet = true;
                        break;
                    }
                    
                }
              }
            }    
            if( totalSize < 2048000000 )
                {
                        useApplet = false;
                }
           
        }catch(Exception ex)
                {
                    // do nothing
                }
       }      
    //end of  fix
    if (useApplet) 
    {
        HashMap props = new HashMap();
        props.put("jobTicket", ticketStr);
        props.put("fcsURL", ftaAction);    
        props.put("refresherURL",Framework.getClientSideURL(response,"/servlet/fcs/checkin"));
        addApplet(request, response, out, context, "com.matrixone.fcs.applet.FileDownloadApplet", 1, 1, props);
%>
        <script>

        function doSubmit()
        {
            var applet = getApplet();
            applet.setCookies(document.cookie);
            applet.doWork();
            //document.forms["FcsForm"].progress.src="../common/images/utilSpacer.gif";
            document.body.className = "download-complete";
        }
        </script>
<%
    }
    else
    {
		
%>
        <script language="javascript">
        function doSubmit() 
        {
            //document.forms["FcsForm"].progress.src="../common/images/utilSpacer.gif";
            //XSSOK
            document.forms["FcsForm"].action="<%=ftaAction%>";
            document.body.className = "download-complete";
            document.forms["FcsForm"].submit();
        }
        </script>
		<script language="JavaScript" src="../common/scripts/emxUICore.js"></script>
<%
    }
 %>
<body onLoad=" resizeWindow(); doSubmit();" class="download-progress" >

<form method="post" name="FcsForm">
    <div id="emxDialogBody">
        <div id="progress">
            <h1><emxUtil:i18n localize="i18nId">emxComponents.CommonDownload.Downloading</emxUtil:i18n></h1>
            <p><emxUtil:i18n localize="i18nId">emxComponents.CommonDownload.DownloadingMessage</emxUtil:i18n></p>
        </div>
        <div id="complete">
            <h1><emxUtil:i18n localize="i18nId">emxComponents.CommonDownload.DownloadComplete</emxUtil:i18n></h1>
            <p><emxUtil:i18n localize="i18nId">emxComponents.CommonDownload.DownloadCompleteMessage</emxUtil:i18n></p>
        </div>
    </div>
    <div id="emxDialogFoot">
        <div id ="closeButton" ><input type="button" value="Close" onclick="javascript:window.closeWindow();"/></div>
    </div>
<input type="hidden" name="<%=McsBase.resolveFcsParam("jobTicket")%>" value="<xss:encodeForHTMLAttribute><%=ticketStr%></xss:encodeForHTMLAttribute>" />
<input type="hidden" name="<%=McsBase.resolveFcsParam("failurePage")%>" value="<xss:encodeForHTMLAttribute><%=Framework.getFullClientSideURL(request,response,errorPage)%></xss:encodeForHTMLAttribute>" />
<!--//XSSOK-->
<input type="hidden" name="<%=McsBase.resolveFcsParam("attachment")%>" value="true" />

</form>

<script language="javascript">
//doSubmit();
function resizeWindow()
{
	window.resizeTo(550,300);		
}
</script>
<%
    }
 catch(Exception e) {
       //COMES HERE WHEN ANY OPERATION HAS FAILED.
       ContextUtil.abortTransaction(context);
       out.println("Exception in excel creation & checkin......"+e.toString());
    e.printStackTrace();
       //throw e;
   }
%>
</body>
</html>
