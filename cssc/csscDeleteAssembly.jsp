<%@page contentType="text/html;charset=utf-8"%>
<%@page
	import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.framework.ui.UIUtil,matrix.db.Person,java.io.File"%>
<%@page
	import="java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*,java.io.PrintWriter,com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>


<%
	System.out.println("Delete page--------------->>>");
	response.setContentType("text/html; charset=utf-8");
	Context context = Framework.getFrameContext(session);
	DomainObject dom = DomainObject.newInstance(context);
	String result = "OK";
	try{
	ContextUtil.pushContext(context);
	
		String [] ids = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
		if(ids!=null &&ids.length>0){
			for(int i = 0;i<ids.length;i++){
				String objectId = ids[i];
				
				
				dom.setId(objectId);
				String type = dom.getInfo(context,DomainObject.SELECT_TYPE);
				if("General Class".equals(type)||"General Library".equals(type)){
					PrintWriter printWrite = response.getWriter();
					printWrite.append("<script language=\"javascript\">");
					printWrite.append("alert('不允许删除库节点！');");
					printWrite.append("</script>");
					printWrite.flush();
					return;
				}
					String CMD = MqlUtil.mqlCommand(context,"expand bus " + objectId + " from rel 'CSSCDELFmiFunctionIdentifiedInstance'  recurse  to all    select bus  id dump ,");
					System.out.println("CMD--------------------------"+CMD);
					StringList subvaultList = FrameworkUtil.split(CMD, "\n");
						Iterator iterator = subvaultList.iterator();
						while (iterator.hasNext()) {
							String subvault = (String) iterator.next();
							String[] vaults = subvault.split(",");
							String id = vaults[6];
							dom.setId(id);
								if(dom.exists(context)){
									MqlUtil.mqlCommand(context,"delete bus "+id);
								}
							
						}
							dom.setId(objectId);
							if(dom.exists(context)){
								MqlUtil.mqlCommand(context,"delete bus "+objectId);
							}
					
				
			}
		}else{
			System.out.println("ids.length is empty--------------");
		}
	ContextUtil.popContext(context);
	}catch(Exception e){
			result = "";
			e.printStackTrace();
	}

	
%>

<script type="text/javascript">
			var result = "<%=result%>";
			if(result==""){
				alert("系统异常！");
			}
			window.parent.location.href=window.parent.location.href;
</script>
