import React, { ReactNode, createContext, useContext } from 'react';
import { SvgContext } from './ResizableSVG';
import { SpringValue, animated } from 'react-spring';

interface EmbeddedHTMLInSVGProps {
  children: ReactNode;
  width: string | SpringValue<number>;
  height: string | SpringValue<number>;
}


const EmbeddedHTMLInSVG: React.FC<EmbeddedHTMLInSVGProps> = ({ children, width, height }) => {
  const curScale = useContext( SvgContext );

  const localWidth = typeof width === 'string' ? parseInt( width ) : width;
  const localHeight = typeof height === 'string' ? parseInt( height ) : height;

  return (
      <animated.foreignObject width={width} height={localHeight}
      >
        <animated.html xmlns="http://www.w3.org/1999/xhtml" style={{
          position: 'relative',
          width: typeof width === 'string' ? parseInt( width ) : width,
          height: typeof height === 'string' ? parseInt( height ) : height,
          scale: curScale,
        }}>
          <body>
            {children}
          </body>
        </animated.html>
      </animated.foreignObject>
  );
};

export default EmbeddedHTMLInSVG;
