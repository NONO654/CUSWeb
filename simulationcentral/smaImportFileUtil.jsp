<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  smaImportFileUtil.jsp Process import command found on the Simulation or 
  Simulation Activity parameter page.  Puts up a file browse button
  and two checkboxes so the user can control parameter error processing 
  and duplicate parameter name processing
--%>
<%@page import="com.sun.corba.se.spi.ior.ObjectId"%>
<%@include file="../emxUICommonAppInclude.inc"%>
<%@include file="../emxUICommonHeaderBeginInclude.inc"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationConstants"%>
<%@page
    import="com.dassault_systemes.smaslm.matrix.common.SimulationUtil"%>
<%@page import="com.matrixone.apps.domain.DomainObject"%>
<%@page import="com.matrixone.apps.domain.DomainSymbolicConstants"%>
<%@page import="com.matrixone.apps.framework.ui.UINavigatorUtil"%>
<%@page import="com.matrixone.apps.domain.util.i18nNow"%>
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@page import="java.net.URL"%>
<%@page import="matrix.util.StringList"%>
<%@ page import="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>
<script language="Javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>
<%

String objectAction = emxGetParameter(request, "objectAction");
String objId = emxGetParameter(request, "objectId");
String overwriteDup = emxGetParameter(request,"overwriteDuplicates");
String overwrite = "no";

if (overwriteDup != null && 
"overwriteDuplicates".equalsIgnoreCase(overwriteDup))
    overwrite = "yes";
String URL = "";
String csrfWSURL = "../resources/slmservices/token/CSRF";

if(objectAction.equalsIgnoreCase("parameterImport"))
    URL = "../resources/slmservices/sim/" + objId +
        "/parameters?action=import&overWrite=" +
            overwrite ;

else if(objectAction.equalsIgnoreCase("attributeImport"))
    URL = "../resources/slmservices/attributeGroups/" 
        + objId + "/importFromFile?fileName=";

else if(objectAction.equalsIgnoreCase("hostImport"))
{
    if ("overwriteDuplicates".equalsIgnoreCase(overwriteDup))
        overwrite = "yes";
    URL = "../resources/slmservices/station/" 
        + "importFromFile?overWrite=" +
            overwrite + "&fileName=";
}

String selectOneFileWarning =
SimulationUtil.getI18NString(context,
    "smaHome.cmdChecks.SelectOnlyOne");
String fileNotFoundError =
SimulationUtil.getI18NString(context,
    "smaSimulationCentral.importxml.warning.notfounderror");

String securityError =
SimulationUtil.getI18NString(context,
    "smaSimulationCentral.importxml.warning.securityerror");

String notReadableError =
SimulationUtil.getI18NString(context,
    "smaSimulationCentral.importxml.warning.NotReadableError");

String encodingError =
SimulationUtil.getI18NString(context,
    "smaSimulationCentral.importxml.warning.encodingerror");

String fileErrorCode =
SimulationUtil.getI18NString(context,
    "smaSimulationCentral.importxml.warning.fileerrorcode");

String noFileSelectedError = 
SimulationUtil.getI18NString(context,
    "smaSimulationCentral.importxml.warning.nofileselected");

String title = SimulationUtil.getI18NString(context,
    "smaSimulationCentral.ImportExportClose."+ objectAction);

String closeLabel = SimulationUtil.getI18NString(context,
"smaSimulationCentral.Button.Close");

StringBuilder paramHTML = new StringBuilder(100);
StringBuilder headerHTML = new StringBuilder(100);

headerHTML.append("<div id=\"pageHeadDiv\"> ");
headerHTML
.append("<TABLE> <TR> <TD class=\"page-title\"> <h2>");
headerHTML.append(title).append("</h2></TD> </TR>");
headerHTML.append(" </TABLE></div> ");

// build toolbar 
StringBuilder toolBarHTML = new StringBuilder(100);
toolBarHTML.append("<TABLE bgcolor=\"#E0E0E0\" ");
toolBarHTML
.append("border=\"1px\" borderColor=\"#CCCCCC\" ");
toolBarHTML.append("width=\"100%\" ");
toolBarHTML
.append("cellspacing=\"0\" cellpadding=\"0\">");
toolBarHTML
.append("<TR> <TD><TABLE ><TR valign=\"bottom\">");
String endToolBarHTML = "</TR></TABLE></TD></TR> </TABLE>";

paramHTML.append(headerHTML.toString());
paramHTML.append(toolBarHTML.toString());
paramHTML.append(endToolBarHTML);

%>
<head>
<link rel="stylesheet" href="../common/styles/emxUIDefault.css"
    type="text/css">
