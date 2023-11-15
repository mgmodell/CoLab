import React, { ReactNode, createContext, useContext } from 'react';
import { SvgContext } from './ResizableSVG';

interface EmbeddedHTMLInSVGProps {
  children: ReactNode;
  width: string;
  height: string;
}


const EmbeddedHTMLInSVG: React.FC<EmbeddedHTMLInSVGProps> = ({ children, width, height }) => {
  const curScale = useContext( SvgContext );


  return (
      <foreignObject width={width} height={height}
      >
        <div xmlns="http://www.w3.org/1999/xhtml" style={{
          width: parseInt( width ),
          height: parseInt( height ),
          scale: curScale,
        }}>
          {children}
        </div>
      </foreignObject>
  );
};

export default EmbeddedHTMLInSVG;
