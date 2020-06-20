import React, { Suspense, useState, useEffect } from "react";
import PropTypes from "prop-types";

import Button from "@material-ui/core/Button";
import IconButton from "@material-ui/core/IconButton";
import Paper from "@material-ui/core/Paper";
import Skeleton from "@material-ui/lab/Skeleton";
import FormControl from '@material-ui/core/FormControlLabel';
import MenuItem from '@material-ui/core/MenuItem'
import FormHelperText from '@material-ui/core/FormHelperText';
import InputLabel from '@material-ui/core/InputLabel';
import ExpansionPanel from "@material-ui/core/ExpansionPanel";
import ExpansionPanelSummary from "@material-ui/core/ExpansionPanelSummary";
import ExpansionPanelDetails from "@material-ui/core/ExpansionPanelDetails";
import ExpandMoreIcon from "@material-ui/icons/ExpandMore";
import TextField from "@material-ui/core/TextField";
import Alert from "@material-ui/lab/Alert";
import Collapse from "@material-ui/core/Collapse";
import CloseIcon from "@material-ui/icons/Close";
//For debug purposes

import { i18n } from "./infrastructure/i18n";
import { useTranslation } from "react-i18next";

import LinkedSliders from "./LinkedSliders";
import Select from "@material-ui/core/Select";

export default function ExperienceDiagnosis(props) {
  const [t, i18n] = useTranslation("experiences");
  const [behaviorId, setBehaviorId ] = useState( 0 );
  const [otherName, setOtherName] = useState( '' );
  const [comments, setComments] = useState( '' );

  const saveButton = (
    <Button variant="contained" onClick={() => props.diagnoseFunc( behaviorId, otherName, comments)}>
      <Suspense fallback={<Skeleton variant="text" />}>{t('next.save_and_continue')}</Suspense>
    </Button>
  );


  return (
    <Paper>
      <Suspense fallback={<Skeleton variant='text' />} >
        <h3>{t( 'next.journal', {week_num: props.weekNum } )}</h3>
      </Suspense>
      <Suspense fallback={<Skeleton variant='rect' />} >
            <p
              dangerouslySetInnerHTML={{
                __html: props.weekText
              }}
            />
      </Suspense>
      <Suspense fallback={<Skeleton variant='text' />} >
        <h3>{t( 'next.prompt' )}</h3>
      </Suspense>
        <InputLabel htmlFor="course_school" id="course_school_lbl">
          <h3>{t( 'next.prompt' )}</h3>
        </InputLabel>
        <Select
          id="behavior"
          value={behaviorId}
          onChange={event => {
            setBehaviorId(Number(event.target.value));
          }}
        >
          <MenuItem value={0}>None Selected</MenuItem>
          {props.behaviors.map(behavior => {
            return (
              <MenuItem key={"behavior_" + behavior.id} value={behavior.id}>
                {behavior.name}
              </MenuItem>
            );
          })}
        </Select>
      {saveButton}
    </Paper>
  );
}

ExperienceDiagnosis.propTypes = {
  diagnoseFunc: PropTypes.func.isRequired,
  behaviors: PropTypes.array.isRequired,
  weekNum: PropTypes.number.isRequired,
  weekText: PropTypes.string.isRequired

};
