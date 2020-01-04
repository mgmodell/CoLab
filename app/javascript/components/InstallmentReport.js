import React, {useState, useEffect} from "react";
import PropTypes from "prop-types";

import ExpansionPanel from '@material-ui/core/ExpansionPanel';
import ExpansionPanelSummary from '@material-ui/core/ExpansionPanelSummary';
import ExpansionPanelDetails from '@material-ui/core/ExpansionPanelDetails';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';

import LinkedSliders from './LinkedSliders';
export default function InstallmentReport(props){
  
  const [dirty, setDirty] = useState( false );
  const [curPanel, setCurPanel] = useState( 0 );
  const [contributions, setContributions] = useState({
        1: [
          {id: 1, name: 'bob 1', value: 1500 },
          {id: 2, name: 'bob 2', value: 1500 },
          {id: 3, name: 'bob 3', value: 1500 },
          {id: 4, name: 'bob 4', value: 1500 }
          ],
        2: 
          [
          {id: 1, name: 'bob 1', value: 1500 },
          {id: 2, name: 'bob 2', value: 2000 },
          {id: 3, name: 'bob 3', value: 1000 },
          {id: 4, name: 'bob 4', value: 1500 }
          ]
        });
    
    const updateSlice = (id, update) =>{
      const lContributions = Object.assign( {}, contributions);

      lContributions[ id ] = update;

      setContributions( lContributions );
      setDirty( true );
    }

    return (
      Object.keys( contributions ).map( (sliceId)=> {
      return(
      <ExpansionPanel
        expanded={sliceId == curPanel}
        onChange={()=>setCurPanel( sliceId )}
        key={sliceId}>
        <ExpansionPanelSummary 
          expandIcon={<ExpandMoreIcon />}
          id={sliceId}>
        {sliceId} ({dirty ? 'dirty' : 'clean' } )
        </ExpansionPanelSummary>
        <ExpansionPanelDetails>
          <LinkedSliders
            key={'f_' + sliceId}
            id={Number( sliceId )}
            sum={6000}
            updateContributors={updateSlice.bind( null, sliceId ) }
            description='definition of stuff that is cool'
            contributors={contributions[sliceId]}
          />
        </ExpansionPanelDetails>
      </ExpansionPanel>
      ) } )
    );
}

InstallmentReport.propTypes = {
  token: PropTypes.string.isRequired,
  getInstallmentUrl: PropTypes.string.isRequired,
  setInstallmentUrl: PropTypes.string.isRequired
};
