<%@page import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.common.Company,com.matrixone.apps.common.Person,com.matrixone.apps.program.Task"%>
<%@page
    import="java.util.Set,java.util.HashSet,java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*,com.matrixone.apps.framework.ui.UIUtil"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>
<%@page contentType="text/html;charset=utf-8"%>
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
	DomainObject taskDom = DomainObject.newInstance(context);
	
	try 
	{
		String selectType = request.getParameter("selectType");
		String[] emxTableRowId	= emxGetParameterValues(request, "emxTableRowId");
		if(emxTableRowId != null && emxTableRowId.length ==1)
		{
			String emxTableRowIds[] = emxTableRowId[0].split("\\|");
			objectId =  emxTableRowIds[1] ;
		} 
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
				dom.connectFrom(context,"CSSCClassifiedItem", new DomainObject(objectId));
				
			}
			
		}else if(taskType.equals("CSSCDELLmiGeneralSystemReference")&&selectType.equals("System")){
			BusinessObject bo = new BusinessObject("CSSCDELLmiGeneralSystemReference",assemblyAutoName, "A","eService Production");
			if(!bo.exists(context)) {
				bo.create(context,"Document Release");
				DomainObject dom  = DomainObject.newInstance(context);
				dom.setId(bo.getObjectId(context));
				System.out.println("bo.getObjectId(context)----------1---------"+bo.getObjectId(context));
				dom.connectFrom(context,"CSSCDELLmiGeneralSystemInstance", new DomainObject(objectId));
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
						dom.connectFrom(context,"CSSCDELLmiGeneralOperationInstance", new DomainObject(objectId));
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
						dom.connectFrom(context,"CSSCDELLmiGeneralOperationInstance", new DomainObject(objectId));
					}
			}
		}else if(taskType.equals("CSSCDELLmiGeneralOperationReference")&&selectType.equals("Operation")){
			System.out.println("++++++++++++++++++++++++++++++++++++++++++++");
			BusinessObject bo = new BusinessObject("CSSCDELLmiGeneralOperationReference",assemblyAutoName, "A","eService Production");
			if(!bo.exists(context)) {
				bo.create(context,"Document Release");
				DomainObject dom  = DomainObject.newInstance(context);
				dom.setId(bo.getObjectId(context));
				dom.connectFrom(context,"CSSCDELLmiGeneralOperationInstance", new DomainObject(objectId));
			}
			
		}	
		

		
	
	
	}catch(Exception e){
		e.printStackTrace();
	}	
		
%>
	

	<script type="text/javascript">
			window.parent.location.href=window.parent.location.href;
		
	</script>
	
	

	