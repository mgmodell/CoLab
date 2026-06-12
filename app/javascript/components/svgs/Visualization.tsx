import React, { useEffect, useState, useRef } from "react";
import { logocolors } from "./Logo";

type Props = {
  height?: number;
  width?: number;
};

export default function Visualization(props: Props) {
  const height = props.height || 72;
  const width = props.width || 72;

  const viewBox = [0, 0, 800, 480].join(" ");

  return (
    <svg
      height={height}
      width={width}
      viewBox={viewBox}
      preserveAspectRatio="xMidYMid meet"
      xmlns="http://www.w3.org/2000/svg"
    >
    <defs>
      <filter id='glow-blur' x="0" y="0" xmlns="http://www.w3.org/2000/svg">
        <feGaussianBlur in='SourceGraphic' stdDeviation="50" />
      </filter>
    </defs>
  <rect x="60" y="10" width="710" height="480"
    filter="url(#glow-blur)"
    opacity="0.6"
    fill="#222" strokeWidth="1" />
  <rect x="70" y="20" width="710" height="480" fill="#f9fafb" stroke="#e5e7eb" strokeWidth="1.5" />

  <g stroke="#e5e7eb" strokeWidth="1">
    <line x1="70" y1="20" x2="780" y2="20" />
    <line x1="70" y1="140" x2="780" y2="140" />
    <line x1="70" y1="260" x2="780" y2="260" />
    <line x1="70" y1="380" x2="780" y2="380" stroke="#9ca3af" strokeDasharray="5,5" strokeWidth="1.5" />
    <line x1="70" y1="500" x2="780" y2="500" />
  </g>

  <g stroke="#e5e7eb" strokeWidth="1">
    <line x1="134.5" y1="20" x2="134.5" y2="500" />
    <line x1="199" y1="20" x2="199" y2="500" />
    <line x1="263.5" y1="20" x2="263.5" y2="500" />
    <line x1="328" y1="20" x2="328" y2="500" />
    <line x1="392.5" y1="20" x2="392.5" y2="500" />
    <line x1="457" y1="20" x2="457" y2="500" />
    <line x1="521.5" y1="20" x2="521.5" y2="500" />
    <line x1="586" y1="20" x2="586" y2="500" />
    <line x1="650.5" y1="20" x2="650.5" y2="500" />
    <line x1="715" y1="20" x2="715" y2="500" />
  </g>

  <g fontSize="12" fill="#4b5563" textAnchor="end">
    <text x="60" y="24">100</text>
    <text x="60" y="144">75</text>
    <text x="60" y="264">50</text>
    <text x="60" y="384" fontWeight="bold" fill="#1f2937">25</text>
    <text x="60" y="504">0</text>
  </g>

  <g fontSize="12" fill="#4b5563" textAnchor="middle">
    <text x="70" y="522">Jan</text>
    <text x="134.5" y="522">Feb</text>
    <text x="199" y="522">Mar</text>
    <text x="263.5" y="522">Apr</text>
    <text x="328" y="522">May</text>
    <text x="392.5" y="522">Jun</text>
    <text x="457" y="522">Jul</text>
    <text x="521.5" y="522">Aug</text>
    <text x="586" y="522">Sep</text>
    <text x="650.5" y="522">Oct</text>
    <text x="715" y="522">Nov</text>
    <text x="780" y="522">Dec</text>
  </g>

  <path fill="none" stroke="#059669" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 20 C 85 100, 105 200, 134.5 70 C 165 20, 185 450, 199 300 C 230 50, 250 400, 263.5 110 C 328 350, 392.5 390, 457 260 C 521.5 240, 586 380, 650.5 450 C 715 400, 750 300, 780 130" />
  <path fill="none" stroke="#059669" strokeWidth="3.5" strokeDasharray="1,5" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 420 C 100 280, 120 180, 134.5 220 C 170 340, 180 20, 199 24 C 230 30, 250 180, 263.5 250 C 328 340, 392.5 240, 457 410 C 521.5 380, 586 350, 650.5 370 C 715 470, 750 320, 780 430" />
  <path fill="none" stroke="#059669" strokeWidth="2.5" strokeDasharray="6,4" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 450 C 90 350, 110 100, 134.5 230 C 160 350, 180 130, 199 150 C 230 180, 250 440, 263.5 390 C 328 380, 392.5 280, 457 320 C 521.5 360, 586 330, 650.5 390 C 715 450, 750 350, 780 500" />

  <path fill="none" stroke="#7c3aed" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 280 C 90 200, 110 140, 134.5 170 C 165 220, 185 80, 199 100 C 230 150, 250 420, 263.5 280 C 328 350, 392.5 290, 457 200 C 521.5 210, 586 320, 650.5 260 C 715 320, 750 190, 780 170" />
  <path fill="none" stroke="#7c3aed" strokeWidth="3.5" strokeDasharray="1,5" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 230 C 90 190, 110 320, 134.5 190 C 165 40, 185 240, 199 160 C 230 60, 250 130, 263.5 140 C 328 200, 392.5 260, 457 350 C 521.5 450, 586 210, 650.5 250 C 715 280, 750 480, 780 500" />
  <path fill="none" stroke="#7c3aed" strokeWidth="2.5" strokeDasharray="6,4" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 190 C 90 290, 110 400, 134.5 360 C 165 310, 185 110, 199 120 C 230 130, 250 160, 263.5 150 C 328 220, 392.5 350, 457 320 C 521.5 220, 586 240, 650.5 300 C 715 240, 750 180, 780 320" />

  <path fill="none" stroke="#ea580c" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 250 C 90 280, 110 420, 134.5 390 C 165 350, 185 160, 199 140 C 230 110, 250 330, 263.5 350 C 328 440, 392.5 330, 457 380 C 521.5 270, 586 390, 650.5 290 C 715 270, 750 310, 780 280" />
  <path fill="none" stroke="#ea580c" strokeWidth="3.5" strokeDasharray="1,5" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 360 C 90 320, 110 330, 134.5 350 C 165 380, 185 140, 199 160 C 230 190, 250 390, 263.5 420 C 328 470, 392.5 390, 457 360 C 521.5 420, 586 380, 650.5 340 C 715 200, 750 240, 780 330" />
  <path fill="none" stroke="#ea580c" strokeWidth="2.5" strokeDasharray="6,4" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 220 C 90 380, 110 220, 134.5 180 C 165 130, 185 290, 199 260 C 230 220, 250 340, 263.5 360 C 328 390, 392.5 450, 457 400 C 521.5 330, 586 320, 650.5 210 C 715 240, 750 300, 780 230" />

  <path fill="none" stroke="#1e3a8a" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 140 C 90 260, 110 380, 134.5 330 C 165 270, 185 240, 199 210 C 230 170, 250 190, 263.5 200 C 328 290, 392.5 290, 457 240 C 521.5 230, 586 390, 650.5 450 C 715 350, 750 250, 780 150" />
  <path fill="none" stroke="#1e3a8a" strokeWidth="3.5" strokeDasharray="1,5" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 310 C 90 220, 110 130, 134.5 250 C 165 400, 185 360, 199 340 C 230 310, 250 210, 263.5 230 C 328 270, 392.5 350, 457 320 C 521.5 290, 586 340, 650.5 360 C 715 410, 750 490, 780 470" />
  <path fill="none" stroke="#1e3a8a" strokeWidth="2.5" strokeDasharray="6,4" strokeLinecap="round" strokeLinejoin="round"
        d="M 70 380 C 90 440, 110 290, 134.5 270 C 165 240, 185 310, 199 290 C 230 260, 250 240, 263.5 260 C 328 430, 392.5 490, 457 470 C 521.5 460, 586 420, 650.5 350 C 715 330, 750 310, 780 210" />

  <g transform="translate(475, 30)">
    <rect x="0" y="0" width="290" height="150" fill="#ffffff" fillOpacity="0.92" stroke="#cbd5e1" strokeWidth="1.5" rx="6" />
    <text x="145" y="22" fontSize="13" fontWeight="bold" fill="#1f2937" textAnchor="middle">Key Metrics</text>

    <text x="110" y="42" fontSize="10" fontWeight="bold" fill="#9ca3af" textAnchor="middle">SOLID</text>
    <text x="175" y="42" fontSize="10" fontWeight="bold" fill="#9ca3af" textAnchor="middle">DASHED</text>
    <text x="240" y="42" fontSize="10" fontWeight="bold" fill="#9ca3af" textAnchor="middle">DOTTED</text>

    <text x="15" y="64" fontSize="12" fontWeight="bold" fill="#374151">Alex</text>
    <line x1="90" y1="60" x2="130" y2="60" stroke="#059669" strokeWidth="3" strokeLinecap="round" />
    <line x1="155" y1="60" x2="195" y2="60" stroke="#059669" strokeWidth="3" strokeDasharray="5,3" strokeLinecap="round" />
    <line x1="220" y1="60" x2="260" y2="60" stroke="#059669" strokeWidth="4" strokeDasharray="1,4" strokeLinecap="round" />

    <text x="15" y="86" fontSize="12" fontWeight="bold" fill="#374151">Avery</text>
    <line x1="90" y1="82" x2="130" y2="82" stroke="#7c3aed" strokeWidth="3" strokeLinecap="round" />
    <line x1="155" y1="82" x2="195" y2="82" stroke="#7c3aed" strokeWidth="3" strokeDasharray="5,3" strokeLinecap="round" />
    <line x1="220" y1="82" x2="260" y2="82" stroke="#7c3aed" strokeWidth="4" strokeDasharray="1,4" strokeLinecap="round" />

    <text x="15" y="108" fontSize="12" fontWeight="bold" fill="#374151">Dakota</text>
    <line x1="90" y1="104" x2="130" y2="104" stroke="#ea580c" strokeWidth="3" strokeLinecap="round" />
    <line x1="155" y1="104" x2="195" y2="104" stroke="#ea580c" strokeWidth="3" strokeDasharray="5,3" strokeLinecap="round" />
    <line x1="220" y1="104" x2="260" y2="104" stroke="#ea580c" strokeWidth="4" strokeDasharray="1,4" strokeLinecap="round" />

    <text x="15" y="130" fontSize="12" fontWeight="bold" fill="#374151">Phoenix</text>
    <line x1="90" y1="126" x2="130" y2="126" stroke="#1e3a8a" strokeWidth="3" strokeLinecap="round" />
    <line x1="155" y1="126" x2="195" y2="126" stroke="#1e3a8a" strokeWidth="3" strokeDasharray="5,3" strokeLinecap="round" />
    <line x1="220" y1="126" x2="260" y2="126" stroke="#1e3a8a" strokeWidth="4" strokeDasharray="1,4" strokeLinecap="round" />
  </g>
</svg>

  );
}
