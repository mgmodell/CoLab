import React from "react";

type Props = {};

export default function Research(props: Props) {
  return (
    <div className={"intro"}>
      <p>
        CoLab is informed by research on peer assessment, collaborative
        learning, and instructor intervention in team-based courses.
      </p>
      <p>
        We are streamlining this bibliography and keeping the publications by
        Micah G. Modell and collaborators as the core references for the
        platform.
      </p>
      <p>
        For the full publication list and project background, visit{" "}
        <a href="http://www.peerassess.info/">PeerAssess.info</a>.
      </p>
    </div>
  );
}
