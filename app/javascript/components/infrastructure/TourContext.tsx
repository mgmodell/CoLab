import React, { createContext, useContext, useState } from "react";
import type { DriveStep } from "driver.js";

interface TourContextValue {
  tourSteps: DriveStep[];
  setTourSteps: (steps: DriveStep[]) => void;
}

const TourContext = createContext<TourContextValue>({
  tourSteps: [],
  setTourSteps: () => {}
});

type Props = {
  children: React.ReactNode;
};

export function TourProvider(props: Props) {
  const [tourSteps, setTourSteps] = useState<DriveStep[]>([]);

  return (
    <TourContext.Provider value={{ tourSteps, setTourSteps }}>
      {props.children}
    </TourContext.Provider>
  );
}

export function useTour(): TourContextValue {
  return useContext(TourContext);
}
