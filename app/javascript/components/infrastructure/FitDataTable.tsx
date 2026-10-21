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
 * its own top edge) and scrolls internally instead of paginating. The
 * space used by the table's own toolbar, column headings/filters and footer
 * is measured and subtracted from the height given to the scrolling body.
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
    const available = window.innerHeight - top - BOTTOM_MARGIN;
    // Space used by everything in the table other than its scrolling body:
    // toolbar/header, column headings and filters, and footer.
    const body = el.querySelector(".p-datatable-scrollable-body") as HTMLElement | null;
    const root = el.querySelector(".p-datatable") as HTMLElement | null;
    const chrome = body && root ? Math.max(0, root.offsetHeight - body.offsetHeight) : 0;
    setHeight(Math.max(MIN_HEIGHT, Math.floor(available - chrome)));
  }, []);

  useLayoutEffect(recalc);

  useEffect(() => {
    window.addEventListener("resize", recalc);
    let observer: ResizeObserver | undefined;
    if (typeof ResizeObserver !== "undefined") {
      observer = new ResizeObserver(recalc);
      observer.observe(document.body);
      const root = wrapperRef.current?.querySelector(".p-datatable");
      if (root) {
        observer.observe(root);
      }
    }
    return () => {
      window.removeEventListener("resize", recalc);
      observer?.disconnect();
    };
  }, [recalc]);

  return (
    <div ref={wrapperRef} className="fit-data-table">
      <DataTable {...tableProps} scrollable scrollHeight={`${height}px`} />
    </div>
  );
}
