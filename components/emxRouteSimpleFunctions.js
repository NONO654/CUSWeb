//=================================================================
// JavaScript emxRouteSimpleFunctions.js
// Copyright (c) 1992-2018 Dassault Systemes.
// All Rights Reserved.
// This program contains proprietary and trade secret information of MatrixOne,Inc.
// Copyright notice is precautionary only
// and does not evidence any actual or intended publication of such program
//  static const char RCSID[] = $Id: emxRouteSimpleFunctions.js.rca 1.4.2.5 Wed Oct 22 16:18:51 2008 przemek Experimental przemek $
//=================================================================


function  populateQuickRouteMemberList(categ,valueList)
  {
      var frame = emxUICore.findFrame(getTopWindow().getWindowOpener().getTopWindow(), "pagecontent");
	  if(frame != null){
		  box = frame;
	  }else{
      box=getTopWindow().getWindowOpener();
	  }
       if(valueList!=null)
      {
          
          valueArr=valueList.split(";");
          for(index=0;index<valueArr.length;index++)
          {
                        curValue=trimWhitespace(valueArr[index]+"");
                        if(curValue.length>0)
                      {
                            curNameValue=curValue.split("|");
                            if(categ=="PERSON")
                           {
                            box.addOption(curNameValue[0],curNameValue[1]);
                          }
                          else
                          {
                            box.addOption(curNameValue[0]+"("+categ+")",curNameValue[1]);
                          }
                      }

            }
       }
  }
  
  
 function  populateQuickRouteMemberListFromIDArray(idAndNameArray, typeLabel)
 {
	  box=getTopWindow().getWindowOpener();
 	  if (idAndNameArray !=null && idAndNameArray.length >0){
		  for (var i=0; i<idAndNameArray.length; i++){
			    var value = idAndNameArray[i];
			    if (value == null){
				    continue;
			    }

				if(typeLabel == null || typeLabel == "")
                {
                	box.addOption(value[1], value[0]);
                }
                else
                {
                    box.addOption(value[1]+"("+typeLabel+")", value[0]);
                }			    
		  }
	  }
 }
  

    function addOption(label,value)
    {
                 thisForm=document.createSimpleDialog;
                 selectBox=thisForm.memberFinalList;
                 if(!isExists(value,selectBox))
                 {
                     selectBox.options[selectBox.length]=new Option(label,value,false,false);
                 }
                 else
                {
                     ;
                }
    }

  function isExists(currentValue,selectBox)
  {
          for(i=0;i<selectBox.length;i++)
         {
               o=selectBox.options[i];
                if(currentValue==o.value)
                {
                        return true;
                }
         }
         return false;
  }

  function removeRouteMember()
  {
      thisForm=document.createSimpleDialog;
      selectBox=thisForm.memberFinalList;
      var selectedLength=getSelectedEntries(selectBox).length;
      var originalLength=selectBox.length;
      var j=0;
      var itmSelected = 0;
      for(i=0;i<selectBox.length;i++)
      {
          if(selectBox.options[i].selected)
          {
            itmSelected = 1;
            break;
          }
      }
      if(itmSelected == 0)
      {
        alert(MAKE_SELECTION_MSG);
        return false;
      }
      if(confirm(REMOVE_WARNING_MSG))
      {
        for(i=0;i<selectBox.length;i++)
        {
          if(selectBox.options[i].selected)
          {
            selectBox.options[i]=null;
            i=-1;
          }
        }
      } 
  }

  function validateRouteDueDate(milliSecondsValue)
  {
       var toDayDate=new Date();
       toDayDate.setDate(toDayDate.getDate());

       var enteredDate = new Date();
       enteredDate.setTime(milliSecondsValue);
       if (enteredDate.getFullYear()< 1950) 
        {
            enteredDate.setFullYear(enteredDate.getFullYear() + 100);
        }
        //Added for the bug 364008
        if( Date.parse(enteredDate.toDateString()) < Date.parse(toDayDate.toDateString()))
        {
        	return false;
        }
        else
        	return true;
        //Ended
        /*if( Date.parse(enteredDate.toGMTString()) <= Date.parse(toDayDate.toGMTString()) )
        {
                
                return false;
        }
        else 
        {
                
                return true;
        }*/
  }
  

                
function handleButtonEvent(eventType,button)
{
      //eventType=event.type;
      switch(eventType)
      {
          case 1:
                            button.className="rollover rolloverhover";
                            break;
           case 2:
                            button.className="rollover rolloveractive";
                            break;
            case 3:
                            button.className="rollover";
                            break;
            case 4:
                           button.className="rollover";
                            break;
      }
}

function getSelectedEntries(selectbox)
{
          thisForm=document.createSimpleDialog;
          selectBox=thisForm.memberFinalList;
          var entries=new Array();
          var j=0;
          for(i=0;i<selectBox.length;i++)
          {
              if(selectBox.options[i].selected)
              {
                 entries[j++]=selectBox.options[i].value;
              }
          }
          return entries;

}
function isPerson(personId)
{
                //regular expression to find the Alphabet index
               var alphaIndex=/[a-z]/ig.test(personId);
               if(!alphaIndex)
               {
                   return true;
               }
               else
              {
                 return false;
              }
}
