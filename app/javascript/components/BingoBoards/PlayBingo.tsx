import React from "react";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { useParams } from "react-router";
import { useTranslation } from "react-i18next";

type Props = {
    rootPath?: string;
};

export default function PlayBingo(props: Props) {
    const category = 'bingo_game';
    const endpoints = useTypedSelector(
        state => state.context.endpoints[category]
    );
    const endpointsLoaded = useTypedSelector(
        state => state.context.status.endpointsLoaded
    );
    const {bingoGameId} = useParams();
    const [t, i18n] = useTranslation(`${category}s`);

    return (
        <div className="play-bingo">
            <h1>{t("play.title")}</h1>
            <p>
                {t("play.welcome_msg")}
            </p>
            <p>
                {t("play.navigation_msg")}
            </p>
        </div>
    );
}