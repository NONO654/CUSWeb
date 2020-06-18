
var validationMsg = "";
var lastDateIndex = 0;
var lastDateField;
var dateFieldArray  = new Array ;

var currentEffTypesArr = new Array();
var currentEffTypesArrActual = new Array();
var debug = true;
var computeRule1    = "" ;
var inValidValKeyIn = ""; 
var bContextExist = false;        
var effectivityColumnType = "";

/*
 * get all settings\data, generate context source panels, operators...
 */
function displayCFFDefinitionDialog(){
    getContextsInfo();
    getEffTypes();
    updateEffTypeList();
    addSettingFields();
    loadContextPanel();
    addANDNOTButtons();
    displayContextSourcePanel();
    addKeyInDiv();
    initialLoad();
    resizePanel();
    showHidePanels(getSelectedContext());
}

/*
 * gets contexts' information and create two arrays. One is to store actuacl contexts' information
 * and the other is to for Context Panel.
 */
function getContextsInfo(){
    //get current contexts' expression and build an array for it
	effectivityColumnType = document.getElementsByName("effColumnType")[0].value;
    if (currentEffExprActual != null && currentEffExprActual != "undefined" && currentEffExprActual != "") {
        currentEffExprActual = encodeURI(currentEffExprActual);		//IR-572037-3DEXPERIENCER2018x fixing because tomee does not allow special symbols thats why encoding URL Parameters.
        var url = "../effectivity/EffectivityUtil.jsp?mode=getContextsMap&currentEffExprActual=" + currentEffExprActual + "&globalContextPhyId=" + globalContextPhyId;
        contextExpressionArr = emxUICore.parseJSON(emxUICore.getDataPost(url));
        
        //collect contexts' id from current expression
        var contextsIdStr = "";
        for(var i=0; i < contextExpressionArr.length; i++){
            var contextId = contextExpressionArr[i].contextId;
            if(contextsIdStr.indexOf(contextId) == -1  && contextId != null && contextId != globalContextPhyId){
                contextsIdStr += (contextsIdStr != "")?"|"+contextExpressionArr[i].contextId:contextExpressionArr[i].contextId;
            }
        }

        if(contextExpressionArr.length > 0){
            var idArray = contextsIdStr.split("|");
            for(var n=0; n < idArray.length; n++){
                if(includeContextsStr == null || includeContextsStr == ""){
                    includeContextsStr = idArray[n];
                } else if(includeContextsStr.indexOf(idArray[n]) == -1){
                    includeContextsStr += "|" + idArray[n];
                }
            }
        }
    }

    //For Context Panel: get display info for contexts from current expression and include program\configuration context
    if(includeContextsStr != null && includeContextsStr != ""){
        var url = "../effectivity/EffectivityUtil.jsp?mode=getContextsForSelect&includeContextList="+includeContextsStr;
        includeContextsInfo = emxUICore.getDataPost(url);   
    }
}

/*
 * checks context's expression for syntax error 
 */
function fnValidate(bSuppressAlert, bCompleteExpression){
	
    var cachedList = document.getElementById("cachedContextList");
    var selectedContextId = cachedList.selectedContext;
    if(selectedContextId == null || selectedContextId == "undefined" || selectedContextId == "" )
    { 
    	giveAlert("MUST_SELECT_A_CONTEXT");  
    	return "false";
    }   
    
	
    if(bSuppressAlert == null || bSuppressAlert == "undefined"){
        bSuppressAlert = false;     
    }

    var formName = document.BCform;
    var lstExpression =  new Array();
    var strInvockedFrom = invokedFrom;
    var incExpSelect = document.getElementById("IncExp");
    var lstExp =  new Array();
    //validating an empty expression
    if(incExpSelect && incExpSelect.options.length < 1){
        if(bSuppressAlert == false && showValidMsg == true){
            giveAlert("VALID_EXPRESSION");
        }
        return "true";
    }
    
    for(var i=0; i<incExpSelect.options.length; i++) 
    {
        var strLExpOption = document.getElementById("IncExp").options[i];
        if (strLExpOption.value == "EF_FO_EF_MS")continue;
        lstExp[i]=strLExpOption.value;         

        if(strLExpOption.value.indexOf("[]") != -1)
        {
            if(bSuppressAlert == false){
                giveAlert("INVALID_EXPRESSION");    
            }
            
            /*validated = false;*/
            return "false";
        }

        if(strLExpOption.value != "AND" && strLExpOption.value != "OR" && strLExpOption.value != "NOT" && strLExpOption.value != "(" && strLExpOption.value != ")")
        {
            lstExpression[i] = "TRUE";
        }
        else
        {
            lstExpression[i] = strLExpOption.value;
        }
    }        
  for(var j=0;j<lstExp.length;j++){
    	var indexcheck=lstExp.indexOf("AND");     
    	if(indexcheck > 0){
    		var firstExp=lstExp[indexcheck-1];
    		var secExp=lstExp[indexcheck+1];    
    	    var checkMS1=	firstExp.search("@EF_MS");    	
    	    if(secExp){
    	    var checkMS2= secExp.search("@EF_MS");     	 
    	    if(checkMS1 > -1 && checkMS2 > -1){
    	    	lstExpression[i] = strLExpOption.value;
    	    	 giveAlert("INVALID_EXPRESSION"); 
    	        return "false";
    	    }
    	}
    }
    }

    var urlParams = "mode=ValidateExpression&ContextId="+strContextObjectId+"&LeftExpression="+lstExpression;
    var vRes = emxUICore.getDataPost("../effectivity/EffectivityUtil.jsp", urlParams);

    vRes = trim(vRes);
    
    if(vRes == "true" && bCompleteExpression == true){
        var selectedContext = getSelectedContext();
        //save current expression 
        if(selectedContext != "undefined" && selectedContext != ""){
            updateCompleteExpression(selectedContext);  
        }
    
        //check for unsupported use-cases
        var completeExp = getCompleteExpression(contextExpressionArr);
        
        var urlParams = "mode=ValidateActualExpression&actualExpression="+completeExp.completedRuleActual;
        var vRes2 = emxUICore.getDataPost("../effectivity/EffectivityUtil.jsp", urlParams);
        vRes2 = trim(vRes2);
        if(vRes2 != "true"){
            alert(vRes2);
            return "false";
        }    
        
    }
    if(vRes == "true" && showValidMsg == true)
    {
         if(bSuppressAlert == false){
            giveAlert("VALID_EXPRESSION");
         }
    }
    if(vRes == "false")
    {
        if(bSuppressAlert == false){            
            giveAlert("INVALID_EXPRESSION");
        }
    }
    
    return vRes;
} // end of function

/*
 * sets panels to their new height due to the change in window's size
 */ 
 function resizePanel(){
    var heightAvr = 0;
    if(currentEffTypesArrActual != null && currentEffTypesArrActual.length > 0){        
        for(var i=0; i < currentEffTypesArrActual.length; i++){
            var effType = currentEffTypesArrActual[i];
            var effTypeDiv = document.getElementById("mx_div"+effType);
            if(effTypeDiv != null && effTypeDiv.className != null && effTypeDiv.className != 'undefined' && (effTypeDiv.className == CLASS_PANEL_OPEN)){
                var divDateId = "";
                if(effType == DATE_EFFECTIVITY_TYPE){
                    divDateId = "mx_div" + DATE_EFFECTIVITY_TYPE + "Body";
                } else if(effType == CONTEXTDATE_EFFECTIVITY_TYPE){
                    divDateId = "mx_div" + CONTEXTDATE_EFFECTIVITY_TYPE + "Body";
                }
                var panelBodyorIframeId = (effType==DATE_EFFECTIVITY_TYPE || effType==CONTEXTDATE_EFFECTIVITY_TYPE)?divDateId:("mx_iframe"+effType); 
                var panelBodyorIframe = document.getElementById(panelBodyorIframeId);
                panelBodyorIframe.style.height = getUpdatedHeight("mx_divSourceList", currentEffTypesArrActual)+"px";
            }           
        }
    }
    
    resetKeyInDiv();
    if($('.dropdown-menu.textcomplete-dropdown').size()>0){
    $('.dropdown-menu.textcomplete-dropdown').css("display", "none");
    }
 
    var incExp = document.getElementById("IncExp");
    if(incExp != null && incExp != 'undefined'){
        incExp.onmousedown=click;
    }
    
}

 //readjust dimensions
 window.onresize=resizePanel;   
    
/*
 * returns selected contexts
 */
 function getSelectedContext(){
    var cachedContextUL = document.getElementById('cachedContextList');
    var selectedContext = cachedContextUL.selectedContext;
    if(selectedContext == null || selectedContext== 'undefined' || selectedContext==""){
        selectedContext = "";
    }   

    return selectedContext;
}   

function getActiveEffectivityType(){
    var sourcePanel = "";
    if(currentEffTypesArrActual != null && currentEffTypesArrActual.length > 0){
        for(var i=0; i < currentEffTypesArrActual.length; i++){
            var effType = currentEffTypesArrActual[i];
            var divSrcPanel = document.getElementById(MX_DIV + effType); 
            if(divSrcPanel != null && divSrcPanel != 'undefined' && divSrcPanel.className == CLASS_PANEL_OPEN){
                sourcePanel = effType;
                break;
            }           
        }       
    }

    return sourcePanel; 
}   

function click(e) {
    var xPos;
    var yPos;
    if (navigator.appName == 'Netscape'
        && e.which == 3) {
        xPos = e.clientX;
        yPos = e.clientY;
        showKeyInEditor(xPos,yPos);
        return false;
    }
    else {
        if (navigator.appName == 'Microsoft Internet Explorer'
            && event.button==2)
        {
            xPos = event.clientX;
            yPos = event.clientY;
            showKeyInEditor(xPos,yPos);
            return false;
        }
        return true;
    }
}
function showKeyInEditor(xPos,yPos)
{
    var selectbox = document.BCform.LeftExpression;
    var index = selectbox.selectedIndex;
    if (index < 0)
    {
        return;
    }
    var selectedEl = selectbox[index];
    var text = selectbox.options[index].text;
    text = encodeURIComponent(text);
    var value = selectbox.options[index].value;
    value = encodeURIComponent(value);
    yPos= yPos+5;
    var categoryType = selectedEl.categoryType;
    if(categoryType == "sequence")
    {
        var helperFrame = document.getElementById("helper");
        var keyInDiv = document.getElementById("keyInDiv");
        var vURL = "../effectivity/EffectivityUtil.jsp?mode=showKeyInEditor&displayString="+text+"&actualString="+value;
        var vRes = emxUICore.getData(vURL);
        var display = trim(vRes);
        populateKeyInDiv(keyInDiv,display,categoryType);
        keyInDiv.style.left=xPos+"px";
        keyInDiv.style.top=yPos+"px";
        positionIFrame("keyInDiv", "helper");
        keyInDiv.style.visibility="visible";
	    var keyInDivIn = document.getElementById('keyin');
   	    keyInDivIn.style.margin = "0px 3px 0px 0px";
   
   	  
    }else if("relational" == categoryType || "milestone"  == categoryType ||  'EF_FO_EF_MS' ==value  || undefined==categoryType ||"undefined"== categoryType){
    	var helperFrame = document.getElementById("helper");
        var keyInDiv = document.getElementById("keyInDiv");
        var display = "";
        populateKeyInDiv(keyInDiv,display,categoryType);
        keyInDiv.style.left=xPos+"px";
        keyInDiv.style.top=yPos+"px";
        positionIFrame("keyInDiv", "helper");
        keyInDiv.style.visibility="visible";
	    var keyInDivIn = document.getElementById('keyin');
   	    keyInDivIn.style.margin = "0px 0px 0px 0px";
        setTimeout(function() { document.getElementById('keyin').focus(); }, 1000);
        //get current selected context
        var cachedList = document.getElementById("cachedContextList");
        var selectedContextId = cachedList.selectedContext;
        if(selectedContextId != null && selectedContextId != "undefined" && selectedContextId != "" &&
        		selectedContextId != globalContextPhyId){ //Global Model is removed	
            LoadTextComplete(selectedContextId);
        } 
 
    	
    }
}

function done()
{
    var selectbox = document.BCform.LeftExpression;
    var index = selectbox.selectedIndex;
    var text = selectbox.options[index].text;
    text = encodeURIComponent(text);
    var value = selectbox.options[index].value;
    value = encodeURIComponent(value);
    var keyInTextbox = document.getElementById("keyin");
    var newValue = keyInTextbox.value;
    newValue = trim(newValue);
    if(validateSequence(newValue))
    {
        newValue = formatExpression(newValue);
        newValue=encodeURIComponent(newValue);      
        var vURL = "../effectivity/EffectivityUtil.jsp?mode=keyIn&displayString="+text+"&actualString="+value+"&keyInValue="+newValue;
        var vRes = emxUICore.getData(vURL);
        var displayActual = trim(vRes).split("-@displayActual@-");
        selectbox.options[index].text=displayActual[0];
        selectbox.options[index].value=displayActual[1];
        var keyInDiv = document.getElementById("keyInDiv");
        populateKeyInDiv(keyInDiv,"","");
        keyInDiv.style.visibility="hidden";
        computedRule();
    }
    else
    {
        giveAlert(validationMsg, inValidValKeyIn);
        clearKeyInDiv();
    }
}
function validateSequence(sequence)
{
    sequence = trim(sequence);
    if(sequence == "")//empty string
    {
        validationMsg = "KEYIN_EMPTY_VALUE_ENETERED";
        return valid;
    }
    var xmlDoc = getDisplaySeparators();
    //var rangeSeparatorDisplay = rangeValueDisplaySeparators[0];
    //var valueSeparatorDisplay = rangeValueDisplaySeparators[1];
    //alert(",".charCodeAt(0)+"zxcv"+valueSeparatorDisplay.charCodeAt(0));
    //alert((",".valueOf()==valueSeparatorDisplay.valueOf()));
    //var list = sequence.split(String.fromCharCode(valueSeparatorDisplay.charCodeAt(0)));
    var rangeValueDisplaySeparators = xmlDoc.getElementsByTagName("Separators");
    var rangeSeparatorDisplay = rangeValueDisplaySeparators[0].getAttribute("rangeSeparator");
    var valueSeparatorDisplay = rangeValueDisplaySeparators[0].getAttribute("valueSeparator");
    var list = sequence.split(valueSeparatorDisplay);
    var valid = false;
    for(var i=0; i<list.length; i++)
    {
        if(list[i]==infinitySymbolKeyIn)
        {
            validationMsg = "KEYIN_INFINITY_AS_SEQUENCE_VALUE";
            return false;
        }
        var range = list[i].split(rangeSeparatorDisplay);
        var startRange = parseInt(range[0]);
        var endRange="";
        if(range[1]=="" || range[1]== "undefined" || range[1] == null || range[1]== infinitySymbolKeyIn )
        {
            if(isNaN(startRange) || isNaN(range[0]))
            {
                inValidValKeyIn = range[0];
                validationMsg = "KEYIN_NOT_VALID_INTEGER_KEYWORD";
                valid = false;
                break;
            }
            else if(startRange <= 0)
            {
                validationMsg = "KEYIN_NO_GREATER_THAN_ZERO";
                return false;
            }
            else
            {
                valid = true;
                continue;
            }
            
        }
        endRange = parseInt(range[1]);
        if(isNaN(startRange) || isNaN(range[0]))
        {
            inValidValKeyIn = range[0];
            if(inValidValKeyIn != infinitySymbolKeyIn)
                {
            validationMsg = "KEYIN_NOT_VALID_INTEGER_KEYWORD";
            }
            else
                validationMsg = "KEYIN_INFINITY_AS_START_SEQUENCE_VALUE";
            return false;
        }
        if(isNaN(endRange) || isNaN(range[1]))
        {
            infinityKeyIn = infinitySymbolKeyIn;
            if(range[1] != infinityKeyIn)
            {
                inValidValKeyIn = range[1];
                validationMsg = "KEYIN_NOT_VALID_INTEGER_KEYWORD";
                return false;
            }
            else
            {
                valid = true;
                continue;
            }
        }
        else
        {
            if(startRange > 0 && endRange >0 )
            {
                valid = true;
            }
            else
            {
                validationMsg = "KEYIN_NO_GREATER_THAN_ZERO";
                return false;
            }
            if(startRange < endRange)
            {
                valid = true;
            }
            else
            {
                validationMsg = "KEYIN_START_RANGE_GREATER_END_RANGE";
                return false;
            }
            
        }
    }
    return valid;
}
function getDisplaySeparators()
{
    var vEffType = getEffTypeSelectedEl();
    var vURL = "../effectivity/EffectivityUtil.jsp?mode=getSeparators&effType="+vEffType;
    var vRes = emxUICore.getXMLData(vURL);
    return vRes;
}
function formatExpression(sequence)
{
    var formattedString=""; 
    var xmlDoc = getDisplaySeparators();
    var rangeValueDisplaySeparators = xmlDoc.getElementsByTagName("Separators");
    var rangeSeparatorDisplay = rangeValueDisplaySeparators[0].getAttribute("rangeSeparator");
    var valueSeparatorDisplay = rangeValueDisplaySeparators[0].getAttribute("valueSeparator");
    var list = sequence.split(valueSeparatorDisplay);
    var valid = false;
    for(var i=0; i<list.length; i++)
    {
        var range = list[i].split(String.fromCharCode(rangeSeparatorDisplay.charCodeAt(0)));
        var startRange = parseInt(range[0]);
        var endRange = "";
        formattedString+=startRange;
        if(range[1]!="" && range[1]!= "undefined" && range[1] != null)
        {
            endRange = parseInt(range[1]);
            if(isNaN(endRange))
            {
                endRange = infinitySymbolKeyIn;
            }
            formattedString+=rangeSeparatorDisplay;
            formattedString+=endRange;
        }
        if(i<list.length-1)
        {
            formattedString+=valueSeparatorDisplay;
        }
    }
    return formattedString;
}


function positionIFrame(divid, frmid)
{
    var div = document.getElementById(divid);
    var frm = document.getElementById(frmid);
    frm.style.left = div.style.left;
    frm.style.top = div.style.top;
    frm.style.height = div.offsetHeight;
    frm.style.width = div.offsetWidth;
}
function cancel()
{   
    var keyInDiv = document.getElementById("keyInDiv");
    populateKeyInDiv(keyInDiv,"","");
    keyInDiv.style.visibility="hidden";
    
}
function emptyDiv (divToClear)
{
    var i;
    while (i=divToClear.childNodes[0])
    {
        divToClear.removeChild(i);
    }
}
function populateKeyInDiv(keyInDiv,display,categoryType)
{
    emptyDiv(keyInDiv);
    var controlHeader =document.createElement("div");
    controlHeader.setAttribute("id","headerDiv");
    controlHeader.style.backgroundColor="silver";
    controlHeader.style.valign="middle";
    controlHeader.style.align="right";
    var headerControl =document.createElement("div");
    headerControl.setAttribute("id","holderDiv");
    headerControl.setAttribute("class","holderDiv");
    
    
    var inp = document.createElement("input");
    inp.setAttribute("type", "text");
    inp.setAttribute("id", "keyin");
    inp.setAttribute("value", display);
 

    var anchor1 = document.createElement("a");
    anchor1.href="javascript:done()";
    var imgDone = document.createElement("img");
    imgDone.setAttribute("src","../common/images/buttonMiniDone.gif");
    imgDone.setAttribute("id", "Done");
    imgDone.setAttribute("vspace","2");
    imgDone.setAttribute("hspace","2");
    imgDone.setAttribute("class","miniDone");
    anchor1.appendChild(imgDone);

    var anchor2 = document.createElement("a");
    anchor2.href="javascript:cancel()";
    var imgCancel = document.createElement("img");
    imgCancel.setAttribute("src","../common/images/buttonMiniCancel.gif");
    imgCancel.setAttribute("id", "Cancel");
    imgCancel.setAttribute("vspace","2");
    imgCancel.setAttribute("hspace","2");
    imgCancel.setAttribute("class","miniClose");
    anchor2.appendChild(imgCancel);
    
    headerControl.appendChild(inp);
    if(categoryType =="relational" ||categoryType=="milestone"){
   
    }else if(categoryType=="sequence"){
    	 headerControl.appendChild(anchor1);
    	 headerControl.appendChild(anchor2);
    }
    controlHeader.appendChild(headerControl);


    if(keyInDiv.childNodes.length <= 0)
    {
        keyInDiv.appendChild(controlHeader);
    }
}


