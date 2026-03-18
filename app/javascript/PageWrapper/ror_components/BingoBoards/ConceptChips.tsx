import React from "react";
import { Chip } from "primereact/chip";
import { Panel } from "primereact/panel";

type Props = {
  concepts: Array<{ id: number; name: string }>;
};
export default function ConceptChips(props: Props) {
  var c = [{ id: 1, name: "nothing" }];

  return (
    <Panel>
      {props.concepts.map(chip => {
        return (
          <Chip key={chip.id} id={`concept_${chip.id}`} label={chip.name} />
        );
      })}
    </Panel>
  );
}
