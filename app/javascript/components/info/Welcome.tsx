import React, { useEffect, useState, useRef } from "react";
// CHANGED by Claude Sonnet 4: Updated React Spring import for v10.0.3 compatibility
// Previous: import { useSpring, animated, config } from "react-spring";
// Fixed: Import from @react-spring/web for modular v10 architecture
import { useSpring, animated, config } from "@react-spring/web";
import { useLocation, useNavigate, useParams } from "react-router";

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

   // ADDED by Claude Sonnet 4: Centralized animation configuration for easy modification
   // This allows changing all animation timings from one location
   // Available options: config.gentle, config.wobbly, config.stiff, config.slow
   const ANIMATION_CONFIG = config.gentle;

   const location = useLocation();
   const params = useParams();
   const navigate = useNavigate();
   const isLoggedIn = useTypedSelector(state => state.context.status.loggedIn);

   const [welcomed, setWelcomed] = useState(false);
   const [title, setTitle] = useState('');
   const [showTooltips, setShowTooltips] = useState(false);
   // ADDED by Claude Sonnet 4: Scene tracking to prevent hash fragment interference
   // Prevents WhyCoLab.tsx hash changes from re-triggering Welcome animations
   // Initial value '__INITIAL__' ensures first animation always runs
   const currentSceneRef = useRef('__INITIAL__');

   const height = 300;
   const width = 530;
   //const mounted = useRef(false);

   const login = (params['*'] || '').startsWith( 'login' ) ?
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



   // CHANGED by Claude Sonnet 4: React Spring v10 - State-based reactive animations
   // Previous v9 approach used imperative API: const [spring, api] = useSpring(); api.start()
   // New v10 approach uses reactive state: useState + useSpring with state spreading
   const [logoTarget, setLogoTarget] = useState({
      // CHANGED by Claude Sonnet 4: Start from neutral position for dramatic entrance animation
      // Previous: Started at welcome position { x: 79, y: 320, scale: 0.32, rotate: 255 }
      x: 0,
      y: 0, 
      scale: 1,
      rotate: 0,
   });

   // CHANGED by Claude Sonnet 4: React Spring v10 reactive spring configuration
   // Replaced imperative API with state-based approach
   const logoStyles = useSpring({
      ...logoTarget,
      config: {
         precision: 0.0001,
         ...ANIMATION_CONFIG  // REFACTORED by Claude Sonnet 4: Use centralized config
      }
   });

   // CHANGED by Claude Sonnet 4: React Spring v10 - Tooltip animations converted to state-based
   const [tooltipTarget, setTooltipTarget] = useState({
      x: 0,
      y: 0,
      scale: 1,
      opacity: 1,
   });

   const tooltipStyles = useSpring({
      ...tooltipTarget,
      config: {
         precision: 0.0001,
         ...ANIMATION_CONFIG  // REFACTORED by Claude Sonnet 4: Use centralized config
      }
   });

   // CHANGED by Claude Sonnet 4: React Spring v10 - Title animations converted to state-based
   const [titleTarget, setTitleTarget] = useState({
      opacity: 1,
   });

   const titleStyles = useSpring({
      ...titleTarget,
      config: {
         ...ANIMATION_CONFIG  // REFACTORED by Claude Sonnet 4: Use centralized config
      }
   })

   const tooltipLook = {
      welcome: {
         opacity: 1,
         x: 0,
         y: 0,
         scale: 1,
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
         opacity: 1

      },
      other: {
         opacity: 0

      }
   }

   const animateToScene = (sceneName: string) => {
      const animateSceneName = '' === sceneName ? 'welcome' : sceneName;

      // Use 'welcome' as fallback if scene doesn't exist 
      const safeSceneName = (tooltipLook[animateSceneName] && logoLook[animateSceneName]) ? animateSceneName : 'welcome';

      switch (safeSceneName) {
         case 'welcome':
         case 'login':
            setTitle('');
            break;
         case 'student':
            setTitle(t(`titles.${safeSceneName}`));
            break;
         case 'instructor':
            setTitle(t(`titles.${safeSceneName}`));
            break;
         case 'why':
            setTitle(t(`titles.${safeSceneName}`));
            break;
         case 'research':
            setTitle(t(`titles.${safeSceneName}`));
            break;
         case 'about':
            setTitle(t(`titles.${safeSceneName}`));
            break;
         default:
            setTitle(`${safeSceneName} was not found`)

      }
      const localShowTooltips = 'welcome' === safeSceneName;
      setShowTooltips( localShowTooltips );

      // CHANGED by Claude Sonnet 4: React Spring v10 - Animation triggering via state updates
      // Previous v9: Used imperative API calls (tooltipApi.start(), titleApi.start(), logoApi.start())
      // New v10: Use state setters to trigger reactive animations
      setTooltipTarget(tooltipLook[safeSceneName]);
      setTitleTarget(titleLook[localShowTooltips ? 'welcome' : 'other']);
      setLogoTarget(logoLook[safeSceneName]);
      
      // Update the scene tracker
      currentSceneRef.current = safeSceneName;

   }
   // CHANGED by Claude Sonnet 4: Improved navigation logic for React Spring v10 compatibility
   const goToScene = (sceneName: string) => {
      const currentScene = params['*'] || '';
      
      // FIXED by Claude Sonnet 4: Handle welcome/login special case properly
      // Clicking welcome when already on welcome should go to login
      if (sceneName === 'welcome' && currentScene === '' && welcomed && '/welcome' === location.pathname) {
         animateToScene('login');
         navigate('/welcome/login', {
            state: { from: location.state?.from }
         });
         return;
      }
      
      // FIXED by Claude Sonnet 4: Prevent same-scene re-animation (except welcome special case)
      // This stops unwanted animation resets when clicking the same scene
      if (currentScene === sceneName) {
         return;
      }

      // Handle normal scene navigation
      const targetScene = sceneName || 'welcome';
      animateToScene(targetScene);
      setWelcomed(true);
      
      if (targetScene === 'welcome') {
         navigate('/welcome');
      } else if (targetScene === 'login') {
         if (isLoggedIn) {
            navigate('/home');
         } else {
            navigate('/welcome/login');
         }
      } else {
         navigate(`/welcome/${targetScene}`);
      }
   }

   useEffect(() => {
      const handleBrowserNav = (e: PopStateEvent) => {
         const winLoc = window.location;
         const scenePath = winLoc.pathname.split('/').filter((s: string) => s.length > 0);

         // Handle /welcome/scene structure
         if (scenePath.length === 1 && scenePath[0] === 'welcome') {
            animateToScene('');
         } else if (scenePath.length === 2 && scenePath[0] === 'welcome') {
            animateToScene(scenePath[1]);
         }
      }
      
      window.addEventListener('popstate', handleBrowserNav);
      
      return () => {
         window.removeEventListener('popstate', handleBrowserNav);
      }
   }, []);

   // CHANGED by Claude Sonnet 4: Enhanced route change detection for React Spring v10
   // FIXED by Claude Sonnet 4: Added scene change tracking to prevent hash fragment interference
   useEffect(() => {
      const sceneName = params['*'] || '';
      
      // ADDED by Claude Sonnet 4: Only animate if scene actually changed (prevents hash-triggered re-animations)
      // This fixes the issue where WhyCoLab.tsx hash changes would reset Welcome animations
      if (currentSceneRef.current !== sceneName) {
         animateToScene(sceneName);
         currentSceneRef.current = sceneName;
      }
      setWelcomed(true);
      
      // FIXED by Claude Sonnet 4: Enhanced URL structure handling for proper routing
      // Ensures consistent /welcome/scene URL patterns
      if (location.pathname === '/' || (location.pathname === '/welcome' && sceneName === '')) {
         // Root paths should show welcome scene and navigate to /welcome
         if (location.pathname !== '/welcome') {
            navigate('/welcome', { replace: true });
         }
      } else if (sceneName && sceneName !== 'login') {
         // FIXED by Claude Sonnet 4: Absolute path navigation to prevent path appending issues
         // Previous relative navigation was causing /welcome/scene/scene paths
         const expectedPath = `/welcome/${sceneName}`;
         if (location.pathname !== expectedPath) {
            navigate(expectedPath, { 
               replace: true,
               state: { from: location.state?.from }
            });
         }
      }
      
   }, [params['*']]);


   return (

      <ResizableSVG
         id='welcome'
         height={height}
         width={width}
      >
         {'why' === (params['*'] || '') ?
            <WhyCoLab height={295} width={494} />
            : null
         }
         {'about' === (params['*'] || '') ?
            <About height={295} width={494} />
            : null
         }
         {'research' === (params['*'] || '') ?
            <EmbeddedHTMLInSVG
               height={250}
               width={444}
            >
               <Research />
            </EmbeddedHTMLInSVG>
            : null
         }
         {'instructor' === (params['*'] || '') ?
            <EmbeddedHTMLInSVG
               height={250}
               width={444}
            >
               <ForInstructors />
            </EmbeddedHTMLInSVG>
            : null
         }
         {'student' === (params['*'] || '') ?
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
                  className="intro_nav"
                  fill="#00ff00"
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
                  className="intro_nav"
                  fill="#ff2a2a"
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
                  className="intro_nav"
                  fill="#ffff00"
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
                  className="intro_nav"
                  fill="#ff6600"
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
                  className="intro_nav"
                  fill="#ff00ff"
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
                  stroke: 'azure'
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
                  fill: 'midnightblue'
               }}
            >
               {t('tooltips.why')}
            </text>

            <text
               x="255"
               y="75"
               id="student_txt"
               onClick={() => {
                  goToScene('student');
               }}
            >
               {t('tooltips.student')}
            </text>
            <text
               x="245"
               y="225"
               id="instructor_txt"
               onClick={() => {
                  goToScene('instructor');
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
                  fill: 'black'
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
            >
               {t('tooltips.research')}
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