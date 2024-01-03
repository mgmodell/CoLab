import React, { lazy } from "react";
import { Tooltip } from "primereact/tooltip";

export function iconForType(type: string) {
  let icon: React.JSX.Element;
  let className: string;
  switch (type.toLowerCase()) {
    case "group experience":
    case "experience":
    case "experiences":
      className = 'experience';
      icon = <span className={`${className} pi pi-book`} />;
      break;
    case "project":
    case "assessment":
    case "assessments":
      className = 'assessment';
      icon = <span className={`${className} pi pi-sliders-h`} />;
      break;
    case "terms list":
    case "bingo_game":
    case "bingo games":
      className = 'bingo_game';
      icon = <span className={`${className} pi pi-table`} />;
      break;
    case "group assignment":
    case "assignment":
    case "Assignments":
      className = 'assignment';
      icon = <span className={`${className} pi pi-file-edi`} />;
      break;
    case "submission":
      className = 'submission';
      icon = <span className={`${className} pi pi-file-export`} />;
      break;
    default:
      console.log(`No icon match for: ${type}`);
  }
  return (
    <>
      <Tooltip target={className}/>
      {icon}
    </>)
}
