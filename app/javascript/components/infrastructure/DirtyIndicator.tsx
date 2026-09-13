import React, { useEffect } from "react";
import { useLocation } from "react-router";
import { useTypedSelector } from "./AppReducers";
import { useTranslation } from "react-i18next";
import { DIRTY_STATUS } from "./StatusSlice";

type Props = {
};
export default function DirtyIndicator(props: Props) {

    const category = 'home';
    const { t } = useTranslation(category);
    const location = useLocation();

    const panelHasDirtyChanges = useTypedSelector(state => {
        const dirtyStatus = state.status.dirtyStatus as Record<string, boolean>;
        const panels = location.pathname.split('/') || [];
        const dataPanel = Number(panels.at(-1)) > 0 ? panels.at(-2) : panels.at(-1);

        switch (dirtyStatus[dataPanel || '']) {
            case null:
            case undefined:
                return DIRTY_STATUS.NONE;
            case 0:
            case false:
                return DIRTY_STATUS.CLEAN;
            default:
                return DIRTY_STATUS.DIRTY;
        }
    });

    return (
        panelHasDirtyChanges !== DIRTY_STATUS.NONE ? (
            <div style={{ display: "flex", justifyContent: "center", width: "100%", padding: "0.5rem 0 0.25rem", position: "relative", zIndex: 1100 }}>
                <div
                    aria-live="polite"
                    role="status"
                    style={{
                        display: "inline-flex",
                        justifyContent: "center",
                        alignItems: "center",
                        gap: "0.5rem",
                        padding: "0.35rem 0.75rem",
                        borderRadius: "999px",
                        border: `1px solid ${panelHasDirtyChanges ? "#f59e0b" : "#16a34a"}`,
                        backgroundColor: panelHasDirtyChanges === DIRTY_STATUS.DIRTY ? "#fff7ed" : "#f0fdf4",
                        color: panelHasDirtyChanges === DIRTY_STATUS.DIRTY ? "#b45309" : "#166534",
                        fontSize: "0.8rem",
                        fontWeight: 600,
                        lineHeight: 1.4,
                        width: "fit-content",
                        position: "relative",
                        //zIndex: 1101
                    }}
                >
                    <i className="pi pi-fw pi-save" />
                </div>
            </div>

        ) : null
    )
}