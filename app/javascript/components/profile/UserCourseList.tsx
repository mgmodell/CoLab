import React, { useState, useEffect } from "react";

import { useDispatch } from "react-redux";

import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";

import WorkingIndicator from "../infrastructure/WorkingIndicator";
import BingoDataRepresentation from "../BingoBoards/BingoDataRepresentation";
import { useTranslation } from "react-i18next";
import StandardListToolbar from "../StandardListToolbar";
import { Panel } from "primereact/panel";
import { DataTable } from "primereact/datatable";
import { Column } from "primereact/column";

interface ICourse {
  id: number;
  name: string;
  number: string;
  experience_performance: number;
  bingo_performance: number;
  assessment_performance: number;
  bingo_data: Array<number>;
}

type Props = {
  retrievalUrl: string;
  coursesList: Array<ICourse>;
  coursesListUpdateFunc: (coursesList: Array<ICourse>) => void;
};

enum OPT_COLS {
  NAME = 'name',
  NUMBER = 'number',
  BINGO = 'bingo',
  ASSESSMENT = 'assessment',
  EXPERIENCE = 'experience',
}

export default function UserCourseList(props: Props) {
  const dispatch = useDispatch();

  const category = "profile";
  const { t } = useTranslation(`${category}s`);
  const [filterText, setFilterText] = useState('');

  const optColumns = [
    t(`course_status.${OPT_COLS.NAME}`),
    t(`course_status.${OPT_COLS.NUMBER}`),
    t(`course_status.${OPT_COLS.BINGO}`),
    t(`course_status.${OPT_COLS.ASSESSMENT}`),
    t(`course_status.${OPT_COLS.EXPERIENCE}`),
  ];
  const [visibleColumns, setVisibleColumns] = useState([]);

  const getCourses = () => {
    dispatch(startTask());
    var url = props.retrievalUrl;
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //MetaData and Infrastructure
        props.coursesListUpdateFunc(data);
        dispatch(endTask());
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  useEffect(() => {
    if (null == props.coursesList || props.coursesList.length < 1) {
      getCourses();
    }
  }, []);


  const courseList =
    null != props.coursesList ? (
      <>
      <DataTable
        value={props.coursesList.filter((course) => {
          return filterText.length === 0 ||
          course.name.includes(filterText) ||
          course.number.includes(filterText);
        })}
        resizableColumns
        tableStyle={{
          minWidth: '50rem'
        }}
        reorderableColumns
        paginator
        rows={5}
        rowsPerPageOptions={
          [5, 10, 20, props.coursesList.length]
        }
        header={
          <StandardListToolbar
          itemType={'activity'}
          filtering={{
            filterValue: filterText,
            setFilterFunc: setFilterText
          }}
          columnToggle={{
            optColumns: optColumns,
            visibleColumns: visibleColumns,
            setVisibleColumnsFunc: setVisibleColumns,
          }}
        />}
        sortField="name"
        sortOrder={-1}
        paginatorDropdownAppendTo={'self'}
        paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
        currentPageReportTemplate="{first} to {last} of {totalRecords}"
        //paginatorLeft={paginatorLeft}
        //paginatorRight={paginatorRight}
        dataKey="id"
        >
          <Column
            header={t("course_status.name")}
            field="name"
            sortable
            filter
            />
          <Column
            header={t("course_status.number")}
            field="number"
            sortable
            filter
            />
          <Column
            header={t("course_status.bingo")}
            field="id"
            sortable
            filter
            body={(rowData) => {
              const data = rowData.bingo_data;
              return (
                <BingoDataRepresentation
                  height={30}
                  width={70}
                  value={Number(rowData.bingo_performance)}
                  scores={data}
                />
              );
            }}
            />
          <Column
            header={t("course_status.assessment")}
            field="assessment_performance"
            sortable
            filter
            body={(rowData) => {
              return `${rowData.assessment_performance}%`;
            }}
            />
          <Column
            header={t("course_status.experience")}
            field="experience_performance"
            sortable
            filter
            body={(rowData) => {
              return `${rowData.experience_performance}%`;
            }}
            />
        </DataTable>
      </>
    ) : (
      "The course data is loading"
    );

  return (
    <Panel>
      <WorkingIndicator identifier="courses_loading" />
      {courseList}
    </Panel>
  );
}
