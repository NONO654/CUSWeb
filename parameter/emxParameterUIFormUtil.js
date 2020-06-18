var canParamSubmit = true;
function setParamFormSubmitAction(submitaction)
{
	canParamSubmit = submitaction;
}

function parameterSaveCreateChanges(isApply,targetLocation)
{
	if(!isApply){
		isApply = false;
	}
	if(canParamSubmit)
	{
		if (validateCreateForm())
		{
			turnOnProgress();
			var objform = document.forms['emxCreateForm'];
			var timeStamp=document.getElementById("timeStamp").value;
			var mode=document.getElementById("mode").value;
			var uiType=document.getElementById("uiType").value;
			if (validatemxLinks(objform, mode, uiType, timeStamp)) {
				setParamFormSubmitAction(false);
				objform.target = "formCreateHidden";
				objform.action = "emxParameterCreateProcess.jsp?isApply=" + isApply;
				addSecureToken(objform);
				objform.submit();
				removeSecureToken(objform);
			}
		}
		else
		{
			setParamFormSubmitAction(true);
		}
	}
	else
	{
		return;
	}
}