function operatorInsert(operator,textArea)
{
    var Exp;
    var leftExp = document.BCform.LeftExpression;
    
    if(textArea=="left"){
        Exp = leftExp;
        }
                                                                                                                     
    var i = Exp.length;
    addOption(document.BCform.LeftExpression,operator,operator,"Operator");
} 

function addOption(selectbox,text,value,invokedFrom,effType)
{

    var optn = document.createElement("OPTION");
    optn.text = text;
    optn.value = value;
    //Split the expression "@EF_UT()" to get the keyword. From the keyword, get the category sequence
    if(invokedFrom == "Operand")
    {
        var temp = value.split("(");
        if(temp[0] != "" && temp[0]!=null && temp[0]!="null")
        {
            var vKeyword = temp[0].split("_");
            if(vKeyword[0] != "" && vKeyword[0] != null && vKeyword[0] != "null")//TODO:Add empty checks
            {
                var vCategoryType = "";
                if (effType == 'undefined' || effType == null || effType == 'null')
                {
                    vCategoryType = getEffSettingByKeyword("categoryType", vKeyword[1]);
					effType = getEffTypeName(vKeyword[1]);
                }
                else
                {                   
                    vCategoryType = getEffSetting("categoryType", effType);
                }
                optn.categoryType = vCategoryType;
                optn.effType = effType;
            }
        }
    }

    var cnt;
    var index = selectbox.selectedIndex;
    if(index != -1)
    {
        cnt = index+1;
        selectbox.options.add(optn,index+1);
    }
    else
    {
        selectbox.options.add(optn);
        cnt = selectbox.length-1;
        if(selectbox.length-1 == 0)
        {
            cnt = 0;
        }
        else
        {
            cnt = selectbox.length-1;
        }
    }
    return optn;
    //add a div with the name as that of it's index
    //addKeyInDiv(cnt);

} 
function addKeyInDiv()
{
    var keyInDiv = document.createElement("div");
    keyInDiv.setAttribute("id", "keyInDiv");
    keyInDiv.style.visibility="hidden";
    keyInDiv.style.position="fixed";
    keyInDiv.setAttribute("oncontextmenu","return false");
}
function resetKeyInDiv()
{
    var keyInDiv = document.getElementById("keyInDiv");
    var helperFrame = document.getElementById("helper");
    if(keyInDiv != null && keyInDiv != "" && keyInDiv != "null")
    {
        helperFrame.style.visibility="hidden";
        keyInDiv.style.visibility="hidden";
    }
    
    
}
function toggleOperator()
{
	var selectedIndexValue = document.BCform.LeftExpression.selectedIndex;
	var currValue = document.BCform.LeftExpression.options[selectedIndexValue].value; 
    if(currValue == "AND"){
    	document.BCform.LeftExpression.options[selectedIndexValue].text = "OR";
    	document.BCform.LeftExpression.options[selectedIndexValue].value = "OR";
    	computedRule("","left");
    }
    if(currValue == "OR"){
    	document.BCform.LeftExpression.options[selectedIndexValue].text = "AND";
    	document.BCform.LeftExpression.options[selectedIndexValue].value = "AND";
    	computedRule("","left");
    }
    
}

function clearKeyInDiv()
{   
    var keyInDiv = document.getElementById("keyin");
    keyInDiv.value="";
}
//Function to move up the feature options 
function moveUp(textArea)
{
    var Exp;
    var leftExp = document.BCform.LeftExpression;
 
    if(textArea=="left"){
        Exp = leftExp;
        }
    var rowSelected = false;
    for (var i = 0; i < Exp.length; i++)
        {
            if (Exp.options[i].selected)
            {  
                rowSelected = true;
                if(i!=0)
                    {
                        var firstOption = Exp.options[i-1];
                        var secondOption = Exp.options[i];
                        Exp.options[i-1] = null;
                        Exp.options.add(firstOption, i);
                    }
                
        
            }
        } //end of for
        
        if(rowSelected == false)
            giveAlert("USER_SELECTION_LIST");
} // end of method



//Function to move down the feature options 
function moveDown(textArea)
{
    var Exp;
    var leftExp = document.BCform.LeftExpression;

    if(textArea=="left"){
        Exp = leftExp;
    }

    var rowSelected = false;
     
    for (var i = Exp.length - 1; i >= 0; i--)
    {
        if (Exp.options[i].selected)
        {  
            rowSelected = true;
            if(i != (Exp.length-1))
                {
                    var firstOption = Exp.options[i];
                    var secondOption = Exp.options[i+1];
                    Exp.options[i] = null;
                    Exp.options.add(firstOption, i+1);
                }
        
        }
    } //end of for
    
    if(rowSelected == false)
        giveAlert("USER_SELECTION_LIST");
    
} // end of method 

//Function to remove the feature options
function removeExp(textArea)
{

    if(textArea == 'left'){
        Exp = document.BCform.LeftExpression ;
    }


    ind = Exp.selectedIndex;

    if (ind == -1){
        if(textArea == 'left'){
            Exp = document.BCform.LeftExpression ;
         }
         for(i=Exp.length-1; i>=0; i--)
         {         
            Exp.options[i] = null;  
                
         }
        return;
    }

    var expValue = Exp.options[ind].value;
    var expText = Exp.options[ind].text;

    

    if (ind != -1) {
        for(i=Exp.length-1; i>=0; i--)
        {
            if(Exp.options[i].selected)
            {
                //checkObjectIds(expValue,ind,textArea,expText);
                Exp.options[i] = null;
            }
        } //end of for

        if (Exp.length > 0) {
            Exp.selectedIndex = ind == 0 ? 0 : ind - 1;
        }
    }

}// end of method

//Function to remove the feature options
function clearAll(textArea)
{

    if(textArea == 'left'){
    Exp = document.BCform.LeftExpression ;
    }
    
    for(i=Exp.length-1; i>=0; i--)
    {         
        Exp.options[i] = null;  
        
    }
        
}// end of method
function getEffTypeSelectedEl()
{
    var selectbox = document.BCform.LeftExpression;
    var listIndex = selectbox.selectedIndex;
    return selectbox.options[listIndex].effType;
}

function insertInfinity()
{
    var selectbox = document.BCform.LeftExpression;
    var listIndex = selectbox.selectedIndex;
    if(listIndex != -1)
    {
        var vEffType = getEffTypeSelectedEl();
        vEffType =  encodeURIComponent(vEffType);
        var text = selectbox.options[listIndex].text;
        text = encodeURIComponent(text);
        var value = selectbox.options[listIndex].value;
        value = encodeURIComponent(value);
        var vURL = "../effectivity/EffectivityUtil.jsp?mode=infinity&displayString="+text+"&actualString="+value+"&effType="+vEffType;
        var vRes = emxUICore.getData(vURL);
        vRes = trim(vRes);
        var vExpression = vRes.split("-@displayActual@-");
        if(trim(vExpression[0]) != "Invalid_Infinity")
        {
            var displayString = vExpression[0];
            var actualString = vExpression[1];
            var optn = document.createElement("OPTION");
            optn.text = displayString;
            optn.value = actualString;
            if(listIndex != -1)
            {
                selectbox.remove(listIndex);
                selectbox.options.add(optn,listIndex);
            }
        }
        else
        {
            giveAlert("INVALID_INFINITY");
        }
    }
    else
    {
        giveAlert("ELEMENT_SELECTION");
    }

}

function insertDate(vActualType,vinsertAsRange)
{
    var vformatType = getEffSetting("Format", vActualType);
    var vcategoryType = getEffSetting(SETTING_CATEGORYTYPE, vActualType);
    var vfield1;
    var vfieldValue;
    var fieldName;
    var vURL = "";
    var vLastRangeValue = "";
    var dateFieldArrayValues = new Array;
    var dateFieldArraySelected = new Array;
    var compiledDates = new Array();
    /*
    if(document.getElementById('insertAsRange') != null)
    {
        vinsertAsRange = document.getElementById('insertAsRange').checked;
    }
    */
    
    //get current selected context
    var cachedList = document.getElementById("cachedContextList");
    var selectedContextId = cachedList.selectedContext;
    if(selectedContextId == null || selectedContextId == "undefined" || selectedContextId == "" )
    { 
    	giveAlert("MUST_SELECT_A_CONTEXT");  
    	return "false";
    }   
    
    
    if(lastDateIndex == 2)
    {
        formDateFieldArray();
    }
    var idx = 0;
    for ( var i = 0; i < dateFieldArray.length; i++) {
        fieldName = dateFieldArray[i]; // "Date" + i;
        vField1 = document.getElementById(fieldName);
        if (vField1 == null) {
            continue;
        }
        vfieldValue = vField1.value;
        if(vfieldValue != "")
        {
            dateFieldArrayValues[idx] = vfieldValue;
            dateFieldArraySelected[idx] = fieldName;
            idx++;
        }
    }
    idx--;
    if(dateFieldArrayValues.length == 0)
    {
        giveAlert("REQUEST_DATE_SELECTION");
        return;
    }
    if(vinsertAsRange)
    {
        if(dateFieldArrayValues.length == 1)
        {
            var firstField = dateFieldArray[0];
            firstFieldName = document.getElementById(firstField);
            var firstFieldValue =   firstFieldName.value; 
            if(firstFieldValue == "")
            {
                compiledDates[0] = "inf";
                compiledDates[1] = dateFieldArrayValues[0];
            }
            else
            {
                compiledDates[0] = dateFieldArrayValues[0];
                compiledDates[1] = "inf";
            }
        }
        else if(dateFieldArrayValues.length == 2)
        {            
            //2. Get the millisecond value for comparing the dates
            var startDate_ms = document.getElementById(dateFieldArraySelected[0]).value;
            var endDate_ms = document.getElementById(dateFieldArraySelected[1]).value;
            if(endDate_ms > startDate_ms)
            {
                for(var idx = 0; idx < dateFieldArrayValues.length; idx++)
                {
                    compiledDates[idx] = dateFieldArrayValues[idx];
                }
            }
            else if(endDate_ms == startDate_ms)
            {
                giveAlert("END_DATE_SAME_START_DATE");
                return;
            }else{
                
                giveAlert("END_DATE_BEFORE_START_DATE");
                return;

            }
        }
        else
        {
            giveAlert("INVALID_DATE_RANGE");
            return;
        }
    }
    else
    {
        for(var idx = 0; idx < dateFieldArrayValues.length; idx++)
        {
            compiledDates[idx] = dateFieldArrayValues[idx];
        }
    }

    // IVU - Start	
    //prepend default operator
    var defaultOperator = "AND";
    var andButton = document.getElementById("or");
	if(andButton.className == "on")
		defaultOperator = "OR";    
    var selectedIdx = -1;
    var options = document.BCform.LeftExpression.options;
    if(options.length > 0){
		var lastIdx = options.length - 1;
		selectedIdx = options.selectedIndex;
		if(selectedIdx != -1)
			lastIdx = selectedIdx;
		
		var lastOption = options[lastIdx].text;
		// get the last option effectivity type to prepend AND operator irrespective of the default operator
		var lastOptionEffType = options[lastIdx].effType;
		if(lastOptionEffType!=undefined){
		if(lastOptionEffType!= vActualType && lastOption!=")"){
			defaultOperator = "AND";
		}	
		}
		
		if(lastOption != "("){
    		operatorInsert(defaultOperator,"left");        		
    		if(selectedIdx != -1)
    			options.selectedIndex++;
    	}
	}
    // IVU - END
    
    var DateJson = new Object();
    DateJson["insertAsRange"] = vinsertAsRange;
    DateJson["values"] = compiledDates;
    DateJson["timezone"] = iClientTimeOffset;
    //get current selected context
    var cachedList = document.getElementById("cachedContextList");
    var selectedContextId = cachedList.selectedContext;
    if(selectedContextId != null && selectedContextId != "undefined" && selectedContextId != "" &&
    		selectedContextId != globalContextPhyId){ //Global Model is removed	
        //((selectedContextId != globalContextPhyId) ||
        //(selectedContextId == globalContextPhyId && vcategoryType == CONTEXTDATE_CATEGORY))){
        DateJson["contextId"] = selectedContextId;
    }   

    //DateJson=DateJson.toJSONString();
    var vURL = "mode=format&effExpr="
        + emxUICore.objectToJSONString(DateJson)+ "&effType=" + vActualType;
    var vRes = emxUICore.getDataPost("../effectivity/EffectivityUtil.jsp",vURL);
    //need to trim \r\n , in IE7 while rendering expression in Text Area, it would not adds newline between expression
    var vExpression = trim(vRes).split("-@clearSelectionValue@-");
    var expression = vExpression[0].split("-@ActualDisplay@-");
    var actualString = expression[0];
    var displayString = expression[1];
    var clearSelectionSetting = vExpression[1];
    addOption(document.BCform.LeftExpression, displayString, actualString,"Operand",vActualType);

}

function insertSeries(vActualType,vinsertAsRange)
{
	if(vinsertAsRange != true)
		vinsertAsRange = false;
	//get selected rows from structure browser
	//var selectedContexts = getStructureValues(); 	
	//var effType = getSelectedEffType();
	var selectedContexts = getStructureValues(MX_IFRAME+vActualType);
	
	if(selectedContexts == null || selectedContexts.length <= 0){
		giveAlert("USER_SELECTION");
		return 0;
	}

    // IVU - Start	
    //prepend default operator
    var defaultOperator = "AND";
    var andButton = document.getElementById("or");
	if(andButton.className == "on")
		defaultOperator = "OR";    
    var selectedIdx = -1;
    var options = document.BCform.LeftExpression.options;
    if(options.length > 0){
		var lastIdx = options.length - 1;
		selectedIdx = options.selectedIndex;
		if(selectedIdx != -1)
			lastIdx = selectedIdx;
		
		var lastOption = options[lastIdx].text;
		// get the last option effectivity type to prepend AND operator irrespective of the default operator
		var lastOptionEffType = options[lastIdx].effType;
		if(lastOptionEffType!= vActualType && lastOption!=")" && lastOption!="(" && lastOption!="NOT"){
			defaultOperator = "AND";
		}		
		
		if(lastOption != "(" && selectedContexts != "0" && lastOption!="NOT"){
    		operatorInsert(defaultOperator,"left");        		
    		if(selectedIdx != -1)
    			options.selectedIndex++;
    	}
	}
    
    // IVU - END
    
	var ctr = 0;
	for(var key in selectedContexts)
		{
		    if(key == "toJSONString" || key == "length")
		    	continue;
			var selectedValues = selectedContexts[key];
			
			if(vinsertAsRange)
 	        {
				if(selectedValues.length != 1 && selectedValues.length != 2)
				{
					giveAlert("INVALID_UNIT_RANGE");
					return 0;
				}

			}
			var selectedOptions = new Object();
			selectedOptions["insertAsRange"] = vinsertAsRange;
			selectedOptions["parentId"] = getSelectedContext();
			
			var selectedSeqSels = new Array();
			var selectedObjectIds = new Array();
			for(var i = 0; i < selectedValues.length; i++)
			{
				var selectedObj = selectedValues[i];
				if(selectedObj)
				{
				  selectedSeqSels[i] = selectedObj["seqSel"];
				  selectedObjectIds[i] = selectedObj["objId"];
				  var selectedNum = Number(selectedSeqSels[i]);
				  //@x56 commenting as no sequnce value column
				  //need to check that the series value is a number that is an integer
				  /*if(vinsertAsRange && (isNaN(selectedNum) || isNaN(parseInt(selectedNum))))
                  {
                       giveAlert("KEYIN_NO_GREATER_THAN_ZERO");
                       return 0;
                  }*/
               }
			}
			selectedOptions["values"] = selectedObjectIds;
			
			var urlParam = "mode=format&effExpr=" + emxUICore.objectToJSONString(selectedOptions) + "&effType=" + vActualType;
			var vRes = emxUICore.getDataPost("../effectivity/EffectivityUtil.jsp", urlParam);
			//need to trim \r\n , in IE7 while rendering expression in Text Area, it would not adds newline between expression
			vExpression = trim(vRes).split("-@clearSelectionValue@-");
			var expression = vExpression[0].split("-@ActualDisplay@-");
			var actualString = expression[0];
			var displayString = expression[1];
			//var optn = addOption(document.BCform.LeftExpression,displayString,actualString,"Operand",effType/*,true*/);
			var optn = addOption(document.BCform.LeftExpression,displayString,actualString,"Operand",vActualType);
			ctr++;
			if(ctr < selectedContexts.length)
			{
				//TODO: Accept OR from the Configuration File, it can be ! or anything else
				operatorInsert(defaultOperator,"left");
			}
		}
		if(vExpression[1])
		{
			clearSelection();
		}
}

function insertStructure(vActualType,vinsertAsRange)
{
    if(vinsertAsRange != true)
        vinsertAsRange = false;
    //get selected rows from structure browser
    var selectedContexts = getStructureValues(MX_IFRAME+vActualType);
    
    if(selectedContexts == null || selectedContexts.length <= 0){
        giveAlert("USER_SELECTION");
        return 0;
    }
    
    //prepend default operator
    var defaultOperator = "OR";
    var selectedIdx = -1;
    var options = document.BCform.LeftExpression.options;
    if(options.length > 0){
		var lastIdx = options.length - 1;
		selectedIdx = options.selectedIndex;
		if(selectedIdx != -1)
			lastIdx = selectedIdx;
		
		var lastOption = options[lastIdx].text;
		// get the last option effectivity type to prepend AND operator irrespective of the default operator
		var lastOptionEffType = options[lastIdx].effType;
		if(lastOptionEffType!= vActualType && lastOption!=")"){
			defaultOperator = "AND";
		}		
		
		if(lastOption != "(" && selectedContexts != "0"){
    		operatorInsert(defaultOperator,"left");        		
    		if(selectedIdx != -1)
    			options.selectedIndex++;
    	}
	}
    
    
    var ctr = 0;
    for(var key in selectedContexts)
        {
            if(key == "toJSONString" || key == "length")
                continue;
            var selectedValues = selectedContexts[key];
            if(vinsertAsRange)
            {
                if(selectedValues.length != 1 && selectedValues.length != 2)
                {
                    giveAlert("INVALID_UNIT_RANGE");
                    return 0;
                }

            }
            var selectedOptions = new Object();
            selectedOptions["insertAsRange"] = vinsertAsRange;
            selectedOptions["parentId"] = key;
            var selectedSeqSels = new Array();
            for(var i = 0; i < selectedValues.length; i++)
            {
                var selectedObj = selectedValues[i];
                if(selectedObj)
                {
                  selectedSeqSels[i] = selectedObj["seqSel"];
                  var selectedNum = Number(selectedSeqSels[i]);
                  //need to check that the series value is a number that is an integer
                  if(vinsertAsRange && (isNaN(selectedNum) || isNaN(parseInt(selectedNum))))
                  {
                       giveAlert("KEYIN_NO_GREATER_THAN_ZERO");
                       return 0;
                  }
               }
            }
            selectedOptions["values"] = selectedSeqSels;
            
            var urlParam = "mode=format&effExpr=" + emxUICore.objectToJSONString(selectedOptions) + "&effType=" + vActualType;
            var vRes = emxUICore.getDataPost("../effectivity/EffectivityUtil.jsp", urlParam);
            //need to trim \r\n , in IE7 while rendering expression in Text Area, it would not adds newline between expression
            vExpression = trim(vRes).split("-@clearSelectionValue@-");
            var expression = vExpression[0].split("-@ActualDisplay@-");
            var actualString = expression[0];
            var displayString = expression[1];
            //var optn = addOption(document.BCform.LeftExpression,displayString,actualString,"Operand",effType/*,true*/);
            var optn = addOption(document.BCform.LeftExpression,displayString,actualString,"Operand",vActualType);
            ctr++;
            if(ctr < selectedContexts.length)
            {
                //TODO: Accept OR from the Configuration File, it can be ! or anything else
                operatorInsert(defaultOperator,"left");
            }
        }
        if(vExpression[1])
        {
            clearSelection();
        }

}

