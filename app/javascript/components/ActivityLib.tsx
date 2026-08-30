import React from "react";
import { Tooltip } from "primereact/tooltip";

export function iconForType(type: string) {
  const iconData = {
    icon: <></>,
    className: "",
  };
  switch (type.toLowerCase()) {
    case "home":
      iconData.className = "home";
      iconData.icon = <span className={`${iconData.className} pi pi-home`} />;
      break;
    case "welcome":
      iconData.className = "welcome";
      iconData.icon = <span className={`${iconData.className} pi pi-info-circle`} />;
      break;
    case "profile":
      iconData.className = "profile";
      iconData.icon = <span className={`${iconData.className} pi pi-user`} />;
      break;
    case "perspective":
      iconData.className = "perspective";
      iconData.icon = <span className={`${iconData.className} pi pi-calculator`} />;
      break;
    case "concept":
    case "concepts":
      iconData.className = "concept";
      iconData.icon = <span className={`${iconData.className} pi pi-tags`} />;
      break;
    case "group experience":
    case "experience":
    case "experiences":
      iconData.className = "experience";
      iconData.icon = <span className={`${iconData.className} pi pi-book`} />;
      break;
    case "project":
    case "assessment":
    case "assessments":
      iconData.className = "assessment";
      iconData.icon = <span className={`${iconData.className} pi pi-sliders-h`} />;
      break;
    case "terms list":
    case "bingo_game":
    case "bingo games":
      iconData.className = "bingo_game";
      iconData.icon = <span className={`${iconData.className} pi pi-table`} />;
      break;
    case "group assignment":
    case "assignment":
    case "assignments":
      iconData.className = "assignment";
      iconData.icon = <span className={`${iconData.className} pi pi-file-edit`} />;
      break;
    case "submission":
      iconData.className = "submission";
      iconData.icon = <span className={`${iconData.className} pi pi-file-export`} />;
      break;
    case "rubric":
    case "rubrics":
      iconData.className = "rubric";
      iconData.icon = <span className={`${iconData.className} pi pi-table`} />;
      break;
    case "course":
    case "courses":
      iconData.className = "course";
      iconData.icon = <span className={`${iconData.className} pi pi-book`} />;
      break;
    case "user":
    case "users":
      iconData.className = "user";
      iconData.icon = <span className={`${iconData.className} pi pi-users`} />;
      break;
    case "reporting":
      iconData.className = "reporting";
      iconData.icon = <span className={`${iconData.className} pi pi-chart-bar`} />;
      break;
    case "administration":
    case "admin":
      iconData.className = "admin";
      iconData.icon = <span className={`${iconData.className} pi pi-cog`} />;
      break;
    case "school":
    case "schools":
      iconData.className = "school";
      iconData.icon = <span className={`${iconData.className} pi pi-building-columns`} />;
      break;
    case "consent_form":
    case "consent_forms":
      iconData.className = "consent_form";
      iconData.icon = <span className={`${iconData.className} pi pi-file`} />;
      break;
    case 'demo':
    case 'demonstration':
      iconData.className = "demonstration";
      iconData.icon = <span className={`${iconData.className} pi pi-video`} />;
      break;
    default:
      iconData.className = `unit-${type}`;
      iconData.icon = <span className={`${iconData.className} pi pi-asterisk`} />;
  }
  return (
    <>
      <Tooltip target={iconData.className} content={type} />
      {iconData.icon}
    </>
  );
}
