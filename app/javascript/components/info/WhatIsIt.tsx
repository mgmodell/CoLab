import React, { useRef } from "react";

import {Parallax, ParallaxLayer} from '@react-spring/parallax';
import {useSpring, animated} from 'react-spring';
import Logo from "../Logo";
import NormallyFunctioningGroup from "../svgs/NormallyFunctioningGroup";
import SocialLoafing from "../svgs/SocialLoafing";
import GroupDomination from "../svgs/GroupDomination";
import StudentConcern from "../svgs/StudentConcern";
import DivisionOfLabor from "../svgs/DivisionOfLabor";
import LeaveItToGeorge from "../svgs/LeaveItToGeorge";
import GroupThink from "../svgs/GroupThink";
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
          msTransform: 'translate(55%,45%)',
          transform: 'translate(55%,45%)'
        }} >
          <LeaveItToGeorge height={225} width={350} />
        </div>
        <div style={{
          position: 'relative',
          msTransform: 'translate(25%,45%)',
          transform: 'translate(25%,45%)'
        }} >
          <GroupThink height={225} width={350} />
        </div>
        <div style={{
          position: 'relative',
          msTransform: 'translate(55%,45%)',
          transform: 'translate(55%,45%)'
        }} >
          <DivisionOfLabor height={225} width={350} />
        </div>
        <div style={{
          position: 'relative',
          msTransform: 'translate(15%,20%)',
          transform: 'translate(15%,20%)'
        }} >
          <SocialLoafing height={225} width={350} />
        </div>
        <div style={{
          position: 'relative',
          msTransform: 'translate(15%,60%)',
          transform: 'translate(15%,60%)'
        }} >
          <GroupDomination height={225} width={350} />
        </div>
        <div style={{
          position: 'relative',
          msTransform: 'translate(55%,45%)',
          transform: 'translate(55%,45%)'
        }} >
          <StudentConcern height={225} width={350} />
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
