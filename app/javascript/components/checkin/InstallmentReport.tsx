import React, { Suspense, useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";

import { Accordion, AccordionTab } from "primereact/accordion";
import { Button } from "primereact/button";
import { Skeleton } from "primereact/skeleton";

import { useDispatch } from "react-redux";
import { startTask, endTask, addMessage, Priorities } from "../infrastructure/StatusSlice";
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";

import axios from "axios";
import parse from "html-react-parser";
import { Panel } from "primereact/panel";
import { InputTextarea } from "primereact/inputtextarea";
import { Col, Container, Row } from "react-grid-system";
import { Slider } from "primereact/slider";
import distributeChange from "./distributeChange";

interface IContribution {
  userId: number;
  factorId: number;
  name: string;
  value: number;
};

interface Props {
  rootPath?: string;
};

export default function InstallmentReport(props: Props) {
  const endpointSet = "installment";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[endpointSet]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const debug = useTypedSelector(
    state => state.context.config.debug
  );
  const user = useTypedSelector(state => state.profile.user);
  const navigate = useNavigate();

  const { installmentId } = useParams();

  const dispatch = useDispatch();
  const [dirty, setDirty] = useState(false);

  const [t, i18n] = useTranslation("installments");

  const [initialised, setInitialised] = useState(false);
  // I need to fix this to use the standard
  const [curPanel, setCurPanel] = useState(0);
  const [group, setGroup] = useState({});
  const [factors, setFactors] = useState({});

  const [project, setProject] = useState({});
  const [sliderSum, setSliderSum] = useState(0);

  const [contributions, setContributions] = useState({});
  const [installment, setInstallment] = useState({ comments: "" });

  const updateSlice = (id, update) => {
    const lContributions = Object.assign({}, contributions);

    lContributions[id] = update;
    setContributions(lContributions);
  };

  const updateComments = event => {
    const inst = Object.assign({}, installment);
    inst.comments = event.target.value;
    setInstallment(inst);
  };

  useEffect(() => setDirty(true), [contributions, installment]);

  useEffect(() => {
    if (endpointStatus) {
      getContributions();
    }
  }, [endpointStatus]);

  //Use this to sort team members with the user on top
  const userCompare = (b, a) => {
    var retVal = 0;
    if (user.id == a.userId) {
      retVal = +1;
    } else {
      retVal = a.name.localeCompare(b.name);
    }
    return retVal;
  };
  const setPanel = panelId => {
    //If the panel is already selected...
    if (panelId == curPanel) {
      //...close it.
      setCurPanel(null);
      //Otherwise...
    } else {
      //...open it
      setCurPanel(panelId);
    }
  };

  const saveButton = (
    <Button onClick={() => saveContributions()}>
      <Suspense fallback={<Skeleton className="mb-2" />}>
        {t("submit")}
      </Suspense>
    </Button>
  );

  //Retrieve the latest data
  const getContributions = () => {
    const url =
      props.rootPath === undefined
        ? `${endpoints.baseUrl}${installmentId}.json`
        : `/${props.rootPath}${endpoints.baseUrl}${installmentId}.json`;

    dispatch(startTask());
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        const factorsData = Object.assign({}, data.factors);
        setFactors(factorsData);

        setSliderSum(data.sliderSum);

        //Process Contributions
        const contributions = data.installment.values.reduce(
          (valuesAccum, value) => {
            const values = valuesAccum[value.factor_id] || [];
            values.push({
              userId: value.user_id,
              factorId: value.factor_id,
              name: data.group.users[value.user_id].name,
              value: value.value
            });
            valuesAccum[value.factor_id] = values.sort(userCompare);
            return valuesAccum;
          },
          {}
        );
        delete data.installment.values;
        setInstallment(data.installment);

        setContributions(contributions);
        setDirty(false);
        setGroup(data.group);
        data.installment.group_id = data.group.id;

        setProject(data.installment.project);
        setInitialised(true);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
      });
  };
  //Store what we've got
  const saveContributions = () => {
    dispatch(startTask("saving"));
    const url =
      (props.rootPath === undefined ? "" : `/${props.rootPath}`) +
      endpoints.saveInstallmentUrl +
      (Boolean(installment.id) ? `/${installment.id}` : ``) +
      ".json";
    const method = Boolean(installment.id) ? "PATCH" : "POST";

    const body = {
      contributions: contributions,
      installment: installment
    };
    axios({
      url: url,
      method: method,
      data: body
    })
      .then(response => {
        const data = response.data;
        //Process Contributions
        if (!data.error) {
          setInstallment(data.installment);
          const receivedContributions = data.installment.values.reduce(
            (valuesAccum, value) => {
              const values = valuesAccum[value.factor_id] || [];
              values.push({
                userId: value.user_id,
                factorId: value.factor_id,
                name: group["users"][value.user_id].name || "",
                value: value.value
              });
              valuesAccum[value.factor_id] = values.sort(userCompare);
              return valuesAccum;
            },
            {}
          );
          setContributions(receivedContributions);
          navigate(`..`);
        }
        if (data.messages.status !== undefined) {
          dispatch(addMessage(data.messages.status, new Date(), Priorities.ERROR));
        }
        setDirty(false);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask("saving"));
      })
  };

  return (
    <Panel>
      <Suspense fallback={<Skeleton className="mb-2" height={"10rem"} />}>
        <h1>{t("subtitle")}</h1>
        <p>
          {parse(
            t("instructions", {
              group_name: group["name"],
              project_name: project["name"],
              member_count: Object.keys(group["users"] || {}).length,
              factor_count: Object.keys(factors || {}).length
            })
          )}
        </p>
        <p>{t("slider.instructions")}</p>
      </Suspense>
      <Suspense fallback={<Skeleton height={"30rem"} />}>
        <div id="installments">
          <Accordion
            activeIndex={curPanel}
            onTabChange={event => setCurPanel(event.index)}
          >
            {Object.keys(contributions).map(sliceId => {
              return (
                <AccordionTab
                  header={factors[sliceId].name}
                  pt={{
                    headerTitle: {
                      factorId: sliceId
                    }
                  }}
                  key={sliceId}
                >
                  <Container>
                    <Row>
                      <Col xs={12}>
                        <p>{factors[sliceId].description}</p>
                      </Col>
                    </Row>
                    {contributions[sliceId].map((contrib, index) => {
                      return (
                        <Row
                          key={"key_fs_" + sliceId + "_c_" + contrib.userId}
                        >
                          <Col xs={12} md={3}>
                            <h5>{contrib.name}</h5>
                          </Col>
                          <Col xs={12} md={9}>
                            <Slider
                              value={contrib.value}
                              id={"fs_" + sliceId + "_c_" + contrib.userId}
                              itemID={"fs_" + sliceId + "_c_" + contrib.userId}
                              name={"fs_" + sliceId + "_c_" + contrib.userId}
                              max={sliderSum}
                              min={0}
                              onChange={event => {
                                updateSlice(sliceId, distributeChange(contributions[sliceId], sliderSum, index, event.value));
                              }}
                            />
                            {debug ? (
                              <input
                                type="number"
                                data-contributor-id={contrib.userId}
                                data-factor-id={sliceId}
                                value={contrib.value}
                                id={"debug_fs_" + contrib.userId + "_c_" + contributions[sliceId].userId}
                                onChange={event => {
                                  updateSlice(sliceId, distributeChange(contributions[sliceId], sliderSum, index, parseInt(event.target.value)));
                                }}
                              />
                            ) : null}

                          </Col>
                        </Row>

                      )

                    })}
                  </Container>
                </AccordionTab>
              );
            })}
          </Accordion>
        </div>
        <br />
        <br />
        <Accordion>
          <AccordionTab header={t("comment_prompt")}>
            <span className="p-float-label">
              <InputTextarea
                value={installment.comments || ""}
                name="comments"
                id="comments"
                itemID="comments"
                autoResize={true}
                onChange={updateComments}
              />
              <label htmlFor="Comments">
                {t("comment_input_prompt")}
              </label>
            </span>
          </AccordionTab>
        </Accordion>
      </Suspense>
      {saveButton}
      <div
        id="installment_debug_div"
        style={{
          height: "10px",
          margin: "auto",
          width: "10px",
          opacity: 0,
          border: "0px"
        }}
      >
      </div>
    </Panel>
  );
}
export { IContribution }