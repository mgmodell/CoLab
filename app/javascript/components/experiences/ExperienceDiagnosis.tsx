import React, { Suspense, useState } from "react";

import parse from "html-react-parser";
import { useDispatch } from "react-redux";
import { setDirty } from "../infrastructure/StatusSlice";

import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";


import { Accordion, AccordionTab } from "primereact/accordion";
import { Skeleton } from "primereact/skeleton";
import { Button } from "primereact/button";
import { InputText } from "primereact/inputtext";
import { InputTextarea } from "primereact/inputtextarea";
import { RadioButton } from "primereact/radiobutton";
import { Container, Row, Col } from "react-grid-system";
import { Panel } from "primereact/panel";

type Props = {
  diagnoseFunc: (
    behaviorId: number,
    otherName: string,
    comments: string,
    resetData: () => void
  ) => void;
  weekNum: number;
  weekText: string;
};

export default function ExperienceDiagnosis(props: Props) {
  const [t, i18n] = useTranslation("experiences");
  const [behaviorId, setBehaviorId] = useState(0);
  const [otherName, setOtherName] = useState("");
  const [comments, setComments] = useState("");
  const [showComments, setShowComments] = useState(false);

  const dirtyStatus = useTypedSelector(
    state => state.status.dirtyStatus["diagnosis"]
  );
  const dispatch = useDispatch();

  const getById = (list, id) => {
    return list.filter(item => {
      return id === item.id;
    })[0];
  };

  const behaviors = useTypedSelector(state => state.context.lookups.behaviors);

  const detailNeeded =
    0 === behaviorId ? true : getById(behaviors, behaviorId).needs_detail;
  const detailPresent = otherName.length > 0;
  const saveButton = (
    <Button
      disabled={
        !dirtyStatus || 0 === behaviorId || (detailNeeded && !detailPresent)
      }
      onClick={() =>
        props.diagnoseFunc(behaviorId, otherName, comments, resetData)
      }
    >
      <Suspense fallback={<Skeleton className="mb-2" />}>
        {t("next.save_and_continue")}
      </Suspense>
    </Button>
  );

  const otherPnl =
    0 !== behaviorId && detailNeeded ? (
      <span className="p-float-label">
        <InputText
          itemID="other_name"
          id="other_name"
          value={otherName}
          onChange={event => {
            setOtherName(event.target.value);
          }}
        />
        <label htmlFor="other_name">{t("next.other")}</label>
      </span>
    ) : null;

  const resetData = () => {
    setBehaviorId(0);
    setOtherName("");
    setComments("");
  };

  return (
    <Panel>
      <Container>
        <Row>
          <Col xs={12}>
            <Suspense fallback={<Skeleton className="mb-2" />}>
              <h3 className="journal_entry">
                {t("next.journal", { week_num: props.weekNum })}
              </h3>
            </Suspense>
          </Col>
        </Row>
        <Row>
          <Col xs={12}>
            <Suspense fallback={<Skeleton className="mb-2" />}>
              <p>{parse(props.weekText)}</p>
            </Suspense>
          </Col>

        </Row>

        <Row>
          <Col xs={12}>
            <h6>
              {t("next.prompt")}
            </h6>
              { behaviors?.map(behavior => {
                  return (
                    <>
                      <RadioButton
                        key={`behavior_${behavior.id}`}
                        inputId={`behavior_${behavior.id}`}
                        className="behaviors"
                        name="behavior"
                        checked={behaviorId === behavior.id}
                        value={behavior.name}
                        onChange={event => {
                          setBehaviorId(behavior.id);
                          setShowComments(behavior.needs_detail);
                          dispatch(setDirty("diagnosis"));
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
            <Accordion>
              <AccordionTab header={t("next.click_for_comment")}>
                <div className="p-float-label">
                  <InputTextarea
                    itemID="comments"
                    id="comments"
                    value={comments}
                    onChange={event => {
                      setComments(event.target.value);
                    }}
                    rows={5}
                    cols={30}
                  />
                  <label htmlFor="comments">{t("next.comments")}</label>

                </div>
              </AccordionTab>
            </Accordion>
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
