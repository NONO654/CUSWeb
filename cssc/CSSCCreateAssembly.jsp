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
		String[] emxTableRowId	= emxGetParameterValues(request, "emxTableRowId");
		if(emxTableRowId != null && emxTableRowId.length ==1)
		{
			String emxTableRowIds[] = emxTableRowId[0].split("\\|");
			objectId =  emxTableRowIds[1] ;
		} 
		taskDom.setId(objectId);
		String taskType = taskDom.getInfo(context, "type");
		String symbolicTypeName = PropertyUtil.getAliasForAdmin(context, "Type", "CreateAssembly", true);
		String symbolicPolicyName = PropertyUtil.getAliasForAdmin(context, "Policy", "VPLM_SMB_Definition", true);
		String autoName =  System.nanoTime()+"";//FrameworkUtil.autoName(context, symbolicTypeName, null, symbolicPolicyName, null, null, true, true);
		String orgId = getAsiccString("Global");
		String assemblyAutoName = "mass-"+orgId+"-"+autoName;
		if("CSSCAssembly".equals(taskType)){
			BusinessObject bo = new BusinessObject("CSSCAssembly",assemblyAutoName, "A","eService Production");
			if(!bo.exists(context)) {
				bo.create(context,"Document Release");
				DomainObject dom  = DomainObject.newInstance(context);
				dom.setId(bo.getObjectId(context));
				dom.connectFrom(context,"CSSCDELFmiFunctionIdentifiedInstance", new DomainObject(objectId));
			}
		}else{
			BusinessObject bo = new BusinessObject("CSSCAssembly",assemblyAutoName, "A","eService Production");
			if(!bo.exists(context)) {
				bo.create(context,"Document Release");
				DomainObject dom  = DomainObject.newInstance(context);
				dom.setId(bo.getObjectId(context));
				dom.connectFrom(context,"CSSCClassifiedItem", new DomainObject(objectId));
			}
		}
	}catch(Exception e){
		e.printStackTrace();
	}	
		
%>
	

	<script type="text/javascript">
			window.parent.location.href=window.parent.location.href;
		
	</script>
	
	

	