<%@include file = "emxNavigatorInclude.inc"%>
<%@include file = "emxNavigatorTopErrorInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@include file = "enoviaCSRFTokenValidation.inc"%>
<jsp:useBean id="tableBean" class="com.matrixone.apps.framework.ui.UITable" scope="session" />

<%
String suiteKey= emxGetParameter(request,"suiteKeyFromURLUtils");
String SuiteDirectory= emxGetParameter(request,"SuiteDirectoryFromURLUtils");
String sHelpMarker= emxGetParameter(request,"HelpMarker");
String strLanguage = request.getHeader("Accept-Language");
%>

<script src="../common/scripts/emxUICore.js"></script>
<script src="../common/scripts/emxUIConstants.js"></script>
<script type="text/javascript">
<%@page import="com.matrixone.apps.domain.util.FrameworkUtil,
                com.matrixone.apps.framework.ui.UIUtil,
                matrix.db.Context,
                com.matrixone.servlet.Framework,
                com.matrixone.apps.domain.util.XSSUtil"
                %>
var langOnlineStr = emxUIConstants.STR_HELP_ONLINE_LANGUAGE;
openHelp('<%=sHelpMarker%>','<%=SuiteDirectory%>','<%=strLanguage%>',langOnlineStr,'','<%=suiteKey%>');
  function openHelp(pageTopic, directory, langStr, langOnlineStr, topLevel, suiteKey) {

  directory = directory.toLowerCase();
  var strFinalURL = "../common/emxXMLHelpLookup.jsp?suiteDir="+directory+"&language="+langStr+"&pageTopic="+pageTopic+"&suiteKey="+suiteKey;
  var isHtmlHelpfile = emxUICore.getData(strFinalURL);
  var htmlHelpfile = emxUICore.trim(isHtmlHelpfile);
  var errorMessageURL = null;
  var url = null;
  var errorJSP = "../common/emxXMLError.jsp";
  if(htmlHelpfile=="false"){
    url = "../doc/" +  directory + "/" + langStr + "/wwhelp/wwhimpl/js/html/wwhelp.htm?context=" + directory + "&topic=" + pageTopic;
    if(!checkURL(url)){
      url = "../doc/" +  directory + "/" + langStr + "/ENOHelp.htm?context=" + directory + "&topic=" + pageTopic;
      if(!checkURL(url)){
        errorMessageURL = errorJSP;
      }
    }
  } else{
	  var defaultUrl;
	  if(emxUIConstants.HELP_URL.indexOf('http') == 0 && emxUIConstants.HELP_URL.indexOf("HelpDS.aspx") > -1){
		  // We have to find a solution for not hardcoding V here		  
		  var contextscope ="";
		  if(emxUIConstants.STR_IS_CLOUD == "true"){
			  contextscope = "cloud";
		  }else{
			  contextscope = "onpremise";
		  }
		  url = emxUIConstants.HELP_URL + "?P=11&V=2019x" + "&L=" +  langOnlineStr + "&F=" +htmlHelpfile + "&contextscope=" + contextscope;
		  defaultUrl = emxUIConstants.HELP_URL + "?P=11&V=2019x" + "&L=" +  langOnlineStr + "&F=" +"FrontmatterMap/DSDocHome.htm" + "&contextscope=" + contextscope;
	  }else{
    url = emxUIConstants.HELP_URL + "/" +  langOnlineStr + "/DSDoc.htm?show=" + htmlHelpfile;
		  defaultUrl = emxUIConstants.HELP_URL + "/DShomepage_"+langOnlineStr+".htm";
	  }
    try {
      if(!checkURL(url) || htmlHelpfile == "true"){
    	url = emxUIConstants.HELP_URL + "/DShomepage_"+langOnlineStr+".htm";
    	if(!checkURL(url)){
	        errorMessageURL = errorJSP+"?pageTopic="+pageTopic;
	    }
      }
    } catch (err) {
    	// do nothing
    }
  }
  if(errorMessageURL){
    var errorMessage = emxUICore.getData(errorMessageURL);
    alert(errorMessage);
    return;
  }
  if ((childWindow == null) || (childWindow.closed)){
    childWindow = window.open(url,"helpwin","location=no,menubar=no,titlebar=no,width=700,height=700,resizable=yes,scrollbars=yes");
    childWindow.focus();
  } else {
    childWindow.location.replace(url);
    childWindow.focus();
  }
  return;
}


function checkURL(url){
  if(url.indexOf('http') == 0){
		return true;
	}
    var xmlhttp = emxUICore.createHttpRequest();
    xmlhttp.open("GET", url, false);
    //xmlhttp.send(null);
    return xmlhttp.status==200;
}    


</script>



