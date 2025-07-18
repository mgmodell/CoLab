import React, { useState, useEffect, useMemo, Fragment } from "react";
import { useDispatch } from "react-redux";

import WorkingIndicator from "../infrastructure/WorkingIndicator";

// Icons - maybe replace later
import { startTask, endTask } from "../infrastructure/StatusSlice";
import axios from "axios";
import { useTranslation } from "react-i18next";
import { DataTable } from "primereact/datatable";
import UserListAdminToolbar from "./UserListAdminToolbar";
import { Column } from "primereact/column";
import { Button } from "primereact/button";
import { Tooltip } from "primereact/tooltip";
import { FilterMatchMode } from "primereact/api";

const DropUserButton = React.lazy(() => import("./DropUserButton"));
const BingoDataRepresentation = React.lazy(() =>
  import("../BingoBoards/BingoDataRepresentation")
);
enum OPT_COLS {
  FIRST_NAME = "first_name",
  LAST_NAME = "last_name",
  EMAIL = "email",
  BINGO_PERF = "bingo_performance",
  CHECKIN_RECORD = "checkin_record",
  EXPERIENCE_COMPLETION = "experience_completion",
  STATUS = "status",
  ACTIONS = "actions"
}

enum UserListType {
  student = "student",
  instructor = "instructor",
  invited_student = "invited_student",
  assistant = "assistant",
  enrolled_student = "enrolled_student",
  requesting_student = "requesting_student",
  rejected_student = "rejected_student",
  dropped_student = "dropped_student",
  declined_student = "declined_student"
}

interface IStudentData {
  assessment_performance: number;
  bingo_data: Array<number>;
  bingo_performance: number;
  drop_link: string;
  email: string;
  experience_performance: number;
  first_name: string;
  id: number;
  last_name: string;
  reinvite_link: string;
  status: UserListType;
}

type Props = {
  courseId: number;
  retrievalUrl: string;
  usersList: Array<IStudentData>; //Need an interface for the users
  usersListUpdateFunc: (usersList: Array<IStudentData>) => void;
  userType: UserListType;
  addMessagesFunc: ({}) => void;
};

