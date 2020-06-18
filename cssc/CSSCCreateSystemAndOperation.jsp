<%@page import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.common.Company,com.matrixone.apps.common.Person,com.matrixone.apps.program.Task"%>
<%@page
    import="java.util.Set,java.util.HashSet,java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*,com.matrixone.apps.framework.ui.UIUtil"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>
<%@page contentType="text/html;charset=utf-8"%>
<SCRIPT language="javascript" src="../common/scripts/emxUICore.js"></SCRIPT>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script src="../common/scripts/emxUIModal.js" type="text/javascript"></script>

<%!
	public  String getAsiccString(String str) {
		String resultString = "";
		try {
			if(UIUtil.isNotNullAndNotEmpty(str)) {
				char[] s=str.toCharArray();
				for(int o = 0;o<s.length;o++) {
					int value=Integer.valueOf(s[o]);
					resultString+=value;
				}
			}
			
		}catch(Exception e) {
			e.printStackTrace();
		}
		System.out.println("resultString---"+resultString);
		return resultString;
	}

%>
<%
	response.setContentType("text/html;charset=UTF-8");
	Context context = Framework.getFrameContext(session);
	
	String objectId = "";
	String taskName = "";
	String information = "";
	String fromId = "";
	String oid = "";
	String relId = "";
	String flag = "FALSE";
	DomainObject taskDom = DomainObject.newInstance(context);
	String portalCommandName = (String)emxGetParameter(request, "portalCmdName");
	portalCommandName = XSSUtil.encodeURLForServer(context, portalCommandName);
	StringBuilder sBuff = new StringBuilder();	
	try 
	{
		
		String selectType = request.getParameter("selectType");
		String[] emxTableRowId	= emxGetParameterValues(request, "emxTableRowId");
		if(emxTableRowId != null && emxTableRowId.length ==1)
		{
			String emxTableRowIds[] = emxTableRowId[0].split("\\|");
			objectId =  emxTableRowIds[1] ;
		} 
		fromId = objectId;
		taskDom.setId(objectId);
		String CSSCQuote = taskDom.getInfo(context,"attribute[CSSCQuote]");
		if("YES".equals(CSSCQuote)){
			
			PrintWriter printWrite = response.getWriter();
			printWrite.append("<script language=\"javascript\">");
			printWrite.append("alert('当前所选择节点为工艺知识库引用对象，不允许在其下创建子节点！');");
			printWrite.append("</script>");
			printWrite.flush();
			return;
		}
		String taskType = taskDom.getInfo(context, "type");
		System.out.println("taskType-----------"+taskType);
		String symbolicTypeName = PropertyUtil.getAliasForAdmin(context, "Type", "DELLmiGeneralSystemReference", true);
		String symbolicPolicyName = PropertyUtil.getAliasForAdmin(context, "Policy", "VPLM_SMB_Definition", true);
		String autoName = FrameworkUtil.autoName(context, symbolicTypeName, null, symbolicPolicyName, null, null, true, true);
		String orgId = getAsiccString("Global");
		String assemblyAutoName = "gsys-"+orgId+"-"+autoName;
		
		
		if(("General Library".equals(taskType)||"General Class".equals(taskType))&&selectType.equals("System")){
			System.out.println("assemblyAutoName-----------"+assemblyAutoName);
			BusinessObject bo = new BusinessObject("CSSCDELLmiGeneralSystemReference",assemblyAutoName, "A","eService Production");
			if(!bo.exists(context)) {
				bo.create(context,"Document Release");
				DomainObject dom  = DomainObject.newInstance(context);
				dom.setId(bo.getObjectId(context));
				dom.setAttributeValue(context, "CSSCVersion", "A.1");
				dom.connectFrom(context,"CSSCClassifiedItem", new DomainObject(objectId));
				oid = bo.getObjectId(context);
				relId = MqlUtil.mqlCommand(context,"print bus "+oid+" select to[CSSCClassifiedItem].id dump");
				
			}
			
		}else if(taskType.equals("CSSCDELLmiGeneralSystemReference")&&selectType.equals("System")){
			BusinessObject bo = new BusinessObject("CSSCDELLmiGeneralSystemReference",assemblyAutoName, "A","eService Production");
			if(!bo.exists(context)) {
				bo.create(context,"Document Release");
				DomainObject dom  = DomainObject.newInstance(context);
				dom.setId(bo.getObjectId(context));
				dom.setAttributeValue(context, "CSSCVersion", "A.1");
				dom.connectFrom(context,"CSSCDELLmiGeneralSystemInstance", new DomainObject(objectId));
				oid = bo.getObjectId(context);
				relId = MqlUtil.mqlCommand(context,"print bus "+oid+" select to[CSSCDELLmiGeneralSystemInstance].id dump");
				System.out.println("bo.getObjectId(context)----------1---------"+oid);
			}
		}else if(taskType.equals("CSSCDELLmiGeneralSystemReference")&&selectType.equals("Operation")){
			String user = context.getUser();
			String related  = MqlUtil.mqlCommand(context,"print bus "+objectId+" select to[CSSCClassifiedItem] dump");
			if("TRUE".equals(related)){
				String value = MqlUtil.mqlCommand(context,"print person "+user+" select property[CSSCConnectionObjFlag].value dump");
				if("YES".equals(value)){
					BusinessObject bo = new BusinessObject("CSSCDELLmiGeneralOperationReference",assemblyAutoName, "A","eService Production");
					if(!bo.exists(context)) {
						bo.create(context,"Document Release");
						DomainObject dom  = DomainObject.newInstance(context);
						dom.setId(bo.getObjectId(context));
						dom.setAttributeValue(context, "CSSCVersion", "A.1");
						dom.connectFrom(context,"CSSCDELLmiGeneralOperationInstance", new DomainObject(objectId));
						oid = bo.getObjectId(context);
						relId = MqlUtil.mqlCommand(context,"print bus "+oid+" select to[CSSCDELLmiGeneralOperationInstance].id dump");
					}
				}else{
					PrintWriter printWrite = response.getWriter();
					printWrite.append("<script language=\"javascript\">");
					printWrite.append("alert('顶级节点的DELLmiGeneralSystemReference类型对象下不允许创建DELLmiGeneralOperationReference类型对象!');");
					printWrite.append("</script>");
					printWrite.flush();
					return;
				}
			}else{
				BusinessObject bo = new BusinessObject("CSSCDELLmiGeneralOperationReference",assemblyAutoName, "A","eService Production");
					if(!bo.exists(context)) {
						bo.create(context,"Document Release");
						DomainObject dom  = DomainObject.newInstance(context);
						dom.setId(bo.getObjectId(context));
						dom.setAttributeValue(context, "CSSCVersion", "A.1");
						dom.connectFrom(context,"CSSCDELLmiGeneralOperationInstance", new DomainObject(objectId));
						oid = bo.getObjectId(context);
						relId = MqlUtil.mqlCommand(context,"print bus "+oid+" select to[CSSCDELLmiGeneralOperationInstance].id dump");
					}
			}
		}else if(taskType.equals("CSSCDELLmiGeneralOperationReference")&&selectType.equals("Operation")){
			System.out.println("++++++++++++++++++++++++++++++++++++++++++++");
			BusinessObject bo = new BusinessObject("CSSCDELLmiGeneralOperationReference",assemblyAutoName, "A","eService Production");
			if(!bo.exists(context)) {
				bo.create(context,"Document Release");
				DomainObject dom  = DomainObject.newInstance(context);
				dom.setId(bo.getObjectId(context));
				dom.setAttributeValue(context, "CSSCVersion", "A.1");
				dom.connectFrom(context,"CSSCDELLmiGeneralOperationInstance", new DomainObject(objectId));
				oid = bo.getObjectId(context);
				relId = MqlUtil.mqlCommand(context,"print bus "+oid+" select to[CSSCDELLmiGeneralOperationInstance].id dump");
			}
			
		}	
		

		
	
	if(UIUtil.isNotNullAndNotEmpty(oid)&&UIUtil.isNotNullAndNotEmpty(relId)&&UIUtil.isNotNullAndNotEmpty(fromId)){
		sBuff.append("<mxRoot>");
		sBuff.append("<action><![CDATA[add]]></action>");
		sBuff.append("<data status=\"committed\" ");
		sBuff.append(">");
		sBuff.append("<item oid=\"" + oid + "\" relId=\"" + relId + "\" pid=\"" + fromId			+ "\"  direction=\"" + "from" + "\" />");
		sBuff.append("</data>");
		sBuff.append("</mxRoot>");
		flag = "TRUE";
	}
	System.out.println("sBuff------------------"+sBuff);
	}catch(Exception e){
		e.printStackTrace();
	}	
	
%>
	

	<script type="text/javascript">
			var flag = "<%=flag%>";
			if(flag=='TRUE'){
				var frame = "<%=portalCommandName%>";
				var topFrame = findFrame(getTopWindow(), frame);
				
				topFrame.rebuildViewInProcess = true;
				topFrame.syncSBInProcess = true;
				topFrame.emxEditableTable.addToSelected('<%=sBuff.toString()%>');
				topFrame.rebuildViewInProcess = false;
				topFrame.syncSBInProcess = false;
				topFrame.emxEditableTable.refreshStructureWithOutSort();
			}else{
				window.parent.location.href=window.parent.location.href;
			}
		
	</script>
	
	

	