import React, { useCallback, useEffect, useLayoutEffect, useRef, useState } from "react";
import { DataTable, type DataTableProps, type DataTableValueArray } from "primereact/datatable";

const BOTTOM_MARGIN = 16;
const MIN_HEIGHT = 200;

// Props that only make sense for a paginated table; the table scrolls instead.
type PaginationProps =
  | "paginator"
  | "rows"
  | "first"
  | "rowsPerPageOptions"
  | "paginatorTemplate"
  | "paginatorDropdownAppendTo"
  | "paginatorLeft"
  | "paginatorRight"
  | "paginatorPosition"
  | "paginatorClassName"
  | "currentPageReportTemplate"
  | "alwaysShowPaginator";

type Props = Omit<DataTableProps<DataTableValueArray>, PaginationProps | "scrollable" | "scrollHeight"> & {
  [key: string]: any;
};

/**
 * A DataTable that fills the vertical space remaining in the window (below
 * its own top edge) and scrolls internally instead of paginating. The wrapper
 * gets the fixed height and the table fills it ("flex"), so the table's own
 * header, column headings and footer are included in the height budget.
 */
export default function FitDataTable(props: Props) {
  const {
    paginator,
    rows,
    first,
    rowsPerPageOptions,
    paginatorTemplate,
    paginatorDropdownAppendTo,
    paginatorLeft,
    paginatorRight,
    paginatorPosition,
    paginatorClassName,
    currentPageReportTemplate,
    alwaysShowPaginator,
    scrollable,
    scrollHeight,
    ...tableProps
  } = props as any;

  const wrapperRef = useRef<HTMLDivElement>(null);
  const [height, setHeight] = useState<number>(MIN_HEIGHT * 2);

  const recalc = useCallback(() => {
    const el = wrapperRef.current;
    if (!el) return;
    const top = el.getBoundingClientRect().top;
    setHeight(Math.max(MIN_HEIGHT, Math.floor(window.innerHeight - top - BOTTOM_MARGIN)));
  }, []);

  useLayoutEffect(recalc);

  useEffect(() => {
    window.addEventListener("resize", recalc);
    let observer: ResizeObserver | undefined;
    if (typeof ResizeObserver !== "undefined") {
      observer = new ResizeObserver(recalc);
      observer.observe(document.body);
    }
    return () => {
      window.removeEventListener("resize", recalc);
      observer?.disconnect();
    };
  }, [recalc]);

  return (
    <div ref={wrapperRef} className="fit-data-table" style={{ height: `${height}px` }}>
      <DataTable {...tableProps} scrollable scrollHeight="flex" />
    </div>
  );
}
