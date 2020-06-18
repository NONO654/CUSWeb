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
<%!
public static List getNodes(String filePath,String elementName) {
		List dataList = new ArrayList();
		try {
			SAXReader reader = new SAXReader();
			Document document = reader.read(new File(filePath));
			Element root = document.getRootElement();
			Element element = root.element(elementName);
			List<Element> eles = element.elements();
			for (Element ele : eles) {
				String name = ele.attributeValue("Name");
				dataList.add(name);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dataList;
	}
%>
<%
	String type = (String)emxGetParameter(request,"type");
	try
	{
		String policy = "CSSCShipTypeScope";
		Context context = Framework.getFrameContext(session);
		
		String elementName = "";
		if(type.equals("CSSCShipType")){
			elementName = "ShipTypeList";
		}else{
			elementName = "ScopeList";
		}
		String urlPath = i18nNow.getI18nString("emxProgramCentral.URL", "emxProgramCentralStringResource", context.getLocale().getLanguage());
		String folder = System.nanoTime() + "";
		BusinessObject bo = new BusinessObject("Document", "ProcessKnowledgeShipTypeAndScope", "0", "eService Production");
		if (bo.exists(context)) {
			String fileName = MqlUtil.mqlCommand(context, "print bus " + bo.getObjectId(context) + " select format.file.name dump;");
			String path = urlPath + "/" + folder;
			File file = new File(path);
			if (!file.exists()) {
				file.mkdirs();
			}

			if (UIUtil.isNotNullAndNotEmpty(fileName)) {
				bo.checkoutFile(context, false, "generic", fileName, path);
				List dataList = getNodes(path+"/"+fileName,elementName);
				Iterator iter = dataList.iterator();
				while(iter.hasNext()){
					String name = (String)iter.next();
					BusinessObject bos = new BusinessObject(type, name, "-", "eService Production");
					if(!bos.exists(context)){
					
						bos.create(context,policy);
						DomainObject dom = DomainObject.newInstance(context,bos.getObjectId(context));
						dom.setAttributeValue(context,"Title", name);
					}
				}
			}
		}
		
	} catch (Exception e){
		e.printStackTrace();
	}
%>

<script language="javascript" type="text/javaScript">
	var typeName = "<%=type%>";
	if (window.parent.location) {
		if("CSSCShipType"==typeName){
			window.location.href = "../common/emxIndentedTable.jsp?table=CSSCShipTypeScopeTable&type=CSSCShipType&program=CSSCShipTypeAndScopeJPO:getScopeListData&editLink=true&toolbar=CSSCShipTypeScopeToolbar&selection=multiple";
		}else if("CSSCScopeList"==typeName){
			window.location.href = "../common/emxIndentedTable.jsp?table=CSSCShipTypeScopeTable&type=CSSCScopeList&program=CSSCShipTypeAndScopeJPO:getScopeListData&editLink=true&toolbar=CSSCScopeToolbar&selection=multiple";
		}
	}

</script>