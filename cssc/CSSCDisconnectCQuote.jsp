<%@page contentType="text/html;charset=utf-8"%>
<%@page
	import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.framework.ui.UIUtil,matrix.db.Person,java.io.File"%>
<%@page
	import="java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*,java.io.PrintWriter,com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>
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
	response.setContentType("text/html; charset=utf-8");
	Context context = Framework.getFrameContext(session);
	
	ContextUtil.pushContext(context);
		String [] ids = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
		for(int i = 0;i<ids.length;i++){
			String objectId = ids[i];
			System.out.println("objectId--------------------------"+objectId);
			DomainObject dom = DomainObject.newInstance(context);
			dom.setId(objectId);
			String type = dom.getInfo(context,DomainObject.SELECT_TYPE);
			if(!"CSSCDELLmiGeneralSystemReference".equals(type)){
				PrintWriter printWrite = response.getWriter();
				printWrite.append("<script language=\"javascript\">");
				printWrite.append("alert('请选择DELLmiGeneralSystemReference类型对象！');");
				printWrite.append("</script>");
				printWrite.flush();
				return;
			}
				
			
				String CMD = MqlUtil.mqlCommand(context,"expand bus " + objectId + " from rel 'CSSCDELLmiGeneralOperationInstance,CSSCDELLmiGeneralSystemInstance'  recurse  to all    select bus  id dump ,");
				System.out.println("CMD--------------------------"+CMD);
				StringList subvaultList = FrameworkUtil.split(CMD, "\n");
					Iterator iterator = subvaultList.iterator();
					while (iterator.hasNext()) {
						String subvault = (String) iterator.next();
						String[] vaults = subvault.split(",");
						String id = vaults[6];
						dom.setId(id);
						dom.setAttributeValue(context,"CSSCQuote", "NO");
						ContextUtil.pushContext(context);
							String symbolicTypeName = PropertyUtil.getAliasForAdmin(context, "Type", "DELLmiGeneralSystemReference", true);
							String symbolicPolicyName = PropertyUtil.getAliasForAdmin(context, "Policy", "VPLM_SMB_Definition", true);
							String autoName = FrameworkUtil.autoName(context, symbolicTypeName, null, symbolicPolicyName, null, null, true, true);
							String orgId = getAsiccString("Global");
							String assemblyAutoName = "gsys-"+orgId+"-"+autoName;
							dom.setName(context, assemblyAutoName);
						ContextUtil.popContext(context);
					}
					dom.setId(objectId);
					String symbolicTypeName = PropertyUtil.getAliasForAdmin(context, "Type", "DELLmiGeneralSystemReference", true);
					String symbolicPolicyName = PropertyUtil.getAliasForAdmin(context, "Policy", "VPLM_SMB_Definition", true);
					String autoName = FrameworkUtil.autoName(context, symbolicTypeName, null, symbolicPolicyName, null, null, true, true);
					String orgId = getAsiccString("Global");
					String assemblyAutoName = "gsys-"+orgId+"-"+autoName;
					ContextUtil.pushContext(context);
					dom.setAttributeValue(context,"CSSCQuote", "NO");
					dom.setAttributeValue(context,"CSSCID", "");
				
					dom.setName(context, assemblyAutoName);
					ContextUtil.popContext(context);
					
				
			}
		
	ContextUtil.popContext(context);

	
%>