/**
 * gets selected milestones from structure browser
 */
function getMilestoneValues(iframeName)
{
    var sourceFrame = findFrame(window, iframeName);
    var checkedItem = sourceFrame.getCheckedCheckboxes();
    if(Object.keys(checkedItem).length === 0)
    {
    	giveAlert("USER_SELECTION");
    	return 0;
    }
    else
    {
    var i = 0;
    var commonParentLength = 0;
    var selectedContexts = new Object();

    for(var key in checkedItem)
    {
        var temp = checkedItem[key];
        var tempArr = temp.split("|");
        var relId = tempArr[0];
        var objId = tempArr[1];
        var parentId = tempArr[2];
        var rowId = tempArr[3];

	//to get the type of selected object
	var objColumnFN  = sourceFrame.colMap.getColumnByIndex(0);      
        var columnName = objColumnFN.name;
        var selSeq = sourceFrame.emxEditableTable.getCellValueByRowId(rowId ,columnName);
	var objType = selSeq.type;
		
        if(MilestoneSubtypes.indexOf(objType) == -1)
    	{
            //It is root node
        	giveAlert("INVALID_INPUT_VALUE");
        	clearAllCheckedNodes(getActiveEffectivityType());
        	UpdateEmptyrow();
        	return 0;
    	}
        else
        {
        if(relId == "")
        {
            parentId = objId;
            objId = "";
        }
        if(selectedContexts[parentId] == null || selectedContexts[parentId] == undefined || selectedContexts[parentId] == "undefined")
        {
            commonParentLength++;
        }
        var objColumnFN  = sourceFrame.colMap.getColumnByName("Name");      
        var columnName = objColumnFN.name;
        var selSeq = sourceFrame.emxEditableTable.getCellValueByRowId(rowId ,columnName);
        var selectedValues = selectedContexts[parentId];
    
        if(!selectedValues)
        {
            selectedValues = new Array();
            selectedContexts[parentId] = selectedValues;
        }
        
        if (selSeq.value.current.actual != "")
        {
            var selectedObj = new Object();
            selectedObj["objId"]=objId;
            selectedObj["seqSel"]=selSeq.value.current.actual;

            var lvlArr = rowId.split(",");
            var contextLvlId = lvlArr[0]+","+lvlArr[1];
            
            //var temp = "/mxRoot/rows//r[@id ='" + contextLvlId + "']";
            var temp = "/mxRoot/rows//r[@id ='" + 0 + "']";
            
            var contextObjRow = emxUICore.selectSingleNode(sourceFrame.oXML.documentElement,temp);
            var contextObjId = contextObjRow.getAttribute("o");             

            selectedObj["relId"]=relId;
            selectedObj["parentId"]=parentId;
            selectedObj["contextId"]=contextObjId;
            selectedValues[selectedValues.length]=selectedObj;
        }
        
        i++;
    }
    }
    }
    selectedContexts.length=commonParentLength;
    
    return selectedContexts;
}

/**
 * formats selected milestone from structure browser and inserts them into expression field
 */
function insertMilestoneStructure(vActualType,vinsertAsRange)
{
    if(vinsertAsRange != true)
        vinsertAsRange = false;
    //get selected rows from structure browser
    var selectedContexts = getMilestoneValues(MX_IFRAME+vActualType);
    
   /* if(selectedContexts == null || selectedContexts.length <= 0){
        giveAlert("USER_SELECTION");
        return 0;
    }*/
    
    //prepend default operator
    var defaultOperator = "OR";
    var selectedIdx = -1;
    var options = document.BCform.LeftExpression.options;
    if(options.length > 0){
		var lastIdx = options.length - 1;
		selectedIdx = options.selectedIndex;
		if(selectedIdx != -1)
			lastIdx = selectedIdx;
		
		var lastOption = options[lastIdx].text;
		// get the last option effectivity type to prepend AND operator irrespective of the default operator
		var lastOptionEffType = options[lastIdx].effType;
		if(lastOptionEffType!= vActualType && lastOption!=")"){
			defaultOperator = "AND";
		}		
		
		if(lastOption != "(" && selectedContexts != "0"){
    		operatorInsert(defaultOperator,"left");        		
    		if(selectedIdx != -1)
    			options.selectedIndex++;
    	}
	}
    //
    
    var ctr = 0;
    for(var key in selectedContexts)
    {
        if(key == "toJSONString" || key == "length")
            continue;
        var selectedValues = selectedContexts[key];
        if(vinsertAsRange)
        {
            if(selectedValues.length != 1 && selectedValues.length != 2)
            {
                giveAlert("INVALID_MILESTONE_RANGE");
                
                //remove prepended default operator
                options.remove(lastIdx + 1);
                //
                return 0;
            }
        }
        var selectedOptions = new Object();
        selectedOptions["insertAsRange"] = vinsertAsRange;
        //selectedOptions["parentId"] = key;
        
        var selectedSeqSels = new Array();      
        if(selectedValues.length == 1)
        {           
            var objIdMilestonePair = selectedValues[0]["objId"];//["seqSel"];
            selectedSeqSels[0] = objIdMilestonePair;
            //if fromFilterToolbar, only single select is allowed
            if(!bForFiltering){
                selectedSeqSels[1] = infinitySymbolKeyIn;   
            }           
        }
        else if(selectedValues.length == 2)
        {
            var objIdMilestoneFromPair = selectedValues[0]["objId"];//["seqSel"];
            var objIdMilestoneToPair = selectedValues[1]["objId"];//["seqSel"];
            selectedSeqSels[0] = objIdMilestoneFromPair;
            selectedSeqSels[1] = objIdMilestoneToPair;
        }
   
        selectedOptions["relId"] = selectedValues[0]["relId"];
        selectedOptions["contextId"] = selectedValues[0]["contextId"];

        selectedOptions["values"] = selectedSeqSels;
        
        var urlParam = "mode=format&effExpr=" + emxUICore.objectToJSONString(selectedOptions) + "&effType=" + vActualType;
        var vRes = emxUICore.getDataPost("../effectivity/EffectivityUtil.jsp", urlParam);

        //need to trim \r\n , in IE7 while rendering expression in Text Area, it would not adds newline between expression
        vExpression = trim(vRes).split("-@clearSelectionValue@-");
        var expression = vExpression[0].split("-@ActualDisplay@-");
        var actualString = expression[0];
        var displayString = expression[1];
        var optn = addOption(document.BCform.LeftExpression,displayString,actualString,"Operand",vActualType);
        ctr++;
        if(ctr < selectedContexts.length)
        {
            //TODO: Accept OR from the Configuration File, it can be ! or anything else
            operatorInsert(defaultOperator,"left");
        }
    }
    //
    if(options.selectedIndex > 0)
		options.selectedIndex--;
    //
    if(vExpression[1])
    {
        clearSelection();
    }
}

function insertRelational(vActualType)
{
    //get selected rows from structure browser
    var selectedContext = getSelectedContext();
    //var bGlobalContextFO = (globalContextPhyId == selectedContext && FEATURE_OPTION_EFF_TYPE == vActualType);
    var bGlobalContextFO = false; //Global Model is removed
    if(bGlobalContextFO  && !bForFiltering){
        clearAll('left');
        var selectedContexts = getStructureRelationalValuesForGlobal(MX_IFRAME+vActualType);
        if(selectedContexts == null || selectedContexts.length <= 0){
            giveAlert("USER_SELECTION");
            return 0;
        }
    }else{
        var selectedContexts = getStructureRelationalValues(MX_IFRAME+vActualType);
        if(selectedContexts == null || selectedContexts.length <= 0){
            giveAlert("USER_SELECTION");
            return 0;
        }
    }   
    
    //get default operator
    var defaultOperator = "OR";
    var andButton = document.getElementById("and");
	if(andButton.className == "on")
		defaultOperator = "AND";
	//
	//prepend default operator
    var selectedIdx = -1;
    var options = document.BCform.LeftExpression.options;
    if(options.length > 0){
    	var lastIdx = options.length - 1;
    	selectedIdx = options.selectedIndex;
    	if(selectedIdx != -1)
    		lastIdx = selectedIdx;
    		
    	var lastOption = options[lastIdx].text;
    	
    	// If the last Option effectivity type and the current option effectivity types are different 
    	// then the operator will be AND, irrespective of Default operator selected.
		var lastOptionEffType = options[lastIdx].effType;
		if(lastOptionEffType!= vActualType && lastOption!=")" && lastOption!="(" && lastOption!="NOT"){
			defaultOperator = "AND";
		}
		
    	if(lastOption != "(" && lastOption != "NOT" && selectedContexts != "0"){
       		operatorInsert(defaultOperator,"left");
       		
       		if(selectedIdx != -1)
       			options.selectedIndex++;
       	}
    }
    //
	
    var ctr = 0;
    
    for(var key in selectedContexts)
        {
            if(key == "toJSONString" || key == "length")
                continue;
            var selectedValues = selectedContexts[key];
            var selectedOptions = new Object();
            for(var i = 0; i < selectedValues.length; i++)
            {
                var selectedObj = selectedValues[i];
                if(selectedObj)
                {   
                    selectedOptions["objId"] = selectedObj["objId"];
                    selectedOptions["relId"] = selectedObj["relId"];    
                    selectedOptions["parentId"] = selectedObj["parentId"];
                    selectedOptions["contextId"] = selectedObj["contextId"];
                    var urlParam = "mode=format&effExpr=" + emxUICore.objectToJSONString(selectedOptions) + "&effType=" + vActualType;
                    var vRes = emxUICore.getDataPost("../effectivity/EffectivityUtil.jsp", urlParam);
                    vExpression = vRes.split("-@clearSelectionValue@-");
                    var expression = vExpression[0].split("-@ActualDisplay@-");
                    var actualString = expression[0];
                    var displayString = expression[1];
                    //var optn = addOption(document.BCform.LeftExpression,displayString,actualString,"Operand",effType/*,true*/);
                    var optn = addOption(document.BCform.LeftExpression,displayString,actualString,"Operand",vActualType);
                    if(i < selectedValues.length-1)
                    {
                        //TODO: Accept OR from the Configuration File, it can be ! or anything else
                        operatorInsert(defaultOperator,"left");
                    }
               }
            }
            ctr++;
            //add operand "AND" if this is for global context on Feature Option with Varies By rel exist on root object
            if (bGlobalContextFO && ctr < selectedContexts.length){
                operatorInsert("AND","left");
            } else if(ctr < selectedContexts.length)
            {
                //TODO: Accept OR from the Configuration File, it can be ! or anything else
                operatorInsert(defaultOperator,"left");
            }
        }
	    //
	    if(options.selectedIndex > 0)
			options.selectedIndex--;
	    //
        if(vExpression[1])
        {
            clearSelection();
        }

}

function insertBranchingStart(textArea)
{
    var vSelected = document.getElementById('typeSelector_mx_divFilter1').selectedIndex;
    var vDisplayType = document.getElementById('typeSelector_mx_divFilter1').options[vSelected].text;
    var vActualType = document.getElementById('typeSelector_mx_divFilter1').options[vSelected].value;
    var vformatType = getEffSetting("Format", vActualType);
    var vcategoryType = getEffSetting("categoryType", vActualType);
    var vinsertAsRange = "";
    
    //get selected rows from structure browser
    var selectedContexts = getStructureRelationalValues();
    var effType = getActiveEffectivityType();
    
    if(selectedContexts == null || selectedContexts.length <= 0){
        giveAlert("USER_SELECTION");
        return 0;
    }

    var ctr = 0;
    var vExpression;
    for(var key in selectedContexts)
        {
            if(key == "toJSONString" || key == "length")
                continue;
            var selectedValues = selectedContexts[key];
            var selectedOptions = new Object();
            
            if(selectedValues.length > 1){
                giveAlert("USER_SELECTION_ONLY_ONE");
                return 0;
            }
            for(var i = 0; i < selectedValues.length; i++)
            {
                var selectedObj = selectedValues[i];
                if(selectedObj)
                {
                  selectedOptions["objId"] = selectedObj["objId"];
                  selectedOptions["relId"] = selectedObj["relId"];  
                  selectedOptions["parentId"] = selectedObj["parentId"];
               }
            }
            
            var url = "../effectivity/EffectivityUtil.jsp?mode=formatStartBranch&effExpr=" + selectedOptions["objId"] + "&effType=" + vActualType;
            var vRes = emxUICore.getData(url);
            vExpression = vRes.split("-@clearSelectionValue@-");
            var expression = vExpression[0].split("-@ActualDisplay@-");
            var actualString = expression[0];
            var displayString = expression[1];
            var optn = addOption(document.BCform.LeftExpression,displayString,actualString,"Operand",effType/*,true*/);
            ctr++;
            //if(ctr < selectedContexts.length)
            //{
                //TODO: Accept OR from the Configuration File, it can be ! or anything else
            //  operatorInsert("OR","left");
            //}
        }
        if(vExpression[0])
        {
            clearSelection();
        }
}

function insertBranchingEnd(textArea)
{
    var vSelected = document.getElementById('typeSelector_mx_divFilter1').selectedIndex;
    var vDisplayType = document.getElementById('typeSelector_mx_divFilter1').options[vSelected].text;
    var vActualType = document.getElementById('typeSelector_mx_divFilter1').options[vSelected].value;
    var vformatType = getEffSetting("Format", vActualType);
    var vcategoryType = getEffSetting("categoryType", vActualType);
    var vinsertAsRange = "";

    //get selected rows from structure browser
    var selectedContexts = getStructureRelationalValues();
    var effType = getActiveEffectivityType();
    
    if(selectedContexts == null || selectedContexts.length <= 0){
        giveAlert("USER_SELECTION");
        return 0;
    }

    var ctr = 0;
    for(var key in selectedContexts)
        {
            if(key == "toJSONString" || key == "length")
                continue;
            var selectedValues = selectedContexts[key];
            var selectedOptions = new Object();
            
            for(var i = 0; i < selectedValues.length; i++)
            {
                var selectedObj = selectedValues[i];
                if(selectedObj)
                {
                  selectedOptions["objId"] = selectedObj["objId"];
                  selectedOptions["relId"] = selectedObj["relId"];  
                  selectedOptions["parentId"] = selectedObj["parentId"];
               }
            }
            
            var url = "../effectivity/EffectivityUtil.jsp?mode=formatStartBranch&effExpr=" + selectedOptions["objId"] + "&effType=" + vActualType;
            var vRes = emxUICore.getData(url);
            vExpression = vRes.split("-@clearSelectionValue@-");
            var expression = vExpression[0].split("-@ActualDisplay@-");
            var actualString = "< " + expression[0];
            var displayString = "< " + expression[1];
            //operatorInsert("AND","left");
            //operatorInsert("NOT","left");
            var optn = addOption(document.BCform.LeftExpression,displayString,actualString,"Operand",effType/*,true*/);
            ctr++;
            //if(ctr < selectedContexts.length)
            //{
                //TODO: Accept OR from the Configuration File, it can be ! or anything else
            //  operatorInsert("OR","left");
            //}
        }
        if(vExpression[0])
        {
            clearSelection();
        }
}

function insertFeatureOptions(effTypeAtual)
{   
    var selectedContext = getSelectedContext();
    var vcategoryType = getEffSetting("categoryType", effTypeAtual);
    var vinsertAsRange = "";
    if(document.getElementById('insertAsRange') != null)
    {
        vinsertAsRange = document.getElementById('insertAsRange').checked;
    }
    RemoveEmptyRow();
    if (vcategoryType == DATE_CATEGORY || vcategoryType == CONTEXTDATE_CATEGORY)
    {
        var bSingleDateAllowed = isSingleDateAllowed(effTypeAtual);
        if(!bSingleDateAllowed){
            vinsertAsRange = true; //force this for date
        }
        insertDate(effTypeAtual,vinsertAsRange);        
    }
    else if (vcategoryType == SEQUENCE_CATEGORY)
    {
        insertStructure(effTypeAtual,vinsertAsRange);
    }
    else if (vcategoryType == RELATIONAL_CATEGORY)
    {
        insertRelational(effTypeAtual,vinsertAsRange);
    }
    else if(vcategoryType == MILESTONE_CATEGORY)
    {
        vinsertAsRange = (bForFiltering == true)?false:true;
        insertMilestoneStructure(effTypeAtual,vinsertAsRange); //always as range. If only one is selected, the other is infinity
    }
	else if (vcategoryType == "series")
	{
		insertSeries(effTypeAtual,vinsertAsRange);
	}    
    if(selectedContext!="Global" && vcategoryType != DATE_CATEGORY && vcategoryType != CONTEXTDATE_CATEGORY ){
    UpdateEmptyrow();
    }
}
function getStructureValues(iframeName)
{
    var sourceFrame = findFrame(window, iframeName);
    var checkedItem = sourceFrame.getCheckedCheckboxes();
    if(Object.keys(checkedItem).length === 0)
    {
    	giveAlert("USER_SELECTION");
    	return 0;
    }
    else
    {
    var i = 0;
    var commonParentLength = 0;
    var selectedContexts = new Object();
    for(var key in checkedItem)
    {
        var temp = checkedItem[key];
        var tempArr = temp.split("|");
        var relId = tempArr[0];
        var objId ="";
        //@x56 geting Physical ID for PR
    	if(iframeName == "mx_iframeProductRevision")
    	{
    		 var vURL = "../effectivity/EffectivityUtil.jsp?mode=getPhysicalId&mpId="+tempArr[1];
    		 var vRes = emxUICore.getData(vURL);
    		 objId = trim(vRes);
    	}
    	else
    	{
    		objId = tempArr[1];
    	}
        var parentId = tempArr[2];
        var rowId = tempArr[3];

        if(relId == "")
        {
            parentId = objId;
            objId = "";
        }
        if(selectedContexts[parentId] == null || selectedContexts[parentId] == undefined || selectedContexts[parentId] == "undefined")
        {
            commonParentLength++;
        }
        if(iframeName == "mx_iframeProductRevision")
        var objColumnFN  = sourceFrame.colMap.getColumnByName("Product Revision");
        else
        var objColumnFN  = sourceFrame.colMap.getColumnByName("SequenceSelectable");
        var columnName = objColumnFN.name;
        var selSeq = sourceFrame.emxEditableTable.getCellValueByRowId(rowId ,columnName);
        var selectedValues = selectedContexts[parentId];
        
        if(!selectedValues)
            {
            selectedValues = new Array();
            selectedContexts[parentId] = selectedValues;
            }
        if (selSeq.value.current.actual != "")
        {
            var selectedObj = new Object();
            selectedObj["objId"]=objId;
            selectedObj["seqSel"]=selSeq.value.current.actual;
            selectedValues[selectedValues.length]=selectedObj;
        }
        i++;

    }
    }
    selectedContexts.length=commonParentLength;
    return selectedContexts;
}

