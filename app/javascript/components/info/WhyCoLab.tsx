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
                        x: 200,
                        y: 20,
                        scale: .01,
                        height: 200,
                        width: 200,
                    }}
                    />
            <foreignObject x="10" y="100" width="150" height="200">
<p xmlns="http://www.w3.org/1999/xhtml" style={{color: 'azure'}}>
                    We dream of teamwork that looks like this
    </p>
</foreignObject>
            
        </svg>
    )

}