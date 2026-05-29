import React, { useState } from "react";
import { animated, useSpring } from "@react-spring/web";

type Props = {};

const supportSections = {
  experiences: {
    title: "Group Work",
    subtitle: "Facilitate authentic in-class collaboration",
    points: [
      "Use simulated authentic group work experiences to anchor in-class discussion.",
      "Coach teams with scenarios that surface common collaboration challenges.",
      "Build shared expectations for productive team process."
    ]
  },
  reading: {
    title: "Reading",
    subtitle: "Encourage collaboration around assigned texts",
    points: [
      "Use gamified reading supports to increase preparation and participation.",
      "Prompt students to engage with ideas before class activities begin.",
      "Reinforce discussion habits that transfer to team project work."
    ]
  },
  perspectives: {
    title: "Perspectives",
    subtitle: "Develop appreciation for different viewpoints",
    points: [
      "Calculate diversity points to foreground perspective-taking in team formation.",
      "Use diversity-point information as a support for reflective team dialogue.",
      "Connect perspective awareness to equitable collaboration practices."
    ]
  }
} as const;

type SupportSection = keyof typeof supportSections;

export default function ForInstructors(props: Props) {
  const [activeSection, setActiveSection] = useState<SupportSection>("reading");

  const section = supportSections[activeSection];
  const handleSelect = (sectionKey: SupportSection) => {
    setActiveSection(sectionKey);
  };

  const handleKeyDown = (
    event: React.KeyboardEvent<SVGCircleElement>,
    sectionKey: SupportSection
  ) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      handleSelect(sectionKey);
    }
  };

  const panelStyles = useSpring({
    opacity: 1,
    transform: "translate3d(0px, 0px, 0px)",
    from: {
      opacity: 0,
      transform: "translate3d(18px, 0px, 0px)"
    },
    reset: true
  });

  return (
    <div className={"intro"}>
      <p>
        CoLab.online extends SAPA with practical instructor supports for group
        work experiences, collaborative reading, and perspective-focused team
        development.
      </p>
      <svg
        viewBox="0 0 390 72"
        preserveAspectRatio="xMidYMid meet"
        style={{ width: "100%", maxWidth: "390px", height: "auto" }}
        role="img"
        aria-label="Instructor support views"
      >
        <title>Instructor support areas: group work, reading, and perspectives</title>
        {(
          [
            { key: "experiences", x: 65, color: "#53b0ff", label: "Group Work" },
            { key: "reading", x: 195, color: "#7ad35a", label: "Reading" },
            { key: "perspectives", x: 325, color: "#ff9f5a", label: "Perspectives" }
          ] as const
        ).map((item) => {
          const isActive = activeSection === item.key;
          return (
            <g key={item.key}>
              <rect
                x={item.x - 43}
                y={44}
                width={86}
                height={19}
                rx={9}
                fill="rgba(255, 255, 255, 0.88)"
              />
              <circle
                cx={item.x}
                cy={24}
                r={isActive ? 19 : 16}
                fill={item.color}
                stroke={isActive ? "midnightblue" : "#1f1f1f"}
                strokeWidth={isActive ? 3 : 1.5}
                className="intro_nav"
                onClick={() => handleSelect(item.key)}
                onKeyDown={(event) => handleKeyDown(event, item.key)}
                tabIndex={0}
                role="button"
                aria-label={`${item.label} support details`}
                aria-pressed={isActive}
              />
              <text
                x={item.x}
                y={56}
                textAnchor="middle"
                style={{
                  fill: "#10243f",
                  fontFamily: "sans-serif",
                  fontSize: "13px",
                  fontWeight: isActive ? "bold" : "normal"
                }}
              >
                {item.label}
              </text>
            </g>
          );
        })}
      </svg>
      <animated.div style={panelStyles}>
        <p>
          <strong>{section.title}:</strong> {section.subtitle}
        </p>
        <ul>
          {section.points.map((point, index) => (
            <li key={index}>{point}</li>
          ))}
        </ul>
      </animated.div>
    </div>
  );
}
