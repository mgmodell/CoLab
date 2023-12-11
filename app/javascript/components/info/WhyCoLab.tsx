import React, { useEffect, useState } from "react";
import { useSpring, animated, config } from "react-spring";
import NormallyFunctioningGroup from "../svgs/NormallyFunctioningGroup";
import { useLocation, useNavigate } from "react-router-dom";
import { fontStyle } from "@mui/system";
import StudentConcern from "../svgs/StudentConcern";
import SocialLoafing from "../svgs/SocialLoafing";

type Props = {
    height: number;
    width: number
}

export default function WhyCoLab(props) {
    const viewBox = [0, 0, 400, 225].join(' ');

    const location = useLocation();
    const navigate = useNavigate( );
    const [curScene, setCurScene ] = useState( 0 );

    const NavSpecs = {
        navDots: 7,
        dotSpacing: 20,
        dotRad: 4,
        centerY: 215,

    }

    const [titleSpring, titleApi] = useSpring(() => ({
        x: 10,
        y: 100,
        width: 175,
        height: 200,
        opacity: 1,

    }))

    const NF_SVG = [
        {
        x: 185,
        y: 20,
        height: 200,
        width: 200,
        opacity: 1,

        },
        {
        x: 265,
        y: 38,
        height: 57,
        width: 57,
        opacity: 1,

        },
        {
        x: 265,
        y: 38,
        height: 57,
        width: 57,
        opacity: 0,

        },
    ]

    const SL_SVG = [
        {
        x: 265,
        y: 38,
        height: 57,
        width: 57,
        opacity: 0,
        },
        {
        x: 265,
        y: 38,
        height: 57,
        width: 57,
        opacity: 0,
        },
        {
        x: 265,
        y: 38,
        height: 57,
        width: 57,
        opacity: 1,
        },
        {
        x: 10,
        y: 19,
        height: 150,
        width: 150,
        opacity: 1,
        },
    ]

    const TS_SVG = [
        {
        x: 190,
        y: 10,
        height: 210,
        width: 210,
        opacity: 0,
        },
        {
        x: 190,
        y: 10,
        height: 210,
        width: 210,
        opacity: 1,
        },
        {
        x: 190,
        y: 10,
        height: 210,
        width: 210,
        opacity: 1,
        },
        {
        x: 190,
        y: 10,
        height: 210,
        width: 210,
        opacity: 0,
        },
    ]

    const [normallyFunctioningSpring, normallyFunctioningApi] = useSpring(() => (
        NF_SVG[ 0 ]
    ))
    const [teacherStudentSpring, teacherStudentApi] = useSpring(() => (
        TS_SVG[ 0 ]
    ))
    const [socialLoafingSpring, socialLoafingApi] = useSpring(() => (
        SL_SVG[ 0 ]
    ))

    const [ arrowNavSpring ] = useSpring(
        () =>({
            from: {
                opacity: .5
            },
            to: {
                opacity: 1
            },
            config: config.gentle,
            loop: {
                reverse: true,
            }

        })
    )

    const curNav: JSX.Element[] = [];
    const navDotsStart = 200 - ((NavSpecs.navDots / 2) * NavSpecs.dotSpacing);

    for (let index = 0; index < NavSpecs.navDots; index++) {
        curNav.push(
            <circle
                id={`navDot-${index}`}
                key={`navDot-${index}`}
                cx={navDotsStart + (index * NavSpecs.dotSpacing)}
                cy={NavSpecs.centerY}
                r={NavSpecs.dotRad}
                stroke={'midnightblue'}
                fill={ index <= curScene ? '#ffff00' : 'midnightblue'}
                strokeWidth={1.5}
                opacity={1}
                onClick={(event) =>{
                    setScene( index );
                    navigate( `why#${index}`);
                }}
            />
        )

    }
    const rightArrowLoc = 200 + ((NavSpecs.navDots + 1) / 2) * NavSpecs.dotSpacing;

    const setScene = ( sceneNum : number ) => {
        setCurScene( sceneNum );
        navigate( `/welcome/why#${sceneNum}`);


    }

    useEffect( () =>{
        normallyFunctioningApi.start({
            to: NF_SVG[ curScene ]
        })
        teacherStudentApi.start({
            to: TS_SVG[ curScene ]
        })
        socialLoafingApi.start({
            to: SL_SVG[ curScene ]
        })


    }, [curScene])

    useEffect( () =>{
        if( location.hash.length < 1 ){
            setScene( 0 );
        } else {
            setScene( parseInt( location.hash.substring( 1 )));
        }

    }, [])

    curNav.push(
        <g
            id='right-arrow'
            key='right-arrow'
            onClick={( event ) =>{
                setScene( curScene + 1 );
            }}
            opacity={ curScene < NavSpecs.navDots ? 1 : 0}
            >

        <circle
            cx={rightArrowLoc - ( NavSpecs.dotRad / 2 )}
            cy={NavSpecs.centerY}
            r={NavSpecs.dotRad * 1.75}
            fill={'midnightblue'}
            stroke={'midnightblue'}
            />
        <animated.polyline
            points={`${rightArrowLoc - NavSpecs.dotRad},${NavSpecs.centerY - NavSpecs.dotRad} ${rightArrowLoc},${NavSpecs.centerY} ${rightArrowLoc - NavSpecs.dotRad},${NavSpecs.centerY + NavSpecs.dotRad}`}
            x1={rightArrowLoc}
            y1={NavSpecs.centerY}

            style={{
                stroke: 'azure',
                strokeWidth: 2,
                strokeLinecap: 'round',
                strokeLinejoin: 'round',
                fill: 'none',
                ...arrowNavSpring,
            }} />
        </g>
    )

    return (
        <svg
            height={props.height}
            width={props.width}
            viewBox={viewBox}
            xmlns="http://www.w3.org/2000/svg"
        >
            <animated.svg
                viewBox={[0, 0, 6780, 5568].join(" ")}
                preserveAspectRatio="xMidYMid meet"
                xmlns="http://www.w3.org/2000/svg"
                opacity={teacherStudentSpring.opacity}
                x={teacherStudentSpring.x}
                y={teacherStudentSpring.y}
                height={teacherStudentSpring.height}
                width={teacherStudentSpring.width}
                 >
                <StudentConcern framed
                />
            </animated.svg>
            <animated.svg
                viewBox={[0, 0, 6761, 5583].join(" ")}
                preserveAspectRatio="xMidYMid meet"
                xmlns="http://www.w3.org/2000/svg"
                opacity={normallyFunctioningSpring.opacity}
                x={normallyFunctioningSpring.x}
                y={normallyFunctioningSpring.y}
                height={normallyFunctioningSpring.height}
                width={normallyFunctioningSpring.width}
                 >

                <NormallyFunctioningGroup />
            </animated.svg>
            <animated.svg
                viewBox={[0, 0, 6761, 5583].join(" ")}
                preserveAspectRatio="xMidYMid meet"
                xmlns="http://www.w3.org/2000/svg"
                opacity={socialLoafingSpring.opacity}
                x={socialLoafingSpring.x}
                y={socialLoafingSpring.y}
                height={socialLoafingSpring.height}
                width={socialLoafingSpring.width}
                 >

                <SocialLoafing />
            </animated.svg>

            <animated.foreignObject
                style={{
                    ...titleSpring
                }} >
                <p
                    style={{ color: 'azure' }}
                    >
                    We dream of teamwork that looks like this
                </p>
            </animated.foreignObject>
            {
                curNav
            }

        </svg>
    )

}