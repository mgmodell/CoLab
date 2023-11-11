import React, { useEffect, useState, useRef } from "react";
import { useSpring, animated, config } from "react-spring";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import SignIn from "./SignIn";
import EmbeddedHTMLInSVG from "./infrastructure/EmbeddedHTMLInSVG";
import ResizableSVG from "./infrastructure/ResizableSVG";

type Props = {
}

export default function Welcome(props: Props) {
  const location = useLocation( );
  const params = useParams( );
  const navigate = useNavigate( );

  //const mounted = useRef(false);
  console.log( location, params );

  const login = params['*'] === 'login' ?
  (
    <animated.g>
      <EmbeddedHTMLInSVG width={'50%'} height={'100%'}>
           <SignIn />
      </EmbeddedHTMLInSVG>
    </animated.g>

  ) : null;


  //const viewBox = [0, 0, 1024, 768].join(" ");

  const [styles, api] = useSpring(() => ({
   x: 0,
   y: 0,
   scale: 1,
   rotate: 0,
   config: {
      precision: 0.0001,
      ...config.molasses
   }
  }));

  const logo_look = {
   welcome: {
      x: 41,
      y: 132,
      scale: 0.125,
      rotate: 255,

   },
   login: {
      x: 41,
      y: 132,
      scale: 0.125,
      rotate: 255,

   }
  }

  const toWelcome = () =>{
   api.start({
      to:{
         x: 41,
         y: 132,
         scale: 0.125,
         rotate: 255,
      }
   })
  }

  const toLogin = () =>{
   navigate('login');
   api.start({
      to:{
         x: 140,
         y: 140,
         scale: 0.08,
         rotate: 615,
      }
   })
  }

  useEffect( () =>{
   toWelcome( );
  },[])


  return (
   <ResizableSVG
      id='welcome'
      height={300}
      width={400}
   >
  <animated.g
     id="title_text"
     style={{
         strokeWidth: .125,
          fill: 'white',
          stroke: 'black',
          scale: 3
     }}>
    <text
         x="29"
         y="21"
       id="improving"
       style={ {
          fontWeight: "normal",
          fontSize: '22',
          lineHeight: 1,
          whiteSpace: 'pre',
          fontFamily: 'sans-serif',

        }}>
         Impr        ving
    </text>
    <text
         x="20"
         y="79"
       id="colab"
       style={ {
          fontWeight: "normal",
          fontSize: '50',
          lineHeight: 1.45,
          fontFamily: 'sans-serif',
          whiteSpace: 'pre',
          fill: 'black',
          stroke: 'white',
        }}>
         C    LAB
    </text>
    <text
         x="133"
         y="101"
       id="oration"
       style={ {
          fontWeight: "normal",
          fontSize: '18',
          lineHeight: 1.25,
          fontFamily: 'sans-serif',
          fill: 'black',
          stroke: 'white',
        }}>
         RATION
    </text>
    <text
         x="65"
         y="117"
       id="one_team"
       style={ {
          fontWeight: "normal",
          fontSize: '12',
          lineHeight: 1.25,
          fontFamily: 'sans-serif',

        }}>
         ne team at a time
    </text>
    </animated.g>
    {


    }
    {login}

    <animated.g
       id="circles"
       stroke="#000000"
       strokeWidth="30"
       transform="
        translate(41,132)
        rotate( 255 )
        scale(.125)"
       style={{
         ...styles
       }}
       >
      <line
         x1="450"
         y1="455"
         x2="124"
         y2="135"
         id="line2" />
      <line
         x1="450"
         y1="455"
         x2="568"
         y2="134"
         id="line3" />
      <line
         x1="450"
         y1="455"
         x2="790"
         y2="530"
         id="line4" />
      <line
         x1="450"
         y1="455"
         x2="610"
         y2="790"
         id="line5" />
      <line
         x1="450"
         y1="455"
         x2="120"
         y2="710"
         id="line6" />
      <circle
         id="desk"
         cx="450"
         cy="455"
         r="160"
         fill="#00ffff" />
      <g
         id="teammates"
         strokeWidth="20">
        <circle
           id="green"
           cx="124"
           cy="135"
           r="82"
           fill="#00ff00" />
        <circle
           id="red"
           cx="568"
           cy="134"
           r="80"
           fill="#ff2a2a" />
        <circle
           id="yellow"
           cx="790"
           cy="530"
           r="85"
           fill="#ffff00" />
        <circle
           id="orange"
           cx="610"
           cy="790"
           r="81"
           fill="#ff6600"
           onClick={()=>{
            toLogin( );
           }}
           />
        <circle
           id="purple"
           cx="120"
           cy="710"
           r="80"
           fill="#ff00ff"
           onClick={()=>{
            toWelcome( );
           }}
           />
      </g>
    </animated.g>
    <animated.g
         id='tooltips'
    >
      <text
         x="59"
         y="62"
       id="one_team"
       style={ {
          fontWeight: "normal",
          fontSize: '9',
          fontFamily: 'sans-serif',
          fill: 'white',
          strokeWidth: .25,
          stroke: 'black',
       }}
      >
         Welcome
      </text>
    </animated.g>
   </ResizableSVG>
  );

}
