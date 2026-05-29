import React from "react";

type Props = {};

export default function Research(props: Props) {
  return (
    <div className={"intro"}>
      <p>
        The SAPA work began with Continuous Assessment (a 2011 PHP prototype)
        used across five classes spanning three semesters, followed by S2 (a
        Ruby on Rails rewrite).
      </p>
      <p>
        A design case from this line of work was presented at AECT 2012, and
        the publications by Micah G. Modell and collaborators remain the core
        references behind CoLab.
      </p>
      <p>
        For the full publication list and broader project background, visit{" "}
        <a href="http://www.peerassess.info/">PeerAssess.info</a>.
      </p>
    </div>
  );
}