export default function CourseUsersList(props: Props) {
  const category = "course";
  const { t } = useTranslation(`${category}s`);

  const [addUsersPath, setAddUsersPath] = useState("");
  const [procRegReqPath, setProcRegReqPath] = useState("");

  const dispatch = useDispatch();

  const [filterText, setFilterText] = useState("");
  const [columnsToShow, setColumnsToShow] = useState([]);
  const [filters, setFilters] = useState({
    global: { value: null, matchMode: FilterMatchMode.CONTAINS }, 
        first_name: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
        last_name: { value: null, matchMode: FilterMatchMode.STARTS_WITH },
        email: { value: null, matchMode: FilterMatchMode.CONTAINS },
        status: { value: null, matchMode: FilterMatchMode.EQUALS },
    });

  const optColumns = [
    t(OPT_COLS.EMAIL),
    t(OPT_COLS.CHECKIN_RECORD),
    t(OPT_COLS.BINGO_PERF),
    t(OPT_COLS.EXPERIENCE_COMPLETION)
  ];

  const getUsers = () => {
    dispatch(startTask());
    var url = props.retrievalUrl;
    axios
      .get(url, {})
      .then(response => {
        const data = response.data;
        //MetaData and Infrastructure
        if ("student" == props.userType) {
          setAddUsersPath(data.add_function.students + ".json");
        } else {
          setAddUsersPath(data.add_function.instructor + ".json");
        }
        setProcRegReqPath(data.add_function.proc_self_reg + ".json");
        props.usersListUpdateFunc(data.users);
      })
      .catch(error => {
        console.log("error", error);
      })
      .finally(() => {
        dispatch(endTask());
      });
  };

  const refreshFunc = newMessages => {
    getUsers();
    props.addMessagesFunc(newMessages);
  };

  useEffect(() => {
    if (null == props.usersList || props.usersList.length < 1) {
      getUsers();
    }
  }, []);

  const iconForStatus = status => {
    var icon;
    switch (status.toLowerCase()) {
      case "enrolled":
      case "enrolled_student":
        icon = (
          <>
            <i className="pi pi-check-circle enrolled" />
          </>
        );
        break;
      case "undetermined":
      case "invited_student":
      case "requesting_student":
        icon = "pi pi-question-circle";
        break;
      case "dropped":
      case "rejected_student":
      case "dropped_student":
      case "declined_student":
        icon = "pi pi-ban";
        break;
      case "instructor":
      case "assistant":
        icon = "pi pi-users";
        break;
      default:
        console.log("status not found: " + status);
    }
    return icon;
  };

  const newUserList = useMemo(() => {
    return (
      <>
        <DataTable
          value={props.usersList.filter(user => {
            if( UserListType.declined_student === user.status ||
                UserListType.dropped_student === user.status ||
                UserListType.rejected_student === user.status ){
              return false;
            } else {
              const checkType =
                UserListType.instructor !== user.status &&
                UserListType.assistant !== user.status;
              return UserListType.instructor === props.userType
                ? !checkType
                : checkType;

            }

          })}
          resizableColumns
          reorderableColumns
          globalFilterFields={["first_name", "last_name", "email", "status"]}
          filters={filters}
          filterDisplay="row"
          paginator
          rows={5}
          tableStyle={{
            minWidth: "50rem"
          }}
          rowsPerPageOptions={[
            5,
            10,
            20,
            props.usersList.filter(user => {
            if( UserListType.declined_student === user.status ||
                UserListType.dropped_student === user.status ||
                UserListType.rejected_student === user.status ){
              return false;
            } else {
              const checkType =
                UserListType.instructor !== user.status &&
                UserListType.assistant !== user.status;
              return UserListType.instructor === props.userType
                ? !checkType
                : checkType;
            }
            }).length
          ]}
          header={
            <UserListAdminToolbar
              courseId={props.courseId}
              userType={props.userType}
              usersListUpdateFunc={props.usersListUpdateFunc}
              retrievalUrl={props.retrievalUrl}
              addMessagesFunc={props.addMessagesFunc}
              refreshUsersFunc={getUsers}
              addUsersPath={addUsersPath}
              filtering={{
                filterValue: filterText,
                setFilterFunc: setFilterText
              }}
              columnToggle={{
                setVisibleColumnsFunc: setColumnsToShow,
                optColumns: optColumns,
                visibleColumns: columnsToShow
              }}
            />
          }
          sortOrder={-1}
          paginatorDropdownAppendTo={"self"}
          paginatorTemplate="RowsPerPageDropdown FirstPageLink PrevPageLink CurrentPageReport NextPageLink LastPageLink"
          currentPageReportTemplate="{first} to {last} of {totalRecords}"
          dataKey="id"
        >
          <Column
            header={t("first_name")}
            field="first_name"
            sortable
            data-id="first_name"
            filter
            key={"first_name"}
          />
          <Column
            header={t("last_name")}
            field="last_name"
            sortable
            data-id="last_name"
            filter
            key={"last_name"}
          />
          {columnsToShow.includes(t(OPT_COLS.EMAIL)) ? (
            <Column
              header={t("email")}
              field="email"
              sortable
              data-id="email"
              filter
              key={"email"}
              body={params => {
                return <a href="mailto:{params.email}">{params.email}</a>;
              }}
            />
          ) : null}
          {columnsToShow.includes(t(OPT_COLS.BINGO_PERF)) ? (
            <Column
              header={t("bingo_progress")}
              field="bingo_performance"
              sortable
              data-id="bingo_performance"
              filter
              key={"bingo_performance"}
              body={params => {
                return (
                  <BingoDataRepresentation
                    height={30}
                    width={70}
                    value={Number(params.bingo_data)}
                    scores={params.bingo_data}
                  />
                );
              }}
            />
          ) : null}
          {columnsToShow.includes(t(OPT_COLS.CHECKIN_RECORD)) ? (
            <Column
              header={t("checkin_record")}
              field="assessment_performance"
              body={params => {
                return `${params.assessment_performance}%`;
              }}
            />
          ) : null}
          {columnsToShow.includes(t(OPT_COLS.EXPERIENCE_COMPLETION)) ? (
            <Column
              header={t("experience_completion")}
              field="experience_performance"
              body={params => {
                return `${params.experience_performance}%`;
              }}
            />
          ) : null}
          {columnsToShow.includes(t(OPT_COLS.STATUS)) ? (
            <Column
              header={t("status")}
              field="status"
              body={params => {
                return iconForStatus(params.status);
              }}
            />
          ) : null}
          <Column
            header={t("actions")}
            field="status"
            sortable
            body={params => {
              const user = props.usersList.filter(user => {
                return params.id === user.id;
              })[0];
              const btns = [];
              switch (user.status) {
                case UserListType.invited_student:
                  btns.push(
                    <Button
                      tooltip={t("re-send_invitation")}
                      aria-label={t("re-send_invitation")}
                      icon="pi pi-envelope"
                      onClick={event => {
                        dispatch(startTask("inviting"));
                        axios
                          .get(user.reinvite_link, {})
                          .then(response => {
                            const data = response.data;
                            refreshFunc(data.messages);
                          })
                          .catch(error => {
                            console.log("error", error);
                          })
                          .finally(() => {
                            dispatch(endTask("inviting"));
                          });
                      }}
                    />
                  );
                case UserListType.instructor:
                case UserListType.assistant:
                case UserListType.enrolled_student:
                  btns.push(
                    <DropUserButton
                      key="drop-student-button"
                      dropUrl={user.drop_link}
                      refreshFunc={refreshFunc}
                    />
                  );
                  break;
                case UserListType.requesting_student:
                  const acceptLbl = t("accept_student");
                  const lbl2 = t("decline_student");
                  btns.push(
                    <Button
                      tooltip={acceptLbl}
                      icon="pi pi-check"
                      aria-label={acceptLbl}
                      onClick={event => {
                        dispatch(startTask("accepting_student"));
                        axios
                          .patch(procRegReqPath, {
                            roster_id: user.id,
                            decision: true
                          })
                          .then(response => {
                            const data = response.data;
                            refreshFunc(data.messages);
                          })
                          .catch(error => {
                            console.log("error", error);
                          })
                          .finally(() => {
                            dispatch(endTask("accepting_student"));
                          });
                      }}
                    />
                  );
                  btns.push(
                    <Button
                      tooltip={lbl2}
                      aria-label={lbl2}
                      icon="pi pi-times-circle"
                      onClick={event => {
                        dispatch(startTask("decline_student"));
                        axios
                          .patch(procRegReqPath, {
                            roster_id: user.id,
                            decision: false
                          })
                          .then(response => {
                            const data = response.data;
                            refreshFunc(data.messages);
                          })
                          .catch(error => {
                            console.log("error", error);
                          })
                          .finally(() => {
                            dispatch(endTask("decline_student"));
                          });
                      }}
                    />
                  );
                  break;
                case UserListType.rejected_student:
                case UserListType.dropped_student:
                case UserListType.declined_student:
                  const lbl = "Re-Add Student";
                  btns.push(
                    <Button
                      tooltip={lbl}
                      icon="pi pi-user-plus"
                      aria-label={lbl}
                      onClick={event => {
                        dispatch(startTask("re-adding"));
                        axios
                          .put(addUsersPath, {
                            addresses: user.email
                          })
                          .then(response => {
                            const data = response.data;
                            refreshFunc(data.messages);
                          })
                          .catch(error => {
                            console.log("error", error);
                          })
                          .finally(() => {
                            dispatch(endTask("re-adding"));
                          });
                      }}
                    />
                  );
                  break;
                default:
                  console.log("Status not found: " + user.status);
              }

              return btns;
            }}
          />
        </DataTable>
      </>
    );
  }, [props.usersList, columnsToShow, filterText]);

  return (
    <Fragment>
      <Tooltip target={".enrolled"} content="Enrolled" />
      <Tooltip target={".awaiting"} content="Awaiting Response" />
      <Tooltip content="Not Enrolled" target={".not-enrolled"} />
      <Tooltip target={".instructor"} content="Instructor or Assistant" />
      <WorkingIndicator identifier="loading_users" />
      {newUserList}
    </Fragment>
  );
}

export { UserListType, IStudentData as StudentData };
