function renderError(errorText, container) {
    // add title
    var _se = document.createElement("div");
    container.appendChild(_se);
    _se.classList.add('SectionContainer');

    var setitle = document.createElement("div");
    setitle.textContent = "Error";
    _se.appendChild(setitle);
    setitle.classList.add('SectionTitle');
    setitle.style['background-color'] = '#fcc';
    
    var se = document.createElement("div");
    _se.appendChild(se);

    var text = document.createElement("textarea");
    text.readOnly = true;

    var imgContainer = document.createElement("div");
    imgContainer.classList.add('ImageContainer');

    
    var numLines = errorText.split(/\r\n|\r|\n/).length;
    if (numLines > 10)
    {
        numLines = 10;
    }
    text.setAttribute("style",
            "width:100%;min-height:" + numLines
                    + "rem;");
    text.value = errorText;

    imgContainer.appendChild(text);
    
    _se.style.width="calc(100% - 10px)";
    _se.style['min-height'] = (numLines+5)+'rem';
    se.style.width="calc(100% - 10px)";
    imgContainer.style.width="calc(100% - 10px)";
    imgContainer.style.height=numLines+"rem";
    
    se.appendChild(imgContainer);
}
function renderReport(report, container, previousVisuals, renderCodeBlocks)
{
    var container = container || document.getElementById('container');
    container.innerHTML = "";
    if (!previousVisuals)
    {
        document.title = report.title;
        container.classList.add('ReportContainer');

        var titleDiv = document.createElement('div');
        titleDiv.classList.add('ReportTitle');
        titleDiv.textContent = report.title;
        container.appendChild(titleDiv);
    }
    var reportData = report.data;
    var newSections = [];
    if (!report.reportSections)
        return;
    report.reportSections
            .forEach(function(section, i)
            {
                if (!section.visuals)
                    return;
                newSections[i] = section.visuals.length;

                if (previousVisuals)
                {
                    // ignore previous sections
                    if (i < previousVisuals.length - 1)
                    {
                        return;
                    } else if (i == previousVisuals.length - 1)
                    {
                        // process the last seen section only if it has more
                        // visuals
                        if (section.visuals.length == previousVisuals[i])
                        {
                            return;
                        }

                    }

                }
                // add title
                var _se = document.createElement("div");
                container.appendChild(_se);
                _se.classList.add('SectionContainer');

                var selector = 'section' + i;
                if (!previousVisuals
                        || (i == previousVisuals.length - 1 && section.visuals.length > previousVisuals[i]))
                {
                    if (section.title)
                    {
                        var setitle = document.createElement("div");
                        setitle.textContent = section.title;
                        _se.appendChild(setitle);
                        setitle.classList.add('SectionTitle');
                    }
                }
                var se = document.createElement("div");
                _se.appendChild(se);
                var widths = [];
                var width = 300;
                var nestedContainers = [];
                var isSectionCodeOrError = false;
                section.visuals
                        .forEach(function(visual, j) {
						try{
                            width = parseInt(visual.options.width || '300');
                            var height = parseInt(visual.options.height
                                    || visual.options.width || '300')
                                    + titleHeight;
                            // dont process the already seen visuals
                            if (previousVisuals && j < previousVisuals[i])
                            {
                                return;
                            }
                            var imgContainer = document.createElement("div");
                            imgContainer.classList.add('ImageContainer');
                            imgContainer.classList.add(selector);
                            var titleHeight = 0;
                            if (visual.name && visual.visualType !== "code" )
                            {
                                var imgTitle = document.createElement("div");
                                imgTitle.classList.add('ImageTitle');
                                imgTitle.textContent = visual.name;
                                imgContainer.appendChild(imgTitle);
                                titleHeight = 40;
                            }
                            if (visual.visualType === "data")
                            {
                                var text = document.createElement("textarea");
                                text.readOnly = true;

                                var str = visual.options.data;
                                var numLines = str.split(/\r\n|\r|\n/).length;
                                if (numLines > 10)
                                {
                                    numLines = 10;
                                }
                                text.setAttribute("style",
                                        "width:100%;min-height:" + numLines
                                                + "rem;");
                                text.value = reportData;

                                imgContainer.appendChild(text);

                            } else if (visual.visualType === "image")
                            {
                                var img = document.createElement("img");
                                img.setAttribute("src",
                                        "data:image/png;charset=utf-8;base64, "
                                                + visual.options.encodedImage);
                                imgContainer.setAttribute("style", "width:"
                                        + visual.options.width + "px");
                                imgContainer.appendChild(img);

                            } else if (visual.visualType === "code" && renderCodeBlocks)
                            {
                            	isSectionCodeOrError = true;
                                var text = document.createElement("textarea");
                                text.readOnly = true;

                                var str = decodeURIComponent(visual.options.data);
                                var numLines = str.split(/\r\n|\r|\n/).length;
                                if (numLines > 10)
                                {
                                    numLines = 10;
                                }
                                text.setAttribute("style",
                                        "width:100%;min-height:" + numLines
                                                + "rem;");
                                

                                imgContainer.appendChild(text);
                                
                                if(CodeMirror) {
                                	var cm = CodeMirror.fromTextArea(text, {
                                        lineNumbers: true,
                                        mode: "javascript"
                                      });
                                	cm.setValue(str);
                                	try{
                                		cm.click();
                                	} catch(e) {}
                                } else {
                                	text.value = decodeURIComponent(visual.options.data);
                                }
                            }else if (visual.visualType === "text")
                            {
                                var text = document.createElement("textarea");
                                text.readOnly = true;

                                var str = visual.options.data || "";
                                var numLines = str.split(/\r\n|\r|\n/).length;
                                if (numLines > 10)
                                {
                                    numLines = 10;
                                } else if (numLines < 1) {
									numLines = 1;
								}
                                text.setAttribute("style",
                                        "resize:none;width:100%;min-height:" + numLines
                                                + "rem;height:100%;");
                                text.value = decodeURIComponent(str);
                                height = '' +(numLines+1) +'rem';
                                imgContainer.appendChild(text);
                            } else if (visual.visualType === "globalEffects")
                            {
                                imgContainer.setAttribute("style", "width:"
                                        + visual.options.width + "px;height:"
                                        + visual.options.height + "px");
                                var ge = JSON.parse(visual.options.data);
                                var series = [];
                                var categories = [];
                                if (!ge)
                                    return;
                                ge.forEach(function(oe)
                                {
                                    var seriesData = [];
                                    categories = [];
                                    oe.coeffs.forEach(function(e)
                                    {
                                        categories.push(e.param);
                                        seriesData.push(e.value);
                                    });

                                    series.push({
                                        "name" : oe.param,
                                        "data" : seriesData
                                    })
                                });
                                Highcharts.chart(imgContainer, {
                                    chart : {
                                        type : 'bar'
                                    },
                                    title : {
                                        text : visual.name,
                                        align : 'high'
                                    },
                                    xAxis : {
                                        categories : categories,
                                        title : {
                                            text : null
                                        }
                                    },
                                    yAxis : {
                                        min : 0,
                                        title : {
                                            text : 'Effect',
                                            align : 'high'
                                        },
                                        labels : {
                                            overflow : 'justify'
                                        }
                                    },
                                    legend : {
                                        layout : 'vertical',
                                        align : 'right',
                                        verticalAlign : 'top',
                                        x : -40,
                                        y : 80,
                                        floating : true,
                                        borderWidth : 1,
                                        backgroundColor : '#FFFFFF',
                                        shadow : true
                                    },
                                    credits : {
                                        enabled : false
                                    },
                                    series : series
                                });
                            } else if (visual.visualType === "mainEffects")
                            {

                                imgContainer
                                        .setAttribute("style", "width:100%");
                                var meContainer = document.createElement("div");
                                meContainer.setAttribute("style",
                                        "width:100%; position:relative");
                                imgContainer.appendChild(meContainer);
                                nestedContainers.push(meContainer);
                                var me = JSON.parse(visual.options.data);
                                if (!me)
                                    return;
                                var sweepData = me.sweepData;
                                var inputNames = me.inputNames;
                                var outputNames = me.outputNames;
                                var sweepSize = me.sweepSize;

                                var y = 0;
                                for (y = 0; y < outputNames.length; y++)
                                {
                                    var series = [];
                                    var categories = [];
                                    var chart = document.createElement('div');
                                    chart.setAttribute("style",
                                            "position:absolute;width:"
                                                    + visual.options.width
                                                    + "px;height:"
                                                    + visual.options.height
                                                    + "px");
                                    for (var k = 0; k < sweepSize; k++)
                                    {
                                        categories.push(k * 100.0
                                                / (sweepSize - 1));
                                    }
                                    var seriesData = [];
                                    sweepData
                                            .forEach(function(row, i)
                                            {

                                                var sweepIndex = i % sweepSize;
                                                var seriesIndex = Math.floor(i
                                                        / sweepSize);
                                                seriesData.push(row[y])

                                                if (sweepIndex == sweepSize - 1)
                                                {
                                                    series
                                                            .push({
                                                                "name" : inputNames[seriesIndex],
                                                                "data" : JSON
                                                                        .parse(JSON
                                                                                .stringify(seriesData))
                                                            });
                                                    seriesData = [];
                                                }
                                            });
                                    Highcharts.chart(chart, {
                                        chart : {
                                            type : 'spline'
                                        },

                                        title : {
                                            text : ''
                                        },

                                        xAxis : {
                                            categories : categories,
                                            title : {
                                                text : null
                                            }
                                        },
                                        yAxis : {
                                            title : {
                                                text : 'Effects on '
                                                        + outputNames[y],
                                                align : 'high'
                                            },
                                            labels : {
                                                overflow : 'justify'
                                            }
                                        },
                                        credits : {
                                            enabled : false
                                        },
                                        series : series
                                    });

                                    var margin = 5;
                                    var height = parseInt(visual.options.height
                                            || visual.options.width || '300')
                                            + titleHeight;
                                    widths.push(width);
                                    var style = document.createElement('style');
                                    style.type = 'text/css';
                                    var className = selector + '-chart' + j
                                            + '-me'
                                    style.innerHTML = '.' + className
                                            + ' { width: '
                                            + (width + 2 * margin)
                                            + '; height: '
                                            + (height + 2 * margin) + '}';
                                    document.getElementsByTagName('head')[0]
                                            .appendChild(style);
                                    chart.classList.add(className);

                                    meContainer.appendChild(chart);
                                    // imgContainer.appendChild(chart);
                                }
                                // width = (width + 5) * outputNames.length;
                            }
                            var margin = 5;
                            widths.push(width);
                            var style = document.createElement('style');
                            style.type = 'text/css';
                            var className = selector + '-chart' + j
                            
                            if(visual.visualType === "code") {
                            	if(renderCodeBlocks) {
    	                            style.innerHTML = '.' + className + ' { width: '
	                                    + 'calc(100% - 10px)' + '; height: '
	                                    + '10rem' + ';}';
		                            document.getElementsByTagName('head')[0]
		                                    .appendChild(style);
		                            imgContainer.classList.add(className);
                            		
                            	} else {
    	                            style.innerHTML = '.' + className + ' { width: '
	                                    + 0 + '; height: '
	                                    + 0 + '; display:none;}';
		                            document.getElementsByTagName('head')[0]
		                                    .appendChild(style);
		                            imgContainer.classList.add(className);
                            	}
                            } else if(visual.visualType === "text"){
                            	
                            	var resizeFunction= function (e) {
	    	                            style.innerHTML = '.' + className + ' { width: '
		                            	+ (se.clientWidth - 2 * margin) + '; height: '
		                            	+ (height + 2 * margin) + '}';
                            	}
                            	window.addEventListener('resize',resizeFunction);
                            	
	                            style.innerHTML = '.' + className + ' { width: '
	                            	+ (se.clientWidth - 25) + '; height: '
	                            	+ (height + 2 * margin) + '}';
	                            
	                            document.getElementsByTagName('head')[0]
	                            .appendChild(style);
	                            imgContainer.classList.add(className);
                            }	else {
	                            style.innerHTML = '.' + className + ' { width: '
	                                    + (width + 2 * margin) + '; height: '
	                                    + (height + 2 * margin) + '}';
	                            document.getElementsByTagName('head')[0]
	                                    .appendChild(style);
	                            imgContainer.classList.add(className);
                            }
                            se.appendChild(imgContainer);
						} catch (e) {
							//ignore
							console.error(e);
						}
                        });
                if (window.Muuri && !isSectionCodeOrError)
                {
                	try {
	                    var grid = new Muuri(se, {
	                        dragEnabled : false
	                    });
	
	                    if (nestedContainers && nestedContainers.length > 0)
	                    {
	                        nestedContainers.forEach(function(ne)
	                        {
	                            var g = new Muuri(ne, {
	                                dragEnabled : false
	                            });
	                        })
	                    }
                	} catch (e) {
                		//ignore
                		console.error(e);
                	}

                } else {
                	se.style['min-height'] = '11rem';
                }
                if(se.children.length == 0) {
                	se.style.display='none';
                	se.style.width='0px';
                	se.style.height='0px';
                }
            });
    return newSections;
}