function getStructureRelationalValues(iframeName)
{
    var sourceFrame = findFrame(window, iframeName);
    var checkedItem = sourceFrame.getCheckedCheckboxes();
    var i = 0;
    var commonParentLength = 0;
    var selectedContexts = new Object();
    for(var key in checkedItem)
    {
        var temp = checkedItem[key];
        var tempArr = temp.split("|");
        var relId = tempArr[0];
        var objId = tempArr[1];
        var parentId = tempArr[2];
        var rowId = tempArr[3];
	//to get type of object
        var objColumnFN  = sourceFrame.colMap.getColumnByIndex(0);      
	var columnName = objColumnFN.name;
	var selSeq = sourceFrame.emxEditableTable.getCellValueByRowId(rowId ,columnName);
	var objType = selSeq.type;
                
        if(ConfigOptionSubtypes.indexOf(objType) == -1)
    	{
            //It is root node
        	giveAlert("INVALID_INPUT_VALUE");
        	clearAllCheckedNodes(getActiveEffectivityType());
        	UpdateEmptyrow();
        	return 0;
    	}
        else
	    {
        
	        
	        if(relId == "")
	        {
	            parentId = objId;
	            objId = "";
	        }
	        if(selectedContexts[parentId] == null || selectedContexts[parentId] == undefined || selectedContexts[parentId] == "undefined")
	        {
	            commonParentLength++;
	        }
	        var selectedValues = selectedContexts[parentId];        
	        if(!selectedValues)
	        {
	            selectedValues = new Array();
	            selectedContexts[parentId] = selectedValues;
	        }
	        
	        var lvlArr = rowId.split(",");
	        var contextLvlId = lvlArr[0]+","+lvlArr[1];
	        
	        var temp = "/mxRoot/rows//r[@id ='" + 0 + "']";
	        var contextObjRow = emxUICore.selectSingleNode(sourceFrame.oXML.documentElement,temp);
	        var caontextObjId = contextObjRow.getAttribute("o");                
	        var selectedObj = new Object();
	        selectedObj["objId"]=objId;
	        selectedObj["relId"]=relId;
	        selectedObj["parentId"]=parentId;
	        selectedObj["contextId"]=caontextObjId;
	        selectedValues[selectedValues.length]=selectedObj;
	
	        i++;
	        
	    }
    }
    selectedContexts.length=commonParentLength;
    return selectedContexts;
}

function getStructureRelationalValuesForGlobal(iframeName)
{
    var sourceFrame = findFrame(window, iframeName);
    var checkedItem = sourceFrame.getCheckedCheckboxes();
    var selCount = 0;
    ///Code to get Column data
    var xmlRef  = sourceFrame.oXML;
    //var changedRXML   =   emxUICore.selectNodes(xmlRef, "/mxRoot/rows//r[@status='changed' or @status='cut' or @status='add']");
    var changedRXML     =   emxUICore.selectNodes(xmlRef, "/mxRoot/rows//r");
    if(changedRXML.length == 0){
        giveAlert("USER_SELECTION");
        return 0;
    }else{
        var modifiedRowData = new Array(changedRXML.length);            
        var selectedContexts = new Object();            
        for(var k = 0; k < changedRXML.length; k++){
          var objId =changedRXML[k].getAttribute("o");
          var status = changedRXML[k].getAttribute("status");             
          var childNodes=changedRXML[k].childNodes;           
          for(var count1 = 0; count1 < childNodes.length ; count1++){
              if(count1!=0){
                  selectedValues = new Array();
                  var IsEdited = childNodes[count1].getAttribute("edited");
                  var checkColumnvalue = childNodes[count1].getAttribute("a");
                  var vProcess = 'true';
                  if(checkColumnvalue=="-" && IsEdited==null){
                      vProcess = 'false';
                  }
                  if(childNodes[count1].tagName == "c" && vProcess == 'true'){
                      columnName =  sourceFrame.colMap.getColumnByIndex(count1).name;
                      var vParentId = "&ColumnId=" + columnName;
                      
                      if(IsEdited=='true'){
                          var columnvalue = childNodes[count1].getAttribute("newA");
                          //Do AJAX call to get the RelId
                          //var vChildId =columnvalue;
                          var vChildId = "&ValueSelectedInCell=" + columnvalue;
                          var url = "../effectivity/EffectivityUtil.jsp?mode=getRelationshipId" + vParentId + vChildId;
                          var vRes = emxUICore.getData(url);
                          var relId = trim(vRes);
                          
                      }else{
                          var rowRelId = sourceFrame.document.getElementsByName("relationshipId")[0].value;
                          var vRowRelId = "&RelId=" + rowRelId;
                          //AJAX call to get cell  value
                          var url = "../effectivity/EffectivityUtil.jsp?mode=getCellValueObjectId" + vParentId + vRowRelId;
                          var vRes = emxUICore.getData(url);
                          var vSelOptionInfo = trim(vRes).split("|");
                          var columnvalue = vSelOptionInfo[0];
                          var relId= vSelOptionInfo[1];
                      }
                     
                      var selectedObj = new Object();
                      selectedObj["objId"]=columnvalue;
                      selectedObj["relId"]=relId;
                      selectedObj["parentId"]=columnName;
                      selectedObj["contextId"]=globalContextPhyId;
                      selectedValues[count1] = selectedObj;
                      selectedContexts[columnName] = selectedValues;
                      selCount++;
                }
            }
         }
       }
    }
    selectedContexts.length=selCount;
    return selectedContexts;
}


function clearSelection()
{
    //alert("need to be reviewed....");
    //return;
     var sourceFrame = findFrame(window, "EffectivitySourceList");
     sourceFrame.clearAllCheckedItems();
     
     var checkedItem = sourceFrame.getCheckedCheckboxes();
     //alert("checkedItem="+checkedItem);
     //var temp;
     //var i = 0;
    // var checkedId = "";
     //var checkedEl = "";
     //for(var key in checkedItem)
    // {
    //   temp = checkedItem[key]
    //   temp = temp.split("|")
    //   checkedId = "rmbrow-"+temp[3] 
    //   checkedEl = sourceFrame.document.getElementById(checkedId);
    //   checkedEl.checked=false;
    //   alert("checkedEl.className="+checkedEl.className);
    //   checkedEl.className = checkedEl.className.replace(' mx_rowSelected' , '');
    //   checkedEl.className = checkedEl.className.replace('mx_rowSelected' , '');

    // }
     
}

//creates expression array to be loaded in Expression Builder panel
function formLeftExp(curExpArr,curExpArrAc){
    if(curExpArr == null || (curExpArr != null && curExpArr.length < 1))
    {
        return;
    }
    
    var expArr = new Array();
    var expArrAc = new Array();
    if(curExpArr != null)
    {
        var currentEffExprList = curExpArr.split("@delimitter@");
        if(currentEffExprList != null && currentEffExprList[0] != null)
        {
            var idx = 0; 
            for (var i=0; i < currentEffExprList.length; i++ ) {
                expArr[idx] = currentEffExprList[i];
                idx++;
            }
        }    
    }

    if(curExpArrAc!=null)
    {
        var currentEffExprListAc = curExpArrAc.split("@delimitter@");
        if(currentEffExprListAc != null && currentEffExprListAc[0] != null)
        {
            var idx = 0; 
            for (var i=0; i < currentEffExprListAc.length; i++ ) {
                expArrAc[idx] = currentEffExprListAc[i];
                idx++;
             }
        }
    }   
    
    formExpression(expArr,expArrAc) ;

} // end of function
function formExpression(expArr,expArrAc) {
    var insertExp = document.BCform.LeftExpression;
    var computeRule = "" ;
    for (var vCount = 0 ; vCount < expArr.length ; vCount++ ){      
        var vFeatureName = expArr[vCount];
        var vFeatureId = expArrAc[vCount];

        var vFName = trim(vFeatureName);
        var VFId = trim(vFeatureId);

        if (vFName ==""){
            continue;
        }
        // Logical Operators 
        if ( vFName == "AND" || vFName == "OR" || vFName == "NOT" || vFName == "(" || vFName == ")")
        {
            computeRule =  computeRule +" "+ "<B>" + vFName+" " + "</B>" ; 
            addOption(insertExp,vFName,vFName,"Operator");
        
        }else {
            computeRule =  computeRule +" "+ "<B>" + vFName+" " + "</B>" ; 
            addOption(insertExp,vFName,VFId,"Operand");
        }
    }

}
//gets options' value and sets them accordingly 
function computedRule(tmpOperator,textarea)
{
    var leftExp = document.BCform.LeftExpression;
    var leftExpText = "";
    var completedRuleText = "";
    var completedRuleActual = "";
    var completedRuleTextList = "";
    var completedRuleActualList = "";
    var computeRule             = "" ;

    for (var i = 0; i < leftExp.length; i++)
    {
    	if(leftExp.options[i].value != "EF_FO_EF_MS")
        leftExpText = leftExpText + leftExp.options[i].text.htmlEncode() + "\n";
    }

    //populates data to the completed expression
    updateCompleteDisplayExp(getSelectedContext(), leftExpText, completedDisplayExpressionArr);

} // end of function

function OnSelectFocus()
{
     if (document.getElementById("divSelect").scrollLeft != 0)
    {
        document.getElementById("divSelect").scrollLeft = 0;
    }

    var lstExp = document.getElementById('IncExp');
    
    if( lstExp.options.length > 10)
    {
        lstExp.focus();
        lstExp.size=10;
    }
}
function OnDivScroll()
{
    var lstExp = document.getElementById("IncExp");
    if (lstExp.options.length > 10)
    {
        lstExp.size=lstExp.options.length;
    }
    else
    {
        lstExp.size=10;
    }
}
function updateDateFieldArray(dateIndex, vFieldName) {
    
    var newField = vFieldName;
    var oldField;
    for ( var i = dateIndex; i < lastDateIndex && newField != ""; i++) {
        oldField = dateFieldArray[i];
        dateFieldArray[i] = newField;
        newField = oldField;
    }
}
function formDateFieldArray() {
    dateFieldArray = new Array;
    var date;
    for ( var i = 0; i < lastDateIndex ; i++) {
        date = "Date"+(i+1);
        dateFieldArray[i] = document.getElementById(date+"_msvalue").id;
    }
}

function removeDateField() {
    if(lastDateIndex == 2)
    {
        giveAlert("DATE_FIELD_DELETION_RESTRICT");
        return;
    }
    var fieldName = "Date" +lastDateIndex;
    var dateEl = document.getElementById(fieldName);
    var parentTD = dateEl.parentNode;
    var parentTR = parentTD.parentNode;
    localCalendars[fieldName] = null;
    parentTR.parentNode.removeChild(parentTR);
    dateEl.parentNode.removeChild(dateEl);
    lastDateIndex--;
    formDateFieldArray();
    
}
//function getModeTypes()
// To be called only after setEffectivityTypes
//Set some of the modes to be used on the selectorTable
function clear(fieldName) {
    var dateEl = document.getElementById(fieldName);
    var dateValue = dateEl.value;
    dateEl.value = "";
    formDateFieldArray();
    
}
function getModeMenu(EffModeValue)
{
    var vURL = "../effectivity/EffectivityUtil.jsp?mode=getModeValue&menuName="+EffModeValue;
    var vRes = emxUICore.getData(vURL);
}

/*
 * returns boolean whether allowSingleDate is true or not
 * set this to true if CFF Dialog is invoked fromCFFToolbar or modeType is filter   
 */
function isSingleDateAllowed(effTypeActual){    
    if(bDefaultAllowSingleDate == true){
        return true;
    }
    
    var allowSingleDate = getEffSetting(SETTING_ALLOWSINGLEDATE, effTypeActual);
    return ((allowSingleDate=="true")?true:false);
}

function insertDateField(dateIndex, effTypeActual){
    var vFieldName;
    var expDisplayField;
    var nextDateIdx = parseInt(dateIndex) + 1;
    lastDateIndex++;   
    expDisplayField =  DATE_TEXT;
    vFieldName = "Date" + lastDateIndex;
    var vFieldName_msVal = vFieldName+"_msvalue";
    expValue = expDisplayField + " " + lastDateIndex;
    var bAllowSingleDate = isSingleDateAllowed(effTypeActual);
    if(!bAllowSingleDate){
        expValue = (dateIndex==1)?DATE_START_TEXT:DATE_END_TEXT;
    }
    
    var tbody = document.getElementById("mx_divSourceList").getElementsByTagName("TBODY")[0];
    var table = document.getElementById("mx_divSourceList").getElementsByTagName("TABLE")[0];
    if(tbody == null)
    {
        tbody = document.createElement("TBODY");
    }   
    table.appendChild(tbody);
    var row = document.createElement("TR");
    var td1 = document.createElement("TD");
    td1.className="label";
    td1.style.position="relative";
    td1.appendChild(document.createTextNode(expValue));
    var td2 = document.createElement("TD");
    td2.appendChild(document.createTextNode(""));
    var td3 = document.createElement("TD");
    td3.className="field";
    //var input1=document.createElement("INPUT");
    var input1=createNamedElement("INPUT",vFieldName);
    //input1.name= vFieldName;
    input1.id= vFieldName;
    input1.readOnly="readOnly";
    input1.type="text";    
    td3.appendChild(input1);
    //Create hidden field to store the millisecond value
    var input1_ms=createNamedElement("INPUT",vFieldName_msVal);
    //input1.name= vFieldName;
    input1_ms.id= vFieldName_msVal;
    input1_ms.type="hidden";    
    td3.appendChild(input1_ms);
    var td4 = document.createElement("TD");
    td4.appendChild(document.createTextNode(""));
    var td5 = document.createElement("TD");
    var anchor1=document.createElement("A");
    anchor1.href="javascript:showCalendar(\"BCform\",\""+vFieldName+ "\",\"\")";
    var img1=document.createElement("IMG");
    img1.src="../common/images/iconSmallCalendar.gif";
    img1.border="0";
    img1.valign="absmiddle";
    anchor1.appendChild(img1);
    td5.appendChild(anchor1);
    
    var td6; var td7; var td8; var td9;
    if(bAllowSingleDate){
    
        td6 = document.createElement("TD");
        td2.appendChild(document.createTextNode(""));
        td7 = document.createElement("TD");
        //var input2=document.createElement("INPUT");
        var input2=createNamedElement("INPUT","addDate");
        input2.type="button";
        //input2.name="addDate";
        input2.value="+";
        if(isIE){
            input2.onclick = function() {
            insertDateField(nextDateIdx, effTypeActual);
                  };
        }else{
            input2.setAttribute("onclick","insertDateField('"+ nextDateIdx + "','" + effTypeActual+ "')");
        }
        td7.appendChild(input2);
        td8 = document.createElement("TD");
        td2.appendChild(document.createTextNode(""));
        td9 = document.createElement("TD");
        var input3 = createNamedElement("INPUT","addDate");
        //var input3=document.createElement("INPUT");
        input3.type="button";
        //input3.name="addDate";
        input3.value="-";
        if(isIE){
            input3.onclick = function() {removeDateField(vFieldName);};
         }else{
             input3.setAttribute("onclick","removeDateField(\"" + vFieldName + "\")");
        }
        td9.appendChild(input3);
    }
    var anchor2=document.createElement("A");
    anchor2.href="javascript:clear(\"" +vFieldName_msVal+"\")"+",clear(\"" +vFieldName+"\")";
    var img2=document.createElement("IMG");
    img2.src="../common/images/iconActionUndo.gif";
    img2.border="0";
    img2.valign="absmiddle";
    anchor2.appendChild(img2);
    var td10 = document.createElement("TD");
    td10.appendChild(anchor2);
    row.appendChild(td1);
    row.appendChild(td2);
    row.appendChild(td3);
    row.appendChild(td4);
    row.appendChild(td5);
    if(bAllowSingleDate){
        row.appendChild(td6);
        row.appendChild(td7);
        row.appendChild(td8);
        row.appendChild(td9);
    }
    row.appendChild(td10);
    tbody.appendChild(row);
    formDateFieldArray();
}


//The NAME attribute cannot be set at run time on elements dynamically created with the createElement method. 
//To create an element with a name attribute, include the attribute and value when using the createElement method.
//eg: document.createElement("<input name='brian' />")
//The browser creates an element with the invalid type="<input name='brian'>". This is what Netscape 7.1 and Opera 8.5 do
//The code simply tries to create the element using the Internet Explorer method first; if this fails it uses the standard method.
function createNamedElement(type, name) {
       var element = null;
       // Try the IE way; this fails on standards-compliant browsers
       try {
          element = document.createElement('<'+type+' name="'+name+'">');
       } catch (e) {
       }
       if (!element || element.nodeName != type.toUpperCase()) {
          // Non-IE browser; use canonical method to create named element
          element = document.createElement(type);
          element.name = name;
       }
       return element;
    }

/*
 * insert Date content for either Date or Context Date Effectivity Types
 */
 function insertDateContent(dateType){
    var divName = "mx_div" +  dateType + "Body";
    var target = document.getElementById(divName); 
    var optionResponse = "";
    var vFieldName;
    var element = document.createElement("table");
            
    element.cellpadding = 0;
    element.cellspacing = 0;
    optionResponse = "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">";
    optionResponse = optionResponse + "</table>";   
    var input1=createNamedElement("table", vFieldName);
    target.innerHTML = optionResponse;
    target.appendChild(element);    
    lastDateIndex = 0;  
    for(var i=1; i<=2; i++) 
    {
        insertDateField(i, dateType);
        updateDateFieldArray(i-1, vFieldName);
    }   
}

/*
 * adds effectivty types' command settings\values as hidden input elements
 * if effectivity types do not exist in the system, they get removed from list
 */
function addSettingFields()
{
    if(currentEffTypesArrActual != null && currentEffTypesArrActual[0] != null)
    {
        for (var i=0; i < currentEffTypesArrActual.length; i++ ) 
        {
            var jsonString = "";
            var URL = "../effectivity/EffectivityServices.jsp?mode=getSettings&effActual="+currentEffTypesArrActual[i];
            jsonString = emxUICore.getData(URL);
            if(jsonString.indexOf("categoryType") > -1){
                var settingFieldName = "EffSettingsField_" + currentEffTypesArrActual[i];
                var element = document.createElement("input");
                element.setAttribute("type", "hidden");
                element.setAttribute("name", settingFieldName);
                element.setAttribute("id", settingFieldName);
                element.setAttribute("value", jsonString);
                document.BCform.appendChild(element);
            } else {
                //the currentEffTypesArrActual[i] does not exist in the system
                //remove it from the list
                currentEffTypesArr.splice(i,1);
                currentEffTypesArrActual.splice(i,1);
                i--;//reposition index
            }            
        }
    }
}

/*
 * adds effectivity types to global array
 */
function getEffTypes()
{
    var idx = 0; 
    if (typeof(currentEffTypes)=='undefined')
    {
        return;
    }
    if(currentEffTypes != null && currentEffTypes[0] != null)
    {
        for (var i=0; i < currentEffTypes.length; i++ ) {
            if (currentEffTypes[i].checked) {   
                var displayActual = currentEffTypes[i].value.split("@displayactual@");
                currentEffTypesArrActual[idx] = displayActual[0];
                currentEffTypesArr[idx] = displayActual[1];
                idx++;
            }
        }
    }
    else
    {   
        if (currentEffTypes.checked) {
            var displayActual = currentEffTypes.value.split("@displayactual@");
            currentEffTypesArrActual[0] = displayActual[0];
            currentEffTypesArr[0] = displayActual[1];
        }
    }    
}

/*
 * commands' settings take precedence over url's parameters
 */
