<%@page contentType="text/html;charset=utf-8"%>
<%@page
	import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.framework.ui.UIUtil,matrix.db.Person,java.io.File"%>
<%@page
	import="java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*,java.io.PrintWriter"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>


<%
	response.setContentType("text/html; charset=utf-8");
	Context context = Framework.getFrameContext(session);
	String selectId = request.getParameter("selectId");
	System.out.println("selectId-------|||||||||||||||||||||||||||||||||||||||------"+selectId);
	
	String oid = request.getParameter("oid");
	if (UIUtil.isNotNullAndNotEmpty(selectId)) {
			
			DomainObject dom = DomainObject.newInstance(context);
			dom.setId(selectId);
			String   CSSCQuote_ = dom.getInfo(context,"attribute[CSSCQuote]");
			String type = dom.getInfo(context,DomainObject.SELECT_TYPE);
			
			if(!"CSSCDELLmiGeneralSystemReference".equals(type)) {
				//报错
				PrintWriter printWrite= response.getWriter();
				printWrite.append("<script language=\"javascript\">");
				printWrite.append("alert('当前所选择节点必须为DELLmiGeneralSystemReference类型！');");
				printWrite.append("</script>");
				printWrite.flush();
				return;
			}else if("CSSCDELLmiGeneralSystemReference".equals(type)&&"YES".equals(CSSCQuote_)){
				
				PrintWriter printWrite= response.getWriter();
				printWrite.append("<script language=\"javascript\">");
				printWrite.append("alert('当前所选择节点为工艺知识库引用对象，不允许多次引用！');");
				printWrite.append("</script>");
				printWrite.flush();
				return;
				
			}else {
				
				if(UIUtil.isNotNullAndNotEmpty(oid)) {
				String oids[] = oid.split("]]");
				for(int i = 0;i<oids.length;i++) {
					if(UIUtil.isNullOrEmpty(oids[i])){
						continue;
					}
					//引用库所选择的System
					String id = oids[1].split("\\|")[1];
					if(UIUtil.isNotNullAndNotEmpty(id)) {
						ContextUtil.pushContext(context);
						dom.setId(id);
						String systemName = dom.getInfo(context,DomainObject.SELECT_NAME);
						String systemVName = dom.getInfo(context,"attribute[PLMEntity.V_Name]");
						String systemType = dom.getInfo(context,DomainObject.SELECT_TYPE);
						String systemVer = dom.getInfo(context,DomainObject.SELECT_REVISION);
						ContextUtil.popContext(context);
						if(!"DELLmiGeneralSystemReference".equals(systemType)){
							//报错所选择引用节点必须是System类型
							PrintWriter printWrite = response.getWriter();
				            printWrite.append("<script language=\"javascript\">");
				            printWrite.append("alert('所选择引用节点必须是DELLmiGeneralSystemReference类型！');");
				            printWrite.append("</script>");
				            printWrite.flush();
							return;
						}else {
							//迭代system获取子节点
							String systemId = "";
							BusinessObject bo = new BusinessObject("CSSCDELLmiGeneralSystemReference",systemName,"A","eService Production");
							if(!bo.exists(context)) {
								bo.create(context,"Document Release");
								bo.setAttributeValue(context, "Title", systemVName);
								bo.setAttributeValue(context,"CSSCID", id);
								bo.setAttributeValue(context,"CSSCQuote", "YES");
								bo.setAttributeValue(context, "CSSCVersion", systemVer);
								bo.setAttributeValue(context, "CSSCQueFlag", "YES");
								systemId = bo.getObjectId(context);
								dom.setId(systemId);
								dom.connectFrom(context,"CSSCDELLmiGeneralSystemInstance", new DomainObject(selectId));
							}else {
								ContextUtil.pushContext(context);
								systemId = bo.getObjectId(context);
								dom.setId(selectId);
								
								String CSSCQuote = dom.getInfo(context,"attribute[CSSCQuote]");
								if("NO".equals(CSSCQuote)||"".equals(CSSCQuote)){
									dom.setId(systemId);
									dom.connectFrom(context,"CSSCDELLmiGeneralSystemInstance", new DomainObject(selectId));
								}
								ContextUtil.popContext(context);
							}
							
							
							StringList boSelects = new StringList(DomainObject.SELECT_ID);
							boSelects.add(DomainObject.SELECT_NAME);
							boSelects.add("attribute[PLMEntity.V_Name]");
							ContextUtil.pushContext(context);
							dom.setId(id);
							MapList routeList = dom.getRelatedObjects(context, "DELLmiGeneralOperationInstance", "DELLmiGeneralOperationReference", boSelects, null, false, true, (short)1, "", "");
							ContextUtil.popContext(context);
							System.out.println("routeList-------------------"+routeList);
							Iterator iter = routeList.iterator();
							while(iter.hasNext()) {
								Map dataMap = (Map)iter.next();
								String operationId = (String)dataMap.get(DomainObject.SELECT_ID);
								String operationName = (String)dataMap.get(DomainObject.SELECT_NAME);
								String operationVName = (String)dataMap.get("attribute[PLMEntity.V_Name]");
								String operationRevision = (String)dataMap.get(DomainObject.SELECT_REVISION);
								
								
								BusinessObject bos = new BusinessObject("CSSCDELLmiGeneralOperationReference",operationName,"A","eService Production");
								if(!bos.exists(context)) {
									bos.create(context,"Document Release");
									bos.setAttributeValue(context, "Title", operationVName);
									bos.setAttributeValue(context,"CSSCID", id);
									bos.setAttributeValue(context,"CSSCQuote", "YES");
									bos.setAttributeValue(context, "CSSCVersion", operationRevision);
									bo.setAttributeValue(context, "CSSCQueFlag", "YES");
									dom.setId(bos.getObjectId(context));
									dom.connectFrom(context,"CSSCDELLmiGeneralOperationInstance", new DomainObject(systemId));
								}else {
									ContextUtil.pushContext(context);
									System.out.println("--------------------------------------********************************");
									StringList dataList = new StringList();
									String operId =  bos.getObjectId(context);
									dom.setId(operId);
									String CSSCQuote = dom.getInfo(context,"attribute[CSSCQuote]");
									if("NO".equals(CSSCQuote)||"".equals(CSSCQuote)){
										dom.connectFrom(context, "CSSCDELLmiGeneralOperationInstance",  new DomainObject(systemId));
										
									}
									ContextUtil.popContext(context);
								}
							}
						}
					
					}
				}
			 }
			}
			
		}
	
%>

<script type="text/javascript">
			window.parent.location.href = window.parent.location.href;
		
</script>
