import React, { useEffect, useState, useRef } from "react";

type Props = {
  height?: number;
  width?: number;
};

export default function BingoBoards(props: Props) {
    const height = props.height || 100;
    const width = props.width || 100;

    const viewBox = [0, 0, 100, 100].join(" ");

  return (
    <svg
      height={height}
      width={width}
      viewBox={viewBox}
      preserveAspectRatio="xMidYMid meet"
      xmlns="http://www.w3.org/2000/svg"
    >
          <g
     transform="translate(50, 50)"
     //style="filter: drop-shadow(4px 4px 6px rgba(0,0,0,0.3))"
     id="g93">
    {/* Card 1 (Left, Yellow Header, Under) */}
    <g
       transform="translate(100, 100) rotate(-20)"
       transform-origin="center"
       id="g30">
      <rect
         x="0"
         y="0"
         width="300"
         height="420"
         rx="10"
         fill="#FFFFFF"
         id="rect2" />
      <rect
         x="0"
         y="0"
         width="300"
         height="60"
         rx="10 10 0 0"
         fill="#FDD701"
         id="rect3" />
      <text
         x="150"
         y="45"
         fontFamily="sans-serif"
         fontWeight="bold"
         fontSize="36"
         textAnchor="middle"
         fill="#E65100"
         id="text3">B I N G O</text>
      {/* Grid */}
      <g
         transform="translate(0, 60)"
         id="g29">
        <line
           x1="0"
           y1="0"
           x2="300"
           y2="0"
           stroke="#000"
           strokeWidth="1.5"
           id="line3" />
        <line
           x1="0"
           y1="72"
           x2="300"
           y2="72"
           stroke="#000"
           strokeWidth="1.5"
           id="line4" />
        <line
           x1="0"
           y1="144"
           x2="300"
           y2="144"
           stroke="#000"
           strokeWidth="1.5"
           id="line5" />
        <line
           x1="0"
           y1="216"
           x2="300"
           y2="216"
           stroke="#000"
           strokeWidth="1.5"
           id="line6" />
        <line
           x1="0"
           y1="288"
           x2="300"
           y2="288"
           stroke="#000"
           stroke-width="1.5"
           id="line7" />
        <line
           x1="0"
           y1="360"
           x2="300"
           y2="360"
           stroke="#000"
           stroke-width="1.5"
           id="line8" />
        <line
           x1="60"
           y1="0"
           x2="60"
           y2="360"
           stroke="#000"
           stroke-width="1.5"
           id="line9" />
        <line
           x1="120"
           y1="0"
           x2="120"
           y2="360"
           stroke="#000"
           stroke-width="1.5"
           id="line10" />
        <line
           x1="180"
           y1="0"
           x2="180"
           y2="360"
           stroke="#000"
           stroke-width="1.5"
           id="line11" />
        <line
           x1="240"
           y1="0"
           x2="240"
           y2="360"
           stroke="#000"
           stroke-width="1.5"
           id="line12" />
        {/* Numbers for Card 1 (extracted) */}
        <g
           font-family="sans-serif"
           font-size="28"
           font-weight="bold"
           text-anchor="middle"
           fill="#000"
           id="g28">
          <text
             x="30"
             y="48"
             id="text12">7</text>
          <text
             x="90"
             y="48"
             id="text13">10</text>
          <text
             x="150"
             y="48"
             id="text14">44</text>
          <text
             x="210"
             y="48"
             id="text15">63</text>
          <text
             x="270"
             y="48"
             id="text16">70</text>
          <text
             x="30"
             y="120"
             id="text17">7</text>
          <text
             x="90"
             y="120"
             id="text18">24</text>
          <text
             x="150"
             y="120"
             id="text19">36</text>
          <text
             x="210"
             y="120"
             id="text20">56</text>
          <text
             x="30"
             y="192"
             id="text21">9</text>
          <text
             x="90"
             y="192"
             id="text22">23</text>
          <text
             x="150"
             y="192"
             font-size="20"
             font-weight="normal"
             id="text23">FREE</text>
          <text
             x="30"
             y="264"
             id="text24">6</text>
          <text
             x="90"
             y="264"
             id="text25">29</text>
          <text
             x="30"
             y="336"
             id="text26">7</text>
          <text
             x="90"
             y="336"
             id="text27">26</text>
          <text
             x="150"
             y="336"
             id="text28">33</text>
        </g>
      </g>
    </g>
    {/* Card 2 (Right, Green Header, Under) */}
    <g
       transform="rotate(25,281.72491,1050.6288)"
       transform-origin="center"
       id="g52">
      <rect
         x="0"
         y="0"
         width="300"
         height="420"
         rx="10"
         fill="#ffffff"
         id="rect30" />
      <rect
         x="0"
         y="0"
         width="300"
         height="60"
         rx="10"
         fill="#1b5e20"
         id="rect31" />
      <text
         x="150"
         y="45"
         font-family="sans-serif"
         font-weight="bold"
         font-size="36px"
         text-anchor="middle"
         fill="#e8f5e9"
         id="text31">B I N G O</text>
      {/* Grid */}
      <g
         transform="translate(0,60)"
         id="g51">
        <line
           x1="0"
           y1="0"
           x2="300"
           y2="0"
           stroke="#000000"
           stroke-width="1.5"
           id="line31" />
        <line
           x1="0"
           y1="72"
           x2="300"
           y2="72"
           stroke="#000000"
           stroke-width="1.5"
           id="line32" />
        <line
           x1="0"
           y1="144"
           x2="300"
           y2="144"
           stroke="#000000"
           stroke-width="1.5"
           id="line33" />
        <line
           x1="0"
           y1="216"
           x2="300"
           y2="216"
           stroke="#000000"
           stroke-width="1.5"
           id="line34" />
        <line
           x1="0"
           y1="288"
           x2="300"
           y2="288"
           stroke="#000000"
           stroke-width="1.5"
           id="line35" />
        <line
           x1="0"
           y1="360"
           x2="300"
           y2="360"
           stroke="#000000"
           stroke-width="1.5"
           id="line36" />
        <line
           x1="60"
           y1="0"
           x2="60"
           y2="360"
           stroke="#000000"
           stroke-width="1.5"
           id="line37" />
        <line
           x1="120"
           y1="0"
           x2="120"
           y2="360"
           stroke="#000000"
           stroke-width="1.5"
           id="line38" />
        <line
           x1="180"
           y1="0"
           x2="180"
           y2="360"
           stroke="#000000"
           stroke-width="1.5"
           id="line39" />
        <line
           x1="240"
           y1="0"
           x2="240"
           y2="360"
           stroke="#000000"
           stroke-width="1.5"
           id="line40" />
        {/* Numbers for Card 2 (extracted, only partial rows shown as in image) */}
        <g
           font-family="sans-serif"
           font-size="28px"
           font-weight="bold"
           text-anchor="middle"
           fill="#000000"
           id="g50">
          <text
             x="30"
             y="48"
             id="text40">29</text>
          <text
             x="90"
             y="48"
             id="text41">42</text>
          <text
             x="210"
             y="48"
             id="text42">65</text>
          <text
             x="30"
             y="120"
             id="text43">7</text>
          <text
             x="90"
             y="120"
             id="text44">51</text>
          <text
             x="150"
             y="120"
             id="text45">62</text>
          <text
             x="30"
             y="192"
             id="text46">46</text>
          <text
             x="90"
             y="192"
             id="text47">60</text>
          <text
             x="30"
             y="264"
             id="text48">51</text>
          <text
             x="90"
             y="264"
             id="text49">78</text>
          <text
             x="30"
             y="336"
             id="text50">77</text>
        </g>
      </g>
    </g>
    {/* Card 3 (Central, Top, Blue & Red Header, with Daubs) */}
    <g
       transform="translate(347.84017,108.55292)"
       id="g92">
      <rect
         x="0"
         y="0"
         width="300"
         height="420"
         rx="10"
         fill="#ffffff"
         id="rect52" />
      <rect
         x="0"
         y="0"
         width="300"
         height="60"
         rx="10"
         fill="#ffffff"
         id="rect53" />
      {/* B I N G O Header (Explicit Colors) */}
      <g
         transform="translate(150,45)"
         font-family="sans-serif"
         font-weight="bold"
         font-size="36px"
         text-anchor="middle"
         id="g57">
        <text
           x="-120"
           y="0"
           fill="#1a237e"
           id="text53">B</text>
        <text
           x="-60"
           y="0"
           fill="#e65100"
           id="text54">I</text>
        <text
           x="0"
           y="0"
           fill="#1a237e"
           id="text55">N</text>
        <text
           x="60"
           y="0"
           fill="#e65100"
           id="text56">G</text>
        <text
           x="120"
           y="0"
           fill="#1a237e"
           id="text57">O</text>
      </g>
      {/* Grid */}
      <g
         transform="translate(0,60)"
         id="g91">
        <line
           x1="0"
           y1="0"
           x2="300"
           y2="0"
           stroke="#000000"
           stroke-width="1.5"
           id="line57" />
        <line
           x1="0"
           y1="72"
           x2="300"
           y2="72"
           stroke="#000000"
           stroke-width="1.5"
           id="line58" />
        <line
           x1="0"
           y1="144"
           x2="300"
           y2="144"
           stroke="#000000"
           stroke-width="1.5"
           id="line59" />
        <line
           x1="0"
           y1="216"
           x2="300"
           y2="216"
           stroke="#000000"
           stroke-width="1.5"
           id="line60" />
        <line
           x1="0"
           y1="288"
           x2="300"
           y2="288"
           stroke="#000000"
           stroke-width="1.5"
           id="line61" />
        <line
           x1="0"
           y1="360"
           x2="300"
           y2="360"
           stroke="#000000"
           stroke-width="1.5"
           id="line62" />
        <line
           x1="60"
           y1="0"
           x2="60"
           y2="360"
           stroke="#000000"
           stroke-width="1.5"
           id="line63" />
        <line
           x1="120"
           y1="0"
           x2="120"
           y2="360"
           stroke="#000000"
           stroke-width="1.5"
           id="line64" />
        <line
           x1="180"
           y1="0"
           x2="180"
           y2="360"
           stroke="#000000"
           stroke-width="1.5"
           id="line65" />
        <line
           x1="240"
           y1="0"
           x2="240"
           y2="360"
           stroke="#000000"
           stroke-width="1.5"
           id="line66" />
        {/* Numbers for Card 3 */}
        <g
           font-family="sans-serif"
           font-size="28px"
           font-weight="bold"
           text-anchor="middle"
           fill="#000000"
           id="g90">
          {/* Row 1 */}
          <text
             x="30"
             y="48"
             id="text66">8</text>
          <text
             x="90"
             y="48"
             id="text67">27</text>
          <text
             x="150"
             y="48"
             id="text68">45</text>
          <text
             x="210"
             y="48"
             id="text69">53</text>
          <text
             x="270"
             y="48"
             id="text70">70</text>
          {/* Row 2 (Daub over 4) */}
          <circle
             cx="30"
             cy="110"
             r="22"
             fill="#e65100"
             opacity="0.6"
             id="circle70" />
          {/* Translucent dauber ink */}
          <text
             x="30"
             y="120"
             id="text71">4</text>
          <text
             x="90"
             y="120"
             id="text72">22</text>
          <text
             x="150"
             y="120"
             id="text73">38</text>
          <text
             x="210"
             y="120"
             id="text74">64</text>
          <text
             x="270"
             y="120"
             id="text75">78</text>
          {/* Row 3 (FREE in center) */}
          <text
             x="30"
             y="192"
             id="text76">11</text>
          <text
             x="90"
             y="192"
             id="text77">19</text>
          <text
             x="150"
             y="192"
             font-size="20px"
             font-weight="normal"
             id="text78">FREE</text>
          <text
             x="210"
             y="192"
             id="text79">59</text>
          <text
             x="270"
             y="192"
             id="text80">73</text>
          {/* Row 4 */}
          <text
             x="30"
             y="264"
             id="text81">1</text>
          <text
             x="90"
             y="264"
             id="text82">22</text>
          <text
             x="150"
             y="264"
             id="text83">36</text>
          <text
             x="210"
             y="264"
             id="text84">60</text>
          <text
             x="270"
             y="264"
             id="text85">71</text>
          {/* Row 5 (Daub over 88) */}
          <circle
             cx="270"
             cy="326"
             r="22"
             fill="#e65100"
             opacity="0.6"
             id="circle85" />
          {/* Translucent dauber ink */}
          <text
             x="30"
             y="336"
             id="text86">10</text>
          <text
             x="90"
             y="336"
             id="text87">26</text>
          <text
             x="150"
             y="336"
             id="text88">35</text>
          <text
             x="210"
             y="336"
             id="text89">57</text>
          <text
             x="270"
             y="336"
             id="text90">88</text>
        </g>
      </g>
    </g>
  </g>

    </svg>
  );
}