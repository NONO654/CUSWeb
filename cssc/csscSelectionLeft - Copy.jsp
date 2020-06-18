<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<%@ page pageEncoding="UTF-8"%>
<%@ page import="java.util.Map.Entry,
				 java.util.Iterator,
				 java.util.List,
				 java.util.ArrayList,
				 matrix.db.Context,
				 java.util.HashMap,
				 matrix.util.UUID,
				 matrix.db.BusinessObject,
				 matrix.db.RelationshipType,
				 com.matrixone.servlet.Framework,
				 matrix.db.Context,
				 com.matrixone.apps.domain.DomainObject,
				 com.matrixone.apps.domain.util.PersonUtil,
				 matrix.util.MatrixException,
				 com.matrixone.apps.domain.util.ContextUtil,
				 com.matrixone.apps.domain.util.FrameworkException,
				 com.matrixone.apps.domain.util.MqlUtil,
				 com.matrixone.apps.domain.util.ContextUtil,
				 com.matrixone.apps.domain.DomainRelationship,
				 com.matrixone.apps.domain.util.i18nNow,
				 java.io.File, java.util.regex.Matcher,java.util.regex.Pattern,net.sourceforge.pinyin4j.PinyinHelper,net.sourceforge.pinyin4j.format.HanyuPinyinOutputFormat,net.sourceforge.pinyin4j.format.HanyuPinyinToneType,com.matrixone.apps.framework.ui.UIUtil,com.matrixone.apps.common.CommonDocument,org.dom4j.Document,org.dom4j.DocumentException,org.dom4j.Element,org.dom4j.io.OutputFormat,org.dom4j.io.SAXReader,org.dom4j.io.XMLWriter"%>
