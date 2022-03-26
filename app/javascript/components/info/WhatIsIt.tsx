import React, { useRef } from "react";

import {Parallax, ParallaxLayer} from '@react-spring/parallax';
import {useSpring, animated} from 'react-spring';
import Logo from "../Logo";
import NormallyFunctioningGroup from "../svgs/NormallyFunctioningGroup";
import SocialLoafing from "../svgs/SocialLoafing";
/*
 * 
 * https://www.privacypolicygenerator.info/
 */
export default function WhatIsIt(props) {
  const ref = useRef( );
  return (
    <Parallax pages={3} ref={ref}>

      <ParallaxLayer sticky={{start: 0, end: 1}} speed={1.25} >
        <div style={{
          height: '100%',
          width: '95%',
          position: 'relative'
        }}>
        <div style={{
          position: 'relative',
          msTransform: 'translate(45%,50%)',
          transform: 'translate(45%,50%)'
        }} >
          <Logo height={200} width={200} />
        </div>
        </div>
      </ParallaxLayer>

      <ParallaxLayer  speed={1.25} >
        <div style={{
          height: '100%',
          width: '95%',
          position: 'relative'
        }}>
        <div style={{
          position: 'relative',
          msTransform: 'translate(15%,20%)',
          transform: 'translate(15%,20%)'
        }} >
          <SocialLoafing height={225} width={350} />
        </div>
        <div style={{
          position: 'relative',
          msTransform: 'translate(65%,40%)',
          transform: 'translate(65%,40%)'
        }} >
          <NormallyFunctioningGroup height={225} width={350} />
        </div>
        </div>
      </ParallaxLayer>
      
    </Parallax>
  );
}
