const utcAdjustDate = (date: Date) => {
  return new Date(date.getTime() + date.getTimezoneOffset() * 60000);
};

const utcAdjustString = (date: string) => {
  const tmpDate =  new Date( Date.parse(date) );
  return new Date(tmpDate.getTime() + tmpDate.getTimezoneOffset() * 60000);
};

const utcAdjustEndDate = (date: Date) => {
  if (date == null) {
    return date;
  } else {
    const tmpDate = new Date(date.getTime() + date.getTimezoneOffset() * 60000);
    return new Date( tmpDate.setHours(tmpDate.getHours() - 23) - 59 * 60000 );
  }
}

export { utcAdjustString, utcAdjustDate, utcAdjustEndDate }; 
