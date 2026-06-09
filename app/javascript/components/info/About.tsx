import React from "react";
import { useSpring, animated, config } from "@react-spring/web";

import MGM from "../svgs/MGM";
import BingoBoards from "../svgs/BingoBoards";

type Props = {};

const contributors = [
  'Maron',
  'Dennis',
  'Esteban',
  'Issiah',
  'Josiah',
  'Soojin',
  'Stephanie',
  'Michael',
  'Julia',
  'Allison',
  'Melissa',
  'Yomaris',
  'Emi',
  'Brillyd',
  'Justin'
]

type Props = {
  height: number;
  width: number;
}
const viewBox = [0, 0, 494, 255].join(" ");

export default function About(props: Props) {
  return (
    <svg
      height={props.height}
      width={props.width}
      viewBox={viewBox}
      xmlns="http://www.w3.org/2000/svg"
    >
          <g
     id="main">
    <title
       id="title1">About CoLab</title>
    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_8"
       y="68.5"
       x="86.5"
       strokeWidth="0"
       stroke="#000"
       fill="#000000">He couldn't let it go, so it became part of his research agenda.</text>
       <animated.svg
       x="10"
       y="50"
       >
          <MGM height={64} width={64} color="#000000" />

       </animated.svg>
    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_9"
       y="152"
       x="30"
       strokeWidth="0"
       stroke="#000"
       fill="#000000">His students got involved and now it's available for you to use, too!</text>
    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_12"
       y="33.5"
       x="25.5"
       strokeWidth="0"
       stroke="#000"
       fill="#000000">Micah Gideon Modell built CoLab to give his student teams a voice.</text>
    <text
       stroke="#000"
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_13"
       y="114.5"
       x="80.5"
       strokeWidth="0"
       fill="#000000">He experimented with visualizations and gamification.</text>
    <animated.g
      id="contributors"
      >

      <text
         transform="rotate(-18 47.6641 193.5)"
         textAnchor="start"
         fontFamily="Noto Sans JP"
         fontSize="14"
         id="svg_14"
         y="198"
         x="29"
         strokeWidth="0"
         stroke="#000"
         fill="#000000">Maron</text>
      <text
         transform="rotate(-3 128.617 205.5)"
         textAnchor="start"
         fontFamily="Noto Sans JP"
         fontSize="14"
         id="svg_15"
         y="210"
         x="108"
         strokeWidth="0"
         stroke="#000"
         fill="#000000">Allison</text>
      <text
         transform="rotate(15 213.832 186.5)"
         textAnchor="start"
         fontFamily="Noto Sans JP"
         fontSize="14"
         id="svg_16"
         y="191"
         x="194"
         strokeWidth="0"
         stroke="#000"
         fill="#000000">Dennis</text>
      <text
         transform="rotate(-21 299.285 193.5)"
         textAnchor="start"
         fontFamily="Noto Sans JP"
         fontSize="14"
         id="svg_17"
         y="198"
         x="281"
         strokeWidth="0"
         stroke="#000"
         fill="#000000">Soojin</text>
      <text
         transform="rotate(-15 389.223 205.5)"
         textAnchor="start"
         fontFamily="Noto Sans JP"
         fontSize="14"
         id="svg_18"
         y="210"
         x="376"
         strokeWidth="0"
         stroke="#000"
         fill="#000000">Julia</text>
      <text
         transform="rotate(13 446.332 186.5)"
         textAnchor="start"
         fontFamily="Noto Sans JP"
         fontSize="14"
         id="svg_20"
         y="191"
         x="430"
         strokeWidth="0"
         stroke="#000"
         fill="#000000">Issiah</text>
      </animated.g>
       <animated.svg
       x="90"
       y="10"
       >
          <BingoBoards height={100} width={100} />
       </animated.svg>

    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_22"
       y="272.5"
       x="24"
       strokeWidth="0"
       stroke="#000"
       fill="#000000">Please review our Privacy policy and our Terms of Service.</text>
    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="23"
       id="svg_23"
       y="242.5"
       x="122"
       strokeWidth="0"
       stroke="#000"
       fill="#000000">And we're not done yet!</text>
  </g>

    </svg>
  );
}