function displayOperatorEffTypeSetting(vActualType)
{
     //range checkbox
     var rangeCheckbox = document.getElementById("rangeCheckbox");
     var insertAsRange = document.getElementById("insertAsRange");
     var allowRange = getEffSetting(ALLOW_RANGE, vActualType );
     if(rangeCheckbox){
         if(allowRange != null && allowRange == "true"){
             rangeCheckbox.style.visibility = "visible";
         } else {
             rangeCheckbox.style.visibility = "hidden"; 
         }
         
         if(rangeCheckbox.style.visibility == "hidden"){
             insertAsRange.checked = false;
         }
     }
     
     //operators
     var orButton = document.getElementById("or");
     var showOr = getEffSetting(SHOW_OR, vActualType); 
     if(orButton){
         orButton.style.visibility = (showOr != null && showOr == 'false')?'hidden':'visible';
         
         //for default operator for milestones
         if(vActualType == "Milestone" || vActualType == UNIT_EFFECTIVITY_TYPE || vActualType ==  DATE_EFFECTIVITY_TYPE){
        	 orButton.className = "on";
			 orButton.style.backgroundColor = "#35b128";
         }        	 
         else {
        	 orButton.className = "off";
			 orButton.style.backgroundColor = "#d3d3d3";
         }
         //
     }

     var andButton = document.getElementById("and");
     var not = document.getElementById("not");
     var showAnd = getEffSetting(SHOW_AND, vActualType );

     if(andButton){
         if(showAnd != null && showAnd == 'false' || getSelectedContext()== "Global"){
             andButton.style.visibility = 'hidden';
             if(not!=null){
             not.style.visibility = 'hidden';
             }
         } else {
        	 if(vActualType ==  "ContextDate")
             {
                             andButton.style.visibility = 'hidden';
                             if(not!=null){
                             not.style.visibility = 'hidden';
                             }
                             orButton.className = "on";
							 orButton.style.backgroundColor = "#35b128";
             }
             else{
             andButton.style.visibility = 'visible';
             if(not!=null){
             not.style.visibility = 'visible';
             }
			 andButton.className="on";
			 andButton.style.backgroundColor = "#35b128";
         }

         }
     }   

     var infinityButton = document.getElementById("infinity");
     var showInfinity = getEffSetting(SHOW_INF, vActualType);
     if(infinityButton){
         infinityButton.style.visibility = (showInfinity != null && showInfinity == 'false')?'hidden':'visible';
     }  
}


function callPostProcessURL()
{
    if(!postProcessURL)
    {
        finalSubmit();
        return;
    }
    var params = getPostProcessURLParams();
    var postProcessURLWithParams = postProcessURL;
    if(params!="")
        postProcessURLWithParams+="?"+params;
    //Next Gen-Starts--commented below for Next Gen
    //var sHTML = emxUICore.getDataPost(postProcessURLWithParams, params);
    showPostProcessURLPopup(postProcessURLWithParams);
}

function getPostProcessURLParams()
{
    var Params = "";
    //get compelte expression 
    var completeExp = getCompleteExpression(contextExpressionArr);
    
    var actualExpression = completeExp.completedRuleActual;//document.BCform.completedRuleActual.value;

    if(actualExpression!="")
    {
        Params+="actualExpression="+actualExpression;
        var displayExpression = completeExp.completedRuleText;//document.BCform.completedRuleText.value;
        if(displayExpression!="");
            Params+="&displayExpression="+displayExpression;
    }
    if(MODE!=null)
    {
        Params+="&modetype=" + MODE;
    }
    Params+="&objectId="+objectId;
    Params+="&parentOID="+parentOID;
    
    return Params; 
}

function showPostProcessURLPopup(iHTML)
{
    var popUp = document.getElementById("PostProcessURLPopup");
    if(!popUp)
        popUp = createPostProcessURLPopup();

    var doc  = popUp.contentWindow.document;
    /*Next Gen-Starts--Passing the control postProcessURL instead constructing HTML and writing into the document
    doc.open();
    alert("iHTML-->"+iHTML);
    doc.write(iHTML);
    doc.close();   
    Next Gen-Ends*/
    doc.location.href = iHTML;
    popUp.style.display="block";    
}

function closePostProcessURLPopup()
{
    var popUp = document.getElementById("PostProcessURLPopup");
    if(popUp)
        popUp.style.display="none"; 
}

function createPostProcessURLPopup()
{
    var popUp = document.createElement("iframe");
    popUp.setAttribute("id", "PostProcessURLPopup");
    popUp.style.display="none";
    popUp.style.position="absolute";
    popUp.style.top = "0px";
    popUp.style.left = "0px";
    popUp.style.width = "100%";
    popUp.style.height = "100%";
    popUp.style.border ="1px solid #CCC";
    popUp.style.backgroundColor="white";
    document.body.appendChild(popUp);
    return popUp;
}

function submitRule(){

    showValidMsg = false;
    var selectedContext = getSelectedContext();
    
    //save current expression 
    if(selectedContext != "undefined" && selectedContext != ""){
        updateCompleteExpression(selectedContext);  
    }
    
    //check if the list of expressions already contain error or not
    //var vRes = fnValidate(false, true);//validate the expression of context being selected or full expression     
    var cxtErrorList = getInvalidContextsExpErrors(contextExpressionArr);
    if(cxtErrorList != ""){
        giveAlert("REVIEW_INVALID_EXPRESSION", cxtErrorList);
        return; 
    }
    
    //validate the expression of context being selected or full expression
    var vRes = fnValidate(false, true);
        
    if(vRes == "true")
    {
        callPostProcessURL();
    }
    else
    {
        showValidMsg = true;
        return;
    }
}

/*
 * adds AND and NOT buttons\operators
 */
function addANDNOTButtons()
{
    /* bShowSingleOperator logic is applicable to only PUE
     * 1) Remove bShowSingleOperator for now and needs to be addressed completely in R2014x
     * 2) If there's only Effectivity and it is PUE (Unit), AND and NOT operators are not needed
     */
    //if(bShowSingleOperator)
    //{
        if(currentEffTypesArrActual && currentEffTypesArrActual.length < 2){
            if(currentEffTypesArrActual[0] == UNIT_EFFECTIVITY_TYPE){
                return; 
            }
            else if (currentEffTypesArrActual[0] == DATE_EFFECTIVITY_TYPE){
            	return; 
            }
        }       
    //}
    //END
    
    //1. Get the operators table
    var operatorsTable = document.getElementById("operatorsTable");
 
    if(operatorsTable)
    {
        //2. Get the OR Button
        var liANDPrevButton = document.getElementById("li-or");

        //3. create the AND button
        var liAND = document.createElement("li");
        liAND.id = "li-and";
        var ANDButton = document.createElement("input");
        ANDButton.setAttribute('type', 'button');
        ANDButton.setAttribute('name', 'and');
        ANDButton.setAttribute('id', 'and');
        ANDButton.setAttribute('value', 'AND');
        ANDButton.setAttribute('class', 'on');        
        ANDButton.setAttribute('onclick', 'togglestyle(this)');
        
        
       /* ANDButton.onclick = function() {
                operatorInsert("AND","left");
                computedRule("AND","left");
                  };*/
        liAND.appendChild(ANDButton);         

        //5. Get the right parenthesis button
        var rParenButton = document.getElementById("r-paren");
        if(rParenButton == 'undefined')
            return;

        var liRParenButton = document.getElementById("li-r-paren");

        //6. create the NOT button - but only if not on a filter dialog
        if (!bForFiltering)
        {
           var liNOT = document.createElement("li");
           liNOT.id = "li-not";
           var NOTButton = document.createElement("input");
           NOTButton.setAttribute('type', 'button');
           NOTButton.setAttribute('name', 'and');
           NOTButton.setAttribute('id', 'not');
           NOTButton.setAttribute('value', 'NOT');
           NOTButton.onclick = function() {
              operatorInsert("NOT","left");
              computedRule("NOT","left");
           };
           liNOT.appendChild(NOTButton);

        var liRParenButton = document.getElementById("li-r-paren");
           operatorsTable.insertBefore(liNOT, liRParenButton);

           //4. Add the AND button before the OR button
           if(liANDPrevButton == 'undefined' || liANDPrevButton == 'null' || liANDPrevButton == null){
              liANDPrevButton = liNOT;
           }
      
           //firstData.insertBefore(ANDButton, ANDPrevButton);
           operatorsTable.insertBefore(liAND, liANDPrevButton);
        }
        else
        {
            //firstData.insertBefore(ANDButton, ANDPrevButton);
            operatorsTable.insertBefore(liAND, liANDPrevButton);       	
        }

    }
}

/*
 * returns value from command setting given setting name and effectivity type
 */
function getEffSetting(settingName, effType)
{
    var EffSettingVal = null;
    var effSettingsField = document.getElementById("EffSettingsField_"+effType);
    if(effSettingsField)
    {
        var EffJSONString = effSettingsField.value;
        if(EffJSONString && EffJSONString != "")
        {
            var EffSettingsObj = emxUICore.parseJSON(EffJSONString);
            if(EffSettingsObj)
            {
                EffSettingVal = EffSettingsObj[settingName];
            }
        }
    }
    if(EffSettingVal == null || EffSettingVal =="null" || EffSettingVal == ""){
        return null;    
    }       
    
    return EffSettingVal;
}

/*
 * returns value from command setting given setting name and effectivity type's keyword
 */
function getEffSettingByKeyword(settingName, effKeyword)
{
    var EffSettingVal = null;
    //Run through all the setting fields looking for the keyword
    if(currentEffTypesArrActual != null && currentEffTypesArrActual[0] != null)
    {
        for (var i=0; i < currentEffTypesArrActual.length; i++ ) 
        {
            var keywordVal = getEffSetting(SETTING_KEYWORD, currentEffTypesArrActual[i]);
            if (keywordVal == effKeyword)
            {
               EffSettingVal = getEffSetting(settingName, currentEffTypesArrActual[i]);
               break;
            }
        }
    }
    return EffSettingVal;
}
/*
* returns name of eff from the given effectivity type's keyword
*/
function getEffTypeName(effKeyword)
{
	 var EffType = null;
    //Run through all the setting fields looking for the keyword
    if(currentEffTypesArrActual != null && currentEffTypesArrActual[0] != null)
    {
        for (var i=0; i < currentEffTypesArrActual.length; i++ ) 
        {
            var keywordVal = getEffSetting(SETTING_KEYWORD, currentEffTypesArrActual[i]);
            if (keywordVal == effKeyword)
            {
               EffType = currentEffTypesArrActual[i];
               break;
            }
        }
    }
    return EffType;

}
/*
 * closes or opens panel\section
 * behaviors: 1) allow all panels in collapsed\closed state
 *            2) do not show blank panel in active state    
 */
function togglePanel(panelDiv, classOpen, classClosed, toggleDiv){
    var divTmp = document.getElementById(panelDiv);
    if(panelDiv!=null && panelDiv!="mx_divContent"){
        setFramePreference(panelDiv);
        }
    var toggleDivTmp = document.getElementById(toggleDiv);
    var currentState = divTmp.className;
    
    /* Special use-cases
     * 1) Global context\model is only applicable to Date/ContextDate and Feature Option
     * 2) For Design Variant panel, this only applies to EFF expression creation, NOT to Filter
     * 
     * Global Model\Context is removed, Global object is only applicable to Date
     */
    /* 
    if(globalContextPhyId == getSelectedContext() && panelDiv != "mx_divContent" &&
       panelDiv != (MX_DIV+DATE_EFFECTIVITY_TYPE)  && panelDiv != (MX_DIV+CONTEXTDATE_EFFECTIVITY_TYPE) && panelDiv != (MX_DIV+FEATURE_OPTION_EFF_TYPE)){
        giveAlert("NOT_APPLICABLE_TO_SELECTED_CONTEXT");
        return;
    } else if(!bForFiltering && globalContextPhyId == getSelectedContext() && panelDiv == (MX_DIV+FEATURE_OPTION_EFF_TYPE)){
        if(!hasDesignVariants(objectId)){
            giveAlert("NO_DESIGN_VARIANT_EXISTS");
            return;
        }       
    } else if(!bForFiltering && globalContextPhyId != getSelectedContext() && panelDiv == (MX_DIV+FEATURE_OPTION_EFF_TYPE)){
        if(hasDesignVariants(objectId)){
            giveAlert("SOME_DESIGN_VARIANT_EXISTS");
            return;
        }
    } else if(globalContextPhyId != getSelectedContext() && panelDiv == (MX_DIV+DATE_EFFECTIVITY_TYPE)){
        giveAlert("NOT_APPLICABLE_TO_SELECTED_CONTEXT");
        return;
    }*/
    
    if((globalContextPhyId == getSelectedContext() && panelDiv != "mx_divContent" && panelDiv != (MX_DIV+DATE_EFFECTIVITY_TYPE)) ||
       (globalContextPhyId != getSelectedContext() && panelDiv == (MX_DIV+DATE_EFFECTIVITY_TYPE))){ 		
        giveAlert("NOT_APPLICABLE_TO_SELECTED_CONTEXT");
        return;
    }
    	
    if(panelDiv && classOpen && classClosed && toggleDivTmp){
        if(currentState==classOpen){
            divTmp.className = classClosed;
            toggleDivTmp.title = CLICK_TO_OPEN;
        } else{
            divTmp.className = classOpen;
            toggleDivTmp.title = CLICK_TO_CLOSE;
        }   
    }
    
    //no further actions taken for source panels
    if(panelDiv == "mx_divContent"){
        return;
    }   
    
    /* processes only if trying to open some panel
       let the being opened panel take all the height
    */
    if(currentState==classClosed && currentEffTypesArrActual && currentEffTypesArrActual.length > 0){
        var sourceListDiv = document.getElementById("mx_divSourceList");
        var sourceListHeight = sourceListDiv.offsetHeight;
        var panelHeight = (sourceListHeight - (currentEffTypesArrActual.length * (24 + 2)));//+2px for borders
        var activePanel = "";
                
        //set height
        for(var i=0; i < currentEffTypesArrActual.length; i++){
            var effType = currentEffTypesArrActual[i];
            var divId = "mx_div"+effType;           
            if(panelDiv == divId){
                var divDateId = "";
                if(effType == DATE_EFFECTIVITY_TYPE){
                    divDateId = "mx_div" + DATE_EFFECTIVITY_TYPE + "Body";
                } else if(effType == CONTEXTDATE_EFFECTIVITY_TYPE){
                    divDateId = "mx_div" + CONTEXTDATE_EFFECTIVITY_TYPE + "Body";
                }
                var panelBodyorIframeId = (effType==DATE_EFFECTIVITY_TYPE || effType==CONTEXTDATE_EFFECTIVITY_TYPE)?divDateId:("mx_iframe"+effType);                
                var bodyorIframeObj = document.getElementById(panelBodyorIframeId);             
                bodyorIframeObj.style.height = (panelHeight - 5)+"px";//re-adjusts the heigth 
                break;
            } 
        }       
        
        //close others and set height to 0
        for(var j=0; j < currentEffTypesArrActual.length; j++){
            var effType = currentEffTypesArrActual[j];
            var divId = "mx_div"+effType;
            //skip the current one
            if(panelDiv == divId){
                continue;
            } else {
                var divDateId = "";
                if(effType == DATE_EFFECTIVITY_TYPE){
                    divDateId = "mx_div" + DATE_EFFECTIVITY_TYPE + "Body";
                } else if(effType == CONTEXTDATE_EFFECTIVITY_TYPE){
                    divDateId = "mx_div" + CONTEXTDATE_EFFECTIVITY_TYPE + "Body";
                }
                var panelBodyorIframeId = (effType==DATE_EFFECTIVITY_TYPE || effType==CONTEXTDATE_EFFECTIVITY_TYPE)?divDateId:("mx_iframe"+effType);                
                var bodyorIframeObj = document.getElementById(panelBodyorIframeId);
                bodyorIframeObj.style.height = "0px";//set to 0 height
                var divObj = document.getElementById(divId);
                divObj.className = classClosed;
                var toggleDiv = document.getElementById(divId+'Toggle');
                toggleDiv.title = CLICK_TO_OPEN;
            }           
        }
        
        //displays ui accordingly
        updateUI();
    }   
}
 
 /*
 * returns whether Global object needs to be displayed in Context Panel
 */
function isGlobalDate(){
    var globalDate = false;
    if(currentEffTypesArrActual != null && currentEffTypesArrActual.length > 0){
        for(var i=0; i < currentEffTypesArrActual.length; i++){
            var effType = currentEffTypesArrActual[i];
            if(DATE_EFFECTIVITY_TYPE == effType){
                globalDate = true;
                break;
            }           
        }       
    }

    return globalDate;
} 
 
/*
 * displays contexts in Context panel
 */
function loadContextPanel(action){
    var searchIconEle = document.getElementById("searchIcon");
    if(!bShowSearchIcon){
        searchIconEle.style.visibility = 'hidden';
    }
    //show global date
    var contextArray = new Array();
    if(bGlobalContext || isGlobalDate()){
        var globalContext = new Object();
        globalContext["actualValue"] = "Global";
        globalContext["displayValue"] = GLOBAL_TEXT;
        globalContext["physicalid"] = globalContextPhyId;
        globalContext["typeIcon"] = globalContextIcon;
        contextArray[0] = globalContext;
    }

    var contextList = (includeContextsInfo!=null && includeContextsInfo!="" && includeContextsInfo.length > 0)?emxUICore.parseJSON(includeContextsInfo):null;
    
    if(contextList != null && contextList.length > 0){
        for(var i=0; i < contextList.length; i++){
			contextList[i].displayValue=contextList[i].displayValue.htmlEncode();
            contextArray.push(contextList[i]);          
        }   
    }   

    if(contextArray != null && contextArray.length < 2 ){    	
    	togglePanel('mx_divContent','open','closed','mx_contextToggle');
    }
    if(contextArray != null && contextArray.length > 0){
        var cachedContextList = document.getElementById("cachedContextList");
        bContextExist = true;
        
        //create an unordered list and assign an id
        for(var n=0; n < contextArray.length; n++){
            var contextInfo = contextArray[n];
            var li = document.createElement("li");
            
            //span for input checkbox
            var spanInput = document.createElement("span");
            spanInput.className = "input";
            var input = document.createElement("input");            
            input.type = "radio";
            input.value = contextInfo.displayValue;
            input.id = contextInfo.physicalid;
            input.setAttribute("onclick", "javascript:updateContextSelection('" + input.id + "');");
            
            //set the first context in includeContextProgram selected
            if(n==0){
                input.setAttribute("checked", "checked");
                cachedContextList.selectedContext = contextInfo.physicalid;
            }
            
            spanInput.appendChild(input);
            spanInput.className = "icon";
            //span for icon
            if(contextInfo.typeIcon != "undefined" && contextInfo.typeIcon != ""){
                var spanIcon = document.createElement("span");          
                var img = document.createElement("img");
                var typeIcon = contextInfo.typeIcon;
                var imgSrc = "../common/images/";
                if(typeIcon != null && typeIcon != ""){
                    imgSrc += typeIcon;                     
                }
                img.src= imgSrc;
                spanIcon.appendChild(img);              
            }
            
            //text section
            var label = document.createElement("label");
            label.innerHTML = "&nbsp;" + contextInfo.displayValue;
            
            //append elements to proper parent          
            li.appendChild(spanInput);
            if(contextInfo.typeIcon != "undefined" && contextInfo.typeIcon != ""){
                li.appendChild(spanIcon);
            }
            li.appendChild(label);
            cachedContextList.appendChild(li);

        } //end for
    } // end if
    
}

/*
 * Searches for some context
 */