<%!
	public static List getNodes(String filePath,String elementName) {
		List dataList = new ArrayList();
		try {
			SAXReader reader = new SAXReader();
			Document document = reader.read(new File(filePath));
			Element root = document.getRootElement();
			Element element = root.element(elementName);
			List<Element> eles = element.elements();
			for (Element ele : eles) {
				String name = ele.attributeValue("Name");
				dataList.add(name);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return dataList;
	}
	
	
	 /**
     *  获取汉字首字母或全拼大写字母
     *
     * @param chinese 汉字
     * @param isFull  是否全拼 true:表示全拼 false表示：首字母
     *
     * @return 全拼或者首字母大写字符窜
     */
    public static String getUpperCase(String chinese,boolean isFull){
        return convertHanzi2Pinyin(chinese,isFull).toUpperCase();
    }

    /**
     * 获取汉字首字母或全拼小写字母
     *
     * @param chinese 汉字
     * @param isFull 是否全拼 true:表示全拼 false表示：首字母
     *
     * @return 全拼或者首字母小写字符窜
     */
    public static  String getLowerCase(String chinese,boolean isFull){
        return convertHanzi2Pinyin(chinese,isFull).toLowerCase();
    }

    /**
     * 将汉字转成拼音
     * <P>
     * 取首字母或全拼
     *
     * @param hanzi 汉字字符串
     * @param isFull 是否全拼 true:表示全拼 false表示：首字母
     *
     * @return 拼音
     */
    private static String convertHanzi2Pinyin(String hanzi,boolean isFull){
        /***
         * ^[\u2E80-\u9FFF]+$ 匹配所有东亚区的语言
         * ^[\u4E00-\u9FFF]+$ 匹配简体和繁体
         * ^[\u4E00-\u9FA5]+$ 匹配简体
         */
        String regExp="^[\u4E00-\u9FFF]+$";
        StringBuffer sb=new StringBuffer();
        if(hanzi==null||"".equals(hanzi.trim())){
            return "";
        }
        String pinyin="";
        for(int i=0;i<hanzi.length();i++){
            char unit=hanzi.charAt(i);
            //是汉字，则转拼音
            if(match(String.valueOf(unit),regExp)){
                pinyin=convertSingleHanzi2Pinyin(unit);
                if(isFull){
                    sb.append(pinyin);
                }
                else{
                    sb.append(pinyin.charAt(0));
                }
            }else{
                sb.append(unit);
            }
        }
        return sb.toString();
    }

    /**
     * 将单个汉字转成拼音
     *
     * @param hanzi 汉字字符
     *
     * @return 拼音
     */
    private static String convertSingleHanzi2Pinyin(char hanzi){
        HanyuPinyinOutputFormat outputFormat = new HanyuPinyinOutputFormat();
        outputFormat.setToneType(HanyuPinyinToneType.WITHOUT_TONE);
        String[] res;
        StringBuffer sb=new StringBuffer();
        try {
            res = PinyinHelper.toHanyuPinyinStringArray(hanzi,outputFormat);
            sb.append(res[0]);//对于多音字，只用第一个拼音
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
        return sb.toString();
    }

    /***
     * 匹配
     * <P>
     * 根据字符和正则表达式进行匹配
     *
     * @param str 源字符串
     * @param regex 正则表达式
     *
     * @return true：匹配成功  false：匹配失败
     */
    private static boolean match(String str,String regex){
        Pattern pattern=Pattern.compile(regex);
        Matcher matcher=pattern.matcher(str);
        return matcher.find();
    }

    /**
     * 测试方法
     */
    public static void main(String[] args) {
        System.out.println(convertHanzi2Pinyin("弗格森的广东省",false).toUpperCase());
    }
%>
<%
		Context context = Framework.getFrameContext(session);
		String objectId=request.getParameter("objectId");
	
		String urlPath = request.getSession().getServletContext().getRealPath("/") ;
		String ids[] = objectId.split(",");
		urlPath=urlPath+"upload/";
		System.out.println(urlPath);
		context = Framework.getFrameContext(session);
		
		
		
		
		
		List shipList = new ArrayList();
		List scopeList = new ArrayList();
	
		String folder = System.nanoTime() + "";
		ContextUtil.pushContext(context);
		BusinessObject bo = new BusinessObject("Document", "ProcessKnowledgeShipTypeAndScope", "0", "eService Production");
		if (bo.exists(context)) {
			
			String fileName = MqlUtil.mqlCommand(context, "print bus " + bo.getObjectId(context) + " select format.file.name dump;");
			String path = urlPath + "/" + folder;
			File file = new File(path);
			if (!file.exists()) {
				file.mkdirs();
			}

			if (UIUtil.isNotNullAndNotEmpty(fileName)) {
				bo.checkoutFile(context, false, "generic", fileName, path);
				shipList = getNodes(path+"/"+fileName,"ShipTypeList");
				scopeList = getNodes(path+"/"+fileName,"ScopeList");
			}
		}
		ContextUtil.popContext(context);

	
%>



<head>

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<meta name="description" content="" />
<link rel="stylesheet" type="text/css" href="css/slidernav.css?v=1.0.0" media="screen, projection" />
<script type="text/javascript" src="js/jquery-1.4.2.min.js?v=1.0"></script>
<script type="text/javascript" src="js/slidernav.js?v=1.0"></script>
<script type="text/javascript">
$(document).ready(function(){
	$('#slider').sliderNav();
});
</script>
<style>
*{margin:0;padding:0;list-style-type:none;}
a,img{border:0;}
body{font:12px/180% Arial, Helvetica, sans-serif, "新宋体";background:#eee;}
/* demo */
.demo{width:400px;margin:20px auto;}
</style>


</head>
<body>

<table>
			<tr>
			
			<td><h3 style="color:red">适用船型:</h3></td>
			</tr>
			
</table>
		<hr>		
<div class="demo">

	<div id="slider">
		<div class="slider-content">
		
			<ul>
		
				<li id="a"><a name="a" class="title">A</a>
				
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
						String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("A")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  <%=checked%> onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="b"><a name="b" class="title">B</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("B")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
				<li id="c"><a name="c" class="title">C</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("C")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
				<li id="d"><a name="d" class="title">D</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							System.out.println("values--------"+values);
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									System.out.println("shipNames---------------"+shipNames);
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("D")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>   onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="e"><a name="e" class="title">E</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("E")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="f"><a name="f" class="title">F</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("F")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="g"><a name="g" class="title">G</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("G")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="h"><a name="h" class="title">H</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("H")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="i"><a name="i" class="title">I</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("I")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="j"><a name="j" class="title">J</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("J")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="k"><a name="k" class="title">K</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("K")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="l"><a name="l" class="title">L</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("L")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="m"><a name="m" class="title">M</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("M")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="n"><a name="n" class="title">N</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("N")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="o"><a name="o" class="title">O</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("O")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="p"><a name="p" class="title">P</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("P")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="q"><a name="q" class="title">Q</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("Q")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="r"><a name="r" class="title">R</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("R")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="s"><a name="s" class="title">S</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("S")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="t"><a name="t" class="title">T</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("T")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="u"><a name="u" class="title">U</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("U")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="v"><a name="v" class="title">V</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("V")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="w"><a name="w" class="title">W</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("W")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="x"><a name="x" class="title">X</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("X")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="y"><a name="y" class="title">Y</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("Y")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				</li>
				
					<li id="z"><a name="z" class="title">Z</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						if(pnin.startsWith("Z")){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				   </li>
				   <li id="z"><a name="z" class="title">其他</a>
						<%
						for(int i = 0;i<shipList.size();i++){
						String shipName = (String)shipList.get(i);
							String checked = "";
						
						if(ids!=null &&ids.length==1){
							String oid = ids[0];
							String values = MqlUtil.mqlCommand(context,"print bus "+oid+" select attribute[PLMEntity.V_description] dump");
							
							 if(values!=null &&values.length()>0&&values.contains(";")) {
									String shipNames = values.substring(0,values.indexOf(";"));
									
									String []sName = shipNames.split(",");
									for(int x = 0;x<sName.length;x++){
										String nm = sName[x].trim();
										
										if(shipName.equals(nm)){
											
											checked ="checked";
										}
									
								
								}
							 }
						}
						String pnin = convertHanzi2Pinyin(shipName,false).toUpperCase();
						
						char [] ch = pnin.toCharArray(); 
						if(!"ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(String.valueOf(ch[0]))){
						%>
						<li><a><input type="checkbox"  name="favorite" value="<%=shipName%>"  <%=checked%>  onClick="setColor(this)" />&nbsp;&nbsp;&nbsp; <%=shipName%></a></li>
						<%
						}
						}
						%>
						
					
				   </li>
			</ul>
		</div>
	</div>

</div>
<script>
	function setColor(checkbox){
		
		if ( checkbox.checked == true){
			checkbox.parentElement.parentElement.style.backgroundColor='#b8f3ff';
		}else{
			checkbox.parentElement.parentElement.style.backgroundColor='';
		}
	}
</script>
</body>
</html>