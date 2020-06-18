<%@page import="com.dassault_systemes.smaslm.matrix.common.json.JSONUtil"%>
<%@page import="com.dassault_systemes.smaslm.matrix.server.SimulationActivity"%>
<%@page import = "java.util.HashMap, java.util.Map, java.util.List, matrix.util.StringList"%>
<%@page import = "com.dassault_systemes.smaslm.matrix.server.SimulationUIUtil, 
                    com.dassault_systemes.smaslm.matrix.common.SimulationUtil, 
                    com.dassault_systemes.smaslm.matrix.common.SimulationConstants,
                    com.dassault_systemes.smaslm.matrix.server.XmlTableUtil,
                    com.dassault_systemes.smaslm.common.util.ParameterAdapter,
                    com.dassault_systemes.smaslm.common.util.ParameterDataAdapter,
                    com.dassault_systemes.smaslm.matrix.server.ParameterUtil,
                    com.dassault_systemes.smaslm.common.util.StringUtil,
                    com.dassault_systemes.smaslm.matrix.server.LogDescriptor,
                    java.lang.reflect.Array,
                    com.dassault_systemes.smaslm.common.util.W3CUtil,
                    org.w3c.dom.Element,
                    org.w3c.dom.NamedNodeMap,
                    org.w3c.dom.Node"%>

<%@page import = "com.matrixone.apps.domain.DomainObject"%>

<%@ page import="matrix.db.*, matrix.util.* ,com.matrixone.servlet.*,java.util.*,com.matrixone.apps.domain.util.*" %>

<%@page import="java.util.Iterator"%>
<%@page import="javax.servlet.http.HttpServletRequest"%>

<%@page import="com.dassault_systemes.smaslm.matrix.common.json.JSONArray"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.json.JSONObject"%>
<%@page import="com.dassault_systemes.smaslm.matrix.common.json.*"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">

<%@include file = "../emxUICommonAppInclude.inc"%>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
  <script src="../plugins/treetable/vendor/jquery.js" type="text/javascript"></script>
  <script src="../common/scripts/jquery-ui.custom.js" type="text/javascript"></script>
  <script src="../plugins/libs/jquerycookie/jquery.cookie.js" type="text/javascript"></script>

  <link href="../plugins/dynatree/1.2.4/skin-vista/ui.dynatree.css" rel="stylesheet" type="text/css">
  <script src="../common/scripts/jquery.dynatree.js" type="text/javascript"></script>

  <!-- (Irrelevant source removed.) -->
<%!

public int[] indexToIntArr (String index) {
    index=index.replaceAll("\\[","");
    index=index.replaceAll("\\]","");
    String[] strArr = new String[1]; 
    if (index.indexOf(",") != -1)
    {
        strArr = index.split(",");    
    } else {
        strArr[0] = index;
    }
    
    int[] intArr = new int[strArr.length];
    for (int i = 0; i < intArr.length; i++)
    {
        try
        {
            int inParam = Integer.parseInt(strArr[i]);
            if (inParam > Integer.MAX_VALUE)
            {
                throw new Exception("Bad Value");
            }
            intArr[i] = inParam;
        }
        catch (Exception e)
        {
            // handle it TODO
        }    
    }
    return intArr;
}

public JSONArray createJSONArrayWithDefaultValue (String key, String val, int... sizes)
throws Exception
{
    JSONObject tempJSONObj = new JSONObject(), innerJSONObj = new JSONObject();
    JSONArray tempJSONArr = new JSONArray(), innerJSONArr = new JSONArray();
    int length = sizes.length;
    for (int i = length - 1 ; i >= 0 ; i--)
    {
        if (i == length - 1)
        {
            for (int j = 0 ; j < sizes[i]; j++)
            {
                innerJSONObj = new JSONObject();
                innerJSONObj.put(key,"\'"+j+"\'");
                innerJSONArr.put(innerJSONObj);
            }    
        } else {
            tempJSONArr = new JSONArray();
            for (int j = 0 ; j < sizes[i]; j++)
            {
                tempJSONObj = new JSONObject();
                tempJSONObj.put(key,"["+j+"]");
                
                tempJSONObj.put("children", new JSONArray(innerJSONArr.toString()) );
                tempJSONArr.put(tempJSONObj);
            }
            //innerJSONArr = new JSONArray();
            innerJSONArr = tempJSONArr;
        }
    }
        return innerJSONArr;
}

