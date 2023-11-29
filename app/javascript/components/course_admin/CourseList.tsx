import React, { useState, useEffect, Suspense } from "react";
import axios from "axios";
import { useDispatch } from "react-redux";
import { useLocation, useNavigate } from "react-router-dom";

import { DateTime } from "luxon";

import { Skeleton } from 'primereact/skeleton';
import { Button } from "primereact/button";

import { DataTable } from "primereact/datatable";
import { ColumnMeta } from "../infrastructure/Types";

import CopyActivityButton from "./CopyActivityButton";
import { useTypedSelector } from "../infrastructure/AppReducers";
import { startTask, endTask } from "../infrastructure/StatusSlice";
import WorkingIndicator from "../infrastructure/WorkingIndicator";
import { useTranslation } from "react-i18next";
import {
  renderDateCellExpand,
  renderTextCellExpand
} from "../infrastructure/GridCellExpand";
import AdminListToolbar from "../infrastructure/AdminListToolbar";
import { Column } from "primereact/column";
import { PrimeIcons } from "primereact/api";

export default function CourseList(props) {
  const category = "course";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status.endpointsLoaded
  );


  const navigate = useNavigate();
  const location = useLocation();
  const { t } = useTranslation(`${category}s`);

  const user = useTypedSelector(state => state.profile.user);
  const [messages, setMessages] = useState({});
  const [showErrors, setShowErrors] = useState(false);

  const dispatch = useDispatch();
  const optColumns: Array<ColumnMeta> = [
    {
      header: t("index.number_col"),
      field: "number",
      sortable: true,
      filterable: false,
      key: 'number',
      body: param => {
        return(
          <span className={'pi pi-users'} >
            &nbsp;{param.number}
          </span>
        )

      }
    },
    {
      header: t('index.name_col'),
      field: 'name',
      sortable: true,
      filterable: false,
      body: param => {
        return renderTextCellExpand( param.name );
      }
    }
  ];

  const [courses, setCourses] = useState([]);
  const [newStartDate, setNewStartDate] = useState(DateTime.local());
  const [filterText, setFilterText] = useState('');


  const getCourses = () => {
    const url = endpoints.baseUrl + ".json";
    dispatch(startTask("loading"));

    axios
      .get(url, {})
      .then(response => {
        //Process the data
        setCourses(response.data);
        dispatch(endTask("loading"));
      })
      .catch(error => {
        console.log("error", error);
      });
  };

  useEffect(() => {
    if (endpointStatus) {
      dispatch(endTask("loading"));
      getCourses();
    }
  }, [endpointStatus]);

  const postNewMessage = msgs => {
    setMessages(msgs);
    setShowErrors(true);
  };

  const dataTable = (
    <>
    <DataTable
      value={courses.filter( (course) =>{
        return filterText.length === 0 || course.name.includes( filterText );
      })}
      resizableColumns
      tableStyle={{
        minWidth: '50rem'
      }}
      reorderableColumns
      paginator
      rows={5}
      rowsPerPageOptions={
        [5, 10, 20, courses.length]
      }
      header={<AdminListToolbar
        itemType={category}
        filterValue={filterText}
        setFilterFunc={setFilterText}
        />}
      sortField="start_date"
      sortOrder={-1}
      paginatorDropdownAppendTo={'self'}
      paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
      currentPageReportTemplate="{first} to {last} of {totalRecords}"
      //paginatorLeft={paginatorLeft}
      //paginatorRight={paginatorRight}
      dataKey="id"
      onRowClick={(event) =>{
          const courseId = event.data.id;
          const locaLocation = `${location.pathname}/${String(courseId)}`;
          navigate(locaLocation, { relative: "path" });
      }}
      >
        <Column
          header={t('index.number_col')}
          field="number"
          sortable
          filter
          key={'number'}
          body={param=>{
            return(
              <span className={'pi pi-users'} >
                &nbsp;{param.number}
              </span>
            )
          }}
          />
        <Column
          header={t('index.name_col')}
          field="name"
          sortable
          filter
          key={'name'}
          />
        <Column
          header={t('index.school_col')}
          field="school_name"
          sortable
          filter
          key={'school_name'}
          />
        <Column
          header={t('index.open_col')}
          sortable
          filter
          field="start_date"
          body={(param)=>{
            return(
              <>
              {DateTime.fromISO( param.start_date).toLocaleString()}
              </>
            )
          }}
          />
        <Column
          header={t('index.close_col')}
          sortable
          filter
          field="end_date"
          body={(param)=>{
            return(
              <>
              {DateTime.fromISO( param.end_date).toLocaleString()}
              </>
            )
          }}
          />
        <Column
          header={t('index.faculty_col')}
          field="faculty_count"
          sortable
          filter
          key={'faculty_count'}
          />
        <Column
          header={t('index.students_col')}
          field="student_count"
          sortable
          filter
          key={'student_count'}
          />
        <Column
          header={t('index.projects_col')}
          field="project_count"
          sortable
          filter
          key={'project_count'}
          />
        <Column
          header={t('index.experiences_col')}
          field="experience_count"
          sortable
          filter
          key={'experience_count'}
          />
        <Column
          header={t('index.bingo_games_col')}
          field="bingo_game_count"
          sortable
          filter
          key={'bingo_game_count'}
          />
        <Column
          header={t('index.actions_col')}
          field="id"
          body={(course) =>{
            //const course = params.row;
            const scoresUrl = endpoints.scoresUrl + course.id + ".csv";
            const copyUrl = endpoints.courseCopyUrl + course.id + ".json";
            return(
              <>
              <Button
                icon='pi pi-download'
                tooltip={'Download Scores to CSV'}
                tooltipOptions={{
                  position: 'left',
                }}
                id={"csv-" + course.id}
                onClick={event => {
                  window.location.href = scoresUrl;
                  event.preventDefault();
                }}
                aria-label="Download scores as CSV"
                size="large"
              />
            <CopyActivityButton
              copyUrl={copyUrl}
              itemId={course.id}
              itemUpdateFunc={getCourses}
              startDate={new Date(course["start_date"])}
              addMessagesFunc={postNewMessage}
            />
              </>

            )

          }
          }
          />

      </DataTable>

    </>
  );

  return (
    <Suspense fallback={<Skeleton className={'mb-2'} />}>
      <WorkingIndicator identifier="courses_loading" />
      {null !== user.lastRetrieved ? (
        <div style={{ maxWidth: "100%" }}>{dataTable}</div>
      ) : null}
    </Suspense>
  );
}

CourseList.propTypes = {};
