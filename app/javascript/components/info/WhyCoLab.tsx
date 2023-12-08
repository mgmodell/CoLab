import React from "react";
import { useSpring, animated, config } from "react-spring";
import NormallyFunctioningGroup from "../svgs/NormallyFunctioningGroup";

type Props = {
    height: number;
    width: number
}
export default function WhyCoLab( props ){
    const viewBox = [0,0,400,225].join(' ');

    return(
        <svg
            height={props.height}
            width={props.width}
            viewBox={viewBox}
            xmlns="http://www.w3.org/2000/svg"
            >
                <NormallyFunctioningGroup
                    svgPos={{
                        x: 85,
                        y: 20,
                        scale: .05
                    }}
                    />
            <animated.text
                x={10}
                y={100}
                style={{
                    fontWeight: "normal",
                    fontSize: '9',
                    lineHeight: 1.25,
                    fontFamily: 'sans-serif',

                }
                }
                >
                    We dream of teamwork that looks like this
                </animated.text>
            
        </svg>
    )

}