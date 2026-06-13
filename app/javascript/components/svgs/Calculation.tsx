import React, { useEffect, useState, useRef } from "react";
import { logocolors } from "./Logo";
import { bingoTerms } from "./BingoBoards";
import { useSpring, animated } from "@react-spring/web";

type Props = {
  height?: number;
  width?: number;
  count?: number;
};

const factors = [
    "home state",
    "home country",
    "major",
    "age",
    "gender",
    "group experiences",
    "years in school",
    "languages",
    "impairments"
]

export default function Calculation(props: Props) {
    const height = props.height || 100;
    const width = props.width || 72;

    const [wordStar, setWordStar] = useState(factors[0]);
    const starLocs = [
        { x: 0, y: 0 },
        { x: 0, y: 100 },
        { x: 0, y: 75 },
        { x: 0, y: 25 }
    ]
    const finalStarLoc = { x: 65, y: 70 };
    const [wordStarFrom, setWordStarFrom] = useState( starLocs[0] );
    const [wordStarColor, setWordStarColor] = useState( logocolors[0] );

    const [perspectiveColor, setPerspectiveColor] = useState( 0 );
    const [perspective, setPerspective] = useSpring(() => ({
        from: { color: logocolors[perspectiveColor] },
        to: { color: logocolors[perspectiveColor - 1 < 0 ? logocolors.length - 1 : perspectiveColor - 1] },
        config: { duration: 1500 },
        onRest: () => {
            const nextColor = Math.floor(Math.random() * logocolors.length);
            setPerspectiveColor(nextColor);
            setPerspective.start({
                from: { color: logocolors[perspectiveColor] },
                to: { color: logocolors[perspectiveColor - 1 < 0 ? logocolors.length - 1 : perspectiveColor - 1] },
                config: { duration: 1500 }
            })
        }
     }));

    const [starFlight, starFlightApi] = useSpring(() => ({
        from: { x: wordStarFrom.x, y: wordStarFrom.y, scale: 1, opacity: 0 },
        to: {
            x: finalStarLoc.x, y: finalStarLoc.y, scale: 0.1 , opacity: 1 },
        config: { duration: 1000 },
        onRest: () => {
            const nextIndex = Math.floor(Math.random() * factors.length);
            setWordStar(factors[nextIndex]);
            const nextLoc = starLocs[Math.floor(Math.random() * starLocs.length)];
            setWordStarFrom(nextLoc);
            const nextColor = logocolors[Math.floor(Math.random() * logocolors.length)];
            setWordStarColor(nextColor);
            starFlightApi.start({
                from: { x: nextLoc.x, y: nextLoc.y, scale: 1, opacity: 0 },
                to: { x: finalStarLoc.x, y: finalStarLoc.y, scale: 0.1, opacity: 1 },
                config: { duration: 1500 }
            });
        }

    }));

    const viewBox = [0, 0, 100, 100].join(" ");
    const cells = factors.map(item =>({ sortKey: Math.random(), value: item}))
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
        <rect x="0" y="0" width="100" height="100" opacity="0" fill="#fff" />
        <g
            transform="translate(40, 45) scale(0.5)">
            <path d="M 75,20 L 25,20 L 55,50 L 25,80 L 75,80 L 68,68 L 47,68 L 65,50 L 47,32 L 68,32 Z" fill="#1e293b" />
            <animated.text
                textAnchor="middle"
                fontFamily="Noto Sans JP"
                fontSize="14"
                fill={perspective.color}
                x="80"
                y="55">Ideas</animated.text>

        </g>

        <animated.text
            x={starFlight.x} y={starFlight.y}
            opacity={starFlight.opacity}
            fontSize={starFlight.scale.to(s => 20 * s)}
            fill={"#000"} textAnchor="middle">{wordStar}</animated.text>

    </svg>
  );
}
