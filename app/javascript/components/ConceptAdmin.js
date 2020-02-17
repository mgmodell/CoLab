import React, {useState, useEffect} from "react"
const [endpoints, endpointsActions] = useEndpointStore();

import PropTypes from "prop-types"

export default function ConceptAdmin(props){
  const endpointSet = 'concept'
  const [endpoints, setEndpoints] = useState({})
  const [loaded, setLoaded] = useState( false );

  useEffect(() => {
    if (endpoints.endpointStatus[endpointSet] != 'loaded') {
      endpointsActions.fetch( endpointSet, props.getEndpointsUrl, props.token);
    }
  }, []);


    return (
      <React.Fragment>
        Token: {this.props.token}
        Get End Points Url: {this.props.getEndPointsUrl}
      </React.Fragment>
    );
}

ConceptAdmin.propTypes = {
  token: PropTypes.string.isRequired,
  getEndPointsUrl: PropTypes.string.isRequired,
  conceptUrl: PropTypes.string.isRequired,
  conceptId: PropTypes.number
};
