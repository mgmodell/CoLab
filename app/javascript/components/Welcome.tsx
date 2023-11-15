import React, { useEffect, useState, useRef } from "react";
import { useSpring, animated, config } from "react-spring";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import SignIn from "./SignIn";
import EmbeddedHTMLInSVG from "./infrastructure/EmbeddedHTMLInSVG";
import ResizableSVG from "./infrastructure/ResizableSVG";
import { useTypedSelector } from "./infrastructure/AppReducers";

type Props = {
}

export default function Welcome(props: Props) {
  const location = useLocation( );
  const params = useParams( );
  const navigate = useNavigate( );
  const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn );

  const [welcomed, setWelcomed] = useState( false );

  const height = 300;
  const width = 500;
  //const mounted = useRef(false);

  const login = params['*'] === 'login' ?
  (
    <animated.g>
      <EmbeddedHTMLInSVG width={`${width / 2}`} height={`${height}`}>
           <SignIn />
      </EmbeddedHTMLInSVG>
    </animated.g>

  ) : null;


  //const viewBox = [0, 0, 1024, 768].join(" ");

  const [logoStyles, logoApi] = useSpring(() => ({
   x: 0,
   y: 0,
   scale: 1,
   rotate: 0,
   config: {
      precision: 0.0001,
      ...config.gentle
   }
  }));

  const [titleStyles, titleApi] = useSpring(() =>({

   opacity: 0,
   config: {
      ...config.gentle
   }
  }))


  const logoLook = {
   welcome: {
      x: 79,
      y: 320,
      scale: 0.32,
      rotate: 255,

   },
   login: {
      x: 200,
      y: 180,
      scale: 0.26,
      rotate: 670,

   }
  }
  const titleLook = {
   welcome: {
      opacity: 100

   },
   other: {
      opacity: 0

   }
  }

  const animateToScene = ( sceneName:string) =>{

      logoApi.start({
         to: logoLook[sceneName]
      })
      titleApi.start({
         to: titleLook['welcome' === sceneName ? 'welcome' : 'other' ]
      })

  }
  const goToScene = (sceneName: string) =>{


   if( `/${sceneName}` !== location.pathname){

      setWelcomed( true );
      animateToScene( sceneName.length > 0 ? sceneName : 'welcome' );
      navigate( sceneName );

   } else if( '' === sceneName ){
      // If there's no change in the path, we only care
      // if the request is for '/' (i.e. 'welcome')
      if( welcomed && '/' === location.pathname){
         animateToScene( 'login' );
         setWelcomed( true );
         navigate( '/login',
         {
            relative: 'route'
         } );
      }else if( !welcomed || '/login' === location.pathname ){
         animateToScene( 'welcome' );
         setWelcomed( true );
         navigate( '/', {
            relative: 'route',
         });

      }

   } else if( sceneName.length > 0 ){
      if( !isLoggedIn || 'login' !== sceneName ){
        navigate( sceneName, {
           replace: true
        })
      } else {
         navigate( '/home', {
            replace: true
         })
      }
   }

  }



  useEffect( () =>{
   const sceneName = '' === params[ '*' ] ? 'welcome' : params['*'];
   animateToScene( sceneName );
   setWelcomed( true );
   navigate( sceneName, {
      replace: true,
   } );
  },[])


  return (
   <ResizableSVG
      id='welcome'
      height={height}
      width={width}
   >
  <animated.g
     id="title_text"
     style={{
         x: 0,

         strokeWidth: .125,
          fill: 'white',
          stroke: 'black',
          scale: 1,
          ...titleStyles
     }}>
    <text
         x="64"
         y="31"
       id="improving"
       style={ {
          fontWeight: "normal",
          fontSize: '42',
          lineHeight: 1,
          whiteSpace: 'pre',
          fontFamily: 'sans-serif',

        }}>
         Impr     ving
    </text>
    <text
         x="23"
         y="181"
       id="colab"
       style={ {
          fontWeight: "normal",
          fontSize: '128',
          lineHeight: 1.45,
          fontFamily: 'sans-serif',
          whiteSpace: 'pre',
          fill: 'black',
          stroke: 'white',
        }}>
         C    LAB
    </text>
    <text
         x="315"
         y="240"
       id="oration"
       style={ {
          fontWeight: "normal",
          fontSize: '50',
          lineHeight: 1.25,
          fontFamily: 'sans-serif',
          fill: 'black',
          stroke: 'white',
        }}>
         RATION
    </text>
    <text
         x="142"
         y="285"
       id="one_team"
       style={ {
          fontWeight: "normal",
          fontSize: '42',
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
       style={{
         ...logoStyles
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
         fill="#00ffff"
         onClick={() =>
            goToScene( '' ) // To Welcome
         }
         />
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
           fill="#ffff00" 
           onClick={()=>{
            goToScene( 'why' );
           }}
           />
        <circle
           id="orange"
           cx="610"
           cy="790"
           r="81"
           fill="#ff6600"
           onClick={()=>{
            goToScene( 'student' );
           }}
           />
        <circle
           id="purple"
           cx="120"
           cy="710"
           r="80"
           fill="#ff00ff"
           onClick={()=>
            goToScene( 'instructor' )
           }
           />
      </g>
    </animated.g>
    <animated.g
         id='tooltips'
         style={{
          fontWeight: 'bold',
          fontSize: '11',
          fontFamily: 'sans-serif',
          fill: 'azure',
          strokeWidth: .5,
          stroke: 'midnightblue',
         }}
    >
      <text
         x="145"
         y="156"
       id="welcome_txt"
       onClick={()=> goToScene( '/' )} // To Welcome
       style={ {
          fontSize: '20',
          fill: 'midnightblue',
          //strokeWidth: .2,
          stroke: 'azure',
       }}
      >
         Welcome
      </text>
      <text
         x="130"
         y="45"
       id="why_txt"
       style={ {
         stroke: "azure",
         fill: 'midnightblue'
       }}
      >
         Why CoLab?
      </text>
      <text
         x="255"
         y="65"
       id="student_txt"
       style={ {
       }}
      >
         Student?
      </text>
      <text
         x="245"
         y="225"
       id="instructor_txt"
       style={ {
       }}
      >
         Instructor?
      </text>
      <text
         x="80"
         y="270"
       id="about_txt"
       style={ {
         stroke: "azure",
         fill: 'black'
       }}
      >
         About
      </text>
      <text
         x="45"
         y="130"
       id="research_txt"
       style={ {
       }}
      >
         Research
      </text>
    </animated.g>
   </ResizableSVG>
  );

}
