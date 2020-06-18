<%-- (c) Dassault Systemes, 2007, 2008 --%>
<%--
  Utility to return xml string to structure browser.  This is called
  after creating new documents
--%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil, 
                    com.dassault_systemes.smaslm.matrix.common.SimulationUtil, 
                    com.dassault_systemes.smaslm.matrix.common.SimulationConstants,
                    com.dassault_systemes.smaslm.matrix.server.XmlTableUtil,
                    com.dassault_systemes.smaslm.common.util.ParameterAdapter,
                    com.dassault_systemes.smaslm.common.util.ParameterDataAdapter,
                    com.dassault_systemes.smaslm.matrix.server.ParameterUtil,
                    java.lang.reflect.Array,
                    com.dassault_systemes.smaslm.common.util.W3CUtil,
                    org.w3c.dom.Element,
                    org.w3c.dom.NamedNodeMap,
                    org.w3c.dom.Node,
                    com.dassault_systemes.smaslm.matrix.common.json.JSONObject,
                    com.dassault_systemes.smaslm.matrix.common.json.JSONArray,
                    com.matrixone.apps.framework.ui.UINavigatorUtil,
                    com.matrixone.apps.domain.util.MapList,
                    com.matrixone.apps.domain.util.ContextUtil,
                    matrix.db.Context,
                    com.dassault_systemes.smaslm.matrix.server.SimulationActivity,
                    java.util.HashMap, 
                    java.util.Map, 
                    java.util.List, 
                    java.util.Iterator, 
                    matrix.util.StringList"%>

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<jsp:useBean id="formEditBean" class="com.matrixone.apps.framework.ui.UIForm" scope="session"/>

<%

String objectAction = emxGetParameter(request, "action");
/*if("ValidateExp".equals(objectAction)){
    Map requestMapForm = UINavigatorUtil.getRequestParameterMap(pageContext);
    String timeStamp = emxGetParameter(request, "timeStamp");
    Map formMap = formEditBean.getFormData(timeStamp);
    Map requestMap = (Map) formMap.get("requestMap");
    
    String Value = (String)requestMapForm.get("value");
    String Expression = (String)requestMapForm.get("Expression");
    if(Value!=null&&!"".equals(Value)&&
        Expression!=null&&!"".equals(Expression)){
        String msg = SimulationUtil.getI18NString(context,
            "smaSimulationCentral.error.ParamValueExp");
        %>
        <script language="JavaScript">
        var msg = '<%=msg%>';
        alert(msg);
        </script>
        <%
    }
}
else 
*/	
if ("saveArrayParameterValue".equalsIgnoreCase(objectAction))
{
    
    String simId = emxGetParameter(request, "simId");
    String parameterId = emxGetParameter(request, "parameterId");
    String arrDimLength = emxGetParameter(request, "arrDimLength");
    int arrDimLen = Integer.valueOf(arrDimLength);

    String dict = request.getParameter("dict");

    JSONObject jsonObj = new JSONObject(dict);
    JSONArray jsonArr = jsonObj.getJSONArray("children"), imJsonArr = new JSONArray();//, mainJsonArr = new JSONArray();
    for (int i = 0; i < arrDimLen; i++)
    {
        for (int j = 0; j < jsonArr.length(); j++)
        {
            if (i == 0)
            {
                imJsonArr.put(jsonArr.getJSONObject(j));    
            } else {
                JSONObject temp = jsonArr.getJSONObject(j);
                JSONArray tempArr = temp.getJSONArray("children");
                for (int k = 0; k < tempArr.length(); k++)
                {
                    imJsonArr.put(tempArr.getJSONObject(k));
                }
            }
        }
        jsonArr = imJsonArr;
        imJsonArr = new JSONArray();
        //mainJsonArr = new JSONArray(mainJsonArr.toString() + imJsonArr.toString());
    }


    String ATTRIBUTE_PARAMETERS = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_attribute_Parameters);
    SimulationActivity simAct = new SimulationActivity(simId);
    String parameters = simAct.getAttributeValue(context, ATTRIBUTE_PARAMETERS);
    org.w3c.dom.Document doc = W3CUtil.loadXml(parameters);
    Element parameterEle = W3CUtil.findElement(doc, "/ParameterData/ParameterList/Parameter[@id='"+parameterId+"']");

    for (int i = 0; i < jsonArr.length(); i++)
    {
        jsonObj = jsonArr.getJSONObject(i);
        if (jsonObj.contains("arrIndex"))
        {
            String arrIndex = jsonObj.getString("arrIndex");
            String indexVal = jsonObj.getString("title");
            String[] arrIndexVal = indexVal.split("~");
            String value = arrIndexVal.length > 1 ? arrIndexVal[1] : "";
            Element paramValueEle = W3CUtil.findElement(parameterEle, "./Value[@index='"+arrIndex+"']");
            if (paramValueEle == null)
            {
                paramValueEle = W3CUtil.newElement(parameterEle, "Value");
                paramValueEle.setAttribute("index", arrIndex);
            } 
            W3CUtil.setTextContent(paramValueEle, value);                
        }
    }
    W3CUtil.saveXMLIntoAttribute(context, simAct, ATTRIBUTE_PARAMETERS, doc); 
}
else 
{
    return;
}

            


%>







