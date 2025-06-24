import React from "react";

import WordCloud from "@visx/wordcloud/lib/Wordcloud";
import { scaleLog } from "@visx/scale";
import { Text } from "@visx/text";

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

  const fontScale = scaleLog({
    domain: [
      Math.min(...foundWords.map(w => w.value)),
      Math.max(...foundWords.map(w => w.value))
    ],
    range: [10, 100]
  });

  return (
    <svg width={width} height={height}>
      <WordCloud
        height={400}
        width={400}
        words={foundWords}
        spiral={"archimedean"}
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
  );
}
