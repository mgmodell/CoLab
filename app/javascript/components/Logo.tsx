import React, { useEffect, useState } from "react";
import PropTypes from "prop-types";

export default function Logo(props) {
  const height = props.height || 72;
  const width = props.width || 72;

  const viewBox = [0, 0, 1000, 1000].join(" ");

  const [colors, setColors] = useState([
    "#00FF00",
    "#FF2A2A",
    "#FFFF00",
    "#FF6600",
    "#FF00FF"
  ]);
  const center = { x: 450, y: 455 };
  const [points, setPoints] = useState([
    { x: 124, y: 135 },
    { x: 568, y: 134 },
    { x: 790, y: 530 },
    { x: 610, y: 790 },
    { x: 120, y: 710 }
  ]);

  const [green, setGreen] = useState(colors[0]);

  function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  function rotateColors() {
    colors.push(colors.shift());
    setColors(colors);
    setGreen(colors[0]);
  }

  async function spinning() {
    while (true) {
      if (props.spinning) {
        rotateColors();
      }
      await sleep(100);
    }
  }

  useEffect(() => {
    spinning();
  }, []);

  async function spinIt() {
    if (!props.spinning) {
      for (let index = 0; index < 15; index++) {
        rotateColors();
        await sleep(Math.log(index, 1000) * 100);
      }
    }
  }

  return (
    <svg
      height={height}
      width={width}
      onClick={spinIt}
      viewBox={viewBox}
      preserveAspectRatio="xMidYMid meet"
      xmlns="http://www.w3.org/2000/svg"
    >
      <linearGradient
        id="bg_grad"
        x1="-5"
        y1="493"
        x2="975"
        y2="493"
        gradientUnits="userSpaceOnUse"
      >
        >
        <stop offset="0" stopColor="#ffffff" stopOpacity="25%" />
        <stop offset="1" stopColor="#c8c8c8" stopOpacity="100%" />
      </linearGradient>
      <circle
        id="background"
        cx="485"
        cy="493"
        r="490"
        fill="url('#bg_grad')"
      />
      <g id="circles" stroke="black" strokeWidth="30">
        <line x1={center.x} y1={center.y} x2={points[0].x} y2={points[0].y} />
        <line x1={center.x} y1={center.y} x2={points[1].x} y2={points[1].y} />
        <line x1={center.x} y1={center.y} x2={points[2].x} y2={points[2].y} />
        <line x1={center.x} y1={center.y} x2={points[3].x} y2={points[3].y} />
        <line x1={center.x} y1={center.y} x2={points[4].x} y2={points[4].y} />
        <circle id="desk" cx={center.y} cy={center.y} r="160" fill="#00FFFF" />
        <g id="teammates" strokeWidth="20">
          <circle
            id="green"
            cx={points[0].x}
            cy={points[0].y}
            r="82"
            fill={green}
          />
          <circle
            id="red"
            cx={points[1].x}
            cy={points[1].y}
            r="80"
            fill={colors[1]}
          />
          <circle
            id="yellow"
            cx={points[2].x}
            cy={points[2].y}
            r="85"
            fill={colors[2]}
          />
          <circle
            id="orange"
            cx={points[3].x}
            cy={points[3].y}
            r="81"
            fill={colors[3]}
          />
          <circle
            id="purple"
            cx={points[4].x}
            cy={points[4].y}
            r="80"
            fill={colors[4]}
          />
        </g>
      </g>
    </svg>
  );

  Logo.propTypes = {
    height: PropTypes.number,
    width: PropTypes.number,
    spinning: PropTypes.bool
  };
}
