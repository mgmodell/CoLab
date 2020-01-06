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
  const [factors, setFactors] = useState( {
    1: {
        name: 'hello',
        description: 'this is gonna\' rock!'
       },
    2: {
        name: 'there',
        description: 'this is not gonna\' rock!'
       }
    } );

  const [contributions, setContributions] = useState({
        1: {
            factorId: 1,
            values: [
          {id: 1, name: 'bob 1', value: 1500 },
          {id: 2, name: 'bob 2', value: 1500 },
          {id: 3, name: 'bob 3', value: 1500 },
          {id: 4, name: 'bob 4', value: 1500 }
          ] },
        2: {
            factorId: 2,
            values: [
          {id: 1, name: 'bob 1', value: 1500 },
          {id: 2, name: 'bob 2', value: 2000 },
          {id: 3, name: 'bob 3', value: 1000 },
          {id: 4, name: 'bob 4', value: 1500 }
          ] }
        });
    
    const updateSlice = (id, update) =>{
      const lContributions = Object.assign( {}, contributions);
      lContributions[ id ].values = update;
      setContributions( lContributions );
    }

    useEffect( () => setDirty( true ), [
      contributions
    ]);

    useEffect( ()=>getContributions(), [] );

    const getContributions = ()=>{
      console.log( 'get that data!' );
    }

    const setPanel = ( panelId )=>{
      //If the panel is already selected...
      if( panelId == curPanel ){
        //...close it.
        setCurPanel( '' );
      //Otherwise...
      } else {
        //...open it
        setCurPanel( panelId );
      }
    }

    return (
      Object.keys( contributions ).map( (sliceId)=> {
      return(
      <ExpansionPanel
        expanded={sliceId == curPanel}
        onChange={()=>setPanel( sliceId )}
        key={sliceId}>
        <ExpansionPanelSummary 
          expandIcon={<ExpandMoreIcon />}
          id={sliceId}>
        {factors[ contributions[ sliceId ].factorId ].name }
        ({
          contributions[sliceId].values.reduce( (total, val)=>{
            return  total + val.value;

          }, 0 ) }
        </ExpansionPanelSummary>
        <ExpansionPanelDetails>
          <LinkedSliders
            key={'f_' + sliceId}
            id={Number( sliceId )}
            sum={6000}
            updateContributors={updateSlice.bind( null, sliceId ) }
            description={factors[ contributions[ sliceId ].factorId ].description }
            contributors={contributions[sliceId].values}
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