function searchContext(){
    //get search types from effectivity list
    var searchTypeArr= new Array();
    var searchTyepeStr = "";
    var includeOIDProgArr= new Array();
    var index = -1;
    if(currentEffTypesArrActual != null && currentEffTypesArrActual.length > 0){
        for(var i=0; i < currentEffTypesArrActual.length; i++){
            var effTypeActual = currentEffTypesArrActual[i];
            var searchTypeTmp = getEffSetting(SETTING_SEARCHTYPE, effTypeActual);
            /*
            if(searchTypeArr.length > 0 && searchTypeArr.indexOf(searchTypeTmp) < 0){
                searchTypeArr[++index] = searchTypeTmp;
            }*/

            if(searchTypeTmp != null && searchTyepeStr.indexOf(searchTypeTmp) < 0){
                searchTyepeStr += (searchTyepeStr!="")?","+searchTypeTmp:searchTypeTmp;             
            }
        }
    }

    var searchType = searchTypeArr.toString();
    if (searchTyepeStr!=null && searchTyepeStr!="")
    {   
        var sURL='../common/emxFullSearch.jsp?field=TYPES=' + searchTyepeStr +':CURRENT!=policy_Model.state_Inactive&table=AEFGeneralSearchResults&selection=multiple&formName=BCform&submitAction=refreshCaller&hideHeader=true&HelpMarker=emxhelpfullsearch&submitURL=../effectivity/EffectivityDefinitionSearch.jsp?fromOperation=search&selectedContext='+getSelectedContext();
        showChooser(sURL, 850, 630);
    } else {
        giveAlert("SEARCH_NOT_APPLICABLE");
    }
}

/*
 * toggles sellect\un-select all
 */ 
function selectContext(option){
    var bSelectAll = false;
    var cachedContextUL = document.getElementById('cachedContextList');
    if(option == "all"){
        bSelectAll = true;
    } else {
        cachedContextUL.selectedContext = "";
    }
    
    if(cachedContextUL && cachedContextUL.hasChildNodes()){
        var liArray = cachedContextUL.getElementsByTagName("li");
        if(liArray && liArray.length > 0){
            for(var i=0; i < liArray.length; i++){
                var liObject = liArray[i];
                var objArray = liObject.getElementsByTagName("input");
                if(objArray && objArray.length == 1){
                    objArray[0].checked = (bSelectAll)?true:false;
                }                                   
            }
        }
    }
}

/*
 * creates complete display expression array, which contains context's display value 
 */
function createCompleteDisplayExpArray(expressionsArray, displayExpressionArray){
    for(var i=0; i < expressionsArray.length; i++){
        var contextJSON = expressionsArray[i];
        var displayCxt = new Object();
        displayCxt["contextId"] = contextJSON.contextId;

        displayCxt["displayValue"] = contextJSON.displayValue;
		var tokens=contextJSON.displayValue.split(" ");
		var strEncodedStr="";
		for(var j=0;j<tokens.length; j++){
			var vTemp=tokens[j];
			vTemp=vTemp.htmlEncode();
			strEncodedStr=strEncodedStr+vTemp;
		}
		displayCxt["displayValue"]=strEncodedStr;
        displayExpressionArray[i] = displayCxt;
    }
}

 
/*
 * loads context data if one is selected by default
 */
function initialLoad(){
    //fill complete display expression array 
    createCompleteDisplayExpArray(contextExpressionArr, completedDisplayExpressionArr);
    
    var selectedContext = getSelectedContext();
    if(selectedContext != null && selectedContext!='undefined' && selectedContext!=""){
        if(selectedContext == globalContextPhyId){
            clearAll('left');
        }
    
        loadSelectedContext(selectedContext);
        updateDatePanelTitle(selectedContext);
        //fill in Expression Builder and Complete Expression panels
        if(contextExpressionArr != null && contextExpressionArr.length > 0){            
            for(var i=0; i < contextExpressionArr.length; i++){             
                var contextJSON = contextExpressionArr[i];
                if(selectedContext == contextJSON.contextId){
                    updateCompleteDisplayExp(selectedContext, contextJSON.displayValue, completedDisplayExpressionArr);
                    formLeftExp(contextJSON.contextRuleTextList, contextJSON.contextRuleActualList);
                    computedRule();                 
                    break;
                }
            } 
            if(contextExpressionArr != null && contextExpressionArr.length==1  && selectedContext=="Global"){
            	
            }else{
            	if(!(currentEffTypesArrActual.indexOf("ContextDate") > -1))
                addLastRow();
            }               
        
        }
		        if (selectedContext != null && selectedContext != ""
				&& selectedContext != "Global") {
			   var   enableAutoComplete = false;
			for ( var i = 0; i < currentEffTypesArrActual.length; i++) {
				var effType = currentEffTypesArrActual[i];
				if ("FeatureOption" == effType) {
					enableAutoComplete = true;
				} else if ("Milestone" == effType) {
					enableAutoComplete = true;
				}
			}
			if (enableAutoComplete) {
				addEmptyRow();
				LoadTextComplete(selectedContext);
			}
		}
    }
    
    // display completed expression
    var completedRule = "";
    for(var n=0; n < completedDisplayExpressionArr.length; n++){
        var cxtItem = completedDisplayExpressionArr[n];
        var tmpDiv = document.getElementById(cxtItem.contextId);
        var displayValue = cxtItem.displayValue;
        if(displayValue != null && displayValue != ""){
            var cxtDisplayValue = "<div class='completeExprOptions' onclick=changeContxextFromExpression('"+cxtItem.contextId+"')>" + tmpDiv.value + ": " + displayValue + "</div>";
            /*if(displayValue.indexOf("OR") >= 0 || displayValue.indexOf("AND") >= 0 || displayValue.indexOf("NOT") >= 0){
                cxtDisplayValue = tmpDiv.value + ": " + displayValue;
            }*/
            completedRule += (completedRule!="")?cxtDisplayValue:cxtDisplayValue;        
        }
    }

    if(completedRule != ""){
        var objDIV = document.getElementById("mx_divRuleText");
        completedRule = "<B>" + completedRule + "<B>";
        objDIV.innerHTML = completedRule.toString();        
    }

}

/*
 * Loads selected context in Context Panel - only one is allowed
 */
function loadSelectedContext(contextId){
    var selectedContext = (contextId)?contextId:getSelectedContext();
    if(selectedContext != null && selectedContext != ""){
        populateContextData(selectedContext); 
        LoadTextComplete(selectedContext);
       
   }
}
 
 /*
 * Fills up source panel  */
function populateContextData(selectedContextList){
    if(selectedContextList == null || selectedContextList == "undefined" || selectedContextList == "" || selectedContextList=="Global"){
        return;
    }
    /* goes through each Effectivity Type and fill in the data, except for Date Effectivity*/
    if(currentEffTypesArrActual != null && currentEffTypesArrActual.length > 0){
        for(var i=0; i < currentEffTypesArrActual.length; i++){
            var effTypeDisplay = currentEffTypesArr[i];
            var effTypeActual = currentEffTypesArrActual[i];
            var vcategoryType = getEffSetting(SETTING_CATEGORYTYPE, effTypeActual);
            //skip Date
            if(DATE_EFFECTIVITY_TYPE == effTypeActual || CONTEXTDATE_EFFECTIVITY_TYPE == effTypeActual) {
                continue;
            }
            var iframeId = MX_IFRAME + effTypeActual;
            var mx_iframeStructureListEl = document.getElementById(iframeId);
            
            //Via search    
            var vformatType = getEffSetting(SETTING_FORMAT, effTypeActual);         
            var searchType = getEffSetting(SETTING_SEARCHTYPE, effTypeActual);          
            var expandProgram = getEffSetting(SETTING_EXPANDPROGRAM, effTypeActual);
            var selectorToolbar = getEffSetting(SETTING_TOOLBAR, effTypeActual);
            var relationalCriteria = getEffSetting(RELATIONAL_CRITERIA, effTypeActual);
            var defnTable = getEffSetting(SETTING_TABLE, effTypeActual);
            var selection = getEffSetting(SETTING_SELECTION, effTypeActual);        
            var vExpandParam = "";
            var vSelectorToolbar = "";
            var vIncludeProg = "";

            if (selectorToolbar != "" && selectorToolbar != null && selectorToolbar != "null") 
            {
                vSelectorToolbar = "&" + SETTING_TOOLBAR + "=" + selectorToolbar;
            }
            
            if (expandProgram != "" && expandProgram != null && expandProgram != "null") //expandProgram takes presidence
            {
                vExpandParam = "&expandProgramCFF=" + expandProgram;
            }
            else //if expandProgram not there, then use relationship
            {
                expandProgram = getEffSetting(SETTING_RELATIONSHIP, effTypeActual);
                if (expandProgram != "" && expandProgram != null && expandProgram != "null")
                {
                    vExpandParam = "&relationshipCFF=" + expandProgram;
                }        
            }
            var vCategoryTypeParam = "&categoryType=" + vcategoryType; 
            var vFormatParam = "&formatType=" + vformatType;
            var vCffTable ="&cffTable="+defnTable;
            var vEffectivtyType = "&effectivityType=" + effTypeActual;    
            var vSelection = "&CFFselection=" + selection;
            var vSelectedContext = "&selectedContext=" + selectedContextList;
            var vTargetLocation = "&targetLocation=popup";
            var vTargetIframe = "&targetIframe=" + iframeId;
            var vROOTID = "&ROOTID=" + ROOTID;
            var vRELID = "&RELID=" + RELID;
            var vMode = "&mode=view";//default
            
            //construct SB url
            var sURL = "../effectivity/EffectivityDefinitionSearch.jsp?";
            sURL += vFormatParam;
            sURL += vSelection;
            sURL += vEffectivtyType;
            sURL += vSelectorToolbar;
            sURL += vCategoryTypeParam;
            sURL += vTargetLocation;
            sURL += vTargetIframe;
            sURL += vRELID;
            sURL += vROOTID;            
           
            //FTR's Specific Use-case: Global Context and Feature Option with root object has "Varies By" rel exist
            /*To Do:
             * 1) check to see if "Varies By" rel exists on root object -D
             * 2) If so, set defnTable to grid table
             * 3) Gather all settings required for this use-case (Global Context and Feature Option Eff Type)
             * 4) Others...
             */
             /*
             * Global Model is removed, hence this logic is not applicable
             */
            /* 
            if(!bForFiltering && globalContextPhyId == selectedContextList && FEATURE_OPTION_EFF_TYPE == effTypeActual){     
                var vContxtLFId =objectId;
                if(hasDesignVariants(vContxtLFId)){
                    vCffTable ="&cffTable="+"FTRGlobalFeatureOptionTable";
                    vSelectedContext = "&selectedContext=" + vContxtLFId;
                    var vObjectId = "&objectId=" + objectId;
                    var vContxtLFId = "&contxtLFId=" + vContxtLFId;
                    var vFromGlobalContextFO = "&FromGlobalContextFO=true";             
                    vExpandParam ="";
                    //specific info
                    vMode = "&mode=edit";
                    sURL += vObjectId;
                    sURL += vContxtLFId;
                    sURL += vFromGlobalContextFO;
                }
            } else {
                //effectivity discipline info is needed for Milestone category
                if(MILESTONE_CATEGORY == vcategoryType){
                    sURL += "&effectivityDiscipline=" + EFFECTIVITY_DISCIPLINE
                    sURL += "&fromFilterToolbar="+bForFiltering;
                }
            }*/
            
            //effectivity discipline info is needed for Milestone category
            if(MILESTONE_CATEGORY == vcategoryType){
                sURL += "&effectivityDiscipline=" + EFFECTIVITY_DISCIPLINE
                sURL += "&fromFilterToolbar="+bForFiltering;
            }            
            
            sURL += vMode;
            sURL += vCffTable;
            sURL += vSelectedContext;
            sURL += vExpandParam;            
            
            if (searchType!=null && searchType!=""){
                var mx_iframeStructureListEl = document.getElementById(iframeId);
                mx_iframeStructureListEl.src= sURL;
                //mx_iframeStructureListEl.contentWindow.location.href = sURL;
            }
            
        } //end for
    } // end if 
}

/*
 * If Milestone is present, Date\ContextDate should be removed from the list if they are present.
 * If there are Date and Context Date Effectivity Types present and Milestone is not, only one kind of date is allowed.
 * Context Date takes precedent over Date (Global Date). 
 */
function updateEffTypeList(){
    if(currentEffTypesArrActual != null && currentEffTypesArrActual.length > 0 &&
            currentEffTypesArr != null && currentEffTypesArr.length > 0){
        var dateEffType = false;
        var cxtDateEffType = false;
        var dateIndex = -1;
        var cxtDateIndex = -1;
        var milestoneIndex = -1;
        var isMilestoneCatPresent = false;
        var isDateCatPresent = false;
        var isCxtDateCatPresent = false;
        var categoryType = "";
        
        for(var i=0; i < currentEffTypesArrActual.length; i++){         
            var URL = "../effectivity/EffectivityServices.jsp?mode=getSettings&effActual="+currentEffTypesArrActual[i];
            var jsonString = emxUICore.getData(URL);                        
            if(jsonString.indexOf("categoryType") < 0){
                continue;
            } else {
                jsonString = emxUICore.parseJSON(jsonString);
                categoryType = jsonString['categoryType'];
                switch(categoryType){
                    case 'milestone':
                        isMilestoneCatPresent = true;
                        milestoneIndex = i;
                        break;
                    case 'date':
                        isDateCatPresent = true;
                        dateIndex = i;
                        break;
                    case 'contextDate':
                        isCxtDateCatPresent = true;
                        cxtDateIndex = i;
                        break;
                    default:;
                }
            }
        }

        //remove ContextDate and\or Date if Milestone is present
        if(isMilestoneCatPresent){
            if(isCxtDateCatPresent){
                currentEffTypesArr.splice(cxtDateIndex, 1);
                currentEffTypesArrActual.splice(cxtDateIndex, 1);                
            }
            if(isDateCatPresent){
                if(isCxtDateCatPresent){//since contextDate has been removed, repositioning dateIndex
                    dateIndex -= 1;
                }            
                currentEffTypesArr.splice(dateIndex, 1);
                currentEffTypesArrActual.splice(dateIndex, 1);
            }        
        } else if(isCxtDateCatPresent){
            if(isDateCatPresent){
                currentEffTypesArr.splice(dateIndex, 1);
                currentEffTypesArrActual.splice(dateIndex, 1);
            }
        }
    }
}

/*
 * Removes selected contexts in Context Panel 
 */
function removeSelectedContext(){
    var cachedContextUL = document.getElementById('cachedContextList');
    if(cachedContextUL && cachedContextUL.hasChildNodes()){
        var liArray = cachedContextUL.getElementsByTagName("li");
        if(liArray && liArray.length > 0){
            for(var i=0; i < liArray.length; i++){
                var liObject = liArray[i];              
                var objArray = liObject.getElementsByTagName("input");
                if(objArray && (objArray.length == 1) && objArray[0].checked){
                    cachedContextUL.removeChild(liObject);
                    i--;
                }
            }
        }
    }   
}

/*
 * Is called upon a different mode is selected
 */
 function onModeChanged(selectName, effTypeActual){
    /* 
    //if not active, do nothing    
    if(effTypeActual != getActiveEffectivityType()){
        return;
    } 
    */
    var vModeSelectBox =  document.getElementById(selectName);
    var jsonString = "";
    if(vModeSelectBox)
    {
        var vModeSelectedIndex = vModeSelectBox.selectedIndex;
        var vModeOptions = vModeSelectBox.options;
        var vModeSelectedOption = vModeOptions[vModeSelectedIndex];
        var vModeEffActual = vModeSelectedOption.value;
        
        //Get settings for selected mode
        var URL = "../effectivity/EffectivityServices.jsp?mode=getSettings&effActual="+effTypeActual+"&modeActual="+vModeEffActual;
        jsonString = emxUICore.getData(URL);   
    }
    else
    {
        var URL = "../effectivity/EffectivityServices.jsp?mode=getSettings&effActual="+effTypeActual;
        jsonString = emxUICore.getData(URL);
    }
    //reset settings for effectivity type
    var effSettingsField = document.getElementById("EffSettingsField_"+effTypeActual);
    effSettingsField.value = jsonString;
    
    //refresh data with new mode
    loadSelectedContext();
    
    //updateUI
    updateUI();
}

