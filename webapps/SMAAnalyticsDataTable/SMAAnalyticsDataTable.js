/* global d3 */
/* global define */
/* global console */

define(
    'DS/SMAAnalyticsDataTable/SMAAnalyticsDataTableSVGHeader',
    [],
    function() {
        'use strict';

        // This function defines an interactive SVG header. Most of the
        // functionality contained in this is no longer in use, and  it needs
        // significant cleanup work.

        function SVGHeader(header) {
            var that = this;

            this.parent = header;

            this.controlObjects = { header: header };

            this.state = {
                totalDataDepth: this.getDataHandler().svgHeaderData.dataDepth,
                dataDepth: this.getDataHandler().svgHeaderData.dataDepth - 1,
                toggleState: 0,
                dragState: {}
            };

            this.dimensions = {
                textRectHeight: 20,
                rectPadding: 0,

                parameterHeaderHeight: 20,
                paramRowHeight: header.dimensions.fixedHeader.height,
                dragWidth: 10 // This is the width of the SVG rects that can be
                // dragged to resize columns.
            };

            this.dimensions.paramSectionHeight =
                this.dimensions.paramRowHeight + 4;

            this.dimensions.collapsedGroupHeight = 0; // this.dimensions.branchWidth +
            // this.dimensions.branchDescent;
            this.dimensions.expandedGroupHeight = this.dimensions.textRectHeight;

            this.dimensions.collapsedTotalHeight = 0; //(this.state.dataDepth) *
            //this.dimensions.collapsedGroupHeight;
            this.dimensions.expandedTotalHeight =
                this.state.dataDepth * this.dimensions.expandedGroupHeight;
            this.dimensions.svgHeight = this.dimensions.paramRowHeight + 4; // + this.dimensions.collapsedTotalHeight
            this.dimensions.currentGroupHeight = 0; // this.dimensions.collapsedGroupHeight;
            this.dimensions.currentTotalHeight = 0; // this.dimensions.collapsedTotalHeight;

            this.scales = {
                xScale: d3.scale.
                    linear().
                    range([0, header.dimensions.mainHeader.totalWidth]).
                    domain([0, 1]),
                yScale: d3.scale.
                    linear().
                    range([0, this.dimensions.collapsedTotalHeight]).
                    domain([
                        1 / (this.state.totalDataDepth + 1),
                        this.state.totalDataDepth /
                            (this.state.totalDataDepth + 1)
                    ])
            };

            this.SVGs = {
                SVG: d3.
                    select(header.containerDivs.svgContentFrame).
                    append('svg').
                    attr('width', header.dimensions.mainHeader.totalWidth).
                    attr('height', that.dimensions.svgHeight)
            };

            this.containerDivs = {
                frame: this.parent.containerDivs.svgContentFrame,
                container: this.parent.containerDivs.svgContainer
            };

            this.SVGs.groupsGroup = this.SVGs.SVG.append('g');
            this.SVGs.parametersGroup = this.SVGs.SVG.append('g');
            this.SVGs.dragRectsGroup = this.SVGs.SVG.append('g');
            try {
                this.SVGs.groupsGroup.
                    node().
                    classList.add('dataTable-header-groupsGroup');
                this.SVGs.parametersGroup.
                    node().
                    classList.add('dataTable-header-parametersGroup');
                this.SVGs.dragRectsGroup.
                    node().
                    classList.add('dataTable-header-dragRectsGroup');
            } catch (e) {
                // for IE classList doesn't work on svg elements and className
                // cannot be modified in strictmode ...
                this.SVGs.groupsGroup.
                    node().
                    setAttribute('class', 'dataTable-header-groupsGroup');
                this.SVGs.parametersGroup.
                    node().
                    setAttribute('class', 'dataTable-header-parametersGroup');
                this.SVGs.dragRectsGroup.
                    node().
                    setAttribute('class', 'dataTable-header-dragRectsGroup');
            }
            //.classed('dataTable-header-groupsGroup', true);

            //          .classed('dataTable-header-parametersGroup', true);

            //          .classed('dataTable-header-dragRectsGroup', true);

            d3.
                select(header.containerDivs.svgContainer).
                style('height', this.dimensions.collapsedTotalHeight + 'px');

            this.updateSVGHeader();

            this.updateDragRects();
        }

        SVGHeader.prototype.updateGroups = function(instant) {
            var newGroups,
                groups,
                header = this;

            var groupsData = header.
                getDataHandler().
                getSVGHeaderData().
                groupData.filter(function(d) {
                    return d.y !== 0;
                });

            groups = this.SVGs.groupsGroup.
                selectAll('g.dataTable-header-dataGroup').
                data(groupsData, function(d) {
                    return d.ID;
                });

            groups.exit().remove();

            newGroups = groups.enter().append('g');

            newGroups.
                classed('dataTable-header-dataGroup', true).
                attr('transform', function(d) {
                    return (
                        'translate(' +
                        header.scales.xScale(d.x) +
                        ',' +
                        header.scales.yScale(d.y) +
                        ')'
                    );
                });

            newGroups.
                append('rect').
                attr('x', header.dimensions.rectPadding). // function(d){return xScale(d.x)})
                //.attr('y', header.state.toggleState === 1 ?
                //header.dimensions.textRectHeight +
                //header.dimensions.branchDescent : 0)//function(d){return
                //yScale(d.y)})
                attr('width', function(d) {
                    return (
                        header.scales.xScale(d.dx) -
                        header.dimensions.rectPadding * 2
                    );
                }).
                attr('height', function(d) {
                    if (header.state.toggleState === 1) {
                        return (
                            (header.state.dataDepth - (d.depth - 1)) *
                            header.dimensions.textRectHeight
                        );
                    }
                    // else
                    return 0;
                }).
                classed('dataTable-header-nodeTextRect', true).
                attr('y', 0);

            newGroups.
                append('text').
                text(function(d) {
                    return d.displayName;
                }).
                attr('x', function(d) {
                    return header.scales.xScale(d.dx) / 2;
                }).
                attr('text-anchor', 'middle').
                style('opacity', header.state.toggleState === 1 ? 1 : 0).
                classed('dataTable-header-nodeText', true).
                attr('y', 14);

            this.SVGs.groups = groups;

            if (header.state.toggleState === 0) {
                groups.classed('dataTable-header-collapsedGroup', true);
            } else {
                groups.classed('dataTable-header-collapsedGroup', false);
            }

            if (!instant) {
                // Change groups to a transition
                groups = groups.transition();
            }

            groups.attr('transform', function(d) {
                return (
                    'translate(' +
                    header.scales.xScale(d.x) +
                    ',' +
                    header.scales.yScale(d.y) +
                    ')'
                );
            });

            groups.
                select('rect.dataTable-header-nodeTextRect').
                attr('width', function(d) {
                    return (
                        header.scales.xScale(d.dx) -
                        header.dimensions.rectPadding * 2
                    );
                });

            groups.
                select('text.dataTable-header-nodeText').
                attr('x', function(d) {
                    return header.scales.xScale(d.dx) / 2;
                });

            groups.select('text.dataTable-header-nodeText').each(function(d) {
                var thisText = d3.select(this);

                thisText.text(function(d) {
                    return d.displayName;
                });

                var maxTextWidth =
                    header.scales.xScale(d.dx) -
                    header.dimensions.rectPadding * 2 -
                    4;

                if (
                    thisText[0][0].offsetWidth > maxTextWidth &&
                    thisText.text().length > 0
                ) {
                    thisText.text(thisText.text() + '...');

                    while (
                        thisText[0][0].offsetWidth > maxTextWidth &&
                        thisText.text().length > 0
                    ) {
                        if (thisText.text().length > 3) {
                            thisText.text(
                                thisText.
                                    text().
                                    substr(0, thisText.text().length - 4) +
                                    '...'
                            );
                        } else {
                            thisText.text(
                                thisText.
                                    text().
                                    substr(0, thisText.text().length - 1)
                            );
                        }
                    }
                }
            });
        };

        SVGHeader.prototype.updateParameters = function() {
            var newParams,
                header = this;

            this.SVGs.parameters = this.SVGs.parametersGroup.
                selectAll('g.dataTable-header-dataParam').
                data(
                    this.getDataHandler().getSVGHeaderData().paramData,
                    function(d) {
                        return d.ID;
                    }
                );

            this.SVGs.parameters.exit().remove();

            this.SVGs.parameters.each(function(d) {
                SVGHeader.prototype.updateParameter.call(this, d, header);
            });

            newParams = this.SVGs.parameters.
                enter().
                append('g').
                classed('dataTable-header-dataParam', true).
                attr('transform', function(d) {
                    return (
                        'translate(' +
                        header.scales.xScale(d.x) +
                        ',' +
                        header.dimensions.collapsedTotalHeight +
                        ')'
                    );
                });

            // if there are no params
            if (
                newParams.data()[0] &&
                newParams.data().length === 1 &&
                newParams.data()[0].ID === proxy.varGroup.ID
            ) {
                return;
            }

            newParams.each(function(d) {
                SVGHeader.prototype.createParameter.call(this, d, header);
            });
        };

        SVGHeader.prototype.createParameter = function(d, header) {
            // Appends a rect element to create the branch for the parameter in
            // the svg hierarchy tree

            var thisGroup = d3.select(this); //,
            // rectHeight = header.dimensions.paramRowHeight;

            var thisRect = thisGroup.append('svg:rect');
            var thisRectElem = thisRect.node();
            thisRectElem.setAttribute('x', header.dimensions.dragWidth / 2);
            thisRectElem.setAttribute('y', 4);
            thisRectElem.setAttribute(
                'width',
                header.scales.xScale(d.dx) - header.dimensions.dragWidth
            );
            thisRectElem.setAttribute(
                'height',
                header.dimensions.textRectHeight
            );
            try {
                thisRectElem.classList.add('dataTable-header-parameterSVG');
            } catch (e) {
                thisRectElem.setAttribute(
                    'class',
                    'dataTable-header-parameterSVG'
                );
            }

            var drag = d3.behavior.drag();

            var dragStarted = false; // Tracks if we've started dragging so as
            // to distinguish between the drag and the
            // click

            var position = [0, 0],
                distance = 0;

            drag.on('dragstart', function() {
                if (d3.event.sourceEvent.which !== 1) {
                    return;
                }
                position = d3.mouse(header.SVGs.SVG[0][0]);

                dragStarted = false;
                console.log('dragstart triggered!');
            });

            drag.on('drag', function() {
                if (d3.event.sourceEvent.which !== 1) {
                    return;
                }
                if (dragStarted === true) {
                    header.moveDrag(thisGroup);
                } else {
                    var newPosition = d3.mouse(header.SVGs.SVG[0][0]);
                    var distance =
                        Math.abs(newPosition[0] - position[0]) +
                        Math.abs(newPosition[1] - position[1]);

                    if (distance > 10) {
                        dragStarted = true;
                        console.log('starting drag...');

                        header.startDrag(thisGroup);
                    }
                }
            });

            drag.on('dragend', function(d) {
                if (d3.event.sourceEvent.which !== 1) {
                    return;
                }
                if (dragStarted === true) {
                    console.log('end drag!');
                    header.endDrag(thisGroup);
                } else {
                    console.log('trigger click!');
                    header.parent.parent.eventController('sortByParam', d.ID);
                }
            });

            thisRect.call(drag);
        };

        SVGHeader.prototype.updateParameter = function(d, header) {
            var parameter = d3.select(this);

            var rectHeight = header.dimensions.paramRowHeight;

            parameter.attr('transform', function(d) {
                return (
                    'translate(' +
                    header.scales.xScale(d.x) +
                    ',' +
                    header.dimensions.currentTotalHeight +
                    ')'
                );
            });

            parameter.
                select('rect').
                attr('width', function(d) {
                    return (
                        header.scales.xScale(d.dx) - header.dimensions.dragWidth
                    );
                }).
                attr('height', rectHeight);
        };

        SVGHeader.prototype.updateDragRects = function() {
            /*jshint validthis: true */

            var dragRectData = [],
                i,
                param,
                header = this;

            var paramData = this.getDataHandler().getSVGHeaderData().paramData;

            paramData.sort(function(a, b) {
                return a.x - b.x;
            });

            var lastParam = paramData[0];

            dragRectData.push({
                x: 0,
                dx: 0,
                lastParam: null,
                nextParam: paramData[0]
            });

            for (i = 1; i < paramData.length; i++) {
                // Create a drag rect for each param but the last.
                // Drag rects should go just after the parameter they map to

                param = paramData[i];

                dragRectData.push({
                    x: param.x,
                    dx: lastParam.dx,
                    lastParam: lastParam,
                    nextParam: param
                });

                lastParam = paramData[i];
            }

            dragRectData.push({
                x: lastParam.x + lastParam.dx,
                dx: 0,
                lastParam: lastParam,
                nextParam: null
            });

            header.SVGs.dragRects = header.SVGs.dragRectsGroup.
                selectAll('rect.dataTable-header-dragRect').
                data(dragRectData);

            header.SVGs.dragRects.
                enter().
                append('rect').
                //          .classed('dataTable-header-dragRect', true)
                each(function(d) {
                    try {
                        this.classList.add('dataTable-header-dragRect');
                    } catch (e) {
                        this.setAttribute('class', 'dataTable-header-dragRect');
                    }
                    header.createDragRect(this, d);
                });

            header.SVGs.dragRects.each(function(d) {
                header.updateDragRect(this, d);
            });
        };

        SVGHeader.prototype.createDragRect = function(thisRect) {
            /*             drag width / 2
             *                <-----|
             * _____________   __________   ______
             *              | |          | |
             *              | |drag rect | |
             *  last param  | |          | |
             *              | |drag width| |
             *              | |<-------->| |
             *______________| |__________| |______
             */

            /*jshint validthis: true */

            function dragStart(d) {
                console.log('drag start on dragrect!');

                startMouse = d3.mouse(that.SVGs.SVG[0][0])[0];
                startWidth = Number(
                    that.getDataHandler().data.columns[d.lastParam.ID].
                        offsetPosition.activeWidth
                );

                mouseChange = 0;
                totalMouseChange = 0;
                positionChange = 0;
                position = 0;
                startPosition = 0;
                rectStart = -d.dx;
            }

            function dragMove(d) {
                console.log('dragging');

                mouseChange =
                    d3.mouse(that.SVGs.SVG[0][0])[0] -
                    startMouse -
                    totalMouseChange;
                totalMouseChange =
                    d3.mouse(that.SVGs.SVG[0][0])[0] - startMouse;

                var newPosition = Math.max(
                    startPosition + that.scales.xScale.invert(totalMouseChange),
                    rectStart + minSize
                );

                positionChange = newPosition - position;
                position = newPosition;

                thisRect.setAttribute(
                    'x',
                    that.scales.xScale(position) - that.dimensions.dragWidth / 2
                );
                //              .attr('x', that.scales.xScale(position) -
                //              that.dimensions.dragWidth / 2);

                console.log(that.scales.xScale(position));
                console.log(that.scales.xScale(positionChange) + startWidth);

                that.parent.parent.eventController('resizeColumn', {
                    ID: d.lastParam.ID,
                    width: that.scales.xScale(newPosition) + startWidth
                });
            }

            function dragEnd() {
                console.log('drag end on dragrect!');

                that.parent.parent.eventController('resizeEnd');
            }

            var that = this;

            var mouseChange,
                totalMouseChange,
                positionChange,
                position,
                startPosition,
                startMouse,
                rectStart,
                startWidth;

            var minSize = that.scales.xScale.invert(22);

            thisRect.setAttribute('y', 3);
            thisRect.setAttribute('width', that.dimensions.dragWidth);
            thisRect.setAttribute('height', that.dimensions.paramRowHeight);
            //      var thisDragRect = d3.select(thisRect);
            //
            //      thisDragRect
            //          .attr('y', 3)
            //          .attr('width', that.dimensions.dragWidth)
            //          .attr('height', that.dimensions.paramRowHeight);

            var drag = d3.behavior.drag();

            drag.on('dragstart', function(d) {
                dragStart(d);
            });

            drag.on('drag', function(d) {
                dragMove(d);
            });

            drag.on('dragend', function() {
                dragEnd();
            });

            d3.select(thisRect).call(drag);
        };

        SVGHeader.prototype.updateDragRect = function(thisRect) {
            // This updates rect position
            // All internal variables in the drag functions are held in closure
            // and updated on dragStart. (so don't worry about them here)

            var thisDragRect = d3.select(thisRect);

            var that = this;

            thisDragRect.
                attr('x', 0 - that.dimensions.dragWidth / 2).
                attr('transform', function(d) {
                    return (
                        'translate(' +
                        that.scales.xScale(d.x) +
                        ',' +
                        that.dimensions.currentTotalHeight +
                        ')'
                    );
                });
        };

        SVGHeader.prototype.toggleExpansion = function() {
            console.log('placeholder for toggle');
        };

        SVGHeader.prototype.getDataHandler = function() {
            return this.controlObjects.header.getDataHandler();
        };

        SVGHeader.prototype.toggleExpansion = function() {
            if (this.state.toggleState) {
                // Collapse all nodes
                this.state.toggleState = 0;
                this.collapse();
            } else {
                // Expand all nodes
                this.state.toggleState = 1;
                this.expand();
            }
        };

        SVGHeader.prototype.updateSVGHeader = function() {
            var header = this,
                dataDepth = header.getDataHandler().svgHeaderData.dataDepth - 1;

            header.state.dataDepth = dataDepth;
            header.state.totalDataDepth = header.getDataHandler().svgHeaderData.dataDepth;

            header.dimensions.collapsedTotalHeight =
                dataDepth * header.dimensions.collapsedGroupHeight;
            header.dimensions.expandedTotalHeight =
                dataDepth * header.dimensions.expandedGroupHeight;
            header.dimensions.currentTotalHeight = header.state.toggleState
                ? header.dimensions.expandedTotalHeight
                : header.dimensions.collapsedTotalHeight;

            header.scales.xScale.
                range([0, header.parent.dimensions.mainHeader.totalWidth]).
                domain([0, 1]);

            header.scales.yScale.
                range([0, header.dimensions.currentTotalHeight]).
                domain([
                    1 / (this.state.totalDataDepth + 1),
                    this.state.totalDataDepth / (this.state.totalDataDepth + 1)
                ]);

            header.SVGs.SVG.
                attr('width', header.parent.dimensions.mainHeader.totalWidth).
                attr(
                    'height',
                    header.dimensions.currentTotalHeight +
                        header.dimensions.paramRowHeight +
                        4
                );

            // header.parent.dimensions.headerHeight =
            // header.dimensions.currentTotalHeight;

            // To animate

            d3.
                select(header.containerDivs.container).
                style('height', header.dimensions.currentTotalHeight + 'px');

            this.updateGroups();
            this.updateParameters();
            this.updateDragRects();
        };

        SVGHeader.prototype.expand = function() {
            function expandPage() {
                header.scales.yScale.range([
                    0,
                    header.dimensions.expandedTotalHeight
                ]);

                header.dimensions.svgHeight =
                    header.dimensions.expandedTotalHeight +
                    header.dimensions.paramSectionHeight;

                header.SVGs.SVG.
                    transition().
                    attr('height', header.dimensions.svgHeight);

                d3.
                    select(header.containerDivs.container).
                    transition().
                    style(
                        'height',
                        header.dimensions.expandedTotalHeight + 'px'
                    );

                // We also need to update the total height of the header. This
                // is information we want before expanding, so we can sync size
                // changes in the body of the table. We can get this by
                // subtracting the collapsed total height from the height of the
                // header and adding the expanded total height.

                header.parent.dimensions.headerHeight +=
                    header.dimensions.expandedTotalHeight -
                    header.dimensions.collapsedTotalHeight;
            }

            function expandGroup() {
                /*jshint validthis: true */
                // Expand backing shapes to fit text, then show text

                d3.
                    select(this).
                    classed('dataTable-header-collapsedGroup', false);

                var transition1 = d3.select(this).transition();

                transition1.attr('transform', function(d) {
                    return (
                        'translate(' +
                        header.scales.xScale(d.x) +
                        ',' +
                        header.scales.yScale(d.y) +
                        ')'
                    );
                });

                transition1.
                    selectAll('.dataTable-header-nodeTextRect').
                    attr('height', function(d) {
                        return (
                            (header.state.dataDepth - (d.depth - 1)) *
                            header.dimensions.textRectHeight
                        );
                    });

                transition1.
                    selectAll('.dataTable-header-nodeText').
                    style('opacity', 1);
            }

            function expandParameter() {
                /*jshint validthis: true */
                // Also used for drag rects, since they're at the same height.
                var thisParameter = d3.select(this);

                thisParameter.attr('transform', function(d) {
                    return (
                        'translate(' +
                        header.scales.xScale(d.x) +
                        ',' +
                        header.dimensions.expandedTotalHeight +
                        ')'
                    );
                });
            }

            //--------------------------------
            // Script Block
            //--------------------------------

            var header = this;

            header.dimensions.currentGroupHeight =
                header.dimensions.expandedGroupHeight;

            expandPage();

            header.SVGs.groups.each(expandGroup);
            header.SVGs.parameters.each(expandParameter);
            header.SVGs.dragRects.each(expandParameter);
        };

        SVGHeader.prototype.collapse = function() {
            function collapsePage() {
                header.scales.yScale.range([
                    0,
                    header.dimensions.collapsedTotalHeight
                ]);

                header.dimensions.svgHeight =
                    header.dimensions.collapsedTotalHeight +
                    header.dimensions.paramRowHeight +
                    4;

                header.SVGs.SVG.
                    transition().
                    attr('height', header.dimensions.svgHeight);

                d3.
                    select(header.containerDivs.container).
                    transition().
                    style(
                        'height',
                        header.dimensions.collapsedTotalHeight + 'px'
                    );

                // Change dimension of parent
                header.parent.dimensions.headerHeight +=
                    -header.dimensions.expandedTotalHeight +
                    header.dimensions.collapsedTotalHeight;
            }

            function collapseGroup() {
                /*jshint validthis: true */

                var transition1 = d3.select(this).transition();

                transition1.attr('transform', function(d) {
                    return (
                        'translate(' +
                        header.scales.xScale(d.x) +
                        ',' +
                        header.scales.yScale(d.y) +
                        ')'
                    );
                });

                transition1.
                    selectAll('.dataTable-header-nodeTextRect').
                    attr('height', 0);

                transition1.
                    selectAll('.dataTable-header-nodeText').
                    style('opacity', 0);

                transition1.each('end', function() {
                    d3.
                        select(this).
                        classed('dataTable-header-collapsedGroup', true);
                });
            }

            function collapseParameter() {
                /*jshint validthis: true */
                // Also used for drag rects, since they're at the same height.
                var thisParameter = d3.select(this);

                thisParameter.attr('transform', function(d) {
                    return (
                        'translate(' +
                        header.scales.xScale(d.x) +
                        ',' +
                        header.dimensions.collapsedTotalHeight +
                        ')'
                    );
                });
            }

            //--------------------------------
            // Script Block
            //--------------------------------

            var header = this;

            header.dimensions.currentGroupHeight =
                header.dimensions.collapsedGroupHeight;

            collapsePage();

            header.SVGs.groups.each(collapseGroup);
            header.SVGs.parameters.each(collapseParameter);
            header.SVGs.dragRects.each(collapseParameter);
        };

        //////Drags

        SVGHeader.prototype.startDrag = function(dragParam) {
            /*jshint validthis: true */

            var header = this;

            var dragParamData = dragParam.data()[0];

            dragParam.classed('dataTable-header-activeParam', true);

            this.SVGs.ghostRect = this.SVGs.SVG.
                append('rect').
                attr('x', d3.mouse(this.SVGs.SVG[0][0])[0] - 15).
                attr('y', this.dimensions.currentTotalHeight + 2).
                attr('height', 10).
                attr('width', 30).
                classed('dataTable-header-ghostParam', true);

            this.state.dragState.paramData = this.getDataHandler().getSVGHeaderData().paramData;

            var startIndex;
            var i = 0;

            // Compute mid points of rects. Also get index of current selection.
            this.state.dragState.midpoints = this.state.dragState.paramData.map(
                function(d) {
                    if (d.ID === dragParamData.ID) {
                        startIndex = i;
                    }
                    i++;

                    return header.scales.xScale(d.x + d.dx / 2);
                }
            );

            this.state.dragState.paramData.sort(function(a, b) {
                return a.x - b.x;
            });

            this.state.dragState.lowerThresh =
                startIndex > 0
                    ? this.state.dragState.midpoints[startIndex - 1]
                    : -Infinity;
            this.state.dragState.upperThresh =
                startIndex < this.state.dragState.midpoints.length - 1
                    ? this.state.dragState.midpoints[startIndex + 1]
                    : Infinity;

            this.state.dragState.dragIndex = startIndex;

            this.state.dragState.dragStarted = true;

            this.state.currentParam = this.state.dragState.paramData[
                this.state.dragState.dragIndex
            ];
        };

        SVGHeader.prototype.moveDrag = function() {
            // Move ghost rect
            this.SVGs.ghostRect.
                attr('x', d3.mouse(this.SVGs.SVG[0][0])[0] - 15).
                attr('y', this.dimensions.currentTotalHeight + 2);

            // TODO: update highlight drag rects
            var thisParam, targetDivider;

            if (
                d3.mouse(this.SVGs.SVG[0][0])[0] <
                this.state.dragState.lowerThresh
            ) {
                this.state.dragState.dragIndex--;

                this.state.dragState.lowerThresh =
                    this.state.dragState.dragIndex > 0
                        ? this.state.dragState.midpoints[
                              this.state.dragState.dragIndex - 1
                          ]
                        : -Infinity;
                this.state.dragState.upperThresh = this.state.dragState.midpoints[
                    this.state.dragState.dragIndex + 1
                ];

                // Change selection
                thisParam = this.state.dragState.paramData[
                    this.state.dragState.dragIndex
                ];
                targetDivider = this.SVGs.dragRects.filter(function(d) {
                    return d.nextParam && d.nextParam.ID === thisParam.ID
                        ? 1
                        : 0;
                });

                d3.
                    selectAll('.highlightDragRect').
                    classed('highlightDragRect', false);
                targetDivider.classed('highlightDragRect', true);

                this.state.currentParam = thisParam;
            } else if (
                d3.mouse(this.SVGs.SVG[0][0])[0] >
                this.state.dragState.upperThresh
            ) {
                this.state.dragState.dragIndex++;

                this.state.dragState.lowerThresh = this.state.dragState.midpoints[
                    this.state.dragState.dragIndex - 1
                ];
                this.state.dragState.upperThresh =
                    this.state.dragState.dragIndex <
                    this.state.dragState.midpoints.length - 1
                        ? this.state.dragState.midpoints[
                              this.state.dragState.dragIndex + 1
                          ]
                        : Infinity;

                // Change selection
                thisParam = this.state.dragState.paramData[
                    this.state.dragState.dragIndex
                ];
                targetDivider = this.SVGs.dragRects.filter(function(d) {
                    return d.lastParam && d.lastParam.ID === thisParam.ID
                        ? 1
                        : 0;
                });

                d3.
                    selectAll('.highlightDragRect').
                    classed('highlightDragRect', false);
                targetDivider.classed('highlightDragRect', true);

                this.state.currentParam = thisParam;
            }
        };

        SVGHeader.prototype.endDrag = function(dragParam) {
            /*jshint validthis: true */
            d3.
                selectAll('.highlightDragRect').
                classed('highlightDragRect', false);
            dragParam.classed('dataTable-header-activeParam', false);

            this.SVGs.ghostRect.remove();

            var dragParamData = dragParam.data()[0];

            // use this.state.currentDragTarget to determine move

            // update state in data handler
            if (dragParamData.order !== this.state.currentParam.order) {
                // this.getDataHandler().moveNode(dragParamData,
                // this.state.currentParam.order);
                this.parent.parent.eventController('updateColumnOrder', {
                    dragParamData: dragParamData,
                    targetOrder: this.state.currentParam.order
                });
            }

            // Reset variables
            this.state.currentDragTarget = null;
            this.state.dragStarted = false;
            this.state.dragState = {};

            // Fire update event to sync everything to new data structure
        };

        return SVGHeader;
    }
);

