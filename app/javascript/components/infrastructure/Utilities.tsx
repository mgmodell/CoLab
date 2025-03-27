const utcAdjust = (date: string) => {
  const tmpDate =  new Date( Date.parse(date) );
  return new Date(tmpDate.getTime() + tmpDate.getTimezoneOffset() * 60000);
};

export { utcAdjust };
