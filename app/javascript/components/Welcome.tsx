import React, { useEffect, useState, useRef } from "react";
import { useSpring, animated } from "react-spring";

type Props = {
}

export default function Welcome(props: Props) {
  const height = '100%'
  const width = '100%'
  //const mounted = useRef(false);

  const viewBox = [0, 0, 220, 175].join(" ");

  const [springs, api] = useSpring(() => ({
   from: {opacity: 1},
  }));

  return (
    <svg
      //height={height}
      //width={width}
      viewBox={viewBox}
      version="1.1"
      id='welcome'
      preserveAspectRatio="xMidYMid meet"
      xmlns="http://www.w3.org/2000/svg"
      onClick={()=>{
         api.start({
            from: {
               opacity: 1,
            },
            to: {
               opacity: 0
            }
         })
      }}
    >
  <animated.g
     id="title_text"
     style={{
      ...springs
     }}>
    <text
         x="29"
         y="27"
       id="improving"
       style={ {
          fontWeight: "normal",
          fontSize: '18',
          lineHeight: 1.25,
          fontFamily: 'sans-serif',
          whiteSpace: 'pre',
          fill: 'white',
          stroke: 'black',

        }}>
         Impr    ving
    </text>
    <text
         x="26"
         y="74"
       id="collab"
       style={ {
          fontWeight: "normal",
          fontSize: '45',
          lineHeight: 1.35,
          fontFamily: 'sans-serif',
          whiteSpace: 'pre',
          fill: 'black',
          stroke: 'white',
        }}>
         C    LAB
    </text>
    <text
         x="119"
         y="93"
       id="oration"
       style={ {
          fontWeight: "normal",
          fontSize: '',
          lineHeight: 1.25,
          fontFamily: 'sans-serif',
          whiteSpace: 'pre',
          fill: 'white',
          stroke: 'black',
        }}>
         RATION
    </text>
    <text
         x="65"
         y="107"
       id="one_team"
       style={ {
          fontWeight: "normal",
          fontSize: '18',
          lineHeight: 1.25,
          fontFamily: 'sans-serif',
          whiteSpace: 'pre',
          fill: 'white',
          stroke: 'black',

        }}>
         ne team at a time
    </text>
    </animated.g>
    <g
       id="circles"
       stroke="#000000"
       strokeWidth="30"
       transform="
        translate(45,115)
        rotate( 255 )
        scale(.1)"
       >
      <line
         x1="450"
         y1="455"
         x2="124"
         y2="135"
         id="line2" />
      <line
         x1="450"
         y1="455"
         x2="568"
         y2="134"
         id="line3" />
      <line
         x1="450"
         y1="455"
         x2="790"
         y2="530"
         id="line4" />
      <line
         x1="450"
         y1="455"
         x2="610"
         y2="790"
         id="line5" />
      <line
         x1="450"
         y1="455"
         x2="120"
         y2="710"
         id="line6" />
      <circle
         id="desk"
         cx="450"
         cy="455"
         r="160"
         fill="#00ffff" />
      <g
         id="teammates"
         strokeWidth="20">
        <circle
           id="green"
           cx="124"
           cy="135"
           r="82"
           fill="#00ff00" />
        <circle
           id="red"
           cx="568"
           cy="134"
           r="80"
           fill="#ff2a2a" />
        <circle
           id="yellow"
           cx="790"
           cy="530"
           r="85"
           fill="#ffff00" />
        <circle
           id="orange"
           cx="610"
           cy="790"
           r="81"
           fill="#ff6600" />
        <circle
           id="purple"
           cx="120"
           cy="710"
           r="80"
           fill="#ff00ff" />
      </g>
    </g>
    </svg>
  );

}
