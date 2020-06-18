<%@page contentType="text/html;charset=utf-8"%>
<%@page
	import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.framework.ui.UIUtil,matrix.db.Person,java.io.File"%>
<%@page
	import="java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>


<%
	Context context = Framework.getFrameContext(session);
	String objectId=request.getParameter("objectId");
	String assemblyObjId = MqlUtil.mqlCommand(context,"print bus "+objectId+" select from[CSSCClassifiedItem].to.id dump");
	DomainObject dom = DomainObject.newInstance(context);
	
	if(assemblyObjId!=null && assemblyObjId.length()>0){
		System.out.println("assemblyObjId--------------------"+assemblyObjId);
		dom.setId(assemblyObjId);
		String parentName = dom.getInfo(context,"name");
		String title = dom.getInfo(context,"attribute[Title]");
		String vec = dom.getInfo(context,DomainObject.SELECT_DESCRIPTION);
		
		BusinessObject bo = new BusinessObject("CreateAssembly",parentName, "A.1","vplm");
			if(!bo.exists(context)) {
				bo.create(context,"VPLM_SMB_Definition");
				dom.setId(bo.getObjectId(context));
				
				dom.setAttributeValue(context, "PLMEntity.V_description", vec);
				dom.setAttributeValue(context, "PLMEntity.V_Name", title);
				dom.connectFrom(context,"Classified Item", new DomainObject(objectId));
				MqlUtil.mqlCommand(context,"modify bus "+bo.getObjectId(context)+" current IN_WORK");
			}
		
		String expandMQL = MqlUtil.mqlCommand(context, "expand bus " + assemblyObjId + "  from rel CSSCDELFmiFunctionIdentifiedInstance recurse  to all    select bus name id dump ]]");
		System.out.println("expandMQL------------"+expandMQL);
		if (UIUtil.isNotNullAndNotEmpty(expandMQL)) {
			String[] expandObjects = expandMQL.split("\n");

			for (int i = 0; i < expandObjects.length; i++) {
				String oid = expandObjects[i].split("]]")[7];
				dom.setId(oid);
				String name = dom.getInfo(context,"name");
				String title_ = dom.getInfo(context,"attribute[Title]");
				String fromId = MqlUtil.mqlCommand(context,"print bus "+oid+" select to[CSSCDELFmiFunctionIdentifiedInstance].from.id dump");
				System.out.println("fromId-------------"+fromId);
				String parentName_ = "";
				if(fromId!=null && fromId.length()>0){
					dom.setId(fromId);
					parentName_ = dom.getInfo(context,"name");
				}
				
				BusinessObject bos = new BusinessObject("CreateAssembly",name, "A.1","vplm");
				System.out.println("bos-------------");
				if(!bos.exists(context)) {
					bos.create(context,"VPLM_SMB_Definition");
					dom.setId(bos.getObjectId(context));
					dom.setAttributeValue(context, "PLMEntity.V_description", vec);
					dom.setAttributeValue(context, "PLMEntity.V_Name", title_);
					
					if(UIUtil.isNotNullAndNotEmpty(parentName_)){
						BusinessObject bos1 = new BusinessObject("CreateAssembly",parentName_, "A.1","vplm");
						if(bos1.exists(context)) {
							String id = bos1.getObjectId(context);
							System.out.println("dom---------"+dom);
							System.out.println("id----------"+id);
							dom.connectFrom(context,"DELFmiFunctionIdentifiedInstance", new DomainObject(id));
						}
					}
					MqlUtil.mqlCommand(context,"modify bus "+bos.getObjectId(context)+" current IN_WORK");
				}
				
			}
			
		}
		
	}
		String contextUser = context.getUser();
		ContextUtil.pushContext(context);
			StringList busSelects = new StringList();
			busSelects.add(DomainObject.SELECT_ID);
			MapList list = DomainObject.findObjects(context, "CSSCAssembly", "eService Production", "owner=='" + contextUser + "'", busSelects);
			System.out.println("list-------------------"+list);
			Iterator<Map<String, String>> iter = list.iterator();
			while (iter.hasNext()) {
				Map objMap = iter.next();
				String objId = (String) objMap.get(DomainObject.SELECT_ID);
				dom.setId(objId);
				if (dom.exists(context)) {
					dom.deleteObject(context);
				}
			}
			
			
		
		if(objectId!=null &&objectId.length()>0){
			ContextUtil.pushContext(context);
				StringList boselectList = new StringList();
				boselectList.add(DomainObject.SELECT_ID);
				boselectList.add(DomainObject.SELECT_NAME);
				boselectList.add(DomainObject.SELECT_TYPE);
				dom.setId(objectId);
				MapList dataList = dom.getRelatedObjects(context, "Subclass", "General Class,General Library", boselectList, null, true, false, (short) 0, "", "");
				if (dataList != null && dataList.size() > 0) {
					Iterator iters = dataList.iterator();
					while (iters.hasNext()) {
						Map dataMap = (Map) iters.next();
						String libType = (String) dataMap.get(DomainObject.SELECT_TYPE);
						String libId = (String) dataMap.get(DomainObject.SELECT_ID);
						if ("General Library".equals(libType)) {
							objectId = libId;
						} else {
							objectId = "";
						}
					}
				}
				ContextUtil.popContext(context);
				
				
				dom.setId(objectId);
			    String sType = dom.getInfo(context,"type");
				System.out.println("sType------------------------------------------"+sType);
				if("General Library".equals(sType)){
					HashMap paramMap = new HashMap();
					paramMap.put("objectId",objectId);
					String resultMap = (String)JPO.invoke(context, "CSSCSystemOperationJPO", new String [] { }, "createMIDModifyXML", JPO.packArgs(paramMap),String.class);  
				}
		}
		
		
		ContextUtil.popContext(context);
		
		
		
		
	
%>

 <script language="javascript">
		window.parent.location.href=window.parent.location.href;
 </script>	