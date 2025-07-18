import React, { Fragment } from "react";

import WordCloud from "@visx/wordcloud/lib/Wordcloud";
import { scaleLog } from "@visx/scale";
import { Text } from "@visx/text";
import { Button } from "primereact/button";

interface WordData {
  text: string;
  value: number;
}

interface WordCloudProps {
  width: number;
  height: number;
  words: string[];
  colors?: string[];
}

export default function ResponsesWordCloud(props: WordCloudProps) {
  const { words, width, height, colors } = props;

  const wordFreq = (words: string[]): WordData[] => {
    const freqMap: Record<string, number> = {};

    for (const w of words) {
      if (!freqMap[w]) freqMap[w] = 0;
      freqMap[w] += 1;
    }
    return Object.keys(freqMap).map(word => ({
      text: word,
      value: freqMap[word]
    }));
  };

  const foundWords = wordFreq(words);
  const [archimedianSpiral, setArchimedianSpiral] = React.useState(true);
  const toggleSpiral = () => setArchimedianSpiral(!archimedianSpiral);


  /* Borrowed from StackOverflow
  https://stackoverflow.com/questions/28226677/save-inline-svg-as-jpeg-png-svg
  */
  const downloadWordCloudPng = () => {
    const svgNode = document.getElementById("wordcloud");
    const svgString = new XMLSerializer().serializeToString(svgNode);
    const svgBlob = new Blob([svgString], { type: "image/svg+xml;charset=utf-8" });

    const DOMURL = window.URL || window.webkitURL || window;
    const url = DOMURL.createObjectURL(svgBlob);

    const image = new Image();
    image.width = svgNode.width.baseVal.value;
    image.height = svgNode.height.baseVal.value;
    image.src = url;

    image.onload = () => {
      const canvas = document.createElement("canvas");
      canvas.width = image.width;
      canvas.height = image.height;

      const ctx = canvas.getContext("2d");
      ctx.drawImage(image, 0, 0);

      const imgURI = canvas.toDataURL("image/png")
        .replace("image/png", "image/octet-stream");
      const a = document.createElement("a");
      a.href = imgURI;
      a.target = "_blank";
      a.download = "wordcloud.png";

      a.click();
    }

  };

  const fontScale = scaleLog({
    domain: [
      Math.min(...foundWords.map(w => w.value)),
      Math.max(...foundWords.map(w => w.value))
    ],
    range: [10, 100]
  });

  return (
    <Fragment>
      <Button label="Download as PNG" onClick={downloadWordCloudPng} />
      <Button label={`Mix it up`} onClick={toggleSpiral} />

    <svg id="wordcloud" width={width} height={height}>
      <WordCloud
        height={400}
        width={400}
        words={foundWords}
        spiral={archimedianSpiral ? "archimedean" : "rectangular"}
        font={"Impact"}
        fontSize={(datum: WordData) => fontScale(datum.value)}
        rotate={() => {
          const rand = Math.random();
          const degree = rand > 0.5 ? 60 : -60;
          return rand * degree;
        }}
        random={Math.random}
      >
        {cloudWords =>
          cloudWords.map((word, index) => (
            <Text
              key={word.text}
              fill={colors[index % colors.length]}
              textAnchor="middle"
              transform={`translate(${word.x}, ${word.y}) rotate(${
                word.rotate
              })`}
              fontSize={word.size}
              fontFamily={word.font}
            >
              {word.text}
            </Text>
          ))
        }
      </WordCloud>
    </svg>
    </Fragment>
  );
}
