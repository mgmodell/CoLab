import React, { Suspense } from "react";

//For debug purposes

import { useTypedSelector } from "../infrastructure/AppReducers";
import { useTranslation } from "react-i18next";
import parse from "html-react-parser";
import { Panel } from "primereact/panel";
import { Button } from "primereact/button";
import { Skeleton } from "primereact/skeleton";

type Props = {
  acknowledgeFunc: () => void;
};

export default function Experience(props: Props) {
  const [t, i18n] = useTranslation("experiences");

  const behaviors = useTypedSelector(state => state.context.lookups.behaviors);

  const saveButton = (
    <Button onClick={() => props.acknowledgeFunc()}>
      {t("instructions.next")}
    </Button>
  );

  return (
    <Panel>
      <Suspense fallback={<Skeleton className="mb-2" />}>
        <h3>{t("instructions.title")}</h3>
      </Suspense>
      <Suspense fallback={<Skeleton className="mb-2" />}>
        <p>{parse(t("inst_p1"))}</p>
      </Suspense>
      <Suspense fallback={<Skeleton className="mb-2" />}>
        <p>{parse(t("inst_p2"))}</p>
      </Suspense>
      <Suspense fallback={<Skeleton className="mb-2" />}>
        <p>{parse(t("inst_p3"))}</p>
      </Suspense>
      <Suspense fallback={<Skeleton className="mb-2" height="30rem" />}>
        <h3>{t("instructions.behaviors_lbl")}</h3>
      </Suspense>
      <Suspense fallback={<Skeleton className="mb-2" />}>
        <dl>
          {(behaviors || []).map(behavior => {
            return (
              <React.Fragment key={behavior.id}>
                <dt>{behavior.name}</dt>
                <dd>{parse(behavior.description)}</dd>
              </React.Fragment>
            );
          })}
        </dl>
      </Suspense>
      <Suspense fallback={<Skeleton className="mb-2" height="30rem" />}>
        <h3>{t("scenario_lbl")}</h3>
      </Suspense>
      <Suspense fallback={<Skeleton className="mb-2" />}>
        <p>{parse(t("scenario_p1"))}</p>
      </Suspense>
      <Suspense fallback={<Skeleton className="mb-2" />}>
        <p>{parse(t("scenario_p2"))}</p>
      </Suspense>
      <Suspense fallback={<Skeleton className="mb-2" />}>
        <p>{parse(t("scenario_p3"))}</p>
      </Suspense>
      {saveButton}
    </Panel>
  );
}
