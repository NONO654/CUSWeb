	var option;
	var id;
	function addType(){
		$('#PLMTable').append(
					'<tr id="'+id+'" class="tab" style="height:30px">'
				+		'<td>'+divElement(id)+'</td>'
				+		'<td>'+editElement(id)+'</td>'
				+		'<td>'+selElement(id)+'</td>'
				+		'<td>'+deleteElement(id)+'</td>'
				+	'</tr>');
		id++;
		refresh();
		
	}
	function addEntry(name, type){
		addType();
		$('#selectType'+(id-1)).val(type);
		$('#viewName'+(id-1)).text(name);
		setType(id-1);
	}
	function selElement(id){
		var tmp = '';
		tmp+='<select id="selectType'+id+'" style="width:122px;height:20px;" class="selectType" onfocus="onFocusActionType('+id+')" onblur="onBlurActionType('+id+')" onchange="onChangeActionType('+id+')">';
		tmp+=option;
		tmp+='</select>';
		tmp+='<span id="viewType'+id+'" style="text-overflow: ellipsis;cursor:default;width:120px;background-color:#FFFFFF;border:1px solid grey;height:18px;font-size: 10pt;font-family: monospace;display: inline-block;overflow:hidden;" class="viewType" onclick="onClickActionType('+id+')"/>';
		return tmp
	}
	function divElement(id){
		return '<div id="viewName'+id+'" style="text-overflow: ellipsis;width:110px;height:18px;overflow:hidden;font-size: 10pt;font-family: monospace;" class="viewName" onclick="onClickActionName('+id+')"/>';
	}
	function inputElement(id){
		return '<input id="editName'+id+'" type="textarea" style="width:110px;height:16px;" onblur="onBlurActionName('+id+')" onkeyup="if(isEnterPressed(event)){onBlurActionName('+id+');}"/>';
	}
	function deleteElement(id){
		return '<img title="Delete" src="../common/images/iconActionDelete.gif" class="delType" onclick="onDelete('+id+')"/>';
	}
	function editElement(id){
		return '<img id="editType'+id+'" title="Edit type" src="../common/images/iconActionEdit.gif" class="editType" onclick="onEditType('+id+')"/>';
	}
	function onDelete(id){
		$('#'+id+'.tab').remove();
		refresh();
	}
	function onEditType(id){
		$('span.viewType').show(); 
		$('select.selectType').hide(); 
		$('span.viewType').css('color','lightgrey');
		$('img.editType').hide();
		$('#viewType'+id).hide();
		$('#selectType'+id).val($('#viewType'+id).text());
		$('#selectType'+id).show();
		$('#editType'+id).show();
		$('#selectType'+id).css('border','2px solid green');
	}
	function onClickActionName(id){
		var editableText = $(inputElement(id));
		$('div.viewName').css('color','lightgrey');
		editableText.val($('#viewName'+id).html());
		$('#viewName'+id).replaceWith(editableText);
		$('#editName'+id).css('border','2px solid green');
		editableText.focus();
		if(id==$('#PLMTable tr.tab:last').attr('id')){
			onEditType(id);
		} else {
			refresh();
		}
	}
	function onFocusActionType(id){
		if(id==$('#PLMTable tr.tab:last').attr('id')){
			$('div.viewName').css('color','lightgrey');
			$('#viewName'+id).css('color','black');
			onEditType(id);
			$('#viewName'+id).css('border','2px solid green');
		}
	}
	function onBlurActionType(id){
		setType(id);
		refresh();
	}
	function onChangeActionType(id){
		setType(id);
		if(id==$('#PLMTable tr.tab:last').attr('id')){
			if($('#selectType'+id).val()!=''){
				if($('#viewName'+id).html()!=''){
					addType();
				}
			}
		}else{
			refresh();
		}
	}
	function setType(id){
		var type=$('#selectType'+id).val();
		$('#viewType'+id).text(type);
		$('#viewType'+id).attr('title',type);
	}
	function onBlurActionName(id) {
		var viewableText=$(divElement(id,0));
		var actor=$('#editName'+id);
		var actorValue=actor.val();
		viewableText.html(actorValue);
		actor.replaceWith(viewableText);
		if(actorValue!=''){
			if(id==$('#PLMTable tr.tab:last').attr('id')){
				if($('#selectType'+id).val()!=''){
					addType();
				}
			}
		}
		refresh();
	}
	function isEnterPressed(e){
		var keycode=null;
		if(e!=null){
			if(window.event!=undefined){
				if(window.event.keyCode){
					keycode=window.event.keyCode;
				}else if(window.event.charCode){
					keycode=window.event.charCode;
				}
			}else{
				keycode=e.keyCode;
			}
		}
		return (keycode==13);
	}
	function refresh(){
		$('span.viewType').css('color','black');
		$('div.viewName').css('color','black');
		$('#PLMTable tr:even').css('background-color', '#EEF0F0');
		$('#PLMTable tr:odd').css('background-color', 'White');
		$('#PLMTable tr:first').css('background-color', '#A9CAE6');
		$('select.selectType').css('border','1px solid grey');
		$('div.viewName').css('border','1px solid grey');
		$('input.editName').css('border','1px solid grey');
		$('div.viewName').each(function(){
			var text=$(this).text();
			$(this).css('color','black');
			$(this).css('border','1px solid grey');
			$(this).css('background-color','white');
			if(text != ''){
				if(!isValid(text)){
					$(this).css('color','white');
					$(this).css('background-color','red');
					$(this).attr('title','Invalid name!');
				}
				if(wordCount(text)!=1)	{
					$(this).css('color','white');
					$(this).css('background-color','red');
					$(this).attr('title','Duplicate name!');
				}
			}
		});
		$('img.delType').show();
		$('img.delType:last').hide();
		$('img.editType').show();
		$('img.editType:last').hide();
		$('span.viewType').show();
		$('span.viewType:last').hide();
		$('select.selectType').hide();
		$('select.selectType:last').show();
	}
	function wordCount(text){
		var c=0;
		$('div.viewName').each(function(){
			if(text == $(this).text()) {
				c++;
			}
		});
		return c;
	}
	function isValid(text){
		return text.match(/^[a-zA-Z]+$/);
	}
	function mainArgumentList(){
		id=0;
		buildBody();
		option=buildOptionsList();
		addEntry('"+tmp[0]+"','"+tmp[1]+"');
		addType();
		setType(id-1);
		refresh();
	}
	$('document').ready(mainArgumentList);
	function setBody(body){
		$('#body').html(body);
	}
	function getBody(){
		return $('#body').html();
	}
	function getArgumentList(){
		var res = '';
		$('#PLMTable tr.tab').each(function(i, a){
			var name=$('#viewName'+$(this).attr('id')).text();
			var type=$('#viewType'+$(this).attr('id')).text();
			if(isvalid(name) && name!='' && type!='' && wordCount(name)==1){
				res+=name+':'+type+';';
			}
		});
		alert(res);
		return res;
	}
	function buildBody(){
		var textarea = $('#body');
		textarea.attr('wrap', 'off');
		textarea.css({resize:'none'});
		var originalTextAreaWidth	= textarea.outerWidth();
		textarea.wrap("<div class='linedtextarea'></div>");
		var linedWrapDiv = textarea.parent().wrap("<div class='linedwrap' style='width:"+originalTextAreaWidth+"px'></div>").parent();
		linedWrapDiv.prepend("<div class='lines' style='width:50px'></div>");
		var linesDiv = linedWrapDiv.find(".lines");
		linesDiv.height( textarea.height() + 6 );
		linesDiv.append( "<div class='codelines'></div>" );
		var codeLinesDiv = linesDiv.find('.codelines');
		var lineNo = fillOutLines( codeLinesDiv, linesDiv.height(), 1 );
		var paddingHorizontal = parseInt(linedWrapDiv.css('border-left-width'))+parseInt(linedWrapDiv.css('border-right-width'))+parseInt(linedWrapDiv.css('padding-left'))+parseInt(linedWrapDiv.css('padding-right'));
		var textareaNewWidth = originalTextAreaWidth - linesDiv.outerWidth() - paddingHorizontal - 20;
		textarea.width( textareaNewWidth );
		linedWrapDiv.width( originalTextAreaWidth - paddingHorizontal );
		textarea.scroll( function(){
			var domTextArea		= $(this)[0];
			var scrollTop 		= domTextArea.scrollTop;
			var clientHeight 	= domTextArea.clientHeight;
			codeLinesDiv.css( {'margin-top': (-1*scrollTop) + 'px'} );
			lineNo = fillOutLines( codeLinesDiv, scrollTop + clientHeight, lineNo );
		});
		textarea.resize( function(){
			linesDiv.height( $(this)[0].clientHeight + 6 );
		});
	}
	var fillOutLines = function(codeLines, h, lineNo){
		while ( (codeLines.height() - h ) <= 0 ){
			codeLines.append("<div class='lineno'>" + lineNo + '</div>');
			lineNo++;
		}
		return lineNo;
	};