/*
 * constructs context source panels
 */
 function displayContextSourcePanel(){
	    var url = "../effectivity/EffectivityUtil.jsp?mode=getFramePref";
	    var vResPref = emxUICore.getDataPost(url);  
	    vResPref = trim(vResPref);	   
    if(currentEffTypesArrActual && currentEffTypesArrActual.length > 0){

        var bDateEff = false;
        var dateType = "";
        var dateEffIndex = -1;      
        var sourceList = document.getElementById("mx_divSourceList");
        var panelSrcArray = new Array();
        var optionDefaultArray = new Array();
        var optionDefaultIndex = -1;
        var heightAvr = getUpdatedHeight("mx_divSourceList", currentEffTypesArrActual);
        
        var tempArray1 = currentEffTypesArrActual;
        var tempArray2 = currentEffTypesArr;
        var size = currentEffTypesArr.length;
        currentEffTypesArrActual = null;
        currentEffTypesArr = null;
        for(var i=0;i<size;i++){
      	  if(effectivityColumnType == "evolution" && tempArray1[i]=="FeatureOption") {
    		  tempArray1.splice(i,1);
    		  tempArray2.splice(i,1);
    		  i=i-1;
    		  size = size-1;
    	  }
    	  if(effectivityColumnType == "variant" && tempArray1[i]!=="FeatureOption") {
    		  tempArray1.splice(i,1);
    		  tempArray2.splice(i,1);
    		  i=i-1;
    		  size = size-1;
    	  }        	  
        }
        currentEffTypesArrActual = tempArray1;
        currentEffTypesArr = tempArray2;        
        
        //search and display Date Effectivity at beginning
        for(var i=0; i < currentEffTypesArr.length; i++){
            var effType = currentEffTypesArr[i];
            var effTypeActual = currentEffTypesArrActual[i];
            //if Mode is configured, get the hidden input box
            var categoryType = getEffSetting(SETTING_CATEGORYTYPE, effTypeActual);
            var modeValue = getEffSetting(SETTING_MODE, effTypeActual);
            var tmpDateIndex = -1;      

            var panelSrcName = MX_DIV + effTypeActual;
            
            if(DATE_EFFECTIVITY_TYPE==effTypeActual || CONTEXTDATE_EFFECTIVITY_TYPE==effTypeActual){ //in case date is lowercase
                bDateEff = true;
                dateEffIndex = i;
                tmpDateIndex = i;
                dateType = effTypeActual;
            }           
            
            var panelSource = document.createElement("div");
            panelSource.className = CLASS_PANEL_CLOSED;
            panelSource.id = panelSrcName;
            
            var panelHead = document.createElement("div");
            panelHead.className = "panel-head";
            panelHead.id = panelSrcName + "Toggle";
            panelHead.title = (i==0)?CLICK_TO_CLOSE:CLICK_TO_OPEN;//default the first one to open

                        
            var panelButToggle = document.createElement("div");
            panelButToggle.className = "button-toggle";
            panelButToggle.setAttribute("onclick", "javascript:togglePanel('" + panelSrcName + "', CLASS_PANEL_OPEN, CLASS_PANEL_CLOSED,'" + panelHead.id + "')");
            var panelAnchor = document.createElement("a");
            panelAnchor.href = "#";
            
            panelButToggle.appendChild(panelAnchor); 

            var panelTitle = document.createElement("div");
            panelTitle.className = "title";
            panelTitle.id = MX_PANEL_TITLE + effTypeActual;
            var globalCxtDateLabel = (categoryType == CONTEXTDATE_CATEGORY)?" ("+CONTEXT_TEXT+")":" ("+GLOBAL_TEXT+")";
            
            //appends Effectivity Discipline
            if(categoryType == MILESTONE_CATEGORY && I18EFFECTIVITY_DISCIPLINE != null &&
               I18EFFECTIVITY_DISCIPLINE != 'undefined' && I18EFFECTIVITY_DISCIPLINE != ""){
                effType += " (" + I18EFFECTIVITY_DISCIPLINE + ")";
            }
            
            panelTitle.innerHTML = effType + ((DATE_CATEGORY==categoryType||CONTEXTDATE_CATEGORY==categoryType)?globalCxtDateLabel:"");
            
            panelHead.appendChild(panelButToggle);
            panelHead.appendChild(panelTitle);          

            //when Mode is configured for Effectivity Type, the selected Mode's settings will be used instead
            if(modeValue != null && modeValue != ""){               
                var url =  "../effectivity/EffectivityServices.jsp?mode=getModes&effActual="+effTypeActual;
                var modesJSON = emxUICore.getData(url);
                var modesArray = emxUICore.parseJSON(modesJSON);
                
                var panelActions = document.createElement("div");
                panelActions.className = "actions";
                
                var select = document.createElement("select");
                var selectName = "mx_selectEff"+effTypeActual; 
                select.name= selectName;
                select.id=selectName;
                //select.setAttribute("onclick", "javascript:onModeChangClicked('" + selectName + "','" + effTypeActual + "');");
                select.setAttribute("onchange", "javascript:onModeChanged('" + selectName + "','" + effTypeActual + "');");
                
                for(var n=0; n < modesArray.length; n++){ 
                    var mode = modesArray[n];
                    var options = document.createElement("option");
                    options.value=mode["actualValue"];
                    var optionsText = document.createTextNode(mode["displayValue"]);
                    options.appendChild(optionsText);
                    select.appendChild(options);                    
                }               
                
                //default to first option in select
                select.selectedIndex = 0;
                panelActions.appendChild(select);               
                panelHead.appendChild(panelActions);
                
                //save default selected options             
                optionDefaultArray[++optionDefaultIndex] = selectName+ "," + effTypeActual; 
            }
        
            var panelBody = document.createElement("div");
            panelBody.className = "panel-body";
            panelBody.id = MX_DIV + effTypeActual + PANEL_BODY;
            
            //not for Date Effectivity
            if(tmpDateIndex < 0){               
                var panelIFrame = document.createElement("iframe");
                panelIFrame.name = MX_IFRAME + effTypeActual; 
                panelIFrame.id = MX_IFRAME + effTypeActual;
                panelIFrame.style.height = heightAvr+"px"; 
                panelIFrame.setAttribute("frameborder", "0");
                panelIFrame.setAttribute("src", "");
                
                panelBody.appendChild(panelIFrame);
            } else {
                panelBody.id = panelSrcName + "Body";
                panelBody.style.height = heightAvr+"px";
                //panelSource.className = CLASS_PANEL_OPEN;             
                
            }
            
            tmpDateIndex = -1;
            
            panelSource.appendChild(panelHead);
            panelSource.appendChild(panelBody);
            
            panelSrcArray[i] =  panelSource;
            
            
        } //end for     
        
        /*add panels to source list and build Date's elements*/
        for(var j=0; j < panelSrcArray.length; j++){
            sourceList.appendChild(panelSrcArray[j]);       
            if(dateEffIndex == j){
                insertDateContent(dateType);
            }                       
        }
        
        /*set the first panel to open
         *if selected context is Global, set default active panel to panel with effectivity type other than ContextDate, Unit and Product Revision.
         */
        var selectedContext = getSelectedContext();
        for(var k=0; k < currentEffTypesArrActual.length; k++){
            var effTypeActual = currentEffTypesArrActual[k];
            if(selectedContext == globalContextPhyId && (DATE_EFFECTIVITY_TYPE != effTypeActual)){
               /*       
               (CONTEXTDATE_EFFECTIVITY_TYPE == effTypeActual ||
                UNIT_EFFECTIVITY_TYPE == effTypeActual ||
                PRODUCTREVISION_EFFECTIVITY_TYPE == effTypeActual)){
               */ 
                continue;
            } else {
                if(bContextExist){                	
                	if(effTypeActual==vResPref){//set to open only some context exists
                       panelSrcArray[k].className = CLASS_PANEL_OPEN;
                       displayOperatorEffTypeSetting(effTypeActual);
                	}else if(vResPref == null || vResPref=='undefined' || vResPref==""){                	
                		 panelSrcArray[k].className = CLASS_PANEL_OPEN;
                         displayOperatorEffTypeSetting(effTypeActual);
                         break;
                	}
                    //displayOperatorEffTypeSetting(effTypeActual);
                	// added to set the operators
                    
                }
            }           
        }
        
        /*
        * Overwrites Effectivity Type's settings with default selected Mode's settings.
        */
        if(optionDefaultIndex > -1){
            for(var index=0; index < optionDefaultArray.length; index++){
                var selectNameEffType = optionDefaultArray[index];
                var selectNameEffTypePair = selectNameEffType.split(",");
                onModeChanged(selectNameEffTypePair[0],selectNameEffTypePair[1]);   
            }           
        }
    } //end outer if
    
}

/*
 * sets the ui based upon settings for the effectivity type in Active
 */ 
 function updateUI(){    
     var activePanel = getActiveEffectivityType();
     if(activePanel != null && activePanel.length > 0){
         //search icon
         /*
         var searchIcon = document.getElementById("searchIcon");
         var contextMode = getEffSetting(CONFIGURATION_CONTEXT_MODE, activePanel );
         searchIcon.style.visibility =  (contextMode != null && contextMode == CLOSED)?"hidden":"visible";
         */
         /*reset operators*/
         displayOperatorEffTypeSetting(activePanel);
     }

 }
 
/*
 * shows or hides 
 */
function showDatePanel(activePanel, bShowPanel){
    var dateDiv = document.getElementById(MX_DIV+activePanel+"Body");
    if(dateDiv){
        dateDiv.style.visibility = (bShowPanel)?"visible":"hidden";
    }
} 
 
/*
 * Cleans up temporary cached objects, which were saved from searches
 */
 function cleanupCache(){
    
    var url =  "../effectivity/EffectivityUtil.jsp?mode=removeSavedContexts";
    var removedEffContexts = emxUICore.getDataPost(url);
    //alert("cache has been cleared out!");
    
}

 /*
  * returns average height for context source panel
  */
  function getUpdatedHeight(divSourceList, effActualArray){
    var heightAvr = 0;
    if(effActualArray && effActualArray.length > 0){
        var sourceList = document.getElementById(divSourceList);
        var sourceListHeight = sourceList.offsetHeight;
        var panelCount = effActualArray.length;
        var panelValue = panelCount*(24+2);//+2px for borders
        var sourceListHeight = sourceList.offsetHeight;
        var modValue = 0;
    
        if(sourceListHeight > panelValue){
            modValue = (sourceListHeight - panelValue) % panelCount; //
            heightAvr = (sourceListHeight - (panelValue));//+modValue)) / panelCount; 
        }
    }
    return heightAvr;
 }

/*
 * updates Date panel's title to include context name - Global or specifc context's name
 */
 function updateDatePanelTitle(contextId){
    if(contextId == null || contextId=='undefined' || contextId==""){
        return;
    }
    if(currentEffTypesArrActual != null && currentEffTypesArrActual.length > 0){
        for(var i=0; i < currentEffTypesArrActual.length; i++){
            var effType = currentEffTypesArrActual[i];
            var effTypeDisplay = currentEffTypesArr[i];
            var categoryType = getEffSetting(SETTING_CATEGORYTYPE, effType);
            var datePanelTitle = document.getElementById(MX_PANEL_TITLE + effType);
            if(effType == DATE_EFFECTIVITY_TYPE || effType == CONTEXTDATE_EFFECTIVITY_TYPE) {
                if(datePanelTitle){
                    var contextDiv = document.getElementById(contextId);
                    var contextName = GLOBAL_TEXT;
                    if(contextId != globalContextPhyId && effType == CONTEXTDATE_EFFECTIVITY_TYPE){
                        contextName = contextDiv.value; 
                    }
                    
                    datePanelTitle.innerHTML = effTypeDisplay + " (" + contextName + ")";                  
                }
                break;
            }
        }
    }
}

/*
 * loads data, updates ui to reflect selected context
 */
function updateContextSelection(inputId){
    var cachedList = document.getElementById("cachedContextList");  
    var selectedContext = cachedList.selectedContext;
    
    if(inputId != selectedContext){     
        //save or update current context's expression
        updateCompleteExpression(selectedContext);

        //clear Expression Builder panel
        clearAll("left");       

        //update context selection
        cachedList.selectedContext = inputId;
        var newContext = document.getElementById(inputId);
        newContext.setAttribute("checked", "checked");//needed for searchContext to behave correctly
        
        //reset previous context to unchecked
        if(selectedContext != null && selectedContext != "undefined" && selectedContext != ""){
            var oldContext = document.getElementById(selectedContext);
            oldContext.checked = false; //uncheck radio button
            oldContext.removeAttribute("checked");//needed for searchContext to behave correctly
        }
        //Load selected context's expression, if it exists, in Expression Builder panel
        for(var n=0; n < contextExpressionArr.length; n++){
            var cxtItem2 = contextExpressionArr[n];
            if(inputId == cxtItem2.contextId){
                formLeftExp(cxtItem2.contextRuleTextList,cxtItem2.contextRuleActualList);
                break;
            }   
        }
        
        /*updates Date panel's title to include selected context*/
        updateDatePanelTitle(cachedList.selectedContext);
        
        /*gets selected context's data and displays it in panels*/
        loadSelectedContext(cachedList.selectedContext);
        
        /*show\hide panels accordingly*/
        showHidePanels(cachedList.selectedContext);  
    	if(selectedContext!="Global"){
    		if(inputId!="Global"){
 			   var   enableAutoComplete = false;
 				for ( var i = 0; i < currentEffTypesArrActual.length; i++) {
 					var effType = currentEffTypesArrActual[i];
 					if ("FeatureOption" == effType) {
 						enableAutoComplete = true;
 					} else if ("Milestone" == effType) {
 						enableAutoComplete = true;
 					}
 				}
 				if (enableAutoComplete) {
 					UpdateEmptyrow();
 				}
    			
    		}
        
    	}
     
    }   
}

/*
 * Global Context specific behavior.
 * Returns whether root object has Design Variants, given that Global Context is selected
 * and active panel is Feature Option
 */
function hasDesignVariants(theObjectId){    
    var url = "../effectivity/EffectivityUtil.jsp?mode=relVariesByExists&vContxtLFId="+theObjectId;
    var vRes = emxUICore.getDataPost(url);
    vRes = trim(vRes);
    
    return ((vRes=="true")?true:false);
}

/*
 * shows or hides panels depending on the context selected
 */
function showHidePanels(selectedContextId){
    /* Special use-cases: (Date and Relational categories can not be combined\defined on the same relationship\type
     * If selected context is Global:
     * 1) Only Date\ContextDate and Feature Option Effectivities are available for selection
     * 2) If Feature Option is selected and no Design Variant exists, the panel should collapse, and 
     * if Date panel is present, switch to that. This applies to EFF expression creation, NOT to Filtering.  
     */
     
     /*
     * Global Model\Context is removed, Global object now is just a place holder and not a real object
     */
    var activeEffType = getActiveEffectivityType();
    var activePanelDiv = document.getElementById(MX_DIV+activeEffType);
    var toggleDiv = document.getElementById(MX_DIV+activeEffType+'Toggle');
    if(selectedContextId == globalContextPhyId && activePanelDiv != null &&
      (activeEffType != DATE_EFFECTIVITY_TYPE)){ //} && activeEffType != CONTEXTDATE_EFFECTIVITY_TYPE && activeEffType != FEATURE_OPTION_EFF_TYPE)){           
        activePanelDiv.className = CLASS_PANEL_CLOSED;
        toggleDiv.title = CLICK_TO_OPEN;
        //set the next one(either Date/ContextDate or Feature Option) to open state?
        if(currentEffTypesArrActual != null && currentEffTypesArrActual.length > 1){        
            for(var i=0; i < currentEffTypesArrActual.length; i++){
                var effTypeActual = currentEffTypesArrActual[i];
                if(activeEffType != DATE_EFFECTIVITY_TYPE /*&& activeEffType != CONTEXTDATE_EFFECTIVITY_TYPE && activeEffType != FEATURE_OPTION_EFF_TYPE*/){
                    continue;
                } else {
					/*	    
                    if(activeEffType == FEATURE_OPTION_EFF_TYPE && !hasDesignVariants(objectId)){
                        activePanelDiv.className = CLASS_PANEL_CLOSED;
                        toggleDiv.title = CLICK_TO_OPEN;
                        continue;
                    }
					*/
                     
                    togglePanel(MX_DIV+effTypeActual,CLASS_PANEL_OPEN,CLASS_PANEL_CLOSED,MX_DIV+effTypeActual+"Toggle");
                    break;
                }
            }
        }
    }/* else if(selectedContextId == globalContextPhyId && activeEffType == FEATURE_OPTION_EFF_TYPE){
        if(!hasDesignVariants(objectId)){//do not show if there's no DV and selected is Global context
            activePanelDiv.className = CLASS_PANEL_CLOSED;
            toggleDiv.title = CLICK_TO_OPEN;
        }
    }*/ else if(selectedContextId != globalContextPhyId && activeEffType == DATE_EFFECTIVITY_TYPE){         
        /*if((!bForFiltering && activeEffType == FEATURE_OPTION_EFF_TYPE && hasDesignVariants(objectId)) ||
            activeEffType == DATE_EFFECTIVITY_TYPE){*/
                //do not show if there's some DV and selected context is not Global
                //or context is not global and it's global date
                activePanelDiv.className = CLASS_PANEL_CLOSED;
                toggleDiv.title = CLICK_TO_OPEN;
        //}
    }

    if(currentEffTypesArrActual != null && currentEffTypesArrActual.length > 0){        
        for(var i=0; i < currentEffTypesArr.length; i++){
            var effType = currentEffTypesArr[i];
            var effTypeActual = currentEffTypesArrActual[i];
            
            var panelBodyDiv = document.getElementById(MX_DIV+effTypeActual+PANEL_BODY);
            
            if(selectedContextId == globalContextPhyId){/*Global Context*/                
            	/*if(FEATURE_OPTION_EFF_TYPE == effTypeActual && panelBodyDiv != null){
                    panelBodyDiv.style.visibility = 'visible';
                } else*/ if(DATE_EFFECTIVITY_TYPE==effTypeActual /*|| CONTEXTDATE_EFFECTIVITY_TYPE==effTypeActual*/){
                    showDatePanel(effTypeActual, true);
                } else if(panelBodyDiv != null){/*hide all panels except "Feature Option and global Date"*/
                    panelBodyDiv.style.visibility = 'hidden';
                }
            } else { /*all other contexts*/
                if(DATE_EFFECTIVITY_TYPE==effTypeActual){
                     showDatePanel(effTypeActual, false);
                } else if(CONTEXTDATE_EFFECTIVITY_TYPE==effTypeActual){
                    showDatePanel(effTypeActual, true);
                } else if(panelBodyDiv != null){
                    panelBodyDiv.style.visibility = 'visible';
                }
            }
        }
    }   
}


/*
 * returns current context's object expression
 */
function getContextExpression(selectedContextId)
{
    var leftExp = document.BCform.LeftExpression;
    //consider GLOBAL: it seems to be appropriate only for Date 
    if(/*leftExp.length < 1  ||*/ selectedContextId == "" || selectedContextId == null || selectedContextId == 'undefined'){
        return "";
    }

    //validate expression before allowing context to be switched silently or need to inform user right away?
    var validated = fnValidate(true);
    var leftExpText = "";
    var contextRuleText = "";
    var contextRuleActual = "";
    var contextRuleTextList = "";
    var contextRuleActualList = "";
    var leftExpValue="";
    for (var i = 0; i < leftExp.length; i++){
        leftExpText = leftExpText + leftExp.options[i].text + "\n";
        leftExpValue = leftExp.options[i].value;
        if (leftExpValue != "EF_FO_EF_MS"){
        //current context's options
        contextRuleText = contextRuleText + leftExp.options[i].text + " ";
        contextRuleActual = contextRuleActual + leftExp.options[i].value + " ";
        contextRuleTextList = trim(contextRuleTextList + leftExp.options[i].text) + "@delimitter@";
        contextRuleActualList = trim(contextRuleActualList + leftExp.options[i].value)+ "@delimitter@";
        }
    }
    
    var cxtInputDiv = document.getElementById(selectedContextId);
    var contextExpression = new Object();
    contextExpression["contextId"] = selectedContextId; //physicalid
    contextExpression["validated"] = validated; //"true" or "false"
    contextExpression["actualValue"] = contextRuleActual; //expression's actual value
    contextExpression["displayValue"] = contextRuleText; //expression's display value
    contextExpression["contextRuleTextList"] = contextRuleTextList; //expression's display value broken up in a list with separator "@delimitter@" 
    contextExpression["contextRuleActualList"] = contextRuleActualList; //expression's actual value broken up in a list with separator "@delimitter@"

    return contextExpression;
}

/*
 * updates complete actual expression array  
 */
function updateCompleteExpression(selectedContext){
    var curContextExp = getContextExpression(selectedContext);  
    if(curContextExp != null && curContextExp !=""){
        var bFound = false;
        var indexFound = -1;
        for(var i=0; i < contextExpressionArr.length; i++){
            var cxtItem = contextExpressionArr[i];//.parseJSON();
            if(cxtItem && selectedContext == cxtItem.contextId){
                bFound = true;
                indexFound = i; //to update this context
                break;
            }
            
        }
        if(!bFound && curContextExp != null && curContextExp != ""){//set new context to the array
            contextExpressionArr[contextExpressionArr.length] = curContextExp;              
            //keep track of this here or move it to some place else such as in session or some other caching approach
            //var jsonURL="../effectivity/EffectivityUtil.jsp?mode=saveJSONExpressions&JSONExpression="+contextExpressionArr.toJSONString();
            //var jsonString = emxUICore.getDataPost(jsonURL);
        } else { //update context with new expression
            contextExpressionArr[indexFound] = curContextExp;           
        }
    }
}

/*
 * updates complete display expression array
 */
 function updateCompleteDisplayExp(selectedId, contextRuleText, displayExpressionsArray){
    //must have some context selected
    if(selectedId == null || selectedId == 'undefined' || selectedId == ""){
        return;
    }

    //update completed expression array
    var bFound = false;
    var indexFound = -1;
    for(var i=0; i < displayExpressionsArray.length; i++){
        var cxtItem = displayExpressionsArray[i];
        if(cxtItem != null && cxtItem != 'undefined' && (selectedId == cxtItem.contextId)){
            bFound = true;
            indexFound = i; //to update this context
            break;
        }
    }

    //add or update context expression array for display
    if(!bFound){//set new context to the array
        var displayCxt = new Object();
        var cxtInputDiv = document.getElementById(selectedId);
        displayCxt["contextId"] = selectedId;
        displayCxt["displayValue"] = contextRuleText;
        displayExpressionsArray[displayExpressionsArray.length] = displayCxt;
    } else { //update context with new expression
        var curContextDisplay = displayExpressionsArray[indexFound];
        curContextDisplay.displayValue = contextRuleText;
        displayExpressionsArray[indexFound] = curContextDisplay;
    }
    
    //display completed expression
    var completedRule = "";
    for(var n=0; n < displayExpressionsArray.length; n++){
        var cxtItem = displayExpressionsArray[n];
        var tmpDiv = document.getElementById(cxtItem.contextId);
		
        var displayValue = cxtItem.displayValue;
        if(displayValue != null && displayValue != ""){
            var cxtDisplayValue = "<div class='completeExprOptions' onclick=changeContxextFromExpression('"+cxtItem.contextId+"')>" + tmpDiv.value + ": " + displayValue + "</div>";
            completedRule += (completedRule!="")?cxtDisplayValue:cxtDisplayValue;        
        }
    }
    
    var objDIV = document.getElementById("mx_divRuleText");
    completedRule = "<B>" + completedRule + "</B>";
    objDIV.innerHTML = completedRule.toString();

}

