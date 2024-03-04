import React, { useEffect, useState } from "react";
import { useSpring, animated, config } from "react-spring";
import NormallyFunctioningGroup from "../svgs/NormallyFunctioningGroup";
import { useLocation, useNavigate } from "react-router-dom";
import StudentConcern from "../svgs/StudentConcern";
import SocialLoafing from "../svgs/SocialLoafing";
import LeaveItToGeorge from "../svgs/LeaveItToGeorge";
import GroupDomination from "../svgs/GroupDomination";
import DivisionOfLabor from "../svgs/DivisionOfLabor";
import { Container, Row, Col } from "react-grid-system";
import EmbeddedHTMLInSVG from "../infrastructure/EmbeddedHTMLInSVG";
import { useTranslation } from "react-i18next";

type Props = {
  height: number;
  width: number;
};

export default function WhyCoLab(props: Props) {
  const category = 'intro';
  const { t } = useTranslation( category);

  const viewBox = [0, 0, 400, 225].join(" ");

  const location = useLocation();
  const navigate = useNavigate();
  const [curScene, setCurScene] = useState(0);

  const NavSpecs = {
    navDots: 7,
    dotSpacing: 20,
    dotRad: 4,
    centerY: 215
  };

  const [title1Spring, title1Api] = useSpring(() => ({
    x: 10,
    y: 100,
    width: 175,
    height: 200,
    opacity: 1
  }));
  
  const [title2Spring, title2Api] = useSpring(() => ({
    x: 10,
    y: 100,
    width: 175,
    height: 200,
    opacity: 1
  }));

  const titles_one = [
    <p >{t('why_slides.captions.one_one')}</p>,
    <p >{t('why_slides.captions.two_one')}</p>,
    <p >{t('why_slides.captions.three_one')}</p>,
    <p >{t('why_slides.captions.four_one')}</p>,
    <p >{t('why_slides.captions.five_one')}</p>,
    <p >{t('why_slides.captions.six_one')}</p>,
    <Container
      style={{
        color: "azure",
        fontSize: "16px"
      }}
    >
      <Row>
        <Col sm={8}>
          <p>{t('why_slides.captions.seven_one.title')}</p>
          <ul
            style={{
              fontSize: "16px"
            }}
          >
            <li>{t('why_slides.captions.seven_one.check-ins')}</li>
            <li>{t('why_slides.captions.seven_one.growth')}</li>
            <li>{t('why_slides.captions.seven_one.visualizations')}</li>
            <li>{t('why_slides.captions.seven_one.diversity')}</li>
            <li>{t('why_slides.captions.seven_one.gamification')}</li>
            <li>{t('why_slides.captions.seven_one.simulations')}</li>
            <li>{t('why_slides.captions.seven_one.iterative_assignments')}</li>
          </ul>
        </Col>
        <Col sm={4}>
          <p>Are you a&hellip;</p>
          <ul>
            <li>
              <a href="/welcome/student">Student?</a>
            </li>
            <li>
              <a href="/welcome/instructor">Instructor?</a>
            </li>
          </ul>
        </Col>
      </Row>
    </Container>
  ];
  const titles_two = [
    <p >{t('why_slides.captions.one_two')}</p>,
    <p >{t('why_slides.captions.two_two')}</p>,
    <p >{t('why_slides.captions.three_two')}</p>,
    <p >{t('why_slides.captions.four_two')}</p>,
    <p >{t('why_slides.captions.five_two')}</p>,
    <p >{t('why_slides.captions.six_two')}</p>,
    <p >{t('why_slides.captions.seven_two')}</p>,
  ];

  const TXT_1 = [
    {
      x: 10,
      y: 50,
      width: 175,
      height: 200,
      opacity: 1
    },
    {
      x: 10,
      y: 100,
      width: 175,
      height: 125,
      opacity: 1
    },
    {
      x: 10,
      y: 120,
      width: 175,
      height: 125,
      opacity: 1
    },
    {
      x: 5,
      y: 160,
      width: 350,
      height: 50,
      opacity: 1
    },
    {
      x: 5,
      y: 160,
      width: 350,
      height: 50,
      opacity: 1
    },
    {
      x: 5,
      y: 10,
      width: 350,
      height: 210,
      opacity: 1
    }
  ];

  const TXT_TWO = [
    {
      x: 10,
      y: 30,
      width: 175,
      height: 200,
      opacity: 1
    },
    {
      x: 10,
      y: 100,
      width: 175,
      height: 125,
      opacity: 1
    },
    {
      x: 10,
      y: 120,
      width: 175,
      height: 125,
      opacity: 1
    },
    {
      x: 5,
      y: 160,
      width: 350,
      height: 50,
      opacity: 1
    },
    {
      x: 5,
      y: 160,
      width: 350,
      height: 50,
      opacity: 1
    },
    {
      x: 5,
      y: 10,
      width: 350,
      height: 210,
      opacity: 1
    }
  ];

  //Normally function group image
  const NF_SVG = [
    {
      x: 200,
      y: 40,
      height: 200,
      width: 200,
      opacity: 1
    },
    {
      x: 265,
      y: 38,
      height: 57,
      width: 57,
      opacity: 0
    },
    {
      x: 265,
      y: 38,
      height: 57,
      width: 57,
      opacity: 0
    },
    {
      x: 265,
      y: 38,
      height: 57,
      width: 57,
      opacity: 0
    },
    {
      x: 265,
      y: 38,
      height: 57,
      width: 57,
      opacity: 0
    },
    {
      x: 185,
      y: 38,
      height: 57,
      width: 57,
      opacity: 1
    }
  ];

  // Social Loafing Image
  const SL_SVG = [
    {
      x: 265,
      y: 38,
      height: 57,
      width: 57,
      opacity: 0
    },
    {
      x: 265,
      y: 38,
      height: 57,
      width: 57,
      opacity: 0
    },
    {
      x: 265,
      y: 38,
      height: 57,
      width: 57,
      opacity: 0
    },
    {
      x: 200,
      y: 150,
      height: 125,
      width: 125,
      opacity: 1
    },
    {
      x: 185,
      y: 38,
      height: 150,
      width: 150,
      opacity: 1
    },
    {
      x: 10,
      y: 19,
      height: 150,
      width: 150,
      opacity: 0
    }
  ];
  // Leave it to George image
  const LITG_SVG = [
    {
      x: 255,
      y: 25,
      height: 150,
      width: 150,
      opacity: 0
    },
    {
      x: 255,
      y: 25,
      height: 150,
      width: 150,
      opacity: 0
    },
    {
      x: 200,
      y: 150,
      height: 150,
      width: 150,
      opacity: 1
    },
    {
      x: 255,
      y: 25,
      height: 120,
      width: 120,
      opacity: 0
    },
    {
      x: 255,
      y: 25,
      height: 150,
      width: 150,
      opacity: 0
    },
    {
      x: 255,
      y: 25,
      height: 150,
      width: 150,
      opacity: 0
    }
  ];
  // Group domination image
  const GD_SVG = [
    {
      x: 155,
      y: 25,
      height: 150,
      width: 150,
      opacity: 0
    },
    {
      x: 200,
      y: 150,
      height: 150,
      width: 150,
      opacity: 1
    },
    {
      x: 255,
      y: 25,
      height: 150,
      width: 150,
      opacity: 0
    },
    {
      x: 125,
      y: 35,
      height: 150,
      width: 150,
      opacity: 0
    },
    {
      x: 125,
      y: 35,
      height: 180,
      width: 180,
      opacity: 0
    },
    {
      x: 125,
      y: 35,
      height: 180,
      width: 180,
      opacity: 0
    }
  ];
  //Division of Labor image
  const DL_SVG = [
    {
      x: 155,
      y: 25,
      height: 150,
      width: 150,
      opacity: 0
    },
    {
      x: 255,
      y: 25,
      height: 150,
      width: 150,
      opacity: 0
    },
    {
      x: 255,
      y: 25,
      height: 150,
      width: 150,
      opacity: 0
    },
    {
      x: 125,
      y: 35,
      height: 150,
      width: 150,
      opacity: 0
    },
    {
      x: 120,
      y: 25,
      height: 175,
      width: 175,
      opacity: 0
    },
    {
      x: 255,
      y: 25,
      height: 150,
      width: 150,
      opacity: 0
    }
  ];

  //Teacher and Student image
  const TS_SVG = [
    {
      x: 190,
      y: 10,
      height: 210,
      width: 210,
      opacity: 0
    },
    {
      x: 190,
      y: 10,
      height: 210,
      width: 210,
      opacity: 0
    },
    {
      x: 190,
      y: 10,
      height: 210,
      width: 210,
      opacity: 0
    },
    {
      x: 190,
      y: 10,
      height: 210,
      width: 210,
      opacity: 0
    },
    {
      x: 200,
      y: 150,
      height: 210,
      width: 210,
      opacity: 1
    },
    {
      x: 200,
      y: 150,
      height: 210,
      width: 210,
      opacity: 1
    }
  ];

  const [normallyFunctioningSpring, normallyFunctioningApi] = useSpring(
    () => NF_SVG[0]
  );
  const [teacherStudentSpring, teacherStudentApi] = useSpring(() => TS_SVG[0]);
  const [socialLoafingSpring, socialLoafingApi] = useSpring(() => SL_SVG[0]);
  const [leaveItToGeorgeSpring, leaveItToGeorgeApi] = useSpring(
    () => LITG_SVG[0]
  );
  const [groupDominationSpring, groupDominationApi] = useSpring(
    () => GD_SVG[0]
  );
  const [divisionOfLaborSpring, divisionOfLaborApi] = useSpring(
    () => DL_SVG[0]
  );

  const [arrowNavSpring] = useSpring(() => ({
    from: {
      opacity: 0.5
    },
    to: {
      opacity: 1
    },
    config: config.gentle,
    loop: {
      reverse: true
    }
  }));

  const curNav: JSX.Element[] = [];
  const navDotsStart = 200 - (NavSpecs.navDots / 2) * NavSpecs.dotSpacing;

  for (let index = 0; index < NavSpecs.navDots; index++) {
    curNav.push(
      <circle
        id={`navDot-${index}`}
        key={`navDot-${index}`}
        cx={navDotsStart + index * NavSpecs.dotSpacing}
        cy={NavSpecs.centerY}
        r={NavSpecs.dotRad}
        stroke={"midnightblue"}
        fill={index <= curScene ? "#ffff00" : "midnightblue"}
        strokeWidth={1.5}
        className="intro-nav"
        opacity={1}
        onClick={event => {
          setScene(index);
        }}
      />
    );
  }
  const rightArrowLoc =
    200 + ((NavSpecs.navDots + 1) / 2) * NavSpecs.dotSpacing;

  const setScene = (sceneNum: number) => {
    setCurScene(sceneNum);
    navigate(`/welcome/why#${sceneNum}`);
  };

  useEffect(() => {
    title1Api.start({
      to: TXT_1[curScene]
    });
    title2Api.start({
      to: TXT_TWO[curScene]
    });
    normallyFunctioningApi.start({
      to: NF_SVG[curScene]
    });
    teacherStudentApi.start({
      to: TS_SVG[curScene]
    });
    socialLoafingApi.start({
      to: SL_SVG[curScene]
    });
    leaveItToGeorgeApi.start({
      to: LITG_SVG[curScene]
    });
    groupDominationApi.start({
      to: GD_SVG[curScene]
    });
    divisionOfLaborApi.start({
      to: DL_SVG[curScene]
    });
  }, [curScene]);

  useEffect(() => {
    const handleBrowserNav = (e: PopStateEvent) => {
      const scenePath = location.pathname.split("/");

      if (scenePath[scenePath.length - 1] === "why" && location.hash.length > 0 ) {
        const targetScene =  location.hash.length > 1 ? parseInt(location.hash.substring(1)) : 0;
        setScene( targetScene );
      }
    };
    window.addEventListener('popstate', handleBrowserNav);

    if (location.hash.length < 1) {
      setScene(0);
    } else {
      setScene(parseInt(location.hash.substring(1)));
    }

    return () => {
      window.removeEventListener('popstate', handleBrowserNav);
    }
  }, []);

  curNav.push(
    <g
      id="right-arrow"
      key="right-arrow"
      className="intro_nav"
      onClick={event => {
        setScene(curScene + 1);
      }}
      //Account for the off-by-one of 0-indexing
      opacity={curScene < NavSpecs.navDots - 1 ? 1 : 0}
    >
      <circle
        cx={rightArrowLoc - NavSpecs.dotRad / 2}
        cy={NavSpecs.centerY}
        r={NavSpecs.dotRad * 1.75}
        className="intro-nav"
        fill={"midnightblue"}
        stroke={"midnightblue"}
      />
      <animated.polyline
        points={`${rightArrowLoc - NavSpecs.dotRad},${NavSpecs.centerY -
          NavSpecs.dotRad} ${rightArrowLoc},${NavSpecs.centerY
          } ${rightArrowLoc - NavSpecs.dotRad},${NavSpecs.centerY +
          NavSpecs.dotRad}`}
        x1={rightArrowLoc}
        y1={NavSpecs.centerY}
        style={{
          stroke: "azure",
          strokeWidth: 2,
          strokeLinecap: "round",
          strokeLinejoin: "round",
          fill: "none",
          ...arrowNavSpring
        }}
      />
    </g>
  );

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
        <StudentConcern framed />
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
        <SocialLoafing oliveColor={"olive"} />
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
        <GroupDomination bgColor={"aliceblue"} />
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
        <DivisionOfLabor bgColor={"aliceblue"} />
      </animated.svg>

      <EmbeddedHTMLInSVG
        width={title1Spring.width}
        height={title1Spring.height}
        x={title1Spring.x}
        y={title1Spring.y}
      >
        <div className="intro">
          {titles_one[curScene]}
        </div>
      </EmbeddedHTMLInSVG>
      <EmbeddedHTMLInSVG
        width={title2Spring.width}
        height={title2Spring.height}
        x={title2Spring.x}
        y={title2Spring.y}
      >
        <div className="intro">
          {titles_two[curScene]}
        </div>
      </EmbeddedHTMLInSVG>
      {curNav}
    </svg>
  );
}
