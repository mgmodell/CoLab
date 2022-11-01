import React from "react";
import PropTypes from "prop-types";

import { scaleLinear } from "@visx/scale";
import { curveMonotoneX } from "@visx/curve";
const LinePath = React.lazy( ()=>
  import ('../Reports/visxLinePath'));
const Text = React.lazy( ()=>
  import ('../Reports/visxText'));

export default function BingoDataRepresentation(props) {
  const getAvg = valueArray => {
    let total = 0;
    for (var i = 0; i < valueArray.length; i++) {
      total += valueArray[i];
    }
    return total / valueArray.length;
  };
  // returns slope, intercept and r-square of the line
  const leastSquares = (xSeries, ySeries) => {
    const reduceSumFunc = function(prev, cur) {
      return prev + cur;
    };

    const xBar = (xSeries.reduce(reduceSumFunc) * 1.0) / xSeries.length;
    const yBar = (ySeries.reduce(reduceSumFunc) * 1.0) / ySeries.length;

    const ssXX = xSeries
      .map(function(d) {
        return Math.pow(d - xBar, 2);
      })
      .reduce(reduceSumFunc);

    const ssYY = ySeries
      .map(function(d) {
        return Math.pow(d - yBar, 2);
      })
      .reduce(reduceSumFunc);

    const ssXY = xSeries
      .map(function(d, i) {
        return (d - xBar) * (ySeries[i] - yBar);
      })
      .reduce(reduceSumFunc);

    const slope = ssXY / ssXX;
    const intercept = yBar - xBar * slope;
    const rSquare = Math.pow(ssXY, 2) / (ssXX * ssYY);

    return [slope, intercept, rSquare];
  };

  const x = scaleLinear({
    range: [0, props.width],
    domain: [0, props.scores.length]
  });

  const y = scaleLinear({
    domain: [0, 100],
    range: [props.height, 0]
  });

  //Explicate the x range
  const xSeries = [];
  for (var i = 1; i <= props.scores.length; i++) {
    xSeries.push(i);
  }

  const avg = getAvg(props.scores);

  var trendData = null;
  if (props.scores.length > 1) {
    const leastSquaresCoeff = leastSquares(xSeries, props.scores);
    const ePerformance = Math.round(
      avg * (1 + leastSquaresCoeff[0] / props.scores.length)
    );
    var trendLineColor = leastSquaresCoeff[0] < 0 ? "red" : "green";
    trendData = (
      <React.Fragment>
        <LinePath
          data={[
            { x: 0, y: leastSquaresCoeff[1] },
            {
              x: props.scores.length - 1,
              y:
                leastSquaresCoeff[1] +
                props.scores.length * leastSquaresCoeff[0]
            }
          ]}
          x={d => {
            return x(d.x);
          }}
          y={d => {
            return y(d.y);
          }}
          stroke={trendLineColor}
          strokeWidth={2}
        />
        <Text
          x={0.65 * props.width}
          y={props.height}
          textAnchor="middle"
          fontSize={9}
          style={{
            opacity: 0.95,
            fill: "blue"
          }}
        >
          {ePerformance.toString() + "%"}
        </Text>
      </React.Fragment>
    );
  }

  return (
    <React.Fragment>
      <svg width={props.width} height={props.height}>
        <LinePath
          data={props.scores}
          x={(d, i) => {
            return x(i);
          }}
          y={d => {
            return y(d < 100 ? d : 100);
          }}
          stroke="steelblue"
          strokeWidth={1}
          curve={curveMonotoneX}
        />
        <Text
          x={0.25 * props.width}
          y={0.8 * props.height}
          textAnchor="middle"
          fontSize={9}
          style={{
            opacity: 0.35,
            fill: "black"
          }}
        >
          {Math.round(avg)}
        </Text>
        {trendData}
      </svg>
    </React.Fragment>
  );
}

BingoDataRepresentation.propTypes = {
  height: PropTypes.number.isRequired,
  width: PropTypes.number.isRequired,
  value: PropTypes.number.isRequired,
  scores: PropTypes.arrayOf(PropTypes.number).isRequired
};
