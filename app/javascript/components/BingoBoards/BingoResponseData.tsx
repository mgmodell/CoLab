import React, { Suspense, useMemo  } from "react";
import { useParams } from "react-router";

import { Skeleton } from "primereact/skeleton";

import { useTranslation } from "react-i18next";

import ConceptChips from "./ConceptChips";
import BingoGameDataAdminTable from "./BingoGameDataAdminTable";

import { useTypedSelector } from "../infrastructure/AppReducers";
import ResponsesWordCloud from "../Reports/ResponsesWordCloud";

type Props = {
  concepts: Array<{ id: number; name: string }>;
  resultData: Array<any>;
  foundWords: string[];
  reviewed: boolean;

};
export default function BingoResponseData( props: Props) {
  const endpointSet = "bingo_game";
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );

  const { t } = useTranslation("bingo_games");


  const colors = ["#477efd", "#74d6fd", "#3d5ef9", "#2b378b", "#1f2255"];

  const averageScore = useMemo(() => {
    if (props.resultData == null || props.resultData.length === 0) {
      return 0;
    } else {
      const totalScore = props.resultData.reduce((acc, cur) => acc + cur.performance, 0);
      return (totalScore / props.resultData.length).toFixed(2);
    }
  }, [props.resultData]);

  const completionRate = useMemo(() => {
    console.log( "calculating completion rate", props.resultData);
    if (props.resultData == null || props.resultData.length === 0) {
      return 0;
    } else {
      const totalCompletion = props.resultData
        .filter((cur) => cur.concepts_expected > 0)
        .reduce((acc : number, cur) => {
        acc += ( cur.concepts_entered / cur.concepts_expected);
        return acc;
      }, 0);
      return (totalCompletion * 100 / props.resultData.length).toFixed(2);
    }
  }, [props.resultData]);


  return (
    <Suspense fallback={<Skeleton className="mb-2" />}>
      <h5>{t("scored_game.completion_rate", { completion_rate: completionRate })}</h5>
      {props.reviewed ? (
                  <h5>{t("scored_game.average_score", { average_score: averageScore })}</h5>
      ) : (
        <p>{t("scored_game.response_pnl_unreviewed")}</p>
      )}
                  <BingoGameDataAdminTable results_raw={props.resultData} reviewed={props.reviewed} />
      {props.reviewed ? (
        <>
                  <br />
                  <ResponsesWordCloud
                    width={400}
                    height={400}
                    words={props.foundWords}
                    colors={colors}
                  />
                  <ConceptChips concepts={props.concepts} />
        </>

      ) : null }
    </Suspense>
  );
}
