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
	String[]  strSelectedCollections = FrameworkUtil.getSplitTableRowIds(emxGetParameterValues(request,"emxTableRowId"));
	try{
			for(int i = 0;i<strSelectedCollections.length;i++){
			DomainObject dom = DomainObject.newInstance(context);
			String objectId = strSelectedCollections[i];
			dom.setId(objectId);
			String parentCurrent = dom.getInfo(context,"current");
			System.out.println("parentCurrent----------"+parentCurrent);
			if("Inactive".equals(parentCurrent)){
				dom.promote(context);
			}
			String cmdMQL = "expand bus " + objectId + " from  rel Subclass   recurse  to all   select bus id current dump ]];";
			String resultBUS = MqlUtil.mqlCommand(context, cmdMQL);
			if (UIUtil.isNotNullAndNotEmpty(resultBUS)) {
						StringList objects = FrameworkUtil.split(resultBUS, "\n");
						Iterator iter = objects.iterator();
						ContextUtil.pushContext(context);
						while (iter.hasNext()) {
							String itemd = (String) iter.next();
							String[] items = itemd.split("]]");
							String oid = items[6];
							String current = items[7];
							System.out.println("current----------"+current);
							if(oid!=null && oid.length()>0){
								if("Inactive".equals(current)){
									dom.setId(oid);
									dom.promote(context);
								}
							}
						}
						ContextUtil.popContext(context);
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
