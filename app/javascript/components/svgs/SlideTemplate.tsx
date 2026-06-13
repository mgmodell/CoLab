import React, { useEffect, useState, useRef } from "react";
import { logocolors } from "./Logo";
import { bingoTerms } from "./BingoBoards";
import { useSpring, animated } from "@react-spring/web";

type Props = {
  height?: number;
  width?: number;
  count?: number;
};

const terms = [
    "team",
    "collaborate",
    "communicate",
    "creativity",
    "adaptable",
    "social",
    "challenge",
    "helping",
    "leadership",
    "empathy",
    "encourage",
    "resilience",
    "conflict",
    "curiosity",
    "initiative",
    "trust",
    "listening",
    "logistics",
    "peer",
    "group",
    "participate",
    "roles",
    "criticism",
    "delegate",
    "feedback",
    "compromise",
]

export default function SlideTemplate(props: Props) {
    const height = props.height || 100;
    const width = props.width || 72;

    const [wordStar, setWordStar] = useState(terms[0]);
    const starLocs = [
        { x: 0, y: 0 },
        { x: 0, y: 150 },
        { x: 130, y: 0 },
        { x: 130, y: 150 }
    ]
    const finalStarLoc = { x: 70, y: 85 };
    const [wordStarFrom, setWordStarFrom] = useState( starLocs[0] );

    const [starFlight, starFlightApi] = useSpring(() => ({
        from: { x: wordStarFrom.x, y: wordStarFrom.y, scale: 1, opacity: 0 },
        to: {
            x: finalStarLoc.x, y: finalStarLoc.y, scale: 0.1 , opacity: 1 },
        config: { duration: 1000 },
        onRest: () => {
            const nextIndex = Math.floor(Math.random() * terms.length);
            setWordStar(terms[nextIndex]);
            const nextLoc = starLocs[Math.floor(Math.random() * starLocs.length)];
            setWordStarFrom(nextLoc);
            starFlightApi.start({
                from: { x: nextLoc.x, y: nextLoc.y, scale: 1, opacity: 0 },
                to: { x: finalStarLoc.x, y: finalStarLoc.y, scale: 0.1, opacity: 1 },
                config: { duration: 1000 }
            });
        }

    }));

    const viewBox = [0, 0, 130, 150].join(" ");
    const cells = terms.map(item =>({ sortKey: Math.random(), value: item}))
                       .sort((a, b) =>  a.sortKey - b.sortKey);
    cells.length = 25;
    cells[12] = { sortKey: 0, value: "*" };

    const count = Math.min( props.count ?? logocolors.length, logocolors.length);

    const slides = Array(count).fill(0).map((_, index) => {
        return {
            //rotate: (Math.random() * 20) - 10,
            color: logocolors[index % logocolors.length]
        }
    })

  return (
    <svg
      height={height}
      width={width}
      viewBox={viewBox}
      preserveAspectRatio="xMidYMid meet"
      xmlns="http://www.w3.org/2000/svg"
    >
        {slides.map((slide, index) => (
            <g id={"slide" + index}
                transform={`translate( 30, 40 ) scale( ${index / slides.length } )`}
            >

              <rect x="30" y="30" width="70" height="50" fill={slide.color} stroke="#000" 
                  strokeWidth="2"
              />
              <line x1="37" y1="37" x2="90" y2="37"
                stroke="#000" strokeWidth="6" />
              <line x1="40" y1="50" x2="90" y2="50"
                strokeDasharray="3 7 8 6 3 8 1"
                stroke="#000" strokeWidth="3" />
              <line x1="40" y1="60" x2="87" y2="60"
                stroke="#000" strokeWidth="3" />
              <line x1="40" y1="68" x2="87" y2="68"
                stroke="#000" strokeWidth="3" />

            </g>
        ))}
        <animated.text
            x={starFlight.x} y={starFlight.y}
            opacity={starFlight.opacity}
            fontSize={starFlight.scale.to(s => 18 * s)}
            fill="#000" textAnchor="middle">{wordStar}</animated.text>

    </svg>
  );
}
