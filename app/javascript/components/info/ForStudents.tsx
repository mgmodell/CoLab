import React from "react";
import { useTranslation } from "react-i18next";
import { logocolors } from "../svgs/Logo";
import { useNavigate } from "react-router";
import TeamworkContracts from "../svgs/TeamworkContracts";
import {animated} from "@react-spring/web";
import SlideTemplate from "../svgs/SlideTemplate";
import Calculation from "../svgs/Calculation";
import Visualization from "../svgs/Visualization";
import BingoBoards from "../svgs/BingoBoards";

type Props = {
  height: number;
  width: number;
};

const activities = {
  gamification: {
    image: <BingoBoards height={150} width={110} />
  },
  feedback: {
    image: <Visualization height={150} width={110} />
  },
  voice: {
  }
};

export default function ForStudents(props: Props) {
  const viewBox = [0, 0, 494, 255].join(" ");
  const category = "intro";
  const catPrefix = "students";
  const { t } = useTranslation(category);

  const navigate = useNavigate();
  const [currentTab, setCurrentTab] = React.useState(Object.keys(activities)[0]);

  return (
    <svg
      height={props.height}
      width={props.width}
      viewBox={viewBox}
      xmlns="http://www.w3.org/2000/svg"
    >
    <defs>
      <filter id='glow-blur' x="0" y="0" xmlns="http://www.w3.org/2000/svg">
        <feGaussianBlur in='SourceGraphic' stdDeviation="1.5" />
      </filter>
    </defs>
    <g id="main">

      <title>{t(`${catPrefix}.title`)}</title>
      <text
         textAnchor="start"
         fontFamily="Noto Sans JP"
         fontSize="12"
         id="svg_1"
         y="88.5"
         x="40.5"
         strokeWidth="0"
         stroke="#000"
         fill="#000000">{t(`${catPrefix}.intro`)}</text>
         <g id="tabs">
          {Object.keys(activities).map((key, index) => (
            <g key={key}
              cursor="pointer"
              onClick={() => setCurrentTab(key)}
              id={"tab_" + key}>
                {currentTab === key ? (
              <circle
                cx={140 + (index * 90)} cy="120" r="23"
                filter="url(#glow-blur)"
                fill={logocolors[index % logocolors.length]} />
                ) : null}
              <circle
                cx={140 + (index * 90)} cy="120" r="17"
                stroke="#000" strokeWidth="1"
                fill={logocolors[index % logocolors.length]} />
              <text
                textAnchor="middle"
                fontFamily="Noto Sans JP"
                fontSize="10"
                id={"tab_text_" + key}
                y="119.5"
                x={140 + (index * 90)}
                strokeWidth="1"
                fill="#000">{t(`${catPrefix}.${key}.title`)}</text>
              <g 
                cursor='default'
                id="activities">
                {currentTab === key ? (
                  <>
                    <text
                     textAnchor="start"
                     fontFamily="Noto Sans JP"
                     fontSize="10"
                     id={"activities_" + key}
                     y="164"
                     x="50.5"
                     strokeWidth="0"
                     stroke="#000"
                     fill="#000000">{t(`${catPrefix}.${key}.line_one`)}</text>
                    <text
                     textAnchor="start"
                     fontFamily="Noto Sans JP"
                     fontSize="10"
                     id={"activities_" + key}
                     y="179"
                     x="65.5"
                     strokeWidth="0"
                     stroke="#000"
                     fill="#000000">{t(`${catPrefix}.${key}.line_two`)}</text>
                    <text
                     textAnchor="start"
                     fontFamily="Noto Sans JP"
                     fontSize="10"
                     id={"activities_" + key}
                     y="203"
                     x="55"
                     strokeWidth="0"
                     stroke="#000"
                     fill="#000000">{t(`${catPrefix}.${key}.line_three`)}</text>
                    <text
                     textAnchor="start"
                     fontFamily="Noto Sans JP"
                     fontSize="10"
                     id={"activities_" + key}
                     y="230"
                     x="95.5"
                     strokeWidth="0"
                     stroke="#000"
                     fill="#000000">{t(`${catPrefix}.${key}.line_four`)}</text>
                    <animated.svg
                    x="390"
                    y="110"
                    >
                      <g id='link'
                      >

                       {activities[key].image}
                      </g>
                    </animated.svg>
                  </>
                ) : null}
              </g>
            </g>
          ))}
        </g>
      </g>

    </svg>
  );
}