/* global d3 */
/* global define */
/* global alert */

define(
    'DS/SMAAnalyticsDataTable/SMAAnalyticsBodyForServant',
    [
        'DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils',
        'DS/SMAAnalyticsUtils/SMAAnalyticsParseUtils'
    ],
    function(NLSUtils, ParseUtils) {
        'use strict';

        function BodyForServant(table) {
            // set some attributes on this
            this.parent = table;
            this.dimensions = {
                fixedWidth:
                    table.controlObjects.header.dimensions.fixedHeader.width
            };
            this.containerDivs = { root: this.parent.containerDivs.body };
            this.svgs = {};
            this.vertScroll = 0;
            this.selections = {
                cells: [],
                rows: [],
                columns: [],
                currentCell: { rowID: null, columnID: null }
            };
            this.copyParser = {};

            // The zero index can exist, so initialize these to -1 so we can
            // update later.
            this.rowIndices = { startIndex: -1, endIndex: -1 };

            this.columnIndices = { startIndex: -1, endIndex: -1 };

            this.data = {
                metaData: {},
                fixedData: { rows: {}, columns: {}, derivedColumns: {} },
                mainData: { rows: {}, columns: {}, derivedColumns: {} },
                rowMetaData: {},
                columnDimensions: {},
                copyData: []
            };

            // styling
            d3.select(this.containerDivs.root).style({
                top: table.controlObjects.header.dimensions.headerHeight + 'px'
            });

            this.dataHandler = this.parent.dataHandler;

            this.callData = {
                currentCall: false,
                currentCallback: false,
                numCalls: 0,
                callback: function() {}
            };

            // Initialize table
            this.initializeMainBody();
            this.initializeFixedBody();
            this.createEventHandlers();
            this.createCopyHandler();

            this.initializeData();

            this.setMainBodyScroll();

            // Additional variables
            this.keyStates = {};

            this.currentHighlightedColumns = {};
            this.currentHighlightedRows = {};

            this.currentSelectedCells = [];

            this.mainRows = [];
            this.fixedRows = [];

            this.rowUpdateDeferred = false;
            this.columnUpdateDeferred = false;
            this.scrollDisabled = false;
        }

        BodyForServant.prototype.getFormattedText = function(d) {
            /* global formatExp */
            // TODO: If there are other non-number types, we need to handle
            // them!
            if (typeof this.data.mainData.columns[d.column] === 'undefined') {
                return d;
            }

            if (this.data.mainData.columns[d.column].type === 'STRING') {
                return this.data.mainData.rows[d.row][d.column];
            } else {
                return formatExp(this.data.mainData.rows[d.row][d.column]);
            }
        };

        /////////////////////////
        // Main Update Methods //
        /////////////////////////

        BodyForServant.prototype.initializeData = function() {
            // Performs all operations necessary to set up the data for the
            // first time.  Also sets up the table!

            var that = this;

            // Calculating row indices will update indices on the data handler
            var rowIndices = this.calculateRowIndices();
            var columnIndices = this.calculateColumnIndices();

            this.columnIndices.startIndex = columnIndices[0];
            this.columnIndices.endIndex = columnIndices[1];
            this.rowIndices.startIndex = rowIndices[0];
            this.rowIndices.endIndex = rowIndices[1];

            // Get all fixed columns
            this.data.fixedData.derivedColumns = this.dataHandler.getDerivedFixedColumns();
            this.data.mainData.derivedColumns = this.dataHandler.getFixedColumns();

            // With indices updated, get ALL of the data.
            this.dataHandler.
                getAllData().
                then(function(pdata, pstatus, pjqXHR) {
                    var newData = ParseUtils.getJSONFromResponse([
                        pdata,
                        pstatus,
                        pjqXHR
                    ]);
                    var key;

                    that.data.metaData = newData.metaData;

                    for (key in newData.rowData) {
                        // if(key >= that.rowIndices.startIndex && key <=
                        // that.rowIndices.endIndex){
                        that.data.mainData.rows[key] =
                            newData.rowData[key].mainData;
                        that.data.fixedData.rows[key] =
                            newData.rowData[key].fixedData;
                        that.data.rowMetaData[key] =
                            newData.rowData[key].metaData;
                        that.data.rowMetaData[key].dimensions = {
                            height:
                                that.dataHandler.dimensions.row.defaultHeight,
                            y:
                                that.dataHandler.dimensions.row.defaultHeight *
                                newData.rowIndexMap[key]
                        };
                        that.data.rowMetaData[key].index =
                            newData.rowIndexMap[key];
                        //}
                    }

                    for (key in newData.columnData.fixedData) {
                        that.data.fixedData.columns[key] =
                            newData.columnData.fixedData[key];
                        that.data.fixedData.columns[
                            key
                        ].displayName = NLSUtils.translate(
                            that.data.fixedData.columns[key].displayName
                        );
                    }

                    for (key in newData.columnData.mainData) {
                        that.data.mainData.columns[key] =
                            newData.columnData.mainData[key];
                    }

                    // Call enter behavior
                    that.addRows();
                    // that.addFixedDerivedColumns(Object.keys(newData.rowData));
                    // that.addDerivedColumns();

                    that.dataHandler.updateMetadata(newData.metaData);

                    that.updateBodySize();
                });
        };

        BodyForServant.prototype.updateRows = function() {
            // This method gets data for all rows that are in bounds but have
            // not been rendered and then calls the  appropriate rendering
            // function.

            // callData.numCalls tracks how many data calls have been made. Only
            // one is allowed at a given time.
            this.callData.numCalls += 1;

            var that = this;

            var indices = this.calculateRowIndices(), // Obtains row indices as
                // an array [start, end]
                startIndex = indices[0],
                endIndex = indices[1];

            var key;

            var newIndices = [],
                nextIndex;

            // Update row indices in table.
            if (startIndex < this.rowIndices.startIndex) {
                // Table is scrolled up

                // We either want to start with the row before the current
                // start, or on the end index.  Since our while loop decrements
                // before checking, add one to end index.
                nextIndex = Math.min(this.rowIndices.startIndex, endIndex + 1);
                while (--nextIndex >= startIndex) {
                    newIndices.push(nextIndex);
                }

                // Remove unneeded rows
                for (key in this.data.fixedData.rows) {
                    if (this.data.rowMetaData[key].index > endIndex) {
                        delete this.data.fixedData.rows[key];
                        delete this.data.mainData.rows[key];
                        delete this.data.rowMetaData[key];
                    }
                }
            } else if (endIndex > this.rowIndices.endIndex) {
                // Table is scrolled down

                // Start either on startIndex or after this.rowIndices.endIndex.
                // Since while loop increments, we must subtract 1 from
                // startIndex before starting loop.
                nextIndex = Math.max(this.rowIndices.endIndex, startIndex - 1);
                while (++nextIndex <= endIndex) {
                    newIndices.push(nextIndex);
                }

                for (key in this.data.fixedData.rows) {
                    if (this.data.rowMetaData[key].index < startIndex) {
                        delete this.data.fixedData.rows[key];
                        delete this.data.mainData.rows[key];
                        delete this.data.rowMetaData[key];
                    }
                }
            }

            this.rowIndices.startIndex = startIndex;
            this.rowIndices.endIndex = endIndex;

            // Remove the DOM for rows we've removed the
            this.removeEmptyRows();

            if (newIndices.length > 0) {
                // Get all of the data and then render everything. Returns a
                // deferred object.
                var deferred = this.addRowData(newIndices).then(function() {
                    that.addRows();

                    that.callData.numCalls -= 1;
                });

                return deferred;
            } else {
                this.callData.numCalls -= 1;
            }

            return false;
        };

        BodyForServant.prototype.updateColumns = function() {
            // Similar to updateRows, but for columns.
            // Note that this assumes that the number of columns remains the
            // same. It should not be used for general column update.

            this.callData.numCalls += 1;
            var that = this;

            // Get the indices
            var indices = this.calculateColumnIndices(),
                startIndex = indices[0],
                endIndex = indices[1];

            var newColumnIndices = [],
                columnIDs = [];
            var nextIndex;
            var newDataDeferred;
            var startIndex, endIndex;

            var key;

            var newIndices = [],
                nextIndex;

            var rowKey, colKey, thisRow, i;

            var colKeys = [];

            // Based on new indices, calculate what data needs to be fetched,
            // and make a request for it
            if (startIndex < this.columnIndices.startIndex) {
                // Add data to beginning and add to the end
                nextIndex = Math.min(
                    this.columnIndices.startIndex,
                    endIndex + 1
                );
                while (--nextIndex >= startIndex) {
                    newIndices.push(nextIndex);
                }

                // Delete unused columns, but save an array of all column IDs
                for (key in this.data.mainData.columns) {
                    if (
                        this.data.mainData.columns[key].displayOrder > endIndex
                    ) {
                        colKeys.push(this.data.mainData.columns[key]);
                        delete this.data.mainData.columns[key];
                    }
                }
            } else if (endIndex > this.columnIndices.endIndex) {
                // Remove from beginning and add to end.

                // Add data to beginning and add to the end
                nextIndex = Math.max(
                    this.columnIndices.endIndex,
                    startIndex + 1
                );
                while (++nextIndex <= endIndex) {
                    newIndices.push(nextIndex);
                }

                // Delete unused columns, but save an array of all column IDs
                for (key in this.data.mainData.columns) {
                    if (
                        this.data.mainData.columns[key].displayOrder <
                        startIndex
                    ) {
                        colKeys.push(this.data.mainData.columns[key]);
                        delete this.data.mainData.columns[key];
                    }
                }
            }

            // Remove data from all rows for all deleted columns
            for (i = 0; i < colKeys.length; i++) {
                for (key in this.data.mainData.rows) {
                    delete this.data.mainData.rows[key][colKeys[i].id];
                }
            }

            this.columnIndices.startIndex = startIndex;
            this.columnIndices.endIndex = endIndex;

            this.removeEmptyColumns();

            if (newIndices.length > 0) {
                var deferred = this.addColumnData(newIndices).then(function() {
                    that.addColumns();

                    that.callData.numCalls -= 1;
                });

                return deferred;
            } else {
                this.callData.numCalls -= 1;
            }

            return false;
        };

        BodyForServant.prototype.refreshBody = function() {
            // Clears out all data and refreshes body.

            this.data = {
                metaData: { numRows: {}, numColumns: {} },
                fixedData: { rows: {}, columns: {}, derivedColumns: {} },
                mainData: { rows: {}, columns: {}, derivedColumns: {} },
                rowMetaData: {},
                columnDimensions: {},
                copyData: []
            };

            this.removeEmptyRows();

            this.rowIndices = { startIndex: -1, endIndex: -1 };

            this.initializeData();

            // Style change on main body
            d3.select(this.containerDivs.root).style({
                top:
                    this.parent.controlObjects.header.dimensions.headerHeight +
                    'px'
            });

            // Remove all content

            // Make request to data handler for new data

            // Once data is received, reduce index if necessary.

            // this.addMainRows(mainData);
            // this.addFixedRows(fixedData);

            this.updateFocus();
        };

        ///////////////////////////////////////
        // Data Processing Methods           //
        ///////////////////////////////////////

        BodyForServant.prototype.updateFromData = function(newData) {
            // This method updates the table based on a provided data object.

            var key;

            this.dataHandler.metaData = newData.metaData;

            this.data.mainData.rows = {};
            this.data.fixedData.rows = {};
            this.data.rowMetaData = {};

            this.removeEmptyRows();

            for (key in newData.rowData) {
                this.data.mainData.rows[key] = newData.rowData[key].mainData;
                this.data.fixedData.rows[key] = newData.rowData[key].fixedData;
                this.data.rowMetaData[key] = newData.rowData[key].metaData;
                this.data.rowMetaData[key].dimensions = {
                    height: this.dataHandler.dimensions.row.defaultHeight,
                    y:
                        this.dataHandler.dimensions.row.defaultHeight *
                        newData.rowIndexMap[key]
                };

                this.data.rowMetaData[key].index = newData.rowIndexMap[key];
            }

            // Call enter behavior
            this.addRows();
        };

        BodyForServant.prototype.addRowData = function(rowIndices) {
            // Makes a request for data at the specified indices and returns a
            // deferred object that other functions can be bound to.  Actual data
            // entry into the DOM elements is not handled by this function.

            var that = this;

            return this.dataHandler.
                getNewRows(rowIndices).
                then(function(pdata, pstatus, pjqXHR) {
                    if (typeof pdata === 'undefined') {
                        return;
                    }

                    var newData = ParseUtils.getJSONFromResponse([
                        pdata,
                        pstatus,
                        pjqXHR
                    ]);
                    var key;

                    for (key in newData.rowData) {
                        // if(key >= that.rowIndices.startIndex && key <=
                        // that.rowIndices.endIndex){
                        that.data.mainData.rows[key] =
                            newData.rowData[key].mainData;
                        that.data.fixedData.rows[key] =
                            newData.rowData[key].fixedData;
                        that.data.rowMetaData[key] =
                            newData.rowData[key].metaData;
                        that.data.rowMetaData[key].dimensions = {
                            height:
                                that.dataHandler.dimensions.row.defaultHeight,
                            y:
                                that.dataHandler.dimensions.row.defaultHeight *
                                newData.rowIndexMap[key]
                        };
                        that.data.rowMetaData[key].index =
                            newData.rowIndexMap[key];
                        //}
                    }
                });
        };

        BodyForServant.prototype.addColumnData = function(columnIndices) {
            // Makes a request for new column data and returns a deferred.
            // Makes necessary changes to the internal data structure based on
            // the data it recieves.

            var that = this;

            // First we need to map the column indices to param IDs
            var paramIDs = columnIndices.map(function(d) {
                return that.dataHandler.data.columnKeys[d];
            });

            return this.dataHandler.
                getNewColumns(paramIDs).
                then(function(pdata, pstatus, pjqXHR) {
                    if (typeof pdata === 'undefined') {
                        return;
                    }

                    var newData = ParseUtils.getJSONFromResponse([
                        pdata,
                        pstatus,
                        pjqXHR
                    ]);
                    var rowKey, colKey, thisRow;

                    for (colKey in newData.columnData.mainData) {
                        that.data.mainData.columns[colKey] =
                            newData.columnData.mainData[colKey];
                    }

                    for (rowKey in newData.rowData) {
                        thisRow = newData.rowData[rowKey];
                        for (colKey in thisRow.mainData) {
                            that.data.mainData.rows[rowKey][colKey] =
                                newData.rowData[rowKey].mainData[colKey];
                        }
                    }
                });
        };

        ///////////////////////////////////////
        // DOM Modification Methods          //
        ///////////////////////////////////////

        BodyForServant.prototype.addRows = function() {
            // Updates the UI to reflect new rows added to the data.
            // Does not make data requests!

            var that = this;

            // Update row data
            this.mainRows = d3.
                select(this.containerDivs.mainBodyContent).
                selectAll('.dataTable-body-rowDiv').
                data(Object.keys(this.data.mainData.rows), function(d) {
                    return d;
                });

            this.fixedRows = d3.
                select(this.containerDivs.fixedBodyContent).
                selectAll('.dataTable-body-rowDiv').
                data(Object.keys(this.data.fixedData.rows), function(d) {
                    return d;
                });

            var topPositionCallback = function(d) {
                return that.data.rowMetaData[d].dimensions.y + 'px';
            };

            var heightAssignmentCallback = function(d) {
                return that.data.rowMetaData[d].dimensions.height + 'px';
            };

            var classAssignmentCallback = function(d) {
                this.classList.add('bodyRow' + that.data.rowMetaData[d].id);
                this.classList.add('dataTable-body-rowDiv');
                this.classList.add(that.data.rowMetaData[d].grade);
                // d3.select(this).classed('bodyRow' +
                // that.data.rowMetaData[d].id + ' dataTable-body-rowDiv ' +
                // that.data.rowMetaData[d].grade, true);
            };

            var newMainRows = this.mainRows.
                enter().
                append('div').
                style('top', topPositionCallback).
                style('height', heightAssignmentCallback).
                each(classAssignmentCallback);

            var newFixedRows = this.fixedRows.
                enter().
                append('div').
                style('top', topPositionCallback).
                style('height', heightAssignmentCallback).
                each(classAssignmentCallback);

            this.addMainColumns(newMainRows);
            this.addFixedColumns(newFixedRows);
        };

        BodyForServant.prototype.addColumns = function() {
            // This adds data for new columns that has been added.
            // It is mostly just a wrapper for this.addMainColumns used for
            // internal consistency.

            this.addMainColumns(this.mainRows);
        };

        BodyForServant.prototype.removeEmptyColumns = function() {
            // This re-binds the data in the table and eliminates any cells in
            // columns that are no longer in the data.

            var that = this;

            this.mainRows = d3.
                select(this.containerDivs.mainBodyContent).
                selectAll('.dataTable-body-rowDiv').
                data(Object.keys(this.data.mainData.rows), function(d) {
                    return d;
                }).
                each(function(rowData) {
                    // TODO: For now, this only removes main columns.
                    // Should we do something similar for derived columns?

                    d3.
                        select(this).
                        selectAll('.mainCell').
                        data(
                            function(d) {
                                return Object.keys(
                                    that.data.mainData.rows[rowData]
                                ).map(function(columnID) {
                                    return {
                                        row: d,
                                        column: columnID
                                    };
                                });
                            },
                            function(d) {
                                return d.column;
                            }
                        ).
                        exit().
                        remove();
                });
        };

        BodyForServant.prototype.removeEmptyRows = function() {
            // This removes all empty rows.
            this.mainRows = d3.
                select(this.containerDivs.mainBodyContent).
                selectAll('.dataTable-body-rowDiv').
                data(Object.keys(this.data.mainData.rows), function(d) {
                    return d;
                }).
                exit().
                remove();

            this.fixedRows = d3.
                select(this.containerDivs.fixedBodyContent).
                selectAll('.dataTable-body-rowDiv').
                data(Object.keys(this.data.fixedData.rows), function(d) {
                    return d;
                }).
                exit().
                remove();
        };

        BodyForServant.prototype.addMainColumns = function(rows) {
            // this adds all cells in the main body to a selection of provided
            // rows. <rows> is provided as a d3 selector.

            var that = this;

            rows = rows || this.mainRows;

            /*var getFormattedText = function(d){
                / global formatExp /
                //TODO: If there are other non-number types, we need to handle
            them! if(typeof that.data.mainData.columns[d.column] ===
            'undefined'){ return d;
                }

                if(that.data.mainData.columns[d.column].type === 'STRING'){
                    return that.data.mainData.rows[d.row][d.column];
                } else {
                    return formatExp(that.data.mainData.rows[d.row][d.column]);
                }
            };*/

            var getFormattedText = function(d) {
                // This is wrapped to ensure the proper context for the
                // getFormattedText call.
                return that.getFormattedText(d);
            };

            var columns = rows.
                selectAll('.mainCell').
                data(
                    function(d) {
                        return Object.keys(
                            that.data.mainData.rows[d]
                        ).map(function(columnID) {
                            return { row: d, column: columnID };
                        });
                    },
                    function(d) {
                        return d.column;
                    }
                ).
                enter().
                append('span').
                classed('constraintViolationDataCell', function(d) {
                    if (
                        that.data.rowMetaData[d.row].violationFlag &&
                        that.data.rowMetaData[d.row].violationFlag[d.column]
                    ) {
                        return true;
                    } else {
                        return false;
                    }
                }).
                //.classed('dataTable-body-tableCell mainCell', true)
                text(getFormattedText).
                attr('contenteditable', false);

            var columnCallback = function(d) {
                this.classList.add('dataTable-body-tableCell');
                this.classList.add('mainCell');
                this.classList.add(that.data.rowMetaData[d.row].grade);
                this.classList.add('bodyColumn' + d.column);
                // d3.select(this).classed(that.data.rowMetaData[d.row].grade +
                // ' bodyColumn' + d.column, true);
            };

            // Position column by assigning it to a column class.
            columns.each(columnCallback);

            var derivedColumns = rows.
                selectAll('.derivedCell').
                data(
                    function(d) {
                        return Object.keys(
                            that.data.mainData.derivedColumns
                        ).map(function(columnID) {
                            return {
                                source: 'derived',
                                row: d,
                                column: columnID
                            };
                        });
                    },
                    function(d) {
                        return d.column;
                    }
                ).
                enter().
                append('span');
            //.classed('dataTable-body-tableCell derivedCell', true);

            var derivedColsCallback = function(d) {
                var content = that.getDerivedContent(d.row, d.column);

                this.innerHTML = '';
                this.appendChild(content);
                // d3.select(this).classed(that.data.rowMetaData[d.row].grade +
                // ' bodyColumn' + d.column, true);
                this.classList.add('dataTable-body-tableCell');
                this.classList.add('derivedCell');
                this.classList.add(that.data.rowMetaData[d.row].grade);
                this.classList.add('bodyColumn' + d.column);
            };
            derivedColumns.each(derivedColsCallback);
        };

        BodyForServant.prototype.addFixedColumns = function(rows) {
            // Similar to addMainColumns, but for fixed columns.

            var that = this;

            rows = rows || this.fixedRows;

            var mainColumns = rows.
                selectAll('.dataCell').
                data(
                    function(d) {
                        return Object.keys(
                            that.data.fixedData.rows[d]
                        ).map(function(columnID) {
                            return {
                                source: 'data',
                                row: d,
                                column: columnID
                            };
                        });
                    },
                    function(d) {
                        return d.column;
                    }
                ).
                enter().
                append('span').
                //.classed('dataTable-body-tableCell dataCell', true)
                text(function(d) {
                    return that.data.fixedData.rows[d.row][d.column];
                });

            var derivedColumns = rows.
                selectAll('.derivedCell').
                data(
                    function(d) {
                        return Object.keys(
                            that.data.fixedData.derivedColumns
                        ).map(function(columnID) {
                            return {
                                source: 'derived',
                                row: d,
                                column: columnID
                            };
                        });
                        // Add derived columns
                    },
                    function(d) {
                        return d.column;
                    }
                ).
                enter().
                append('span');
            //.classed('dataTable-body-tableCell derivedCell', true);

            var mainColCallback = function(d) {
                // console.log(this);
                // d3.select(this).classed(that.data.rowMetaData[d.row].grade +
                // ' bodyColumn' + d.column, true);
                this.classList.add('dataTable-body-tableCell');
                this.classList.add('dataCell');
                this.classList.add(that.data.rowMetaData[d.row].grade);
                this.classList.add('bodyColumn' + d.column);
            };

            // Position column by assigning it to a column class.
            mainColumns.each(mainColCallback);

            var derivedColsCallback = function(d) {
                var content = that.getFixedDerivedContent(d.row, d.column);

                this.innerHTML = '';
                this.classList.add('dataTable-body-tableCell');
                this.classList.add('derivedCell');
                this.classList.add(that.data.rowMetaData[d.row].grade);
                this.classList.add('bodyColumn' + d.column);
                this.appendChild(content);
            };
            derivedColumns.each(derivedColsCallback);
        };

        BodyForServant.prototype.updateDerivedCells = function() {
            // this updates the content of all fixed derived cells.

            var that = this;

            this.fixedRows.selectAll('.derivedCell').each(function(d) {
                var content = that.getFixedDerivedContent(d.row, d.column);

                this.innerHTML = '';
                this.appendChild(content);
            });
        };

        BodyForServant.prototype.getFixedDerivedContent = function(
            rowId,
            columnId
        ) {
            // This function returns the derived content for a single
            // fixed cell.

            // For now, these are always computed from metaData and
            // fixedData.
            // TODO: Find a good way of generalizing this.
            var row = {
                metaData: this.data.rowMetaData[rowId],
                fixedData: this.data.fixedData[rowId]
            };

            var column = this.dataHandler.data.fixedColumns[columnId],
                outputs = column.columnFn(row);

            return outputs.content;
        };

        BodyForServant.prototype.getDerivedContent = function(rowId, columnId) {
            // This returns the derived content for a single cell.

            var row = {
                metaData: this.data.rowMetaData[rowId],
                fixedData: this.data.fixedData.rows[rowId],
                mainData: this.data.mainData.rows[rowId]
            };

            var column = this.dataHandler.data.columns[columnId],
                outputs = column.columnFn(row);

            return outputs.content;
        };

        BodyForServant.prototype.updateBodySize = function() {
            // This function will update the size of the body

            // var that = this;

            // Update containers
            d3.select(this.containerDivs.mainBodyContainer).style({
                left: this.dimensions.fixedWidth + 'px'
            });

            d3.select(this.containerDivs.fixedBodyContainer).style({
                width: this.dimensions.fixedWidth + 'px'
            });

            // Update height
            var totalHeight = this.dataHandler.getTotalHeight();

            d3.select(this.containerDivs.fixedBodyContent).style({
                height: totalHeight + 'px',
                width: this.dimensions.fixedBodyContent.width + 'px'
            });

            // Update width
            var mainWidth = this.dataHandler.getMainWidth();

            this.dimensions.mainBodyContent = {
                height: totalHeight,
                width: mainWidth
            };

            d3.select(this.containerDivs.mainBodyContent).style({
                height: this.dimensions.mainBodyContent.height + 'px',
                width: this.dimensions.mainBodyContent.width + 'px'
            });
        };

        BodyForServant.prototype.animateToHeader = function(speed) {
            // This will animate the table to match any expand/collapse behavior
            // that has been triggered on the header.

            // var headerHeight = this.parent.dimensions.headerHeight;

            var header;

            if (speed === 'instant') {
                header = d3.select(this.containerDivs.root);
            } else {
                header = d3.select(this.containerDivs.root).transition();
            }

            header.style({
                top:
                    this.parent.controlObjects.header.dimensions.headerHeight +
                    'px'
            });
        };

        //////////////////////
        // Indexing Methods //
        //////////////////////

        BodyForServant.prototype.calculateColumnIndices = function() {
            // Calculates which column indices are in range and returns them as
            // an array. [startIndex, endIndex]

            var container = this.containerDivs.mainBodyContainer;

            var indices = this.dataHandler.updateColumnIndex(
                container.scrollLeft - 200,
                container.scrollLeft + container.clientWidth + 200
            );

            return indices;
            // this.columnIndices.startIndex = indices[0];
            // this.columnIndices.endIndex = indices[1];
        };

        BodyForServant.prototype.calculateRowIndices = function() {
            // Calculates which rpw indices are in range and returns them as an
            // array. [startIndex, endIndex]

            var container = this.containerDivs.mainBodyContainer;

            var indices = this.dataHandler.updateRowIndex(
                container.scrollTop - 200,
                container.scrollTop + container.clientHeight + 200
            );

            return indices;
            // this.rowIndices.startIndex = indices[0];
            // this.rowIndices.endIndex = indices[1];
        };

        //////////////////////////////////
        // DOM Initialization functions //
        //////////////////////////////////

        BodyForServant.prototype.initializeMainBody = function() {
            // Append a main body container and content
            this.containerDivs.mainBodyContainer = document.createElement(
                'div'
            );
            this.containerDivs.mainBodyContainer.className +=
                'dataTable-body-mainBodyContainer ';
            this.containerDivs.root.appendChild(
                this.containerDivs.mainBodyContainer
            );

            this.containerDivs.mainBodyContent = document.createElement('div');
            this.containerDivs.mainBodyContent.className +=
                'dataTable-body-mainBodyContent ';
            this.containerDivs.mainBodyContainer.appendChild(
                this.containerDivs.mainBodyContent
            );

            // this.controlObjects.mainBody = new MainBodyForServant(this);

            d3.select(this.containerDivs.mainBodyContainer).style({
                right: '0px',
                left: this.dimensions.fixedWidth + 'px',
                top: '0px',
                bottom: '0px'
            });

            this.dimensions.mainBodyContent = {
                height: this.dataHandler.getTotalHeight(),
                width: this.dataHandler.getMainWidth()
            };

            d3.select(this.containerDivs.mainBodyContent).style({
                position: 'absolute',
                height: this.dimensions.mainBodyContent.height + 'px',
                width: this.dimensions.mainBodyContent.width + 'px'
            });
        };

        /*BodyForServant.prototype.updateMainBody = function() {

            d3.select(this.containerDivs.mainBodyContainer).style({ left :
        this.dimensions.fixedWidth + 'px' });

            this.dimensions.mainBodyContent = { height :
        this.dataHandler.getTotalHeight(), width :
        this.dataHandler.getMainWidth() };

            d3.select(this.containerDivs.mainBodyContent).style({ height :
        this.dimensions.mainBodyContent.height + 'px', width :
        this.dimensions.mainBodyContent.width + 'px' });
        };*/

        BodyForServant.prototype.initializeFixedBody = function() {
            // Sets up the dom structure for the fixed portion of the table
            // body.

            this.containerDivs.fixedBodyContainer = document.createElement(
                'div'
            );
            this.containerDivs.fixedBodyContainer.className +=
                'dataTable-body-fixedBodyContainer ';
            this.containerDivs.root.appendChild(
                this.containerDivs.fixedBodyContainer
            );

            // this.controlObjects.fixedBody = new FixedBodyForServant(this);
            // Reinstate this if we decide to separate out the fixed body as its
            // own prototype

            this.containerDivs.fixedBodyContent = document.createElement('div');
            this.containerDivs.fixedBodyContent.className +=
                'dataTable-body-fixedBodyContent ';
            this.containerDivs.fixedBodyContainer.appendChild(
                this.containerDivs.fixedBodyContent
            );

            d3.select(this.containerDivs.fixedBodyContainer).style({
                width: this.dimensions.fixedWidth + 'px',
                top: '0px',
                left: '0px',
                bottom: '0px'
            });

            this.dimensions.fixedBodyContent = {
                height: this.dataHandler.getTotalHeight(),
                width: this.dimensions.fixedWidth
            };

            d3.select(this.containerDivs.fixedBodyContent).style({
                position: 'absolute',
                height: this.dimensions.fixedBodyContent.height + 'px',
                width: this.dimensions.fixedBodyContent.width + 'px'
            });
        };

        BodyForServant.prototype.updateFixedWidth = function() {
            var fixedWidth = this.parent.controlObjects.header.dimensions.
                fixedHeader.width;

            this.dimensions.fixedWidth = fixedWidth;
            this.dimensions.fixedBodyContent.width = fixedWidth;
        };

        /*BodyForServant.prototype.updateFixedBody = function(){

            d3.select(this.containerDivs.fixedBodyContainer)
                .style({
                    width : this.dimensions.fixedWidth + 'px'
                });

            this.dimensions.fixedBodyContent = {
                height : this.dataHandler.getTotalHeight(),
                width : this.dimensions.fixedWidth
            };

            d3.select(this.containerDivs.fixedBodyContent)
                .style({
                    height : this.dimensions.fixedBodyContent.height + 'px',
                    width : this.dimensions.fixedBodyContent.width + 'px'
                });
        };*/

        /*BodyForServant.prototype.getDataHandler = function(){
            return this.parent.dataHandler;
        };*/

        /*BodyForServant.prototype.updateTableIndices = function(){
            var container = this.containerDivs.mainBodyContainer;
        };*/

        //

        ///////////////////////
        // Scrolling Methods //
        ///////////////////////

        BodyForServant.prototype.scrollHorizontal = function() {
            // This is called when the user scrolls horizontally.

            var that = this;

            if (this.scrollDisabled === false) {
                this.disableScroll();
                this.columnUpdateDeferred = this.updateColumns();
            } else if (that.callData.currentCallback === false) {
                this.callData.currentCallback = true;
                if (this.columnUpdateDeferred) {
                    this.columnUpdateDeferred.then(function() {
                        that.enableHozScroll();
                    });
                } else {
                    that.enableHozScroll();
                }
            }
        };

        // Enable and disable scroll are used to stop the page from overloading
        // itself with too many calls.  This is done by not allowing the body to
        // request more data until the current request is finished.  Requests for
        // data are disabled until the current request is finished, at which
        // point another request will be  made if any scroll activity took place
        // while the scroll was disabled.
        BodyForServant.prototype.disableScroll = function() {
            this.scrollDisabled = true;
        };

        BodyForServant.prototype.enableHozScroll = function() {
            var that = this;

            this.columnUpdateDeferred = this.updateColumns();

            if (this.columnUpdateDeferred) {
                this.callData.currentCallback = false;
                this.columnUpdateDeferred.always(function() {
                    that.scrollDisabled = false;
                });
            } else {
                this.scrollDisabled = false;
                this.callData.currentCallback = false;
            }
        };

        BodyForServant.prototype.enableScroll = function() {
            var that = this;

            this.rowUpdateDeferred = this.updateRows();

            if (this.rowUpdateDeferred) {
                that.callData.currentCallback = false;
                this.rowUpdateDeferred.always(function() {
                    that.scrollDisabled = false;
                });
            } else {
                this.scrollDisabled = false;
                this.callData.currentCallback = false;
            }
        };

        BodyForServant.prototype.scrollVertical = function() {
            /*
            For a vertical scroll, we need to update the row data, then call
            updateRows
            */

            var that = this;

            if (this.scrollDisabled === false) {
                this.disableScroll();
                this.rowUpdateDeferred = this.updateRows();
            } else if (that.callData.currentCallback === false) {
                this.callData.currentCallback = true;
                if (this.rowUpdateDeferred) {
                    this.rowUpdateDeferred.then(function() {
                        that.enableScroll();
                    });
                } else {
                    that.enableScroll();
                }
            }
        };

        BodyForServant.prototype.setMainBodyScroll = function() {
            // configure the scrolling behavior for the main body

            var that = this;

            d3.
                select(this.containerDivs.mainBodyContainer).
                on('scroll', function() {
                    that.containerDivs.fixedBodyContainer.scrollTop =
                        that.containerDivs.mainBodyContainer.scrollTop;
                    that.parent.controlObjects.header.setMainHeaderScroll(
                        that.containerDivs.mainBodyContainer.scrollLeft
                    );

                    if (
                        that.containerDivs.fixedBodyContainer.scrollTop !==
                        this.vertScroll
                    ) {
                        that.scrollVertical();

                        this.vertScroll =
                            that.containerDivs.fixedBodyContainer.scrollTop;
                    } else {
                        that.scrollHorizontal();
                    }
                });
        };

        BodyForServant.prototype.singleCellSelect = function(
            rowID,
            columnID,
            cellData,
            cell
        ) {
            // Select behavior for the cell at row/column

            // Define cellSelected as a boolean
            var cellSelected =
                this.selections.currentCell.columnID === columnID &&
                this.selections.currentCell.rowID === rowID;

            if (
                cellSelected === false ||
                cellData.editable === true ||
                cellData.editable === 'true'
            ) {
                // Update selection
                this.selections.rows = [
                    {
                        id: rowID,
                        index: this.data.rowMetaData[rowID].index
                    }
                ];

                this.selections.columns = [columnID];

                this.selections.currentCell.columnID = columnID;
                this.selections.currentCell.rowID = rowID;
                this.selections.currentCell.data = cellData;
                this.selections.currentCell.cell = cell;
                this.selections.currentCell.rowIndex = this.data.rowMetaData[
                    rowID
                ].index;

                this.selections.cells = [
                    {
                        rowID: rowID,
                        columnID: columnID,
                        rowIndex: this.data.rowMetaData[rowID].index
                    }
                ];

                this.data.copyData = {};
                this.data.copyData[rowID] = {};
                this.data.copyData[rowID][columnID] = this.getCellValue(
                    rowID,
                    columnID
                );
            } else {
                // Deselect cell
                this.selections.rows = [];
                this.selections.columns = [];

                this.selections.currentCell.columnID = null;
                this.selections.currentCell.rowID = null;
                this.selections.currentCell.cell = null;
                this.selections.currentCell.data = null;

                this.selections.cells = [];

                this.data.copyData = {};
            }
        };

        /////////////////////////
        // User Input Handling //
        /////////////////////////

        BodyForServant.prototype.createEventHandlers = function() {
            // This sets up user input event handlers on the body.
            // Events handled are: click, contextmenu, keydown, keyup

            var that = this;

            d3.
                select(this.containerDivs.root).
                on('click', function() {
                    console.log(d3.event);
                    console.log(d3.event.which);

                    // Click controls selection.
                    var row,
                        col = d3.event.target;

                    var hasClass = function(element, testName) {
                        return (
                            (' ' + element.className + ' ').indexOf(
                                ' ' + testName + ' '
                            ) > -1
                        );
                    };

                    while (
                        hasClass(col, 'dataTable-body-tableCell') === false &&
                        col.parentElement !== null
                    ) {
                        col = col.parentElement;
                    }

                    var datum = d3.select(col).datum();

                    if (typeof datum !== 'undefined') {
                        that.cellClick(col, datum.row, datum.column, d3.event);
                    }
                }).
                on('mousedown', function() {
                    /*console.log('Mousedown!');
                        console.log(d3.event.which);*/
                    if (d3.event.which === 3) {
                        that.keyStates.context = true;
                    }
                }).
                on('mouseup', function() {
                    that.keyStates.context = false;
                }).
                on('contextmenu', function() {
                    // This is the right click context menu.

                    // Alt key to bypass context menu (for debugging)
                    if (d3.event.altKey) {
                        return true;
                    }

                    var target = d3.event.target;

                    while (
                        target !== null &&
                        !target.classList.contains('dataTable-body-tableCell')
                    ) {
                        target = target.parentElement;
                    }

                    if (target == null) {
                        return;
                    }

                    var row = target.parentElement,
                        col = target;

                    var rowData = d3.select(row).datum(),
                        colData = d3.select(col).datum();

                    if (
                        !that.selections.cells.some(function(d) {
                            return (
                                d.columnID === colData.column &&
                                Number(d.rowID) === Number(colData.row)
                            );
                        })
                    ) {
                        // Right clicked cell not selected, change selection
                        // to cell
                        that.selectCells(
                            colData.row,
                            colData.column,
                            colData,
                            d3.event.target,
                            {}
                        );
                    }

                    // Fire context menu event
                    that.fireBodyContext();

                    d3.event.preventDefault();
                }).
                on('keydown', function() {
                    // This sets things up for copy/pasting when the control
                    // key is pressed.

                    if (d3.event.ctrlKey) {
                        that.keyStates.ctrl = true;

                        // We need to do three things:
                        /* 1: Copy current selection to copy text area
                             * 2: Select all of copy text area
                             * 3: Transfer focus to copy text area
                             */

                        var dataHandler = that.dataHandler;

                        if (
                            that.selections.cells.length ===
                            that.selections.rows.length *
                                that.selections.columns.length
                        ) {
                            // Selection is rectangular - should be copyable

                            var rowsArray = [],
                                rowIndexes = {},
                                columnIndexes = {};

                            for (
                                var i = 0;
                                i < that.selections.rows.length;
                                i++
                            ) {
                                rowsArray.push([]);
                                rowIndexes[that.selections.rows[i].id] = i;
                            }

                            for (
                                i = 0;
                                i < that.selections.columns.length;
                                i++
                            ) {
                                columnIndexes[that.selections.columns[i]] = i;
                            }

                            for (i = 0; i < that.selections.cells.length; i++) {
                                rowsArray[
                                    rowIndexes[that.selections.cells[i].rowID]
                                ][
                                    columnIndexes[
                                        that.selections.cells[i].columnID
                                    ]
                                ] =
                                    that.data.copyData[
                                        that.selections.cells[i].rowID
                                    ][that.selections.cells[i].columnID];
                            }

                            that.containerDivs.copyTextArea.value = that.copyParser.SheetClip.stringify(
                                rowsArray
                            );
                        }

                        // Transfer focus to text area
                        that.containerDivs.copyTextArea.focus();
                        that.containerDivs.copyTextArea.select();
                    }

                    if (d3.event.shiftKey) {
                        that.keyStates.shift = true;
                    }
                }).
                on('keyup', function() {
                    // This sets focus back to the table on a keyup.
                    if (!d3.event.ctrlKey) {
                        delete that.keyStates.ctrl;
                    }

                    if (!d3.event.shiftKey) {
                        delete that.keyStates.shift;
                    }

                    if (d3.event.crtlKey) {
                        that.updateFocus();
                    }
                });
        };

        BodyForServant.prototype.cellClick = function(
            thisCell,
            rowID,
            columnID,
            event
        ) {
            // Handles behavior for cell click

            var cellData = {},
                colData,
                key;

            if (typeof this.data.mainData.columns[columnID] !== 'undefined') {
                colData = this.data.mainData.columns[columnID];
            } else if (
                typeof this.data.fixedData.columns[columnID] !== 'undefined'
            ) {
                colData = this.data.fixedData.columns[columnID];
            } else if (
                typeof this.data.mainData.derivedColumns[columnID] !==
                'undefined'
            ) {
                colData = this.data.mainData.derivedColumns[columnID];
            } else {
                // No selectable columns.
                colData = {};
                // throw 'column ID not found in data!';
            }

            for (key in colData) {
                if (colData.hasOwnProperty(key)) {
                    cellData[key] = colData[key];
                }
            }

            if (typeof this.data.mainData.columns[columnID] !== 'undefined') {
                cellData.editable = 'true';
            }

            this.selectCells(rowID, columnID, cellData, thisCell, event);
            this.updateSelectedCells(true);
        };

        BodyForServant.prototype.focusCell = function(cell) {
            // Handles behavior for focus event on cell.

            var that = this;

            var d3cell = d3.
                select(cell).
                attr('contenteditable', true).
                classed('inputCell', true);

            cell.focus();

            function moveVert(indices) {
                console.log('Pressed enter!');
                event.preventDefault();
                event.stopPropagation();
                cell.blur();

                var cellParent = cell.parentElement;
                var numColumns = cellParent.children.length;
                var i = 0;

                var cellData = d3cell.datum();

                var rowIndex = that.data.rowMetaData[cellData.row].index,
                    newColId;

                var newRow = that.mainRows.filter(function(d) {
                    return Number(d) === Number(cellData.row) + indices;
                });
                var newColumn = newRow.selectAll('span').filter(function(d) {
                    return d.column === cellData.column;
                });

                if (newColumn[0] && newColumn[0][0]) {
                    var newCell = newColumn[0][0];
                    var newCellData = newColumn.datum();

                    that.selectCells(
                        newCellData.row,
                        newCellData.column,
                        newCellData,
                        newCell,
                        {}
                    );
                    // that.focusCell(newCell);
                    that.updateSelectedCells(true);
                    that.focusCell(newCell);
                }
            }

            function moveHoz(indices) {
                event.preventDefault();
                event.stopPropagation();
                cell.blur();

                var cellParent = cell.parentElement;
                var numColumns = cellParent.children.length;
                var i = 0;

                var cellData = d3cell.datum();

                var colIds = Object.keys(that.data.mainData.columns),
                    colIndex =
                        that.data.mainData.columns[cellData.column].
                            displayOrder,
                    newColId;

                for (var key in that.data.mainData.columns) {
                    if (
                        that.data.mainData.columns[key].displayOrder ===
                        colIndex + indices
                    ) {
                        newColId = key;
                        break;
                    }
                }

                var columnData =
                    that.data.mainData.columns[d3.select(cell).datum().column];

                if (newColId) {
                    var newCell = Array.prototype.filter.call(
                        cellParent.children,
                        function(cell) {
                            return d3.select(cell).datum().column === newColId;
                        }
                    )[0];

                    var newCellData = d3.select(newCell).datum();

                    that.selectCells(
                        newCellData.row,
                        newCellData.column,
                        newCellData,
                        newCell,
                        {}
                    );
                    // that.focusCell(newCell);
                    that.updateSelectedCells(true);
                    that.focusCell(newCell);
                }
            }

            cell.onkeydown = function(event) {
                var keyCode = event.keyCode ? event.keyCode : event.which;

                if (Number(keyCode) === 9 && event.shiftKey) {
                    // Tab + shift
                    moveHoz(-1);
                } else if (Number(keyCode) === 9) {
                    // Tab key
                    moveHoz(1);
                } else if (Number(keyCode) === 38) {
                    // Up arrow
                    moveVert(-1);
                } else if (Number(keyCode) === 40) {
                    // Down arrow
                    moveVert(1);
                }
            };

            cell.onkeypress = function(event) {
                var keyCode = event.keyCode ? event.keyCode : event.which;

                if (Number(keyCode) === 13) {
                    // Enter key
                    moveVert(1);
                }
            };

            /*d3cell.on('keydown', function(){
                console.log('Pressed a key!');
                console.log(d3.event);
            });*/

            // Bind data saving function
            cell.onblur = function() {
                var compareNumber = function(a, b) {
                    /* global formatExp */
                    return formatExp(a) === formatExp(b);
                };

                // Deselect contents
                d3.
                    select(cell).
                    attr('contenteditable', false).
                    classed('inputCell', false);

                cell.onblur = '';

                // Save stuff

                var content = cell.textContent;

                var cellData = d3.select(cell).datum();

                var validationType = that.data.mainData.columns[
                    cellData.column
                ].type.toLowerCase();

                // We can no longer rely on having the data saved.
                // Instead, we have the data in the current selection object.

                if (
                    content ===
                    that.data.copyData[cellData.row][cellData.column]
                ) {
                    // Do we have a way to save empty data?
                    if (
                        !(
                            that.keyStates.shift ||
                            that.keyStates.ctrl ||
                            that.keyStates.context
                        )
                    ) {
                        that.deselectAllCells();
                    }
                    return;
                }

                if (
                    content !== '' &&
                    (validationType === 'real' ||
                        validationType === 'double(6)' ||
                        validationType === 'integer')
                ) {
                    content = Number(content);
                }

                // First we need to validate
                if (
                    content === '' ||
                    that.parent.externalInterface.execute('validateContents', [
                        {
                            validationType: validationType,
                            content: content
                        }
                    ])
                ) {
                    // console.log('data is valid');
                    d3.select(cell).classed('invalidDataCell', false);
                    // save data

                    // Format: {columnmID : {rowID : value}}
                    var changeObject = {};

                    var colId = cellData.column,
                        rowId = cellData.row;

                    changeObject[colId] = {};

                    changeObject[colId][rowId] = content;

                    var save = true;
                    var colType = that.data.mainData.columns[colId].type;

                    if (colType === 'REAL') {
                        if (
                            compareNumber(
                                content,
                                that.data.mainData.rows[rowId][colId]
                            )
                        ) {
                            save = false;
                        }
                    } else {
                        if (content === that.data.mainData.rows[rowId][colId]) {
                            save = false;
                        }
                    }

                    if (save) {
                        that.parent.eventController(
                            'saveChanges',
                            changeObject
                        );
                    }
                } else {
                    // console.log('data is NOT valid!!!');
                    d3.select(cell).classed('invalidDataCell', true);
                    //    highlight cell content, don't save data
                }

                if (!(that.keyStates.shift || that.keyStates.ctrl)) {
                    that.deselectAllCells();
                }
            };
        };

        BodyForServant.prototype.getCellValue = function(rowID, columnID) {
            // Gets the value of a single cell.

            if (
                typeof this.data.mainData.rows[rowID] !== 'undefined' &&
                typeof this.data.mainData.rows[rowID][columnID] !== 'undefined'
            ) {
                return this.data.mainData.rows[rowID][columnID];
            } else if (
                typeof this.data.fixedData.rows[rowID] !== 'undefined' &&
                typeof this.data.fixedData.rows[rowID][columnID] !== 'undefined'
            ) {
                return this.data.fixedData.rows[rowID][columnID];
            }

            return undefined;
        };

        BodyForServant.prototype.fireBodyContext = function() {
            // This sets up the context menu, since we need to define the items
            // in it before executing it.
            var selections = {
                cells: this.selections.cells,
                columns: this.selections.columns,
                currentCell: this.selections.currentCell
            };

            var that = this;

            selections.rows = this.selections.rows.map(function(d) {
                return {
                    mainData: that.data.mainData.rows[d.id],
                    fixedData: that.data.fixedData.rows[d.id],
                    metaData: that.data.rowMetaData[d.id]
                };
            });

            var cellCol = selections.currentCell.columnID;

            var cellName =
                (this.data.mainData.columns[cellCol] &&
                    this.data.mainData.columns[cellCol].displayName) ||
                (this.data.fixedData.columns[cellCol] &&
                    this.data.fixedData.columns[cellCol].displayName) ||
                (this.data.mainData.derivedColumns[cellCol] &&
                    this.data.mainData.derivedColumns[cellCol].displayName);

            this.parent.externalInterface.execute('contextMenu', [
                selections,
                cellName
            ]);
        };

        ///////////////////////
        // Selection Methods //
        ///////////////////////

        BodyForServant.prototype.updateSelectedCells = function(
            propagateEvent
        ) {
            // Updates which cells are selected based on what is in
            // this.selections

            // console.log(this.selections.cells);
            var cssEditor = this.parent.cssEditor;

            var newCellsList = this.selections.cells.
                map(function(d) {
                    return '.bodyRow' + d.rowID + ' .bodyColumn' + d.columnID;
                }).
                sort();

            var cell,
                i,
                j = 0;

            for (i = 0; i < newCellsList.length; i++) {
                while (
                    this.currentSelectedCells[j] &&
                    this.currentSelectedCells[j] < newCellsList[i]
                ) {
                    cssEditor.removeStyle(
                        this.currentSelectedCells[j],
                        'border'
                    );
                    j++;
                }

                if (this.currentSelectedCells[j] === newCellsList[i]) {
                    j++;
                } else {
                    cssEditor.addStyle(
                        newCellsList[i],
                        'border',
                        '2px solid #333'
                    );
                }
            }

            for (j; j < this.currentSelectedCells.length; j++) {
                cssEditor.removeStyle(this.currentSelectedCells[j], 'border');
            }

            this.currentSelectedCells = newCellsList;

            this.updateFocus();

            // sd4 - Generate and propagate event to the external interface
            if (true /*propagateEvent*/) {
                var selections = this.selections.rows.map(function(d) {
                    return d.rowID || d.id;
                });
                console.log(selections);

                this.parent.externalInterface.execute('onSelection', [
                    selections
                ]);
            }
        };

        BodyForServant.prototype.updateFocus = function() {
            // If the current cell is editable, focus on it. If not, focus on
            // the keydown catcher.

            if (
                typeof this.selections === 'undefined' ||
                typeof this.selections.currentCell === 'undefined' ||
                typeof this.selections.currentCell.data === 'undefined'
            ) {
                return;
            }

            if (
                this.selections.currentCell.data.editable === true ||
                this.selections.currentCell.data.editable === 'true'
            ) {
                this.focusCell(this.selections.currentCell.cell);
            } else {
                // Focus on keydown catcher
                this.containerDivs.copyTextArea.focus();
            }
        };

        BodyForServant.prototype.shiftCellSelect = function(
            rowID,
            columnID,
            cellData,
            cell
        ) {
            // Applies shift + select
            // Does not change current cell

            //////////////////////////////////
            //  Pseudocode for shift click  //
            //////////////////////////////////

            /*
             * 1: Check size of clicked area. If overly large (greater than 1000
             * rows / 20000 cells, perhaps?), prompt user to warn of potential
             * performance issues with large shift click.
             *
             * 2: Make a server request for all of the requested data. This
             * should have the column data for all columns selected for the
             * selected rows. Data also needs to have IDs. Indices should not be
             * necessary.
             *
             * 3: Once server sends back data:
             *
             *     a: Copy all of the data to the clipboard for copying.
             *
             *     b: Iterate through all rows and:
             *         i: add IDs to list of currently selected rows
             *         ii: Add all cells to list of selected cells
             *
             *     c: Add all columns to list of currently selected columns
             *
             */

            ///////////////////////////////////////////////////////////////////

            var selectedColumns = [],
                selectedRowIndices = [],
                selectedRowIds = [],
                that = this;

            // Select columns
            // Needs to account for columns and fixed columns. How to handle?
            var columns = this.dataHandler.data.fixedColumnKeys.concat(
                    this.dataHandler.data.columnKeys
                ),
                i = 0;

            while (
                columns[i] !== columnID &&
                columns[i] !== this.selections.currentCell.columnID &&
                i < 999999
            ) {
                i++;
            }

            this.selections.columns = [];
            this.selections.columns.push(columns[i]);

            if (
                columnID !== this.selections.currentCell.columnID &&
                this.selections.currentCell.columnID !== null
            ) {
                i++;

                while (
                    columns[i] !== columnID &&
                    columns[i] !== this.selections.currentCell.columnID &&
                    i < 999999
                ) {
                    this.selections.columns.push(columns[i]);
                    i++;
                }

                this.selections.columns.push(columns[i]);
            }

            var startSelectionIndex = Math.min(
                    this.data.rowMetaData[rowID].index,
                    this.selections.currentCell.rowIndex
                ),
                endSelectionIndex = Math.max(
                    this.data.rowMetaData[rowID].index,
                    this.selections.currentCell.rowIndex
                );

            // Build list of row indices
            for (i = startSelectionIndex; i <= endSelectionIndex; i++) {
                selectedRowIndices.push(i);
            }

            return this.dataHandler.
                getData(selectedRowIndices, this.selections.columns).
                then(function(pdata, pstatus, pjqXHR) {
                    if (typeof pdata === 'undefined') {
                        return;
                    }

                    var newData = ParseUtils.getJSONFromResponse([
                        pdata,
                        pstatus,
                        pjqXHR
                    ]);

                    that.selections.rows = [];
                    that.data.copyData = {};

                    for (var key in newData.rowData) {
                        that.selections.rows.push({
                            id: key,
                            index: newData.rowIndexMap[key]
                        });

                        that.data.copyData[key] = {};
                    }

                    var i, j;
                    var colId, rowId;

                    // Update cells
                    that.selections.cells = [];
                    for (i = 0; i < that.selections.rows.length; i++) {
                        for (j = 0; j < that.selections.columns.length; j++) {
                            rowId = that.selections.rows[i].id;
                            colId = that.selections.columns[j];

                            that.selections.cells.push({
                                rowID: rowId,
                                columnID: colId
                            });

                            if (
                                typeof newData.rowData[rowId].mainData[
                                    colId
                                ] !== 'undefined'
                            ) {
                                that.data.copyData[rowId][colId] =
                                    newData.rowData[rowId].mainData[colId];
                            } else {
                                that.data.copyData[rowId][colId] =
                                    newData.rowData[rowId].fixedData[colId];
                            }
                        }
                    }
                });
        };

        BodyForServant.prototype.deselectAllCells = function() {
            var that = this;

            this.selections.currentCell = {};

            this.selections.cells = [];
            this.selections.rows = [];
            this.selections.columns = [];

            this.data.copyData = {};

            // No need to get data...
            this.mainRows.each(function(d) {
                that.updateRowSelection(this, d);
            });

            this.fixedRows.each(function(d) {
                that.updateRowSelection(this, d);
            });

            this.updateSelectedCells(true);
        };

        BodyForServant.prototype.selectCells = function(
            rowID,
            columnID,
            cellData,
            cell,
            e
        ) {
            // Fire this when there's a change to selection

            /*Selection Object (for reference)
             * this.selections = {
                rows : [{id:'1', index:0}, {}],
                columns : [],
                currentCell : {
                    rowID : null,
                    columnID : null
                }
            };
             */

            var ctrlKeySelect = function() {
                var i;
                // console.log('ctrl key only!');

                var rowIndex = -1;

                for (i = 0; i < this.selections.cells.length; i++) {
                    if (
                        this.selections.cells[i].rowID === rowID &&
                        this.selections.cells[i].columnID === columnID
                    ) {
                        rowIndex = i; // Index of selected cell
                        break;
                    }
                }

                if (rowIndex > -1) {
                    // Row is currently selected. Deselect JUST THIS ROW.

                    if (
                        columnID === this.selections.currentCell.columnID &&
                        rowID === this.selections.currentCell.rowID
                    ) {
                        this.selections.currentCell.columnID = null;
                        this.selections.currentCell.rowID = null;
                        this.selections.currentCell.data = null;
                        this.selections.currentCell.rowIndex = null;
                    }

                    this.selections.cells.splice(rowIndex, 1);
                } else {
                    this.selections.currentCell.columnID = columnID;
                    this.selections.currentCell.rowID = rowID;
                    this.selections.currentCell.data = cellData;
                    this.selections.currentCell.rowIndex = this.data.rowMetaData[
                        rowID
                    ].index;

                    this.selections.cells.push({
                        rowID: rowID,
                        columnID: columnID,
                        rowIndex: this.data.rowMetaData[rowID].index
                    });
                }

                // Rebuild rows & cols from cells.
                var uniqueCols = {},
                    uniqueRows = {};

                this.selections.rows = [];
                this.selections.columns = [];

                for (i = 0; i < this.selections.cells.length; i++) {
                    if (!uniqueCols[this.selections.cells[i].columnID]) {
                        uniqueCols[this.selections.cells[i].columnID] = true;
                        this.selections.columns.push(
                            this.selections.cells[i].columnID
                        );
                    }

                    if (!uniqueRows[this.selections.cells[i].rowID]) {
                        uniqueRows[this.selections.cells[i].rowID] = true;
                        this.selections.rows.push({
                            id: this.selections.cells[i].rowID,
                            index: this.selections.cells[i].rowIndex
                        });
                    }
                }
            };

            var deferred = false;

            // If current cell is already selected and this is a right click,
            // don't handle the click event  if(e.which === 3 &&
            // this.selections.cells.some(function(d){
            //  return +d.rowID === +cellData.row && d.columnID ===
            //  cellData.column;
            //})){
            //  return;
            //}

            /* global console */
            if (e.ctrlKey && e.shiftKey) {
                console.log('shift + ctrl! Not handled yet...');
            } else if (e.ctrlKey) {
                ctrlKeySelect.call(this);
            } else if (e.shiftKey) {
                deferred = this.shiftCellSelect(
                    rowID,
                    columnID,
                    cellData,
                    cell
                );
            } else {
                this.singleCellSelect(rowID, columnID, cellData, cell);
            }

            var that = this;

            if (deferred) {
                deferred.then(function() {
                    // We can assume that row and column are in the current
                    // range. We won't be calling this on scroll.
                    that.mainRows.each(function(d) {
                        that.updateRowSelection(this, d);
                    });

                    that.fixedRows.each(function(d) {
                        that.updateRowSelection(this, d);
                    });

                    that.updateSelectedCells(true);
                });
            } else {
                var that = this;

                // We can assume that row and column are in the current range.
                // We won't be calling this on scroll.
                this.mainRows.each(function(d) {
                    that.updateRowSelection(this, d);
                });

                this.fixedRows.each(function(d) {
                    that.updateRowSelection(this, d);
                });

                this.updateSelectedCells(true);
            }
        };

        BodyForServant.prototype.selectedCellStyles = {
            // These styles are used by the css editor to create new styles for
            // selected cells.

            feasible: { background: '#b2f0f1' },
            infeasible: { background: '#ff5959' },
            paretoDesign: { background: '#59ff59' },
            excluded: { background: '#a5a5a5' }
        };
        BodyForServant.prototype.setColors = function(
            feasible,
            infeasible,
            pareto,
            excluded
        ) {
            this.selectedCellStyles.feasible.background = feasible.HIGHLIGHT;
            this.selectedCellStyles.infeasible.background =
                infeasible.HIGHLIGHT;
            this.selectedCellStyles.paretoDesign.background = pareto.HIGHLIGHT;
            this.selectedCellStyles.excluded.background = excluded.HIGHLIGHT;
        };
        BodyForServant.prototype.updateRowSelection = function(thisRow, d) {
            // Update selection for a given row.
            // Note that the main rows and fixed rows are not contained in the
            // same rows, and need to be updated separately.

            // Each selector needs three identifiers, since the default
            // identifiers for row classes have two.

            // CSS Style Sheet Changes
            // Column classes
            var cssEditor = this.parent.cssEditor;

            var selectedClasses = this.selections.columns.map(function(d) {
                return 'bodyColumn' + d;
            });

            var i, key;

            for (key in this.currentHighlightedColumns) {
                if (
                    this.currentHighlightedColumns.hasOwnProperty(key) &&
                    selectedClasses.indexOf(key) === -1
                ) {
                    cssEditor.removeStyle(
                        '.dominated .dataTable-body-tableCell.' + key,
                        'background'
                    );
                    cssEditor.removeStyle(
                        '.infeasible .dataTable-body-tableCell.' + key,
                        'background'
                    );
                    cssEditor.removeStyle(
                        '.pareto .dataTable-body-tableCell.' + key,
                        'background'
                    );
                    cssEditor.removeStyle(
                        '.excluded .dataTable-body-tableCell.' + key,
                        'background'
                    );

                    delete this.currentHighlightedColumns[key];
                }
            }

            for (i = 0; i < selectedClasses.length; i++) {
                if (
                    typeof this.currentHighlightedColumns[
                        selectedClasses[i]
                    ] === 'undefined'
                ) {
                    // Update classes
                    cssEditor.addStyle(
                        '.dominated .dataTable-body-tableCell.' +
                            selectedClasses[i],
                        'background',
                        this.selectedCellStyles.feasible.background
                    );
                    cssEditor.addStyle(
                        '.infeasible .dataTable-body-tableCell.' +
                            selectedClasses[i],
                        'background',
                        this.selectedCellStyles.infeasible.background
                    );
                    cssEditor.addStyle(
                        '.pareto .dataTable-body-tableCell.' +
                            selectedClasses[i],
                        'background',
                        this.selectedCellStyles.paretoDesign.background
                    );
                    cssEditor.addStyle(
                        '.excluded .dataTable-body-tableCell.' +
                            selectedClasses[i],
                        'background',
                        this.selectedCellStyles.excluded.background
                    );

                    this.currentHighlightedColumns[selectedClasses[i]] = true;
                }
            }

            // Row classes
            selectedClasses = this.selections.rows.map(function(d) {
                return 'bodyRow' + d.id;
            });

            for (key in this.currentHighlightedRows) {
                if (
                    this.currentHighlightedRows.hasOwnProperty(key) &&
                    selectedClasses.indexOf(key) === -1
                ) {
                    cssEditor.removeStyle(
                        '.dominated.' + key + ' .dataTable-body-tableCell',
                        'background'
                    );
                    cssEditor.removeStyle(
                        '.infeasible.' + key + ' .dataTable-body-tableCell',
                        'background'
                    );
                    cssEditor.removeStyle(
                        '.pareto.' + key + ' .dataTable-body-tableCell',
                        'background'
                    );
                    cssEditor.removeStyle(
                        '.excluded.' + key + ' .dataTable-body-tableCell',
                        'background'
                    );

                    delete this.currentHighlightedRows[key];
                }
            }

            for (i = 0; i < selectedClasses.length; i++) {
                if (
                    typeof this.currentHighlightedRows[selectedClasses[i]] ===
                    'undefined'
                ) {
                    // Update classes
                    cssEditor.addStyle(
                        '.dominated.' +
                            selectedClasses[i] +
                            ' .dataTable-body-tableCell',
                        'background',
                        this.selectedCellStyles.feasible.background
                    );
                    cssEditor.addStyle(
                        '.infeasible.' +
                            selectedClasses[i] +
                            ' .dataTable-body-tableCell',
                        'background',
                        this.selectedCellStyles.infeasible.background
                    );
                    cssEditor.addStyle(
                        '.pareto.' +
                            selectedClasses[i] +
                            ' .dataTable-body-tableCell',
                        'background',
                        this.selectedCellStyles.paretoDesign.background
                    );
                    cssEditor.addStyle(
                        '.excluded.' +
                            selectedClasses[i] +
                            ' .dataTable-body-tableCell',
                        'background',
                        this.selectedCellStyles.excluded.background
                    );

                    this.currentHighlightedRows[selectedClasses[i]] = true;
                }
            }
        };

        ////////////////////////
        // Copy/Paste Methods //
        ////////////////////////

        BodyForServant.prototype.saveData = function(changeObject) {
            var col, colId, rowId, cellContent, sourceContent;

            var that = this;

            var copyData = that.data.copyData;

            var getFormattedText = function(d) {
                return that.getFormattedText(d);
            };

            for (colId in changeObject) {
                col = changeObject[colId];
                for (rowId in col) {
                    cellContent = col[rowId];
                    sourceContent = copyData[rowId][colId];

                    // FIXME: We should allow for high-precision data
                    // modification.
                    if (
                        getFormattedText(cellContent) !==
                        getFormattedText(sourceContent)
                    ) {
                        that.parent.eventController(
                            'saveChanges',
                            changeObject
                        );
                        return;
                    }
                }
            }
        };

        BodyForServant.prototype.createCopyHandler = function() {
            // Creates a div that holds content for copying and catches pasted
            // content.

            var that = this;

            this.containerDivs.copyTextArea = document.createElement(
                'textarea'
            );
            this.containerDivs.copyTextArea.className +=
                'dataTable-body-copyTextArea ';
            this.containerDivs.root.appendChild(
                this.containerDivs.copyTextArea
            );

            var isPasteable = function(data) {
                var colData;

                // Make sure data is an array of arrays
                if (!(data instanceof Array)) {
                    return false;
                }
                if (!(data[0] instanceof Array)) {
                    return false;
                }

                var rowLength = data[0].length,
                    i;

                // Make sure that all rows are the same length
                for (i = i; i < data.length; i++) {
                    if (data[i].length !== rowLength) {
                        return false;
                    }
                }

                // Make sure all columns are editable
                for (i = 0; i < that.selections.columns; i++) {
                    colData = that.dataHandler.data.columns(
                        that.selections.columns[i]
                    );

                    if (!colData.editable || colData.editable === 'false') {
                        return false;
                    }
                }

                return true;
            };

            d3.
                select(this.containerDivs.copyTextArea).
                on('paste', function() {
                    // On a paste, we push a function that will deal with
                    // the pasted data onto the event stack. This makes sure
                    // that  the pasted data has entered the dom before we
                    // retrieve it to paste into the cells.
                    window.setTimeout(function() {
                        // console.log(that.containerDivs.copyTextArea.value);

                        // First we need to parse the content
                        var parsedData = that.copyParser.SheetClip.parse(
                            that.containerDivs.copyTextArea.value
                        );

                        // Empty parsedData
                        that.containerDivs.copyTextArea.value = '';

                        // Send command to copy the data if all of the
                        // selected columns are editable
                        if (isPasteable(parsedData)) {
                            // Pass to parent to make changes to data

                            var data = parsedData,
                                selections = that.selections;

                            var changeObject = {};

                            var dataRowsLength = data.length,
                                dataColsLength = data[0].length;

                            var startColIndex = that.dataHandler.data.columnKeys.indexOf(
                                    selections.currentCell.columnID
                                ),
                                startRowIndex = Math.min.apply(
                                    null,
                                    selections.rows.map(function(d) {
                                        return d.index;
                                    })
                                );

                            // Check for valid indices
                            if (startColIndex === -1 || startRowIndex === -1) {
                                throw 'cound not locate selection index.';
                            }

                            // Make sure that data will fit in editable
                            // area.
                            var endColIndex = Math.min(
                                    startColIndex + dataColsLength,
                                    that.dataHandler.data.columnKeys.length
                                ),
                                endRowIndex = Math.min(
                                    startRowIndex + dataRowsLength - 1,
                                    that.data.metaData.displayedRows - 1
                                );

                            // We can't just use the selection we have here
                            // because the data can be larger than the
                            // selection.
                            var colKeys = that.dataHandler.data.columnKeys.slice(
                                    startColIndex,
                                    endColIndex
                                ),
                                rowKeys = [];

                            var i, j;
                            for (i = startRowIndex; i <= endRowIndex; i++) {
                                rowKeys.push(i);
                            }

                            if (
                                startRowIndex + parsedData.length >
                                that.data.metaData.numRows
                            ) {
                                throw 'Pasted data does not fit in table!';
                            }

                            var saveChanges = false;

                            var content, validationType;

                            var filterFn = function(d) {
                                return d.ID === rowKeys[j];
                            };

                            var isNaNPaste = 0;

                            for (i = 0; i < colKeys.length; i++) {
                                changeObject[colKeys[i]] = {};
                                validationType = that.dataHandler.data.columns[
                                    colKeys[i]
                                ].dataType.toLowerCase();

                                for (j = 0; j < rowKeys.length; j++) {
                                    content = data[j][i]; // This is the content

                                    if (
                                        validationType === 'real' ||
                                        validationType === 'double(6)' ||
                                        validationType === 'integer'
                                    ) {
                                        // Handle blank cells
                                        if (content !== '') {
                                            isNaNPaste += isNaN(content);

                                            content = Number(content);
                                        }
                                    }

                                    if (
                                        content === '' ||
                                        that.parent.externalInterface.execute(
                                            'validateContents',
                                            [
                                                {
                                                    validationType: validationType,
                                                    content: content
                                                }
                                            ]
                                        )
                                    ) {
                                        // if valid, paste to corresponding
                                        // column & save
                                        changeObject[colKeys[i]][
                                            rowKeys[j]
                                        ] = content;

                                        saveChanges = true; // There is some
                                        // valid data
                                    }
                                }
                            }

                            if (isNaNPaste) {
                                alert(
                                    'Invalid data has been entered in one or more cells.\n\nInvalid numeric data will be converted to NaN'
                                );
                            }

                            that.dataHandler.editCellsByIndex(changeObject);
                            
                            //Enter editing mode
                            that.parent.startEditMode();
                            
                            //Update data and populate cells
                            var changedColumns = Object.keys(changeObject);
                            var startIndex = that.rowIndices.startIndex;
                            var rows = that.mainRows;
                            changedColumns.forEach(function(columnKey){
                            	var columnData = changeObject[columnKey];
                            	rows.each(function(d, i){
                                	var rowIndex = startIndex + i;
                                	if(typeof columnData[rowIndex] !== 'undefined'){
                                		that.data.mainData.rows[d][columnKey] = columnData[rowIndex];
                                		var cell = d3.select(this).selectAll('span').filter(function(d){
                                			return d.column === columnKey;
                                		});
                                		cell.text(function(){
                                			return columnData[rowIndex];
                                		});
                                	}
                                });
                            });
                            
                            /*
                             * for (key in newData.rowData) {
                        // if(key >= that.rowIndices.startIndex && key <=
                        // that.rowIndices.endIndex){
                        that.data.mainData.rows[key] =
                            newData.rowData[key].mainData;
                        that.data.fixedData.rows[key] =
                            newData.rowData[key].fixedData;
                        that.data.rowMetaData[key] =
                            newData.rowData[key].metaData;
                        that.data.rowMetaData[key].dimensions = {
                            height:
                                that.dataHandler.dimensions.row.defaultHeight,
                            y:
                                that.dataHandler.dimensions.row.defaultHeight *
                                newData.rowIndexMap[key]
                        };
                        that.data.rowMetaData[key].index =
                            newData.rowIndexMap[key];
                        //}
                    }
                             */
                        }
                    }, 1);
                }).
                on('cut', function(d) {
                    var colKeys = that.selections.columns,
                        rowKeys = that.selections.rows;

                    var rowsEditable = 1,
                        colsEditable = 1,
                        editableCells;

                    var i, j;

                    if (
                        that.selections.cells.length !==
                        that.selections.columns.length *
                            that.selections.rows.length
                    ) {
                        alert(
                            'Only rectangular selections can be copied or cut.'
                        );
                        return false;
                    }

                    // Copy contents

                    // Cut current contents if all cells are deletable and
                    // selection is rectangular
                    var changeObject = {};

                    for (i = 0; i < that.selections.columns.length; i++) {
                        changeObject[that.selections.columns[i]] = {};
                    }

                    for (i = 0; i < that.selections.cells.length; i++) {
                        changeObject[that.selections.cells[i].columnID][
                            that.selections.cells[i].rowID
                        ] =
                            '';
                    }

                    // that.saveData(changeObject);

                    that.parent.eventController('saveChanges', changeObject);
                });

            ///
            /**
             * SheetClip - Spreadsheet Clipboard Parser
             * version 0.2
             *
             * This tiny library transforms JavaScript arrays to strings that
             * are pasteable by LibreOffice, OpenOffice, Google Docs and
             * Microsoft Excel.
             *
             * Copyright 2012, Marcin Warpechowski
             * Licensed under the MIT license.
             * http://github.com/warpech/sheetclip/
             *
             * DS IP Asset: IPA005404
             */
            (function(global) {
                function countQuotes(str) {
                    return str.split('"').length - 1;
                }

                global.SheetClip = {
                    parse: function(str) {
                        var r,
                            rlen,
                            rows,
                            arr = [],
                            a = 0,
                            c,
                            clen,
                            multiline,
                            last;

                        rows = str.split('\n');
                        if (rows.length > 1 && rows[rows.length - 1] === '') {
                            rows.pop();
                        }
                        for (r = 0, rlen = rows.length; r < rlen; r += 1) {
                            rows[r] = rows[r].split('\t');
                            for (
                                c = 0, clen = rows[r].length;
                                c < clen;
                                c += 1
                            ) {
                                if (!arr[a]) {
                                    arr[a] = [];
                                }
                                if (multiline && c === 0) {
                                    last = arr[a].length - 1;
                                    arr[a][last] =
                                        arr[a][last] + '\n' + rows[r][0];
                                    if (
                                        multiline &&
                                        (countQuotes(rows[r][0]) && 1)
                                    ) {
                                        //& 1 is a bitwise way
                                        //of performing mod 2
                                        multiline = false;
                                        arr[a][last] = arr[a][last].
                                            substring(
                                                0,
                                                arr[a][last].length - 1
                                            ).
                                            replace(/""/g, '"');
                                    }
                                } else {
                                    if (
                                        c === clen - 1 &&
                                        rows[r][c].indexOf('"') === 0
                                    ) {
                                        arr[a].push(
                                            rows[r][c].
                                                substring(1).
                                                replace(/""/g, '"')
                                        );
                                        multiline = true;
                                    } else {
                                        arr[a].push(
                                            rows[r][c].replace(/""/g, '"')
                                        );
                                        multiline = false;
                                    }
                                }
                            }
                            if (!multiline) {
                                a += 1;
                            }
                        }
                        return arr;
                    },

                    stringify: function(arr) {
                        var r,
                            rlen,
                            c,
                            clen,
                            str = '',
                            val;
                        for (r = 0, rlen = arr.length; r < rlen; r += 1) {
                            for (
                                c = 0, clen = arr[r].length;
                                c < clen;
                                c += 1
                            ) {
                                if (c > 0) {
                                    str += '\t';
                                }
                                val = arr[r][c];
                                if (typeof val === 'string') {
                                    if (val.indexOf('\n') > -1) {
                                        str +=
                                            '"' + val.replace(/"/g, '""') + '"';
                                    } else {
                                        str += val;
                                    }
                                } else if (val === null || val === void 0) {
                                    // void 0 resolves to
                                    // undefined
                                    str = String(str);
                                } else {
                                    str += val;
                                }
                            }
                            str += '\n';
                        }
                        return str;
                    }
                };
            })(that.copyParser);
        };

        return BodyForServant;
    }
);

/* exported getOrderedParamList */
/* exported fixParameterOrder */
/* exported setGroupOrder */
/* exported setD3GroupOrder */
/* exported makeD3ParameterCopy */
/* exported makeGroupCopyFromD3 */
/* global define*/
define('DS/SMAAnalyticsDataTable/SMAAnalyticsDataTableUtils', [], function() {
    'use strict';
    function DataTableUtils() {}
    DataTableUtils.prototype.getOrderedParamList = function(data) {
        // Uses the 'order' attribute (if provided) to generate an ordered list
        // of
        // all parameters

        // getOrderedParamList will organize one layer, and then call itself on
        // all
        // group children, replacing the child with a flattened list of all of
        // its
        // children.
        // This flattened list will be generated with getOrderedParamList.

        var paramList = [],
            paramLength = data.parameters ? data.parameters.length : 0,
            groupLength = data.groups ? data.groups.length : 0,
            i;

        for (i = 0; i < paramLength; i++) {
            paramList.push(data.parameters[i]);
        }

        for (i = 0; i < groupLength; i++) {
            paramList.push(data.groups[i]);
        }

        paramList.sort(function(a, b) {
            if (
                typeof a.order === 'undefined' ||
                typeof b.order === 'undefined'
            ) {
                if (
                    typeof a.order === 'undefined' &&
                    typeof b.order === 'undefined'
                ) {
                    return 0;
                } else if (typeof b.order === 'undefined') {
                    return 1;
                }

                return -1;
            } else {
                return a.order - b.order;
            }
        });

        for (i = paramList.length - 1; i >= 0; i--) {
            // Traverse in reverse order so that subbing out groups for their
            // flattened lists doesn't affect the indexing.
            if (paramList[i].groups || paramList[i].parameters) {
                Array.prototype.splice.apply(
                    paramList,
                    [i, 1].concat(
                        DataTableUtils.prototype.getOrderedParamList(
                            paramList[i]
                        )
                    )
                );
            }
        }

        return paramList;
    };

    DataTableUtils.prototype.fixParameterOrder = function(paramArray) {
        var i = 0;

        for (i; i < paramArray.length; i++) {
            paramArray[i].order = i;
        }
    };

    DataTableUtils.prototype.setGroupOrder = function(data) {
        var groupsLength = data.groups ? data.groups.length : 0,
            parametersLength = data.parameters ? data.parameters.length : 0,
            i,
            groupOrder = Infinity,
            childOrder;

        for (i = 0; i < groupsLength; i++) {
            childOrder = DataTableUtils.prototype.setGroupOrder(data.groups[i]);

            if (childOrder < groupOrder) {
                groupOrder = childOrder;
            }
        }

        for (i = 0; i < parametersLength; i++) {
            childOrder = data.parameters[i].order;

            if (childOrder < groupOrder) {
                groupOrder = childOrder;
            }
        }

        data.order = groupOrder;

        return data.order;
    };

    DataTableUtils.prototype.setD3GroupOrder = function(data) {
        var childrenLength = data.children ? data.children.length : 0,
            i,
            groupOrder = Infinity,
            childOrder;

        for (i = 0; i < childrenLength; i++) {
            childOrder = DataTableUtils.prototype.setD3GroupOrder(
                data.children[i]
            );

            if (childOrder < groupOrder) {
                groupOrder = childOrder;
            }
        }

        if (i !== 0) {
            data.order = groupOrder;
        }

        return data.order;
    };

    // Makes a copy of a parameter that can be modified without messing up the
    // parent
    DataTableUtils.prototype.makeD3ParameterCopy = function(
        parameter,
        parentID
    ) {
        var newParam = { parentID: parentID },
            key;

        // Add all attributes
        for (key in parameter) {
            if (parameter.hasOwnProperty(key)) {
                newParam[key] = parameter[key];
            }
        }

        newParam.nodeType = 'parameter';

        return newParam;
    };

    DataTableUtils.prototype.makeParameterCopyFromD3 = function(parameter) {
        var newParam = {},
            key;

        for (key in parameter) {
            if (
                key !== 'nodeType' &&
                key !== 'parentID' &&
                key !== 'x' &&
                key !== 'y' &&
                key !== 'dx' &&
                key !== 'dy' &&
                key !== 'value'
            ) {
                newParam[key] = parameter[key];
            }
        }

        return newParam;
    };

    DataTableUtils.prototype.makeGroupCopyFromD3 = function(group) {
        var newGroup = { parameters: [], groups: [] };

        var i, key;

        for (key in group) {
            // Sanitize group by removing all keys added by d3
            if (
                key !== 'children' &&
                key !== 'paramIDs' &&
                key !== 'groupIDs' &&
                key !== 'paramIDs' &&
                key !== 'parentID' &&
                key !== 'nodeType' &&
                key !== 'x' &&
                key !== 'y' &&
                key !== 'dx' &&
                key !== 'dy' &&
                key !== 'value'
            ) {
                newGroup[key] = group[key];
            }
        }

        for (i = 0; i < group.children.length; i++) {
            if (group.children[i].nodeType === 'parameter') {
                newGroup.parameters.push(
                    DataTableUtils.prototype.makeParameterCopyFromD3(
                        group.children[i]
                    )
                );
            } else {
                newGroup.groups.push(
                    DataTableUtils.prototype.makeGroupCopyFromD3(
                        group.children[i]
                    )
                );
            }
        }

        return newGroup;
    };
    return DataTableUtils.prototype;
});

/* global define */
/* global console */
/* global d3 */
/* global formatExp */

/* exported DataTableUtils */
define(
    'DS/SMAAnalyticsDataTable/SMAAnalyticsServantDataHandler',
    [
        'DS/SMAAnalyticsDataTable/SMAAnalyticsDataTableUtils',
        'DS/SMAAnalyticsNLS/SMAAnalyticsNLSUtils',
        'DS/SMAAnalyticsUtils/SMAAnalyticsParseUtils'
    ],
    function(DataTableUtils, NLSUtils, ParseUtils) {
        'use strict';
        function ServantDataHandler(
            options,
            externalInterface,
            dataTableProxy,
            makeD3GroupCopy
        ) {
            this.externalInterface = externalInterface;
            this.dataTableProxy = dataTableProxy;
            this.makeD3GroupCopy = makeD3GroupCopy;
            // Data should be an array

            if (!options) {
                options = {};
            }

            // Reference to the data object.
            this.data = {
                rows: {},
                rowKeys: [], // Main and fixed rows share keys
                fixedColumns: {},
                fixedColumnKeys: [],
                columns: {},
                columnKeys: [],
                metaData: { rows: 0 }
            };

            // Data for the header
            this.svgHeaderData = {};

            // Order in which items will be sorted.
            this.currentSorts = [
                { id: 'Rank', fixed: 'true', reverseSort: 'false' },
                { id: 'Name', fixed: 'true', reverseSort: 'false' }
            ];

            this.state = {};

            this.colType = options.columnType || 'key';

            this.colWidthSpec = options.columnWidthSpec || 'single';

            this.rowHeightSpec = options.rowHeightSpec || 'single'; // Defines that only a single value is given for
            // row height

            this.dimensions = {
                column: {
                    defaultWidth: options.columnWidth || 100,
                    x: [0] // This will store a list of all column x
                    // positions. The order should correspond to
                    // this.data.columnKeys
                },
                fixedColumns: {
                    defaultWidth: options.columnWidth || 100,
                    x: [0] // This will store a list of all column x
                    // positions. The order should correspond to
                    // this.data.columnKeys
                },
                row: { defaultHeight: options.rowHeight || 20, y: [0] },
                totalWidth: 0,
                totalHeight: 0
            };

            this.startRowIndex = 0;
            this.endRowIndex = 0;

            this.startColumnIndex = 0;
            this.endColumnIndex = 0;

            this.dataClasses = {
                integer: 'number',
                'double(6)': 'number',
                REAL: 'number'
            };

            this.editableColumns = {};
            this.editableRows = {};

            this.sortFreeze = false;
        }

        ////////////////////////////
        // Initialization methods //
        ////////////////////////////

        ServantDataHandler.prototype.initializeTableData = function() {
            // This will make a proxy call for the table data and set an
            // internal variable to the data contained in the response

            var that = this;

            return this.dataTableProxy.
                getTableMetadata().
                then(function(pdata, pstatus, pjqXHR) {
                    var newData = ParseUtils.getJSONFromResponse([
                        pdata,
                        pstatus,
                        pjqXHR
                    ]);

                    that.data.metaData = newData.metaData;

                    that.data.serverColumnData = newData.columnData;

                    // define columns for all of the FIXED columns in
                    // serverColumnData. Other columns should be handled by importing
                    // varGroup.
                    var column;
                    for (var key in newData.columnData.fixedData) {
                        column = newData.columnData.fixedData[key];

                        // translate the column display names
                        if (typeof column.displayName !== 'undefined') {
                            column.displayName = NLSUtils.translate(
                                column.displayName
                            );
                        }

                        that.updateFixedColumn(column.id, column);
                    }
                });
        };

        ServantDataHandler.prototype.updateMetadata = function(newMetaData) {
            this.data.metaData = newMetaData;
        };

        ServantDataHandler.prototype.setFixedColumns = function(
            fixedColumns,
            noFixedEdit
        ) {
            this.state.noFixedEdit = noFixedEdit; // TODO: This should get
            // passed in once we have
            // it in the data.

            this.state.fixedColumns = fixedColumns;
        };

        /////////////////////////
        // Data Import Methods //
        /////////////////////////

        ServantDataHandler.prototype.importVarGroup = function(options) {
            var columns,
                i,
                that = this;

            options = options || {};

            // Imports proxy.prototype.varGroup as the parameter hierarchy
            this.varGroupCopy = this.externalInterface.execute('getHierarchy');

            if (options.noColumnUpdate === true) {
                return;
            }

            if (options.garbageCollect === true) {
                this.flagGarbageCollect('mainColumn');
            }

            // Make sure that all parameters and groups are ordered and that
            // children of groups occur in order  if(options.initializing ===
            // true){  Only do this the first time refresh is called.
            // This makse sure everything has an order and displayOrders are
            // observed
            this.sanitizeGroupOrder();
            //}

            columns = DataTableUtils.getOrderedParamList(this.varGroupCopy);

            for (i = 0; i < columns.length; i++) {
                if (typeof columns[i].dataClass === 'undefined') {
                    if (this.dataClasses[columns[i].dataType] === 'number') {
                        columns[i].dataClass = 'numberCell';
                    } else {
                        columns[i].dataClass = 'stringCell';
                    }
                }

                if (this.editableColumns[columns[i].ID] === true) {
                    columns[i].editable = true;
                }

                this.updateColumn(columns[i].ID, columns[i]);
            }

            // After updating, clean up any columns not in the current varGroup
            // if gc === true.
            if (options.garbageCollect === true) {
                this.collectGarbage('mainColumn');
            }

            // Make sure that column keys are ordered properly.
            this.data.columnKeys.sort(function(A, B) {
                var a = that.data.columns[A];
                var b = that.data.columns[B];

                // if (typeof a.order === 'undefined' || typeof b.order ===
                // 'undefined') {

                //  if(typeof a.order === 'undefined' && typeof b.order ===
                //  'undefined'){
                //      return 0;
                //  } else if (typeof b.order === 'undefined') {
                //      return -1;
                //  }

                //  return 1;
                //} else {
                return a.order - b.order;
                //}
            });
        };

        ///////////////////////////////////////////////////
        // Internal data definition and updating methods //
        ///////////////////////////////////////////////////

        ServantDataHandler.prototype.updateColumn = function(
            ID,
            columnOptions
        ) {
            var key;

            if (typeof this.data.columns[ID] === 'undefined') {
                this.data.columns[ID] = {};
                this.data.columnKeys.push(ID);
            }

            for (key in columnOptions) {
                if (
                    columnOptions.hasOwnProperty(key) &&
                    typeof columnOptions[key] !== 'undefined'
                ) {
                    this.data.columns[ID][key] = columnOptions[key];
                }
            }

            this.data.columns[ID].isOldData = 'false';
        };

        ServantDataHandler.prototype.updateFixedColumn = function(
            ID,
            columnOptions
        ) {
            var key;

            if (typeof this.data.fixedColumns[ID] === 'undefined') {
                this.data.fixedColumns[ID] = {};
                this.data.fixedColumnKeys.push(ID);
            }

            for (key in columnOptions) {
                if (columnOptions.hasOwnProperty(key)) {
                    this.data.fixedColumns[ID][key] = columnOptions[key];
                }
            }

            if (
                this.state.noFixedEdit === true ||
                this.state.noFixedEdit === 'true'
            ) {
                this.data.fixedColumns[ID].editable = 'fixed';
            }
        };

        //---------------------------------
        // Data fetching methods
        //---------------------------------

        ServantDataHandler.prototype.getFixedHeaderData = function() {
            // Returns ordered column array for building fixed header

            var i,
                returnArray = [];

            for (i = 0; i < this.data.fixedColumnKeys.length; i++) {
                returnArray.push(
                    this.data.fixedColumns[this.data.fixedColumnKeys[i]]
                );
            }

            return returnArray;
        };

        ServantDataHandler.prototype.getMainHeaderData = function() {
            // Returns ordered array of columns for building main header

            var parameterData = [],
                i;

            for (i = 0; i < this.data.columnKeys.length; i++) {
                parameterData.push(this.data.columns[this.data.columnKeys[i]]);
            }

            return parameterData;
        };

        //----------------------------------------------------
        // Methods for updating SVG data - used by SVG header
        //----------------------------------------------------

        ServantDataHandler.prototype.updateDataFromD3 = function() {
            /*On a d3 data change, the columns are changing. The following
             * things need to happen: -Update main data object from the d3 data
             * -> eventually, push change to server -Update SVG data
             *
             * -Call refresh on table, which does the following:
             *   -Updates columns
             *   -Calls refresh on header
             *       -Main header updates -> new position object
             *       -SVG header updates to reflect changes to position object
             *   -Calls refresh on body
             *       -Body uses new width object to reposition columns
             */

            var columns,
                i,
                that = this;

            this.varGroupCopy = DataTableUtils.makeGroupCopyFromD3(
                this.svgHeaderData.d3Data
            ); // It would be better to not have to
            // clone the data
            // The data can probably be modified in place in the local copy for
            // both the svg data and the other data. The partition  would remain
            // separate, but it uses references anyways.

            columns = DataTableUtils.getOrderedParamList(this.varGroupCopy);

            for (i = 0; i < columns.length; i++) {
                this.updateColumn(columns[i].ID, columns[i]);
            }

            // Sanitized data might not match keys
            this.data.columnKeys.sort(function(a, b) {
                return that.data.columns[a].order - that.data.columns[b].order;
            });
        };

        ServantDataHandler.prototype.insertParameter = function(
            newParameter,
            targetOrder
        ) {
            // Places a parameter at a specified location in the parameter order

            var columnId =
                newParameter.id || newParameter.Id || newParameter.ID; // TODO: Standardize ID.

            this.editableColumns[columnId] = true;

            this.updateColumn(columnId, newParameter);

            var paramData = { editable: 'true' };

            if (typeof newParameter.dataClass === 'undefined') {
                if (this.dataClasses[newParameter.dataType] === 'number') {
                    paramData.dataClass = 'numberCell';
                } else {
                    paramData.dataClass = 'stringCell';
                }
            }

            this.updateColumn(columnId, paramData);

            var newNode = this.data.columns[columnId];

            this.moveNode(newNode, targetOrder);
        };

        ServantDataHandler.prototype.moveNode = function(
            movedNode,
            targetOrder
        ) {
            // this function moves a single leaf (movedNode) to a certain
            // position (targetOrder) and  then updates all parameter orders.
            //
            // movedNode.order will be undefined for a newly created node that
            // has not had an order attribute defined

            var that = this;

            var startOrder, endOrder, orderChange;

            var i;

            // Set up re-indexing variables
            if (typeof movedNode.order === 'undefined') {
                targetOrder += 1;
                startOrder = targetOrder;
                endOrder = that.data.columnKeys.length - 1;
                orderChange = +1;
            } else if (movedNode.order === targetOrder) {
                return;
            } else if (movedNode.order < targetOrder) {
                startOrder = movedNode.order + 1;
                endOrder = targetOrder;
                orderChange = -1;
            } else {
                // movedNode.order > targetOrder
                startOrder = targetOrder;
                endOrder = movedNode.order - 1;
                orderChange = +1;
            }

            this.data.columnKeys.sort(function(A, B) {
                var a = that.data.columns[A];
                var b = that.data.columns[B];

                if (
                    typeof a.order === 'undefined' ||
                    typeof b.order === 'undefined'
                ) {
                    if (
                        typeof a.order === 'undefined' &&
                        typeof b.order === 'undefined'
                    ) {
                        return 0;
                    } else if (typeof b.order === 'undefined') {
                        return -1;
                    }

                    return 1;
                } else {
                    return a.order - b.order;
                }
            });

            // update column orders
            for (i = startOrder; i <= endOrder; i++) {
                this.updateColumn(this.data.columnKeys[i], {
                    order: i + orderChange
                });
            }

            this.updateColumn(movedNode.ID, { order: targetOrder });

            this.data.columnKeys.sort(function(a, b) {
                return that.data.columns[a].order - that.data.columns[b].order;
            });

            // Update varGroup data based on new order
            this.updateVarGroupOrder();
            // this.saveVarGroupOrder(); //Save new order to server
        };

        ServantDataHandler.prototype.getSVGHeaderData = function() {
            return this.svgHeaderData;
        };

        //---------------------------------------------------
        // Methods for updating dimensioning based on data
        //---------------------------------------------------

        ServantDataHandler.prototype.updateColumnPositions = function() {
            // Updates all column positions based on content sizes and user set
            // column sizes,  as well as column order.

            var i = 0,
                nextLeft = 0,
                thisColumn,
                that = this;

            for (i = 0; i < this.data.fixedColumnKeys.length; i++) {
                thisColumn = this.data.fixedColumns[
                    this.data.fixedColumnKeys[i]
                ];

                thisColumn.left = Number(nextLeft);
                nextLeft += thisColumn.activeWidth;
            }

            this.dimensions.fixedWidth = nextLeft;
            nextLeft = 0;

            this.data.columnKeys.sort(function(a, b) {
                return that.data.columns[a].order - that.data.columns[b].order;
            });

            for (i = 0; i < this.data.columnKeys.length; i++) {
                thisColumn = this.data.columns[this.data.columnKeys[i]];

                thisColumn.left = Number(nextLeft); // Return value instead of reference
                nextLeft += thisColumn.offsetPosition.activeWidth;
            }

            this.dimensions.mainWidth = nextLeft;
        };

        //------------------------------------
        // Update Indices - used by body & when fetching data
        //------------------------------------

        ServantDataHandler.prototype.updateColumnIndex = function(
            startPosition,
            endPosition
        ) {
            // This updates what the internal start and end indices for
            // columns are, based on a new start/end position  for what
            // should be rendered and the sizes of the columns.

            var i;

            if (this.data.columnKeys.length === 0) {
                return [0, 0];
            }

            if (this.columnWidthSpec === 'single') {
                this.startColumnIndex = Math.max(
                    Math.floor(startPosition / this.columnWidth),
                    0
                );
                this.endColumnIndex = Math.min(
                    Math.ceil(endPosition / this.columnWidth),
                    this.data.columnKeys.length - 1
                );
            } else {
                i = this.data.columnKeys.length - 1;

                // primitive o(n) array lookup
                while (
                    this.data.columns[this.data.columnKeys[i]].offsetPosition.
                        left > endPosition &&
                    i--
                ) {
                    /* jshint noempty:false */
                }

                this.endColumnIndex = Math.min(
                    Math.max(i + 1, 0),
                    this.data.columnKeys.length - 1
                );

                do {
                    /* jshint noempty:false */
                } while (
                    i-- &&
                    this.data.columns[this.data.columnKeys[i]].offsetPosition.
                        left > startPosition
                );

                this.startColumnIndex = Math.max(i, 0);
            }

            return [this.startColumnIndex, this.endColumnIndex];
        };

        ServantDataHandler.prototype.updateRowIndex = function(
            startPosition,
            endPosition
        ) {
            // This updates what the internal start and end indices for row are,
            // based on a new start/end position  for what should be rendered and
            // the sizes of the rows. All rows are the same size.

            var i;

            if (this.rowHeightSpec === 'single') {
                // This is the only option.
                this.startRowIndex = Math.max(
                    Math.floor(
                        startPosition / this.dimensions.row.defaultHeight
                    ),
                    0
                );
                this.endRowIndex = Math.ceil(
                    endPosition / this.dimensions.row.defaultHeight
                );
            }

            return [this.startRowIndex, this.endRowIndex];
        };

        //------------------------------
        // Dimension fetching methods
        //------------------------------

        ServantDataHandler.prototype.getMainWidth = function() {
            // Gets the width of the main body/main header
            return this.dimensions.mainWidth;
        };

        ServantDataHandler.prototype.getTotalHeight = function() {
            // Gets the height of the content block in the body.

            var totalHeight =
                this.data.metaData.displayedRows *
                this.dimensions.row.defaultHeight;

            return totalHeight;
        };

        ServantDataHandler.prototype.updateVarGroupOrder = function() {
            // Internally updates the order of parameters in varGroup

            var handler = this;

            function updateGroupOrder(group) {
                var minOrder = Infinity,
                    i;

                if (typeof group.parameters !== 'undefined') {
                    for (i = 0; i < group.parameters.length; i++) {
                        group.parameters[i].order =
                            handler.data.columns[group.parameters[i].ID].order;
                        group.parameters[i].displayOrder =
                            group.parameters[i].order;
                        minOrder = Math.min(
                            minOrder,
                            group.parameters[i].order
                        );
                    }
                }

                if (typeof group.groups !== 'undefined') {
                    for (i = 0; i < group.groups.length; i++) {
                        minOrder = Math.min(
                            minOrder,
                            updateGroupOrder(group.groups[i])
                        );
                    }
                }

                group.order = minOrder;
                group.displayOrder = group.order;

                return minOrder;
            }

            updateGroupOrder(handler.varGroupCopy);
        };

        ServantDataHandler.prototype.saveOrder = function() {
            // Saves group order to the server.

            this.updateVarGroupOrder();
            return this.externalInterface.execute('updateParameter', [
                this.varGroupCopy,
                { event: { iaEventUISource: 'dataHandler-saveOrder' } }
            ]);
        };

        ServantDataHandler.prototype.sanitizeGroupOrder = function() {
            // Makes sure that thre are no gaps in the order of the parameters
            // and that each group is ordered by its first  parameter or subgroup.
            // Also makes sure that all parameters have an order.

            var nextOrder = 0,
                parameters = [],
                displayOrders = [],
                ordersObject = {},
                groups = [];

            function unpackGroup(group) {
                group.order = nextOrder;
                var i;

                if (typeof group.parameters !== 'undefined') {
                    for (i = 0; i < group.parameters.length; i++) {
                        group.parameters[i].parentString =
                            group.parentString + group.displayName;
                        if (
                            typeof group.parameters[i].displayOrder !==
                            'undefined'
                        ) {
                            displayOrders.push(
                                group.parameters[i].displayOrder
                            );
                        }
                    }
                }

                parameters = parameters.concat(group.parameters || []);
                groups = groups.concat(group.groups || []);

                if (typeof group.groups !== 'undefined') {
                    for (i = 0; i < group.groups.length; i++) {
                        group.groups[i].parentString =
                            group.parentString + group.displayName;
                        unpackGroup(group.groups[i]);
                    }
                }
            }

            this.varGroupCopy.parentString = '';
            unpackGroup(this.varGroupCopy);

            displayOrders.sort(function(a, b) {
                return Number(a) - b;
            });
            displayOrders.forEach(function(d, i) {
                ordersObject[d] = i;
            });

            var orderedParameters = parameters.filter(function(d) {
                    return typeof d.displayOrder !== 'undefined';
                }),
                unorderedParameters = parameters.filter(function(d) {
                    return typeof d.displayOrder === 'undefined';
                });

            // Sort all unordered parameters by group name, then parameter name
            unorderedParameters.sort(function(a, b) {
                return (
                    a.parentString.localeCompare(b.parentString) ||
                    a.displayName.localeCompare(b.displayName)
                );
            });

            // Set order of all parameters with displayOrder and find out what
            // the last one is
            for (var i = 0; i < orderedParameters.length; i++) {
                orderedParameters[i].order =
                    ordersObject[orderedParameters[i].displayOrder];
                orderedParameters[i].displayOrder =
                    ordersObject[orderedParameters[i].displayOrder];
            }

            nextOrder = orderedParameters.length;

            for (i = 0; i < unorderedParameters.length; i++) {
                unorderedParameters[i].order = nextOrder;
                nextOrder++;
            }

            // Now make sure all groups are ordered by their first parameter
            function orderGroup(group) {
                var groupOrder = Infinity;

                var groupsLength = (group.groups && group.groups.length) || 0,
                    paramsLength =
                        (group.parameters && group.parameters.length) || 0;

                for (var i = 0; i < groupsLength; i++) {
                    groupOrder = Math.min(
                        orderGroup(group.groups[i]),
                        groupOrder
                    );
                }

                for (i = 0; i < paramsLength; i++) {
                    groupOrder = Math.min(
                        group.parameters[i].order,
                        groupOrder
                    );
                }

                group.order = groupOrder;

                return group.order;
            }

            orderGroup(this.varGroupCopy);

            // At this point, some or all of the parameters/columns may be
            // ordered, but we need to make sure that they all behave themselves.
            // sanitizeGroupOrder(this.varGroupCopy, 0);
        };

        //----------------------------------------
        //  SVG Data Methods
        //----------------------------------------

        ServantDataHandler.prototype.svgDataFunctions = {
            getPartition: function(widthObj) {
                // Gets a d3 partition object for setting up SVG header
                return d3.layout.
                    partition().
                    value(function(d) {
                        return widthObj.activeWidth[d.ID];
                    }).
                    sort(function(a, b) {
                        return a.order - b.order;
                    });
            },
            splitGroup: function(group) {
                // Split group into multiple groups for hierarchical display
                // purposes. Created  groups will all have continuously ordered
                // parameters.

                // For example, a group containing parameters with orders
                // [1,2,5,6,7] will  be split into groups [1,2] and [5,6,7].

                var i;

                var clones = [],
                    children = [];

                clones.push(
                    ServantDataHandler.prototype.svgDataFunctions.makeEmptyCopy(
                        group
                    )
                );

                var splitGroups = [];

                // First we need to process (i.e. split) all children.
                for (i = 0; i < group.groups.length; i++) {
                    splitGroups = ServantDataHandler.prototype.svgDataFunctions.splitGroup(
                        group.groups[i]
                    );

                    children = children.concat(splitGroups);
                }

                for (i = 0; i < group.parameters.length; i++) {
                    group.parameters[i].paramLength = 1;
                    children.push(group.parameters[i]);
                }

                children.sort(function(a, b) {
                    return b.order - a.order;
                });

                if (children.length) {
                    // At this point, the list "children" should be populated.
                    // Pop the elements out of it and use their indices to make
                    // some groups.
                    var childrenLength = children.length - 1;
                    var lastOrder = children[childrenLength].order; // initialize the order

                    var clonesLength = clones.length - 1;

                    var nextChild;

                    clones[clonesLength].ID += '-clone-' + clonesLength;

                    for (i = children.length; i > 0; i--) {
                        nextChild = children.pop();
                        if (nextChild.order === lastOrder) {
                            // Add to the current clone
                            clones[clonesLength].children.push(nextChild);
                            clones[clonesLength].paramLength +=
                                nextChild.paramLength;
                        } else {
                            // Make a new clone
                            clonesLength++;
                            clones.push(
                                ServantDataHandler.prototype.svgDataFunctions.makeEmptyCopy(
                                    group
                                )
                            );
                            clones[clonesLength].paramLength +=
                                nextChild.paramLength;
                            clones[clonesLength].order = nextChild.order;
                            clones[clonesLength].children = [nextChild];
                            clones[clonesLength].ID += '-clone-' + clonesLength;
                        }
                        childrenLength--;
                        lastOrder = nextChild.order + nextChild.paramLength;
                    }
                }

                return clones;
            },
            makeEmptyCopy: function(group) {
                // Creates an empty copy of a group.
                // This is used when splitting a group into multiple chunks of
                // continuously ordered parameters.
                var groupCopy = {};

                var key;

                for (key in group) {
                    if (group.hasOwnProperty(key) && key !== 'children') {
                        groupCopy[key] = group[key];
                    }
                }

                groupCopy.paramLength = 0;
                groupCopy.children = [];

                return groupCopy;
            }
        };

        ServantDataHandler.prototype.makeSVGHeaderData = function(widthObj) {
            // Takes widthObj as an input. widthObj is an object that records
            // the widths of each object, which will be used  as values for
            // creating the partition. These widths should be computed in the
            // creation of the parameter <span>s  and can then be used to create a
            // matching SVG header

            this.svgDataFunctions.partition = this.svgDataFunctions.getPartition(
                widthObj
            );

            var rootClones = this.svgDataFunctions.splitGroup(
                this.varGroupCopy
            );

            // var newSVGRoot = rootClones[0];

            // console.log(newSVGRoot);

            this.svgHeaderData.d3Data = rootClones[0];

            this.updateSVGHeaderData('d3');
        };

        ServantDataHandler.prototype.updateSVGHeaderData = function(source) {
            // Updates the data used for the SVG header. New data can come from
            // several different  sources, which determine what all needs to be
            // done to coerce the data into the right  form for d3 to work with.

            var handler = this;

            if (source !== 'd3' && source !== 'svg') {
                // d3 data must be generated from varGroup
                this.svgHeaderData.d3Data = this.makeD3GroupCopy(
                    this.varGroupCopy
                );
            }

            if (source !== 'svg') {
                // svg data must be partitioned to get x/dx/y/dy
                this.svgHeaderData.svgData = this.svgDataFunctions.partition(
                    this.svgHeaderData.d3Data
                );
            }

            this.svgHeaderData.dataDepth = 0;

            this.svgHeaderData.groupData = this.svgHeaderData.svgData.
                filter(function(d) {
                    return typeof d.children !== 'undefined' &&
                    d.children.length > 0
                        ? 1
                        : 0;
                }).
                sort(function(a, b) {
                    return a.depth - b.depth;
                });

            this.svgHeaderData.paramData = this.svgHeaderData.svgData.filter(
                function(d) {
                    return typeof d.children !== 'undefined' ? 0 : 1;
                }
            );

            this.svgHeaderData.svgData.forEach(function(d) {
                if (d.depth > handler.svgHeaderData.dataDepth) {
                    handler.svgHeaderData.dataDepth = d.depth;
                }
            });
        };

        ServantDataHandler.prototype.updateWidthValues = function(widthObj) {
            // Updates partition object based on new widths
            this.svgHeaderDataFunctions.partition.value(function(d) {
                return widthObj.activeWidth[d.ID];
            });
        };

        ServantDataHandler.prototype.updateColumnWidth = function(ID, width) {
            // Updates the width of a single column.

            this.data.columns[ID].offsetPosition.activeWidth = width;

            this.data.columns[ID].userSetWidth = true;

            // update other widths
            // TODO: more efficient way of doing this?
            // this.updateColumnPositions();
        };

        //--------------------------
        // Data sorting methods
        //--------------------------

        // All sorting is now on the servant. These methods control whether or
        // not sorting can happen, but probably aren't  used right now.

        ServantDataHandler.prototype.freezeSort = function() {
            this.sortFreeze = true;
        };

        ServantDataHandler.prototype.unfreezeSort = function() {
            this.sortFreeze = false;
            this.applyCurrentSorts();
        };

        //----------------------------------
        // Garbage Collecting Methods
        //----------------------------------
        // These only collect columns now.

        ServantDataHandler.prototype.flagGarbageCollect = function(dataType) {
            var i;

            if (dataType === 'mainColumn') {
                for (i = 0; i < this.data.columnKeys.length; i++) {
                    this.data.columns[this.data.columnKeys[i]].isOldData = true;
                }
            }
        };

        ServantDataHandler.prototype.collectGarbage = function(dataType) {
            var i;

            if (dataType === 'mainColumn') {
                // Garbage collect any flagged columns
                // Traverse from last to first so we don't change the order of
                // anything we haven't looked at
                for (i = this.data.columnKeys.length - 1; i >= 0; i--) {
                    if (
                        this.data.columns[this.data.columnKeys[i]].isOldData ===
                        true
                    ) {
                        // Garbage collect this column
                        delete this.data.columns[this.data.columnKeys[i]];
                        this.data.columnKeys.splice(i, 1);
                    }
                }
            }
        };

        //----------------------------------------------------------------
        // Data adding methods. These are used to define new columns/rows
        //----------------------------------------------------------------

        ServantDataHandler.prototype.getNewColName = function() {
            var colIndex = 0;

            var refObj = {};

            var key;

            for (key in this.data.columns) {
                if (this.data.columns.hasOwnProperty(key)) {
                    refObj[this.data.columns[key].displayName] = true;
                }
            }

            while (refObj['Parameter' + colIndex] === true) {
                colIndex++;
            }

            return 'Parameter' + colIndex;
        };

        ServantDataHandler.prototype.addEmptyColumn = function(columnID) {
            /* example columnData:
             * {
             *    columnName : 'foo', //Optional - we can auto-generate this.
             *    ID : 'aaa-bbb-ccc', //ID of this column (optional? get from
             * servant?) previousColId : 'aaa-bbb-ccc', //ID of last column
             * (optional)
             * }
             */

            // Add column -- handled by ImportVarGroup

            this.editableColumns[columnID] = true;
            this.updateColumn(columnID, { editable: 'true' });
        };

        ServantDataHandler.prototype.addFunctionColumn = function(
            fn,
            columnData,
            columnFixed
        ) {
            // Function will add to either main columns or fixedcolumns,
            // based on columnFixed attribute in data

            // This will add a column which will upate based on a
            // function.

            // This will not update real time, but rather every time that
            // getData is called.

            columnData.columnFn = fn;

            columnData.dataType = 'function';

            var id = columnData.id || columnData.ID;

            if (columnFixed) {
                this.updateFixedColumn(id, columnData);
            } else {
                this.updateColumn(id, columnData);
            }
        };

        ServantDataHandler.prototype.removeColumns = function(columns) {
            // Remove all cols from keys & remove all cols from data.columns

            var i;

            // Columns should always be an array of strings.
            // Also, let's assume that only parameters can be deleted from the
            // table.

            // This is inefficient right now and would be better replaced by
            // something  more elegant.

            // We can probably use the fact that our data is sorted to speed
            // this up as follows:
            //  1) Sort 'rows'
            //  2) Iterate backwards throught the array, removing elements one
            //  by one from both rows and rowKeys 3) Break when we're done
            //  iterating.

            // TODO: make this fast and elegant
            this.data.columnKeys = this.data.columnKeys.filter(function(d) {
                return columns.indexOf(d) > -1 ? 0 : 1;
            });

            for (i = 0; i < columns.length; i++) {
                // Remove from columns
                delete this.data.columns[columns[i]];
                // Also remove from sorts if this exists in the sorts
                this.removeSort(columns[i]);
            }
        };

        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////

        // New data methods. These all rely on the servant to get data for what
        // is currently visible.

        ServantDataHandler.prototype.getNewRows = function(rowIndices) {
            // This function will return the rows that lie at specific indices
            // in the table.  Data will be returned in a JSON that looks like
            // this:

            //{<rowIDs> : { metaData : {<keys> : <values} : fixedData : {<keys>
            //: <values>}, mainData : {<keys> : <values>} } }

            var that = this;

            var parameterIDs = this.data.columnKeys.
                slice(this.startColumnIndex, this.endColumnIndex + 1).
                filter(function(d) {
                    return that.data.columns[d].structure !== 'ARRAY';
                });

            return this.dataTableProxy.getNewRows(rowIndices, parameterIDs);
        };

        ServantDataHandler.prototype.getNewColumns = function(parameterIDs) {
            // This function will return the specified columns.
            // Data will be returned in a JSON that looks like this:

            //{ rowData : {<rowIDs> : { mainData : {<keys> : <values>} } },
            //columnData : {<columnIDs> : { metaData : {<keys> : <values>} } } }
            //

            var that = this;

            parameterIDs = parameterIDs.filter(function(d) {
                return that.data.columns[d].structure !== 'ARRAY';
            });

            var rowIndices = [];
            var nextIndex = this.startRowIndex;

            rowIndices.push(this.startRowIndex);

            while (++nextIndex <= this.endRowIndex) {
                rowIndices.push(nextIndex);
            }

            return this.dataTableProxy.getNewColumns(rowIndices, parameterIDs);
        };

        ServantDataHandler.prototype.getData = function(
            rowIndices,
            parameterIds
        ) {
            return this.dataTableProxy.getNewRows(rowIndices, parameterIds);
        };

        ServantDataHandler.prototype.getDerivedFixedColumns = function() {
            var derivedFixedColumns = {};

            for (var key in this.data.fixedColumns) {
                if (this.data.fixedColumns[key].dataType === 'function') {
                    derivedFixedColumns[key] = this.data.fixedColumns[key];
                }
            }

            return derivedFixedColumns;
        };

        ServantDataHandler.prototype.getFixedColumns = function() {
            var derivedColumns = {};

            for (var key in this.data.columns) {
                if (typeof this.data.columns[key].columnFn === 'function') {
                    derivedColumns[key] = this.data.columns[key];
                }
            }

            return derivedColumns;
        };

        ServantDataHandler.prototype.getAllData = function() {
            // This function will return all of the data about the table.
            // Data will be returned in a JSON that looks like this:

            //{ rowData : {<rowIDs> : { metaData : {<keys> : <values} :
            //fixedData : {<keys> : <values>}, mainData : {<keys> : <values>} }
            //},
            //  columnData : {<columnIDs> : { metaData : {<keys> : <values>} } }
            //  fixedColumnData : {<columnIDs> : { metaData : {<keys> :
            //  <values>} } } tableData : {totalRows : <total # of rows>,
            //  totalColumns : <total # of columns>}  }

            var that = this;

            var parameterIDs = this.data.columnKeys.
                slice(this.startColumnIndex, this.endColumnIndex + 1).
                filter(function(d) {
                    return that.data.columns[d].structure !== 'ARRAY';
                });

            var rowIndices = [];
            var nextIndex = this.startRowIndex;

            rowIndices.push(this.startRowIndex);

            while (++nextIndex <= this.endRowIndex) {
                rowIndices.push(nextIndex);
            }

            return this.dataTableProxy.getTableData(rowIndices, parameterIDs);
        };

        ServantDataHandler.prototype.sortByParam = function(paramId) {
            // Calls the servant to sort by a given parameter, and also passes a
            // request for what data  the servant should return for display when
            // it finishes sorting.

            var isFixed;
            var that = this;

            if (this.data.columns[paramId]) {
                isFixed = 'false';
            } else if (this.data.fixedColumns[paramId]) {
                isFixed = 'true';
            } else {
                throw 'Could not locate the requested parameter for sorting!';
            }

            var newSort = { reverseSort: 'false', id: paramId, fixed: isFixed };

            var reverseSort = 'false';

            for (var i = 0; i < this.currentSorts.length; i++) {
                if (this.currentSorts[i].id === paramId) {
                    newSort.reverseSort =
                        this.currentSorts[i].reverseSort === 'false'
                            ? 'true'
                            : 'false';
                    this.currentSorts.splice(i, 1); // Remove the sort from the
                    // current list. Mirrored on
                    // server.
                    break;
                }
            }

            this.currentSorts.unshift(newSort);

            // Compute paramIDs and indices for new rows
            var paramIds = [],
                rowIndices = [];

            for (i = this.startColumnIndex; i <= this.endColumnIndex; i++) {
                paramIds.push(this.data.columnKeys[i]);
            }

            paramIds = paramIds.filter(function(d) {
                return that.data.columns[d].structure !== 'ARRAY';
            });

            for (i = this.startRowIndex; i <= this.endRowIndex; i++) {
                rowIndices.push(i);
            }

            // Make call to server and return deferred
            return this.dataTableProxy.sortTableByParameter(
                newSort.id,
                newSort.fixed,
                newSort.reverseSort,
                paramIds,
                rowIndices
            );
        };

        ServantDataHandler.prototype.editCellsByIndex = function(dataObject) {
            // Edit certain cells.

            return this.dataTableProxy.setDataValuesFromIndex(dataObject);
        };

        return ServantDataHandler;
    }
);

/* global d3 */
/* global define */

define(
    'DS/SMAAnalyticsDataTable/SMAAnalyticsDataTableHeader',
    ['DS/SMAAnalyticsDataTable/SMAAnalyticsDataTableSVGHeader'],
    function(SVGHeader) {
        'use strict';
        function DataTableHeader(table) {
            // Table is the control object for the entire table.

            // Element variables

            // Root element
            var rootDiv = table.containerDivs.header,
                // Elements for control div
                headerControlDiv = document.createElement('div'),
                expandButton = document.createElement('div'),
                // Elements for SVG
                svgContentRoot = document.createElement('div'),
                svgContentFrame = document.createElement('div'),
                // Table header row
                tableHeader = document.createElement('div'),
                // Fixed header
                fixedHeaderDiv = document.createElement('div'),
                // Main header
                mainHeaderDiv = document.createElement('div'),
                parameterContainerDiv = document.createElement('div');

            this.containerDivs = {
                // Holds references to all container divs
                headerRoot: rootDiv,
                headerControl: headerControlDiv,
                svgContainer: svgContentRoot,
                svgContentFrame: svgContentFrame,
                tableHeader: tableHeader,
                fixedHeader: fixedHeaderDiv,
                mainHeader: mainHeaderDiv,
                parameterContainerDiv: parameterContainerDiv
            };

            this.parent = table;

            this.controlElements = {
                // Holds references to icons and other elements used for control
                expandButton: expandButton
            };

            // Other variables
            var // i,
            that = this; // Map this to variable for access from within functions

            // Object attributes
            this.dimensions = {
                fixedHeader: {},
                mainHeader: {
                    totalWidth: 0,
                    outerWidth: {},
                    innerWidth: {},
                    activeWidth: {},
                    left: {}
                },
                headerHeight: 0
            };

            this.controlObjects = {
                table: table // References the parent control object
            }; // This will hold control objects for the components of the
            // header

            // Update header margin to account for scroll bar width
            this.dimensions.scrollWidth = DataTableHeader.prototype.getScrollWidth();

            // JS assignment of style doesn't work in firefox. Use D3 wrapper
            // instead.
            this.containerDivs.headerRoot.style.paddingRight =
                this.dimensions.scrollWidth + 'px';
            // d3.select(this.containerDivs.headerRoot)
            //  .style('padding-right', this.dimensions.scrollWidth + 'px');

            // Create SVG content holder
            svgContentRoot.className += 'dataTable-header-SVGRootDiv';
            svgContentRoot.appendChild(svgContentFrame);

            rootDiv.appendChild(svgContentRoot);

            svgContentFrame.className += 'dataTable-header-SVGContentFrame';

            // Create table header row
            tableHeader.className += 'dataTable-header-tableHeader';
            rootDiv.appendChild(tableHeader);

            // Create fixed header
            fixedHeaderDiv.className += 'dataTable-header-fixedHeaderDiv';
            tableHeader.appendChild(fixedHeaderDiv);

            this.updateFixedHeader();
            this.updatingHeaderWidths = false; // Used to throttle header updates.

            // Create parameter divs.
            tableHeader.appendChild(mainHeaderDiv);

            mainHeaderDiv.className += 'dataTable-header-mainHeaderDiv ';
            mainHeaderDiv.appendChild(parameterContainerDiv);

            this.containerDivs.parameterContainerDiv.className +=
                'dataTable-header-paramContainerDiv ';

            // Create top header bar //Removed until we need it...
            // Switched position to side.
            headerControlDiv.className += 'dataTable-header-controlDiv ';
            headerControlDiv.appendChild(expandButton);

            expandButton.className += 'dataTable-headerControls-expandSVG ';
            expandButton.className += 'ui-icon ui-icon-plusthick';

            rootDiv.appendChild(headerControlDiv);

            // Dimension main header div
            d3.select(mainHeaderDiv).style({
                position: 'absolute',
                left: that.dimensions.fixedHeader.width + 'px',
                top: '0px',
                right: '0px',
                height: that.dimensions.fixedHeader.height + 'px'
            });

            // Dimension control div
            d3.select(headerControlDiv).style({
                height: that.dimensions.fixedHeader.height + 'px',
                right: '0px',
                width: this.dimensions.scrollWidth + 'px'
            });

            // Dimension table header
            d3.select(tableHeader).style({
                height: that.dimensions.fixedHeader.height + 'px'
            });

            this.updateMainHeader();

            // Dimension svg holder
            d3.select(svgContentFrame).style({
                position: 'relative',
                'margin-left': that.dimensions.fixedHeader.width + 'px'
            });

            this.getDataHandler().makeSVGHeaderData(this.getWidthObject());

            this.controlObjects.svgHeaderController = new SVGHeader(this);

            // this.controlObjects.expansionController = new
            // ExpansionController(this);

            this.dimensions.headerHeight = this.containerDivs.headerRoot.offsetHeight;

            this.createControls();

            this.updateControls();
        }

        DataTableHeader.prototype.getScrollWidth = function() {
            // Gets the width of the scroll bar for positioning the header.

            // FIXME: refactor into a common utils module
            // same as AdviseUtils.getScrollWidth

            var scrollTestDiv = document.createElement('div');

            document.body.appendChild(scrollTestDiv);

            scrollTestDiv.style.position = 'absolute';
            scrollTestDiv.style.width = '100px';
            scrollTestDiv.style.height = '100px';
            scrollTestDiv.style.overflow = 'scroll';
            scrollTestDiv.style.top = '-9999px';

            var scrollWidth =
                scrollTestDiv.offsetWidth - scrollTestDiv.clientWidth;
            document.body.removeChild(scrollTestDiv);

            return scrollWidth;
        };

        DataTableHeader.prototype.getDataHandler = function() {
            // Helper method for getting data handler.
            // TODO: Replace this with an attribute on the header object (i.e.
            // this.dataHandler = dataHandler during init.)

            return this.controlObjects.table.dataHandler;
        };

        DataTableHeader.prototype.updateMainHeader = function(instant) {
            // This updates the header data and adjsts the DOM to match.

            this.dimensions.mainHeader.availableWidth = this.containerDivs.mainHeader.getBoundingClientRect().width;

            var spans,
                newSpans,
                that = this;

            spans = d3.
                select(this.containerDivs.parameterContainerDiv).
                selectAll('span').
                data(this.getDataHandler().getMainHeaderData(), function(d) {
                    return d.ID;
                });

            spans.exit().remove();

            newSpans = spans.
                enter().
                append('span').
                classed('dataTable-header-fixedPositionSpan', true).
                on('click', function(d) {
                    that.parent.eventController('sortByParam', d.ID);
                }).
                each(function(d) {
                    if (typeof d.offsetPosition === 'undefined') {
                        d.offsetPosition = {};
                        d.offsetPosition.outerWidth = Math.max(
                            d.offsetPosition.outerWidth || this.offsetWidth,
                            100
                        );
                        d.offsetPosition.activeWidth =
                            d.offsetPosition.activeWidth ||
                            d.offsetPosition.outerWidth;
                        d.offsetPosition.innerWidth =
                            d.offsetPosition.innerWidth ||
                            parseInt(window.getComputedStyle(this).width, 10);
                    }

                    that.dimensions.mainHeader.totalWidth +=
                        d.offsetPosition.outerWidth;
                });

            spans.text(function(d) {
                return d.displayName;
            });

            that.containerDivs.mainSpans = spans;

            // Enlarge widths to fit screen (if necessary)
            this.fitWidths();

            // Make sure keys are ordered
            // Keys should be ordered in the data handler
            // this.orderKeys(); <-- DOESN'T EXIST.

            // Update all widths to fit computed widths
            // Also updates size of container
            this.updateWidths(instant);

            // Update all positions based on order
            this.updatePositions(instant);

            this.updateWidthData();
        };

        DataTableHeader.prototype.updateWidths = function(instant) {
            // Computes and updates all header widths based on their data.
            // These widths are used for cells in the body.

            var spans = instant
                    ? this.containerDivs.mainSpans
                    : this.containerDivs.mainSpans.transition(),
                that = this,
                totalWidth = 0;

            var cssEditor = this.parent.cssEditor;

            spans.each(function(d) {
                d3.
                    select(this).
                    style('width', d.offsetPosition.activeWidth + 'px');
                totalWidth += d.offsetPosition.activeWidth;

                // Use css editor to update rules for widths
                cssEditor.addStyle(
                    '.bodyColumn' + d.ID,
                    'width',
                    d.offsetPosition.activeWidth + 'px'
                );
            });

            this.dimensions.mainHeader.totalWidth = totalWidth;

            this.getDataHandler().dimensions.mainWidth = totalWidth;

            d3.
                select(that.containerDivs.parameterContainerDiv).
                style('width', that.dimensions.mainHeader.totalWidth + 'px');
        };

        DataTableHeader.prototype.updatePositions = function(instant) {
            // Computes and updates all header positions based on their data.
            // Widths must be computed before positions.
            // These positions are used for cells in the body.

            var spans = this.containerDivs.mainSpans;

            spans.order();

            var nextLeft = 0;

            var cssEditor = this.parent.cssEditor;

            spans.each(function(d) {
                d.offsetPosition.left = nextLeft;
                nextLeft += d.offsetPosition.activeWidth;

                // Use css editor to update lefts for body columns
                cssEditor.addStyle(
                    '.bodyColumn' + d.ID,
                    'left',
                    d.offsetPosition.left + 'px'
                );
            });

            this.dimensions.mainHeader.totalWidth = nextLeft;

            if (!instant) {
                spans = this.containerDivs.mainSpans.transition();
            }

            spans.style('left', function(d) {
                return d.offsetPosition.left + 'px';
            });
        };

        DataTableHeader.prototype.updateWidthData = function() {
            // Pushes all header positioning data to the storage objects on the
            // data handler.  Ideally, we'd only modify the data in one place.

            var that = this;

            this.containerDivs.mainSpans.each(function(d) {
                that.
                    getDataHandler().
                    updateColumn(d.ID, { offsetPosition: d.offsetPosition });
            });
        };

        DataTableHeader.prototype.fitWidths = function() {
            // Compute widths needed to fit screen

            var spans = this.containerDivs.mainSpans, // Go be reference to preserve order
                that = this;

            var widths = [],
                userWidths = 0,
                totalOuterWidth = 0;

            spans.each(function(d) {
                var thisData = that.getDataHandler().data.columns[d.ID];

                if (thisData.userSetWidth === true) {
                    userWidths += thisData.offsetPosition.activeWidth;
                    // d.activeWidth = thisData.activeWidth;
                    // d.userSetWidth = true;
                } else {
                    widths.push(d.offsetPosition.outerWidth);
                    totalOuterWidth += d.offsetPosition.outerWidth;
                }
            });

            // totalOuterWidth += userWidths;

            var freeWidths = widths.length;

            var availableWidth =
                that.dimensions.mainHeader.availableWidth - userWidths;

            var fractionWidth = availableWidth / freeWidths,
                extraWidth = 0;

            if (totalOuterWidth < availableWidth) {
                // We want to expand columns to fit available width
                widths.sort(function(a, b) {
                    return Number(b) - a;
                });

                // Loop through widths and expand.
                while (widths[0] > fractionWidth) {
                    // Next width is too large. Reduce fractionWidth and proceed
                    // to the next index.
                    extraWidth += widths.shift();
                    fractionWidth =
                        (availableWidth - extraWidth) / widths.length;
                }

                // Update widths to account for new fractionWidths
                spans.each(function(d) {
                    if (
                        d.userSetWidth !== true &&
                        d.offsetPosition.outerWidth < fractionWidth
                    ) {
                        // Update active widths of columns with widths less than
                        // the active width
                        d.offsetPosition.activeWidth = fractionWidth;
                    } else if (d.userSetWidth !== true) {
                        d.offsetPosition.activeWidth =
                            d.offsetPosition.outerWidth;
                    }
                });
            } else {
                spans.each(function(d) {
                    if (d.userSetWidth !== true) {
                        // Update active widths of columns with widths less than
                        // the active width
                        d.offsetPosition.activeWidth =
                            d.offsetPosition.outerWidth;
                    }
                });
            }
        };

        DataTableHeader.prototype.updateFixedHeader = function() {
            // This populates the fixed header with data and builds it.
            // This should be called before the main header is created, since
            // the positioning for the main  header cells is based on the size of
            // the fixed header.

            var that = this;

            var nextLeft = 0;

            var headerCells = d3.
                select(this.containerDivs.fixedHeader).
                selectAll('span').
                data(this.getDataHandler().getFixedHeaderData()).
                enter().
                append('span');

            var cssEditor = this.parent.cssEditor;

            headerCells.
                text(function(d) {
                    return d.displayName;
                }).
                each(function(d) {
                    // Update the data handler to store column dimensions

                    that.parent.dataHandler.updateFixedColumn(d.id, {
                        outerWidth: this.offsetWidth,
                        activeWidth: this.offsetWidth,
                        innerWidth: parseInt(
                            window.getComputedStyle(this).width,
                            10
                        ),
                        left: nextLeft
                    });

                    cssEditor.addStyle(
                        '.bodyColumn' + d.id,
                        'width',
                        this.offsetWidth + 'px'
                    );
                    cssEditor.addStyle(
                        '.bodyColumn' + d.id,
                        'left',
                        nextLeft + 'px'
                    );

                    nextLeft += this.offsetWidth;
                }).
                on('click', function(d) {
                    that.parent.eventController('sortByParam', d.id);
                });

            headerCells.
                filter(function(d) {
                    return typeof d.headerClass !== 'undefined';
                }).
                each(function(d) {
                    var thisClass = d.headerClass;
                    d3.select(this).classed(thisClass, true);
                });

            // Clear styling before measuring size of fixedHeader
            d3.
                select(this.containerDivs.fixedHeader).
                style({ width: '', height: '' });

            // In IE, setting the header exactly can cause the last div to drop
            // to the next line. Pad by one pixel.
            this.dimensions.fixedHeader.width =
                this.containerDivs.fixedHeader.getBoundingClientRect().width +
                1;
            this.dimensions.fixedHeader.height = this.containerDivs.fixedHeader.getBoundingClientRect().height;
            // FIXME HACK
            if (this.dimensions.fixedHeader.height > 20) {
                this.dimensions.fixedHeader.height = 20;
            }

            d3.select(this.containerDivs.fixedHeader).style({
                position: 'absolute',
                left: '0px',
                top: '0px',
                width: that.dimensions.fixedHeader.width + 'px',
                height: that.dimensions.fixedHeader.height + 'px'
            });

            this.dimensions.headerHeight = this.containerDivs.headerRoot.offsetHeight;

            this.updateDragHandlers();
        };

        DataTableHeader.prototype.quickUpdateFixedColumnWidth = function(
            colId,
            colWidth
        ) {
            var that = this;

            var nextLeft = 0;

            var cssEditor = this.parent.cssEditor;

            var setWidth = false;

            var startWidth;

            d3.
                select(this.containerDivs.fixedHeader).
                selectAll('span').
                each(function(d) {
                    // Update the data handler to store column dimensions

                    if (d.id === colId) {
                        startWidth = Number(d.outerWidth);

                        d3.select(this).style({ width: colWidth + 'px' });
                        cssEditor.addStyle(
                            '.bodyColumn' + d.id,
                            'width',
                            colWidth + 'px'
                        );
                        setWidth = true;
                        nextLeft += colWidth;
                    } else if (setWidth === true) {
                        cssEditor.addStyle(
                            '.bodyColumn' + d.id,
                            'left',
                            nextLeft + 'px'
                        );
                        nextLeft += d.outerWidth;
                    } else {
                        nextLeft += d.outerWidth;
                    }
                });

            var widthChange = colWidth - startWidth;

            var newFixedHeaderWidth =
                this.dimensions.fixedHeader.width + widthChange;

            d3.select(this.containerDivs.fixedHeader).style({
                width: newFixedHeaderWidth + 'px'
            });

            d3.select(this.containerDivs.mainHeader).style({
                left: newFixedHeaderWidth + 'px'
            });

            // Update width of fixed body content.
            this.parent.updateBodySize();
        };

        DataTableHeader.prototype.updateFixedColumnWidth = function() {
            var that = this;
            var nextLeft = 0;
            var headerCells = d3.
                select(this.containerDivs.fixedHeader).
                selectAll('span');
            var cssEditor = this.parent.cssEditor;

            headerCells.
                text(function(d) {
                    return d.displayName;
                }).
                each(function(d) {
                    // Update the data handler to store column dimensions

                    that.parent.dataHandler.updateFixedColumn(d.id, {
                        outerWidth: this.offsetWidth,
                        activeWidth: this.offsetWidth,
                        innerWidth: parseInt(
                            window.getComputedStyle(this).width,
                            10
                        ),
                        left: nextLeft
                    });

                    cssEditor.addStyle(
                        '.bodyColumn' + d.id,
                        'width',
                        this.offsetWidth + 'px'
                    );
                    cssEditor.addStyle(
                        '.bodyColumn' + d.id,
                        'left',
                        nextLeft + 'px'
                    );

                    nextLeft += this.offsetWidth;
                });

            // Clear styling before measuring size of fixedHeader
            d3.select(this.containerDivs.fixedHeader).style({ width: '' });

            this.dimensions.fixedHeader.width =
                this.containerDivs.fixedHeader.getBoundingClientRect().width +
                1;

            d3.select(this.containerDivs.fixedHeader).style({
                width: that.dimensions.fixedHeader.width + 'px'
            });

            this.dimensions.headerHeight = this.containerDivs.headerRoot.offsetHeight;

            this.parent.updateBodySize();
            this.updateDragHandlers();
        };

        DataTableHeader.prototype.updateDragHandlers = function() {
            var handleWidth = 8;
            var leftOffset = handleWidth / 2;

            var that = this;

            var cells = d3.
                select(this.containerDivs.fixedHeader).
                selectAll('span')[0];

            var fixedData = this.getDataHandler().
                getFixedHeaderData().
                map(function(d, i) {
                    return { data: d, headerCell: cells[i] };
                });

            var startEventX = 0,
                startX = 0,
                lastX = 0,
                startWidth = 0,
                thisSpan,
                spanData;

            var dragStart = function(d) {
                // We need to save the current position to use while calculating
                // positions for the rest of the drag.
                console.log('dragStart');
                console.log(d3.event);

                // d3.event.preventDefault();

                startEventX;

                // if(typeof d3.event.x !== 'undefined'){
                //  startEventX = d3.event.x;
                //} else {
                startEventX = d3.event.clientX;
                //}
                startX = d.data.left + d.data.outerWidth - leftOffset;
                lastX = startX;
                startWidth = d.headerCell.offsetWidth;
                // startY = d3.event.y;

                thisSpan = this;
                spanData = d;

                // Set up event listeners for manually handling drag
                document.addEventListener('mousemove', drag, false);
                document.addEventListener('mouseup', dragEnd, false);
            };

            var drag = function(e) {
                e.preventDefault();
                e.stopPropagation();

                // d3.event.stopPropagation();

                // console.log('dx = ' + (d3.event.x - startX));
                // console.log(d3.event);

                if (that.updatingHeaderWidths === false) {
                    that.updatingHeaderWidths = true;

                    var x;
                    // if(typeof e.x !== 'undefined'){
                    //  x = e.x;
                    //} else {
                    x = e.clientX;
                    //}

                    var startX = Number(startEventX);
                    var startW = Number(startWidth);

                    window.setTimeout(function() {
                        if (Math.abs(lastX - x) < 50) {
                            var dx = x - startX;

                            d3.
                                select(thisSpan).
                                style({ left: startX + dx + 'px' });

                            /*d3.select(d.headerCell).style({
                                'width' : (startWidth + dx) + 'px'
                            });

                            that.updateFixedPositions();*/
                            // console.log('clientX: ' + e.clientX);
                            // console.log('startX: ' + startX);
                            // console.log('x: ' + e.x);
                            // console.log('target update width: ' + (startX +
                            // dx));

                            that.quickUpdateFixedColumnWidth(
                                spanData.data.id,
                                startW + dx
                            );
                        }

                        lastX = x;
                        that.updatingHeaderWidths = false;
                    }, 0);
                }

                return false;
            };

            var dragEnd = function(e) {
                // console.log('drag ended!');

                that.updateFixedColumnWidth();
                that.updateSVGHeader();
                // that.updateFixedHeader();

                document.removeEventListener('mousemove', drag, false);
                document.removeEventListener('mouseup', dragEnd);
            };

            var setupResizeDiv = function(d) {
                // d is the data element
                // this.classList.add('headerResizeDiv');
                d3.select(this).style({
                    position: 'absolute',
                    top: '0px',
                    bottom: '0px',
                    width: handleWidth + 'px',
                    //'background' : 'steelblue',
                    cursor: 'ew-resize'
                });
            };

            var updateResizeDiv = function(d) {
                d3.select(this).style({
                    left: d.data.left + d.data.outerWidth - leftOffset + 'px'
                });
            };

            var divContainer = d3.select(this.containerDivs.fixedHeader);

            divContainer.
                selectAll('.headerResizeDiv').
                data(fixedData).
                enter().
                append('div').
                classed('headerResizeDiv', true).
                each(setupResizeDiv).
                on('mousedown', dragStart);
            //.on('drag', drag)
            //.on('dragend', dragEnd);

            divContainer.selectAll('.headerResizeDiv').each(updateResizeDiv);
        };

        DataTableHeader.prototype.createControls = function() {
            // This creates the expand/collapse control for toggling the
            // hierarchical svg header on and off.

            var that = this;

            d3.
                select(this.controlElements.expandButton).
                on('click', function() {
                    if (that.getDataHandler().svgHeaderData.dataDepth > 1) {
                        that.expandHeader();
                    }
                });
        };

        DataTableHeader.prototype.expandHeader = function() {
            // Expands the hierarchical header and also fires an event to adjust
            // the body to fit below it.

            var controller = this.controlElements.expandButton;

            if (controller.classList.contains('ui-icon-plusthick') === false) {
                d3.select(controller).classed('ui-icon-plusthick', true);
                d3.select(controller).classed('ui-icon-minusthick', false);
            } else {
                d3.select(controller).classed('ui-icon-plusthick', false);
                d3.select(controller).classed('ui-icon-minusthick', true);
            }

            this.parent.eventController('toggleExpandHeader');
        };

        DataTableHeader.prototype.updateDimensions = function() {
            // Updates header dimensions.
            // TODO: This is probably unnecessary.

            this.dimensions.headerHeight = this.containerDivs.headerRoot.offsetHeight;
            this.dimensions.fixedWidth = this.dimensions.fixedHeader.width;
        };

        DataTableHeader.prototype.setMainHeaderScroll = function(scrollLeft) {
            // This is used to programatically scroll the header based on the
            // scroll position of the body.

            // Scroll main header
            this.containerDivs.mainHeader.scrollLeft = scrollLeft;

            // Scroll SVG header
            this.controlObjects.svgHeaderController.containerDivs.frame.scrollLeft = scrollLeft;
        };

        DataTableHeader.prototype.updateHeader = function(instant) {
            // This function should run when the header needs to be updated. It
            // will involve rebuilding the data, then re-rendering the header.
            this.updateFixedHeader();

            this.updateMainHeader(instant);

            // TODO: move this to SMAAnalyticsDataTable.js in order to eliminate
            // reference to SVGHeaderData
            this.getDataHandler().makeSVGHeaderData(this.getWidthObject());

            this.dimensions.headerHeight = this.containerDivs.headerRoot.offsetHeight;

            this.updateSVGHeader();

            this.updateControls();
        };

        DataTableHeader.prototype.updateControls = function() {
            // Updates the controls in the header. For now, this just adds or
            // removes a disabling class  on the hierarchical header expansion
            // control.

            var that = this;

            var groupsTest =
                that.getDataHandler().svgHeaderData.dataDepth > 1 ? 0 : 1;
            if (groupsTest > 0) {
                this.controlElements.expandButton.classList.add('noGroups');
            } else {
                this.controlElements.expandButton.classList.remove('noGroups');
            }
            /*
            d3.select(this.controlElements.expandButton)
                .classed('noGroups', function(){
                    return that.getDataHandler().svgHeaderData.dataDepth > 1 ? 0
            : 1;
                });
            */
        };

        DataTableHeader.prototype.updateSVGHeader = function() {
            // Updates the SVG header

            // Dimension svg holder
            d3.select(this.containerDivs.svgContentFrame).style({
                'margin-left': this.dimensions.fixedHeader.width + 'px'
            });

            if (
                typeof this.controlObjects.svgHeaderController !== 'undefined'
            ) {
                this.controlObjects.svgHeaderController.updateSVGHeader();
            }
        };

        DataTableHeader.prototype.getWidthObject = function() {
            // Returns an object describing the widths of each position
            // structured for use by the d3 partition function
            var widthObject = { activeWidth: {} };

            this.containerDivs.mainSpans.each(function(d) {
                widthObject.activeWidth[d.ID] = d.offsetPosition.activeWidth;
            });

            return widthObject;
        };

        DataTableHeader.prototype.updateSortClasses = function() {
            // Updates the classes of header cells for sorted columns to allow
            // styling

            function updateSortClass(d) {
                /*jshint validthis: true */
                d3.
                    select(this).
                    classed('firstSort secondSort thirdSort', false).
                    classed('sortUp sortDown', false);

                var sortPosition = that.
                    getDataHandler().
                    sortOrder.indexOf(d.ID);
                var sortDirection =
                    that.getDataHandler().currentSorts[d.ID] === 1
                        ? 'sortUp '
                        : 'sortDown ';

                if (sortPosition !== -1) {
                    d3.
                        select(this).
                        classed(
                            sortDirection + sortClasses[sortPosition],
                            true
                        );
                }
            }

            var that = this,
                sortClasses = ['firstSort', 'secondSort', 'thirdSort'];

            d3.
                select(this.containerDivs.fixedHeader).
                selectAll('span').
                each(updateSortClass);

            d3.
                select(this.containerDivs.mainHeader).
                selectAll('span').
                each(updateSortClass);
        };

        return DataTableHeader;
    }
);

/* global console */
/* global define */

define(
    'DS/SMAAnalyticsDataTable/SMAAnalyticsDataTable2',
    [
        'DS/SMAAnalyticsDataTable/SMAAnalyticsDataTableHeader',
        'DS/SMAAnalyticsDataTable/SMAAnalyticsBodyForServant',
        'DS/SMAAnalyticsUtils/SMAAnalyticsParseUtils'
    ],
    function(DataTableHeader, DataTableBody, ParseUtils) {
        'use strict';
        function ShopDataTable(options, externalInterface) {
            // This is a modified version of dataTable that uses a modified data
            // table body changed for  use with the servant data table handler.

            // dataHandler is a data handler object that manages all data
            // containerDiv is the div that the table should be generated in
            // options specifies various options for the table.
            if (!options) {
                options = {};
            }

            // Initialize and set variables
            this.initializeOptions(options);

            this.controlObjects = {};

            this.dimensions = {
                totalHeight: 0,
                totalWidth: 0,
                columnWidths: [],
                rowHeights: []
            };

            this.externalInterface = externalInterface; // Interface is a reserved word.

            this.externalInterface.bindBridge(this);

            this.sortFrozen = false;

            this.editMode = true;
        }

        /////////////////////////
        // Table Setup Methods //
        /////////////////////////

        ShopDataTable.prototype.setCssEditor = function(editor) {
            this.cssEditor = editor;
        };

        ShopDataTable.prototype.setContainer = function(container) {
            this.containerDivs = { main: container };

            // Build body div
            this.containerDivs.body = document.createElement('div');
            this.containerDivs.body.className += 'dataTable-body ';
            this.containerDivs.main.appendChild(this.containerDivs.body);

            // Build header div
            this.containerDivs.header = document.createElement('div');
            this.containerDivs.header.className += 'dataTable-header ';
            this.containerDivs.main.appendChild(this.containerDivs.header);

            this.dimensions.totalWidth = container.offsetWidth;
            this.dimensions.totalHeight = container.offsetHeight;
        };

        ShopDataTable.prototype.setDataHandler = function(dataHandler) {
            this.dataHandler = dataHandler;
        };

        ShopDataTable.prototype.setOptions = function(options) {
            this.initializeOptions(options);
        };

        ShopDataTable.prototype.initializeOptions = function(options) {
            this.options = {
                fixedColumns: options.fixedColumns || 0,
                pareto_color: options.pareto_color,
                feasible_color: options.feasible_color,
                infeasible_color: options.infeasible_color,
                excluded_color: options.excluded_color
            };
        };

        ////////////////////////////////////
        // Content Initialization Methods //
        ////////////////////////////////////

        ShopDataTable.prototype.initializeHeader = function() {
            // Build data table head

            // Create div contents
            this.controlObjects.header = new DataTableHeader(this);
        };

        ShopDataTable.prototype.initializeBody = function(dependencies) {
            // Build data table body

            // Create div content
            this.controlObjects.body = new DataTableBody(this, dependencies);
            // sd4 - allow users to provide the colors
            //(feasible, infeasible, pareto, excluded )
            this.controlObjects.body.setColors(
                this.options.feasible_color,
                this.options.infeasible_color,
                this.options.pareto_color,
                this.options.excluded_color
            );
        };

        ////////////////////////////
        // Content Update Methods //
        ////////////////////////////

        ShopDataTable.prototype.updateHeader = function(instant) {
            if (typeof this.controlObjects.header !== 'undefined') {
                this.controlObjects.header.updateHeader(instant);
            } else {
                console.log('WARNING! Header not initialized. Update skipped.');
                // this.initializeHeader();
            }
        };

        ShopDataTable.prototype.updateBody = function() {
            if (typeof this.controlObjects.body !== 'undefined') {
                this.controlObjects.body.refreshBody();
            } else {
                console.log('WARNING! Body not initialized. Update skipped.');
                // this.initializeHeader();
            }
        };

        ShopDataTable.prototype.updateBodySize = function() {
            // Controls resizing for the body.

            this.controlObjects.body.updateFixedWidth();
            this.controlObjects.body.updateBodySize();
        };

        ShopDataTable.prototype.refreshTable = function(args) {
            // Fully refreshes the table, clearing out and restoring its data.

            // Build header
            this.updateHeader(args.instant);

            // Update sorting and positions
            this.dataHandler.updateColumnPositions();
            this.controlObjects.header.updateDimensions();

            // Build body
            this.updateBody();
        };

        ShopDataTable.prototype.startEditMode = function() {
            this.editMode = true;

            // this.controlObjects.body.startEditMode();

            this.freezeSort();
            this.startEditCallback();
        };

        ShopDataTable.prototype.leaveEditMode = function() {
            this.editMode = false;
            this.unfreezeSort();

            this.endEditCallback();
        };

        ShopDataTable.prototype.setStartEditCallback = function(callback) {
            this.startEditCallback = callback;
        };

        ShopDataTable.prototype.setEndEditCallback = function(callback) {
            this.endEditCallback = callback;
        };

        ///////////////////////////////////
        //        Sorting Methods        //
        ///////////////////////////////////

        ShopDataTable.prototype.sortByParam = function(paramId, isFixed) {
            var that = this;

            if (this.sortFrozen === true) {
                // Sorting can no longer be unfrozen by clicking a sort.
            } else {
                // Sort the data.
                // This should go directly to the proxy, rather than routing
                // through the data handler.

                this.dataHandler.
                    sortByParam(paramId).
                    then(function(pdata, pstatus, pjqXHR) {
                        var newData = ParseUtils.getJSONFromResponse([
                            pdata,
                            pstatus,
                            pjqXHR
                        ]);

                        that.controlObjects.body.updateFromData(newData);
                    });
            }
        };

        ShopDataTable.prototype.freezeSort = function() {
            // Change sort handlers on the header
            this.sortFrozen = true;
            this.containerDivs.header.classList.add('noSort');
        };

        ShopDataTable.prototype.unfreezeSort = function() {
            // Enable sorting from header
            this.sortFrozen = false;
            this.containerDivs.header.classList.remove('noSort');
        };

        ////////////////////////////////////////
        // External Data Manipulation Methods //
        ////////////////////////////////////////

        ShopDataTable.prototype.moveNode = function(args) {
            // move node
            this.dataHandler.moveNode(args.dragParamData, args.targetOrder);

            // Fire update data event to server
            this.externalInterface.execute('updateParameter', [
                this.dataHandler.varGroupCopy,
                { event: { iaEventUISource: 'dataHandler-moveColumn' } }
            ]);

            // Update header
            this.controlObjects.header.updateHeader(true);

            // Change top of body to account for changing header height
            // this.controlObjects.body.updateAllData();
            this.updateBody();
            // this.controlObjects.body.updateAllPositions();
        };

        ShopDataTable.prototype.addColumns = function(args) {
            // Passes command for adding columns to an external data source.

            // Called when a column is added
            // Args is an object that gives column info

            this.externalInterface.execute('addColumns', [args]);
        };

        ShopDataTable.prototype.addRows = function(args) {
            // Passes command for adding rows to an external data source.
            this.externalInterface.execute('addRows', [args]);
        };

        ////////////////////////////////////////
        // Internal Data Manipulation Methods //
        ////////////////////////////////////////

        ShopDataTable.prototype.resizeColumn = function(args) {
            // This is the event that fires when a drag rect is dragged.
            // It will update all header positions/widths and all drag rects
            // except for the one being dragged

            // Change active width in data
            // Change data on span?
            // Change outerWidth on span
            // Call updatePositions();

            // Updates width object in header
            this.dataHandler.updateColumnWidth(args.ID, args.width);

            this.controlObjects.header.fitWidths();

            this.controlObjects.header.updateWidths(true);
            this.controlObjects.header.updatePositions(true);

            // this.controlObjects.body.updateAllWidths();
        };

        ShopDataTable.prototype.resizeEnd = function(args) {
            // Called on the end of the resize to update the dragged rect

            // Build header
            this.updateHeader(args);

            // Update positions
            this.dataHandler.updateColumnPositions();
            this.controlObjects.header.updateDimensions();

            // Build body
            this.updateBody();
        };

        ShopDataTable.prototype.addColumnsFromInterface = function(args) {
            // This is called after columns are added on the server. It updates
            // the client to reflect those changes.
            var i;

            var columns = args[0],
                targetCellID = args[1];

            this.dataHandler.importVarGroup();

            if (typeof targetCellID !== 'undefined') {
                for (i = columns.length - 1; i >= 0; i--) {
                    this.dataHandler.moveNode(
                        {
                            ID: columns[i],
                            order: this.dataHandler.data.columns[columns[i]].
                                order
                        },
                        this.dataHandler.data.columns[targetCellID].order
                    );
                }
            }

            for (i = 0; i < columns.length; i++) {
                this.dataHandler.addEmptyColumn(columns[i]);
            }

            this.eventController('refreshTable', { instant: true });
        };

        ShopDataTable.prototype.addRowsFromInterface = function(args) {
            // args[1] = ID of PREVIOUS row
            // args[0] = row
            // this.freezeSort();

            // this.dataHandler.editableRows[args[0][0].ID] = true;

            // args[0][0].editable = true;

            // this.dataHandler.addRows(args[0], args[1]); //Make this change to
            // the data here rather than getting data back from the server

            this.eventController('refreshTable', {
                instant: true,
                noSort: true
            });
        };

        /*ShopDataTable.prototype.removeRows = function(){
            //Update all data, since scoring can change.
            console.log('DELETE IS BROKEN ON INTERFACE! Can you call it
        directly?'); this.externalInterface.execute('refreshData');
        };*/

        ShopDataTable.prototype.saveChanges = function(args) {
            // Saves client-side data changes to the server.

            // args === changeObject
            // this.freezeSort();

            this.externalInterface.execute('saveChanges', [args]);
        };

        ShopDataTable.prototype.toggleExpandHeader = function(args) {
            this.controlObjects.header.controlObjects.svgHeaderController.toggleExpansion();
            this.controlObjects.body.animateToHeader();
        };

        ////////////////////////////////////////
        // Update methods for external events //
        ////////////////////////////////////////

        ShopDataTable.prototype.basketChanged = function() {
            // Only body changes.
            // Body content is calculated on update for function-driven columns,
            // so updating the body is enough.
            this.controlObjects.body.updateDerivedCells();
        };

        ///////////////////////////////////////////////////////////
        // Event controller - should be removed when convenient. //
        ///////////////////////////////////////////////////////////

        ShopDataTable.prototype.eventController = function(eventType, args) {
            // Fires off events for the specified event type.
            // These should eventually become methods on the prototype. This is
            // inefficient and hard to search.

            var that = this;
            var dataColumns = this.dataHandler.data.columnKeys.map(function(
                colKey
            ) {
                return that.dataHandler.data.columns[colKey].displayName;
            });

            if (eventType === 'initializeTable') {
                console.log(
                    'initialize event is not implemented on data table.'
                );
            } else if (eventType === 'updateColumnOrder') {
                this.moveNode(args);
            } else if (eventType === 'toggleExpandHeader') {
                this.toggleExpandHeader(args);
            } else if (eventType === 'sortByParam') {
                this.sortByParam(args);
            } else if (eventType === 'refreshTable') {
                console.log('REFRESHING DATA TABLE!');
                console.log(dataColumns);

                this.refreshTable(args);
            } else if (eventType === 'resizeColumn') {
                this.resizeColumn(args);
            } else if (eventType === 'resizeEnd') {
                this.resizeEnd(args);
            } else if (eventType === 'addColumns') {
                this.addColumns(args);
            } else if (eventType === 'addColumnsFromInterface') {
                this.addColumnsFromInterface(args);
            } else if (eventType === 'addRows') {
                this.addRows(args);
            } else if (eventType === 'addRowsFromInterface') {
                this.addRowsFromInterface(args);
            } else if (eventType === 'basketChanged') {
                this.basketChanged();
            } else if (eventType === 'removeRows') {
                this.removeRows();
                //} else if (eventType === 'removeColumns'){
                //  this.removeColumns();
            } else if (eventType === 'saveChanges') {
                this.saveChanges(args);
            }
        };
        return ShopDataTable;
    }
);

