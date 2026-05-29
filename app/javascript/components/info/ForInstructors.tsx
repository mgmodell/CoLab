import React, { useState } from "react";
import { animated, useSpring } from "@react-spring/web";

type Props = {};

const supportSections = {
  planning: {
    title: "Plan",
    subtitle: "Set teams up for success",
    points: [
      "Structure team roles and expectations before project pressure builds.",
      "Use kickoff check-ins to normalize communication and accountability.",
      "Align collaboration goals with assignment milestones."
    ]
  },
  monitoring: {
    title: "Monitor",
    subtitle: "Track team health over time",
    points: [
      "Review periodic self- and peer-check-ins for emerging risks.",
      "See trends in participation before a team reaches a crisis point.",
      "Use quick summaries to prioritize where your support is needed."
    ]
  },
  intervention: {
    title: "Intervene",
    subtitle: "Offer targeted supports",
    points: [
      "Start coaching conversations with clear, behavior-based evidence.",
      "Guide teams through repair steps when conflict or uneven effort appears.",
      "Follow up after interventions to reinforce productive collaboration."
    ]
  }
} as const;

type SupportSection = keyof typeof supportSections;

export default function ForInstructors(props: Props) {
  const [activeSection, setActiveSection] = useState<SupportSection>("monitoring");

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
        CoLab gives instructors a quick way to move from setup, to monitoring,
        to action while teams are still working.
      </p>
      <svg width="390" height="72" viewBox="0 0 390 72" role="img" aria-label="Instructor support views">
        {(
          [
            { key: "planning", x: 65, color: "#53b0ff", label: "Plan" },
            { key: "monitoring", x: 195, color: "#7ad35a", label: "Monitor" },
            { key: "intervention", x: 325, color: "#ff9f5a", label: "Intervene" }
          ] as const
        ).map((item) => {
          const isActive = activeSection === item.key;
          return (
            <g key={item.key}>
              <circle
                cx={item.x}
                cy={24}
                r={isActive ? 19 : 16}
                fill={item.color}
                stroke={isActive ? "white" : "midnightblue"}
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
                  fill: "azure",
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
          {section.points.map((point) => (
            <li key={point}>{point}</li>
          ))}
        </ul>
      </animated.div>
    </div>
  );
}