<title><%=title%></title>
</head>
<body style="margin: 0px; padding: 0px;">
    <%=paramHTML.toString()%>
    <br>
    <br>
    <div id="divPageBody" style="margin: 5px; padding: 5px;">
        <input type="file" id="fileSelector" multiple accept=".xml" />
            <script type="text/javascript">
      var objectId = "<%=objId %>";
      var overwrite = "<%=overwrite %>";
      var objectAction = "<%=objectAction %>";
      var url = "<%=URL %>";
      var csrfWSURL = "<%=csrfWSURL %>";
      var fileName = "";
      if (!window.FileReader) {
        message = '<p>The ' +
                  '<a href="http://dev.w3.org/2006/webapi/FileAPI/" target="_blank">File API</a>s ' +
                  'are not fully supported by this browser.</p>' +
                  '<p>Upgrade your browser to the latest version.</p>';
      
        document.querySelector('body').innerHTML = message;
      }
      else {
        // Set up the file drag and drop listeners:         
        document.getElementById('fileSelector').addEventListener('change', handleFileSelection, false);
      }
      
      function handleDragOver(evt) {
        evt.stopPropagation();  // Do not allow the dragover event to bubble.
        evt.preventDefault(); // Prevent default dragover event behavior.
      }

      function importParameters(evt) {
        var fileString = evt.target.result;

        importParametersXML(fileString);
      }
      
      function importParametersXML(fileString)
      {
          if(objectAction == "attributeImport" || 
                  objectAction == "HostImport")
              url = url+fileName;
          
          jQuery.ajax
          (
              {
                  url : csrfWSURL,
                  type : "GET",
                  contentType : "text/plain",
                  beforeSend: function(request){
                      request.setRequestHeader('Accept', 'application/json');
                  },
                  error:  function(err){
						console.log(err);
		          		alert(err);
				  	},
                  success: function(response){
                	  csrfKey = response;
                      jQuery.ajax
                      (
                          {
                  url : url,
                  type : "POST",
                              beforeSend: function(request){
                                  request.setRequestHeader('Accept', 'application/xml');
                                  request.setRequestHeader('eno_csrf_token', csrfKey);
                              },
                  data : fileString,
                  contentType : "application/xml",
                  error: redirectURL,
                              success: redirectURL
              });         
                  }
              });
          
      }
      
      function redirectURL(returndata)
      {
    	  var responseString = "";
    	  if(returndata.responseText)
    		  responseString = returndata.responseText;
    		  
    		  getTopWindow().location.href = 
    			  "../simulationcentral/smaImportExportClose.jsp?results="
                  +responseString+"&method="+objectAction;
       }
      
      function handleFileReadAbort(evt) {
        alert("File read aborted.");
      }

      function handleFileReadError(evt) {
        var message;
        
        switch (evt.target.error.name) {
          case "NotFoundError":
            alert("<%=fileNotFoundError %>");
            break;
          case "SecurityError":
            alert("<%=securityError %>");
            break;
          case "NotReadableError":
            alert("<%=notReadableError %>");
            break;
          case "EncodingError":
            alert("<%=encodingError %>");
            break;
          default:
            alert("<%=fileErrorCode %>" + evt.target.error.name);
        }
      } 

      function startFileRead(fileObject) {
        var reader = new FileReader();

        // Set up asynchronous handlers for file-read-success, file-read-abort, and file-read-errors:
        reader.onloadend = importParameters; // "onloadend" fires when the file contents have been successfully loaded into memory.
        reader.abort = handleFileReadAbort; // "abort" files on abort.
        reader.onerror = handleFileReadError; // "onerror" fires if something goes awry.

        if (fileObject) { 
          reader.readAsText(fileObject); // Asynchronously start a file read thread. Other supported read methods include readAsArrayBuffer() and readAsDataURL().
        }
      } 

      function handleFileSelection(evt) {
        evt.stopPropagation(); // Do not allow the drop event to bubble.
        evt.preventDefault(); // Prevent default drop event behavior.

        var files = evt.target.files;

        if (!files) {
          alert("<%=noFileSelectedError %>");
          return;
        }

        if (files.length > 1) {
            alert("<%=selectOneFileWarning %>");
            return;
          }

        for (var i = 0, file; file = files[i]; i++) {
          if (!file) {
            alert("Unable to access " + file.name); 
            return;
          }
          if (file.size == 0) {
            alert("Skipping " + file.name.toUpperCase() + " because it is empty.");
            return;
          }
          if ( !file.type.match('text/.*') ) {
            alert("Skipping " + file.name.toUpperCase() + " because it is not a known text file type.");
            return;
          }
          fileName = file.name;
          startFileRead(file);
        }
      }  
      </script>
    </div>
    <form action="result" method="post">
        <br>
        <div id="divPageFoot">
            <table>
                <tr>
                    <td class="functions"></td>
                    <td class="buttons">
                        <table>
                            <tr>
                                <td><a href="javascript:getTopWindow().closeWindow();"><img
                                        src="../common/images/buttonDialogCancel.gif" border="0"
                                        alt="<%=closeLabel%>"></a></td>
                                <td><a href="javascript:getTopWindow().closeWindow();" class="button"><%=closeLabel%></a></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
