import React, { ReactNode, createContext, useContext } from "react";
import { SvgContext } from "./ResizableSVG";
import { SpringValue, animated } from "react-spring";

interface Props {
  children: ReactNode;
  width: string | SpringValue<number> | number;
  height: string | SpringValue<number> | number;
  x?: string | SpringValue<number> | number;
  y?: string | SpringValue<number> | number;
}

const EmbeddedHTMLInSVG: React.FC<Props> = ({
  children,
  width,
  height,
  x,
  y
}) => {
  const curScale = useContext(SvgContext);

  const localWidth = typeof width === "string" ? parseInt(width) : width;
  const localHeight = typeof height === "string" ? parseInt(height) : height;
  const localX = typeof x === "string" ? parseInt(x) : x;
  const localY = typeof y === "string" ? parseInt(y) : y;

  return (
    <animated.foreignObject
      width={localWidth}
      height={localHeight}
      x={localX}
      y={localY}
    >
      <animated.div
        //xmlns="http://www.w3.org/1999/xhtml"
        style={{
          position: "relative",
          width: localWidth,
          height: localHeight,
          scale: curScale
        }}
      >
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
