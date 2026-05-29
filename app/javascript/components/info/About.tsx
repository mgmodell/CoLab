import React from "react";

type Props = {};

export default function About(props: Props) {
  return (
    <div className={"intro"}>
      <p>
        This site houses ongoing explorations into self- and peer-assessment
        (SAPA) led by Micah Gideon Modell.
      </p>
      <p>
        CoLab.online is the latest iteration, building on earlier SAPA systems
        (S2 and Continuous Assessment) to support collaborative learning and the
        development of collaboration skills.
      </p>
      <p>
        These systems do not include publicly accessible class content. For
        access details or implementation questions, please{" "}
        <a href="mailto:support@peerassess.info">contact us</a>.
      </p>
      <p>
        Please review our <a href="/privacy">Privacy policy</a> and{" "}
        <a href="/terms">Terms of Service</a>.
      </p>
    </div>
  );
}
