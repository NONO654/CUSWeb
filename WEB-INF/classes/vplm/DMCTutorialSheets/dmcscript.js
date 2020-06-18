initialize = function(min, max){
	if ( min == undefined || max == undefined){
		alert("Bad initialize() invokation");
	}
	_idMin = min;
	_idMax = max;
	_currentIdStep = min;
	displayStep(_idMin);
}

// switch to the next step of the tutorial (stepid is then id+1)
nextStep = function(id){
	if (id == undefined){
		alert("Bad nextstep() invokation");
	}

	_currentIdStep = id + 1;
	
	displayStep(_currentIdStep);
}

// display only the id wanted
displayStep = function(id){
	if (id == undefined){
		alert("Bad displayStep() invokation");
	}
	for (var i = _idMin; i <= _idMax; i++){
		validateStatus(i);
		if (i == id){
			showStep(i);
		}
		else{
			hideStep(i);
		}
	}
	// show/hide the message of the end
	if (_currentIdStep > _idMax){
		displayFinished(true);
	}
	else{
		displayFinished(false);
	}
}

// show or hide the message : tutorial finished
displayFinished = function(bVisible){
	if (bVisible == undefined){
		alert("Bad displayFinished() invokation");
	}
	var pFinish = document.getElementById("finished");
	if (bVisible == true){
		var sClass = "finishShown";
	}
	else{
		var sClass = "finishHidden";
	}
	pFinish.className = sClass;
}

// tick the status of the id if the step is done
validateStatus = function(id){
	if (id == undefined){
		alert("Bad ValidateStatus() invokation");
	}
	var bDone = false;
	if (id < _currentIdStep){
		bDone = true;
	}
	var sPathImg = "rsc/DMCHelp_empty.gif";
	if (bDone){
		sPathImg = "rsc/DMCHelp_check.gif";
	}
	var pStatus = document.getElementById("status" + id);

	pStatus.setAttribute("src", sPathImg);
	
}

// display the step wanted
showStep = function(id){
	if (id == undefined){
		alert("Bad showStep() invokation");
	}
	var pStep = document.getElementById("step" + id);
	var sClass = "stepTodoShown";
	if (id < _currentIdStep){
		sClass = "stepDoneShown";
	}
	pStep.className = sClass;
	var pArrow = document.getElementById("arrow" + id);
	pArrow.setAttribute("src", "rsc/DMCHelp_down.gif");
}

// hide the step wanted
hideStep = function(id){
	if (id == undefined){
		alert("Bad hideStep() invokation");
	}
	var pStep = document.getElementById("step" + id);
	var sClass = "stepTodoHidden";
	if (id < _currentIdStep){
		sClass = "stepDoneHidden";
	}
	sClass += (id % 2);
	pStep.className = sClass;
	var pArrow = document.getElementById("arrow" + id);
	pArrow.setAttribute("src", "rsc/DMCHelp_right.gif");
}

setColor = function(id){
	if (id == undefined){
		alert("Bad setColor() invokation");
	}
	var pStep = document.getElementById("step" + id);
	
	var color = "red";
	if ( (id % 2) == 0){
		color = "blue";
	}
	pStep.style.backgroundColor = color;
	
}