public void setValueInJSON (JSONArray jsonArr, String index, String val, int... sizes)
throws Exception
{
    int length = sizes.length;
    int len = sizes[length  - 1];
    val = "["+ len + "]" + "~" + val;
    JSONArray tempJsonArr = jsonArr, innerJsonArr = new JSONArray();
    JSONObject innerJsonObj = new JSONObject(); 
    for (int i = 0; i < length; i++)
    {
        innerJsonObj = (JSONObject) tempJsonArr.get(sizes[i]);
        if (innerJsonObj.contains("children"))
        {
            innerJsonArr = innerJsonObj.getJSONArray("children");
            tempJsonArr = innerJsonArr;    
        } 
    }
    innerJsonObj.put("title",val);
    innerJsonObj.put("arrIndex",index);
}

public String formatErrorMsg (Context context, String paramType, String paramName)
{
    String emsg = "";
    final String SEP = SimulationConstants.FORMAT_SEP;
    if ("integer".equals(paramType))
    {
        String maxVal = Integer.toString(Integer.MAX_VALUE);
        String minVal = Integer.toString(Integer.MIN_VALUE);
        emsg = StringUtil.concat("Error.Parameter.InvalidIntegerValue", SEP, paramName, SEP, minVal, SEP, maxVal);
    } else if ("real".equals(paramType)) {
        emsg = StringUtil.concat("Error.Parameter.InvalidRealValue", SEP, paramName);    
    } else if ("boolean".equals(paramType)) {
        emsg = StringUtil.concat("Error.Parameter.InvalidBooleanValue", SEP, paramName) ;    
    }
    
    emsg = LogDescriptor.formatLogMsg(context,
        emsg,
        SimulationConstants.FORMAT_SEP);

    return emsg;
}

public int[] tail(int[] arr) {
    return Arrays.copyOfRange(arr, 1, arr.length);
}
public ArrayList fillWithIndexes(ArrayList al, String v, int... sizes) {
    for (int i = 0; i < sizes[0]; i++)
    {
            
        if (sizes.length == 1){
            String index = v + "," + i;
            index = index.substring(1);
            al.add("[" + index + "]");
        }
        else {
            fillWithIndexes(al, v + ","+i, tail(sizes));
        }
    }
        
        
    return al;
}

%>

<%
String strLanguage = request.getHeader("Accept-Language");

String simId = emxGetParameter(request, "objectId");
String parameterId = emxGetParameter(request, "parameterId");

String ATTRIBUTE_PARAMETERS = SimulationUtil.getSchemaProperty(SimulationConstants.SYMBOLIC_attribute_Parameters);
SimulationActivity simAct = new SimulationActivity(simId);
String parameters = simAct.getAttributeValue(context, ATTRIBUTE_PARAMETERS);

ParameterDataAdapter parameterData = ParameterUtil.getParameterData(context, simId);
ParameterAdapter parameter = parameterData.getParameterById(parameterId);
String paramType = parameter.getType();
paramType = paramType == null || "".equals(paramType) ? "string" : paramType;
String paramName = parameter.getName();
String strArrayDim = parameter.getArrayDim();

int[] intArrDim = indexToIntArr(strArrayDim);
String arrDimLength = intArrDim.length + "";

String defaultVal = "";
if (paramType.equalsIgnoreCase("string"))
{
    defaultVal = "";
} else {
    defaultVal = "";
}
JSONArray jsonArr111 = createJSONArrayWithDefaultValue("title", defaultVal, intArrDim);
org.w3c.dom.Document doc = W3CUtil.loadXml(parameters);
Element parameterEle = W3CUtil.findElement(doc, "/ParameterData/ParameterList/Parameter[@id='"+parameterId+"']");
List paramValueEles = W3CUtil.findElements(parameterEle, "./Value");
int size = paramValueEles.size();
int sizeArrDim = 1;
for (int i : intArrDim) 
{
    sizeArrDim = sizeArrDim * i;  
}

