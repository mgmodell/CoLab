import React, { Suspense, useState } from "react";
import { useSelector, useDispatch } from "react-redux";
import { setDirty } from "../infrastructure/StatusSlice";
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";
import parse from "html-react-parser";

import { Button } from "primereact/button";
import { Panel } from "primereact/panel";
import { Skeleton } from "primereact/skeleton";

import { InputText } from "primereact/inputtext";
import { InputTextarea } from "primereact/inputtextarea";
import { RadioButton } from "primereact/radiobutton";
import { Container, Row, Col } from "react-grid-system";
import { di } from "@fullcalendar/core/internal-common";
import { FloatLabel } from "primereact/floatlabel";

type Props = {
  reactionFunc: Function;
};

export default function ExperienceReaction(props: Props) {
  const [t, i18n] = useTranslation("experiences");
  const [behaviorId, setBehaviorId] = useState(0);
  const [otherName, setOtherName] = useState("");
  const [improvements, setImprovements] = useState("");
  const dirtyStatus = useSelector(state => {
    return state.status.dirtyStatus["reaction"];
  });
  const dispatch = useDispatch();
  const behaviors = useTypedSelector(state => state.context.lookups.behaviors);

  const getById = (list, id) => {
    return list.filter(item => {
      return id === item.id;
    })[0];
  };

  const detailNeeded =
    0 === behaviorId ? true : getById(behaviors, behaviorId).needs_detail;
  const detailPresent = otherName.length > 0;
  const improvementsPresent = improvements.length > 0;
  const saveButton = (
    <Button
      disabled={
        !dirtyStatus || !improvementsPresent || (detailNeeded && !detailPresent)
      }
      onClick={() =>
        props.reactionFunc(behaviorId, otherName, improvements, resetData)
      }
    >
      <Suspense fallback={<Skeleton className="mb-2" />}>
        {t("reaction.submit")}
      </Suspense>
    </Button>
  );
  const otherPnl =
    0 !== behaviorId && getById(behaviors, behaviorId).needs_detail ? (
      <FloatLabel>
        <InputText
          itemID="otherName"
          value={otherName}
          onChange={event => {
            setOtherName(event.target.value);
          }}
        />
        <label htmlFor="otherName">{t("next.other")}</label>
      </FloatLabel>
    ) : null;

  const resetData = () => {
    setBehaviorId(0);
    setOtherName("");
    setImprovements("");
  };

  return (
    <Panel>
      <Container>
        <Row>
          <Col xs={12}>
            <Suspense fallback={<Skeleton className="mb-2" />}>
              <h3>{t("reaction.title")}</h3>
            </Suspense>
          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <Suspense fallback={<Skeleton className="mb-2" />}>
              <p>{parse(t("reaction.instructions"))}</p>
            </Suspense>
          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <h6>
              {t("reaction.dom_behavior")}
            </h6>
            {
            behaviors?.map(behavior => {
              return (
                <>
                  <RadioButton
                    key={`behavior_${behavior.id}`}
                    inputId={`behavior_${behavior.id}`}
                    name='dom_behavior'
                    checked={behaviorId === behavior.id}
                    value={behavior.name}
                    onChange={event => {
                      setBehaviorId(behavior.id);
                      dispatch(setDirty("reaction"));
                    }}
                  />
                  <label htmlFor={`behavior_${behavior.id}`}>{behavior.name}</label>

                  <p>{parse(behavior.description)}</p>
                </>
              );
            })
          }

          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            {otherPnl}

          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <h3>{t("reaction.improve")}</h3>
            <FloatLabel>
              <InputTextarea
                id="improvements"
                itemID="improvements"
                value={improvements}
                onChange={event => {
                  setImprovements(event.target.value);
                }}
                rows={5}
                cols={30}
              />
              <label htmlFor="improvements">{t("reaction.suggest")}</label>
            </FloatLabel>

          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            {saveButton}

          </Col>
        </Row>
      </Container>

    </Panel>
  );
}
