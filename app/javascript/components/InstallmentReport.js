import React, {useState, useEffect} from "react";
import PropTypes from "prop-types";

import ExpansionPanel from '@material-ui/core/ExpansionPanel';
import ExpansionPanelSummary from '@material-ui/core/ExpansionPanelSummary';
import ExpansionPanelDetails from '@material-ui/core/ExpansionPanelDetails';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';

import LinkedSliders from './LinkedSliders';
export default function InstallmentReport(props){
  
  const [dirty, setDirty] = useState( false );
  const [messages, setMessages] = useState( { } );
  const [curPanel, setCurPanel] = useState( 0 );
  const [factors, setFactors] = useState( { } );
  const [group, setGroup] = useState( { } );
  const [project, setProject] = useState( { } );

  const [contributions, setContributions] = useState({ });
    
    const updateSlice = (id, update) =>{
      const lContributions = Object.assign( {}, contributions);
      lContributions[ id ] = update;
      setContributions( lContributions );
    }

    useEffect( () => setDirty( true ), [
      contributions
    ]);

    useEffect( ()=>getContributions(), [] );

    const getContributions = ()=>{
      fetch( props.getInstallmentUrl + '.json', {
        method: 'GET',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json',
          Accepts: 'application/json',
          'X-CSRF-Token': props.token
        }
      })
        .then(response => {
          if( response.ok ){
            setMessages( { } );
            return response.json( );
          } else {
            console.log( 'error' );
          }
        })
        .then( data => {
          setFactors( data.factors );

          //Process Contributions
          const contributions = data.installment.values.reduce(
            (valuesAccum,value)=>{
              const values = valuesAccum[ value.factor_id ] || [ ];
              values.push ({
                id: value.user_id,
                factorId: value.factor_id,
                name: data.group.users[ value.user_id ].name,
                value: value.value
              });
              valuesAccum[ value.factor_id ] = values;
              return valuesAccum;
              }, {} );
          setContributions( contributions );

          setGroup( data.group );
          setProject( data.installment.project )


        });
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
        {factors[ sliceId ].name }
        ({
          contributions[sliceId].reduce( (total, val)=>{
            return  total + val.value;

          }, 0 ) }
        </ExpansionPanelSummary>
        <ExpansionPanelDetails>
          <LinkedSliders
            key={'f_' + sliceId}
            id={Number( sliceId )}
            sum={6000}
            updateContributors={updateSlice.bind( null, sliceId ) }
            description={factors[ sliceId ].description }
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
