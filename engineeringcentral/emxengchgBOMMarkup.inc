<%-- emxengchgBOMMarkup.inc
   Copyright (c) 1992-2018 Dassault Systemes.
   All Rights Reserved.
   This program contains proprietary and trade secret information of Dassault Systemes
   Copyright notice is precautionary only and does not evidence any actual or
   intended publication of such program
--%>
<%@page import ="com.matrixone.apps.domain.util.EnoviaResourceBundle"%>

<% 
    String languageString = request.getHeader("Accept-Language");
	//Multitenant
   /* String selectAnItemMsg = i18nNow.getI18nString("emxEngineeringCentral.EBOMMarkup.PleaseSelectAnItem","emxEngineeringCentralStringResource",languageString);
    String emptyMarkupMsg = i18nNow.getI18nString("emxEngineeringCentral.EBOMMarkup.CannotSaveAnEMptyMarkupObject","emxEngineeringCentralStringResource",languageString);
    String msg1 = i18nNow.getI18nString("emxEngineeringCentral.EBOMMarkup.msg1","emxEngineeringCentralStringResource",languageString);
    String msg2 = i18nNow.getI18nString("emxEngineeringCentral.EBOMMarkup.msg2","emxEngineeringCentralStringResource",languageString);
    String selectOnlyOneItemMsg = i18nNow.getI18nString("emxEngineeringCentral.EBOMMarkup.PleaseSelectOnlyoneItem","emxEngineeringCentralStringResource",languageString);
    String searchBeforeApplyMsg = i18nNow.getI18nString("emxEngineeringCentral.EBOMMarkup.SearchBeforeApply","emxEngineeringCentralStringResource",languageString);
    String applyCompletedMsg = i18nNow.getI18nString("emxEngineeringCentral.EBOMMarkup.ApplyCompleted","emxEngineeringCentralStringResource",languageString);
    String searchAndSelectMsg = i18nNow.getI18nString("emxEngineeringCentral.EBOMMarkup.SearchAndSelect","emxEngineeringCentralStringResource",languageString);
   */
   String selectAnItemMsg = EnoviaResourceBundle.getProperty(context, "emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.EBOMMarkup.PleaseSelectAnItem");
   String emptyMarkupMsg = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.EBOMMarkup.CannotSaveAnEMptyMarkupObject");
   String msg1 = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.EBOMMarkup.msg1");
   String msg2 = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.EBOMMarkup.msg2");
   String selectOnlyOneItemMsg = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.EBOMMarkup.PleaseSelectOnlyoneItem");
   String searchBeforeApplyMsg = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.EBOMMarkup.SearchBeforeApply");
   String applyCompletedMsg = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.EBOMMarkup.ApplyCompleted");
   String searchAndSelectMsg = EnoviaResourceBundle.getProperty(context,"emxEngineeringCentralStringResource",context.getLocale(),"emxEngineeringCentral.EBOMMarkup.SearchAndSelect");

