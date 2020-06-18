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
public static void deleteNode(String filePath, List nodeList, String parentElementName) {
		try {
			SAXReader reader = new SAXReader();
			Document document = reader.read(new File(filePath));
			Element root = document.getRootElement();
			Element element = root.element(parentElementName);
			List<Element> eles = element.elements();
			for (Element ele : eles) {
				String name = ele.attributeValue("Name");
				Iterator iter = nodeList.iterator();
				while (iter.hasNext()) {
					String vName = (String) iter.next();
					if (vName.equals(name)) {
						ele.getParent().remove(ele);
					}
				}

			}

			FileOutputStream fos = new FileOutputStream(filePath);
			OutputFormat of = new OutputFormat(" ", false);
			of.setEncoding("UTF-8");
			XMLWriter xw = new XMLWriter(fos, of);
			xw.write(document);
			xw.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

%>
<%
	try
	{
		Context context = Framework.getFrameContext(session);
		String language = context.getSession().getLanguage();
		List nodeList = new ArrayList();
		String parentName = "";
	
		String[] emxTableRowIds = emxGetParameterValues(request, "emxTableRowId");
		if (emxTableRowIds != null && emxTableRowIds.length > 0)
		{
			for (int i = 0; i < emxTableRowIds.length; i++)
			{
				String rowId = emxTableRowIds[i];
				String[] sId = rowId.split("[|]");
			
				System.out.println(rowId+"----rowId");
				String objId = "";
				if (sId.length >= 2) {
					objId = sId[1];
				} else {
					objId = sId[0];
				}
				DomainObject dom = DomainObject.newInstance(context, objId);
				String name = dom.getInfo(context,"name");
				String type = dom.getInfo(context,"type");
				if("CSSCShipType".equals(type)){
					parentName ="ShipTypeList";
				
				}else if("CSSCScopeList".equals(type)){
					parentName ="ScopeList";
				}
				nodeList.add(name);
				
				dom.delete(context);
				
				
				
			}
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
				
				deleteNode(path + "/" + fileName, nodeList, parentName);
				bo.checkinFile(context, true, true, "", "generic", fileName, path);
			}
		}
		
	} catch (Exception e){
		e.printStackTrace();
	}
%>

<script language="javascript" type="text/javaScript">

	if (window.parent.location) {
		window.parent.location.href = window.parent.location.href;
	}

</script>