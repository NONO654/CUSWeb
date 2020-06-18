
<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../emxUICommonHeaderBeginInclude.inc" %>
<%@ page import = "com.matrixone.apps.domain.DomainObject,com.matrixone.apps.domain.util.*"%>

<%!
    static String appDirectory = null;
    static String suiteDir = "";
    private static synchronized void init(HttpSession session) throws matrix.util.MatrixException, FrameworkException, Exception {
		if (suiteDir == null || "".equals(suiteDir) || "null".equals(suiteDir) ) {
			matrix.db.Context utilContext = Framework.getFrameContext(session);
			try {
				suiteDir = FrameworkProperties.getProperty(utilContext,"eServiceSuiteComponents.Directory");
				appDirectory = FrameworkProperties.getProperty(utilContext,"eServiceSuiteComponents.Directory");
			} finally {
				utilContext.shutdown();
			}
		}
	}
%>
<%
  String objectId = emxGetParameter(request, "objectId");  
  if( objectId != null)
  {
    try
    {
		String retVal = null;
		String errorMsg = null;
		
		Map argsHash = new HashMap();
		argsHash.put("objectId", objectId);
			
		String[] args = JPO.packArgs(argsHash);
			
		retVal =(String) JPO.invoke(context, "emxParameter", null, "createMajorRevision", args, String.class);
		if (retVal != null) {
			// Message processing for eliminating exceptions of the type : java.lang.Exception: Message:No toconnect access to business object 'PlmParameter PlmParameter-0000101 A' Severity:2 ErrorCode:1500028
					
			errorMsg = retVal;
					
			if(errorMsg.contains("java.lang.Exception:")){
				errorMsg = errorMsg.replaceAll("java.lang.Exception:","");
			}
					
			if(errorMsg.contains("Message:")){
				errorMsg = errorMsg.replaceAll("Message:","");
			}
					
			if(errorMsg.contains("Severity")){
				int i = errorMsg.indexOf("Severity");
				errorMsg = errorMsg.substring(0,i-1);
			}
%>
			<script>
				alert("<%= errorMsg %>");
			</script>
<%
		} else {
		}	
    } catch (Exception ex) {
		session.setAttribute("error.message" , ex.toString());
    }
  }
%>
<html>
<body>
	<script src="../common/scripts/emxUICore.js" type="text/javascript"></script>
	<script language="JavaScript" src="../common/scripts/emxUIConstants.js" type="text/javascript"></script>
	<script language="JavaScript" src="../common/scripts/emxUIUtility.js" type="text/javascript"></script>
	<script src="../webapps/AmdLoader/AmdLoader.js"></script>
	<script type="text/javascript">window.dsDefaultWebappsBaseUrl = "../webapps/";</script>
	<script src="../webapps/WebappsUtils/WebappsUtils.js"></script>
	<script language="Javascript" >
		var frameContent = findFrame(getTopWindow(), "detailsDisplay");
		var contentFrame = findFrame(getTopWindow(), "content");
		var contTree = contentFrame.objDetailsTree;
		if (contTree == null) {
			if (frameContent.editableTable !=null&&frameContent.emxEditableTable!=null) {
				frameContent.editableTable.loadData();
				frameContent.emxEditableTable.refreshStructureWithOutSort();
			} else {
	  			refreshTablePage();
			}
		} else {
			var node = contTree.getSelectedNode().parent;
			if ( contentFrame != null && node != null && this.name != "listHidden") {
				if (getTopWindow().addContextTreeNode) {
				  getTopWindow().addContextTreeNode('<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>', node.nodeID, '<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>');
				} else {
				  contentFrame.addContextTreeNode('<xss:encodeForJavaScript><%=objectId%></xss:encodeForJavaScript>', node.nodeID, '<xss:encodeForJavaScript><%=appDirectory%></xss:encodeForJavaScript>');
				}
			} else {
				frameContent.document.location.href = frameContent.document.location.href;
			}
		}
	</script>
</body>
</html>
