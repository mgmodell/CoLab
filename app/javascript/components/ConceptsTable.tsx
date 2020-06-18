/* eslint-disable no-console */
import React, { useEffect, useState } from "react";
import PropTypes from "prop-types";
import Button from "@material-ui/core/Button";
import classNames from "classnames";
import { withStyles } from "@material-ui/core/styles";
import Dialog from "@material-ui/core/Dialog";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import DialogActions from "@material-ui/core/DialogActions";
import DialogTitle from "@material-ui/core/DialogTitle";
import Paper from "@material-ui/core/Paper";
import InputBase from "@material-ui/core/InputBase";
import SearchIcon from "@material-ui/icons/Search";
import Toolbar from "@material-ui/core/Toolbar";
import TextField from "@material-ui/core/TextField";
import Typography from "@material-ui/core/Typography";
import WorkingIndicator from './infrastructure/WorkingIndicator';
import { SortDirection } from "react-virtualized";

import WrappedVirtualizedTable from "./WrappedVirtualizedTable";

import { useEndpointStore } from "./infrastructure/EndPointStore";
import { useStatusStore } from './infrastructure/StatusStore';

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
  const endpointSet = "concept";
  const [endpoints, endpointsActions] = useEndpointStore();
  const [status, statusActions] = useStatusStore( );

  const [conceptsRaw, setConceptsRaw] = useState([]);
  const [concepts, setConcepts] = useState([]);

  const [search, setSearch] = useState("");
  const [sortBy, setSortBy] = useState("name");
  const [sortDirection, setSortDirection] = useState(SortDirection.DESC);

  const [editing, setEditing] = useState(false);
  const [dirty, setDirty] = useState(false);
  const [conceptName, setConceptName] = useState("");
  const [conceptId, setConceptId] = useState(-1);

  const columns = [
    {
      width: 200,
      flexGrow: 1.0,
      label: "Name",
      dataKey: "name",
      numeric: false,
      disableSort: false,
      visible: true
    },
    {
      width: 120,
      label: "Times Suggested",
      dataKey: "times",
      numeric: true,
      disableSort: true,
      visible: true
    },
    {
      width: 120,
      label: "Course Appearances",
      dataKey: "courses",
      numeric: true,
      disableSort: true,
      visible: true
    },
    {
      width: 120,
      label: "Bingo! Appearances",
      dataKey: "bingos",
      numeric: true,
      disableSort: true,
      visible: true
    }
  ];

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != "loaded") {
      endpointsActions.fetch(endpointSet, props.getEndpointsUrl, props.token);
    }
  }, []);

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] == "loaded") {
      getConcepts();
    }
  }, [endpoints.endpointStatus[endpointSet]]);

  const setName = newName => {
    setConceptName(newName);
    setDirty(true);
  };

  const getConcepts = () => {
    statusActions.startTask( 'load' )
    fetch(endpoints.endpoints[endpointSet].baseUrl + ".json", {
      method: "GET",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      }
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return [{ id: -1, name: "no data" }];
        }
      })
      .then(data => {
        setConcepts(data);
        setConceptsRaw(data);
        statusActions.endTask( 'load' )
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
    statusActions.startTask( 'load' );
    fetch(endpoints.endpoints[endpointSet].baseUrl + "/" + id + ".json", {
      method: "PATCH",
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
        Accepts: "application/json",
        "X-CSRF-Token": props.token
      },
      body: JSON.stringify({
        concept: {
          id: id,
          name: name
        }
      })
    })
      .then(response => {
        if (response.ok) {
          return response.json();
        } else {
          console.log("error");
          return [{ id: -1, name: "no data" }];
        }
      })
      .then(data => {
        const tmpConcepts = Object.assign([], conceptsRaw);
        const updatedObject = tmpConcepts.find(element => element.id == id);
        updatedObject.name = data.name;
        updatedObject.cap_name = data.name.toUpperCase();

        setConcepts(tmpConcepts);
        setConceptsRaw(tmpConcepts);
        statusActions.endTask( 'load' );
        setEditing(false);
      });
  };
  return (
    <React.Fragment>
      <Paper style={{ height: 450, width: "100%" }}>
        <Toolbar>
          <InputBase placeholder="Search concepts" onChange={filter} />
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
        <WorkingIndicator identifier='saving_concept' />
        <DialogTitle>Edit Concept</DialogTitle>
        <DialogContent>
          <DialogContentText>Concept Name</DialogContentText>
          <TextField
            value={conceptName}
            onChange={event => setName(event.target.value)}
          />

          <DialogActions>
            <Button variant="contained" onClick={() => setEditing(false)}>
              Cancel
            </Button>
            <Button
              variant="contained"
              onClick={() => updateConcept(conceptId, conceptName)}
              disabled={!dirty}
            >
              Update Concept
            </Button>
          </DialogActions>
        </DialogContent>
      </Dialog>
    </React.Fragment>
  );
}
ConceptsTable.propTypes = {
  token: PropTypes.string.isRequired,
  getEndpointsUrl: PropTypes.string.isRequired
};
