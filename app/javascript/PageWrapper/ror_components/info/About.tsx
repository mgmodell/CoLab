import React from "react";

type Props = {};

export default function About(props: Props) {
  return (
    <div className={"intro"}>
      <p>
        This is where you'll find information about those who have made CoLab
        possible.
      </p>
      <p>
        Please do review our <a href="/privacy">Privacy policy</a> and our{" "}
        <a href="/terms">Terms of Service</a>.
      </p>
    </div>
  );
}
