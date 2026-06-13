import React, { useEffect, useState, useRef } from "react";

type Props = {
  height?: number;
  width?: number;
};

export default function TeamworkContracts(props: { height?: number; width?: number }) {
    const height = props.height || 100;
    const width = props.width || 72;

    const viewBox = [0, 0, 700, 950].join(" ");

    return(
    <svg
      height={height}
      width={width}
      viewBox={viewBox}
      preserveAspectRatio="xMidYMid meet"
      xmlns="http://www.w3.org/2000/svg"
    >
        <svg viewBox="0 0 700 950" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style={{
        stopColor: '#ededf0',
        stopOpacity: 1
       }} />
      <stop offset="100%" style={{
        stopColor: '#e2e2e6',
        stopOpacity: 1
       }} />
    </linearGradient>

    <filter id="stackShadow" x="-10%" y="-10%" width="130%" height="130%">
      <feDropShadow dx="0" dy="8" stdDeviation="12" floodColor="#1e293b" floodOpacity="0.12" />
      <feDropShadow dx="0" dy="2" stdDeviation="4" floodColor="#1e293b" floodOpacity="0.08" />
    </filter>

    <g id="base-page-template">
      <rect width="480" height="680" rx="4" fill="#f5f3eb" stroke="#d6d3c9" strokeWidth="1" />
    </g>

    <g id="bullet-element">
      <circle cx="0" cy="0" r="5" fill="#52586b" />
    </g>
  </defs>


  <g filter="url(#stack-shadow)">
    <use href="#base-page-template" x="110" y="85" transform="rotate(3.5, 350, 425)" />

    <use href="#base-page-template" x="110" y="80" transform="rotate(-4, 350, 420)" />

    <use href="#base-page-template" x="112" y="75" transform="rotate(1.8, 350, 415)" />

    <use href="#base-page-template" x="108" y="72" transform="rotate(-2.2, 350, 412)" />

    <g transform="rotate(0.5, 350, 410)">
      <rect x="110" y="70" width="480" height="680" rx="4" fill="#faf9f5" stroke="#d0cbbd" strokeWidth="1" />

      <text x="350" y="165" fontFamily="Georgia, serif" fontSize="38" fontWeight="bold" fill="#3a415a" textAnchor="middle">Team Contract</text>

      <g fill="none" stroke="#7c7769" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" opacity="0.85">
        <path d="M 165 210 Q 185 204, 210 212 T 260 208 T 310 210 T 360 205 T 410 212 T 460 208 T 510 207 T 535 212" />
        <path d="M 165 230 Q 190 228, 220 234 T 270 227 T 320 231 T 370 226 T 420 233 T 470 229 T 520 232" />
        <path d="M 165 250 Q 180 248, 205 253 T 255 247 T 305 251 T 355 246 T 405 254 T 455 248 T 500 250" />
        <path d="M 165 270 Q 195 266, 230 272 T 285 268 T 340 271 T 395 265 T 450 273 T 485 269" />
      </g>

      <g transform="translate(165, 310)" fill="none" stroke="#7c7769" strokeLinecap="round" strokeLinejoin="round">
        <g>
          <use href="#bullet-element" x="10" y="15" />
          <path d="M 28 15 Q 50 11, 75 16 T 125 13 T 175 17" strokeWidth="2.5" />
          <path d="M 28 30 Q 55 28, 90 32 T 145 29" strokeWidth="2" opacity="0.6" />

          <use href="#bullet-element" x="10" y="55" />
          <path d="M 28 55 Q 60 51, 95 56 T 150 53 T 185 57" strokeWidth="2.5" />
          <path d="M 28 70 Q 50 67, 80 71 T 120 68" strokeWidth="2" opacity="0.6" />

          <use href="#bullet-element" x="10" y="95" />
          <path d="M 28 95 Q 45 91, 70 96 T 120 93 T 165 97" strokeWidth="2.5" />

          <use href="#bullet-element" x="10" y="135" />
          <path d="M 28 135 Q 55 131, 90 137 T 145 134 T 190 138" strokeWidth="2.5" />
          <path d="M 28 150 Q 45 147, 75 151" strokeWidth="2" opacity="0.6" />
        </g>

        <g transform="translate(210, 0)">
          <use href="#bullet-element" x="10" y="15" />
          <path d="M 28 15 Q 55 11, 90 16 T 145 13 T 180 17" strokeWidth="2.5" />

          <use href="#bullet-element" x="10" y="55" />
          <path d="M 28 55 Q 45 52, 75 57 T 120 54" strokeWidth="2.5" />
          <path d="M 28 70 Q 60 66, 100 71 T 155 68" strokeWidth="2" opacity="0.6" />

          <use href="#bullet-element" x="10" y="95" />
          <path d="M 28 95 Q 50 92, 85 97 T 140 94 T 175 98" strokeWidth="2.5" />

          <use href="#bullet-element" x="10" y="135" />
          <path d="M 28 135 Q 45 132, 75 137 T 125 134" strokeWidth="2.5" />
        </g>
      </g>

      <g transform="translate(165, 540)" fontFamily="system-ui, -apple-system, sans-serif">
        <g stroke="#7c7769" strokeWidth="1.2" fill="none" strokeLinecap="round">
          <path d="M 12 25 L 20 12 L 25 15 L 17 28 Z M 20 12 L 24 8 L 28 12 L 25 15" />
          <line x1="16" y1="20" x2="22" y2="24" />

          <rect x="210" y="10" width="18" height="18" rx="2" />
          <line x1="210" y1="16" x2="228" y2="16" />
          <line x1="215" y1="7" x2="215" y2="11" />
          <line x1="223" y1="7" x2="223" y2="11" />
        </g>

        <text x="12" y="44" fontSize="12" fill="#716b5a" fontWeight="500">Signature</text>
        <text x="210" y="44" fontSize="12" fill="#716b5a" fontWeight="500">Date</text>

        <line x1="12" y1="32" x2="185" y2="32" stroke="#cbc5b5" strokeWidth="1" />
        <line x1="210" y1="32" x2="385" y2="32" stroke="#cbc5b5" strokeWidth="1" />

        <g stroke="#ded9cb" strokeWidth="1" fill="#9e998a">
          <circle cx="14" cy="65" r="2" />
          <line x1="25" y1="65" x2="165" y2="65" />
          <circle cx="212" cy="65" r="2" />
          <line x1="223" y1="65" x2="365" y2="65" />

          <circle cx="14" cy="82" r="2" />
          <line x1="25" y1="82" x2="145" y2="82" />
          <circle cx="212" cy="82" r="2" />
          <line x1="223" y1="82" x2="340" y2="82" />

          <circle cx="14" cy="99" r="2" />
          <line x1="25" y1="99" x2="155" y2="99" />
          <circle cx="212" cy="99" r="2" />
          <line x1="223" y1="99" x2="315" y2="99" />
        </g>
      </g>
    </g>
  </g>
</svg>

</svg>


    )
}
