import React, { ReactNode, createContext, useContext } from 'react';
import { SvgContext } from './ResizableSVG';
import { SpringValue, animated } from 'react-spring';

interface EmbeddedHTMLInSVGProps {
  children: ReactNode;
  width: string | SpringValue<number>;
  height: string | SpringValue<number>;
  x?: string | SpringValue<number>;
  y?: string | SpringValue<number>;
}


const EmbeddedHTMLInSVG: React.FC<EmbeddedHTMLInSVGProps> = ({ children, width, height, x, y }) => {
  const curScale = useContext(SvgContext);

  const localWidth = typeof width === 'string' ? parseInt(width) : width;
  const localHeight = typeof height === 'string' ? parseInt(height) : height;
  const localX = typeof x === 'string' ? parseInt(x) : x;
  const localY = typeof y === 'string' ? parseInt(y) : y;

  return (
    <animated.foreignObject
      width={localWidth}
      height={localHeight}
      x={x}
      y={y}

    >
      <animated.div
        //xmlns="http://www.w3.org/1999/xhtml"
        style={{
          position: 'relative',
          width: localWidth,
          height: localHeight,
          scale: curScale,
        }}>
        {children}
        {/*
          <body>
            {children}
          </body>
          */}
      </animated.div>
    </animated.foreignObject>
  );
};

export default EmbeddedHTMLInSVG;
