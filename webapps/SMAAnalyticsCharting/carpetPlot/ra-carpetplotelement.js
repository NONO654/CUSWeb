(function(GLOBAL) {
    var carpetPlotPrototype = {
        is: 'ra-carpetplotelement',
        behaviors: [GLOBAL.DS.RAComponents.chartcomponent]
    };

    carpetPlotPrototype.setDataProvider = function(dataProvider) {
        this.dataProvider = dataProvider;
    };

    carpetPlotPrototype.format = function(n) {
        if (Math.abs(n) > 1000 || (Math.abs(n) < 0.001 && n !== 0)) {
            return n.toExponential(3);
        } else {
            return d3.round(n, 4);
        }
    };

    carpetPlotPrototype.createdCallback = function() {
        GLOBAL.DS.RAComponents.chartcomponent.createdCallback.call(this);
        var that = this;

        this.scales = {};
        this.scales.x = d3.scale.linear();
        this.scales.y = d3.scale.linear();

        this.dimensions = {};

        this.svgs = {
            root: document.createElementNS('http://www.w3.org/2000/svg', 'svg')
        };

        this.appendChild(this.svgs.root);

        // Main content
        this.svgs.mainContentGroup = d3.
            select(this.svgs.root).
            append('g').
            classed('mainContent', true);

        this.svgs.contentBackRect = this.svgs.mainContentGroup.
            append('rect').
            style({ fill: 'white', stroke: 'none' });

        this.carpetParams = {};

        this.svgs.mainContentGroup.on('click', function(d) {
            console.log(d3.event);
            var coords = d3.mouse(that.svgs.root);

            var x = coords[0],
                y = coords[1];

            var pointData = that.interpolateCrossing([
                that.scales.x.invert(x),
                that.scales.y.invert(y)
            ]);
            that.drawInterpolateLines(pointData);
        });
    };

    carpetPlotPrototype.setTotalHeight = function(totalHeight) {
        this.dimensions.plotHeight = totalHeight;

        // Dimensions computed with plot height
        this.scales.y.range([totalHeight, 0]);

        this.svgs.contentBackRect.attr('height', totalHeight);

        d3.select(this.svgs.root).style('height', totalHeight + 'px');
    };

    carpetPlotPrototype.setTotalWidth = function(totalWidth) {
        this.dimensions.plotWidth = totalWidth;

        // Dimensions computed with plot width
        this.scales.x.range([0, totalWidth]);

        this.svgs.contentBackRect.attr('width', totalWidth);

        d3.select(this.svgs.root).style('width', totalWidth + 'px');
    };

    carpetPlotPrototype.setX = function(xParam) {
        this.xParam = xParam;

        var xPad = (xParam.max - xParam.min) / 20;
        this.scales.x.domain([xParam.min - xPad, xParam.max + xPad]);
    };

    carpetPlotPrototype.setY = function(yParam) {
        // Sets the y-parameter and updates the dependent variables.

        this.yParam = yParam;

        var yPad = (yParam.max - yParam.min) / 20;
        this.scales.y.domain([yParam.min - yPad, yParam.max + yPad]);
    };

    carpetPlotPrototype.setCarpetParam1 = function(param) {
        this.carpetParams.param1 = param;
    };

    carpetPlotPrototype.setCarpetParam2 = function(param) {
        this.carpetParams.param2 = param;
    };

    carpetPlotPrototype.setData = function(data) {
        this.data = data;

        this.recalculateRanges();
    };

    carpetPlotPrototype.recalculateRanges = function() {
        var data = this.data;
        var i, j, thisArray, thisVal;
        // recalculate ranges
        var xMax = data.x[0][0],
            xMin = data.x[0][0],
            yMax = data.y[0][0],
            yMin = data.y[0][0];

        for (i = 0; i < data.x.length; i++) {
            thisArray = data.x[i];
            for (j = 0; j < thisArray.length; j++) {
                thisVal = thisArray[j];
                if (thisVal > xMax) {
                    xMax = thisVal;
                } else if (thisVal < xMin) {
                    xMin = thisVal;
                }
            }
        }

        for (i = 0; i < data.y.length; i++) {
            thisArray = data.y[i];
            for (j = 0; j < thisArray.length; j++) {
                thisVal = thisArray[j];
                if (thisVal > yMax) {
                    yMax = thisVal;
                } else if (thisVal < yMin) {
                    yMin = thisVal;
                }
            }
        }

        var newX = this.xParam,
            newY = this.yParam;

        newX.min = xMin;
        newX.max = xMax;
        newY.min = yMin;
        newY.max = yMax;

        this.setX(newX);
        this.setY(newY);
    };

    carpetPlotPrototype.getLineGenerator = function() {
        var that = this;

        var gen = d3.svg.
            line().
            x(function(d) {
                return that.scales.x(d[0]);
            }).
            y(function(d) {
                return that.scales.y(d[1]);
            });

        return gen;
    };

    carpetPlotPrototype.render = function() {
        var that = this;

        // Draw carpet plot
        var p1PathData = [];
        var p2PathData = [];
        var param1 = this.carpetParams.param1;
        var param2 = this.carpetParams.param2;
        var data = this.data;

        var i, j, thisArray;

        // Get paths for sweeps with constant param1 values
        for (i = 0; i < param1.values.length; i++) {
            thisArray = [];
            for (j = 0; j < param2.values.length; j++) {
                thisArray.push([data.x[i][j], data.y[i][j]]);
            }

            p1PathData.push(thisArray);
        }

        // Ge paths for sweeps with constant param2 values
        for (j = 0; j < param2.values.length; j++) {
            thisArray = [];
            for (i = 0; i < param1.values.length; i++) {
                thisArray.push([data.x[i][j], data.y[i][j]]);
            }

            p2PathData.push(thisArray);
        }

        this.svgs.p1PathGroup = this.svgs.mainContentGroup.append('g');
        this.svgs.p2PathGroup = this.svgs.mainContentGroup.append('g');

        var gen = that.getLineGenerator();

        this.svgs.p1Paths = this.svgs.p1PathGroup.
            selectAll('path').
            data(p1PathData).
            enter().
            append('path').
            attr('d', function(d) {
                return gen(d);
            }).
            style({ stroke: 'steelblue', fill: 'none' });

        this.svgs.p2Paths = this.svgs.p2PathGroup.
            selectAll('path').
            data(p2PathData).
            enter().
            append('path').
            attr('d', function(d) {
                return gen(d);
            }).
            style({ stroke: 'steelblue', fill: 'none' });

        this.addLineValues();
    };

    carpetPlotPrototype.addLineValues = function() {
        var that = this;

        var dataArray1 = [],
            dataArray2 = [];

        var offsetPx = 10;

        var i, x1, y1, x2, y2;
        var tanVector, normVector, tanMag;
        for (i = 0; i < this.data.x.length; i++) {
            x1 = this.data.x[i][0];
            y1 = this.data.y[i][0];
            x2 = this.data.x[i][1];
            y2 = this.data.y[i][1];

            var tanVector = [x1 - x2, y2 - y1];
            var tanMag = Math.sqrt(
                tanVector[0] * tanVector[0] + tanVector[1] * tanVector[1]
            );
            var normVector = tanVector.map(function(d) {
                return d / tanMag;
            });

            dataArray1.push({
                x: that.scales.x(x1) + normVector[0] * offsetPx,
                y: that.scales.y(y1) + normVector[1] * offsetPx,
                value: this.carpetParams.param1.values[i]
            });
        }

        var j;
        for (j = 0; j < this.data.x[0].length; j++) {
            x1 = this.data.x[0][j];
            y1 = this.data.y[0][j];
            x2 = this.data.x[1][j];
            y2 = this.data.y[1][j];

            var tanVector = [x1 - x2, y2 - y1];
            var tanMag = Math.sqrt(
                tanVector[0] * tanVector[0] + tanVector[1] * tanVector[1]
            );
            var normVector = tanVector.map(function(d) {
                return d / tanMag;
            });

            dataArray2.push({
                x: that.scales.x(x1) + normVector[0] * offsetPx,
                y: that.scales.y(y1) + normVector[1] * offsetPx,
                value: this.carpetParams.param2.values[j]
            });
        }

        var addValue = function(d) {
            d3.
                select(this).
                text(that.format(d.value)).
                attr('text-anchor', 'middle').
                attr('x', d.x).
                attr('y', d.y);
        };

        this.svgs.mainContentGroup.
            selectAll('.param1ValueText').
            data(dataArray1).
            enter().
            append('text').
            each(addValue);

        this.svgs.mainContentGroup.
            selectAll('.param2ValueText').
            data(dataArray2).
            enter().
            append('text').
            each(addValue);
    };

    carpetPlotPrototype.interpolateCrossing = function(point) {
        // polyContains(A, B, C, D, P);
        /*
    We assume the points are laid out this awy

    A-----------------B
    |                 |
    |                 |
    |                 |
    |                 |
    C-----------------D
    */
        var i, j;
        var A, B, C, D;

        var inBounds = false;

        // Find polygon containing point
        // Label outer loop for breaking purposes.
        xLoop: for (i = 1; i < this.data.x.length; i++) {
            for (j = 1; j < this.data.x[i].length; j++) {
                A = [this.data.x[i - 1][j - 1], this.data.y[i - 1][j - 1]];
                B = [this.data.x[i - 1][j], this.data.y[i - 1][j]];
                C = [this.data.x[i][j - 1], this.data.y[i][j - 1]];
                D = [this.data.x[i][j], this.data.y[i][j]];

                if (polyContains(A, B, C, D, point)) {
                    console.log('found container!');
                    inBounds = true;
                    break xLoop; // Breaks out of both loops.
                }
            }
        }

        var pointData = { A: A, B: B, C: C, D: D, i: i, j: j };

        if (inBounds) {
            pointData.crossingData = calculatePointData2(A, B, C, D, point);
            console.log(pointData);
        }

        return pointData;
    };

    carpetPlotPrototype.drawInterpolateLines = function(pointData) {
        var abInt, acInt;

        var a = pointData.A,
            b = pointData.B,
            c = pointData.C,
            d = pointData.D,
            ab = pointData.crossingData.ab,
            ac = pointData.crossingData.ac;

        if (a[0] != b[0]) {
            abInt = (ab[0] - a[0]) / (b[0] - a[0]);
        } else {
            abInt = (ab[1] - a[1]) / (b[1] - a[1]);
        }

        if (a[0] != c[0]) {
            acInt = (ac[0] - a[0]) / (c[0] - a[0]);
        } else {
            acInt = (ac[1] - a[1]) / (c[1] - a[1]);
        }

        var i, j;
        var A, B, C;

        j = pointData.j;
        var abPointArray = [],
            acPointArray = [];

        for (i = 0; i < this.data.x.length; i++) {
            A = [this.data.x[i][j - 1], this.data.y[i][j - 1]];
            B = [this.data.x[i][j], this.data.y[i][j]];

            thisPoint = [
                (B[0] - A[0]) * abInt + A[0],
                (B[1] - A[1]) * abInt + A[1]
            ];
            abPointArray.push(thisPoint);
        }

        i = pointData.i;
        for (j = 0; j < this.data.x[i].length; j++) {
            A = [this.data.x[i - 1][j], this.data.y[i - 1][j]];
            C = [this.data.x[i][j], this.data.y[i][j]];

            thisPoint = [
                (C[0] - A[0]) * acInt + A[0],
                (C[1] - A[1]) * acInt + A[1]
            ];
            acPointArray.push(thisPoint);
        }

        this.svgs.mainContentGroup.selectAll('.abInterpolateLine').remove();
        this.svgs.mainContentGroup.selectAll('.acInterpolateLine').remove();

        var gen = this.getLineGenerator();

        this.svgs.mainContentGroup.
            append('path').
            classed('abInterpolateLine', true).
            style({ fill: 'none', stroke: 'red' }).
            attr('d', gen(abPointArray));

        this.svgs.mainContentGroup.
            append('path').
            classed('acInterpolateLine', true).
            style({ fill: 'none', stroke: 'red' }).
            attr('d', gen(acPointArray));
    };

    function calculatePointData2(A, B, C, D, P) {
        // Gets all crossing point values

        /*
    We assume the points are laid out this awy

    A-----------------B
    |                 |
    |                 |
    |                 |
    |                 |
    C-----------------D
    */

        var acbdData = calculatePointData(A, B, C, D, P),
            abcdData = calculatePointData(A, C, B, D, P);

        var pointData = {
            ab: abcdData.ac,
            ac: acbdData.ac,
            bd: acbdData.bd,
            cd: abcdData.bd
        };

        return pointData;
    }

    function calculatePointData(A, B, C, D, P) {
        // Gets intersects across 'ac' and 'bd' lines for a line containing 'p' and
        // bisecting the angle formed by 'ab' and 'cd'

        var pointData = { ac: [0, 0], bd: [0, 0] };

        var xA = A[0],
            xB = B[0],
            xC = C[0],
            xD = D[0],
            xP = P[0];
        var yA = A[1],
            yB = B[1],
            yC = C[1],
            yD = D[1],
            yP = P[1];

        var m1, b1;
        // if(xB !== xA){
        m1 = (yB - yA) / (xB - xA);
        b1 = yA - m1 * xA;
        //} else {
        //  m1 = Infinity;
        //}

        var m2, b2;
        // if(xD !== xC){
        m2 = (yD - yC) / (xD - xC);
        b2 = yC - m2 * xC;
        //} else {
        //  m2 = Infinity;
        //}

        var x0, y0, m3, b3;
        if (m1 === m2) {
            m3 = m1;
            b3 = yP - m3 * xP;

            x0 = xP !== 0 ? xP * 0.9 : 1;
            y0 = m3 * x0 + b3;
        } else {
            x0 = (b2 - b1) / (m1 - m2);
            y0 = m1 * x0 + b1;

            m3 = (yP - y0) / (xP - x0);
            b3 = yP - m3 * xP;
        }

        // if(xP !== x0){

        //} else {
        // Intersecting line is vertical.
        // pointData.ac[0] = x0;
        // pointData.bd[0] = x0;
        //}

        // TODO: We need to handle all vertical line cases.

        var m4, b4;
        m4 = (yC - yA) / (xC - xA);
        b4 = yC - m4 * xC;

        var m5, b5;
        m5 = (yD - yB) / (xD - xB);
        b5 = yD - m5 * xD;

        pointData.ac[0] = (b4 - b3) / (m3 - m4);
        pointData.ac[1] = m3 * pointData.ac[0] + b3;

        pointData.bd[0] = (b5 - b3) / (m3 - m5);
        pointData.bd[1] = m3 * pointData.bd[0] + b3;

        return pointData;
    }

    function polyContains(A, B, C, D, P) {
        // Polygon should have sides, AB AC BD CD
        var intersects = 0;
        intersects += checkIntersect(A, B, P);
        intersects += checkIntersect(A, C, P);
        intersects += checkIntersect(B, D, P);
        intersects += checkIntersect(C, D, P);

        if (intersects % 2 === 1) {
            return true;
        } else {
            return false;
        }
    }

    function checkIntersect(A, B, P) {
        // Checks if a horizonal ray drawn from P to infinity intersects segment AB.
        if (A[1] === B[1]) {
            // Line is parallel. Ignore coincident lines for now.
            return 0;
        }

        var xA = A[0],
            yA = A[1],
            xB = B[0],
            yB = B[1],
            xP = P[0],
            yP = P[1];

        var dAP, dBP, dAB;
        // Find intersect point
        if (xB != xA) {
            var m = (yB - yA) / (xB - xA);
            var b = yB - m * xB;

            var y0 = yP; // Horizontal line.
            var x0 = (y0 - b) / m;

            dAP = Math.abs(yA - yP);
            dBP = Math.abs(yB - yP);
            dAB = Math.abs(yA - yB);

            if (x0 > xP && dAB > dAP && dAB > dBP) {
                return 1;
            } else {
                return 0;
            }
        } else {
            // Line is vertical
            dAP = Math.abs(yA - yP);
            dBP = Math.abs(yB - yP);
            dAB = Math.abs(yA - yB);

            if (xA > xP && dAB > dAP && dAB > dBP) {
                // Segment is on the right of point P and P is between A and B on y
                // axis.

                return 1;
            } else {
                return 0;
            }
        }
    }

    Polymer(carpetPlotPrototype);
    GLOBAL.DS.RAComponents.carpetplotelement = carpetPlotPrototype;
})(this);
