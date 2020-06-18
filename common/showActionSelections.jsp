<%@include file = "../common/emxNavigatorInclude.inc"%>
<%!
  //
  // returns true/false based on whether it is to be displayed or not
  //
  static public String isChecked(String ActionItem,String FilterList)
  {
            String retValue="";
            StringTokenizer st = new StringTokenizer(FilterList, ",");
            while(st.hasMoreTokens())
             {
               String stItem=st.nextToken().trim();
               if(stItem.equalsIgnoreCase(ActionItem)){
               retValue="checked";
               break;
               }
             }
    return retValue;
  }
%>
<html>
<%@include file = "../common/emxNavigatorTopErrorInclude.inc"%>
<script language="javascript" src="../common/scripts/emxUIConstants.js"></script>
<script language="javascript" src="../common/scripts/emxUICore.js"></script>
<script language="javascript" src="../common/scripts/emxUICoreMenu.js"></script>
<%@include file = "../emxStyleListInclude.inc"%>
<%
String strSelectOnlyOneItem = UINavigatorUtil.getI18nString("emxFramework.History.SelectAtLeastOneActionType","emxFrameworkStringResource",request.getHeader("Accept-Language"));
strSelectOnlyOneItem = FrameworkUtil.findAndReplace(strSelectOnlyOneItem,"'","\\'");
%>
<script language="javascript">
  function isInList(currentChoice,listOfChoices){
  var selectionArr=listOfChoices.split(",");
  var selectionResults="";
  for(var z=0; z<selectionArr.length;z++)
  {
      if(selectionArr[z]==currentChoice){
        selectionResults="checked";
        break;
      }
   }
   return selectionResults;
  }


function checkchkList()
{

  var objForm = document.ActionSelect;
  var isAllChecked=true;
       for (var i=0; i < objForm.elements.length; i++){
         if (objForm.elements[i].name.indexOf('checkBox') > -1)
         {
           if(!objForm.elements[i].checked)
           {
             isAllChecked=false;
             break;
           }
         }
       }
       if(isAllChecked)
       {
         objForm.chkList.checked=true;
       }
}

function selectAll(){
	var objForm = document.ActionSelect;
	// Collect value of Action type checkbox in a variable.
	var chkList = objForm.chkList;
	for (var i=0; i < objForm.elements.length; i++){
        if (objForm.elements[i].name.indexOf('checkBox') > -1)
        {
        	  // Set the checked value irrespective of the selection.
			  objForm.elements[i].checked = chkList.checked;
        }
      }	  
	// No need to hardcode isAllChecked to true.
}

   function deSelectOne(objCheckbox){
   var objForm = document.ActionSelect;
   if (!objCheckbox.checked)
     {
          document.ActionSelect.chkList.checked=false;
     }
     else
     {
       var isAllChecked=true;
       for (var i=0; i < objForm.elements.length; i++){
         if (objForm.elements[i].name.indexOf('checkBox') > -1)
         {
           if(!objForm.elements[i].checked)
           {
             isAllChecked=false;
             break;
           }
         }
       }
       if(isAllChecked)
       {
         objForm.chkList.checked=true;
       }
     }
  }

function checkSelectedActions(){
  var objForm = document.ActionSelect;
  var chkList = objForm.chkList;
  var atleastOneSelect=false;
  var selectedActions="";
  var selectedEnglishActions="";
  var cntNotSelected=0;
  for (var i=1; i < objForm.elements.length; i++){
    if (objForm.elements[i].checked){
      var sFullValue = objForm.elements[i].value;
      var splValue = sFullValue.split("|");
      selectedEnglishActions+=splValue[0]+",";
      selectedActions+=splValue[1]+",";
      atleastOneSelect=true;
    }else{
      cntNotSelected++;
    }
   }
      var strLast=selectedActions.charAt(selectedActions.length-1);
      if(strLast==",")
        selectedActions=selectedActions.substring(0,selectedActions.length-1);

    if(!atleastOneSelect){
        //XSSOK
        alert('<%=strSelectOnlyOneItem%>');
        return;
    }else{

        if(cntNotSelected==0){
        	parent.getWindowOpener().document.objectHistoryHeader.actionFilterDisplay.value="*";
        	parent.getWindowOpener().document.objectHistoryHeader.actionFilter.value="*";
        }else{
        	parent.getWindowOpener().document.objectHistoryHeader.actionFilterDisplay.value=selectedActions;
        	parent.getWindowOpener().document.objectHistoryHeader.actionFilter.value=selectedEnglishActions;
        }

        parent.window.closeWindow();
    }
  }
</script>
</head>


<body onLoad="checkchkList()">
<%

String selectionlist=emxGetParameter(request, "hiddenActions");
selectionlist = com.matrixone.apps.domain.util.XSSUtil.decodeFromURL(selectionlist);
String actionlist=emxGetParameter(request, "actionFilter");
if(actionlist==null)
  actionlist="";

if(selectionlist==null)
  selectionlist="";

String rowValue="";
int j=0;
int z=0;
String actualValue= "";
StringBuffer htmlOutput= new StringBuffer(250);

         StringTokenizer st = new StringTokenizer(selectionlist, "|");
            while(st.hasMoreTokens())
             {
                      rowValue = "#ffffff";
                   if (j == 0) {
                       rowValue="#eeeeee";
                   }
               String stValue=st.nextToken().trim();
               if (stValue.contains("(") && stValue.contains(")")){
                   actualValue=stValue;
                   stValue = stValue.replace("(","");
                   stValue = stValue.replace(")","");
               }
               String strSelected="";

            if(!actionlist.equals("*")){
                strSelected=isChecked(stValue,actionlist);
            }else{
                strSelected="checked";
            }


           if(z==0) {

            String sActionType = UINavigatorUtil.getI18nString("emxFramework.History.ActionType", "emxFrameworkStringResource", request.getHeader("Accept-Language"));
%>
            <form name="ActionSelect" method="post" onsubmit="checkSelectedActions(); return false;">
                <table width="100%">
                    <tr>
                        <td bgcolor="#336699">
                            <input type="checkbox" name="chkList" onClick="selectAll()" />
                                <!-- //XSSOK -->
                                <font color="#ffffff"><b><%=sActionType%></b>
                        </td>
                    </tr>
<%
         }

          String sActionProp = "emxFramework.History." + stValue.replace(' ','_');
          String sActionI18N = "";
          String val = "";
          if(sActionProp.indexOf("(") < 0 ){
            sActionI18N = UINavigatorUtil.getI18nString(sActionProp, "emxFrameworkStringResource", request.getHeader("Accept-Language"));
          }else{
            sActionI18N=stValue;
          }

          if (actualValue!="") {
			  val = actualValue + "|" + sActionI18N;
		  }else {
			  val = stValue + "|" + sActionI18N;
		  }
          
%>
          <!-- //XSSOK -->
          <tr bgcolor="<%=rowValue%>">
            <td>
                <input type="checkbox" name="checkBox" value="<xss:encodeForHTMLAttribute><%=val%></xss:encodeForHTMLAttribute>" <%=strSelected%> onClick="deSelectOne(this)" />
                <xss:encodeForHTML><%=sActionI18N%></xss:encodeForHTML>
            </td>
          </tr>
<%
          z++;
          j=z%2;
       }
%>
</table>
</form>
</body>
</html>
