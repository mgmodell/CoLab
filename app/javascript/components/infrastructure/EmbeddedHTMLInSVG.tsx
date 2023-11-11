import { width } from '@mui/system';
import React, { ReactNode } from 'react';

interface EmbeddedHTMLInSVGProps {
  children: ReactNode;
  width: string;
  height: string;
}

const EmbeddedHTMLInSVG: React.FC<EmbeddedHTMLInSVGProps> = ({ children, width, height }) => {
  return (
      <foreignObject width={width} height={height}>
        <div xmlns="http://www.w3.org/1999/xhtml" style={{ width: '100%', height: '100%' }}>
          {children}
        </div>
      </foreignObject>
  );
};

export default EmbeddedHTMLInSVG;
