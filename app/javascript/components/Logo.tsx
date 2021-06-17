import React, {useState} from 'react';
import PropTypes from 'prop-types';
import SelectInput from '@material-ui/core/Select/SelectInput';

export default function Logo(props){

const height = props.height || 72;
const width = props.width || 72;

const viewBox = [0, 0, 1000, 1000].join(' ')

const [colors, setColors] = useState(
  ['#00FF00', '#FF2A2A', '#FFFF00', '#FF6600', '#FF00FF' ]);
const [green, setGreen] = useState( colors[ 0 ] );

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function rotateColors() {
  for(let index = 0; index < 15; index++ ){
    colors.push( colors.shift( ) );
    setColors( colors );
    setGreen( colors[ 0 ] );
    await sleep( Math.log( index, 1000 ) * 100 )

  }
}

return(
<svg height={height} width={width} onClick={rotateColors}
  viewBox={viewBox} preserveAspectRatio="xMidYMid meet"
  xmlns="http://www.w3.org/2000/svg">
  <linearGradient id="bg_grad" x1="-5" y1="493" x2="975" y2="493"
  gradientUnits="userSpaceOnUse" >>
    <stop offset="0" stopColor="#ffffff" stopOpacity="0%"/>
    <stop offset="1" stopColor="#c8c8c8" stopOpacity="100%"/>
  </linearGradient>
  <circle id="background" cx="485" cy="493" r="490" fill="url('#bg_grad')" />
  <g id="circles" stroke="black" strokeWidth="30">
    <line x1="450" y1="455" x2="124" y2="135"/>
    <line x1="450" y1="455" x2="568" y2="134"/>
    <line x1="450" y1="455" x2="790" y2="530"/>
    <line x1="450" y1="455" x2="610" y2="790"/>
    <line x1="450" y1="455" x2="120" y2="710"/>
    <circle id="desk" cx="450" cy="455" r="160" fill="#00FFFF"/>
    <g id="teammates" strokeWidth="20">
      <circle id="green" cx="124" cy="135" r="82" fill={green} />
      <circle id="red" cx="568" cy="134" r="80" fill={colors[1]} />
      <circle id="yellow" cx="790" cy="530" r="85" fill={colors[2]}/>
      <circle id="orange" cx="610" cy="790" r="81" fill={colors[3]}/>
      <circle id="purple" cx="120" cy="710" r="80" fill={colors[4]}/>
    </g>
  </g>

</svg>)

Logo.propTypes = {
  height: PropTypes.number,
  width: PropTypes.number
};}
