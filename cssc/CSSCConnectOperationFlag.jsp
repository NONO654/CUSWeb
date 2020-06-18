<%@page contentType="text/html;charset=utf-8"%>
<%@page
	import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.framework.ui.UIUtil,matrix.db.Person,java.io.File"%>
<%@page
	import="java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*,java.io.PrintWriter,com.matrixone.apps.domain.util.FrameworkUtil"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>


<%
	response.setContentType("text/html; charset=utf-8");
	Context context = Framework.getFrameContext(session);
	
	
		String [] ids = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
		if(ids!=null){
			if(ids.length>1){
				PrintWriter printWrite = response.getWriter();
				printWrite.append("<script language=\"javascript\">");
				printWrite.append("alert('请选择对象！');");
				printWrite.append("</script>");
				printWrite.flush();
				return;
			}else if(ids.length<1){
				PrintWriter printWrite = response.getWriter();
				printWrite.append("<script language=\"javascript\">");
				printWrite.append("alert('只允许选择一个对象！');");
				printWrite.append("</script>");
				printWrite.flush();
				return;
			}else if(ids.length==1){
				String objectId = ids[0];
				if(objectId!=null && objectId.length()>0){
					String type = MqlUtil.mqlCommand(context,"print bus "+objectId+" select type dump");
					if("!CSSCDELLmiGeneralSystemReference".equals(type)){
						PrintWriter printWrite = response.getWriter();
						printWrite.append("<script language=\"javascript\">");
						printWrite.append("alert('请选择DELLmiGeneralSystemReference类型对象！');");
						printWrite.append("</script>");
						printWrite.flush();
						return;
					}
					
					String related  = MqlUtil.mqlCommand(context,"print bus "+objectId+" select to[CSSCClassifiedItem] dump");
					if("FALSE".equals(related)){
						PrintWriter printWrite = response.getWriter();
						printWrite.append("<script language=\"javascript\">");
						printWrite.append("alert('请选择顶级节点的DELLmiGeneralSystemReference类型对象！');");
						printWrite.append("</script>");
						printWrite.flush();
						return;
					}
					
					String user = context.getUser();
					ContextUtil.pushContext(context);	
					System.out.println("user----------xxxxxxxxxxxxxxxxx--------------"+user);
					String value = MqlUtil.mqlCommand(context,"print person "+user+" select property[CSSCConnectionObjFlag].value dump");
					if(value==null||value.length()==0){
						MqlUtil.mqlCommand(context,"modify person "+user+" add property CSSCConnectionObjFlag");
						MqlUtil.mqlCommand(context,"modify person "+user+"  property CSSCConnectionObjFlag value YES;");
					}else if("YES".equals(value)){
						PrintWriter printWrite = response.getWriter();
						printWrite.append("<script language=\"javascript\">");
						printWrite.append("alert('已关闭！');");
						printWrite.append("</script>");
						printWrite.flush();
						
						MqlUtil.mqlCommand(context,"modify person "+user+"  property CSSCConnectionObjFlag value NO;");
					}else if("NO".equals(value)){
						PrintWriter printWrite = response.getWriter();
						printWrite.append("<script language=\"javascript\">");
						printWrite.append("alert('已开启！');");
						printWrite.append("</script>");
						printWrite.flush();
						MqlUtil.mqlCommand(context,"modify person "+user+"  property CSSCConnectionObjFlag value YES;");
					}
					ContextUtil.popContext(context);	
				}
			}
		}
	
	
%>


