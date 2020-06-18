<%@page contentType="text/html;charset=utf-8"%>
<%@page
	import="com.matrixone.apps.domain.*,com.matrixone.apps.domain.util.*,matrix.util.*,matrix.db.Context,com.matrixone.servlet.Framework,com.matrixone.apps.framework.ui.UIUtil,matrix.db.Person,java.io.File"%>
<%@page
	import="java.util.*,java.text.SimpleDateFormat,java.math.BigDecimal,java.util.Calendar,java.text.*"%>
<%@include file="../common/emxUIConstantsInclude.inc"%>
<%@include file="../emxRequestWrapperMethods.inc"%>
<%@include file="../emxStyleDefaultInclude.inc"%>



<%!
	 public void deleteFolder(String path) throws Exception {

        File file = new File(path);
        if (file.isDirectory())
        {
            for (File child : file.listFiles())
            {
                deleteFolder(child.getAbsolutePath());
            }
            file.delete();
        }else{
            file.delete();
        }
    }
%>


<%
	Context context = Framework.getFrameContext(session);
	response.setContentType("text/html;charset=UTF-8");
	try{
			String tomcatPath = request.getSession().getServletContext().getRealPath("/")+"upload"; 
			System.out.println("tomcatPath-----------"+tomcatPath);
			String objectId = emxGetParameter(request,"objectId");
			if(UIUtil.isNullOrEmpty(objectId)){
				String [] ids = com.matrixone.apps.common.util.ComponentsUIUtil.getSplitTableRowIds((String[]) request.getParameterValues("emxTableRowId"));
				if(ids.length==1){
					objectId=ids[0];
				}else{
					%>
						<script>
							alert("请选择书签工作区后在导出工作区！");
						</script>
					<%
				}
	
			}
			HashMap<String, Object> programMap = new HashMap<String, Object>(3);
			programMap.put("objectId",objectId);
			programMap.put("tomcatPath",tomcatPath);
			Map resultMap = (Map)JPO.invoke(context, "CSICImportDesignStructure", new String [] { }, "exportWorkspace", JPO.packArgs(programMap),Map.class);
			String flag = (String)resultMap.get("flag");
			if("ERROR".equals(flag)){
			}else if("OK".equals(flag)){
			    String path = (String)resultMap.get("path");
				String fileName = (String)resultMap.get("fileName");
     			
				if(path!=null && path.length()>0){
					File filel = new File(path);
					long length = filel.length();
					StringBuffer sb = new StringBuffer(2048);
					sb.append("attachment;filename=");
					sb.append(fileName);
			
					response.setContentType("application/x-msdownload;charset=UTF-8");
					response.setHeader("Content-Disposition", new String(sb.toString().getBytes(), "ISO8859-1"));
					response.addHeader("Content-Length", length+"");
					out.clear();
					out = pageContext.pushBody();
					java.io.FileInputStream fis = new java.io.FileInputStream(path);
					System.out.println("path-------------"+path);
					java.io.BufferedOutputStream bos = new java.io.BufferedOutputStream(response.getOutputStream());
					byte[] buffer = new byte[2048];
					while (fis.read(buffer) != -1)
					{
						bos.write(buffer);
					}
					
					bos.close();
					fis.close();   
					if(path!=null && path.length()>0){
						//deleteFolder(path); 
					}
			    }
			}
	} catch(Exception e) {
		e.printStackTrace();
	}
%>

 <script language="javascript">
	window.top.opener.parent.opener.location.href = window.top.opener.parent.opener.location.href;
	window.top.opener.parent.close();
	window.close();
 </script>