if (size > 0 && size == sizeArrDim) 
{
    for(int i =0;i<size;i++)
    {
        Node paramValueEle = (Node)paramValueEles.get(i);
        NamedNodeMap attributes = (NamedNodeMap)paramValueEle.getAttributes();
        String index = attributes.getNamedItem("index").getNodeValue();
        String valueText = paramValueEle.getTextContent();
        int[] indexArr = indexToIntArr(index);
        setValueInJSON(jsonArr111, index, valueText, indexArr);
    }
} else {
    ArrayList indexArrLst = new ArrayList();
    fillWithIndexes(indexArrLst, "", intArrDim);
    if (size < sizeArrDim)
    {
        for(int i =0;i<size;i++)
        {
            Node paramValueEle = (Node)paramValueEles.get(i);
            NamedNodeMap attributes = (NamedNodeMap)paramValueEle.getAttributes();
            String index = attributes.getNamedItem("index").getNodeValue();
            String valueText = paramValueEle.getTextContent();
            int[] indexArr = indexToIntArr(index);
            setValueInJSON(jsonArr111, index, valueText, indexArr);
            indexArrLst.remove(index);
        }        
    } else {
        for(int i =0;i<size;i++)
        {
            Node paramValueEle = (Node)paramValueEles.get(i);
            NamedNodeMap attributes = (NamedNodeMap)paramValueEle.getAttributes();
            String index = attributes.getNamedItem("index").getNodeValue();
            if(!indexArrLst.contains(index))
            {
//                paramValueEles.remove(i);
                continue;
            } else {
                String valueText = paramValueEle.getTextContent();
                int[] indexArr = indexToIntArr(index);
                setValueInJSON(jsonArr111, index, valueText, indexArr);
                indexArrLst.remove(index);
            }
        }
        
    }

    ListIterator lstItr = indexArrLst.listIterator();    
    while (lstItr.hasNext()) {
        String index = (String) lstItr.next();
        int[] indexArr = indexToIntArr(index);
        setValueInJSON(jsonArr111, index, "", indexArr);
    }    
}

String emsg = formatErrorMsg(context, paramType, paramName);
String strCancel = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Button.Cancel", new Locale(strLanguage));
String strSubmit = EnoviaResourceBundle.getFrameworkStringResourceProperty(context, "emxFramework.Button.Submit", new Locale(strLanguage));
%>
<script type="text/javascript">

var paramType = "<%=paramType%>";
var emsg = "<%=emsg%>";

function validateValueType (paramType, value) {
	var validation_flag = true;
    if (paramType == "integer" || paramType == "real") 
    {
         if (isNaN(value)) 
            {
            validation_flag = false;
            }
         else
          {
            if(value.toString().indexOf(".")>=0 && paramType == "integer")
             {
             validation_flag = false;
             }
           }
        
        if(!validation_flag)
        return false;
	 }
	 else if (paramType == "boolean")
	 {
        if (!(value.toLowerCase() == "true" || value.toLowerCase() == "false")) 
            return false;
     }
    return true;    
}
/**
 * Implement inline editing for a dynatree node
 */
 
function editNode(node){
  //var prevTitle = node.data.title,
  // Render title as columns
  if(node.data.title.indexOf("~") === -1){
	// Default rendering
	return false;
  }
  var cols = node.data.title.split("~");
  //cols[0] = cols[0] + "]";
  if (cols[1] === undefined)
  {
	  cols[1] = '';
  }
  var prevTitle = cols[1];
    tree = node.tree;
  // Disable dynatree mouse- and key handling
  tree.$widget.unbind();
  // Replace node with <input>
  //$(".dynatree-title", node.span).html("<input id='editNode' value='" + prevTitle + "'>");
  //$(".dynatree-title").append("<input id='editNode' value='" + prevTitle + "'>");
  $(".dynatree-title", node.span).append("<input id='editNode' value='" + prevTitle + "'>");
  // Focus <input> and bind keyboard handler
  $("input#editNode")
    .focus()
    .keydown(function(event){
      switch( event.which ) {
      case 27: // [esc]
        // discard changes on [esc]
        $("input#editNode").val(cols[0] + " " + prevTitle);
        $(this).blur();
        break;
      case 13: // [enter]
        // simulate blur to accept new value
        $(this).blur();
        break;
      }
    }).blur(function(event){
        // Accept new value, when user leaves <input>
        var title = $("input#editNode").val();
        var isValidData = validateValueType(paramType, title);
        title = cols[0] + "~" + title;
        if (!isValidData) {
            alert(emsg);
            title = prevTitle;
        }
        node.setTitle(title);
        // Re-enable mouse and keyboard handlling
        tree.$widget.bind();
        node.focus();
      });
}

// ----------

