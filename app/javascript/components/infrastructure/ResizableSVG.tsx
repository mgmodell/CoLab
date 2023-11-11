/*
This code began life as a ChatGPT3 response to a prompt. The initial prompt was:
' write me javascript code for an SVG that automatically resizes to fit the window
 at a 3:4 aspect ratio'
 */
import React, { useEffect, ReactNode, useRef } from 'react';

interface ResizableSVGProps {
  children: ReactNode;
  id: string;
  height: number;
  width: number;
}


const ResizableSVG: React.FC<ResizableSVGProps> = ({ children, id, height, width }) => {
    const containerRef = useRef( );

  useEffect(() => {
    // Function to update the SVG size based on the window size
    const resizeSVG = () => {
      const svg = document.getElementById(id) as unknown as SVGSVGElement;
      const parent = (containerRef.current as SVGSVGElement).parentElement;


      if (svg) {
        const parentWidth = window.innerWidth; // parent.clientWidth;
        const parentHeight = window.innerHeight; // parent.clientHeight;

        // Calculate the new width and height to maintain a 3:4 aspect ratio
        let newWidth, newHeight;
        if (parentWidth / width > parentHeight / height) {
          newWidth = (parentHeight * width) / height;
          newHeight = parentHeight - 200;
        } else {
          newWidth = parentWidth;
          newHeight = ( (parentWidth * height) / width ) - 200;
        }

        // Set the SVG width and height attributes
        svg.setAttribute('width', newWidth.toString());
        svg.setAttribute('height', newHeight.toString());
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
    <svg id={id} ref={containerRef}  xmlns="http://www.w3.org/2000/svg" viewBox={`0 0 ${height} ${width}`} >
      {children}
    </svg>
  );
};

export default ResizableSVG;