%>
<script language="javascript">
//function to popup the Edit Window Frameset
function ebomEdit(actionType,selectedindex){
          var mode="";
          var targetPartName = "";
          var targetPartRev = "";
          var targetPartVault = "";
          var uniqueId = "false";
          var index=selectedindex-1;
          var test=parent.pagecontent;
          if(test !=null)
          {
               mode=document.markupForm.mode.value;
               document.markupForm.selectedIndex.value = index;
               targetPartName = parent.pagecontent.document.markupForm.partNameHidden[index].value;
               targetPartRev = document.markupForm.revHidden[index].value;
               targetPartVault = document.markupForm.vaultHidden[index].value;
               if(document.markupForm.uniqueId && document.markupForm.uniqueId[index]) {
                 uniqueId = document.markupForm.uniqueId[index].value;
               }

          }else{
               mode=parent.frames[1].pagecontent.document.markupForm.mode.value;
               document.markupForm.selectedIndex.value = index;
               targetPartName = document.markupForm.partNameHidden[index].value;
               targetPartRev = document.markupForm.revHidden[index].value;
               targetPartVault = document.markupForm.vaultHidden[index].value;
               if(document.markupForm.uniqueId && document.markupForm.uniqueId[index]) {
                 uniqueId = document.markupForm.uniqueId[index].value;
               }

          }
          var editWindow=null;

        if ((editWindow == null) || (editWindow.closed) )
          {
               winHeight = Math.round(screen.height*50/100);
               winWidth = Math.round(screen.width*40/100);
               winX=Math.round(screen.width/2)-(winWidth/2);
               winY=Math.round(screen.height/2)-(winHeight/2);
               var url = "emxpartEBOMMarkupEditDialog.jsp?mode="+mode+"&targetPartName="+targetPartName+"&targetPartRev="+targetPartRev+"&targetPartVault="+targetPartVault;
               if(uniqueId != "false") {
                 url +="&uniqueId="+uniqueId;
               }
               url = fnEncode(url);
               editWindow=window.open(url, "editWindow",'height='+winHeight+',width='+winWidth+',left='+winX+',top='+winY+',toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=yes,resizable=1,copyhistory=1,dependent=0');
               editWindow.focus()
            }
          else
            {
               editWindow.focus()
            }
          return;
        }

    //deletes ebom makup line items from the bom or reset an Item
    function ebomRemoveReset(actionType,mode){
      var oneValueChecked=false;
      for(var x = 0;(x<document.markupForm.partName.length) && (!oneValueChecked);x++)
      {
        if(document.markupForm.partName[x].checked == true)
        {
          oneValueChecked = true;
        }
      }

      if(!oneValueChecked)
      {
        alert("<%=selectAnItemMsg%>");
        return;
      }

      if(actionType == "Delete")
      {
        document.markupForm.action="emxengchgBOMMarkupDelete.jsp?mode="+mode;
      }
      else if(actionType == "Reset")
      {
        document.markupForm.action="emxengchgBOMMarkupResetProcess.jsp?mode="+mode;
      }
      document.markupForm.submit();

      return;
    }

  //delete XML file in the Ematrix directory
  function ebomCleanup(mode,markupId)
    {
         var sResponse=false;
         if(mode=="Create")
          sResponse = window.confirm("<%=msg1%>");
         else
          sResponse = window.confirm("<%=msg2%>");

         if(sResponse==true)
            {
             location.href="emxengchgBOMMarkupCleanup.jsp?mode="+mode+"&markupId="+markupId;
             parent.closeWindow();
             return;
             }
     }

//Save changes for create and view and edit mode
function ebomSaveEdit(actionType,mode,markupid){
    if(document.markupForm.elements.length<=5)
      {
          alert("<%=emptyMarkupMsg%>");
          return;
      }

      if(actionType=="SaveEdit")
      {

          document.markupForm.action="emxengchgBOMMarkupViewSave.jsp?mode="+mode+"&markupId="+markupid;
      }

      document.markupForm.submit();
      return;
}

// variable so that we won't process submit more than once
EBOMSaveCreateBoolean=false;

//Save changes for create and view and edit mode
function ebomSaveCreate(actionType,mode,markupid){
    if (!EBOMSaveCreateBoolean)
  {
        if(document.markupForm.elements.length<=5)
        {
            alert("<%=emptyMarkupMsg%>");
            return;
        }

        if(actionType=="SaveCreate")
        {
            document.markupForm.action="emxengchgBOMMarkupSave.jsp?mode="+mode;
        }
        else
        {

            document.markupForm.action="emxengchgBOMMarkupViewSave.jsp?mode="+mode+"&markupId="+markupid;
        }

        document.markupForm.submit();
        EBOMSaveCreateBoolean=true;
    }

    return;
}




function ebomAdd(actionType,mode,busId)
    {
      if(actionType == "Add")
      {
        var addWindow=null;
        if ((addWindow == null) || (addWindow.closed) )
        {
            winHeight = Math.round(screen.height*45/100);
            winWidth = Math.round(screen.width*45/100);
            winX=Math.round(screen.width/2)-(winWidth/2);
            winY=Math.round(screen.height/2)-(winHeight/2);
            var url = "emxpartEBOMMarkupAddDialog.jsp?mode="+mode+"&busId="+busId;
            addWindow=window.open(url, "addWindow",'height='+winHeight+',width='+winWidth+',left='+winX+',top='+winY+',toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=yes,resizable=1,copyhistory=1,dependent=0');
            addWindow.focus()
          }
          else{
           addWindow.focus()
          }

        return;
      }
  }


      function doCheck()
      {
          var objForm="";
          var test=parent.pagecontent;
          if(test != null){
             objForm = document.markupForm;
            }else{
                objForm = document.markupForm;
            }
          var chkList = objForm.chkList;
          var reChkName = /chkItem/gi;

          for (var i=0; i < objForm.elements.length; i++)
            if (objForm.elements[i].name.indexOf('partName') > -1)
              objForm.elements[i].checked = chkList.checked;
    }


    function updateCheck()
    {
      var objForm = document.forms[0];
      var chkList = objForm.chkList;
      chkList.checked = false;
    }
   

