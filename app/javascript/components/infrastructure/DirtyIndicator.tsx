import React, { useEffect } from "react";
import { useTypedSelector } from "./AppReducers";
import { useTranslation } from "react-i18next";

type Props = {
};
export default function DirtyIndicator(props: Props) {

    const category = 'home';
    const {t} = useTranslation(category);

    const hasDirtyChanges = useTypedSelector(state => {
        const dirtyStatus = state.status.dirtyStatus as Record<string, boolean>;
        for (const key in dirtyStatus) {
            if (dirtyStatus[key]) {
                return true;
            }
        }
        return false;
    });

    return (
        hasDirtyChanges ? (
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
                    border: `1px solid ${hasDirtyChanges ? "#f59e0b" : "#16a34a"}`,
                    backgroundColor: hasDirtyChanges ? "#fff7ed" : "#f0fdf4",
                    color: hasDirtyChanges ? "#b45309" : "#166534",
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