import React from "react";

type Props = {};

export default function About(props: Props) {
  return (
    <div className={"intro"}>
      <p>
        CoLab helps teams learn how to collaborate well while there is still
        time to improve. Students and instructors use regular check-ins,
        peer-feedback, and shared team views to spot patterns early and build
        healthier group habits.
      </p>
      <p>
        The platform was developed as a research-informed teaching tool and is
        maintained by educators, researchers, and software contributors who
        care about equitable teamwork.
      </p>
      <p>
        Please review our <a href="/privacy">Privacy policy</a> and{" "}
        <a href="/terms">Terms of Service</a>.
      </p>
    </div>
  );
}