/*
 * for selecting the context from the selection from complete expression itself
 */ 
function changeContxextFromExpression(contextId)
{
	if(contextId)
		{
			document.getElementById(contextId).checked = true;
			updateContextSelection(contextId);
		}
}
  
/*
 *  returns true if there's some error in complete expression
 */
function getInvalidContextsExpErrors(expressionsArray)
{   
    var cxtErrorList = ""; 
    //check to see if there's any syntax error in contexts' expression
    for(var i=0; i < expressionsArray.length; i++){
        var cxtItem = expressionsArray[i];
        var tmpDiv = document.getElementById(cxtItem.contextId);
        if(tmpDiv.value != ""){
            if(cxtItem.validated == "false"){
                if(cxtErrorList != ""){
                    cxtErrorList += ",";
                }
                cxtErrorList += tmpDiv.value;
            }
        }
    }
    return cxtErrorList;
}

/*
 * returns complete expression containing below data in JSON format
 *         completedRuleText, completedRuleActual, completedRuleTextList, completedRuleActualList   
 */
function getCompleteExpression(expressionsArray){
    var completeExpObj = new Object();
    var completedRuleText = "";
    var completedRuleActual = "";
    var completedRuleTextList = "";
    var completedRuleActualList = "";
    var OR_OP = "OR";

    for(var i=0; i < expressionsArray.length; i++){
        var cxtItem = expressionsArray[i];
        if(cxtItem != null && cxtItem.actualValue != "" && cxtItem.displayValue != ""){
            completedRuleText += (completedRuleText != "")?" "+ OR_OP+" "+trim(cxtItem.displayValue):cxtItem.displayValue;
            completedRuleActual += (completedRuleActual != "")?" "+OR_OP+" "+trim(cxtItem.actualValue):cxtItem.actualValue;
            completedRuleTextList += (completedRuleTextList != "")?"@delimitter@"+OR_OP+"@delimitter@"+cxtItem.contextRuleTextList:cxtItem.contextRuleTextList;
            completedRuleActualList += (completedRuleActualList != "")?"@delimitter@"+OR_OP+"@delimitter@"+cxtItem.contextRuleActualList:cxtItem.contextRuleActualList;         
        }
    }
    
    completeExpObj["completedRuleText"] = completedRuleText;
    completeExpObj["completedRuleActual"] = completedRuleActual;
    completeExpObj["completedRuleTextList"] = completedRuleTextList;
    completeExpObj["completedRuleActualList"] = completedRuleActualList;
        
    return completeExpObj;
}


function togglestyle(el){
	if(el.className == "off"){
		var otherElem = null;
		if(el.id == "and"){
			otherElem = document.getElementById("or");			
		}
		else if(el.id == "or"){
			otherElem = document.getElementById("and");	
		}
		if(otherElem != null){
			el.className="on";
			el.style.backgroundColor = "#35b128";
			otherElem.className="off";
			otherElem.style.backgroundColor = "#d3d3d3";
		}		
	}
}

function clearExpression(){
	var options = document.getElementById("IncExp").options;
	if(options.length > 0 && options.selectedIndex == -1 && options[0].value != "EF_FO_EF_MS" && ! confirm(CLEAR_ALL_EXPRESSION))
		return;
	removeExp('left');
	computedRule('','left');
	var selectedContext = getSelectedContext();
	
 if (selectedContext != null && selectedContext != ""
			&& selectedContext != "Global") {
		   var   enableAutoComplete = false;
		for ( var i = 0; i < currentEffTypesArrActual.length; i++) {
			var effType = currentEffTypesArrActual[i];
			if ("FeatureOption" == effType) {
				enableAutoComplete = true;
			} else if ("Milestone" == effType) {
				enableAutoComplete = true;
			}
		}
		if (enableAutoComplete) {
			UpdateEmptyrow();
		}
	}

}


function clearAllCheckedNodes(effTypeAtual){
	var sourceFrame = findFrame(window, MX_IFRAME+effTypeAtual);
	var checkedItem = sourceFrame.getCheckedCheckboxes();	
    sourceFrame.clearAllCheckedItems();
    for(var key in checkedItem)
    {
        var temp = checkedItem[key];
        var tempArr = temp.split("|");
        checkedId = "rmbrow-"+tempArr[3]; 
        checkedEl = sourceFrame.document.getElementById(checkedId);
        checkedEl.checked=false;
    }
        var treeBodytable= sourceFrame.document.getElementById("treeBodyTable");
        var listBodyTable = sourceFrame.document.getElementById("bodyTable");
	    if (treeBodytable) 
	    {
	        var selectedRowStyle = 'mx_rowSelected';
	        for (var i = 1; i < treeBodytable.rows.length; i++) 
		        {
		            var tr = treeBodytable.rows[i];
		            var id = tr.getAttribute('id');
		            
		            tr.className = tr.className.replace(' ' + selectedRowStyle , '');
		            tr.className = tr.className.replace(selectedRowStyle , '');
		         }
	    }
	    
	    if (listBodyTable) 
	    {
	        var selectedRowStyle = 'mx_rowSelected';
	        for (var i = 1; i < listBodyTable.rows.length; i++) 
		        {
		            var tr = listBodyTable.rows[i];
		            var id = tr.getAttribute('id');
		            
		            tr.className = tr.className.replace(' ' + selectedRowStyle , '');
		            tr.className = tr.className.replace(selectedRowStyle , '');
		        }
	      }

}



function load(res) {	
	
	var optionslist=parseJson(res);	
     $('#keyin').textcomplete([
                                { // emoji strategy
                                    optionslist:options,                                   
                                    match: /\b(\w{1,})$/
                                    ,
                                    search: function (term, callback) {
                                        callback($.map(options, function (option) {
                                         var returnvalue = "";
                                          var OPTION="";
                                         //term processing                                           
                                         var TERM = term.toUpperCase();
                                          OPTION = option.displayText;
                                          optionType=option.Type;
                                         if("Header"===optionType)return option;
                                         if (OPTION === "") return null;
                                         OPTION=OPTION.replace(/[\(\)\[\]{}'":\s]/g,"");
                                         OPTION=OPTION.trim();
                                         OPTION = OPTION.toUpperCase();
                                         return OPTION.indexOf(TERM) != -1 ? option : null;
                                        }));
                                    }
                                    ,
                                    
                                    template: function (value) {
                                    	return value.displayText;                                        
                                    },
                                    replace: function (value) {                                    	
                                    	  //term processing
                                         var displayValue=""; 
                                    	  var actualExp="";
                                    	  var msHolderId=""; 
                                    	  var contextId="";
                                    	if("Operators"===value.optionName)
                                     	 {
                                       	    displayValue=value.FeatureName;
                                       	    type="Operators";                                       	   
                                     	 }else if("ConfigurationOption"===value.Type){
                                     		displayValue = value.context+":["+value.FeatureName+"]:"+value.FeatureRevision+"{"+value.optionName+"}";
                                     		actualExp=value.ParentRelId;
                                     		type=value.Type;
                                     		contextId=value.ContextID;
                                     	 } else if("Milestone"===value.Type){
                                     		displayValue = value.context+":["+value.optionName+"-"+'\u221e'+"]";                                     		
                                     		type=value.Type;
                                     		actualExp=value.optionId;
                                     		contextId=value.ContextID;
                                     		msHolderId=value.ParentRelId;
                                     	 }                                    	
                                    	
                                        if (displayValue === "") return null;                             
                                      
                                       editObject_Dropdown(contextId,actualExp,displayValue,type,msHolderId);  
                                       return  displayValue;
                                    },
                                    index: 1
                                }
     				        ], {
     				            onKeydown: function (e, commands) {
     				                if (e.ctrlKey && e.keyCode === 74 && e.keyCode === 9) { // CTRL-J
     				                    return commands.KEY_ENTER;
     				                }
     				            }
     				        });

}

function setFramePreference(frameName){ 	
    var url = "../effectivity/EffectivityUtil.jsp?mode=framePref&vFrameName="+frameName;
    var vRes = emxUICore.getDataPost(url);
    vRes = trim(vRes);    
    return ((vRes=="true")?true:false);
}
var options="";
function parseJson(jsonDico){
	  var jsonDicoRes = emxUICore.parseJSON(jsonDico);


	var operators = [ "AND", "OR", "NOT" ];
	var optionarray = [];
	var featureoptionarray = [];
	var milestonearray = [];
	var sortfunction = function(a, b) {
		if (a.displayText.toUpperCase() < b.displayText.toUpperCase())
			return -1;
		if (a.displayText.toUpperCase() > b.displayText.toUpperCase())
			return 1;
		return 0;
	}

	for (cnt = 0; cnt < operators.length; cnt++) {

		optionarray.push({
			"optionName" : "Operators",
			"FeatureName" : operators[cnt],
			"optionId" : operators[cnt],
			"featureId" : operators[cnt],
			"displayText" : operators[cnt],
			"context" : jsonDicoRes.name,
		     "Type":"Operators"
		});
	}
	optionarray.sort(sortfunction);

	optionarray.unshift({
		"optionName" : "Operators",
		"Type" : "Header",
		"optionId" : "",
		"featureId" : "",
		"displayText" : CatOperators
	});

	var currentfeature = 0;
	var currentMilestone = 0;
	var context = jsonDicoRes.name;
	for (currentfeature = 0; currentfeature < jsonDicoRes.features.length; currentfeature++) {
		var currentoption = 0;
		var feature = jsonDicoRes.features[currentfeature];
		for (currentoption = 0; currentoption < feature.options.length; currentoption++) {
			var option = feature.options[currentoption];
			var obj = {
				"optionName" : option.name,
				"FeatureName" : feature.name,
				"optionId" : option.id,
				"featureId" : feature.id,
				"FeatureRevision" : feature.revision,
				"ParentRelId" : option.parentRelId,
				"context" : jsonDicoRes.name,
				"Type" : "ConfigurationOption",
				"ContextID" : jsonDicoRes.id,			
				"displayText" : feature.name + ":" + feature.revision + "{"
						+ option.name + "}"
			}
			featureoptionarray.push(obj);
		}
	}

	featureoptionarray.sort(sortfunction);

	featureoptionarray.unshift({
		"optionName" : "Feature Option",
		"Type" : "Header",		
		"displayText" : EffFeatureOption
	});

	for (currentmilestones = 0; currentmilestones < jsonDicoRes.milestones.length; currentmilestones++) {
		var currensequence = 0;
		var milestones = jsonDicoRes.milestones[currentmilestones];
		for (currentsequence = 0; currentsequence < milestones.sequence.length; currentsequence++) {
			var sequence = milestones.sequence[currentsequence];
			var current=sequence.current;
			if("Complete"!=current){
			var obj = {
				"optionName" : sequence.name,
				"optionId" : sequence.id,
				"ParentRelId" : sequence.parentId,
				"context" : jsonDicoRes.name,
				"Type" : "Milestone",
				"ContextID" : jsonDicoRes.id,				
				"displayText" : sequence.name
			}
			milestonearray.push(obj);
		}
		}
	}

	milestonearray.sort(sortfunction);

	milestonearray.unshift({
		"optionName" : "Milestone",
		"Type" : "Header",
		"displayText" : EffMilestone
	});

	options = optionarray.concat(featureoptionarray);
	options = options.concat(milestonearray);
//console.log(options);
	return options;
	     
 }
function editObject_Dropdown(contextId,actualExp,displayValue,type,msHolderId)
{ 
	 
       var selectedIndexValue = document.BCform.LeftExpression.selectedIndex;
       var currValue = document.BCform.LeftExpression.options[selectedIndexValue].value; 
       var contextId=contextId.split("pid:");      
       var contextIdPhyID=contextId[1];     
       var actualExp=actualExp.split("pid:");      
       var actualExpPhyID=actualExp[1];
       if("ConfigurationOption"===type){
    	   var newValue="@EF_FO(PHY@EF:"+actualExpPhyID +"~"+contextIdPhyID+")";
    	   document.BCform.LeftExpression.options[selectedIndexValue].categoryType="relational"
         // document.BCform.LeftExpression.options[selectedIndexValue].effType="relational"
    	   
       }else if("Milestone"===type){    	   
           var msHolderId=msHolderId.split("pid:");      
           var msHolderExpPhyID=msHolderId[1];
    	   var newValue="@EF_MS(PHY@EF:"+msHolderExpPhyID +"[PHY@EF:"+actualExpPhyID+"-^])"; 
    	   document.BCform.LeftExpression.options[selectedIndexValue].categoryType="milestone"
    	  // document.BCform.LeftExpression.options[selectedIndexValue].effType="milestone"
    		  
       } else if("Operators"==type){
    	   var newValue=displayValue;    	  
    	   
       }  
       var currtext = document.BCform.LeftExpression.options[selectedIndexValue].text;     
       document.BCform.LeftExpression.options[selectedIndexValue].text=displayValue; 
       document.BCform.LeftExpression.options[selectedIndexValue].value=newValue;       	
	   var keyInDiv=document.getElementById("keyInDiv");
	   keyInDiv.style.visibility= "hidden";
	   var leftExp= document.BCform.LeftExpression;	  
	   var leftExpText="";
	   for (var i = 0; i < leftExp.length; i++)
	    {
		   if(leftExp.options[i].value != "EF_FO_EF_MS")
	        leftExpText = leftExpText + leftExp.options[i].text.htmlEncode() + "\n";
	        
	    }      
	   updateCompleteDisplayExp(getSelectedContext(), leftExpText, completedDisplayExpressionArr);	
	   UpdateEmptyrow();	 
}

function addEmptyRow() {
	var selectbox = document.BCform.LeftExpression;
	var cnt =  selectbox.options.length;
	if (cnt == 0) {		
	addOption(document.BCform.LeftExpression, CLICK_TO_ADD_OPTION, "EF_FO_EF_MS","Operand",null);
	}
}
function addLastRow()
{
	var selectbox = document.BCform.LeftExpression;
	var cnt =  selectbox.options.length - 1;
	var tempArray1 = currentEffTypesArr;
	var tempArray2 = currentEffTypesArrActual;
    var size = currentEffTypesArr.length;
	for(var i=0;i<size;i++){
		if((tempArray1[i] == "Variants and Options" || tempArray1[i] == "Feature Option") && tempArray2[i] == "FeatureOption"){
			if (selectbox.options[cnt].value != "EF_FO_EF_MS") {
				selectbox.selectedIndex =  cnt;	
				addOption(document.BCform.LeftExpression, CLICK_TO_ADD_OPTION, "EF_FO_EF_MS","Operand",null);	
			}	
		}
	}
}
function LoadTextComplete(selectedContext)
{
	if(selectedContext != null && selectedContext != ""){	
	
				var cachedList = document.getElementById("cachedContextList");					
				var selectedContext = cachedList.selectedContext;
				 if(selectedContext!="Global"){
				// getting the dictionary
				var res=function ()
				{
					 var FO=0;
					 var MS=0;					 
					 for(var i=0; i < currentEffTypesArrActual.length; i++){
				         var effType = currentEffTypesArrActual[i];				       
				        if("FeatureOption"==effType){
				        	FO=1;
				        }else if("Milestone"==effType){
				        	MS=1;
				        }				         
					 }
					var hostURL=getHostUrl();					
				    var url = hostURL+"/resources/modeler/model/pid:" + selectedContext + "/configurationdictionary";
				    url += "?features="+FO+"&milestones="+MS;					  
		            var  jsonString = emxUICore.getDataPost(url);		           
		            return  jsonString;		   
		            // to-DO conversion
				}();
					
				 load(res);
				}
	}else{
					var cachedList = document.getElementById("cachedContextList");						
					var selectedContext = cachedList.selectedContext;				
					// getting the dictionary
					var res=function ()
					{	
						 var FO=0;
						 var MS=0;
						 for(var i=0; i < currentEffTypesArrActual.length; i++){
					         var effType = currentEffTypesArrActual[i];					       
					        if("FeatureOption"==effType){
					        	FO=1;
					        }else if("Milestone"==effType){
					        	MS=1;
					        }				         
						 }
						var hostURL=getHostUrl();
					    var url = hostURL+"/resources/modeler/model/pid:" + selectedContext + "/configurationdictionary";					  
					    url += "?features="+FO+"&milestones="+MS;	
			           var  jsonString = emxUICore.getDataPost(url);			           
			           return  jsonString;		   
			            // to-DO conversion
					}();					
					 load(res);
				}
		 
}

function RemoveEmptyRow() {
	Exp = document.BCform.LeftExpression;

	for (i = Exp.length - 1; i >= 0; i--) {
		if (Exp.options[i].value == "EF_FO_EF_MS") {
			Exp.options[i] = null;
			break;
		}
	}
}

function UpdateEmptyrow()
{	

	addEmptyRow();
	addLastRow();
}

function toggleBuilderPanel() {
	 resetKeyInDiv();
	var buildIcon = document.getElementById("builderCollId");
	var anchorDiv = document.getElementById("builderTagId");
	var builderToggleDiv = document.getElementById("mx_builderToggle");
	var Val = builderToggleDiv.getAttribute("value");
	if (Val.indexOf('openStatus') != -1) {
		var buildIcon = document.getElementById("builderCollId");
		buildIcon.src = "../common/images/iconActionOpenPanel.gif";
		anchorDiv.title = CLICK_TO_COLLAPSE;
		var builderToggleDiv = document.getElementById("mx_builderToggle");
		var Val = builderToggleDiv.setAttribute("value", "closeStatus");

	// Adding inline style
		
		var divSource = document.getElementById("mx_divSourceList")
		divSource.style.width = "auto";

		var divExpression = document.getElementById("mx_divExpression");
		divExpression.style.width = '68%';
		var divSelect = document.getElementById("divSelect");
		divSelect.style.width = '93%';
		var operatorsTable = document.getElementById("operatorsTable");
		operatorsTable.parentElement.style.left = "100px";
		operatorsTable.parentElement.style.float = "right";
	
	} else {
		 resetKeyInDiv();
		var buildIcon = document.getElementById("builderCollId");
		buildIcon.src = "../common/images/iconActionClosePanel.gif";
		anchorDiv.title = CLICK_TO_EXPAND;
		var builderToggleDiv = document.getElementById("mx_builderToggle");
		var Val = builderToggleDiv.setAttribute("value", "openStatus");

		// removing inline style
		var divSource = document.getElementById("mx_divSourceList");
		if (divSource.style.removeProperty) {
			divSource.style.removeProperty('width');
		} else {
			divSource.style.removeAttribute('width');
		}

		var divExpression = document.getElementById("mx_divExpression");
		divExpression.style.width = '300px';

		var divSelect = document.getElementById("divSelect");
		if (divSelect.style.removeProperty) {
			divSelect.style.removeProperty('width');
		} else {
			divSelect.style.removeAttribute('width');
		}
	}

}

var getHostUrl = function ()
{
    var contextname = location.pathname.substring(0, location.pathname.indexOf('/', 1));
    //as location.origin failes on IE11 win10
    var hostOriginUrl = window.location.protocol + "//" + window.location.hostname + (window.location.port ? ':' + window.location.port: '');
    var hostUrl = hostOriginUrl.concat(contextname);
    return hostUrl;
};
function resetReadMode(){	
$( document ).on( 'keydown', function ( e ) {
    if ( e.keyCode === 27 ) { 
    	// ESC
    	var keyInDiv=document.getElementById("keyInDiv");
    	keyInDiv.style.visibility="hidden";
    	//this.dropdown.deactivate();
    }
})
}

