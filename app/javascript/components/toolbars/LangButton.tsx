import React, { useRef } from "react";

import { useDispatch } from "react-redux";
import { LANGUAGES } from "../infrastructure/i18n";

import { setLocalLanguage } from "../infrastructure/ProfileSlice";

import { Menu } from "primereact/menu";
import { Button } from "primereact/button";
import { useTranslation } from "react-i18next";
import { useTypedSelector } from "../infrastructure/AppReducers";


type Props = {
}
export default function LangButton(props: Props) {

    const buttonRef = useRef(null);
    const dispatch = useDispatch();
    const languages = useTypedSelector(state => state.context.lookups.languages);
    const [t, i18n] = useTranslation();

    const languageMenu = LANGUAGES.map((lang) => {
        return (
            {
                label: lang.name,
                icon: "pi pi-flag",
                command: () => {
                    const localLang = languages.find((l) => l.code === lang.code);
                    dispatch( setLocalLanguage( localLang.id))
                }
            }
        )
    });


    return (
        <div>
            <Menu model={languageMenu} popup={true} ref={buttonRef} />
            <Button
                icon="pi pi-globe"
                aria-controls="lang-menu"
                aria-haspopup={true}
                onClick={(event) => buttonRef.current.toggle(event)}
                size="small"
                rounded
                text
                outlined
            >
                {i18n.language}
            </Button>
        </div>
    );
}