function ebomCreateNew(mode,objectId)
    {
        
	winHeight = Math.round(screen.height*70/100);
	winWidth = Math.round(screen.width*75/100);
	winX=Math.round(screen.width/2)-(winWidth/2);
	winY=Math.round(screen.height/2)-(winHeight/2);
	var url = "emxengchgCreateBOMMarkupFS.jsp?mode="+mode+"&objectId="+objectId;
	emxShowModalDialog(url,winWidth,winHeight,false);
        return;
  }

//remove ebom makup line items from the bom or reset an Item
function ebomRemoveReset(actionType,mode){
        var oneValueChecked=false;
        for(var x = 0;(x<document.markupForm.partName.length) && (!oneValueChecked);x++)
        {
          if(document.markupForm.partName[x].checked == true)
          {
            oneValueChecked = true;
          }
        }

      if(!oneValueChecked)
      {
        alert("<%=selectAnItemMsg%>"); 
        return;
      }

      if(actionType == "Delete")
      {
        document.markupForm.action="emxengchgBOMMarkupDelete.jsp?mode="+mode;
      }
      else if(actionType == "Reset")
      {
        document.markupForm.action="emxengchgBOMMarkupResetProcess.jsp?mode="+mode;
      }
      document.markupForm.submit();
//      parent.frames[1].pageheader.location.reload();
      return;
    }



//deletes ebom makup from DB
function ebomDelete(selectone){
        var oneValueChecked=false;
        for(var x = 0;(x<document.markupForm.checkBox.length) && (!oneValueChecked);x++)
        {
          if(document.markupForm.checkBox[x].checked == true)
          {
            oneValueChecked = true;
          }
        }

      if(!oneValueChecked)
      {
        alert("<%=selectAnItemMsg%>");
        return;
      }
        document.markupForm.action="emxengchgEBOMMarkupDelete.jsp";
        document.markupForm.submit();
    }


