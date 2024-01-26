import React, { useState } from "react";

import axios from "axios";

import { useTranslation } from "react-i18next";
import { DateTime } from "luxon";
import { useNavigate } from "react-router-dom";
import { useDispatch } from "react-redux";
import {
    startTask,
    endTask,
    addMessage,
    Priorities,
} from "../infrastructure/StatusSlice";

import { Button } from "primereact/button";
import { Column } from "primereact/column";
import { DataTable } from "primereact/datatable";

import CourseAdminListToolbar from "./CourseAdminListToolbar";
import { iconForType } from "../ActivityLib";

import { IActivityLink } from "./CourseDataAdmin";
import { a } from "react-spring";

enum ActivityType {
    BingoGame = "bingo_game",
    Experience = "experience",
    Project = "project",
    Assignment = "assignment",
};

interface IActivity {
    id: number;
    name: string;
    active: boolean;
    type: ActivityType;
    start_date: Date;
    end_date: Date;
    link: string;
};

enum ACTIVITY_COLS {
    STATUS = "status",
    OPEN = "open",
    CLOSE = "close",
}


type Props = {
    activities: IActivity[];
    newActivityLinks: Array<IActivityLink>;
    refreshFunc: () => void;
};

export default function ActivityList(props: Props) {
    const category = 'course';
    const { t } = useTranslation(`${category}s`);
    const navigate = useNavigate();
    const dispatch = useDispatch();

    const [filterText, setFilterText] = React.useState('');
    const optColumns = [
        ACTIVITY_COLS.STATUS,
        ACTIVITY_COLS.OPEN,
        ACTIVITY_COLS.CLOSE,
    ]
    const [optActivityColumns, setOptActivityColumns] = useState(optColumns);

    return (
        <DataTable
            value={props.activities.filter((activity) => {

                //Add filtering here
                return filterText.length === 0 || activity.name.includes(filterText);

            })}
            resizableColumns
            reorderableColumns
            paginator
            rows={5}
            tableStyle={{
                minWidth: '50rem'
            }}
            rowsPerPageOptions={
                [5, 10, 20, props.activities.length]
            }
            header={
                <CourseAdminListToolbar
                    newActivityLinks={props.newActivityLinks}
                    filtering={{
                        filterValue: filterText,
                        setFilterFunc: setFilterText,
                    }}
                    columnToggle={{
                        optColumns: optColumns,
                        visibleColumns: optActivityColumns,
                        setVisibleColumnsFunc: setOptActivityColumns,

                    }}
                />}
            sortOrder={-1}
            paginatorDropdownAppendTo={'self'}
            paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
            onRowClick={(event) => {
                const link = event.data.link; //courseActivities[cellMeta.dataIndex].link;
                const activityId = event.data.id; // courseActivities[cellMeta.dataIndex].id;
                navigate(`${link}/${activityId}`);
            }}
            currentPageReportTemplate="{first} to {last} of {totalRecords}"
            dataKey="id"
        >
            <Column
                header={t('activities.type_col')}
                field="type"
                body={(rowData) => {
                    return iconForType(rowData.type);
                }}
            />
            <Column
                header={t('activities.name_col')}
                field="name"
            />
            {optActivityColumns.includes(ACTIVITY_COLS.STATUS) ? (
                <Column
                    header={t('activities.status_col')}
                    field="status"
                    body={(rowData) => {
                        if (!rowData.active) {
                            return 'Not Activated'
                        }
                        else if (rowData.end_date > new Date()) {
                            return "Active";
                        } else {
                            return "Expired";
                        }
                    }}
                />) : null
            }
            {optActivityColumns.includes(ACTIVITY_COLS.OPEN) ? (
                <Column
                    header={t('activities.open_col')}
                    field="start_date"
                    body={(rowData) => {
                        return <span>{DateTime.fromISO( rowData.start_date ).toLocaleString() }</span>;
                    }}
                />
            ) : null}
            {optActivityColumns.includes(ACTIVITY_COLS.CLOSE) ? (
                <Column
                    header={t('activities.close_col')}
                    field="end_date"
                    body={(rowData) => {
                        return <span>{DateTime.fromISO( rowData.end_date ).toLocaleString( )}</span>;

                    }}
                />
            ) : null}
            <Column
                header=''
                field="link"
                body={(rowData) => {
                    const lbl = t('activities.delete_lbl');
                    return (
                        <Button
                            icon="pi pi-trash"
                            aria-label="Delete"
                            tooltip={lbl}
                            onClick={event => {
                                dispatch(startTask("deleting"));
                                axios
                                    // Is this right? Shouldn't it be params.value?
                                    .delete(rowData.link, {})
                                    .then(response => {
                                        const data = response.data;
                                        props.refreshFunc();
                                        dispatch( addMessage(
                                                data.message, new Date(), Priorities.INFO
                                            ));
                                        //setMessages(data.messages);
                                        dispatch(endTask("deleting"));
                                    })
                                    .catch(error => {
                                        console.log("error:", error);
                                    }).finally(() => {
                                        dispatch(endTask("deleting"));
                                    })
                            }}
                        />
                    );
                }}
            />

        </DataTable>

    )
}

export { ActivityType, IActivity as Activity };