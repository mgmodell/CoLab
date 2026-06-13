import React from "react";
import { useTranslation } from "react-i18next";
import { logocolors } from "../svgs/Logo";
import { useNavigate } from "react-router";
import TeamworkContracts from "../svgs/TeamworkContracts";
import {animated} from "@react-spring/web";
import SlideTemplate from "../svgs/SlideTemplate";
import Calculation from "../svgs/Calculation";
import Visualization from "../svgs/Visualization";

type Props = {
  height: number;
  width: number;
};

const activities = {
  viz: {
    image: <Visualization height={150} width={110} />
  },
  perspective: {
    link: "https://docs.google.com/spreadsheets/d/1kiy8euf6zXmv1TkPKyQUqb7ZrFZ2KmFp6GVE0yGctOM/edit?usp=sharing",
    image: <Calculation height={150} width={110} />
  },
  contracts: {
    link: "https://docs.google.com/document/d/1yM86ptoqw2_wnHYJv3P1U3YZYQlYurLDCvQ9hvksD7M/edit?usp=sharing",
    image: <TeamworkContracts height={150} width={110} />
  },
  simulation: {
    link: "https://docs.google.com/presentation/d/16s5fnFM41dtmX45sZprbNk4qxKSsry3Lw67NcCiYrYw/edit?usp=sharing",
    image: <SlideTemplate height={150} width={110} />
  }
};

export default function ForInstructors(props: Props) {
  const viewBox = [0, 0, 494, 255].join(" ");
  const category = "intro";
  const catPrefix = "instructors";
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
         y="28.5"
         x="30.5"
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
                cx={140 + (index * 90)} cy="65" r="23"
                filter="url(#glow-blur)"
                fill={logocolors[index % logocolors.length]} />
                ) : null}
              <circle
                cx={140 + (index * 90)} cy="65" r="17"
                stroke="#000" strokeWidth="1"
                fill={logocolors[index % logocolors.length]} />
              <text
                textAnchor="middle"
                fontFamily="Noto Sans JP"
                fontSize="10"
                id={"tab_text_" + key}
                y="66.5"
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
                     y="99"
                     x="30.5"
                     strokeWidth="0"
                     stroke="#000"
                     fill="#000000">{t(`${catPrefix}.${key}.line_one`)}</text>
                    <text
                     textAnchor="start"
                     fontFamily="Noto Sans JP"
                     fontSize="10"
                     id={"activities_" + key}
                     y="123"
                     x="55.5"
                     strokeWidth="0"
                     stroke="#000"
                     fill="#000000">{t(`${catPrefix}.${key}.line_two`)}</text>
                    <text
                     textAnchor="start"
                     fontFamily="Noto Sans JP"
                     fontSize="10"
                     id={"activities_" + key}
                     y="145"
                     x="45.5"
                     strokeWidth="0"
                     stroke="#000"
                     fill="#000000">{t(`${catPrefix}.${key}.line_three`)}</text>
                    <text
                     textAnchor="start"
                     fontFamily="Noto Sans JP"
                     fontSize="10"
                     id={"activities_" + key}
                     y="173"
                     x="68"
                     strokeWidth="0"
                     stroke="#000"
                     fill="#000000">{t(`${catPrefix}.${key}.line_four`)}</text>
                    <text
                     textAnchor="start"
                     fontFamily="Noto Sans JP"
                     fontSize="10"
                     id={"activities_" + key}
                     y="198"
                     x="88"
                     strokeWidth="0"
                     stroke="#000"
                     fill="#000000">{t(`${catPrefix}.${key}.line_five`)}</text>
                    <animated.svg
                    x="390"
                    y="110"
                    >
                      <g id='link'
                        cursor={activities[key].link ? "pointer" : "default"}
                        onClick={() => {
                          if (activities[key].link) {
                            window.open(activities[key].link, "_blank");
                          }
                        }}
                      >

                       {activities[key].image}
                       { activities[key].link ? (
                       <text
                         textAnchor="start"
                         fontFamily="Noto Sans JP"
                         fontSize="10"
                         id={"activities_" + key}
                         y="140"
                         x="30.5"
                         strokeWidth="0"
                         stroke="#000"
                         fill="#000000">{t(`${catPrefix}.click`)}</text>
                       ) : null }
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
