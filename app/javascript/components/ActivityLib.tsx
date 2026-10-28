import React from "react";
import i18n from "./infrastructure/i18n";

const t = i18n.getFixedT(null, "base");

const tooltipAliases: Record<string, string> = {
  courses: "course",
  concepts: "concept",
  "group experience": "experience",
  experiences: "experience",
  project: "project",
  assessments: "assessment",
  "terms list": "bingo_game",
  bingo_games: "bingo_game",
  "bingo games": "bingo_game",
  "group assignment": "assignment",
  assignments: "assignment",
  rubrics: "rubric",
  users: "user",
  schools: "school",
  consent_forms: "consent_form",
  admin: "admin",
  demonstration: "demonstration"
};

export function iconForType(type: string) {
  const iconData = {
    icon: <></>,
    className: "",
  };
  switch (type.toLowerCase()) {
    case "home":
      iconData.className = "home";
      iconData.icon = <i className={`${iconData.className} pi pi-home`} />;
      break;
    case "welcome":
      iconData.className = "welcome";
      iconData.icon = <i className={`${iconData.className} pi pi-info-circle`} />;
      break;
    case "profile":
      iconData.className = "profile";
      iconData.icon = <i className={`${iconData.className} pi pi-user`} />;
      break;
    case "perspective":
      iconData.className = "perspective";
      iconData.icon = <i className={`${iconData.className} pi pi-calculator`} />;
      break;
    case "concept":
    case "concepts":
      iconData.className = "concept";
      iconData.icon = <i className={`${iconData.className} pi pi-tags`} />;
      break;
    case "group experience":
    case "experience":
    case "experiences":
      iconData.className = "experience";
      iconData.icon = <i className={`${iconData.className} pi pi-wave-pulse`} />;
      break;
    case "project":
    case "assessment":
    case "assessments":
      iconData.className = "assessment";
      iconData.icon = <i className={`${iconData.className} pi pi-sliders-h`} />;
      break;
    case "terms list":
    case "bingo_game":
    case "bingo games":
      iconData.className = "bingo_game";
      iconData.icon = <i className={`${iconData.className} pi pi-table`} />;
      break;
    case "group assignment":
    case "assignment":
    case "assignments":
      iconData.className = "assignment";
      iconData.icon = <i className={`${iconData.className} pi pi-file-edit`} />;
      break;
    case "submission":
      iconData.className = "submission";
      iconData.icon = <i className={`${iconData.className} pi pi-file-export`} />;
      break;
    case "rubric":
    case "rubrics":
      iconData.className = "rubric";
      iconData.icon = <i className={`${iconData.className} pi pi-table`} />;
      break;
    case "course":
    case "courses":
      iconData.className = "course";
      iconData.icon = <i className={`${iconData.className} pi pi-book`} />;
      break;
    case "user":
    case "users":
      iconData.className = "user";
      iconData.icon = <i className={`${iconData.className} pi pi-address-book`} />;
      break;
    case "reporting":
      iconData.className = "reporting";
      iconData.icon = <i className={`${iconData.className} pi pi-chart-bar`} />;
      break;
    case "administration":
    case "admin":
      iconData.className = "admin";
      iconData.icon = <i className={`${iconData.className} pi pi-cog`} />;
      break;
    case "school":
    case "schools":
      iconData.className = "school";
      iconData.icon = <i className={`${iconData.className} pi pi-building-columns`} />;
      break;
    case "consent_form":
    case "consent_forms":
      iconData.className = "consent_form";
      iconData.icon = <i className={`${iconData.className} pi pi-file`} />;
      break;
    case 'demo':
    case 'demonstration':
      iconData.className = "demonstration";
      iconData.icon = <i className={`${iconData.className} pi pi-video`} />;
      break;
    default:
      iconData.className = `unit-${type}`;
      iconData.icon = <i className={`${iconData.className} pi pi-asterisk`} />;
  }
  const tooltipType = tooltipAliases[type.toLowerCase()] ?? iconData.className;
  const tooltipKey = `breadcrumbs.${tooltipType.startsWith("unit-") ? "item" : tooltipType}`;
  return (
    React.cloneElement(iconData.icon, {
      title: t(tooltipKey)
    })
  );
}
