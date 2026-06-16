import React from "react";
import { useSprings, animated, config } from "@react-spring/web";
import { useTranslation } from "react-i18next";

import MGM from "../svgs/MGM";
import BingoBoards from "../svgs/BingoBoards";
import { logocolors } from "../svgs/Logo";
import { useNavigate } from "react-router";
import TeamworkContracts from "../svgs/TeamworkContracts";

const contributors = [
  {name: "Maron" },
  {name: "Dennis" },
  {name: "Misun", github: "misunrina"},
  {name: "Esteban", github: "eseban9108" },
  {name: "Issiah", github: "AnotherHotSpot" },
  {name: "Josiah", github: "MadSiah-glitchy" },
  {name: "Soojin" },
  {name: "Stephanie", github: "stxphaniem" },
  {name: "Michael" },
  {name: "Julia" },
  {name: "Ricardo" },
  {name: "Emi", github: "emmyAlta" },
  {name: "Sonya" },
  {name: "Allison", github: "https://github.com/aesp6765" },
  {name: "Melissa" },
  {name: "Yomaris" },
  {name: "Brillyd", github: "https://github.com/blop5277" },
  {name: "Justin" },
  {name: "Maverick", github: 'mavrukis'},
  {name: "Manhattan" }
]

const githubBaseUrl = "https://github.com/";

type Props = {
  height: number;
  width: number;
}
const viewBox = [0, 0, 494, 255].join(" ");

export default function About(props: Props) {
  const category = "intro";
  const { t } = useTranslation(category);

  const [marcher, marcherApi] = useSprings(
    contributors.length ,
    (index) => {
      const randomRotation = (Math.random() * 50 ) -25;
      const yPos = Math.random() * 40 + 170;
      const duration = (contributors[index].github ? 9000 : 5000) + Math.random() * 5000;

      return {
        from: {
          x: 570,
          y: yPos,
          rotate: randomRotation,
          fill: logocolors[index % logocolors.length],
        },
        to: {x: -100 },
        config: {
          ...config.molasses,
          duration: duration
        },
        loop: true,
        delay: index * 200
      };
    }
  )
  const navigate = useNavigate();
  
  return (
    <svg
      height={props.height}
      width={props.width}
      viewBox={viewBox}
      xmlns="http://www.w3.org/2000/svg"
    >
          <g
     id="main">
    <title
       id="title1">{t("about.title")}</title>
    <defs>
      <filter id='name-shadow' x="-20%" y="-20%" width="140%" height="140%">
        <feDropShadow dx="3" dy="3" stdDeviation="2" floodColor="#000000" floodOpacity="0.6"/>
      </filter>
      <filter id='link-blur' x="0" y="0" xmlns="http://www.w3.org/2000/svg">
        <feGaussianBlur in='SourceGraphic' stdDeviation=".5" />
      </filter>
    </defs>
    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_8"
       y="68.5"
       x="86.5"
       strokeWidth="0"
       stroke="#000"
       fill="#000000">{t("about.became_research")}</text>
       <animated.svg
       x="10"
       y="50"
       >
          <MGM height={64} width={64} color="#000000" />

       </animated.svg>
    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_9"
       y="152"
       x="30"
       strokeWidth="0"
       stroke="#000"
       fill="#000000">{t("about.student_involvement")}</text>
    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_12"
       y="33.5"
       x="25.5"
       strokeWidth="0"
       stroke="#000"
       fill="#000000">{t("about.giving_voice")}</text>
    <text
       stroke="#000"
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_13"
       y="114.5"
       x="80.5"
       strokeWidth="0"
       fill="#000000">{t("about.experimented")}</text>
    <g
      id="contributors"
      >
        {
          marcher.map((props, index) => {
            const yPos = Math.random() * 90 +150;
            return (
            <animated.text
              key={`text-${index}`}
              style={{
                ...props,
                transformOrigin: 'left center'
              }}
              textAnchor="start"
              fontFamily="Noto Sans JP"
              fontSize="14"
              id={`svg_${14 + index}`}
              cursor={contributors[index].github ? "pointer" : "default"}
              onClick={
                contributors[index].github ? () => window.open(`${githubBaseUrl}${contributors[index].github}`, "_blank") : undefined
              }
              strokeWidth="0"
              stroke="#000"
              fill="#000000"
              filter="url(#name-shadow)"
              >
                {contributors[index].name}
            </animated.text>
            );
          })
        }

      </g>

    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_22"
       y="270.5"
       x="255"
       strokeWidth="0"
       stroke="#000"
       filter="url(#link-blur)"
       fill={logocolors[2]}>{t("about.tos_link")}</text>
    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_22"
       y="270.5"
       x="126"
       strokeWidth="0"
       stroke="#000"
       filter="url(#link-blur)"
       fill={logocolors[2]}>{t("about.policy_link")}</text>
    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="14"
       id="svg_22"
       y="272.5"
       x="24"
       strokeWidth="0"
       stroke="#000"
       fill="#000000">{t("about.policy_tos")}</text>
    <rect
       id="rect1"
       height="15"
       width="85"
       y="260"
       x="125"
       cursor="pointer"
       onClick={
        ()=> navigate( '/privacy')
       }
       opacity="0"
       />
    <rect
       id="rect1"
       height="15"
       width="97"
       y="260"
       x="257"
       cursor="pointer"
       onClick={
        ()=> navigate( '/tos')
       }
       opacity="0"
       />
    <text
       textAnchor="start"
       fontFamily="Noto Sans JP"
       fontSize="23"
       id="svg_23"
       y="242.5"
       x="122"
       strokeWidth="0"
       stroke="#000"
       fill="#000000">{t("about.not_done")}</text>
  </g>
       <animated.svg
       x="410"
       y="170"
       >
          <BingoBoards height={150} width={110} count={5}/>
       </animated.svg>

    </svg>
  );
}
