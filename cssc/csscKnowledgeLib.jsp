<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ page import="java.util.Map.Entry,
				 java.util.Iterator,
				 java.util.List,
				 java.util.HashMap,
				 matrix.util.UUID,
				 matrix.db.RelationshipType,
				 com.matrixone.servlet.Framework,
				 matrix.db.Context,
				 com.matrixone.apps.domain.DomainObject,
				 com.matrixone.apps.domain.util.PersonUtil,
				 matrix.util.MatrixException,
				 com.matrixone.apps.domain.util.ContextUtil,
				 com.matrixone.apps.domain.util.FrameworkException,
				 com.matrixone.apps.domain.util.MqlUtil,
				 com.matrixone.apps.domain.util.ContextUtil,
				 com.matrixone.apps.domain.DomainRelationship,
				 com.matrixone.apps.domain.util.i18nNow,
				 java.io.File,
				 com.matrixone.apps.framework.ui.UIUtil,
				 com.matrixone.apps.common.CommonDocument,org.dom4j.Document,org.dom4j.DocumentException,org.dom4j.Element,org.dom4j.io.OutputFormat,org.dom4j.io.SAXReader,org.dom4j.io.XMLWriter"%>

<%@include file="../emxRequestWrapperMethods.inc"%>
<%
Context context = Framework.getFrameContext(session);
ContextUtil.pushContext(context);
MapList libList = DomainObject.findObjects(context, "General Library", "eService Production", "name=='\u5de5\u827a\u77e5\u8bc6\u5e93'", new StringList(DomainObject.SELECT_ID));
String libId  = "";
if(libList!=null &&libList.size()>0){
libId = (String) ((Map) libList.get(0)).get(DomainObject.SELECT_ID);
}
System.out.println("libId----------------"+libId);
ContextUtil.popContext(context);
%>


<script language="javascript" type="text/javaScript">
	var libId = "<%=libId%>";
	if(libId!=null&&libId!=""){
		window.location.href = "../common/emxIndentedTable.jsp?selection=multiple&isAddExisting=true&HelpMarker=emxhelpselectorganization&header=emxComponentsCentral.Common.SelectRegion&suiteKey=Components&table=CSSCShowLibTable&expandProgram=CSSCGetResources:getExpandResources&findMxLink=false&massPromoteDemote=false&customize=false&showRMB=false&showClipboard=false&objectCompare=false&objectId="+libId;
	}else{
		alert("未查找到工艺知识库！");
	}
	

</script>