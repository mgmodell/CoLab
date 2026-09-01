import axios from "axios";

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

const handleDownload = (url: string, filename: string, event: React.MouseEvent)=> {
  event.preventDefault();
  axios.get( url, { responseType: "blob" } )
  .then((response) => {
    const blob = new Blob( [response.data]);
    const downloadUrl = window.URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = downloadUrl;
    link.setAttribute( 'download', filename );
    document.body.appendChild(link);
    link.click();
    link.remove();
  })
  .catch((error) => {
    console.error("Error downloading file:", error);
  });
}

export { utcAdjustString, utcAdjustDate, utcAdjustEndDate, handleDownload }; 
