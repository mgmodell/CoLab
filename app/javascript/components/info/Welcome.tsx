import React, { useEffect, useState } from "react";
import { useSpring, animated, config } from "react-spring";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import SignIn from "../SignIn";
import EmbeddedHTMLInSVG from "../infrastructure/EmbeddedHTMLInSVG";
import ResizableSVG from "../infrastructure/ResizableSVG";
import { useTypedSelector } from "../infrastructure/AppReducers";
import WhyCoLab from "./WhyCoLab";
import About from "./About";
import Research from "./Research";
import ForStudents from "./ForStudents";
import ForInstructors from "./ForInstructors";
import { useTranslation } from "react-i18next";

type Props = {
}

export default function Welcome(props: Props) {
   const category = 'intro';
   const { t } = useTranslation(category);

   const location = useLocation();
   const params = useParams();
   const navigate = useNavigate();
   const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);

   const [welcomed, setWelcomed] = useState(false);
   const [title, setTitle] = useState('');
   const [showTooltips, setShowTooltips] = useState(false);

   const height = 300;
   const width = 530;
   //const mounted = useRef(false);

   const login = params['*'] === 'login' ?
      (
         <EmbeddedHTMLInSVG
            width={`${width * 4 / 5}rem`}
            height={`${height}rem`}
            x={-70}
            y={0}
         >
            <SignIn />
         </EmbeddedHTMLInSVG>

      ) : null;



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

   const [tooltipRStyles, tooltipRApi] = useSpring(() => ({
      transform: 'translate(0, 0)'
   }))

   const [tooltipStyles, tooltipApi] = useSpring(() => ({
      x: 0,
      y: 0,
      scale: 1,
      config: {
         precision: 0.0001,
         ...config.gentle
      }
   }));

   const [titleStyles, titleApi] = useSpring(() => ({
      opacity: 0,
      config: {
         ...config.gentle
      }
   }))

   const tooltipLook = {
      welcome: {
         opacity: 100,
         x: 0,
         y: 0,
         scale: 1,
         /*
         rotate: 0,
         */

      },
      login: {
         opacity: 0,
         x: 370,
         y: 0,
         scale: 0.8125,
         /*
         rotate: 55,
         */
      },
      student: {
         opacity: 0,
         x: 370,
         y: 0,
         scale: 0.8125,
      },
      instructor: {
         opacity: 0,
         x: 370,
         y: 0,
         scale: 0.8125,
      },
      why: {
         opacity: 0,
         x: 370,
         y: 0,
         scale: 0.8125,
      },
      research: {
         opacity: 0,
         x: 370,
         y: 0,
         scale: 0.8125,
      },
      about: {
         opacity: 0,
         x: 370,
         y: 0,
         scale: 0.8125,

      }
   }

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
      },
      why: {
         x: 535,
         y: 45,
         scale: 0.07,
         rotate: 135,
      },
      research: {
         x: 90,
         y: 80,
         scale: 0.11,
         rotate: 430,
      },
      student: {
         x: 13,
         y: 35,
         scale: 0.10,
         rotate: 325,
      },
      instructor: {
         x: 85,
         y: 245,
         scale: 0.08,
         rotate: 510,
      },
      about: {
         x: 405,
         y: 95,
         scale: 0.10,
         rotate: 685,
      },

   }
   const titleLook = {
      welcome: {
         opacity: 100

      },
      other: {
         opacity: 0

      }
   }

   const animateToScene = (sceneName: string) => {
      const animateSceneName = '' === sceneName ? 'welcome' : sceneName;

      switch (animateSceneName) {
         case 'welcome':
         case 'login':
            setTitle('');
            break;
         case 'student':
            setTitle(t(`titles.${animateSceneName}`));
            break;
         case 'instructor':
            setTitle(t(`titles.${animateSceneName}`));
            break;
         case 'why':
            setTitle(t(`titles.${animateSceneName}`));
            break;
         case 'research':
            setTitle(t(`titles.${animateSceneName}`));
            break;
         case 'about':
            setTitle(t(`titles.${animateSceneName}`));
            break;
         default:
            setTitle(`${sceneName} was not found`)

      }
      const localShowTooltips = 'welcome' === animateSceneName;
      setShowTooltips( localShowTooltips );

      tooltipApi.start({
         to: tooltipLook[animateSceneName]
      })
      titleApi.start({
         to: titleLook[localShowTooltips ? 'welcome' : 'other']
      })
      logoApi.start({
         to: logoLook[animateSceneName]
      })

   }
   const goToScene = (sceneName: string) => {

      if ('welcome' !== sceneName && `/${sceneName}` !== location.pathname) {

         setWelcomed(true);
         animateToScene(sceneName.length > 0 ? sceneName : 'welcome');
         navigate(sceneName);

      } else if ('welcome' === sceneName) {
         // If there's no change in the path, we only care
         // if the request is for '/' (i.e. 'welcome')
         if (welcomed && '/welcome' === location.pathname) {
            animateToScene('login');
            setWelcomed(true);
            navigate('/welcome/login',
               {
                  relative: 'path',
                  state: {
                     from: location.state?.from,
                  }
               });
         } else if ('' !== params['*']) {
            animateToScene('welcome');
            setWelcomed(true);
            navigate('/welcome',
               {
                  relative: 'route'
               });

         } else if (!welcomed || '/welcome/login' === location.pathname) {
            animateToScene('welcome');
            setWelcomed(true);
            navigate('/welcome', {
               relative: 'route',
               state: {
                  from: location.state?.from
               }
            });

         }

      } else if (sceneName.length > 0) {
         if (!isLoggedIn || 'login' !== sceneName) {
            navigate(sceneName, {
               replace: true
            })
         } else {
            navigate('/home', {
               replace: true
            })
         }
      }

   }

   useEffect(() => {
      const handleBrowserNav = (e: PopStateEvent) => {
         const winLoc = window.location;
         const scenePath = winLoc.pathname.split('/').filter((s: string) => s.length > 0)  ;

         if (scenePath.length < 3) {
            animateToScene(scenePath[scenePath.length - 1]);
         }
      }
      window.addEventListener('popstate', handleBrowserNav);

      const sceneName = params['*'];

      animateToScene(sceneName);
      setWelcomed(true);
      navigate(`${sceneName}${location.hash}`, {
         relative: 'path',
         replace: true,
         state: {
            from: location.state?.from,
         }
      });
      return () => {
         window.removeEventListener('popstate', handleBrowserNav);
      }
   }, [])


   return (

      <ResizableSVG
         id='welcome'
         height={height}
         width={width}
      >
         {'why' === params['*'] ?
            <WhyCoLab height={295} width={494} />
            : null
         }
         {'about' === params['*'] ?
            <EmbeddedHTMLInSVG
               height={250}
               width={444}
            >
               <About />
            </EmbeddedHTMLInSVG>
            : null
         }
         {'research' === params['*'] ?
            <EmbeddedHTMLInSVG
               height={250}
               width={444}
            >
               <Research />
            </EmbeddedHTMLInSVG>
            : null
         }
         {'instructor' === params['*'] ?
            <EmbeddedHTMLInSVG
               height={250}
               width={444}
            >
               <ForInstructors />
            </EmbeddedHTMLInSVG>
            : null
         }
         {'student' === params['*'] ?
            <EmbeddedHTMLInSVG
               height={250}
               width={444}
            >
               <ForStudents />
            </EmbeddedHTMLInSVG>
            : null
         }
         <text
            x="90"
            y="20"
            id="title"
            style={{
               fontWeight: "normal",
               fontSize: '18',
               lineHeight: 1,
               fontFamily: 'sans-serif',
               strokeWidth: .2,
               fill: 'azure',
               stroke: 'midnightblue',

            }}>
            {title}
         </text>
         <animated.g
            id="title_text"
            className='intro-text'
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
               style={{
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
               style={{
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
               style={{
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
               style={{
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
         {
            // Login module insertion point
            login
         }
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
               className="intro_nav"
               onClick={() =>
                  goToScene('welcome') // To Welcome
               }
            >
               {
                  !showTooltips ? (
                     <title>{t('tooltips.welcome')}</title>
                  ) : null
               }
            </circle>
            <g
               id="teammates"
               strokeWidth="20">
               <circle
                  id="green"
                  cx="124"
                  cy="135"
                  r="82"
                  className="intro-nav"
                  fill="#00ff00"
                  className="intro_nav"
                  onClick={() => {
                     goToScene('about');
                  }}
               >
                  {
                     !showTooltips ? (
                        <title>{t('tooltips.about')}</title>
                     ) : null
                  }
               </circle>
               <circle
                  id="red"
                  cx="568"
                  cy="134"
                  r="80"
                  className="intro-nav"
                  fill="#ff2a2a"
                  className="intro_nav"
                  onClick={() => {
                     goToScene('research');
                  }}
               >
                  {
                     !showTooltips ? (
                        <title>{t('tooltips.research')}</title>
                     ) : null
                  }
               </circle>
               <circle
                  id="yellow"
                  cx="790"
                  cy="530"
                  r="85"
                  className="intro-nav"
                  fill="#ffff00"
                  className="intro_nav"
                  onClick={() => {
                     goToScene('why');
                  }}
               >
                  {
                     !showTooltips ? (
                        <title>{t('tooltips.why')}</title>
                     ) : null
                  }
               </circle>
               <circle
                  id="orange"
                  cx="610"
                  cy="790"
                  r="81"
                  className="intro-nav"
                  fill="#ff6600"
                  className="intro_nav"
                  onClick={() => {
                     goToScene('student');
                  }}
               >
                  {
                     !showTooltips ? (
                        <title>{t('tooltips.student')}</title>
                     ) : null
                  }
               </circle>
               <circle
                  id="purple"
                  cx="120"
                  cy="710"
                  r="80"
                  className="intro-nav"
                  fill="#ff00ff"
                  className="intro_nav"
                  onClick={() =>
                     goToScene('instructor')
                  }
               >
                  {
                     !showTooltips ? (
                        <title>{t('tooltips.instructor')}</title>
                     ) : null
                  }
               </circle>
            </g>
         </animated.g>
         <animated.g
            id='tooltips'
            className='intro-text'
            style={{
               fontWeight: 'bold',
               fontSize: '11',
               fontFamily: 'sans-serif',
               fill: 'azure',
               strokeWidth: .5,
               stroke: 'midnightblue',
               ...tooltipStyles
            }}
         >
            <text
               x="145"
               y="156"
               id="welcome_txt"
               onClick={() => goToScene('welcome')} // To Welcome
               style={{
                  fontSize: '20',
                  fill: 'midnightblue',
                  //strokeWidth: .2,
                  stroke: 'azure',
                  ...tooltipRStyles,
               }}
            >
               {t('tooltips.welcome')}
            </text>
            <text
               x="130"
               y="45"
               id="why_txt"
               onClick={() => {
                  goToScene('about');
               }}
               style={{
                  stroke: "azure",
                  fill: 'midnightblue',
                  ...tooltipRStyles
               }}
            >
               {t('tooltips.why')}
            </text>

            <animated.g
               style={{
                  ...tooltipRStyles
               }}
            >
               <text
                  x="255"
                  y="75"
                  id="student_txt"
                  onClick={() => {
                     goToScene('student');
                  }}
                  style={{
                     ...tooltipRStyles
                  }}
               >
                  {t('tooltips.student')}
               </text>
            </animated.g>
            <text
               x="245"
               y="225"
               id="instructor_txt"
               onClick={() => {
                  goToScene('instructor');
               }}
               style={{
                  ...tooltipRStyles
               }}
            >
               {t('tooltips.instructor')}
            </text>
            <text
               x="80"
               y="270"
               id="about_txt"
               onClick={() => {
                  goToScene('about');
               }}
               style={{
                  stroke: "azure",
                  fill: 'black',
                  ...tooltipRStyles
               }}
            >
               {t('tooltips.about')}
            </text>
            <text
               x="45"
               y="130"
               id="research_txt"
               onClick={() => {
                  goToScene('research');
               }}
               style={{
                  ...tooltipRStyles,
               }}
            >
               Research
            </text>
         </animated.g>
         <g
            style={{
               transform: 'translate( 10 150 )',
            }}
         >
         </g>
      </ResizableSVG>
   );

}
