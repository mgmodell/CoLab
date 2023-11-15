/*
This code began life as a ChatGPT3 response to a prompt. The initial prompt was:
' write me javascript code for an SVG that automatically resizes to fit the window
 at a 3:4 aspect ratio'
 */
import React, { useEffect, ReactNode, useRef, useState, createContext } from 'react';

interface ResizableSVGProps {
  children: ReactNode;
  id: string;
  height: number;
  width: number;
}


export const SvgContext = createContext( null );

const ResizableSVG: React.FC<ResizableSVGProps> = ({ children, id, height, width }) => {

    const containerRef = useRef( );

      const [curHeight, setCurHeight] = useState( height );
      const [curWidth, setCurWidth] = useState( width );
      const [curScale, setCurScale] = useState( 1 );


  useEffect(() => {
    // Function to update the SVG size based on the window size
    const resizeSVG = () => {
      const svg = document.getElementById(id) as unknown as SVGSVGElement;
      // const parent = (containerRef.current as SVGSVGElement).parentElement;



      if (svg) {
        const windowWidth = window.innerWidth - 50; // parent.clientWidth;
        const windowHeight = window.innerHeight - 130; // parent.clientHeight;

        // Calculate the new width and height to maintain a 3:4 aspect ratio
        let newWidth, newHeight;
        if (windowWidth / width > windowHeight / height) {
          newWidth = (windowHeight * width) / height;
          newHeight = windowHeight;
          setCurScale( height / newHeight );
        } else {
          newWidth = windowWidth;
          newHeight = ( (windowWidth * height) / width );
          setCurScale( width / newWidth );
        }

        // Set the SVG width and height attributes
        //svg.setAttribute('width', newWidth.toString());
        //svg.setAttribute('height', newHeight.toString());
        setCurHeight( newHeight );
        setCurWidth( newWidth );
      }
    };

    // Initial SVG resizing
    resizeSVG();

    // Attach a resize event listener to update the SVG when the window is resized
    window.addEventListener('resize', resizeSVG);

    // Clean up the event listener when the component unmounts
    return () => {
      window.removeEventListener('resize', resizeSVG);
    };
  }, []);

  return (
    <SvgContext.Provider value={curScale} >

    <div style={{
        width: curWidth,
        height: curHeight,
    }}
    >

    <svg id={id} xmlns="http://www.w3.org/2000/svg" viewBox={`0 0 ${width} ${height}`} >
      {children}
    </svg>
    </div>
    </SvgContext.Provider>
  );
};

export default ResizableSVG;
