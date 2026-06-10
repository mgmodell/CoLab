import React, { useEffect, useState, useRef } from "react";
import { logocolors } from "./Logo";

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

export default function BingoBoards(props: Props) {
    const height = props.height || 100;
    const width = props.width || 72;

    const viewBox = [0, 0, 130, 150].join(" ");
    const cells = terms.map(item =>({ sortKey: Math.random(), value: item}))
                       .sort((a, b) =>  a.sortKey - b.sortKey);
    cells.length = 25;
    cells[12] = { sortKey: 0, value: "*" };

    const count = Math.min( props.count ?? logocolors.length, logocolors.length);

    const cards = Array(count).fill(0).map((_, index) => {
        return {
            rotate: (Math.random() * 20) - 10,
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
        {cards.map((card, index) => (
            <g id={"card_" + index}
                transform={`rotate(${card.rotate}, 10, 90) scale( 0.7 ) translate( ${20 + index}, ${(index * -2) + 10} )`}
            >

        <rect x="1" y="0" width="70" height="92" fill="#fff" 
            stroke="#000" strokeWidth="2"
        />
        <rect x="0" y="23" width="70" height="70" fill="#fff" 
            stroke="#000" strokeWidth="2"
        />
        <rect x="5" y="5" width="60" height="12" fill={card.color} />
        <text
        textAnchor="middle"
        fontFamily="Noto Sans JP"
        fontSize="11"
        fill="#000000"
        x="35"
        y="15">B I N G O</text>
        {
            cells.map((termObj, index) => {
                const term = termObj.value;
                return(
                    <g>
                    <rect
                        x={ 1+ (index % 5) * 14}
                        y={23 + Math.floor(index / 5) * 14}
                        width="14" height="14" fill="#fff" stroke="#000" strokeWidth="1"/>
                    <text
                    height="12" width="12"
                    textAnchor="middle"
                    fontFamily="Noto Sans JP"
                    fontSize={'*' === term ? 10 : 3}
                    strokeWidth="0"
                    fill={'*' === term ? props.color || "#f44" : "#000000"}
                    x={7 + (index % 5) * 14}
                    y={28 + Math.floor(index / 5) * 15}>{term}</text>
                    {
                        (Math.random() * 8 ) > 1 ? (
                            <></>
                        ) : (
                            <circle
                            cx={7 + (index % 5) * 14}
                            cy={28 + Math.floor(index / 5) * 15 - 3}
                            opacity={0.4}
                            r="5" fill="#f44"/>
                        )

                    }
                    </g>

                )
            })
        }
        </g>
        ))}

    </svg>
  );
}
