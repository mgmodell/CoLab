/* eslint-disable no-console */
import React, { useEffect, useState } from "react";
import axios from "axios";
import PropTypes from "prop-types";
import Button from "@mui/material/Button";
import classNames from "classnames";
import withStyles from "@mui/styles/withStyles";
import Dialog from "@mui/material/Dialog";
import DialogContent from "@mui/material/DialogContent";
import DialogContentText from "@mui/material/DialogContentText";
import DialogActions from "@mui/material/DialogActions";
import DialogTitle from "@mui/material/DialogTitle";
import Paper from "@mui/material/Paper";
import InputBase from "@mui/material/InputBase";
import SearchIcon from "@mui/icons-material/Search";
import Toolbar from "@mui/material/Toolbar";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import WorkingIndicator from "./infrastructure/WorkingIndicator";
import { SortDirection } from "react-virtualized";
import { useTypedSelector } from "./infrastructure/AppReducers";
import { useTranslation } from "react-i18next";

import WrappedVirtualizedTable from "./WrappedVirtualizedTable";

import { useDispatch } from "react-redux";
import { startTask, endTask } from "./infrastructure/StatusActions";

const styles = theme => ({
  table: {
    fontFamily: theme.typography.fontFamily
  },
  flexContainer: {
    display: "flex",
    alignItems: "center",
    boxSizing: "border-box"
  },
  tableRow: {
    cursor: "pointer"
  },
  tableRowHover: {
    "&:hover": {
      backgroundColor: theme.palette.grey[200]
    }
  },
  tableCell: {
    flex: 1
  },
  noClick: {
    cursor: "initial"
  }
});
export default function ConceptsTable(props) {
  const category = "concept";
  const endpoints = useTypedSelector(
    state => state.context.endpoints[category]
  );
  const endpointStatus = useTypedSelector(
    state => state.context.status["endpointsLoaded"]
  );
  const dispatch = useDispatch();

  const [conceptsRaw, setConceptsRaw] = useState([]);
  const [concepts, setConcepts] = useState([]);

  //const [search, setSearch] = useState("");
  const [sortBy, setSortBy] = useState("name");
  const [sortDirection, setSortDirection] = useState(SortDirection.DESC);

  const [editing, setEditing] = useState(false);
  const [dirty, setDirty] = useState(false);
  const [conceptName, setConceptName] = useState("");
  const [conceptId, setConceptId] = useState(-1);
  const { t } = useTranslation(`${category}s`);

  const columns = [
    {
      width: 200,
      flexGrow: 1.0,
      label: t("name"),
      dataKey: "name",
      numeric: false,
      disableSort: false,
      visible: true
    },
    {
      width: 120,
      label: t("use_count"),
      dataKey: "times",
      numeric: true,
      disableSort: true,
      visible: true
    },
    {
      width: 120,
      label: t("courses"),
      dataKey: "courses",
      numeric: true,
      disableSort: true,
      visible: true
    },
    {
      width: 120,
      label: t("games"),
      dataKey: "bingos",
      numeric: true,
      disableSort: true,
      visible: true
    }
  ];

  useEffect(() => {
    if (endpointStatus) {
      getConcepts();
    }
  }, [endpointStatus]);

  const setName = newName => {
    setConceptName(newName);
    setDirty(true);
  };

  const getConcepts = () => {
    dispatch(startTask("load"));
    //statusActions.startTask("load");
    axios
      .get(endpoints.baseUrl + ".json", {})
      .then(response => {
        const data = response.data;
        setConcepts(data);
        setConceptsRaw(data);
        dispatch(endTask("load"));
      })
      .catch(error => {
        console.log(error);
        return [{ id: -1, name: "no data" }];
        dispatch(endTask("load"));
      });
  };
  const filter = function(event) {
    var filtered = conceptsRaw.filter(concept =>
      concept.cap_name.includes(event.target.value.toUpperCase())
    );
    setConcepts(filtered);
  };

  const colSort = function(event) {
    let tmpArray = conceptsRaw;
    let direction = SortDirection.DESC;
    let mod = 1;
    if (event.sortBy == sortBy && direction == sortDirection) {
      direction = SortDirection.ASC;
      mod = -1;
    }
    tmpArray.sort((a, b) => {
      return mod * a[event.sortBy].localeCompare(b[event.sortBy]);
    });
    setConcepts(tmpArray);
    setSortDirection(direction);
    setSortBy(event.sortBy);
  };
  const drillDown = event => {
    setConceptId(event.rowData.id);
    setConceptName(event.rowData.name);
    setEditing(true);
    setDirty(false);
  };
  const updateConcept = (id, name) => {
    dispatch(startTask("load"));
    //statusActions.startTask("load");
    axios
      .patch(endpoints.baseUrl + "/" + id + ".json", {
        concept: {
          id: id,
          name: name
        }
      })
      .then(data => {
        const tmpConcepts = Object.assign([], conceptsRaw);
        const updatedObject = tmpConcepts.find(element => element.id == id);
        updatedObject.name = data.name;
        updatedObject.cap_name = data.name.toUpperCase();

        setConcepts(tmpConcepts);
        setConceptsRaw(tmpConcepts);
        dispatch(endTask("load"));
        //statusActions.endTask("load");
        setEditing(false);
      })
      .catch(error => {
        console.log("error:", error);
        return [{ id: -1, name: "no data" }];
      });
  };
  return (
    <React.Fragment>
      <Paper style={{ height: 450, width: "100%" }}>
        <Toolbar>
          <InputBase placeholder={t("search_concepts")} onChange={filter} />
          <SearchIcon />
          <Typography variant="h6" color="inherit">
            Showing {concepts.length} of {conceptsRaw.length}
          </Typography>
        </Toolbar>
        <WrappedVirtualizedTable
          rowCount={concepts.length}
          rowGetter={({ index }) => concepts[index]}
          sort={colSort}
          sortBy={sortBy}
          sortDirection={sortDirection}
          onRowClick={drillDown}
          columns={columns}
        />
      </Paper>
      <Dialog
        open={editing}
        onClose={() => setEditing(false)}
        aria-labelledby="edit"
      >
        <WorkingIndicator identifier="saving_concept" />
        <DialogTitle> {t("edit.title")} </DialogTitle>
        <DialogContent>
          <DialogContentText>{t("concept_name")} </DialogContentText>
          <TextField
            value={conceptName}
            onChange={event => setName(event.target.value)}
          />

          <DialogActions>
            <Button variant="contained" onClick={() => setEditing(false)}>
              {t("cancel")}
            </Button>
            <Button
              variant="contained"
              onClick={() => updateConcept(conceptId, conceptName)}
              disabled={!dirty}
            >
              {t("update_con")}
            </Button>
          </DialogActions>
        </DialogContent>
      </Dialog>
    </React.Fragment>
  );
}