// ebom makup from DB
function ebomApplyMarkup(objectId){
        var oneValueChecked=false;
        var selectedIndex;
        var selItem=0;
        for(var x = 0;(x<document.markupForm.checkBox.length);x++)
        {
          if(document.markupForm.checkBox[x].checked == true && document.markupForm.checkBox[x].type=="checkbox" )
          {
            selItem=selItem+1;
            selectedIndex=x;
            oneValueChecked = true;
          }

        }

             if(selItem>1)
              {
                alert("<%=selectOnlyOneItemMsg%>");
                return;
              }

      if(!oneValueChecked)
      {
        alert("<%=selectAnItemMsg%>");
        return;
      }
      var markupId=document.markupForm.checkBox[selectedIndex].value;
      var applyEBOMWindow=null;
      if ((applyEBOMWindow == null) || (applyEBOMWindow.closed) )
      {
          winHeight = Math.round(screen.height*50/100);
          winWidth = Math.round(screen.width*50/100);
          winX=Math.round(screen.width/2)-(winWidth/2);
          winY=Math.round(screen.height/2)-(winHeight/2);
        var url = "emxpartApplyEBOMMarkupMergeReplaceFS.jsp?markupId="+markupId+"&objectId="+objectId;
        applyEBOMWindow=window.open(url, "applyEBOMWindow",'height='+winHeight+',width='+winWidth+',left='+winX+',top='+winY+',toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=yes,resizable=1,copyhistory=1,dependent=0');
        applyEBOMWindow.focus()
       }
       else
       {

           applyEBOMWindow.focus()
       }

    }


  function applyebomNewSearch(objectId,markupId)
  {
       var contentURL = "emxpartApplyEBOMMarkupHeader.jsp?markupId="+markupId+"&objectId="+objectId;
       parent.frames[1].document.location.href=contentURL;
    }

    function applyebomSubmit(){
      var oneValueChecked=false;
     var readyState=parent.frames[1].document.statusform.readyState.value;
     if(readyState == "no" )
      {
        alert("<%=searchBeforeApplyMsg%>");
      }else{


      for (var i = 0; i<parent.frames[1].document.resultForm.elements.length; i++)
     {
       if(parent.frames[1].document.resultForm.elements[i].type == "radio")
       {
         if(parent.frames[1].document.resultForm.elements[i].checked == true)
         {
           var temp1 = parent.frames[1].document.resultForm.elements[i].value;
           oneValueChecked=true;
           break;
         }
       }
     }

      if(!oneValueChecked)
      {
        alert("<%=selectAnItemMsg%>");
        return;
      }

      parent.frames[1].document.busIdForm.radioValue.value = temp1;
     parent.frames[1].document.busIdForm.submit();

      }
    }


   function applyebomMarkup(){
    var applytest=parent.frames[1].document.choiceApplyBOM;
     if(applytest==null){
     alert("<%=applyCompletedMsg%>");
     return;
    }
   var attributeAction=parent.frames[1].document.choiceApplyBOM.attributeAction;

   var the_index = attributeAction.selectedIndex;
   var the_selected = attributeAction.options[the_index].value;
   if(the_selected== "Merge")
   {
     parent.frames[1].submitApplyBOMMerge('Merge');
   }else{
     parent.frames[1].submitchoiceApplyBOM('Replace');
   }



}


    function findpartSelect(){
      var oneValueChecked=false;
       var pattern = '|';
      var readyState=parent.frames[1].document.statusform.readyState.value;
     if(readyState == "no" )
      {
        alert("<%=searchAndSelectMsg%>");
      }else{

      for (var i = 0; i<parent.frames[1].document.resultForm.elements.length; i++)
     {
       if(document.resultForm.elements[i].type == "radio")
       {
         if(document.resultForm.elements[i].checked == true)
         {
           var temp1 = document.resultForm.elements[i].value;
           oneValueChecked=true;
           break;
         }
       }
     }

      if(!oneValueChecked)
      {
        alert("<%=selectAnItemMsg%>");
        return;
      }

  var logs2 = temp1.split(pattern);
  var sName2 = logs2[0];
  var sRev2 = logs2[1];
  var svault = logs2[2];
  var sType = logs2[3];
  parent.window.getWindowOpener().document.markupAddForm.targetPartName.value = sName2;
  parent.window.getWindowOpener().document.markupAddForm.targetPartRev.value = sRev2;
  parent.window.getWindowOpener().document.markupAddForm.targetPartVault.value = svault;
  parent.window.getWindowOpener().document.markupAddForm.targetPartType.value = sType;

  parent.closeWindow();
      }
    }

 function mrkpChkFNUniqueness(fnValue)
 {
      for(var i=0;i<fnArray.length;i++)
      {
       if(fnArray[i].length>0 && fnArray[i]==fnValue)
    {
      return false;
      }
      }
   return true;
 }
    
</script>
<%! 
    /**
      * This method is used for removing whitespaces from the Attribute Name
      * @param String - Name of the Attribute
      * @return Attribute name without whitespaces
      * @exception java.lang.Exception The exception description
      **/
    public String removeWhiteSpace(String str) throws Exception
    {
        String whiteSpace = " ";
        String newstr = "";
        try{
            for(int i=0;i<str.length();i++){
                String chstr  =  str.charAt(i)+"";
                if (chstr.equals(whiteSpace)){
                    newstr = str.substring(0,i) + str.substring(i+1, str.length());
                    str=newstr;
                }
            }
        }
        catch(Exception e){
                throw e;
        }
        return str;
    }
     
     /**
      * This method is used for converting the Unicode to equivalent Character Entity String.
      * @param String - Unicode string
      * @return Equivalent character entity of the Unicode
      * @exception java.lang.Exception The exception description
      **/
    public String getCharacterEntityString (String strUnicode) throws Exception {
        StringBuffer sb = new StringBuffer ();
        try{
            int len = strUnicode.length ();
            for (int i=0;i<len ;i++ )
            {
                int c = strUnicode.charAt (i);
                sb.append (c);
                sb.append (";");
            }
        }
        catch(Exception e){
            throw e;
        }
        return sb.toString ();
    }

%>
