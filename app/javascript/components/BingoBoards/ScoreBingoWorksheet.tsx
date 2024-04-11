import React, { useState, useEffect } from "react";
import axios from "axios";
import { useNavigate, useParams } from "react-router-dom";
//Redux store stuff
import { useDispatch } from "react-redux";
import { startTask, endTask } from "../infrastructure/StatusSlice";

import { useTranslation } from "react-i18next";

import { InputText } from "primereact/inputtext";
import { Col, Container, Row } from "react-grid-system";
import { Button } from "primereact/button";
import { Panel } from "primereact/panel";

import { useTypedSelector } from "../infrastructure/AppReducers";
import parse from "html-react-parser";

export default function ScoreBingoWorksheet(props) {
  const category = "bingo_game";
  const dispatch = useDispatch();
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointsLoaded = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );
  const [t, i18n] = useTranslation(category);
  const { worksheetIdParam } = useParams();

  const [topic, setTopic] = useState("loading");
  const [description, setDescription] = useState("loading");
  const [worksheetAnswers, setWorksheetAnswers] = useState([[]]);
  const [performance, setPerformance] = useState(0);
  const [resultImgUrl, setResultImgUrl] = useState(null);
  const [newImg, setNewImg] = useState(null);
  const [newImgExt, setNewImgExt] = useState(null);

  const imgFileDataId = "result_photo";

  useEffect(() => {
    if (endpointsLoaded) {
      getWorksheetData();
    }
  }, [endpointsLoaded]);

  const getWorksheetData = () => {
    const url = `${endpoints.worksheetResultsUrl}/${worksheetIdParam}.json`;
    dispatch(startTask());
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        setTopic(data.bingo_game.topic);
        setDescription(data.bingo_game.description);
        setWorksheetAnswers(data.practice_answers);
        setResultImgUrl(data.bingo_game.result_url);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const handleFileSelect = evt => {
    const file = evt.target.files[0];

    if (file) {
      setNewImgExt(file.name.split(".").pop());
      setNewImg(file);
    }
  };
  const submitScore = () => {
    const formData = new FormData();
    if (newImg) {
      formData.append("result_img", newImg);
    }

    formData.append("performance", performance);
    formData.append("img_ext", newImgExt);

    const url = `${endpoints.worksheetScoreUrl}${worksheetIdParam}.json`;

    axios
      .post(url, formData, {
        headers: {
          "content-type": "multipart/form-data"
        }
      })
      .then(response => {
        const data = response.data;
        setResultImgUrl(data.bingo_game.result_url);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const resultImage =
    null === resultImgUrl ? null : (
      <Row>
        <Col xs={12} sm={12}>
          <img src={resultImgUrl} />
        </Col>
      </Row>
    );

  return (
    <Panel>
      <Container>
        <Row>
          <Col xs={12} sm={6}>
            <h2>{t("topic")}:</h2>
          </Col>
          <Col xs={12} sm={6}>
            <h2>{topic}</h2>
          </Col>
        </Row>
        <Row>
          <Col xs={12} sm={6}>
            <h2>{t("description")}:</h2>
          </Col>
          <Col xs={12} sm={6}>
            <p>{parse(description)}</p>
          </Col>
        </Row>
        <Row>
          <Col xs={12} sm={12}>
            <table>
              <tbody>
                {worksheetAnswers.map((answerRow, outerIndex) => {
                  return (
                    <tr key={outerIndex}>
                      {answerRow.map((cell, innerIndex) => {
                        return (
                          <td key={`${outerIndex}-${innerIndex}`}>
                            {null === cell ? "-" : cell}
                          </td>
                        );
                      })}
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </Col>
        </Row>
        <Row>
          <Col xs={12} sm={6}>
            <span className="p-float-label">
              <InputText
                id="score"
                value={performance.toString()}
                type="number"
                onChange={event => {
                  setPerformance(parseInt(event.target.value));
                }}
              />
              <label htmlFor="score">{t("score")}</label>
            </span>
          </Col>
          <Col xs={12} sm={6}>
            <label htmlFor={imgFileDataId}>
              <input
                style={{ display: "none" }}
                id={imgFileDataId}
                name={imgFileDataId}
                onChange={handleFileSelect}
                type="file"
              />
              <Button>{t("file_select")}</Button>
            </label>
          </Col>
        </Row>
        <Row>
          <Col xs={12} sm={12}>
            <Button onClick={submitScore}>{t("submit_scores")}</Button>
          </Col>
        </Row>
        {resultImage}
      </Container>
    </Panel>
  );
}
