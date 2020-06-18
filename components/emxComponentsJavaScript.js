<body/>
<script language="Javascript">

var NSX = (navigator.appName == "Netscape");
var IE4 = (document.all) ? true : false;

<%
String language  = request.getHeader("Accept-Language");
%>

// Internationalization of AlertMessages used for Selection of an Object,
// Deletion or Removal of Objects.
var MAKE_SELECTION_MSG = "<%=i18nNow.getI18nString("emxComponents.Message.PleaseMakeASelection", "emxComponentsStringResource",language)%>";
var REMOVE_WARNING_MSG = "<%=i18nNow.getI18nString("emxComponents.Message.RemoveWarningMsg", "emxComponentsStringResource",language)%>";
var DELETE_WARNING_MSG = "<%=i18nNow.getI18nString("emxComponents.Message.DeleteWarningMsg", "emxComponentsStringResource",language)%>";

var s = document.createElement('script');
s.setAttribute('type','text/javascript');
s.setAttribute('src','../components/emxComponentsJSFunctions.js');
document.body.appendChild(s);

</script>