$(function(){
  var isMac = /Mac/.test(navigator.platform);
  $("#tree").dynatree({
    title: "Event samples",
    children: <%=jsonArr111.toString()%>,
    onClick: function(node, event) {
      if( event.shiftKey ){
          if (node.data.children == null)
          {
            editNode(node);           
          }
        return false;
      }
    },
    onDblClick: function(node, event) {
        if (node.data.children == null)
            {
              editNode(node);           
            }

      return false;
    },
    onKeydown: function(node, event) {
      switch( event.which ) {
      case 113: // [F2]
          if (node.data.children == null)
          {
            editNode(node);           
          }
        return false;
      case 13: // [enter]
        if( isMac ){
            if (node.data.children == null)
            {
              editNode(node);           
            }
          return false;
        }
      }
    },
    onRender: function(node, nodeSpan) {
        $(nodeSpan).find("span.dynatree-icon").css("background-image", "url(\"../plugins/dynatree/1.2.4/skin-vista/icons-orig.gif\")");
    },
    onCustomRender: function(node) {
        // Render title as columns
        if(node.data.title.indexOf("~") === -1){
          // Default rendering
          return false;
        }
        var cols = node.data.title.split("~"),
          html = "<a class='dynatree-title' href='#'>";
        /* for(var i=0; i<cols.length; i++){
          html += "<span id='editableVal' class='td'>" + cols[i] + "</span>";
        } */
        for(var i=0; i<cols.length; i++){
            html += cols[i] ;
        }
        return html + "</a>";
    }
  });
});
</script>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="Javascript" src="../common/scripts/emxUICore.js"></script>


    <script type="text/javascript" src="../common/scripts/emxUIModal.js"></script>
    <script type="text/javascript" src="../common/scripts/emxUIShortcut.js"></script>
    <script type="text/javascript" src="../common/scripts/emxNavigatorHelp.js"></script>
    <script type="text/javascript" src="../simulationcentral/smaStructureNavigator.js"></script>
    
<script>

function closeSlideIn(){
    alert(getTopWindow());
    getTopWindow().closeSlideInDialog();
}
function doSave(){
    var dict = $("#tree").dynatree("getTree").toDict();
    var simId = "<%= simId%>";
    var strArrayDim = "<%= strArrayDim%>";
    var parameterId = "<%= parameterId%>";
    var arrDimLength = "<%= arrDimLength%>";
    dict = JSON.stringify(dict);
    
    jQuery.ajax(
            {
                url : '../simulationcentral/smaParameterUtil.jsp',
                type : "POST",
                data : { 'dict' : dict, 'simId' : simId, 'parameterId' : parameterId, 'strArrayDim' : strArrayDim, 'arrDimLength' : arrDimLength, 'action' : 'saveArrayParameterValue'},
                dataType : "text",
                success : function (returndata,status,xhr)
                    {
                       alert("Array values saved successfully");
                       getTopWindow().closeSlideInDialog();
                    },
                error :  function(  jqXHR,  textStatus,  errorThrown )
                    {
                        alert("jqXHR = "+jqXHR+" textStatus= "+textStatus+" errorThrown = "+errorThrown);
                    }
                }
            );
}
</script>
</head>
<body class="example">
    <div id="tree">
    </div>

  <!-- (Irrelevant source removed.) -->
  
  <form name="CreateNewFooter" method="post" >
      <table width="100%" border="0" margin="0" align="center" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right">
            <table border="0" cellspacing="0" cellpadding="0">
              <br/><tr>
                <td>&nbsp;&nbsp;</td>
                <td><a href="javascript:doSave()"><img border="0" " src="../common/images/buttonDialogDone.gif"></a></td>
                <td nowrap>&nbsp;<a href="javascript:doSave()" class="button"><%=strSubmit %></a></td>
                <td>&nbsp;&nbsp;</td>
                <!--  Changed by qw9 for converting to slide-ins. Changed href property to getTopWindow().CloseSlideInDialog from topClose -->
                <td><a href="javascript:getTopWindow().closeSlideInDialog()"><img border="0" src="../common/images/buttonDialogCancel.gif"></a></td>
                <td nowrap>&nbsp;<a class="button" href="javascript:getTopWindow().closeSlideInDialog()"><%=strCancel %></a>&nbsp;</td>
              </tr>
            </table>
          </td>
        </tr>
      </table>
      </form>

  
</body>

</html>





