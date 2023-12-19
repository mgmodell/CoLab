import React, { useEffect, useState } from "react";
import { useSpring, animated, config } from "react-spring";
import NormallyFunctioningGroup from "../svgs/NormallyFunctioningGroup";
import { useLocation, useNavigate } from "react-router-dom";
import { fontStyle } from "@mui/system";
import StudentConcern from "../svgs/StudentConcern";
import SocialLoafing from "../svgs/SocialLoafing";
import LeaveItToGeorge from "../svgs/LeaveItToGeorge";
import GroupDomination from "../svgs/GroupDomination";
import DivisionOfLabor from "../svgs/DivisionOfLabor";
import { Container, Row, Col } from "react-grid-system";
import EmbeddedHTMLInSVG from "../infrastructure/EmbeddedHTMLInSVG";

type Props = {
    height: number;
    width: number
}

export default function WhyCoLab(props) {
    const viewBox = [0, 0, 400, 225].join(' ');

    const location = useLocation();
    const navigate = useNavigate();
    const [curScene, setCurScene] = useState(0);

    const NavSpecs = {
        navDots: 6,
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

    const titles = [
        (<p style={{ color: 'azure' }}>
            We dream of teamwork that looks like this
        </p>),
        (<p style={{ color: 'azure' }}>
            But we often learn that&hellip;
        </p>),
        (<p style={{ color: 'azure' }}>
            It feels like an inequitable experience
        </p>),
        (<p style={{ color: 'azure' }}>
            And negative experiences take many shapes
        </p>),
        (<p style={{ color: 'azure' }}>
            Or possibly the results just feel cookie-cutter and boring?
        </p>),
        (
            <Container
                style={{
                    color: 'azure',
                    fontSize: '16px'
                }}
            >
                <Row>
                    <Col sm={8}>
                        <p>CoLab.online can help!</p>
                        <ul style={{
                            fontSize: '10px'
                        }}>
                            <li>Weekly self- and peer-assessment check-ins</li>
                            <li>Growth focused (not judgment)</li>
                            <li>Visualizations</li>
                            <li>Diversity-focused group composition</li>
                            <li>Gamified collaborative reading</li>
                            <li>Simulated team experiences</li>
                            <li>Iterative assignments</li>
                        </ul>
                    </Col>
                    <Col sm={4}>
                        <ul>
                            <li onClick={()=>{
                                navigate('/welcome/student');

                            }}>
                                Student?
                            </li>
                        </ul>
                    </Col>
                </Row>
            </Container>
        )


    ]

    const TXT = [
        {
            x: 10,
            y: 100,
            width: 175,
            height: 200,
            opacity: 1,
        },
        {
            x: 10,
            y: 125,
            width: 175,
            height: 125,
            opacity: 1,
        },
        {
            x: 10,
            y: 125,
            width: 175,
            height: 125,
            opacity: 1,
        },
        {
            x: 5,
            y: 155,
            width: 350,
            height: 50,
            opacity: 1,
        },
        {
            x: 5,
            y: 155,
            width: 350,
            height: 50,
            opacity: 1,
        },
        {
            x: 5,
            y: 10,
            width: 350,
            height: 210,
            opacity: 1,
        },

    ]

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
            height: 125,
            width: 125,
            opacity: 1,
        },
        {
            x: 10,
            y: 19,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 10,
            y: 19,
            height: 150,
            width: 150,
            opacity: 0,
        },
    ]
    const LITG_SVG = [
        {
            x: 255,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 255,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 255,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 255,
            y: 25,
            height: 120,
            width: 120,
            opacity: 1,
        },
        {
            x: 255,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 255,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
    ]
    const GD_SVG = [
        {
            x: 155,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 255,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 255,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 125,
            y: 35,
            height: 150,
            width: 150,
            opacity: 1,
        },
        {
            x: 125,
            y: 35,
            height: 180,
            width: 180,
            opacity: 0,
        },
        {
            x: 125,
            y: 35,
            height: 180,
            width: 180,
            opacity: 0,
        },
    ]
    const DL_SVG = [
        {
            x: 155,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 255,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 255,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 125,
            y: 35,
            height: 150,
            width: 150,
            opacity: 0,
        },
        {
            x: 120,
            y: 25,
            height: 175,
            width: 175,
            opacity: 1,
        },
        {
            x: 255,
            y: 25,
            height: 150,
            width: 150,
            opacity: 0,
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
            opacity: 0,
        },
    ]

    const [normallyFunctioningSpring, normallyFunctioningApi] = useSpring(() => (
        NF_SVG[0]
    ))
    const [teacherStudentSpring, teacherStudentApi] = useSpring(() => (
        TS_SVG[0]
    ))
    const [socialLoafingSpring, socialLoafingApi] = useSpring(() => (
        SL_SVG[0]
    ))
    const [leaveItToGeorgeSpring, leaveItToGeorgeApi] = useSpring(() => (
        LITG_SVG[0]
    ))
    const [groupDominationSpring, groupDominationApi] = useSpring(() => (
        GD_SVG[0]
    ))
    const [divisionOfLaborSpring, divisionOfLaborApi] = useSpring(() => (
        DL_SVG[0]
    ))

    const [arrowNavSpring] = useSpring(
        () => ({
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
                fill={index <= curScene ? '#ffff00' : 'midnightblue'}
                strokeWidth={1.5}
                opacity={1}
                onClick={(event) => {
                    setScene(index);
                    navigate(`why#${index}`);
                }}
            />
        )

    }
    const rightArrowLoc = 200 + ((NavSpecs.navDots + 1) / 2) * NavSpecs.dotSpacing;

    const setScene = (sceneNum: number) => {
        setCurScene(sceneNum);
        navigate(`/welcome/why#${sceneNum}`);


    }

    useEffect(() => {
        titleApi.start({
            to: TXT[curScene]
        })
        normallyFunctioningApi.start({
            to: NF_SVG[curScene]
        })
        teacherStudentApi.start({
            to: TS_SVG[curScene]
        })
        socialLoafingApi.start({
            to: SL_SVG[curScene]
        })
        leaveItToGeorgeApi.start({
            to: LITG_SVG[curScene]
        })
        groupDominationApi.start({
            to: GD_SVG[curScene]
        })
        divisionOfLaborApi.start({
            to: DL_SVG[curScene]
        })


    }, [curScene])

    useEffect(() => {
        if (location.hash.length < 1) {
            setScene(0);
        } else {
            setScene(parseInt(location.hash.substring(1)));
        }

    }, [])

    curNav.push(
        <g
            id='right-arrow'
            key='right-arrow'
            onClick={(event) => {
                setScene(curScene + 1);
            }}
            //Account for the off-by-one of 0-indexing
            opacity={curScene < ( NavSpecs.navDots - 1 ) ? 1 : 0}
        >

            <circle
                cx={rightArrowLoc - (NavSpecs.dotRad / 2)}
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

                <SocialLoafing oliveColor={'olive'} />
            </animated.svg>
            <animated.svg
                viewBox={[0, 0, 6753, 5590].join(" ")}
                preserveAspectRatio="xMidYMid meet"
                xmlns="http://www.w3.org/2000/svg"
                opacity={leaveItToGeorgeSpring.opacity}
                x={leaveItToGeorgeSpring.x}
                y={leaveItToGeorgeSpring.y}
                height={leaveItToGeorgeSpring.height}
                width={leaveItToGeorgeSpring.width}
            >

                <LeaveItToGeorge />
            </animated.svg>
            <animated.svg
                viewBox={[0, 0, 6753, 5590].join(" ")}
                preserveAspectRatio="xMidYMid meet"
                xmlns="http://www.w3.org/2000/svg"
                opacity={groupDominationSpring.opacity}
                x={groupDominationSpring.x}
                y={groupDominationSpring.y}
                height={groupDominationSpring.height}
                width={groupDominationSpring.width}
            >

                <GroupDomination bgColor={'aliceblue'} />
            </animated.svg>
            <animated.svg
                viewBox={[0, 0, 6753, 5590].join(" ")}
                preserveAspectRatio="xMidYMid meet"
                xmlns="http://www.w3.org/2000/svg"
                opacity={divisionOfLaborSpring.opacity}
                x={divisionOfLaborSpring.x}
                y={divisionOfLaborSpring.y}
                height={divisionOfLaborSpring.height}
                width={divisionOfLaborSpring.width}
            >

                <DivisionOfLabor bgColor={'aliceblue'} />
            </animated.svg>

            <EmbeddedHTMLInSVG
                width={titleSpring.width}
                height={titleSpring.height}
                >
                {titles[curScene]}

                </EmbeddedHTMLInSVG>
            {
                curNav
            }

        </svg>
    )

}